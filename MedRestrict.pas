unit MedRestrict;

interface

uses
  LatTypes;

const
  MRC_bGENERAL      =        0;
  MRC_bSNAP         =        1;
  MRC_bWIC          =        2;
  MRC_bFUEL         =        3;
  MRC_bMAINT        =        4;
  MRC_bTOBACCO      =        5;
  MRC_bALCOHOL      =        6;
  MRC_bMONEYORDERS  =        7;
  MRC_bCASHPRODUCTS =        8;
  MRC_bLOTTERY      =        9;
  MRC_bSALESTAX     =       10;
  MRC_bOUTSIDEFUEL  =       11;
  MRC_bACTIVATED    =       12;
  MRC_bCARWASH      =       13;
  MRC_bNEGATE       =       31;

  MRC_UNKNOWN       = longword(0);
  MRC_GENERAL       = longword(1 shl MRC_bGENERAL);
  MRC_SNAP          = longword(1 shl MRC_bSNAP);
  MRC_WIC           = longword(1 shl MRC_bWIC);
  MRC_FUEL          = longword(1 shl MRC_bFUEL);
  MRC_MAINT         = longword(1 shl MRC_bMAINT);
  MRC_TOBACCO       = longword(1 shl MRC_bTOBACCO);
  MRC_ALCOHOL       = longword(1 shl MRC_bALCOHOL);
  MRC_MONEYORDERS   = longword(1 shl MRC_bMONEYORDERS);
  MRC_CASHPRODUCTS  = longword(1 shl MRC_bCASHPRODUCTS);
  MRC_LOTTERY       = longword(1 shl MRC_bLOTTERY);
  MRC_SALESTAX      = longword(1 shl MRC_bSALESTAX);
  MRC_OUTSIDEFUEL   = longword(1 shl MRC_bOUTSIDEFUEL);
  MRC_ACTIVATED     = longword(1 shl MRC_bACTIVATED);
  MRC_CARWASH       = longword(1 shl MRC_bCARWASH);
  MRC_NEGATE        = longword(1 shl MRC_bNEGATE);
  MRC_UNRESTRICTED  = MRC_NEGATE - 1;
  MRC_CREDITDEFAULT = MRC_UNRESTRICTED - MRC_MONEYORDERS - MRC_LOTTERY;

function CanPayForTotal(const mr : longword; const sales : TNotList) : currency;
function CanPayFor(const mr : longword; const sales : TNotList) : TNotList;
function RestrictionCodeToString(const mr : longword) : string;
function SalesTotal(const sales : TNotList) : currency;
function NeedsPayment(const sd : pSalesData) : currency;
function PaidForWithAuthID(const sd : pSalesData; const AuthID : integer) : currency;

implementation

uses
  SysUtils,
  Classes,
  POSMisc,
  JCLStringLists,
  ExceptLog;

function RestrictionName(const s : byte) : string;
begin
  case s of
    MRC_bGENERAL     : Result := 'General';
    MRC_bSNAP        : Result := 'SNAP';
    MRC_bWIC         : Result := 'WIC';
    MRC_bFUEL        : Result := 'Fuel';
    MRC_bMAINT       : Result := 'Maintenance';
    MRC_bTOBACCO     : Result := 'Tobacco';
    MRC_bALCOHOL     : Result := 'Alcohol';
    MRC_bMONEYORDERS : Result := 'Money Orders';
    MRC_bCASHPRODUCTS: Result := 'Cash Products';
    MRC_bLOTTERY     : Result := 'Lottery';
    MRC_bSALESTAX    : Result := 'Sales Tax';
    MRC_bOUTSIDEFUEL : Result := 'Outside Fuel';
    MRC_bACTIVATED   : Result := 'Activated Items';
    MRC_bCARWASH     : Result := 'Carwash';
  else
    Result := '';
  end;
end;

function RestrictionCodeToString(const mr : longword) : string;
var
  i : byte;
  sl : TStringList;
  n : string;
begin
  sl := TStringList.Create();
  try
    for i := 0 to pred(MRC_bNEGATE) do
      if BitSet(mr, i) then
      begin
        n := RestrictionName(i);
        if n <> '' then
          sl.Add(n);
      end;
    if sl.Count > 0 then
    begin
      if bitset(mr, MRC_bNEGATE) then n := 'NOT '
        else n := '';
      Result := n + JCLStringListStrings(sl).Join(',');
    end
    else
      Result := 'None';
  finally
    sl.Destroy;
  end;
end;

function NeedsPayment(const sd : pSalesData) : currency;
var
  i : integer;
  r : boolean;
begin
  Result := 0;
  r := ((SD^.LineType = 'PLU') or
        (SD^.LineType = 'DPT') or
        (SD^.LineType = 'FUL') or
        (SD^.LineType = 'PPY') or
        (SD^.LineType = 'PRF') or
        (SD^.LineType = 'DSC'))
        and (SD^.LineVoided = False)
        and ((SD^.SaleType = 'Sale') or (SD^.SaleType = 'Rtrn'))
        or (SD^.LineType = 'TAX');
  if r then
  begin
    Result := sd^.ExtPrice;
    // Remove paid for amounts from this sum
    if ( Result <> 0 ) and assigned( sd^.Paidlist ) then
      for i := 0 to pred( sd^.Paidlist.Count ) do
        Result := Result - pPaymentInfo( sd^.paidlist[i] ).Amount;
  end;
end;

function PaidForWithAuthID(const sd : pSalesData ; const authid : integer) : currency;
var
  i : integer;
  r : boolean;
begin
  Result := 0;
  r := (((SD^.LineType = 'PLU') or
         (SD^.LineType = 'DPT') or
         (SD^.LineType = 'PPY'))
         and (SD^.LineVoided = False)
         and (SD^.SaleType = 'Sale') or
         (SD^.LineType = 'TAX') )
       and assigned( sd^.Paidlist );
  if r then
    for i := 0 to pred( sd^.paidlist.Count ) do
      if pPaymentInfo( sd^.paidlist[i] ).AuthID = authid then
        Result := Result + pPaymentInfo( sd^.paidlist[i] ).Amount;
end;

function CanPayForLine(const mr : longword; const sd : pSalesData) : boolean;
begin
  if mr = 0 then
    Result := True  // If media has no restrictions, treat it as unrestricted
  else
    if bitset(mr, MRC_bNEGATE) then
      Result := ((mr - MRC_NEGATE) and sd.mediarestrictioncode) = 0
    else
      Result := (sd.mediarestrictioncode and mr) > 0;
end;

function CanPayFor(const mr : longword; const sales : TNotList) : TNotList;
var
  i : integer;
  c : integer;
  sd : pSalesData;
  l : TNotList;
  np : currency;
begin
  {$IFDEF DEBUG} UpdateZLog('CanPayFor mr=%08x', [mr]); {$ENDIF}
  l := TNotList.Create;
  c := sales.Count;
  if c > 0 then
    for i := 0 to pred(c) do
    begin
      sd := sales.Items[i];
      np := NeedsPayment(sd);
      {$IFDEF DEBUG} UpdateZLog('CPF %03d %-30.30s %3.3s %6.2g mr=%08x', [i, sd.name, sd.linetype, np, sd.mediarestrictioncode]); {$ENDIF}
      if ( np <> 0 ) and CanPayForLine(mr, sd) then
        l.Add(sd);
    end;
  Result := l;
end;

function SalesTotal(const sales : TNotList) : currency;
var
  i : integer;
begin
  Result := 0;
  if sales.count > 0 then
    for i := 0 to pred(sales.count) do
      Result := Result + NeedsPayment( pSalesData( sales[i] ) );
end;

function CanPayForTotal(const mr : longword; const sales : TNotList) : currency;
var
  i : integer;
  c : integer;
  sd : pSalesData;
  l : TNotList;
  r : Currency;
begin
  l := CanPayFor(mr, sales);
  r := 0;
  c := l.Count;
  if c > 0 then
    for i := 0 to pred(c) do
    begin
      sd := l.Items[i];
      if CanPayForLine(mr, sd) then
        r := r + NeedsPayment(sd);
    end;
  Result := r;
  l.Free();
end;

end.

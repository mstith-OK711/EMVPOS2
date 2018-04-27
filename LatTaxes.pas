unit LatTaxes;
{$I ConditionalCompileSymbols.txt}

interface

uses
  Classes,
  LatTypes
  ;

type
  TDBTax = record
    TaxNo : smallint;
    Name : string[20];
    Rate : currency;
    TaxType : smallint;
    FirstCent : currency;
    SalesTax : boolean;
  end;
  pDBTax = ^TDBTax;

  TDBTaxTable = record
    TaxNo : smallint;
    SeqNo : smallint;
    RefNo : smallint;
    Increment : smallint;
    TypeStr : string[20];
    RecType : integer;
  end;
  pDBTaxTable = ^TDBTaxTable;

  TDBPLUTax = record
    PLU : currency;
    taxno : smallint;
  end;
  pDBPLUTax = ^TDBPLUTax;

  TTaxTable = record
    Increment   : array[1..50] of currency;
    RepeatCount : array[1..50] of integer;
    CurCount    : array[1..50] of integer;
    StepType    : array[1..50] of integer;
  end;
  pTaxTable = ^TTaxTable;

  TCurTax = record
    TaxNo       : smallint;
    Taxable     : Currency;
    TaxQty      : Currency;
    TaxCharged  : Currency;
    CalcAmount  : currency;
    FSTaxExemptSales : currency;    // Food stamp sale amount exempted from sales tax
    FSTaxExemptAmount : currency;   // Food stamp sales tax exempted
  end;
  pCurTax = ^TCurTax;

var
  lTax      : TThreadList;
  lPLUTax   : TThreadList;
  lTaxTable : TThreadList;

const
  TAX_TYPE_RATE  = 1;
  TAX_TYPE_TABLE = 2;
  TAX_TYPE_QTY   = 3;

procedure InitTaxTables();
procedure LoadPLUTax();
function ItemTaxed(const CurSaleData : pSalesData) : boolean;
function FindFirstPLUTax(pt : TList; PLU : currency) : integer;
procedure ReleaseTaxTables();

procedure ClearTaxListEntries(const tl: pTList);
procedure AllocateTaxes(var SD: pSalesData; var qTaxList: pTList; const taxexempt : boolean);
function ComputeTaxes(var qTaxList: pTList) : Currency;

implementation

uses
  SysUtils,
  POSDM,
  ExceptLog,
  POSMisc;

procedure InitTaxTables();
begin
  lTax      := TThreadList.Create;
  lPLUTax   := TThreadList.Create;
  lTaxTable := TThreadList.Create;

end;

function FindFirstPLUTax(pt : TList; PLU : currency) : integer;
var
  i : integer;
  pdbpt : pDBPLUTax;
begin
  // TODO: This really should be a binary search
  Result := -1;
  i := 0;
  while (i < pt.Count) do
  begin
    pdbpt := pt.Items[i];
    if pdbpt.PLU = PLU then
    begin
      Result := i;
      break;
    end
    else
      inc(i);
  end;
  if i >= pt.Count then
    Result := -1;
end;

procedure LoadPLUTax();
var
  pPT : pDBPLUTax;
  tl : TList;
begin
{$IFDEF MULTI_TAX}
  tl := lPLUTax.LockList;
  try
    DisposeTlistItems(tl);
    tl.Pack;
    with POSDataMod.IBTempQuery do
    begin
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      SQL.Clear;
      SQL.Add('SELECT * FROM PLUTax Order by PLUNo, TaxNo');
      Open;
      while not EOF do
      begin
        new(pPT);
        pPT^.PLU := fieldbyname('PLUNo').AsCurrency;
        pPT^.taxno := fieldbyname('TaxNo').AsInteger;
        tl.Add(pPT);
        next;
      end;
      close;
      Transaction.commit;
    end;
  finally
    UpdateZLog('Loaded %d PLUTax entries', [tl.Count]);
    lPLUTax.UnlockList;
  end;
{$ENDIF}
end;

{ Returns boolean to indicate if sales item is taxable. }
function ItemTaxed(const CurSaleData : pSalesData) : boolean;
var
  plutaxlist : TList;
begin
  Result := False;
  if CurSaleData^.TaxNo > 0 then
    Result := True
  else
  begin
    {$IFDEF MULTI_TAX}
    if (CurSaleData^.TaxNo = MULTITAX_PLU) and (CurSaleData^.LineType = 'PLU') then // possible Mult Tax
    begin
      plutaxlist := lPLUTax.LockList;
      try
        if plutaxlist.Count > 0  then
          Result := (FindFirstPLUTax(plutaxlist, CurSaleData^.Number) >= 0);
      finally
        lPLUTax.UnlockList;
      end;
    end // if possible multi-tax
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;
end;

procedure ReleaseTaxTables();
begin
  if assigned(lTax) then
  begin
    try
      DisposeTlistItems(lTax.LockList);
    finally
      lTax.UnlockList;
    end;
    FreeAndNil(lTax);
  end;

  if assigned(lPLUTax) then
  begin
    try
      DisposeTListItems(lPLUTax.LockList);
    finally
      lPLUTax.UnlockList;
    end;
    FreeAndNil(lPLUTax);
  end;

  if assigned(lTaxTable) then
  begin
    try
      DisposeTListItems(lTaxTable.LockList);
    finally
      lTaxTable.UnlockList;
    end;
    FreeAndNil(lTaxTable);
  end;
end;

function AddTax(ST : pSalesTax; ndx : integer) : boolean;
begin

  AddTax := True;
  ST^.CalcAmount := ST^.CalcAmount + ST^.Increment[ndx];
  if ST^.CalcAmount < Abs(ST^.Taxable) then
  begin
    ST^.TaxCharged := ST^.TaxCharged + 0.01;
  end
  else
    AddTax := False;

end;

function ComputeTaxes(var qTaxList: pTList) : Currency;
var
  i : integer;
  ST: pSalesTax;
  taxndx: Integer;
begin
  Result := 0.0;
  for i := 1 to qTaxList^.Count - 1 do
  begin
    ST := qTaxList^.Items[i];
    if (ST^.TaxType = TAX_TYPE_QTY) then // Flat tax per item
    begin
      ST^.TaxCharged := POSRound(ST^.TaxQty * ST^.TaxRate, 2);
    end
    else   if (ST^.TaxType = TAX_TYPE_RATE) then // Tax Rate
    begin
      if (Abs(ST^.Taxable) < ST^.FirstPenny) then
        ST^.TaxCharged := 0
      else
        ST^.TaxCharged := POSRound(ST^.Taxable * ST^.TaxRate, 2);
    end
    else // Tax Table
    begin
      ST^.TaxCharged := 0;
      ST^.CalcAmount := 0;
      taxndx := 1;
      while True do
      begin
        case ST^.StepType[TaxNdx] of
          1: //Increment
          begin
            if Not AddTax(ST, TaxNdx) then
              break;
            Inc(TaxNdx, 1);
          end;
          2: //Repeat Increment
          begin
            if ST^.CurCount[TaxNdx] = 0  then
            begin
              ST^.CurCount[TaxNdx] := ST^.RepeatCount[TaxNdx];
              Inc(TaxNdx, 1);
            end
            else
            begin
              if Not AddTax(ST, TaxNdx) then
                break;
              Dec(ST^.CurCount[TaxNdx], 1);
            end;
          end;
          3: //LoopBack
          begin
            if ST^.CurCount[TaxNdx] = 0  then
            begin
              ST^.CurCount[TaxNdx] := ST^.RepeatCount[TaxNdx] - 1;
              Inc(TaxNdx, 1);
            end
            else
            begin
              Dec(ST^.CurCount[TaxNdx], 1);
              TaxNdx := Trunc(ST^.Increment[TaxNdx] * 100);
            end;
          end;
          4: //Jump
          begin
            TaxNdx := Trunc(ST^.Increment[TaxNdx] * 100);
          end;
        else
          break;
        end; //Case
      end; // while true
    end; // else (i.e., tax table)
  Result := Result + ST^.TaxCharged;
  end; // for i:= 1 to qTaxList^.Count-1
end;

procedure ClearTaxListEntries(const tl: pTList);
var
  i: integer;
  ST : pSalesTax;
begin
  for i := 0 to tl^.Count - 1 do
  begin
    ST := tl^.Items[i];
    ST^.Taxable := 0;
    ST^.TaxCharged := 0;
    ST^.TaxQty := 0;
    ST^.FSTaxExemptSales := 0;
    ST^.FSTaxExemptAmount := 0;
  end;
end;

procedure UpdateSalesTaxRec(ST : pSalesTax; qty, extprice : currency);
begin
  ST^.TaxQty :=  ST^.TaxQty + Qty;
  ST^.Taxable :=  ST^.Taxable + POSRound(ExtPrice, 2);
end;

function FindTaxRecord(qtaxlist : pTList; taxno : smallint) : pSalesTax;
var
  i : integer;
begin
  Result := pSalesTax(qtaxlist^.Items[0]);
  for i := 0 to qtaxlist^.Count - 1 do
  begin
    if pSalesTax(qtaxlist^.Items[i]).TaxNo = taxno then
    begin
      Result := pSalesTax(qtaxlist^.Items[i]);
      break;
    end;
  end;
end;

procedure AllocateTaxes(var SD: pSalesData; var qTaxList: pTList; const taxexempt : boolean);
  procedure alloc(var SD: pSalesData; var qTaxList: pTList; taxno : smallint; te : boolean);
  var
    ST : pSalesTax;
  begin
    ST := FindTaxRecord(qTaxList, taxno);
    if ST^.SalesTax and te then
      ST := FindTaxRecord(qTaxList, 0);
    UpdateSalesTaxRec(ST, SD^.Qty, SD^.ExtPrice);
  end;
var
  plutaxlist : TList;
  i : integer;
begin
  {$IFDEF MULTI_TAX}
  if (SD^.TaxNo = MULTITAX_PLU) and (SD^.LineType = 'PLU') then // possible Mult Tax
  begin
    plutaxlist := lPLUTax.LockList;
    try
      if plutaxlist.Count = 0  then
        alloc(SD, qTaxList, SD^.TaxNo, taxexempt)
      else
      begin
        i := FindFirstPLUTax(plutaxlist, SD^.Number);
        if i < 0  then
          alloc(SD, qTaxList, SD^.TaxNo, taxexempt)
        else
        while (i < plutaxlist.Count) and (pDBPLUTax(plutaxlist[i]).PLU = SD^.Number) do
        begin
          alloc(SD, qTaxList, pDBPLUTax(plutaxlist[i]).taxno, taxexempt);
          inc(i);
        end;
      end;
    finally
      lPLUTax.UnlockList;
    end;
  end // if possible multi-tax
  else
    alloc(SD, qTaxList, SD^.TaxNo, taxexempt);
  {$ELSE}
  alloc(SD, qTaxList, SD^.TaxNo, taxexempt);
  {$ENDIF}
end;
  
end.
 
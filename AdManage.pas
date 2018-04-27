unit AdManage;

interface

uses
  SysUtils, Classes, DB, IBSQL, IBStoredProc, IBCustomDataSet;

type
  TAdManageMod = class(TDataModule)
    AdLoad: TIBSQL;
    AdvedPLULoad: TIBSQL;
    AdReloadProc: TIBStoredProc;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FAdvedPLU : TThreadList;
    FAdsTbl : TThreadList;
    FCurDisp : smallint;
    FMaxAd : smallint;
    procedure AdvedPLUReload(Sender : TObject);
    procedure AdReload(Sender : TObject);
    function AdvPLUPrice(const PLUNO : currency) : currency;
  public
    { Public declarations }
    procedure Init();
    procedure SetMaxAd(const Value : smallint);
    property MaxAd : smallint read FMaxAd write SetMaxAd;
    function GoodAd(const DispNo : smallint; var adno : smallint) : boolean;
    function GetAdNo : smallint;
  end;

var
  AdManageMod: TAdManageMod;

implementation

uses
  POSDM,
  ExceptLog,
  POSMisc,
  Forms;

{$R *.dfm}

type
  TAdRec = record
    AdNo       : smallint;
    TimeBegin  : TDateTime;
    TimeEnd    : TDateTime;
    DateBegin  : TDateTime;
    DateEnd    : TDateTime;
    PLUNo      : currency;
    pricepoint : currency;
    DispOrder  : smallint;
  end;
  pAdRec = ^TAdRec;

  TAdvedPLURec = record
    PLUNo : currency;
    price : currency;
  end;
  pAdvedPLURec = ^TAdvedPLURec;


{ TAdManageMod }

procedure TAdManageMod.AdvedPLUReload(Sender: TObject);
var
  AdvedPLU : TList;
  prec : pAdvedPLURec;
begin
  UpdateZLog('Reloading Advertized PLU Prices');
  AdvedPLU := FAdvedPLU.LockList;
  try
    DisposeTListItems(AdvedPLU);
    AdvedPLU.Pack;
    with AdvedPLULoad do
    try
      Transaction.StartTransaction;
      ExecQuery;
      while not AdvedPLULoad.Eof do
      begin
        new(prec);
        prec^.PLUNo := FieldByName('PLUNO').AsCurrency;
        prec^.price := FieldByName('Price').AsCurrency;
        AdvedPLU.Add(prec);
        Next;
      end;
      Close();
      Transaction.Commit;
    except
      on E: Exception do
      begin
        Transaction.Rollback;
        UpdateExceptLog('TAdManageMod.AdvedPLUReload failed - %s - %s', [E.ClassName, E.Message]);
      end;
    end;
  finally
    FAdvedPLU.UnlockList;
  end;
end;

procedure TAdManageMod.AdReload(Sender: TObject);
var
  AdsTbl : TList;
  prec : pAdRec;
begin
  UpdateZLog('Reloading Ad data');
  AdsTbl := FAdsTbl.LockList;
  try
    DisposeTListItems(AdsTbl);
    AdsTbl.Pack;
    with AdLoad do
    try
      Transaction.StartTransaction;
      ExecQuery;
      while not AdLoad.Eof do
      begin
        if FieldByName('DispOrder').AsInteger > 0 then
        begin
          new(prec);
          prec^.AdNo            := FieldByName('AdNo').AsInteger;
          prec^.TimeBegin       := FieldByName('TimeBegin').AsTime;
          prec^.TimeEnd         := FieldByName('TimeEnd').AsTime;
          prec^.DateBegin       := FieldByName('DateBegin').AsDate;
          prec^.DateEnd         := FieldByName('DateEnd').AsDate;
          prec^.PLUNO           := FieldByName('PLUNO').AsCurrency;
          prec^.PricePoint      := FieldByName('PricePoint').AsCurrency;
          prec^.DispOrder       := FieldByName('DispOrder').AsInteger;
          AdsTbl.Add(prec);
        end;
        Next;
      end;
      Close();
      Transaction.Commit;
    except
      on E: Exception do
      begin
        Transaction.Rollback;
        UpdateExceptLog('TAdManageMod.AdReload failed - %s - %s', [E.ClassName, E.Message]);
      end;
    end;
  finally
    FAdsTbl.UnlockList;
  end;
end;

procedure TAdManageMod.Init;
var
  ts : TDateTime;
begin

  POSDataMod.RegIBEventNotification('AdReload', AdReload);
  POSDataMod.RegIBEventNotification('AdPriceChange', AdvedPLUReload);
  POSDataMod.IBNotify('AdReload');
  POSDataMod.IBNotify('AdPriceChange');
  if not POSDataMod.IBEvents.Registered then
  begin
    UpdateZLog('Registering IBEvents: %s', [POSDataMod.IBEvents.Events.CommaText]);
    POSDataMod.IBEvents.RegisterEvents;
    ts := Now();
    while not TimerExpiredms(ts, 250) do
      Application.ProcessMessages;
  end;

  {
  POSDataMod.IBAdTrans.StartTransaction;
  UpdateZLog('Executing DoAdReload');
  Self.AdReloadProc.ExecProc;
  POSDataMod.IBAdTrans.Commit;
  UpdateZLog('Done committing DoAdReload');
  }
end;

function TAdManageMod.GetAdNo: smallint;
var
  start : smallint;
  adno : smallint;
begin
  start := Self.FCurDisp;
  repeat
    adno := 0;
    Self.FCurDisp := (Self.FCurDisp mod Self.FMaxAd) + 1;
  until (start = Self.FCurDisp) or GoodAd(Self.FCurDisp, adno);
  Result := adno;
end;

function TAdManageMod.GoodAd(const dispno: smallint; var adno : smallint): boolean;
var
  AdsTbl : TList;
  AdRec : pAdRec;
  r : boolean;
  price : currency;
  CurTS : TDateTime;
  tts : TDateTime;
  i : integer;
begin
  CurTS := Now();
  r := False;
  AdRec := nil;
  AdsTbl := FAdsTbl.LockList;
  try
    for i := 0 to Pred(AdsTbl.Count) do
    begin
      AdRec := pAdRec(AdsTbl.Items[i]);
      if (AdRec <> nil) and (AdRec.DispOrder = dispno) then
      begin
        r := True;
        break;
      end;
    end;
    if r then
      r := (AdRec.AdNo <= Self.FMaxAd);
    if r and (AdRec.TimeBegin <> 0) and (AdRec.TimeEnd <> 0) then
    begin
      tts := Frac(CurTS);
      if AdRec.TimeBegin < AdRec.TimeEnd then
        r := (AdRec.TimeBegin <= tts) and (tts <= AdRec.TimeEnd)
      else
        r := (AdRec.TimeEnd <= tts) and (tts <= (AdRec.TimeEnd + 1));
    end;
    if r and (AdRec.DateBegin <> 0) and (AdRec.DateEnd <> 0) then
    begin
      tts := Trunc(CurTS);
      if AdRec.DateBegin < AdRec.DateEnd then
        r := (AdRec.DateBegin <= tts) and (tts <= AdRec.DateEnd)
      else // negative date range?
        r := False;
    end;
    if r and (AdRec.PLUNo <> 0) then
    begin
      if (AdRec.pricepoint <> 0) then
      begin
        price := AdvPLUPrice(AdRec.PLUNo);
        if price < 0 then
          r := False
        else
          r := (price = AdRec.pricepoint);
      end
      else
        r := False;
    end;
    Result := r;
    if r then
      adno := AdRec.AdNo;
  finally
    FAdsTbl.UnlockList;
  end;

end;

function TAdManageMod.AdvPLUPrice(const PLUNO: currency): currency;
var
  AdvedPLU : TList;
  AdvedPLURec : pAdvedPLURec;
  i : integer;
begin
  AdvPLUPrice := -1.0;
  AdvedPLU := FAdvedPLU.LockList;
  try
    for i := 0 to Pred(AdvedPLU.Count) do
    begin
      AdvedPLURec := AdvedPLU.Items[i];
      if PLUNO = AdvedPLURec.PLUNo then
      begin
        AdvPLUPrice := AdvedPLURec.price;
        break;
      end;
    end;
  finally
    FAdvedPLU.UnLockList;
  end;
end;

procedure TAdManageMod.SetMaxAd(const Value: smallint);
begin
  Self.FMaxAd := Value;
end;

procedure TAdManageMod.DataModuleCreate(Sender: TObject);
begin
  FAdvedPLU := TThreadList.Create;
  FAdsTbl := TThreadList.Create;
  Self.FMaxAd := 20;
  Self.FCurDisp := 1;
end;

procedure TAdManageMod.DataModuleDestroy(Sender: TObject);
begin
  try
    DisposeTListItems(FAdvedPLU.LockList);
  finally
    FAdvedPLU.UnlockList;
    FreeAndNil(FAdvedPLU);
  end;
  try
    DisposeTListItems(FAdsTbl.LockList);
  finally
    FAdsTbl.UnlockList;
    FreeAndNil(FAdsTbl);
  end;

end;

end.

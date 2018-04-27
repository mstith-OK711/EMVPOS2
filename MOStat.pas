unit MOStat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, POSMain, Math, LatTypes;

type
  TfmMO = class(TForm)
    lStatus: TPanel;
    ProgBar: TProgressBar;
    Memo: TMemo;
    ButtonOK: TButton;
    BlinkTimer: TTimer;
    TimeOutTimer: TTimer;
    PingTimeOut: TTimer;

    procedure FormShow(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure OnBlinkTimer(Sender: TObject);
    procedure OnTimeOutTimerElapsed(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FTransNo  : integer;
    FSaleList : pTList;
    FErrorCount : integer;
    FPrintTS : TDateTime;
    FLastMsg : TDateTime;
    FAlerting : boolean;
    FLock : boolean;
    function FindSeq(const seqno : integer) : integer;
    function FindSeqLink(const seqlink : integer) : integer;
    procedure SetSaleList(const Value: pTList);
    procedure SetTransNo(const Value: integer);
    function GetNeedToPrint: boolean;
    procedure ExpandSaleList();
    procedure HandleStatus(tno, sno: integer; msg : string);
    procedure HandleResolution(tno, sno: integer; msg : string);
    procedure ProcessMsg(var Msg: TWMStatus); message WM_MOMSG;
    procedure Ping();
    procedure PrintDocs(var Msg: TWMStatus); message WM_MOMSGPRINT;
    function GetNeedToVoid: boolean;
    procedure VoidSaleLine(line : pSalesData);
    procedure VoidSale(const reason : string; const alert : boolean);
    procedure Unlock();
  public
    { Public declarations }
    property TransNo : integer write SetTransNo;
    property SaleList : pTList write SetSaleList;
    property NeedToPrint : boolean read GetNeedToPrint;
    property NeedToVoid : boolean read GetNeedToVoid;
    function MOLine(line : pSalesData) : boolean;
    procedure Void();
    function DupReturn(const docno : string) : boolean;
    function CleanSaleList() : boolean;
  end;

var
  fmMO: TfmMO;

implementation

uses
   MoDocNo, POSMisc, ExceptLog, POSDM, JclHashMapsCustom, IBSQL, MMSystem, DateUtils;
{$R *.dfm}
const
{$I MOTags.inc}
  ALERTNAME = 'ALERT';

procedure TfmMO.ExpandSaleList;
var
  ndx, j : integer;
  line, newline : pSalesData;
begin
  ndx := 0;
  while ndx < FSaleList^.Count do
  begin
    line := FSaleList^.Items[ndx];
    if MOLine(line) and (line^.Qty > 1) then
    begin
      line^.ExtPrice := line^.Price;
      for j := 1 to (floor(line^.Qty) - 1) do
      begin
        New(newline);
        move(line^,newline^,sizeof(TSalesData));
        line^.Qty := line^.Qty - 1;
        newline^.Qty := 1;
        FSaleList^.Insert(ndx + 1,newline);
      end;
    end;
    line^.SeqNumber := ndx + 1;
    inc(ndx);
  end;
end;

function TfmMO.GetNeedToPrint: boolean;
var
  ndx : integer;
  line : pSalesData;
begin
  GetNeedToPrint := False;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^.Items[ndx];
    if MOLine(line) and (line^.Qty > 0) and (line^.MODocNo = '') then
    begin
      GetNeedToPrint := True;
      Break;
    end;
  end;
end;

function TfmMO.GetNeedToVoid: boolean;
var
  ndx : integer;
  line : pSalesData;
begin
  GetNeedToVoid := False;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^.Items[ndx];
    if MOLine(line) and (line^.Qty < 0) and (line^.MODocNo <> '') then
    begin
      GetNeedToVoid := True;
      Break;
    end;
  end;
end;


function TfmMO.MOLine(line: pSalesData): boolean;
begin
  MOLine := (not line^.LineVoided) and (line^.SaleType <> 'Void') and
              (line^.LineType = 'DPT') and (line^.Name = 'Money Order');
end;

procedure TfmMO.Ping( );
begin
  fmPOS.MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPING)) + BuildTag(TAG_MOTERMNO, IntToStr(fmPOS.ThisTerminalNo)));
end;

procedure TfmMO.PrintDocs;
var
  ndx : integer;
  line : pSalesData;
  trycount : integer;
  sent : boolean;
begin
  sent := False;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^[ndx];
    if MOLine(line) and (line^.Qty > 0) and (line^.MODocNo = '') then
    begin
      for trycount := 1 to 5 do
        try
          FPrintTS := now() - (500 * OneMillisecond);
          fmPOS.MO.SendMSG(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPRINTDOCUMENT)) +
                           BuildTag(TAG_MOTERMNO, IntToStr(fmPOS.ThisTerminalNo)) +
                           BuildTag(TAG_MOTRANNO, IntToStr(FTransNo)) +
                           BuildTag(TAG_MOSEQNO, IntToStr(line.SeqNumber)) +
                           BuildTag(TAG_MOVALUE, CurrToStr(line.Price)));
          Self.TimeOutTimer.Enabled := True;
          sent := True;
          break;
        except
          on E: Exception do
          begin
            UpdateExceptLog('fmMO(DCOMMOProg.PrintDocument): Failed - ' + E.Message);
            New(StatusMsg);
            StatusMsg.Text := BuildTag(TAG_MOTRANNO, IntToStr(FTransNo))
                              + BuildTag(TAG_MOSEQNO, IntToStr(line.SeqNumber))
                              + BuildTag(TAG_MOMSGTYPE, IntToStr(MO_STATUS))
                              + BuildTag(TAG_MOSTATSTR, 'Reconnecting to MO Printer Server: ' + E.Message);
            Self.FErrorCount := Self.FErrorCount + 1;
            PostMessage(fmMO.Handle, WM_MOMSG, 0, LongInt(StatusMsg));
          end;
        end;
        if not sent then
        begin
          New(StatusMsg);
          StatusMsg.Text := BuildTag(TAG_MOTRANNO, IntToStr(FTransNo))
                 + BuildTag(TAG_MOSEQNO, IntToStr(line.SeqNumber))
                 + BuildTag(TAG_MOSTATUS, BoolToText(False))
                 + BuildTag(TAG_MODOCNO, 'Could not reconnect to DCOM Server');;
          PostMessage(fmMO.Handle, WM_MOMSG, 0, LongInt(StatusMsg));
        end;
      // for loop end
      break;
    end;  // printable if
  end;
end;

function TfmMO.FindSeq(const seqno : integer) : integer;
var
  ndx : integer;
  line : pSalesData;
begin
  FindSeq := -1;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^[ndx];
    if (line.SeqNumber = seqno) and not line.LineVoided then
    begin
      FindSeq := ndx;
      break;
    end;
  end;
end;

function TfmMO.FindSeqLink(const seqlink : integer) : integer;
var
  ndx : integer;
  line : pSalesData;
begin
  FindSeqLink := -1;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^[ndx];
    if (line.SeqLink = seqlink) and not line.LineVoided then
    begin
      FindSeqLink := ndx;
      break;
    end;
  end;
end;

procedure TfmMO.HandleStatus(tno, sno: integer; msg : string);
var
  mStatStr : String;
begin
  try
    mStatStr := '';
    mStatStr := GetTagData(TAG_MOSTATSTR, msg, True);
  except
  end;
  FLastMsg := Now();
  if (mStatStr <> '') and self.Visible then
  begin
    Self.lStatus.Caption := mStatStr;
    Self.Memo.Lines.Add(mStatStr);
  end;
  if (pos('retain', mStatStr) > 0) then
  begin
    Self.BlinkTimer.Enabled := True;
    PlaySound( ALERTNAME, HInstance, SND_LOOP or SND_ASYNC or SND_RESOURCE) ;
    Self.FAlerting := True;
  end;
end;

procedure TfmMO.HandleResolution(tno, sno: integer; msg : string);
var
  mStatus : string;
  mStatusVerbose : string;
  mResult : String;
  ndx : integer;
  line : pSalesData;
  bTemp : boolean;
begin
  mStatus := GetTagData(TAG_MOSTATUS,msg);
  mStatusVerbose := GetTagData(TAG_MOSTATSTR, msg);
  mResult := GetTagData(TAG_MODOCNO, msg);
  FLastMsg := Now();
  Self.TimeOutTimer.Enabled := False;
  ndx := FindSeq(sno);
  if ndx >= 0 then // if negative, then we haven't found it.
  begin
    line := FSaleList^[ndx];
    if mStatus = 'Success' then
    begin
      bTemp := POSDataMod.Cursors.Transaction.InTransaction;
      if bTemp then
        POSDataMod.Cursors.Commit;
      POSDataMod.Cursors.StartTransaction;
      try
        with POSDataMod.Cursors['MO-Insert'] do
        begin
          ParamByName('pSerialNo').AsString := mResult;
          ParamByName('pDocValue').AsCurrency := line^.Price;
          ParamByName('pPurchTS').AsDateTime := FPrintTS;
          ParamByName('pTransNo').AsInteger := FTransNo;
          ExecQuery();
          Close();
        end;
        with POSDataMod.Cursors['MO-UpdLP'] do
        begin
          ParamByName('pSerialNo').AsString := mResult;
          ExecQuery();
          Close();
        end;
        POSDataMod.Cursors.Commit();
        line.MODocNo := mResult;
        Self.Memo.Lines.Add(Format('Storing document %s to batch', [mResult]));
      except
        on E: Exception do
        begin
          UpdateExceptLog('Problem with MO-Insert for ' + mResult + ': ' + E.Message);
          POSDataMod.Cursors.Rollback;
          VoidSaleLine(line);
          Self.Memo.Lines.Add('Please retain document ' + mResult + ' as it is VOID');
        end;
      end;
      if bTemp then
        POSDataMod.Cursors.StartTransaction;
      PostMessage(fmMO.Handle, WM_MOMSGPRINT,0 ,0);
    end
    else if mStatus = 'Fatal' then
    begin
      Self.lStatus.Color := clRed;
      FErrorCount := -1;
      Self.Memo.Lines.Add('Voiding remaining MO''s due to fatal error: ' + mStatusVerbose);
      while ndx < FSaleList^.Count do
      begin
        line := FSaleList^[ndx];
        if MOLine(line) then
          VoidSaleLine(line);
        ndx := ndx + 1;
      end;
      fmPOS.CheckSaleList();
    end
    else
    begin
      self.lStatus.Color := clRed;
      FErrorCount := FErrorCount + 1;
      Self.Memo.Lines.Add('Voiding ' + CurrToStr(line.Price) + ' - Reason: ' + mResult);
      VoidSaleLine(line);
      fmPOS.CheckSaleList();
    end;
    ProgBar.StepIt();
    if (ProgBar.Position = ProgBar.Max) or (FErrorCount < 0) then
    begin
      Self.Unlock();
      Self.TimeOutTimer.Enabled := False;
      if (FErrorCount = 0) then
        fmMO.Close()
      else
        Self.ButtonOK.Visible := True;
    end;
  end
  else
    UpdateExceptLog('Cannot find SeqNo: ' + IntToStr(sno) + ' in FSaleList for document: ' + mResult);
end;

procedure TfmMO.Unlock();
begin
  // send unlock
  fmPOS.MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(TAG_UNLOCK)));
end;

procedure TfmMO.ProcessMsg(var Msg: TWMStatus);
var
  dcmsg : string;
  mTransNo, mSeqNo, mMsgType : integer;
  docnostr, status : string;
begin
  if Msg.Status <> nil then
  begin
    dcmsg := Msg.Status.Text;
    try
      mMsgType := StrToInt(GetTagData(TAG_MOMSGTYPE, dcmsg, True));
    except
      on E: Exception do
      begin
        UpdateExceptLog('fmMO.ProcessMsg: Message parsing failed - ' + E.Message);
        raise;
      end;
    end;

    if (MO_RESOLUTION <= mMsgType) and (mMsgType <= MO_STATUS) then
    begin
      try
        mTransNo := StrToInt(GetTagData(TAG_MOTRANNO,dcmsg, True));
        mSeqNo   := StrToInt(GetTagData(TAG_MOSEQNO, dcmsg, True));
      except
        on E: Exception do
        begin
          UpdateExceptLog('fmMO.ProcessMsg: Message parsing failed - ' + E.Message);
          raise;
        end;
      end;
      if mTransNo <> FTransNo then
        exit;
      case mMsgType of
        MO_RESOLUTION : HandleResolution(mTransNo, mSeqNo, dcmsg);
        MO_STATUS     : HandleStatus(mTransNo, mSeqNo, dcmsg);
      else
        UpdateExceptLog('fmMO.ProcessMsg: Failure to understand MsgType ' + IntToStr(mMsgType));
      end;
    end
    else if mMsgType = MO_PONG then
    begin
      Self.FLastMsg := Now();
      docnostr := GetTagData(TAG_MODOCNO, dcmsg);
      status := GetTagData(TAG_MOSTATUS, dcmsg);
      if status = 'Success' then
      begin
        if docnostr = 'None' then
        begin
          fmPOS.MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(SHOW_SERIAL)));
          if isAbortResult( MoDocEntry.ShowModal() ) then
            VoidSale('Cancelled document scan', False);
        end
        else
          PostMessage(fmMO.Handle, WM_MOMSGPRINT,0 ,0)
      end
      else
        VoidSale(Format('Fatal Error - Failures: %s', [GetTagData(TAG_MOSTATSTR, dcmsg)]), False);
    end
    else if mMsgType = MODOCNOSET then
    begin
      Self.FLastMsg := Now();
      PostMessage(fmMO.Handle, WM_MOMSGPRINT,0 ,0)
    end
    else if mMsgType = LOCKRESP then
    begin
      status := GetTagData(TAG_MOSTATUS, dcmsg);
      if status = 'Success' then
        Ping()
      else
        VoidSale('could not aquire lock', False);
    end;
  end;
end;


procedure TfmMO.SetSaleList(const Value: pTList);
begin
  FSaleList := Value;
end;

procedure TfmMO.SetTransNo(const Value: integer);

begin
  FTransNo := Value;
end;

procedure TfmMO.FormShow(Sender: TObject);
var
  ndx : integer;
  line : pSalesData;
begin
  ExpandSaleList();
  ProgBar.Max := 0;
  Self.Memo.Lines.Clear;
  Self.FErrorCount := 0;
  Self.ButtonOK.Visible := False;
  Self.ButtonOK.Caption := 'Acknowledge Problem';
  Self.lStatus.color := clGreen;
  Self.lStatus.Caption := 'Attempting to communicate with printer';
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^[ndx];
    if MOLine(line) and (line^.Qty > 0) then
       ProgBar.Max := ProgBar.Max + 1;
  end;
  fmPOS.MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(LOCK)));


end;

procedure TfmMO.ButtonOKClick(Sender: TObject);
begin
  if Self.ButtonOK.Caption = 'Acknowledge Problem' then
  begin
    if Self.FAlerting then
    begin
      PlaySound(nil, 0, 0) ;
      Self.ButtonOK.Caption := 'Close Window';
      Self.FAlerting := False;
    end
    else
    begin
      Self.BlinkTimer.Enabled := False;
      Self.Close();
    end;
  end
  else if self.ButtonOK.Caption = 'Close Window' then
  begin
    Self.BlinkTimer.Enabled := False;
    Self.Close();
  end
  else if Self.ButtonOK.Caption = 'Cancel Wait' then
  begin
    VoidSale('Cancelled wait for lock', False);
  end;
end;

procedure TfmMO.Void;
var
  Cursors : TIBSqlBuilder;
  Cur : TIBSQL;
  ndx : integer;
  line : pSalesData;
  bInsert : boolean;
begin
  UpdateZLog('Entering TfmMO.Void()');
  Cursors := POSDataMod.CursorBuild();
  Cursors.Transaction.Name := 'fmMO_Void_Cursors_Transaction';
  Cursors.StartTransaction;
  Cursors.AddCursor('VS', 'Select SerialNo, DocValue from MoneyOrder where SerialNo = :pSerialNo');
  Cursors.AddCursor('VU', 'Update MoneyOrder set posted = 0, batched = 0, voided = 1, VoidTS = :pVoidTS where SerialNo = :pSerialNo and DocValue = :pDocValue');
  Cursors.AddCursor('VI', 'Insert into MoneyOrder (SerialNo, Voided, VoidTS, DocValue) values (:pSerialNo, 1, :pVoidTS, :pDocValue)');
  try
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^[ndx];
    if MOLine(line) and (line^.Qty < 0) then
    begin
      with Cursors['VS'] do
      begin
        ParamByName('pSerialNo').AsString := line^.MODocNo;
        ExecQuery();
        bInsert := EOF;
        close;
      end;
      if bInsert then
        Cur := Cursors['VI']
      else
        Cur := Cursors['VU'];
      with Cur do
      begin
        ParamByName('pSerialNo').AsString := line^.MODocNo;
        ParamByName('pVoidTS').AsDateTime := Now();
        ParamByName('pDocValue').AsCurrency := line^.Price;
        ExecQuery();
        Close();
      end;
    end;
  end;
    Cursors.Commit;
  except on E: Exception do
    begin
      UpdateExceptLog('Exception occured while voiding MOs ' + E.Message);
      Cursors.Rollback;
    end;
  end;
  Cursors.Free;
  UpdateZLog('Exiting TfmMO.Void()');
end;

procedure TfmMO.VoidSaleLine(line : pSalesData);
var
  ndx : integer;
  tline : pSalesData;
  CurSaleData : pSalesData;
begin
  CurSaleData := line;
  fmPOS.PostItemVoid(CurSaleData);
  ndx := FindSeqLink(-1 * line^.SeqLink);  // find negative seqlink to match positive above (fee)
  if ndx >= 0 then  // if found and not voided
  begin
    CurSaleData := FSaleList^[ndx];
    if CurSaleData^.Qty > 1 then
    begin
      new(tline);
      move(CurSaleData^,tline^,sizeof(TSalesData));  // duplicate it
      tline^.Qty := tline^.Qty - 1; // remove qty 1
      tline^.ExtPrice := tline^.Qty * tline^.Price;
      FSaleList^.Insert(ndx+1,tline); // stick new linked fee line in after old
    end;
    fmPOS.PostItemVoid(CurSaleData);  // void original
  end
  else
    UpdateExceptLog('Cannot find SeqLink: ' + IntToStr(-1 * line^.SeqLink) + ' in FSaleList');;
end;


function TfmMO.DupReturn(const docno: string): boolean;
var
  ndx : integer;
  line : pSalesData;
begin
  DupReturn := False;
  for ndx := 0 to FSaleList^.Count - 1 do
  begin
    line := FSaleList^.Items[ndx];
    if MOLine(line) and (line^.Qty < 0) and (line^.MODocNo = docno) then
    begin
      DupReturn := True;
      Break;
    end;
  end;
end;

function TfmMO.CleanSaleList : boolean;
var
  ndx : integer;
  line : pSalesData;
  cleaned : boolean;
begin
  ndx := 0;
  cleaned := False;
  while ndx < FSaleList^.Count do
  begin
    line := FSaleList^.Items[ndx];
    if MOLine(line) and (line^.MODocNo = '') then
    begin
      Self.VoidSaleLine(line);
      cleaned := True;
    end;
    inc(ndx);
  end;
  UpdateZLog('Leaving TfmMO.CleanSaleList - returning ' + BoolToText(cleaned));
  Result := cleaned;
end;

procedure TfmMO.OnBlinkTimer(Sender: TObject);
begin
  if not self.Visible then
  begin
    self.BlinkTimer.Enabled := False;
    exit;
  end;
  if self.lStatus.Color = clGreen then
    self.lStatus.Color := clRed
  else
    self.lStatus.Color := clGreen;
  self.lStatus.Invalidate;
end;

procedure TfmMO.VoidSale(const reason : string; const alert : boolean);
var
  ndx : integer;
  line : pSalesData;
begin
  Self.Unlock();
  Progbar.Position := ProgBar.Max;
  ndx := 0;
  while ndx < FSaleList^.Count do
  begin
    line := FSaleList^[ndx];
    if MOLine(line) and (line^.Qty > 0) and (line^.MODocNo = '') then
      VoidSaleLine(line);
    ndx := ndx + 1;
  end;
  UpdateExceptLog('Voiding remaining MOs due to %s: %d', [ reason, FTransNo ]);
  Self.Memo.Lines.Add(Format('Voiding remaining money orders due %s', [ reason ]));
  Self.Memo.Lines.Add('Please retain any documents not on reciept');
  if alert then
  begin
    Self.BlinkTimer.Enabled := True;
    PlaySound( ALERTNAME, HInstance, SND_LOOP or SND_ASYNC or SND_RESOURCE) ;
    Self.FAlerting := True;
  end;
  Self.ButtonOK.Visible := True;
end;

procedure TfmMO.OnTimeOutTimerElapsed(Sender: TObject);
begin
  if not fmMO.Visible then
  begin
    Self.TimeOutTimer.Enabled := False;
    exit;
  end;
  if (Now() - FLastMsg) > (OneMinute) then
  begin
    Self.TimeOutTimer.Enabled := False;
    inc(FErrorCount);
    fmPos.MO.Flush;
    VoidSale('timeout on transaction', True);
  end;
end;

procedure TfmMO.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Self.BlinkTimer.Enabled := False;
  Self.TimeOutTimer.Enabled := False;
end;

procedure TfmMO.FormCreate(Sender: TObject);
begin
  inherited;
  Self.FLastMsg := 0;
  Self.FAlerting := False;
  Self.FErrorCount := 0;
  Self.FPrintTS := 0;
  Self.FLock := False;
end;

end.

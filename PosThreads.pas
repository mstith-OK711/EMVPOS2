unit PosThreads;

interface

uses Classes, DBInt, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IBSQL, IdURI, POSDM;

type
  TFPCPostThread = class(TThread)
  private
    FStore : integer;
    FFPCurl : string;
    FHTTPClient : TIdHTTP;
    FConfig : TConfigRW;
    FLogStr : string;
    procedure ReloadCfg();
    function Stringify(SQ : TIBSQL) : string;
    procedure OnTermination(Sender : TObject);
  protected
    procedure Execute; override;
    procedure EnableTimer;
    procedure DisableTimer;
    procedure LogStatus;
    procedure UpdateExceptLog;
  public
    constructor Create(CreateSuspended : boolean; storeno : integer);
  end;


implementation

uses Forms, SysUtils, ExceptLog, POSMain, POSMisc;

{ TFPCPostThread }

constructor TFPCPostThread.Create(CreateSuspended : boolean; storeno : integer);
begin
  try
    Self.OnTerminate := Self.OnTermination;
    FStore := storeno;
    FHTTPClient := TIdHTTP.Create(Application);
    FHTTPClient.Request.Connection := 'keep-alive';
    FConfig := TConfigRW.Create(POSDataMod.IBDb, POSDataMod.IBThreadConfigTrans);
    ReloadCfg();
    inherited Create(CreateSuspended);
  except
    on E: Exception do
    begin
      FLogStr := E.Message;
      Self.Synchronize(Self.LogStatus);
      DumpTraceback(E);
    end;
  end;
end;

procedure TFPCPostThread.ReloadCfg();
begin
  FConfig.StartTransaction;
  FFPCurl := FConfig.Str['FUEL_PC_POSTURL'];
  FConfig.Commit;
end;

function TFPCPostThread.Stringify(SQ : TIBSQL) : string;
  function BuildString(n : string) : string;
  begin
    BuildString := n + '=' + SQ.FieldByName(n).AsString + '&';
  end;
  function BuildTS(n : string) : string;
  var
    t : TDateTime;
  begin
    t := SQ.FieldByName(n).AsDateTime;
    if t = 0 then
      BuildTS := n + '=&'
    else
      BuildTS := n + '=' + FormatDateTime('yyyy-mm-dd hh:mm:ss', t) + '&';
  end;
begin
  Stringify := BuildTS('TS') + BuildString('ProductName') + BuildString('CashPrice') + BuildString('CreditPrice') + BuildString('TotalVolume') + BuildString('TotalValue');
end;

procedure TFPCPostThread.Execute;
var
  hp : string;
  eflag : boolean;
begin
  eflag := False;
  while not Self.Terminated do
  begin
    Self.FLogStr := 'Attempting Posting';
    Self.Synchronize(Self.LogStatus);
    try
      POSDataMod.ThCursors.StartTransaction;
      Self.FLogStr := 'Started Transaction';
      Self.Synchronize(Self.LogStatus);
      with POSDataMod.ThCursors['FPC-PostSel'] do
      begin
        ExecQuery;
        if EOF then
        begin
          Self.FLogStr := 'No records to post.';
          Self.Synchronize(Self.LogStatus);
        end;
        while not EOF do
        begin
          hp := TIdURI.ParamsEncode('method=post&Store=' + IntToStr(FStore) + '&' + Stringify(POSDataMod.ThCursors['FPC-PostSel']));
          try
            FHTTPClient.Get(Self.FFPCurl + '?' + hp);
            if FHTTPClient.ResponseCode = 200 then
            begin
              POSDataMod.ThCursors['FPC-PostU'].ParamByName('pKey').AsString := POSDataMod.ThCursors['FPC-PostSel'].FieldByName('DB_KEY').AsString;
              POSDataMod.ThCursors['FPC-PostU'].ExecQuery;
              Self.FLogStr := format('Posted FPC (%d): %s %s', [POSDataMod.ThCursors['FPC-PostU'].RowsAffected,
                                                                POSDataMod.ThCursors['FPC-PostSel'].FieldByName('TS').AsString,
                                                                POSDataMod.ThCursors['FPC-PostSel'].FieldByName('ProductName').AsString]);
              Self.Synchronize(Self.LogStatus);
            end;
            if not FHTTPClient.Response.KeepAlive then
              FHTTPClient.Disconnect;
          except
            on E: EIdHTTPProtocolException do
            begin
              eflag := True;
              Self.FLogStr := Self.FFPCurl + '?' + hp + ' returns ' + E.Message;
              Self.Synchronize(Self.LogStatus);
            end;
          end;
          Next();
        end;
        if FHTTPClient.Connected then
          FHTTPClient.Disconnect;
      end;
      POSDataMod.ThCursors.Commit;
      Self.FLogStr := 'Committed Transaction';
      Self.Synchronize(Self.LogStatus);
    except
      on E: Exception do
      begin
        POSDataMod.ThCursors.Rollback;
        Self.FLogStr := 'Problem selecting/posting FPCs - ' + E.ClassName + ' - ' + E.Message;
        Self.Synchronize(Self.UpdateExceptLog);
      end;
    end;
    if eflag then
    begin
      Self.Synchronize(Self.ReloadCfg);
      Self.Synchronize(Self.EnableTimer);
      eflag := False;
    end
    else
      Self.Synchronize(Self.DisableTimer);
    Self.FLogStr := 'Re-Suspending thread';
    Self.Synchronize(Self.LogStatus);
    Self.Suspended := True;
  end;  // Self.Terminated
  Self.FLogStr := 'Thread Terminated';
  Self.Synchronize(Self.LogStatus);
end;

procedure TFPCPostThread.LogStatus;
begin
  UpdateZLog('(t) ' + Self.FLogStr);
end;

procedure TFPCPostThread.UpdateExceptLog;
begin
  ExceptLog.UpdateExceptLog('(t) ' + Self.FLogStr);
end;

procedure TFPCPostThread.DisableTimer;
begin
  fmPOS.FPCPostTimer.Enabled := False;
end;

procedure TFPCPostThread.EnableTimer;
begin
  fmPOS.FPCPostTimer.Enabled := True;
end;

procedure TFPCPostThread.OnTermination(Sender: TObject);
begin
  Self.FLogStr := 'Cleaning up thread state';
  Self.Synchronize(Self.LogStatus);
  FHTTPClient.Free;
  FConfig.Free;
end;

end.

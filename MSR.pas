unit MSR;

interface

uses
  SysUtils,
  Classes,
  ExtCtrls,
  ADPort,
  SerialDev
  ;

type

  EBadCmd = class(Exception);
  ETimeout = class(Exception);

  TMPDE = procedure(const value: String) of object;
  TMPDET = procedure(const track1, track2, track3 : String) of object;
  TProcParser = procedure();
  TFuncSetup = function() : boolean;
  TMSR = class(TDataModule)
  private
    FPortNo : Integer;
    FBaudRate : integer;
    FDataBits : integer;
    FStopBits : integer;
    FParity : TParity;
    FEFTDev : TEFTDevice;
    FMPDE : TMPDE;
    FMPDET : TMPDET;
    FSetupTimer : TTimer;
    FOnline : boolean;
    FLogging : boolean;
    procedure MPMsgReceived(Sender : TObject; Buffer : pChar; Count : integer);
    procedure MPAckReceived(Sender : TObject);
    procedure MPNakReceived(Sender : TObject; Count : integer);
    procedure MPTimeoutEvent(Sender : TObject; Count : integer);
    procedure Parse(const Value : string); virtual;
    function GetPortOpen : boolean;
    procedure SetPortOpen (const value : boolean);
    procedure SetLogging(const Value: boolean);
  protected
    FLastCmd : string;
    FError : string;
    procedure SetupTimerExpired(Sender : TObject);
    procedure SendConfig(const cfg : string; const timeout : integer = 1);
  public
    function Setup() : boolean; virtual;
    procedure PortSettings(PortNo, BaudRate, DataBits, StopBits : integer; Parity : TParity);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Open : boolean read GetPortOpen write SetPortOpen;
    property OnDataEvent : TMPDE read FMPDE write FMPDE;
    property OnDataEventTracks :  TMPDET read FMPDET write FMPDET;
    property Online : boolean read FOnline;
    property Logging : boolean read FLogging write SetLogging;
  end;

  TMSRBasic = class(TMSR)
  end;

  TMSRMagTek = class(TMSR)
  end;

  TMSRIDTechIDEA = class(TMSR)
  end;

  TMSRDevice = class of TMSR;

const MSRDevices : Array[0..2] of TMSRDevice = (TMSRBasic, TMSRMagTek, TMSRIDTechIDEA);

  function GetMSR(AOwner: TComponent; const MSRtype: integer) : TMSR;


implementation

uses Forms, StrUtils, DateUtils, POSMisc, ExceptLog;

function TMSR.GetPortOpen: boolean;
begin
  if FEFTDev <> nil then
    Result := FEFTDev.Connected
  else
    Result := False;
end;

procedure TMSR.SetPortOpen(const value: boolean);
begin
  if FEFTDev = nil then
  begin
    FEFTDev := TEFTDevice.Create(Self, FPortNo, FBaudRate, FDataBits, FStopBits, FParity, tlsNone);
    FEFTDev.LogPrefix := 'MSR';
    FEFTDev.OnMsgReceived := MPMsgReceived;
    FEFTDev.OnAck := MPAckReceived;
    FEFTDev.OnNak := MPNakReceived;
    FEFTDev.OnTimeout := MPTimeoutEvent;
    FEFTDev.TimeOut := 1000;
    FEFTDev.LoggingEnabled := FLogging;
  end;
  FEFTDev.Connected := Value;
  if value then
    Setup();
end;

constructor TMSR.Create(AOwner: TComponent);
begin
  UpdateZLog(Format('Creating MSR %s', [Self.ClassName]));
  FLogging := False;
  FOnline := False;
  //inherited;
end;

procedure TMSR.SetupTimerExpired(Sender: TObject);
begin
  FSetupTimer.Enabled := False;
  Setup;
end;

destructor TMSR.Destroy;
begin
  if Assigned(Self.FEFTDev) then
  begin
    Self.FEFTDev.Connected := False;
    FreeAndNil(Self.FEFTDev);
  end;
  if FSetupTimer <> nil then
  begin
    FSetupTimer.Enabled := False;
    FreeAndNil(FSetupTimer);
  end;
  inherited;
end;

procedure TMSR.PortSettings(PortNo, BaudRate, DataBits,
  StopBits: integer; Parity: TParity);
begin
  FPortNo := PortNo;
  FBaudRate := BaudRate;
  FDataBits := DataBits;
  FStopBits := StopBits;
  FParity := Parity;
end;



procedure TMSR.MPMsgReceived(Sender: TObject; Buffer: pChar; Count: integer); // parse and pass up
begin
  try
    Parse(copy(Buffer, 1, Count));
  except
    on E: Exception do
    begin
      UpdateExceptLog('TMSR.MPMsgReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;
end;

procedure TMSR.MPAckReceived(Sender: TObject); // config accepted
begin
  try
    with TEFTDevice(Sender) do
      if QueueCount = 0 then
      begin
        FOnline := True;
        if LoggingEnabled and not FLogging then
        begin
          LogEvent('Queue count 0, disabling logging');
          LoggingEnabled := False;
        end;
      end;
  except
    on E: Exception do
    begin
      UpdateExceptLog('TMSR.MPAckReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TMSR.MPNakReceived(Sender: TObject; Count: integer); // config not accepted
begin
  try
    with TEFTDevice(Sender) do
    begin
      LoggingEnabled := True;
      FlushOutQueue;
      LogEvent('Queue Flushed due to NAK');
      UpdateZLog('TMSR Setup NAKed');
    end;
    FSetupTimer.Enabled := True;
  except
    on E: Exception do
    begin
      UpdateExceptLog('TMSR.MPNakReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TMSR.MPTimeoutEvent(Sender: TObject; Count: integer); // timeout
begin
  try
    with TEFTDevice(Sender) do
    begin
      LoggingEnabled := True;
      FlushOutQueue;
      LogEvent('Queue Flushed due to Timeout');
      UpdateZLog('TMSR Setup timed out');
    end;
    FSetupTimer.Enabled := True;
  except
    on E: Exception do
    begin
      UpdateExceptLog('TMSR.MPTimeoutEvent - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TMSR.Parse(const Value : string);
begin
  if Assigned(Self.FMPDE) then
    Self.FMPDE(Value);
end;

function TMSR.Setup: boolean;
begin
  UpdateZlog('TMSR.Setup returning true');
  Result := True;
  FOnline := True;
end;

procedure TMSR.SendConfig(const cfg: string; const timeout: integer = 1);
begin
  if Self.FEFTDev <> nil then
    Self.FEFTDev.Send(cfg);
end;

procedure TMSR.SetLogging(const Value: boolean);
begin
  FLogging := Value;
  if FEFTDev <> nil then
    FEFTDev.LoggingEnabled := True;
end;

{ non-class methods }

function GetMSR(AOwner: TComponent; const msrtype: integer) : TMSR;
begin
  UpdateZLog(Format('MSR.GetMSR: Attempting to return MSR for type %d',[msrtype]));
  if msrtype > high(MSRDevices) then
    Result := MSRDevices[0].Create(AOwner)
  else
    Result := MSRDevices[msrtype].Create(AOwner);
end;


end.

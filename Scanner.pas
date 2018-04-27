unit Scanner;

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

  TSPDE = procedure(const Sym: String; const value: String) of object;
  TProcParser = procedure();
  TFuncSetup = function() : boolean;
  TScanner = class(TDataModule)
  private
    FPortNo : Integer;
    FBaudRate : integer;
    FDataBits : integer;
    FStopBits : integer;
    FParity : TParity;
    FSPDE : TSPDE;
    FSetupTimer : TTimer;
    FLastCmd : string;
    FError : string;
    FOnline : boolean;
    FLogging : boolean;
    procedure SetupTimerExpired(Sender : TObject);
    procedure SPMsgReceived(Sender : TObject; Buffer : pChar; Count : integer); virtual;
    procedure SPAckReceived(Sender : TObject);
    procedure SPNakReceived(Sender : TObject; Count : integer);
    procedure SPTimeoutEvent(Sender : TObject; Count : integer);
    procedure Parse(const Value : string); virtual;
    procedure SendConfig(const cfg : string; const timeout : integer = 1); virtual;
    function GetPortOpen : boolean; virtual;
    procedure SetPortOpen (const value : boolean); virtual;
    procedure SetLogging(const Value: boolean); virtual;
  public
    function Setup() : boolean; virtual;
    procedure PortSettings(PortNo, BaudRate, DataBits, StopBits : integer; Parity : TParity);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Open : boolean read GetPortOpen write SetPortOpen;
    property OnDataEvent : TSPDE read FSPDE write FSPDE;
    property Online : boolean read FOnline;
    property Logging : boolean read FLogging write SetLogging;
  end;

  TScnrBasic = class(TScanner)
  end;

  TScnrSTXETX = class(TScanner)
  private
    Dev : TEFTDevice;
    function GetPortOpen : boolean; override;
    procedure SetPortOpen (const value : boolean); override;
    procedure SendConfig(const cfg : string; const timeout : integer = 1); override;
    procedure SetLogging(const Value: boolean); override;
  public
    destructor Destroy(); override;
  end;

  TScnrCR = class(TScanner)
  private
    Dev : TCRDevice;
    FInSetup : boolean;
    function GetPortOpen : boolean; override;
    procedure SetPortOpen (const value : boolean); override;
    procedure SendConfig(const cfg : string; const timeout : integer = 1); override;
    procedure SetLogging(const Value: boolean); override;
  public
    destructor Destroy(); override;
  end;

  TScnrMS3580 = class(TScnrSTXETX)
  private
    procedure Parse(const Value : string); override;
  end;

  TScnrMS7580 = class(TScnrSTXETX)
  private
    procedure Parse(const Value : string); override;
  public
    function Setup() : boolean; override;
  end;

  TScnrDLGD4400 = class(TScnrCR)
  private
    procedure Parse(const Value : string); override;
    //procedure SPMsgReceived(Sender : TObject; Buffer : pChar; Count : integer); override;
  public
    //function Setup() : boolean; override;
  end;

  TScannerDevice = class of TScanner;

const ScannerDevices : Array[0..3] of TScannerDevice = (TScnrBasic, TScnrMS3580, TScnrMS7580, TScnrDLGD4400);

  function GetScanner(AOwner: TComponent; const scannertype: integer) : TScanner;


//    function SetupMS7580() : boolean;
//    procedure ParseMS7580();
//    procedure ParseMS3580();


implementation

uses Forms, StrUtils, DateUtils, POSMisc, ExceptLog;

constructor TScanner.Create(AOwner: TComponent);
begin
  UpdateZLog(Format('Creating scanner %s', [Self.ClassName]));
  if Self.ClassNameIs(TScnrMS7580.ClassName) then
  begin
    FSetupTimer := TTimer.Create(AOwner);
    FSetupTimer.Interval := 3000;
    FSetupTimer.OnTimer := SetupTimerExpired;
    FSetupTimer.Enabled := False;
  end;
  FLogging := False;
  FOnline := False;
  //inherited;
end;

procedure TScanner.SetupTimerExpired(Sender: TObject);
begin
  FSetupTimer.Enabled := False;
  Setup;
end;

destructor TScanner.Destroy;
begin
  if assigned(FSetupTimer) then
  begin
    FSetupTimer.Enabled := False;
    FreeAndNil(FSetupTimer);
  end;
  inherited;
end;

procedure TScanner.PortSettings(PortNo, BaudRate, DataBits,
  StopBits: integer; Parity: TParity);
begin
  FPortNo := PortNo;
  FBaudRate := BaudRate;
  FDataBits := DataBits;
  FStopBits := StopBits;
  FParity := Parity;
end;



procedure TScanner.SPMsgReceived(Sender: TObject; Buffer: pChar; Count: integer); // parse and pass up
begin
  try
    Parse(copy(Buffer, 1, Count));
  except
    on E: Exception do
    begin
      UpdateExceptLog('TScanner.SPMsgReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;
end;

procedure TScanner.SPAckReceived(Sender: TObject); // config accepted
begin
  try
    with TSerialDevice(Sender) do
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
      UpdateExceptLog('TScanner.SPAckReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TScanner.SPNakReceived(Sender: TObject; Count: integer); // config not accepted
begin
  try
    with TSerialDevice(Sender) do
    begin
      LoggingEnabled := True;
      FlushOutQueue;
      LogEvent('Queue Flushed due to NAK');
      UpdateZLog('TScanner Setup NAKed');
    end;
    if assigned(FSetupTimer) then
      FSetupTimer.Enabled := True;
  except
    on E: Exception do
    begin
      UpdateExceptLog('TScanner.SPNakReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TScanner.SPTimeoutEvent(Sender: TObject; Count: integer); // timeout
begin
  try
    with TSerialDevice(Sender) do
    begin
      LoggingEnabled := True;
      FlushOutQueue;
      LogEvent('Queue Flushed due to Timeout');
      UpdateZLog('%s Setup timed out', [self.ClassName]);
    end;
    if assigned(FSetupTimer) then
      FSetupTimer.Enabled := True;
  except
    on E: Exception do
    begin
      UpdateExceptLog('%s.SPTimeoutEvent - Exception %s - %s', [self.ClassName, E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TScanner.Parse(const Value : string);
begin
  if Assigned(Self.FSPDE) then
    Self.FSPDE('', Value);
end;

function TScanner.Setup: boolean;
begin
  UpdateZlog('TScanner.Setup returning true');
  Result := True;
  FOnline := True;
end;

function TScanner.GetPortOpen: boolean;
begin
  result := False;
end;

procedure TScanner.SendConfig(const cfg: string; const timeout: integer);
begin
end;

procedure TScanner.SetLogging(const Value: boolean);
begin
end;

procedure TScanner.SetPortOpen(const value: boolean);
begin
  raise Exception.Create('Cannot open port without port to open');
end;

{ TScnrSTXETX }

function TScnrSTXETX.GetPortOpen: boolean;
begin
  if Dev <> nil then
    Result := Dev.Connected
  else
    Result := False;
end;

procedure TScnrSTXETX.SetPortOpen(const value: boolean);
begin
  if Dev = nil then
  begin
    Dev := TEFTDevice.Create(Self, FPortNo, FBaudRate, FDataBits, FStopBits, FParity, tlsNone);
    Dev.LogPrefix := 'EFTScanner';
    Dev.OnMsgReceived := SPMsgReceived;
    Dev.OnAck := SPAckReceived;
    Dev.OnNak := SPNakReceived;
    Dev.OnTimeout := SPTimeoutEvent;
    Dev.TimeOut := 1000;
    Dev.LoggingEnabled := FLogging;
  end;
  Dev.Connected := Value;
  if value then
    Setup();
end;

destructor TScnrSTXETX.Destroy;
begin
  if Assigned(Self.Dev) then
  begin
    Self.Dev.Connected := False;
    FreeAndNil(Self.Dev);
  end;
  inherited;
end;

procedure TScnrSTXETX.SendConfig(const cfg: string; const timeout: integer = 1);
begin
  if Self.Dev <> nil then
    Self.Dev.Send(cfg);
end;

procedure TScnrSTXETX.SetLogging(const Value: boolean);
begin
  FLogging := Value;
  if Dev <> nil then
    Dev.LoggingEnabled := True;
end;

{ TScnrCR }

destructor TScnrCR.Destroy;
begin
  if Assigned(Self.Dev) then
  begin
    Self.Dev.Connected := False;
    FreeAndNil(Self.Dev);
  end;
  inherited;
end;

function TScnrCR.GetPortOpen: boolean;
begin
  if Dev <> nil then
    Result := Dev.Connected
  else
    Result := False;
end;

procedure TScnrCR.SendConfig(const cfg: string; const timeout: integer);
begin
  if Self.Dev <> nil then
    Self.Dev.Send(cfg);
end;

procedure TScnrCR.SetLogging(const Value: boolean);
begin
  FLogging := Value;
  if Dev <> nil then
    Dev.LoggingEnabled := True;
end;

procedure TScnrCR.SetPortOpen(const value: boolean);
begin
  if Dev = nil then
  begin
    Dev := TCRDevice.Create(Self, FPortNo, FBaudRate, FDataBits, FStopBits, FParity, tlsNone);
    Dev.LogPrefix := 'CRScanner';
    Dev.OnMsgReceived := SPMsgReceived;
    Dev.OnAck := SPAckReceived;
    Dev.OnNak := SPNakReceived;
    Dev.OnTimeout := SPTimeoutEvent;
    Dev.TimeOut := 10000;
    Dev.LoggingEnabled := True;
  end;
  Dev.Connected := Value;
  if value then
    Setup();
end;

{ TScnrMS3580 }

procedure TScnrMS3580.Parse(const Value : string);
var
  sym, barcode : string;
  ipos : integer;
begin
  UpdateZLog('Frame = "' + value + '"');
  ipos := pos(' ', value);
  sym := copy(value,0,ipos - 1);
  barcode := copy(value, ipos + 1, length(value) - ipos);
  UpdateZlog(Format('%s - Calling SPDE with "%s" - "%s"', [self.classname, sym, barcode]));
  if Assigned(Self.FSPDE) then
    Self.FSPDE(sym, barcode);
end;

{ TScnrMS7580 }

procedure TScnrMS7580.Parse(const Value : string);
var
  sym, barcode : string;
  t1, t2 : string;
  ipos : integer;
begin
  UpdateZLog('Frame = "' + value + '"');
  t1 := copy(value, 0, 1);
  t2 := copy(value, 0, 2);
  if t2 = 'FF' then
  begin
    ipos := 2; sym := 'EAN8';
  end
  else if t1 = 'F' then
  begin
    ipos := 1; sym := 'EAN13';
  end
  else if t2 = 'E0' then
  begin
    ipos := 2; sym := 'UPC-E';
  end
  else if t1 = 'A' then
  begin
    ipos := 1; sym := 'UPC-A';
  end
  else if t2 = 'B1' then
  begin
    ipos := 2; sym := 'Code39';
  end
  else if t2 = 'B2' then
  begin
    ipos := 2; sym := 'ITF';
  end
  else if t2 = 'B3' then
  begin
    ipos := 2; sym := 'Code128';
  end
  else
  begin
    ipos := 0; sym := 'Unknown';
  end;
  barcode := copy(value, ipos + 1, length(value) - ipos);
  UpdateZlog(Format('%s - Calling SPDE with "%s" - "%s"', [self.ClassName, sym, barcode]));
  if Assigned(Self.FSPDE) then
    Self.FSPDE(sym, barcode);
end;

function TScnrMS7580.Setup: boolean;
begin
  UpdateZLog('Entering TScnrMS7580.Setup');
    try
      Self.SendConfig('999999');
      Self.SendConfig('999998');  // recall defaults
      Self.SendConfig('116614');  // enable ETX suffix
      Self.SendConfig('116603');  // disable CR suffix
      Self.SendConfig('116602');  // disable LF suffix
      Self.SendConfig('116615');  // enable STX prefix
      Self.SendConfig('107510');  // enable GTIN-14 format
      Self.SendConfig('107911');  // enable NCR Prefix ID
      Self.SendConfig('999999');
      Result := True;
      UpdateZLog(Format('%s.Setup returning True',[Self.ClassName]));
    except
      on E: Exception do
      begin
        Self.FError := E.Message;
        Result := False;
        UpdateZLog(Format('%s.Setup returning False (lastcmd: %s): %s',[Self.ClassName, Self.FLastCmd, E.Message]));
      end;
    end;
end;

{ TScnrDLGD4400 }

procedure TScnrDLGD4400.Parse(const Value: string);
var
  sym, barcode : string;
  t0, t1, t2 : string;
  ipos : integer;
begin
  if Self.FInSetup then
    exit;
  UpdateZLog('%s.Parse Frame = "%s"', [Self.ClassName, value]);
  t0 := copy(value, 1, 1);
  t1 := copy(value, 2, 1);
  t2 := copy(value, 2, 2);
  updatezlog('t0: %s, t1: %s, t2: %s', [t0, t1, t2]);
  sym := 'Undecoded';
  if t0 = ']' then
  begin
    ipos := 4;
    if t1 = 'E' then
      sym := 'EAN/UPC'
    else if t1 = 'A' then
      sym := 'Code39'
    else if t1 = 'C' then
      sym := 'Code128';
  end
  else
  begin
    ipos := 1;
    sym := 'Unknown';
  end;
  barcode := copy(value, ipos, length(value) - (ipos - 1));
  UpdateZlog(Format('%s - Calling SPDE with "%s" - "%s"', [self.ClassName, sym, barcode]));
  if Assigned(Self.FSPDE) then
    Self.FSPDE(sym, barcode);
end;

{
function TScnrDLGD4400.Setup: boolean;
begin
  Self.FInSetup := True;
  UpdateZLog('Entering TScnrDLGD4400.Setup');
    try
      Self.SendConfig('$+$!');
      //Self.SendConfig('$hA');
      Self.SendConfig('$CN2MIFE00000000000000000000000000000000000000,CC3ID423100,CEBID453000,CEMID453000,CSNML01,CEBAB01,C8B3B01,CGBEN01');
      // should receive '$>,>,>,>,>,>,>,>,>,>\r'
      Result := True;
      UpdateZLog(Format('%s.Setup returning True',[Self.ClassName]));
    except
      on E: Exception do
      begin
        Self.FError := E.Message;
        Result := False;
        UpdateZLog(Format('%s.Setup returning False (lastcmd: %s): %s',[Self.ClassName, Self.FLastCmd, E.Message]));
      end;
    end;

end;

procedure TScnrDLGD4400.SPMsgReceived(Sender: TObject; Buffer: pChar; Count: integer); // parse and pass up
begin
  try
    if self.FInSetup then
      Parse(copy(Buffer, 1, Count));
  except
    on E: Exception do
    begin
      UpdateExceptLog('TScanner.SPMsgReceived - Exception %s - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;
end;
}

{ non-class methods }

function GetScanner(AOwner: TComponent; const scannertype: integer) : TScanner;
begin
  UpdateZLog(Format('Scanner.GetScanner: Attempting to return scanner for type %d',[scannertype]));
  Result := ScannerDevices[scannertype].Create(AOwner);
end;

end.

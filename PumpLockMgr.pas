unit PumpLockMgr;

interface

uses
  Classes,
  ExtCtrls, // TTimer
  ClientLF,
  PumpLockSup,
  LatTypes,
  PumpXIcon;

type
  TPumpLockMgr = class(TComponent)
    FClient : TClientLF;
    Timer : TTimer;
  private
    FTermNo : shortint;
    FPumps : TPumpArray;
    procedure ConnectEvent(Sender : TObject);
    procedure DisconnectEvent(Sender : TObject);
    procedure SocketErrEvent(Sender : TObject; ErrCode : Integer);
    procedure MsgEvent(Sender : TObject; Msg : string);
    procedure TimerEvent(Sender : TObject);

    procedure StatusUpdate(SS : string);
    procedure SetAllUnknown();
    function GetPumpStatus(PumpNo: shortint): TPumpLockStatus;
  public
    constructor Create(AOwner : TComponent;
                       const host : string; const port : word;
                       const termno : shortint; const Pumps : TPumpArray); reintroduce;
    destructor Destroy(); override;
    procedure UnlockPump(const PumpNo : shortint);
    procedure PowerPump(const PumpNo : shortint);
    procedure DepowerPump(const PumpNo : shortint);
    property PumpStatus[PumpNo : shortint] : TPumpLockStatus read GetPumpStatus;
  end;

implementation

uses
  ExceptLog,
  SysUtils;

{ TPumpLockMgr }

constructor TPumpLockMgr.Create(AOwner: TComponent; const host: string; const port: word;
                                const termno : shortint; const Pumps : TPumpArray);
begin
  inherited Create(AOwner);

  Self.FTermNo := termno;
  Self.FClient := TClientLF.Create(Self, host, port);
  with Self.FClient do
  begin
    OnConnect := Self.ConnectEvent;
    OnDisconnect := Self.DisconnectEvent;
    OnSocketError := Self.SocketErrEvent;
    OnMsgEvent := Self.MsgEvent;
  end;
  Self.FPumps := Pumps;
  Self.SetAllUnknown;

  Self.Timer := TTimer.Create(Self);
  Self.Timer.Interval := 1000;
  Self.Timer.OnTimer := Self.TimerEvent;
  Self.Timer.Enabled := True;
end;

destructor TPumpLockMgr.Destroy;
begin
  Self.FClient.Send('QUIT');
  inherited;
end;

procedure TPumpLockMgr.ConnectEvent(Sender: TObject);
begin
  Self.FClient.Send('LOGIN POS' + IntToStr(Self.FTermNo));
  Self.FClient.Send('STATUS');
end;

procedure TPumpLockMgr.DisconnectEvent(Sender: TObject);
begin
  Self.SetAllUnknown;
end;

procedure TPumpLockMgr.MsgEvent(Sender: TObject; Msg: string);
begin
  if SameText(Copy(Msg, 1, 7), 'STATUS ') then
    Self.StatusUpdate(Copy(Msg, 7, length(Msg) - 7));
end;

procedure TPumpLockMgr.SocketErrEvent(Sender: TObject; ErrCode: Integer);
begin

end;

procedure TPumpLockMgr.StatusUpdate(SS: string);
var
  i : integer;
begin
  for i := low(Self.FPumps) to high(Self.FPumps) do
    if assigned(Self.FPumps[i]) then
      Self.FPumps[i].PumpLockStatus := PLCharToEnum(SS[i + 1]);
end;

procedure TPumpLockMgr.SetAllUnknown;
var
  i : integer;
begin
  for i := low(Self.FPumps) to high(Self.FPumps) do
    if assigned(Self.FPumps[i]) then
      Self.FPumps[i].PumpLockStatus := plsUnknown;
end;

procedure TPumpLockMgr.TimerEvent(Sender: TObject);
begin
  Self.FClient.Open := True;
end;

procedure TPumpLockMgr.UnlockPump(const PumpNo: shortint);
begin
  Self.FClient.Send('UNLOCK ' + IntToStr(PumpNo));
end;

procedure TPumpLockMgr.DepowerPump(const PumpNo: shortint);
begin
  Self.FClient.Send('SHUTDOWN ' + IntToStr(PumpNo));
end;

procedure TPumpLockMgr.PowerPump(const PumpNo: shortint);
begin
  Self.FClient.Send('POWER ' + IntToStr(PumpNo));
end;

function TPumpLockMgr.GetPumpStatus(PumpNo: shortint): TPumpLockStatus;
begin
  Result := Self.FPumps[PumpNo].PumpLockStatus;
end;

end.

unit hScales;

interface

uses
  SysUtils,
  Classes,
  ExtCtrls,
  ADPort,
  AdPacket,
  SerialDev
  ;

type
  TSendCurr = procedure(const value: Currency) of object;

  TScale = class(TObject)
  private
    FTimeout : TTimer;
    FSendProc : TSendCurr;
    FPort: TApdComPort;
    FWMsg: TApdDataPacket;
    procedure SetPort(const Value: TApdComPort);
    procedure MsgReceived(Sender: TObject; buff : string);
    procedure TimeOut(sender: TObject);
    procedure QueryWeight();
  public
    constructor Create();
    destructor Destroy(); override;
    procedure sendweights( proc:TSendCurr );
    procedure stopweights();
  published
    property Port : TApdComPort read FPort write SetPort;
  end;

implementation

uses
  StrUtils,
  ExceptLog;

{ TScale }

constructor TScale.Create;
begin
  FTimeout := TTimer.Create(nil);
  FTimeout.Interval := 2000;
  FTimeout.OnTimer := Self.TimeOut;
end;

destructor TScale.Destroy;
begin
  FTimeout.Free;
  inherited;
end;

procedure TScale.MsgReceived(Sender: TObject; buff : string);
var
  ws, ss : string;
  ls : TStringList;
  i, s, e : integer;
begin
  ls := TStringList.Create;
  i := 1;
  s := PosEx( #10, buff, i);
  while s > 0 do
  begin
    e := PosEx( #13, buff, s);
    ls.Add(copy(buff, s+1, e-s-1));
    i := e;
    s := PosEx(#10, buff, i);
  end;
  if ls.Count = 2 then
  begin
    ws := LeftStr(ls.Strings[0], length(ls.Strings[0]) - 2);
    ss := ls.Strings[1];
    if assigned(FSendProc) then
      FSendProc(StrToCurr(ws));
  end;
  ls.Free;
  QueryWeight;
end;

procedure TScale.QueryWeight;
begin
  FTimeout.Enabled := False;
  FPort.PutString('W' + #13);
  FTimeout.Enabled := True;
end;

procedure TScale.sendweights(proc: TSendCurr);
begin
  FSendProc := proc;
  QueryWeight;
end;

procedure TScale.SetPort(const Value: TApdComPort);
begin
  if FPort <> Value then
  begin
    if assigned(FPort) then
      FPort.Open := False;
    if assigned(FWMsg) then
      FWMsg.Free;
    FPort := Value;
    FWMsg := TApdDataPacket.Create(FPort);
    FWMsg.TimeOut := 30;
    FWMsg.FlushOnTimeout := True;
    with FWMsg do
    begin
      ComPort := FPort;
      StartCond := scString;
      StartString := #10;
      EndCond := [ ecString ];
      EndString := #3;
      IncludeStrings := True;
      OnStringPacket := Self.MsgReceived;
      Enabled := True;
    end;
  end;
end;

procedure TScale.stopweights;
begin
  FTimeout.Enabled := False;
  FSendProc := nil;
end;

procedure TScale.TimeOut(sender: TObject);
begin
  if assigned(FSendProc) then
    FSendProc(9999);
  QueryWeight;
end;

end.

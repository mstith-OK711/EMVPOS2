unit CCLog;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, AdTerm, AdPort;

type
  TfmCCLog = class(TForm)
    LogOps: TRadioGroup;
    Quit: TButton;
    ApdTerminal1: TApdTerminal;
    procedure QuitClick(Sender: TObject);
    procedure LogOpsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCCLog: TfmCCLog;

implementation

uses ccmain;

{$R *.DFM}

procedure TfmCCLog.QuitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmCCLog.LogOpsClick(Sender: TObject);
begin
  fmCreditServer.ApdComPort1.Logging := TTraceLogState(LogOps.ItemIndex);
  LogOps.ItemIndex := Ord(fmCreditServer.ApdComPort1.Logging);
  ApdTerminal1.SetFocus;
end;

procedure TfmCCLog.FormShow(Sender: TObject);
begin
  ApdTerminal1.ComPort := fmCreditServer.ApdComPort1;
  ApdTerminal1.Active := True;
end;

end.

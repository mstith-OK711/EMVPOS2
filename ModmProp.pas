
unit ModmProp;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, AdModDB, NBSMain;

type
  TfmModemProperties = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    InitializeEdit: TEdit;
    DialEdit: TEdit;
    DialSuffixEdit: TEdit;
    CancelDialEdit: TEdit;
    HangupEdit: TEdit;
    ConfigureEdit: TEdit;
    AnswerEdit: TEdit;
    Label9: TLabel;
    OkayEdit: TEdit;
    Label10: TLabel;
    ConnectEdit: TEdit;
    Label11: TLabel;
    BusyEdit: TEdit;
    Label12: TLabel;
    VoiceEdit: TEdit;
    Label13: TLabel;
    NoCarrierEdit: TEdit;
    Label14: TLabel;
    NoDialtoneEdit: TEdit;
    Label15: TLabel;
    ErrorEdit: TEdit;
    RingEdit: TEdit;
    Label16: TLabel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    GroupBox4: TGroupBox;
    Label17: TLabel;
    BPSRateEdit: TEdit;
    LockDTEBox: TCheckBox;
    procedure OkBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  public
    ModemName : string;
  end;


var
fmModemProperties : TfmModemProperties;
ModemInfo : TModemInfo;

implementation


{$R *.DFM}


procedure TfmModemProperties.OkBtnClick(Sender: TObject);

begin
  with ModemInfo do begin
    InitCmd       := TrimRight(InitializeEdit.Text);
    DialCmd       := TrimRight(DialEdit.Text);
    DialTerm      := TrimRight(DialSuffixEdit.Text);
    DialCancel    := TrimRight(CancelDialEdit.Text);
    HangupCmd     := TrimRight(HangupEdit.Text);
    ConfigCmd     := TrimRight(ConfigureEdit.Text);
    AnswerCmd     := TrimRight(AnswerEdit.Text);
    OkMsg         := TrimRight(OkayEdit.Text);
    ConnectMsg    := TrimRight(ConnectEdit.Text);
    BusyMsg       := TrimRight(BusyEdit.Text);
    VoiceMsg      := TrimRight(VoiceEdit.Text);
    NoCarrierMsg  := TrimRight(NoCarrierEdit.Text);
    NoDialToneMsg := TrimRight(NoDialToneEdit.Text);
    ErrorMsg      := TrimRight(ErrorEdit.Text);
    RingMsg       := TrimRight(RingEdit.Text);
  //  Val(BPSRateEdit.Text, Temp, E);
    LockDTE := LockDTEBox.Checked;
  end;
  fmCreditServer.ModemDB.UpdModem(ModemName, ModemInfo);

end;

procedure TfmModemProperties.FormShow(Sender: TObject);
begin
  {set initial control values}

  fmCreditServer.ModemDB.Open := False;
  fmCreditServer.ModemDB.Filename :=  ExtractFileDir(Application.ExeName) + '\AWMODEM.INI';

  fmCreditServer.ModemDB.GetModem(ModemName, ModemInfo);
  with ModemInfo do begin
    InitializeEdit.Text := InitCmd;
    DialEdit.Text       := DialCmd;
    DialSuffixEdit.Text := DialTerm;
    CancelDialEdit.Text := DialCancel;
    HangupEdit.Text     := HangupCmd;
    ConfigureEdit.Text  := ConfigCmd;
    AnswerEdit.Text     := AnswerCmd;
    OkayEdit.Text       := OkMsg;
    ConnectEdit.Text    := ConnectMsg;
    BusyEdit.Text       := BusyMsg;
    VoiceEdit.Text      := VoiceMsg;
    NoCarrierEdit.Text  := NoCarrierMsg;
    NoDialToneEdit.Text := NoDialToneMsg;
    ErrorEdit.Text      := ErrorMsg;
    RingEdit.Text       := RingMsg;
    BPSRateEdit.Text    := IntToStr(DefBaud);
    LockDTEBox.Checked  := LockDTE;
  end;

end;

end.

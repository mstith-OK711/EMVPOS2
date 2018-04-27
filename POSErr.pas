{-----------------------------------------------------------------------------
 Unit Name: POSErr
 Author:    Gary Whetton
 Date:      9/11/2003 3:13:42 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSErr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CardActivation,
  ExtCtrls, StdCtrls, POSMain, ElastFrm, MMSystem;


const
  {$I ConditionalCompileSymbols.txt}
  UM_GRIDCHECK  = WM_USER + 200;

type
  TCanvasPanel = Class(TPanel)
  Public
    Property Canvas;
  End;

  TfmPOSErrorMsg = class(TForm)
    lErrMsg: TPanel;
    lblContinue: TPanel;
    lblCapture: TPanel;
    lblNo: TPanel;
    lblYes: TPanel;
    Supplement: TPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure lblCaptureClick(Sender: TObject);
    procedure lblNoClick(Sender: TObject);
    procedure lblYesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblContinueClick(Sender: TObject);
    procedure lErrMsgDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    CapturePLU : boolean;
    ShowYesNo  : boolean;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure GridCheck(var Msg: TMessage); message UM_GRIDCHECK;
    procedure SetupLabels;
    function Continue(const cap, msg: string; const supp: string=''):integer;
    function YesNo(const cap, msg: string; supp: string = ''):integer;
  end;

var
  fmPOSErrorMsg: TfmPOSErrorMsg;
  KeyBuff: array[0..200] of Char;


Const
  BuffPtr  :  short = 0;

implementation
uses POSDM, POSLog, Sounds, ExceptLog;

{$R *.DFM}

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.GridCheck
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.GridCheck(var Msg:TMessage);
begin
  SetupLabels;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.CheckKey(var Msg : TWMPOSKey);
var
 sKeyChar  : string[2];
 s         : String;
begin
  KeyBuff[BuffPtr] := Msg.KeyCode;
  if BuffPtr = 1 then
    begin
      sKeyChar := UpperCase(Copy(KeyBuff,1,2));
      if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
        begin
          sKeyType := KBDef[sKeyChar[1], sKeyChar[2]].KeyType;
          sKeyVal  := KBDef[sKeyChar[1], sKeyChar[2]].KeyVal;
          sPreset  := KBDef[sKeyChar[1], sKeyChar[2]].Preset;

          ProcessKey();
        end;

      KeyBuff := '';
      BuffPtr := 0;
    end
  else
   begin
     s:= UpperCase(KeyBuff[0]);
     if s[1] in ['A'..'N'] then
        Inc(BuffPtr,1) ;
   end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.ProcessKey;
begin
  if sKeyType = 'ENT' then
     ModalResult := mrOk

  else if sKeyType = 'CLR' then
     ModalResult := mrCancel

  else if sKeyType = 'ERC' then
     ModalResult := mrYES

  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PAT' then        { Authorize }
     fmPOS.ProcessKeyPAT

  else if sKeyType = 'PAL' then        { Authorize All }
     fmPOS.ProcessKeyPAL

  else if sKeyType = 'PMP' then        { Pump Number }
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset)

  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //Gift
  if (bClearDisplayAfterError) then
    fmPOS.ClearEntryField;
  //fmPOS.ClearEntryField;
  //Gift
  fmPOSErrorMsg.CapturePLU := False;
  fmPOSErrorMsg.ShowYesNo := False;
  lblContinue.Visible := True;
  lblCapture.Visible := False;
  lblYes.Visible := False;
  lblNo.Visible := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.FormShow(Sender: TObject);
begin

  fmPOSErrorMsg.Top := Trunc(((Screen.Height - fmPOSErrorMsg.Height) / 2)) + 100;
  fmPOSErrorMsg.Left := Trunc(((Screen.Width - fmPOSErrorMsg.Width) / 2));
  (*{$ifdef TOC}
  if fmPOS.bPlayWave then PlaySound( 'Response2', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$else}
  if fmPOS.bPlayWave then PlaySound( 'ERROR', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$endif}*)
  try
    if fmPOS.bPlayWave and (Self.Tag <> POS_ERROR_MSG_TAG_CARD_ACTIVATION) then MakeNoise( RESPONSESOUND) ;
  except
    on E: Exception do UpdateExceptLog('TfmPOSErrorMsg.FormShow: Problem playing response sound - %s - %s', [E.ClassName, E.Message]);
  end;
  PostMessage(fmPOSErrorMsg.Handle, UM_GRIDCHECK,0 ,0);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.SetupLabels
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.SetupLabels;
begin
  if fmPOSErrorMsg.ShowYesNo then
    begin
      lblYes.Visible := True;
      lblNo.Visible := True;
      lblContinue.Visible := False;
      lblCapture.Visible := False;
    end
  else
    begin
      lblContinue.Visible := True;
      lblYes.Visible := False;
      lblNo.Visible := False;
      if fmPOSErrorMsg.CapturePLU then
        lblCapture.Visible := True
      else
        lblCapture.Visible := False;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.lblCaptureClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.lblCaptureClick(Sender: TObject);
begin
    ModalResult := mrYes;
    if fmPOSErrorMsg.FormState <> [fsModal] then
      Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.lblNoClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.lblNoClick(Sender: TObject);
begin
    ModalResult := mrNo;
    if fmPOSErrorMsg.FormState <> [fsModal] then
      Close;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.lblYesClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.lblYesClick(Sender: TObject);
begin
    ModalResult := mrOK;
    if fmPOSErrorMsg.FormState <> [fsModal] then
      Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.FormCreate(Sender: TObject);
begin
  fmPOSErrorMsg.CapturePLU := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.lblContinueClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.lblContinueClick(Sender: TObject);
begin
    if ( fmPOSErrorMsg.Tag = POS_ERROR_MSG_TAG_CARD_ACTIVATION) then
    begin
      ClearActivationProductData(@ActivationProductData);
      fmPOSErrorMsg.Tag := 0;
    end;
    ModalResult := mrOk;
    if fmPOSErrorMsg.FormState <> [fsModal] then
      Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSErrorMsg.lErrMsgDblClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSErrorMsg.lErrMsgDblClick(Sender: TObject);
begin
  ModalResult := mrYes;
  if fmPOSErrorMsg.FormState <> [fsModal] then
    Close;

end;

function TfmPOSErrorMsg.YesNo(const cap, msg: string; supp: string) : integer;
begin
  Self.Caption := cap;
  ShowYesNo := True;
  lErrMsg.Caption := Msg + ' ?';
  Supplement.Caption := supp;
  if supp = '' then
  begin
    Height := 160;
    lblYes.Top := 72;
    lblNo.Top := 72;
    Supplement.Visible := False;
  end
  else
  begin
    Height := 214;
    lblYes.Top := 116;
    lblNo.Top := 116;
    Supplement.Visible := True;
  end;
  Result := ShowModal();
  Height := 266;
  lblContinue.Top := 128;
  Supplement.Visible := False;
end;

function TfmPOSErrorMsg.Continue(const cap, msg : string; const supp: string = '') : integer;
var
  tw, origpw, origww : integer;
  changewidth : boolean;
begin
  Self.Caption := cap;
  ShowYesNo := False;
  tw := TCanvasPanel(lErrMsg).canvas.TextWidth(Msg + ' !');
  changewidth := (tw > lErrMsg.Width);
  origpw := lErrMsg.Width;
  origww := width;
  if changewidth then
  begin
    lerrmsg.width := tw + 40;
    width := lerrmsg.width + (origww - origpw);
  end;
  lblContinue.Left := (width - lblContinue.Width) div 2;
  lErrMsg.Caption := Msg + ' !';
  Supplement.Caption := supp;
  if supp = '' then
  begin
    Height := 160; //214;
    lblContinue.Top := 72;
    Supplement.Visible := False;
  end
  else
  begin
    Height := 214;
    lblContinue.Top := 116;
    Supplement.Visible := True;
  end;
  Result := ShowModal();
  if changewidth then
  begin
    lErrMsg.Width := origpw;
    width := origww;
  end;
  Height := 266;
  lblContinue.Top := 128;
  Supplement.Visible := False;
end;

end.


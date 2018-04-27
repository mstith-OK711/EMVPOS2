{-----------------------------------------------------------------------------
 Unit Name: OldRecpt
 Author:    Gary Whetton
 Date:      9/11/2003 3:07:42 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit OldRecpt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, POSMain, ElastFrm;

type
  TfmOldReceipt = class(TForm)
    lErrMsg: TPanel;
    lblYes: TPanel;
    lblNo: TPanel;
    ElasticForm1: TElasticForm;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblNoClick(Sender: TObject);
    procedure lblYesClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    CapturePLU : boolean;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
  end;

var
  fmOldReceipt: TfmOldReceipt;
  KeyBuff: array[0..200] of Char;


Const
  BuffPtr  :  short = 0;

implementation
uses POSDM, POSLog;

{$R *.DFM}

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmOldReceipt.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmOldReceipt.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmOldReceipt.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmOldReceipt.ProcessKey;
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
  Name:      TfmOldReceipt.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmOldReceipt.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 //  fmPOS.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmOldReceipt.lblNoClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmOldReceipt.lblNoClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;


{-----------------------------------------------------------------------------
  Name:      TfmOldReceipt.lblYesClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmOldReceipt.lblYesClick(Sender: TObject);
begin
    bPrintingPriorReceipt := True;  //20070529a
    ModalResult := mrOK;
end;

end.


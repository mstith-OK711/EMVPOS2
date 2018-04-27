{-----------------------------------------------------------------------------
 Unit Name: POSMsg
 Author:    Gary Whetton
 Date:      4/13/2004 4:08:53 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, POSMain, ElastFrm;

type
  TfmPOSMsg = class(TForm)
    Panel1: TPanel;
    ElasticForm1: TElasticForm;
    TopMsg: TPanel;
    BottomMsg: TPanel;
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure ShowMsg(const sTopMsg, sBottomMsg: String; const sleeptime: integer = 0  );
  end;

var
  fmPOSMsg: TfmPOSMsg;
  KeyBuff: array[0..200] of Char;


Const
  BuffPtr  :  short = 0;

implementation

// uses POSMain;

uses ExceptLog;

{$R *.DFM}

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmPOSMsg.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSMsg.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmPOSMsg.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSMsg.ProcessKey;
begin

  if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL
  else if sKeyType = 'PMP' then        { Pump Number }
    begin
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
    end
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL
  else if sKeyType = 'PAL' then        { Pump Halt }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PLR' then        { Print Last Receipt }
    fmPOS.ProcessKeyPLR ;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOSMsg.ShowMsg
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: sTopMsg, sBottomMsg : String
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOSMsg.ShowMsg(const sTopMsg, sBottomMsg : String; const sleeptime: integer = 0 );
begin

  fmPOSMsg.Show;
  if sTopMsg > '' then
    fmPOSMsg.TopMsg.Caption  := sTopMsg;
  fmPOSMsg.BottomMsg.Caption := sBottomMsg;
  fmPOSMsg.Refresh;
  UpdateZLog('ShowMsg - `%s` `%s`', [fmPOSMsg.TopMsg.Caption, fmPOSMsg.BottomMsg.Caption]);
  //20061018c... Provide delay for messages
  Application.ProcessMessages;
  if sleeptime <> 0 then
    Sleep(sleeptime);
  //...20061018c
end;

end.

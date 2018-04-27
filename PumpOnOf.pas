{-----------------------------------------------------------------------------
 Unit Name: PumpOnOf
 Author:    Gary Whetton
 Date:      4/13/2004 4:19:25 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PumpOnOf;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  POSMain, Grids, DBGrids, StdCtrls, Mask, DBCtrls, ExtCtrls, ElastFrm;

type
  TfmPumpOnOff = class(TForm)
    Label1: TLabel;
    pnlPumpMode: TPanel;
    ePumpNo: TEdit;
    ElasticForm1: TElasticForm;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure RefreshFields;
    procedure ChangeMode;
  end;

var
  fmPumpOnOff: TfmPumpOnOff;
  KeyBuff: array[0..200] of Char;


  CurField: Integer;

Const
  BuffPtr  :  short = 0;

implementation
uses POSDM, POSLog, FuelPric;

{$R *.DFM}

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmPumpOnOff.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpOnOff.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmPumpOnOff.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpOnOff.ProcessKey;
begin

  if sKeyType = 'ENT' then
    begin
      ChangeMode;
    end
  else if sKeyType = 'CLR' then
     fmPumpOnOff.Close

  else if sKeyType = 'ERC' then
    begin
      PostMessage(ActiveControl.Handle, WM_KEYDOWN, VK_BACK, 0);
    end

  else if sKeyType = 'NUM' then
    begin
      PostMessage(ActiveControl.Handle, WM_CHAR, vkKeyScan(sKeyVal[1]),0);
    end

// --- Pass Through Keys --------
  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PMP' then        { Pump Number }
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset)

  else if sKeyType = 'PAT' then   {Pump Authorize}
     fmPOS.ProcessKeyPAT

  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpOnOff.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpOnOff.FormShow(Sender: TObject);
begin
  RefreshFields;
  ePumpNo.SetFocus;
  ePumpNo.SelectAll;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpOnOff.RefreshFields
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpOnOff.RefreshFields;
begin
   ePumpNo.Text   := '0';
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpOnOff.ChangeMode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpOnOff.ChangeMode;
var
pNo : integer;
begin

  try
    pNo := StrToInt(ePumpNo.Text);
  except
    pNo := 0;
  end;
  if (pNo > 0) and (pNo <= 24) then
    begin
      if pnlPumpMode.Caption = 'Offline' then
        fmPOS.SendFuelMessage( pNo, PMP_OFFLINE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
      else
        fmPOS.SendFuelMessage( pNo, PMP_ONLINE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
    end;

  fmPumpOnOff.Close;

end;


end.

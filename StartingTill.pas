{-----------------------------------------------------------------------------
 Unit Name: StartingTill
 Author:    Gary Whetton
 Date:      4/13/2004 4:22:11 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit StartingTill;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  POSMain, Grids, DBGrids, StdCtrls, Mask, DBCtrls, ExtCtrls, POSBtn,
  ToolEdit, CurrEdit;

type
  TfmStartingTill = class(TForm)
    Label1: TLabel;
    eStartingTill: TEdit;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
  end;

var
  fmStartingTill: TfmStartingTill;
  KeyBuff: array[0..200] of Char;


  CurField: Integer;
Keytops  : array[1..12] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT');
POSButtons    : array[1..12] of TPOSTouchButton;

EntryStr : string;

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
  Name:      TfmStartingTill.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmStartingTill.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.ProcessKey;
begin

  if sKeyType = 'ENT' then
    begin
      with POSDataMod.IBTempQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('Update Totals set StartingTill = :pStartingTill where (TerminalNo = ' + IntToStr(fmPOS.ThisTerminalNo) +
                                ') and (ShiftNo = ' + IntToStr(nShiftNo) + ')');
          ParamByName('pStartingTill').AsCurrency := StrToCurr(eStartingTill.Text);
          ExecSQL;
        end;
      Close;


    end
  else if sKeyType = 'CLR' then
//   fmChangeFuelPrice.Close
    begin
      EntryStr := '0';
      eStartingTill.Text := '0.00';
      eStartingTill.SetFocus;
      eStartingTill.SelectAll;
    end

  else if sKeyType = 'ERC' then
    begin
      PostMessage(ActiveControl.Handle, WM_KEYDOWN, VK_BACK, 0);
    end

  else if sKeyType = 'NUM' then
    begin
      EntryStr := EntryStr + sKeyVal[1];
      eStartingTill.Text := FormatFloat('0.00',  (StrToFloat(EntryStr) / 100));
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
  Name:      TfmStartingTill.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.FormShow(Sender: TObject);
begin

  if POSButtons[1] = nil then
    BuildTouchPad;
  EntryStr := '0';
  eStartingTill.Text := '0.00';
  eStartingTill.SetFocus;
  eStartingTill.SelectAll;

end;


{-----------------------------------------------------------------------------
  Name:      TfmStartingTill.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.BuildTouchPad;
var
KeyNo, Row, Col : integer;
begin

  KeyNo := 1;
  for Row := 1 to 4 do
    for Col := 1 to 3 do
      begin
        BuildButton(Row, Col, KeyNo);
        Inc(KeyNo);
      end;



end;


{-----------------------------------------------------------------------------
  Name:      TfmStartingTill.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.BuildButton(RowNo, ColNo, KeyNo : short );
var
TopKeyPos : short;
KeyColOffset : short;
sBtnColor : string;
nBtnShape, nBtnCOlor : short;
begin

  TopKeyPos := 110;

  KeyColOffset := Trunc((fmChangeFuelPrice.Width - (3 * 65)) /2) ;


  POSButtons[KeyNo]             := TPOSTouchButton.Create(Self);
  POSButtons[KeyNo].Parent      := Self;
  POSButtons[KeyNo].Name        := 'User' + IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 65);
  POSButtons[KeyNo].Left        := ((ColNo - 1) * 65) + KeyColOffset;
  POSButtons[KeyNo].KeyRow      := RowNo;
  POSButtons[KeyNo].KeyCol      := ColNo;
  POSButtons[KeyNo].Height      := 60;
  POSButtons[KeyNo].Width       := 60;
  POSButtons[KeyNo].Visible     := True;
  POSButtons[KeyNo].OnClick     := POSButtonClick;
  POSButtons[KeyNo].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[KeyNo].FrameStyle  := bfsNone;
  POSButtons[KeyNo].WordWrap    := True;
  POSButtons[KeyNo].Tag         := KeyNo;
  POSButtons[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  POSButtons[KeyNo].NumGlyphs   := 14;
  POSButtons[KeyNo].Frame       := 8;
  POSButtons[KeyNo].ShowHint := False;

  POSButtons[KeyNo].Font.Name := 'System';
  POSButtons[KeyNo].Font.Color := clBlack;
  POSButtons[KeyNo].Font.Size := 12;
//  POSButtons[KeyNo].Font.Style := [fsBold]

  if KeyNo = 10 then
    begin
      POSButtons[KeyNo].KeyType := 'CLR - Clear';
      POSButtons[KeyNo].Caption := 'Clear';
      sBtnColor := 'YELLOW';
      nBtnShape := 1;
    end
  else if KeyNo = 12 then
    begin
      POSButtons[KeyNo].KeyType := 'ENT - Enter';
      POSButtons[KeyNo].Caption := 'Enter';
      sBtnColor := 'RED';
      nBtnShape := 1;
    end
  else
    begin
      POSButtons[KeyNo].KeyType := 'NUM';
      POSButtons[KeyNo].Caption := KeyTops[KeyNo];
      POSButtons[KeyNo].KeyVal  := KeyTops[KeyNo];
      sBtnColor := 'WHITE';
      nBtnShape := 2;
    end;
  nBtnColor := 6;
  if sBtnColor = 'BLUE' then
    nBtnColor := 1
  else if sBtnColor = 'GREEN' then
    nBtnColor := 2
  else if sBtnColor = 'RED' then
    nBtnColor := 3
  else if sBtnColor = 'WHITE' then
    nBtnColor := 4
  else if sBtnColor = 'MAGENTA' then
    nBtnColor := 5
  else if sBtnColor = 'CYAN' then
    nBtnColor := 6
  else if sBtnColor = 'YELLOW' then
    nBtnColor := 7 ;

  if nBtnShape = 1 then
    Inc(nBtnColor,7);

  POSButtons[KeyNo].Frame := nBtnColor;

end;


{-----------------------------------------------------------------------------
  Name:      TfmStartingTill.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmStartingTill.POSButtonClick(Sender: TObject);
begin

  if (Sender is TPOSTouchButton) then
    begin
//      if not POSDataMod.TouchTable.Locate('CODE',TPOSTouchButton(Sender).Keycode,SearchOption) then
//        ShowMessage('Record Not Found')
//      else
//        begin
          sKeyType := TPOSTouchButton(Sender).KeyType ;
          sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
          sPreset  := TPOSTouchButton(Sender).KeyPreset ;
          ProcessKey;
//        end;
    end;

end;

end.

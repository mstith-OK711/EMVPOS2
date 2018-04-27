{-----------------------------------------------------------------------------
 Unit Name: PriceOverride
 Author:    Gary Whetton
 Date:      4/13/2004 4:16:17 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PriceOverride;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  POSBTN, ElastFrm, StdCtrls, POSMain;

type
  TfmPriceOverride = class(TForm)
    fldPrice: TEdit;
    ElasticForm1: TElasticForm;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
  end;

var
  fmPriceOverride: TfmPriceOverride;
  KeyBuff: array[0..200] of Char;
  Keytops  : array[1..13] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT', 'CLS');
  POSButtons2    : array[1..13] of TPOSTouchButton;

implementation

var
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmPriceOverride.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.ProcessKey;
begin
  if sKeyType = 'NUM' then
  begin
    fldPrice.text := fldPrice.text + sKeyVal;
  end
  else if sKeyType = 'CLR' then
  Begin
    fldPrice.text := '';
  end
  else if sKeyType = 'ENT' then
  begin
    try
      strtoint(fldPrice.text);
      close;
    except
      showmessage('Price must be a number.');
    end;
  end
  else if sKeyType = 'CLS' then
  begin
    //Build 19
    fldPrice.text := '';
    //Build 19
    close;
  end
  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PMP' then        { Pump Number }
    fmPOS.ProcessKeyPMP(sKeyVal, sPreset)
  else if sKeyType = 'PAL' then        { Pump Authorize All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceOverride.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmPriceOverride.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.BuildTouchPad;
var
KeyNo, Row, Col : integer;
begin
  KeyNo := 1;
  for Row := 1 to 5 do
    for Col := 1 to 3 do
    begin
      //Build 23
      if KeyNo < 14 then
      //Build 23
        BuildButton(Row, Col, KeyNo);
      Inc(KeyNo);
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceOverride.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.BuildButton(RowNo, ColNo, KeyNo : short );
var
  TopKeyPos : short;
  KeyColOffset : short;
  sBtnColor : string;
  nBtnShape, nBtnCOlor : short;
  POSScreenSize : integer;

begin
  TopKeyPos := 0;
  KeyColOffset := 0;
  if screen.width = 800 then
    POSScreenSize := 2
  else
    POSScreenSize := 1;
  case POSScreenSize of
  1: begin
       TopKeyPos := 60;
       KeyColOffset := 60;//Trunc((fmPLUEdit.Width - (3 * 65)) /2) ;
     end;
  2: begin
       TopKeyPos := 50;
       KeyColOffset := 50;//Trunc((fmPLUEdit.Width - (3 * 50)) /2) ;
     end;
  end;
  POSButtons2[KeyNo]             := TPOSTouchButton.Create(Self);
  POSButtons2[KeyNo].Parent      := Self;
  POSButtons2[KeyNo].Name        := 'Numbers' + IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons2[KeyNo].KeyRow      := RowNo;
  POSButtons2[KeyNo].KeyCol      := ColNo;
  case POSScreenSize of
  1: begin
       POSButtons2[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 65);
       POSButtons2[KeyNo].Left        := ((ColNo - 1) * 65) + KeyColOffset;
       POSButtons2[KeyNo].Height      := 60;
       POSButtons2[KeyNo].Width       := 60;
       POSButtons2[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
     end;
  2: begin
       POSButtons2[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 50);
       POSButtons2[KeyNo].Left        := ((ColNo - 1) * 50) + KeyColOffset;
       POSButtons2[KeyNo].Height      := 47;
       POSButtons2[KeyNo].Width       := 47;
       POSButtons2[KeyNo].Glyph.LoadFromResourceName(HInstance, 'BTN47');
     end;
  end;
  POSButtons2[KeyNo].Visible     := True;
  POSButtons2[KeyNo].Transparent := True;
  POSButtons2[KeyNo].OnClick     := POSButtonClick;
  POSButtons2[KeyNo].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons2[KeyNo].FrameStyle  := bfsNone;
  POSButtons2[KeyNo].WordWrap    := True;
  POSButtons2[KeyNo].Tag         := KeyNo;
  POSButtons2[KeyNo].NumGlyphs   := 14;
  POSButtons2[KeyNo].Frame       := 8;
  POSButtons2[KeyNo].MaskColor   := fmPriceOverride.Color;
  POSButtons2[KeyNo].ShowHint := False;
  POSButtons2[KeyNo].Font.Name := 'Arial';
  POSButtons2[KeyNo].Font.Color := clBlack;
  POSButtons2[KeyNo].Font.Size := 10;
//  POSButtons2[KeyNo].Font.Style := [fsBold]

  if KeyNo = 10 then
  begin
    POSButtons2[KeyNo].KeyType := 'CLR - Clear';
    POSButtons2[KeyNo].Caption := 'Clear';
    sBtnColor := 'YELLOW';
    nBtnShape := 1;
  end
  else if KeyNo = 12 then
  begin
    POSButtons2[KeyNo].KeyType := 'ENT - Enter';
    POSButtons2[KeyNo].Caption := 'Enter';
    sBtnColor := 'RED';
    nBtnShape := 1;
  end
  else if KeyNo = 13 then
  begin
    POSButtons2[KeyNo].KeyType := 'CLS - Close';
    POSButtons2[KeyNo].Caption := 'Close';
    sBtnColor := 'RED';
    nBtnShape := 1;
  end
  else
  begin
    POSButtons2[KeyNo].KeyType := 'NUM';
    POSButtons2[KeyNo].Caption := KeyTops[KeyNo];
    POSButtons2[KeyNo].KeyVal  := KeyTops[KeyNo];
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
  POSButtons2[KeyNo].Frame := nBtnColor;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceOverride.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.POSButtonClick(Sender: TObject);
begin
  if (Sender is TPOSTouchButton) then
  begin
    sKeyType := TPOSTouchButton(Sender).KeyType ;
    sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
    sPreset  := TPOSTouchButton(Sender).KeyPreset ;
    ProcessKey;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceOverride.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceOverride.FormShow(Sender: TObject);
begin
  if POSButtons2[1] = nil then
    BuildTouchPad;
  //Build 19
  fldPrice.Text := '';
  //Build 19
end;

end.

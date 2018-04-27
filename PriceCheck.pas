{-----------------------------------------------------------------------------
 Unit Name: PriceCheck
 Author:    Gary Whetton
 Date:      4/13/2004 4:15:19 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PriceCheck;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ElastFrm, Mask, ToolEdit, CurrEdit, POSMain, POSBtn;

type
  TfmPriceCheck = class(TForm)
    ElasticForm1: TElasticForm;
    Label1: TLabel;
    fldDescription: TEdit;
    Label2: TLabel;
    btnClose: TBitBtn;
    fldPrice: TCurrencyEdit;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );
    procedure CCButtonClick(Sender: TObject);
  end;

var
  fmPriceCheck: TfmPriceCheck;
  POSButtons: array[1..3] of TPOSTouchButton;

implementation

uses POSDM;

{$R *.DFM}

var
  sKeyType  : string[3];
  sKeyVal   : string[12];
  sPreset   : string[20];

{-----------------------------------------------------------------------------
  Name:      TfmPriceCheck.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.FormShow(Sender: TObject);
begin
  //Build 19
  fldDescription.text := '';
  fldPrice.value := 0.00;
  //Build 19
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceCheck.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.ProcessKey;
begin
  if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL
  else if sKeyType = 'PMP' then        { Pump Number }
    fmPOS.ProcessKeyPMP(sKeyVal, sPreset)
  else if sKeyType = 'PAL' then        { Pump Authorize All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL
  else if sKeyType = 'MOD' then
  begin
    if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
    with POSDataMod.IBTempQry1 do
    begin
      Close;SQL.Clear;
      SQL.Add('Select P.PLUPrice, M.ModifierName from PLUMod P, Modifier M where ');
      SQL.Add('P.PLUModifierGroup = :pPLUModifierGroup and ');
      SQL.Add('P.PLUModifier = :pPLUModifier and ');
      SQL.Add('P.PLUModifierGroup = M.ModifierGroup and P.PLUModifier = M.ModifierNo');
      parambyname('pPLUModifierGroup').AsString := sKeyVal;
      parambyname('pPLUModifier').AsString := sPreset;
      Open;
      if RecordCount > 0 then
      begin
        fldPrice.Text := FieldByName('PLUPrice').AsString;
        fldDescription.Text := FieldByName('ModifierName').AsString;
      end;
      Close;
    end;
    if POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.Commit;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceCheck.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmPriceCheck.BuildkeyPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.BuildkeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin

  if screen.width = 800 then
    TopKeyPos := 98
  else
    TopKeyPos := 128;
  if POSButtons[BtnNdx] = nil then
  begin
    POSButtons[BtnNdx]         := TPOSTouchButton.Create(Self);//TPOSTouchButton.Create(self);

    POSButtons[BtnNdx].Parent  := self;
    POSButtons[BtnNdx].Name    := 'PriceCheck' + IntToStr(BtnNdx);//'PumpButton' + IntToStr(BtnNdx);
  end;

  if screen.width = 1024 then
  begin
    POSButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 65);
    POSButtons[BtnNdx].Left     := ((ColNo - 1) * 65) + 16;  // 20030708 - changed from 375
    POSButtons[BtnNdx].Height     := 60;
    POSButtons[BtnNdx].Width      := 60;
    POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  end
  else
  begin
    POSButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 50);
    POSButtons[BtnNdx].Left     := ((ColNo - 1) * 50) + 16;  // 20030708 - changed from 500
    POSButtons[BtnNdx].Height     := 47;
    POSButtons[BtnNdx].Width      := 47;
    POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
  end;
  POSButtons[BtnNdx].KeyRow     := RowNo;
  POSButtons[BtnNdx].KeyCol     := ColNo;
  POSButtons[BtnNdx].Visible    := True;
  POSButtons[BtnNdx].OnClick    := CCButtonClick;
  POSButtons[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[BtnNdx].FrameStyle := bfsNone;
  POSButtons[BtnNdx].WordWrap   := True;
  POSButtons[BtnNdx].Tag        := BtnNdx;
  POSButtons[BtnNdx].NumGlyphs  := 14;
  POSButtons[BtnNdx].Frame      := 8;
  POSButtons[BtnNdx].KeyPreset  := '';
  POSButtons[BtnNdx].MaskColor  := fmPriceCheck.Color;

  POSButtons[BtnNdx].Font.Color :=  clBlack;
  POSButtons[BtnNdx].Frame := 11;
  POSButtons[BtnNdx].KeyType            := 'MOD';
  POSButtons[BtnNdx].KeyVal             := POSDataMod.IBPLUQuery.fieldbyname('ModifierGroup').AsString;
  POSButtons[BtnNdx].KeyPreset          := IntToStr(POSDataMod.IBTempQuery.FieldByName('ModifierNo').AsInteger);
  POSButtons[BtnNdx].Caption         := POSDataMod.IBTempQuery.FieldByName('ModifierName').AsString;
  POSButtons[BtnNdx].Visible := True;



end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceCheck.CCButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.CCButtonClick(Sender: TObject);
var
  ndx : Byte;
begin
  if (Sender is TPOSTouchButton) then
  begin
    sKeyType := TPOSTouchButton(Sender).KeyType ;
    sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
    sPreset  := TPOSTouchButton(Sender).KeyPreset ;
    ProcessKey;
    for ndx := 1 to 3 do
      if POSButtons[ndx] <> nil then
        POSButtons[Ndx].Visible := False;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPriceCheck.btnCloseClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPriceCheck.btnCloseClick(Sender: TObject);
var
  ndx : Byte;
begin
  for ndx := 1 to 3 do
    if POSButtons[ndx] <> nil then
      POSButtons[Ndx].Visible := False;
  Close;
end;

end.

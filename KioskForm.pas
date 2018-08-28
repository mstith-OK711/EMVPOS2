{-----------------------------------------------------------------------------
 Unit Name: KioskForm
 Author:    Gary Whetton
 Date:      4/13/2004 4:25:33 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit KioskForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ElastFrm, POSBtn;

type
  TfmKiosk = class(TForm)
    ElasticForm1: TElasticForm;
    Label1: TLabel;
    fldKioskCode: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KioskButtonClick(Sender: TObject);
    procedure BuildTouchPad;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );
    procedure SetNumberPad;
    procedure ProcessKey;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  fmKiosk: TfmKiosk;
  Keytops      : array[1..15] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '', '0', '', 'C', 'B', 'E');
  POSKioskButtons    : array[1..15] of TPOSTouchButton;

implementation

uses POSMain;

var
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{$R *.dfm}

{-----------------------------------------------------------------------------
  Name:      TfmKiosk.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.FormCreate(Sender: TObject);
begin
  if screen.width > 800 then
  begin
    fmKiosk.Left := 205;
    fmKiosk.Top  := 350;
  end
  else
  begin
    fmKiosk.Left := 123;
    fmKiosk.Top  := 265;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.FormShow(Sender: TObject);
begin
  case fmPOS.POSScreenSize of
    1 :
      begin
        fmKiosk.Left := 205;
        fmKiosk.Top  := 350;
      end;
    2 :
      begin
        fmKiosk.Left := 123;
        fmKiosk.Top  := 265;
      end;
  end;

  BuildTouchPad;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.BuildTouchPad;
var
nRowNo : short;
nColNo : short;
nBtnNo : short;

begin
  nBtnNo := 1;
  for nRowNo := 1 to 5 do
    for nColNo := 1 to 3 do
    begin
      BuildKeyPad(nRowNo, nColNo, nBtnNo );
      Inc(nBtnNo);
    end;
  SetNumberPad;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.BuildKeyPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.BuildKeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin
  if screen.width = 800 then
    TopKeyPos := 48
  else
    TopKeyPos := 64;
  if POSKioskButtons[BtnNdx] = nil then
  begin
    POSKioskButtons[BtnNdx]         := TPOSTouchButton.Create(fmKiosk);

    POSKioskButtons[BtnNdx].Parent  := fmKiosk;
    POSKioskButtons[BtnNdx].Name    := 'KioskButton' + IntToStr(BtnNdx);
  end;

  if screen.width = 1024 then
  begin
    POSKioskButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 65);
    POSKioskButtons[BtnNdx].Left     := ((ColNo - 1) * 65) + 400;
    POSKioskButtons[BtnNdx].Height     := 60;
    POSKioskButtons[BtnNdx].Width      := 60;
    POSKioskButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  end
  else
  begin
    POSKioskButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 50);
    POSKioskButtons[BtnNdx].Left     := ((ColNo - 1) * 50) + 375;
    POSKioskButtons[BtnNdx].Height     := 47;
    POSKioskButtons[BtnNdx].Width      := 47;
    POSKioskButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
  end;
  POSKioskButtons[BtnNdx].KeyRow     := RowNo;
  POSKioskButtons[BtnNdx].KeyCol     := ColNo;
  POSKioskButtons[BtnNdx].Visible    := True;
  POSKioskButtons[BtnNdx].OnClick    := KioskButtonClick;
  POSKioskButtons[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSKioskButtons[BtnNdx].FrameStyle := bfsNone;
  POSKioskButtons[BtnNdx].WordWrap   := True;
  POSKioskButtons[BtnNdx].Tag        := BtnNdx;
  POSKioskButtons[BtnNdx].NumGlyphs  := 14;
  POSKioskButtons[BtnNdx].Frame      := 8;
  POSKioskButtons[BtnNdx].KeyPreset  := '';
  POSKioskButtons[BtnNdx].MaskColor  := fmKiosk.Color;

  POSKioskButtons[BtnNdx].Font.Color :=  clBlack;
  POSKioskButtons[BtnNdx].Frame := 11;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.SetNumberPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.SetNumberPad;
var
BtnNdx : short;
begin
  for BtnNdx := 1 to 15 do
  begin
    case BtnNdx of
      15 :
          begin
            POSKioskButtons[BtnNdx].Visible := True;
            POSKioskButtons[BtnNdx].KeyType   := 'ENT';
            POSKioskButtons[BtnNdx].KeyVal := '';
            POSKioskButtons[BtnNdx].Caption := 'Enter';
          end;
      14 :
          begin
            POSKioskButtons[BtnNdx].Visible := True;
            POSKioskButtons[BtnNdx].KeyType   := 'BSP';
            POSKioskButtons[BtnNdx].KeyVal := '';
            POSKioskButtons[BtnNdx].Caption := 'Back Space';
          end;
      13 :
          begin
            POSKioskButtons[BtnNdx].Visible := True;
            POSKioskButtons[BtnNdx].KeyType   := 'CLR';
            POSKioskButtons[BtnNdx].KeyVal := '';
            POSKioskButtons[BtnNdx].Caption := 'Clear';
          end;
      10, 12 :
          begin
            POSKioskButtons[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSKioskButtons[BtnNdx].Visible  := True;
          POSKioskButtons[BtnNdx].KeyType  := 'NUM - Number';
          POSKioskButtons[BtnNdx].KeyVal   := KeyTops[BtnNdx];
          POSKioskButtons[BtnNdx].Caption  := KeyTops[BtnNdx];
        end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.KioskButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.KioskButtonClick(Sender: TObject);
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
  Name:      TfmKiosk.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.ProcessKey;
begin
  while True do
  begin
    if sKeyType = 'CLR' then
    begin
      if fldKioskCode.text = '' then
        close
      else
        fldKioskCode.text := '';
    end
    else if sKeyType = 'BSP' then
    begin
      if length(fldKioskCode.Text) > 0 then
        fldKioskCode.Text := copy(fldKioskCode.Text, 1, (length(fldKioskCode.Text) - 1));
    end
    else if sKeyType = 'NUM' then
      fldKioskCode.Text := fldKioskCode.Text + sKeyVal
    else if sKeyType = 'ENT' then
    begin
      if length(fldKioskCode.Text) > 0 then
      begin
        sEntry := fldKioskCode.Text;
        Close;
      end;
    end
    else if sKeyType = 'PMP' then        {Pump Number}
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset)
    else if sKeyType = 'PAT' then        {Pump Authorize}
      fmPOS.ProcessKeyPAT
    else if sKeyType = 'PAL' then        {Pump Authorize All}
      fmPOS.ProcessKeyPAL
    else if sKeyType = 'EHL' then        { Emergency Halt }
      fmPOS.ProcessKeyEHL
    else if sKeyType = 'PHL' then        { Pump Halt }
      fmPOS.ProcessKeyPHL;
    break;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmKiosk.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmKiosk.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fldKioskCode.Text := '';
end;

end.

unit PopUpMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, RXCombos, POSBtn, POSMain;

type
  TfmMsgView = class(TForm)
    Image1: TImage;
    POSTouchButton1: TPOSTouchButton;
    procedure FormShow(Sender: TObject);
    procedure POSTouchButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMsgView: TfmMsgView;

implementation

uses PosDm;

{$R *.DFM}


procedure TfmMsgView.FormShow(Sender: TObject);
var
TmpRect : TRect;
Flags : Longint;
ItemLen : integer;
HighLighted : Boolean;
DC : THandle;
nTop, nBot, x : integer;
begin

  DC := Image1.Picture.Bitmap.Canvas.Handle;

  Image1.Picture.Bitmap.Canvas.Font.Assign( fmMsgView.Font ) ;
  Image1.Picture.Bitmap.Canvas.Font.Name          := 'Arial';
  Image1.Picture.Bitmap.Canvas.Font.Color         := clRed;
  Image1.Picture.Bitmap.Canvas.Font.PixelsPerInch := 96;
  Image1.Picture.Bitmap.Canvas.Font.Size          := 16;
  Image1.Picture.Bitmap.Canvas.Font.Style := [fsBold,fsItalic] ;
  TmpRect := Rect(82, 0, Image1.Width, 72);

  Image1.Picture.Bitmap.Canvas.Brush.Style := bsClear;
  Image1.Picture.Bitmap.Canvas.FillRect(TmpRect);
  Flags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  ItemLen := Length(POSDataMod.MsgTable.FieldByName('MsgHeader').AsString) ;
  DC := Image1.Picture.Bitmap.Canvas.Handle;
  SetBkMode(DC,Windows.TRANSPARENT);
  DrawText(DC,
           PChar(POSDataMod.MsgTable.FieldByName('MsgHeader').AsString),
           ItemLen, TmpRect, Flags);

  nTop := 74;
  nBot := 96;
  for x := 1 to 10 do
    begin
      Image1.Picture.Bitmap.Canvas.Font.Color := clBlack;
      Image1.Picture.Bitmap.Canvas.Font.Size  := 10;
      Image1.Picture.Bitmap.Canvas.Font.Style := [fsBold] ;
      TmpRect := Rect(82 , nTop, Image1.Width,  nBot);
      Image1.Canvas.Brush.Style := bsClear;
      Image1.Canvas.FillRect(TmpRect);
      Flags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER);
      ItemLen := Length(POSDataMod.MsgTable.FieldByName('MsgLine' + IntToStr(x)).AsString) ;
      DC := Image1.Picture.Bitmap.Canvas.Handle;
      SetBkMode(DC,Windows.TRANSPARENT);
      DrawText(DC, PChar(POSDataMod.MsgTable.FieldByName('MsgLine' + IntToStr(x)).AsString), ItemLen, TmpRect, Flags);
      Inc(nTop,24);
      Inc(nBot,24);
    end;

end;

procedure TfmMsgView.POSTouchButton1Click(Sender: TObject);
begin
  Close;
end;

end.

{-----------------------------------------------------------------------------
 Unit Name: PopMsg
 Author:    Gary Whetton
 Date:      9/11/2003 3:12:32 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PopMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, RXCombos, POSBtn, POSMain;

type
  TfmPopUpMsg = class(TForm)
    Image1: TImage;
    POSTouchButton1: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    procedure FormShow(Sender: TObject);
    procedure POSTouchButton1Click(Sender: TObject);
    procedure POSTouchButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmPopUpMsg: TfmPopUpMsg;

implementation

uses PosDm, POSPrt, Reports, POSLog;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmPopUpMsg.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPopUpMsg.FormShow(Sender: TObject);
var
TmpRect : TRect;
Flags : Longint;
ItemLen : integer;
DC : THandle;
nTop, nBot, x : integer;
tmpPChar : array[0..50] of char;
begin

  Image1.Picture.BitMap.LoadFromResourceName(HInstance, 'MSGPAD');

//cwe  DC := Image1.Picture.Bitmap.Canvas.Handle;

  Image1.Picture.Bitmap.Canvas.Font.Assign( fmPopUpMsg.Font ) ;
  Image1.Picture.Bitmap.Canvas.Font.Name          := 'Arial';
  Image1.Picture.Bitmap.Canvas.Font.Color         := clRed;
  Image1.Picture.Bitmap.Canvas.Font.PixelsPerInch := 96;
  Image1.Picture.Bitmap.Canvas.Font.Size          := 16;
  Image1.Picture.Bitmap.Canvas.Font.Style := [fsBold,fsItalic] ;
  TmpRect := Rect(82, 0, Image1.Width, 72);

  Image1.Picture.Bitmap.Canvas.Brush.Style := bsClear;
  Image1.Picture.Bitmap.Canvas.FillRect(TmpRect);
  Flags := DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  ItemLen := Length( PopUpMsg^.MsgHeader ) ;
  DC := Image1.Picture.Bitmap.Canvas.Handle;
  SetBkMode(DC,Windows.TRANSPARENT);
  StrPCopy(tmpPChar, PopUpMsg^.MsgHeader );
  DrawText(DC,
           tmpPChar ,
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
      ItemLen := Length(PopUpMsg^.MsgLine[x]) ;
      DC := Image1.Picture.Bitmap.Canvas.Handle;
      SetBkMode(DC,Windows.TRANSPARENT);
      StrPCopy(tmpPChar, PopUpMsg^.MsgLine[x] );

      DrawText(DC, tmpPChar, ItemLen, TmpRect, Flags);
      Inc(nTop,24);
      Inc(nBot,24);
    end;

  POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'BIGYLW_SQ');
  POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'BIGYLW_SQ');


end;


{-----------------------------------------------------------------------------
  Name:      TfmPopUpMsg.POSTouchButton1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPopUpMsg.POSTouchButton1Click(Sender: TObject);
begin
  ModalResult := mrOK;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPopUpMsg.POSTouchButton2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPopUpMsg.POSTouchButton2Click(Sender: TObject);
var
x : short;
begin

  LineOut( '========================================');
  LineOut( 'Message: ' + PopUpMsg^.MsgHeader);
  LineOut( 'Date  : ' + DateToStr(Date));
  LineOut( 'Time  : ' + TimeToStr(Time));
  LineOut( '----------------------------------------');

  for x := 1 to 10 do
    LineOut( PopUpMsg^.MsgLine[x] );

  fmPOS.AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  POSPrt.PrintSeq;
  LogRpt('Print Message');

  ModalResult := mrOK;
  Close;

end;

end.

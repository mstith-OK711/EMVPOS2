object POSMenu: TPOSMenu
  Left = 0
  Top = -1
  HelpContext = 571
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'RSG Retail'
  ClientHeight = 713
  ClientWidth = 1016
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'System'
  Font.Style = [fsBold]
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 1016
    Height = 2
    Align = alTop
    Shape = bsTopLine
  end
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 1025
    Height = 721
  end
end

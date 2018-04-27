object fmChangeFuelPrice: TfmChangeFuelPrice
  Left = 444
  Top = 170
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Change Fuel Prices'
  ClientHeight = 420
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 79
    Top = 75
    Width = 60
    Height = 22
    Alignment = taRightJustify
    Caption = 'Price :'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object eCashPrice: TMaskEdit
    Left = 146
    Top = 72
    Width = 63
    Height = 30
    EditMask = '0.000;1;0'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    MaxLength = 5
    ParentFont = False
    TabOrder = 0
    Text = ' .   '
  end
  object pnlGradeName: TPanel
    Left = 8
    Top = 8
    Width = 273
    Height = 41
    BevelInner = bvLowered
    BevelWidth = 2
    Color = clNavy
    Font.Charset = ANSI_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
end

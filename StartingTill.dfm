object fmStartingTill: TfmStartingTill
  Left = 404
  Top = 86
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Enter Starting Till Amount'
  ClientHeight = 420
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 10
    Top = 43
    Width = 105
    Height = 24
    Caption = 'Starting Till'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object eStartingTill: TEdit
    Left = 144
    Top = 40
    Width = 121
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'DejaVu Sans Mono'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    Text = '0.00'
  end
end

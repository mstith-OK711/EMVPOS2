object SigExtractMain: TSigExtractMain
  Left = 704
  Top = 79
  Width = 848
  Height = 195
  Caption = 'Signature Extract'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SigImg: TImage
    Left = 176
    Top = 8
    Width = 609
    Height = 113
    DragMode = dmAutomatic
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 48
    Width = 145
    Height = 21
    Enabled = False
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboBox1Change
  end
  object CopyToClipBoard: TButton
    Left = 32
    Top = 80
    Width = 113
    Height = 25
    Caption = 'Copy to Clipboard'
    Enabled = False
    TabOrder = 1
    OnClick = CopyToClipBoardClick
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'Open'
        OnClick = Open1Click
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 48
    Top = 8
  end
end

object fmPriceCheck: TfmPriceCheck
  Left = 378
  Top = 168
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Price Check'
  ClientHeight = 307
  ClientWidth = 241
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 103
    Height = 16
    Caption = 'Item Description'
  end
  object Label2: TLabel
    Left = 16
    Top = 64
    Width = 65
    Height = 16
    Caption = 'Item Price'
  end
  object fldDescription: TEdit
    Left = 16
    Top = 32
    Width = 209
    Height = 24
    TabOrder = 0
  end
  object btnClose: TBitBtn
    Left = 96
    Top = 240
    Width = 60
    Height = 60
    Caption = 'Close'
    TabOrder = 1
    OnClick = btnCloseClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00388888888877
      F7F787F8888888888333333F00004444400888FFF444448888888888F333FF8F
      000033334D5007FFF4333388888888883338888F0000333345D50FFFF4333333
      338F888F3338F33F000033334D5D0FFFF43333333388788F3338F33F00003333
      45D50FEFE4333333338F878F3338F33F000033334D5D0FFFF43333333388788F
      3338F33F0000333345D50FEFE4333333338F878F3338F33F000033334D5D0FFF
      F43333333388788F3338F33F0000333345D50FEFE4333333338F878F3338F33F
      000033334D5D0EFEF43333333388788F3338F33F0000333345D50FEFE4333333
      338F878F3338F33F000033334D5D0EFEF43333333388788F3338F33F00003333
      4444444444333333338F8F8FFFF8F33F00003333333333333333333333888888
      8888333F00003333330000003333333333333FFFFFF3333F00003333330AAAA0
      333333333333888888F3333F00003333330000003333333333338FFFF8F3333F
      0000}
    Layout = blGlyphTop
    NumGlyphs = 2
  end
  object fldPrice: TCurrencyEdit
    Left = 16
    Top = 88
    Width = 121
    Height = 24
    AutoSize = False
    TabOrder = 2
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 776
    DesignPixelsPerInch = 96
    DesignFormWidth = 249
    DesignFormHeight = 341
    DesignFormClientWidth = 241
    DesignFormClientHeight = 307
    DesignFormLeft = 378
    DesignFormTop = 168
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 152
    Top = 64
  end
end

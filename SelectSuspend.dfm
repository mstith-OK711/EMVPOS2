object fmSuspend: TfmSuspend
  Left = 258
  Top = 110
  Width = 696
  Height = 534
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Pending Sales'
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
    Left = 8
    Top = 8
    Width = 85
    Height = 16
    Caption = 'Transaction #'
  end
  object Label2: TLabel
    Left = 136
    Top = 8
    Width = 71
    Height = 16
    Caption = 'Description'
  end
  object Label3: TLabel
    Left = 408
    Top = 8
    Width = 37
    Height = 16
    Caption = 'Count'
  end
  object Label4: TLabel
    Left = 512
    Top = 8
    Width = 49
    Height = 16
    Caption = 'Amount'
  end
  object LBSuspend: TListBox
    Left = 8
    Top = 32
    Width = 673
    Height = 393
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'DejaVu Sans Mono'
    Font.Style = [fsBold]
    ItemHeight = 22
    ParentFont = False
    TabOrder = 0
    OnDblClick = btnSelectSuspendedClick
  end
  object btnSelectSuspended: TBitBtn
    Left = 280
    Top = 432
    Width = 60
    Height = 60
    Caption = 'Select'
    TabOrder = 1
    OnClick = btnSelectSuspendedClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
      FFFFFFF000FFFFF000FFFF0FCC0FFF0FCC0FFF0FCC0FFF0FCC0FFF0FCC0FFF0F
      CC0FF0CCCCF0F0CCCCF0F0CCCCF0F0CCCCF0F0CCFFF0F0CCFFF0F0FFFFF0F0FF
      FFF0F0FFFFF0F0FFFFF0F0FFFFF0F0FFFFF0FF0FFF0FFF0FFF0FFF0FFF0FFF0F
      FF0FFF0FFF0FFF0FFF0FFFF000FFFFF000FFFFFFFFFFFFFFFFFF}
    Layout = blGlyphTop
  end
  object btnClose: TBitBtn
    Left = 368
    Top = 432
    Width = 60
    Height = 60
    Caption = 'Close'
    TabOrder = 2
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
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 776
    DesignPixelsPerInch = 96
    DesignFormWidth = 696
    DesignFormHeight = 534
    DesignFormClientWidth = 688
    DesignFormClientHeight = 500
    DesignFormLeft = 258
    DesignFormTop = 110
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 88
    Top = 400
  end
end

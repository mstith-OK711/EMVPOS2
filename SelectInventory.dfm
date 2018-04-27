object fmInventorySelect: TfmInventorySelect
  Left = 428
  Top = 270
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Inventory Selection'
  ClientHeight = 77
  ClientWidth = 204
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 16
  object btnReceive: TBitBtn
    Left = 8
    Top = 8
    Width = 60
    Height = 60
    Caption = 'Receive'
    TabOrder = 0
    OnClick = btnReceiveClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
      6666666666666666666666660000666666666666666666666666666666666666
      0000666666666666666666666666666666666666000066666666FFF666666666
      666666FFF666666600006666666822F66666666666666877F666666600006666
      666822F66666666666666877F666666600006666666822F66666666666666877
      F666666600006666FFF622FFFFF6666666FFF777FFFFF6660000666822222222
      22F66666687777777777F666000066682222222222F66666687777777777F666
      000066688888226888666666688888777888666600006666666822F666666666
      66666877F666666600006666666822F66666666666666877F666666600006666
      666822F66666666666666877F666666600006666666888666666666666666888
      6666666600006666666666666666666666666666666666660000666666666666
      6666666666666666666666660000666666666666666666666666666666666666
      0000}
    Layout = blGlyphTop
    NumGlyphs = 2
  end
  object btnAdjust: TBitBtn
    Left = 72
    Top = 8
    Width = 60
    Height = 60
    Caption = 'Adjust'
    TabOrder = 1
    OnClick = btnAdjustClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
      6666666666666666666666660000666666666666666666666666666666666666
      0000666666666666666666666666666666666666000066666666666666666666
      6666666666666666000066666666666666666666666666666666666600006666
      6666666666666666666666666666666600006666666666666666666666666666
      6666666600006666FFFFFFFFFFF6666666FFFFFFFFFFF6660000666811111111
      11F66666687777777777F666000066681111111111F66666687777777777F666
      0000666888888888886666666888888888886666000066666666666666666666
      6666666666666666000066666666666666666666666666666666666600006666
      6666666666666666666666666666666600006666666666666666666666666666
      6666666600006666666666666666666666666666666666660000666666666666
      6666666666666666666666660000666666666666666666666666666666666666
      0000}
    Layout = blGlyphTop
    NumGlyphs = 2
  end
  object btnCancel: TBitBtn
    Left = 136
    Top = 8
    Width = 60
    Height = 60
    Caption = 'Close'
    TabOrder = 2
    OnClick = btnCancelClick
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
    DesignFormWidth = 212
    DesignFormHeight = 111
    DesignFormClientWidth = 204
    DesignFormClientHeight = 77
    DesignFormLeft = 428
    DesignFormTop = 270
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 104
    Top = 32
  end
end
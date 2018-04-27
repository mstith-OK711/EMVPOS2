object fmPumpInfo: TfmPumpInfo
  Left = 323
  Top = 197
  Width = 376
  Height = 450
  Caption = 'Pump Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LB: TTextListBox
    Left = 16
    Top = 8
    Width = 337
    Height = 361
    ItemHeight = 13
    TabOrder = 0
  end
  object btnExit: TButton
    Left = 280
    Top = 384
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = btnExitClick
  end
  object btnRefresh: TButton
    Left = 16
    Top = 384
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 2
    OnClick = btnRefreshClick
  end
end

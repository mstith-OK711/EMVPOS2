object fmSetTerminal: TfmSetTerminal
  Left = 289
  Top = 103
  Width = 218
  Height = 184
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Set Terminal Number'
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
  object Label1: TLabel
    Left = 32
    Top = 43
    Width = 68
    Height = 16
    Caption = 'Terminal #'
  end
  object edTerminalNo: TRxSpinEdit
    Left = 120
    Top = 40
    Width = 57
    Height = 24
    Decimal = 0
    MaxValue = 9.000000000000000000
    MinValue = 1.000000000000000000
    Value = 1.000000000000000000
    TabOrder = 0
  end
  object btnOK: TBitBtn
    Left = 72
    Top = 96
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 748
    DesignPixelsPerInch = 96
    DesignFormWidth = 218
    DesignFormHeight = 184
    DesignFormClientWidth = 210
    DesignFormClientHeight = 150
    DesignFormLeft = 289
    DesignFormTop = 103
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 8
    Top = 96
  end
end

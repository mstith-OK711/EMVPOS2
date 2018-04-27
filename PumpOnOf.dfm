object fmPumpOnOff: TfmPumpOnOff
  Left = 302
  Top = 259
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'Pump On/Off Line'
  ClientHeight = 127
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 67
    Top = 75
    Width = 72
    Height = 24
    Alignment = taRightJustify
    Caption = 'Pump #'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object pnlPumpMode: TPanel
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
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object ePumpNo: TEdit
    Left = 160
    Top = 80
    Width = 49
    Height = 24
    TabOrder = 1
    Text = 'ePumpNo'
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 748
    DesignPixelsPerInch = 96
    DesignFormWidth = 298
    DesignFormHeight = 161
    DesignFormClientWidth = 290
    DesignFormClientHeight = 127
    DesignFormLeft = 302
    DesignFormTop = 259
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 248
    Top = 72
  end
end

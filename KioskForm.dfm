object fmKiosk: TfmKiosk
  Left = 204
  Top = 284
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Scan or Enter Kiosk Order Barcode Number or Order Number'
  ClientHeight = 446
  ClientWidth = 688
  Color = clBackground
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 261
    Height = 16
    Caption = 'Enter Receipt Barcode or Order Number  '
    Color = clBackground
    Font.Charset = ANSI_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object fldKioskCode: TEdit
    Left = 248
    Top = 16
    Width = 345
    Height = 24
    TabOrder = 0
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 776
    DesignPixelsPerInch = 96
    DesignFormWidth = 696
    DesignFormHeight = 480
    DesignFormClientWidth = 688
    DesignFormClientHeight = 446
    DesignFormLeft = 204
    DesignFormTop = 284
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 48
    Top = 184
  end
end

object fmFuelSelect: TfmFuelSelect
  Left = 290
  Top = 249
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'POS Fuel Select'
  ClientHeight = 212
  ClientWidth = 415
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 4
    Top = 8
    Width = 405
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 'XXXXXXXXXXXXXXXXXXXX'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 8
    Top = 56
    Width = 401
    Height = 41
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 6
    Top = 112
    Width = 401
    Height = 41
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 6
    Top = 168
    Width = 401
    Height = 41
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button3Click
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 748
    DesignPixelsPerInch = 96
    DesignFormWidth = 423
    DesignFormHeight = 246
    DesignFormClientWidth = 415
    DesignFormClientHeight = 212
    DesignFormLeft = 290
    DesignFormTop = 249
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 384
    Top = 8
  end
end

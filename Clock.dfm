object fmClockInOut: TfmClockInOut
  Left = 345
  Top = 167
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Clock In/Out'
  ClientHeight = 555
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  OldCreateOrder = False
  Position = poDesktopCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 136
    Width = 111
    Height = 37
    Caption = 'User ID'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 192
    Width = 150
    Height = 37
    Caption = 'Password'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object fldUserID: TEdit
    Left = 248
    Top = 128
    Width = 125
    Height = 44
    AutoSize = False
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'DejaVu Sans Mono'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnChange = fldUserIDChange
  end
  object fldPassword: TEdit
    Left = 248
    Top = 184
    Width = 125
    Height = 44
    AutoSize = False
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'DejaVu Sans Mono'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnChange = fldPasswordChange
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 385
    Height = 105
    BevelInner = bvLowered
    Caption = 'Clock In/Out'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1024
    DesignScreenHeight = 786
    DesignPixelsPerInch = 96
    DesignFormWidth = 388
    DesignFormHeight = 589
    DesignFormClientWidth = 380
    DesignFormClientHeight = 555
    DesignFormLeft = 345
    DesignFormTop = 167
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 160
    Top = 120
  end
end

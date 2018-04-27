object fmUser: TfmUser
  Left = 214
  Top = 8
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Select User'
  ClientHeight = 559
  ClientWidth = 452
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object lSubtotal: TLabel
    Left = 472
    Top = 6
    Width = 63
    Height = 20
    Caption = 'User ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 564
    Top = 6
    Width = 83
    Height = 20
    Caption = 'Username'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 88
    Top = 136
    Width = 100
    Height = 36
    Caption = 'User ID'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 88
    Top = 196
    Width = 120
    Height = 36
    Caption = 'Password'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
  end
  object DBGrid1: TDBGrid
    Left = 472
    Top = 32
    Width = 221
    Height = 225
    DataSource = POSDataMod.UserSource
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Options = [dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ParentFont = False
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'UserID'
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'UserName'
        Width = 150
        Visible = True
      end>
  end
  object Panel1: TPanel
    Left = 16
    Top = 8
    Width = 429
    Height = 113
    BevelInner = bvLowered
    Caption = 'System Log-On'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -64
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 224
    Top = 136
    Width = 125
    Height = 46
    AutoSelect = False
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    MaxLength = 4
    ParentFont = False
    TabOrder = 2
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 224
    Top = 192
    Width = 125
    Height = 46
    AutoSelect = False
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    MaxLength = 4
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 3
    OnChange = Edit2Change
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 748
    DesignPixelsPerInch = 96
    DesignFormWidth = 460
    DesignFormHeight = 593
    DesignFormClientWidth = 452
    DesignFormClientHeight = 559
    DesignFormLeft = 214
    DesignFormTop = 8
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    Version = 700.000000000000000000
    Left = 16
    Top = 160
  end
end

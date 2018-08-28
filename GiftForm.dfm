object fmGiftForm: TfmGiftForm
  Left = 17
  Top = 206
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Gift Card Balance Inquiry'
  ClientHeight = 431
  ClientWidth = 704
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clYellow
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnActivate = FormActivate
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object lStatus: TPanel
    Left = 16
    Top = 8
    Width = 681
    Height = 41
    BevelInner = bvLowered
    BevelWidth = 2
    Caption = 'lStatus'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object lPinPadStatus: TPanel
    Left = 16
    Top = 384
    Width = 369
    Height = 41
    Alignment = taLeftJustify
    BevelInner = bvLowered
    BevelWidth = 2
    Caption = 'lPinPadStatus'
    Color = clLime
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object leCardNo: TPOSLabeledEdit
    Left = 130
    Top = 92
    Width = 300
    Height = 24
    EditLabel.Width = 84
    EditLabel.Height = 16
    EditLabel.Caption = 'Card Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Card Number'
    TabOrder = 3
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leRestrictionCode: TPOSLabeledEdit
    Left = 130
    Top = 224
    Width = 121
    Height = 24
    EditLabel.Width = 104
    EditLabel.Height = 16
    EditLabel.Caption = 'Restriction Code'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Restriction Code'
    TabOrder = 2
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1024
    DesignScreenHeight = 786
    DesignPixelsPerInch = 96
    DesignFormWidth = 712
    DesignFormHeight = 465
    DesignFormClientWidth = 704
    DesignFormClientHeight = 431
    DesignFormLeft = 17
    DesignFormTop = 206
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 672
    Top = 400
  end
  object AuthTimeOutTimer: TTimer
    Enabled = False
    OnTimer = AuthTimeOutTimerTimer
    Left = 408
    Top = 400
  end
end

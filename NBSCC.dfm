object fmNBSCCForm: TfmNBSCCForm
  Left = 462
  Top = 191
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Credit Card Authorization'
  ClientHeight = 431
  ClientWidth = 704
  Color = clBackground
  DragMode = dmAutomatic
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
  OnHide = FormHide
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
    TabOrder = 2
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
    TabOrder = 6
  end
  object leApprovalCode: TPOSLabeledEdit
    Tag = 6
    Left = 130
    Top = 59
    Width = 121
    Height = 24
    TabStop = False
    EditLabel.Width = 94
    EditLabel.Height = 16
    EditLabel.Caption = 'Approval Code'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Approval Code'
    TabOrder = 7
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
  object leCardName: TPOSLabeledEdit
    Left = 270
    Top = 125
    Width = 160
    Height = 24
    TabStop = False
    EditLabel.Width = 71
    EditLabel.Height = 16
    EditLabel.Caption = 'Card Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 10
    ParentFont = False
    TabOrder = 0
  end
  object leExpDate: TPOSLabeledEdit
    Left = 130
    Top = 125
    Width = 49
    Height = 24
    EditLabel.Width = 62
    EditLabel.Height = 16
    EditLabel.Caption = 'Card Exp.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Expiration Date'
    TabOrder = 4
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leCardTypeName: TPOSLabeledEdit
    Left = 130
    Top = 191
    Width = 297
    Height = 24
    TabStop = False
    EditLabel.Width = 65
    EditLabel.Height = 16
    EditLabel.Caption = 'Card Type'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    TabOrder = 1
  end
  object leRestrictionCode: TPOSLabeledEdit
    Left = 390
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
    LabelSpacing = 276
    ParentFont = False
    StatusCaption = 'Enter Restriction Code'
    TabOrder = 8
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leVehicleNo: TPOSLabeledEdit
    Tag = 237
    Left = 130
    Top = 257
    Width = 121
    Height = 24
    EditLabel.Width = 69
    EditLabel.Height = 16
    EditLabel.Caption = 'Vehicle No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    PasswordChar = '*'
    StatusCaption = 'Enter Vehicle No'
    TabOrder = 9
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leDriverID: TPOSLabeledEdit
    Tag = 236
    Left = 130
    Top = 290
    Width = 121
    Height = 24
    EditLabel.Width = 55
    EditLabel.Height = 16
    EditLabel.Caption = 'Driver ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    PasswordChar = '*'
    StatusCaption = 'Enter Driver ID'
    TabOrder = 10
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leOdometer: TPOSLabeledEdit
    Tag = 239
    Left = 130
    Top = 323
    Width = 121
    Height = 24
    EditLabel.Width = 63
    EditLabel.Height = 16
    EditLabel.Caption = 'Odometer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Odometer'
    TabOrder = 11
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leRefNo: TPOSLabeledEdit
    Left = 130
    Top = 356
    Width = 121
    Height = 24
    EditLabel.Width = 86
    EditLabel.Height = 16
    EditLabel.Caption = 'Reference No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter Reference Number'
    TabOrder = 12
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leZipCode: TPOSLabeledEdit
    Tag = 249
    Left = 130
    Top = 158
    Width = 121
    Height = 24
    EditLabel.Width = 56
    EditLabel.Height = 16
    EditLabel.Caption = 'Zip Code'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    StatusCaption = 'Enter ZIP Code of CardHolder'
    TabOrder = 5
    OnEnter = tpleEnter
    OnExit = tpleExit
  end
  object leCardType: TPOSLabeledEdit
    Left = 400
    Top = 59
    Width = 30
    Height = 24
    EditLabel.Width = 65
    EditLabel.Height = 16
    EditLabel.Caption = 'Card Type'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelPosition = lpLeft
    ParentFont = False
    TabOrder = 13
    Visible = False
  end
  object leID: TPOSLabeledEdit
    Tag = 242
    Left = 152
    Top = 230
    Width = 121
    Height = 19
    EditLabel.Width = 13
    EditLabel.Height = 16
    EditLabel.Caption = 'ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    LabelSpacing = 16
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 14
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1024
    DesignScreenHeight = 786
    DesignPixelsPerInch = 96
    DesignFormWidth = 712
    DesignFormHeight = 465
    DesignFormClientWidth = 704
    DesignFormClientHeight = 431
    DesignFormLeft = 462
    DesignFormTop = 191
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

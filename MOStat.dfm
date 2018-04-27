object fmMO: TfmMO
  Left = 747
  Top = 257
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Money Order Print Status'
  ClientHeight = 221
  ClientWidth = 620
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lStatus: TPanel
    Left = 20
    Top = 8
    Width = 580
    Height = 41
    BevelInner = bvLowered
    BevelWidth = 2
    Color = clGreen
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'System'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object ProgBar: TProgressBar
    Left = 20
    Top = 72
    Width = 580
    Height = 17
    Max = 0
    Step = 1
    TabOrder = 1
  end
  object Memo: TMemo
    Left = 24
    Top = 112
    Width = 457
    Height = 89
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object ButtonOK: TButton
    Left = 512
    Top = 128
    Width = 75
    Height = 49
    Caption = 'Acknowledge problem'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 10
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    WordWrap = True
    OnClick = ButtonOKClick
  end
  object BlinkTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = OnBlinkTimer
    Left = 512
    Top = 96
  end
  object TimeOutTimer: TTimer
    Enabled = False
    OnTimer = OnTimeOutTimerElapsed
    Left = 552
    Top = 96
  end
  object PingTimeOut: TTimer
    Interval = 5000
    Left = 512
    Top = 184
  end
end

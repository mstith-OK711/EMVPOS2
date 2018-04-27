object fmPOS: TfmPOS
  Left = 72
  Top = 108
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Latitude'
  ClientHeight = 552
  ClientWidth = 776
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object lSuspend: TLabel
    Left = 4
    Top = 329
    Width = 133
    Height = 21
    AutoSize = False
    Caption = 'Suspended Sale'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object lReceipt1: TLabel
    Left = 34
    Top = 643
    Width = 183
    Height = 20
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object lReceipt2: TLabel
    Left = 268
    Top = 635
    Width = 189
    Height = 20
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object lbReturn: TLabel
    Left = 152
    Top = 328
    Width = 68
    Height = 19
    Caption = 'Mgr Void'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object KeyPanel: TBevel
    Left = 480
    Top = 256
    Width = 537
    Height = 433
  end
  object lTotal: TLabel
    Left = 105
    Top = 600
    Width = 160
    Height = 25
    AutoSize = False
    Caption = 'lTotal'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -19
    Font.Name = 'r_ansi'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
  end
  object TMGauge1: TGauge
    Left = 48
    Top = 600
    Width = 10
    Height = 30
    BackColor = clSilver
    Kind = gkVerticalBar
    ParentShowHint = False
    Progress = 0
    ShowHint = True
    ShowText = False
    Visible = False
  end
  object TMGauge2: TGauge
    Left = 58
    Top = 600
    Width = 10
    Height = 30
    BackColor = clSilver
    Kind = gkVerticalBar
    ParentShowHint = False
    Progress = 0
    ShowHint = True
    ShowText = False
    Visible = False
  end
  object TMGauge3: TGauge
    Left = 68
    Top = 600
    Width = 10
    Height = 30
    BackColor = clSilver
    Kind = gkVerticalBar
    ParentShowHint = False
    Progress = 0
    ShowHint = True
    ShowText = False
    Visible = False
  end
  object TMGauge4: TGauge
    Left = 78
    Top = 600
    Width = 10
    Height = 30
    BackColor = clSilver
    Kind = gkVerticalBar
    ParentShowHint = False
    Progress = 0
    ShowHint = True
    ShowText = False
    Visible = False
  end
  object TMGauge5: TGauge
    Left = 88
    Top = 600
    Width = 10
    Height = 30
    BackColor = clSilver
    Kind = gkVerticalBar
    ParentShowHint = False
    Progress = 0
    ShowHint = True
    ShowText = False
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 522
    Width = 776
    Height = 30
    Panels = <
      item
        Width = 125
      end
      item
        Width = 125
      end
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 150
      end
      item
        Width = 50
      end>
    SizeGrip = False
  end
  object DisplayEntry: TEdit
    Left = 280
    Top = 324
    Width = 193
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    MaxLength = 15
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = '123456789012345'
    OnKeyPress = DisplayEntryKeyPress
  end
  object DisplayQty: TEdit
    Left = 224
    Top = 324
    Width = 49
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    Text = '1'
    Visible = False
  end
  object eTotal: TEdit
    Left = 280
    Top = 600
    Width = 193
    Height = 30
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 3
    Text = 'eTotal'
  end
  object POSListBox: TPOSListBox
    Left = 8
    Top = 360
    Width = 465
    Height = 233
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'DejaVu Sans Mono'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    ItemHeight = 18
    Items.Strings = (
      '1234567890ABCDEFGHIJKLMNOP QRSTUVWXYZ')
    ParentFont = False
    Style = lbOwnerDrawFixed
    TabOrder = 4
  end
  object PumpPanel: TPanel
    Left = 24
    Top = 24
    Width = 185
    Height = 41
    TabOrder = 5
  end
  object Button1: TButton
    Left = 248
    Top = 256
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 6
    OnClick = Button1Click
  end
  object OPOSScanner: TOPOSScanner
    Left = 112
    Top = 208
    Width = 32
    Height = 32
    OnDataEvent = OPOSScannerDataEvent
    OnErrorEvent = OPOSScannerErrorEvent
    ControlData = {00030000D8130000D8130000}
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 376
    Top = 208
  end
  object Track2Timer: TTimer
    Enabled = False
    OnTimer = Track2TimerTimer
    Left = 300
    Top = 208
  end
  object FuelPriceTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = FuelPriceTimerTimer
    Left = 260
    Top = 212
  end
  object PopUpMsgTimer: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = PopUpMsgTimerTimer
    Left = 336
    Top = 208
  end
  object PopupMenu1: TPopupMenu
    Left = 24
    Top = 160
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
    object LoggingOn1: TMenuItem
      Caption = 'Logging is Off'
      OnClick = LoggingOn1Click
    end
    object SyncLogging1: TMenuItem
      Caption = 'Sync Logging is Off'
      OnClick = SyncLogging1Click
    end
    object PPLogging: TMenuItem
      Caption = 'PinPad Logging is Off'
      OnClick = PPLoggingClick
    end
    object menuShowCursor: TMenuItem
      Caption = 'Show Cursor'
      OnClick = menuShowCursorClick
    end
    object menuFuelMsgLogging: TMenuItem
      Caption = 'Fuel Msg Logging Off'
      OnClick = menuFuelMsgLoggingClick
    end
  end
  object IBConfigService1: TIBConfigService
    Protocol = TCP
    TraceFlags = []
    Left = 216
    Top = 152
  end
  object IBBackupService1: TIBBackupService
    Protocol = TCP
    TraceFlags = []
    BlockingFactor = 0
    Options = []
    Left = 264
    Top = 152
  end
  object IBRestoreService1: TIBRestoreService
    Protocol = TCP
    TraceFlags = []
    PageSize = 0
    PageBuffers = 0
    Left = 320
    Top = 152
  end
  object ReceiptEvents: TReceiptSrvrITReceiptEvents
    GotPrinterError = ReceiptEventsGotPrinterError
    Left = 400
    Top = 152
  end
  object CarwashEvents: TCarwashICarwashOLEEvents
    GotMsg = CarwashEventsGotMsg
    Left = 440
    Top = 152
  end
  object FPCPostTimer: TTimer
    Enabled = False
    Interval = 600000
    OnTimer = FPCPostTimerTimer
    Left = 416
    Top = 208
  end
  object PumpPopupMenu: TPopupMenu
    AutoPopup = False
    Left = 104
    Top = 160
    object UnlockPump: TMenuItem
      Tag = 1
      Caption = 'Unlock Pump'
      OnClick = PumpMenuItemClick
    end
    object PowerPump: TMenuItem
      Tag = 2
      Caption = 'Power Pump'
      Enabled = False
      GroupIndex = 1
      RadioItem = True
      OnClick = PumpMenuItemClick
    end
    object DepowerPump: TMenuItem
      Tag = 3
      Caption = 'Depower Pump'
      Enabled = False
      GroupIndex = 1
      RadioItem = True
      OnClick = PumpMenuItemClick
    end
  end
  object SysMgrPopup: TPopupMenu
    Left = 144
    Top = 160
    object Show1: TMenuItem
      Caption = '&POS Back-Office'
      OnClick = SysMgr1Click
    end
  end
end

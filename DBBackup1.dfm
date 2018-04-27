object Form1: TForm1
  Left = 428
  Top = 188
  Width = 310
  Height = 142
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IBBackupService1: TIBBackupService
    Protocol = TCP
    TraceFlags = []
    BlockingFactor = 0
    Options = []
    Left = 88
    Top = 80
  end
  object DB: TIBDatabase
    Params.Strings = (
      'user_name=rsgretail'
      'password=pos')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 1
    TraceFlags = []
    Left = 32
    Top = 8
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = DB
    AutoStopAction = saNone
    Left = 80
    Top = 8
  end
  object TempQuery: TIBQuery
    Database = DB
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    Left = 128
    Top = 8
  end
end

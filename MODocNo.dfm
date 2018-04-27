object MoDocEntry: TMoDocEntry
  Left = 850
  Top = 490
  Width = 625
  Height = 233
  Caption = 'Money Order Document Number Entry'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 32
    Top = 112
    Width = 122
    Height = 16
    Caption = 'Document Number:'
  end
  object DocNo: TLabel
    Left = 184
    Top = 112
    Width = 4
    Height = 16
  end
  object lStatus: TPanel
    Left = 8
    Top = 16
    Width = 580
    Height = 41
    BevelInner = bvLowered
    BevelWidth = 3
    Caption = 'lStatus'
    Color = clRed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 432
    Top = 104
    Width = 75
    Height = 41
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
end

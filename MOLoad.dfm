object fmMOLoad: TfmMOLoad
  Left = 898
  Top = 336
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Money Order Load'
  ClientHeight = 199
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 88
    Width = 176
    Height = 16
    Caption = 'Starting Document Number:'
  end
  object Label2: TLabel
    Left = 16
    Top = 136
    Width = 170
    Height = 16
    Caption = 'Ending Document Number:'
  end
  object docnostart: TLabel
    Left = 200
    Top = 88
    Width = 4
    Height = 16
  end
  object docnoend: TLabel
    Left = 200
    Top = 136
    Width = 4
    Height = 16
  end
  object lStatus: TPanel
    Left = 8
    Top = 16
    Width = 577
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
  object btnLoad: TButton
    Left = 432
    Top = 72
    Width = 75
    Height = 41
    Caption = 'Load'
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object btnCancel: TButton
    Left = 432
    Top = 136
    Width = 75
    Height = 41
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
end

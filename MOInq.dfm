object fmMOInq: TfmMOInq
  Left = 659
  Top = 323
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Money Order Inquiry'
  ClientHeight = 199
  ClientWidth = 600
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
    Top = 136
    Width = 75
    Height = 41
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object DocNo: TEdit
    Left = 184
    Top = 104
    Width = 121
    Height = 24
    TabOrder = 1
    OnChange = DocNoChange
  end
  object btnFind: TButton
    Left = 432
    Top = 72
    Width = 75
    Height = 41
    Caption = 'Find'
    TabOrder = 3
    Visible = False
    OnClick = btnFindClick
  end
end

object fmPOSErrorMsg: TfmPOSErrorMsg
  Left = 120
  Top = 172
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'POS Error!'
  ClientHeight = 199
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Supplement: TPanel
    Left = 8
    Top = 64
    Width = 577
    Height = 41
    BevelOuter = bvNone
    TabOrder = 5
  end
  object lErrMsg: TPanel
    Left = 8
    Top = 16
    Width = 577
    Height = 41
    BevelInner = bvLowered
    BevelWidth = 3
    Caption = 'lErrMsg'
    Color = clRed
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnDblClick = lErrMsgDblClick
  end
  object lblContinue: TPanel
    Left = 176
    Top = 72
    Width = 249
    Height = 41
    BevelWidth = 2
    Caption = 'Touch HERE to Continue'
    TabOrder = 1
    OnClick = lblContinueClick
  end
  object lblCapture: TPanel
    Left = 176
    Top = 184
    Width = 249
    Height = 41
    BevelWidth = 2
    Caption = 'Touch HERE to Capture PLU'
    TabOrder = 2
    OnClick = lblCaptureClick
  end
  object lblNo: TPanel
    Left = 8
    Top = 128
    Width = 153
    Height = 41
    BevelWidth = 2
    Caption = 'No'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    Visible = False
    OnClick = lblNoClick
  end
  object lblYes: TPanel
    Left = 432
    Top = 128
    Width = 153
    Height = 41
    BevelWidth = 2
    Caption = 'Yes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    Visible = False
    OnClick = lblYesClick
  end
end

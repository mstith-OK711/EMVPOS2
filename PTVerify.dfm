object frmPTVerify: TfrmPTVerify
  Left = 649
  Top = 192
  Width = 588
  Height = 183
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Partial Tender Verification'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object Label1: TLabel
    Left = 0
    Top = 16
    Width = 580
    Height = 20
    Alignment = taCenter
    Caption = 'This card has only partially tendered the requested total.'
  end
  object Notice: TLabel
    Left = 0
    Top = 48
    Width = 580
    Height = 20
    Alignment = taCenter
    Caption = '%s of %s will be applied to the sale.'
    Layout = tlCenter
  end
  object btnAccept: TButton
    Left = 24
    Top = 84
    Width = 75
    Height = 49
    Caption = 'Accept'
    ModalResult = 1
    TabOrder = 0
    OnClick = btnAcceptClick
  end
  object btnReject: TButton
    Left = 480
    Top = 84
    Width = 75
    Height = 49
    Caption = 'Reject'
    ModalResult = 2
    TabOrder = 1
    OnClick = btnRejectClick
  end
end

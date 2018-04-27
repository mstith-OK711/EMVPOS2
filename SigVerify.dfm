object frmSigVerify: TfrmSigVerify
  Left = 649
  Top = 192
  Width = 588
  Height = 300
  Caption = 'Signature Verification'
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
  object SigImg: TImage
    Left = 2
    Top = 8
    Width = 576
    Height = 200
  end
  object btnAccept: TButton
    Left = 24
    Top = 212
    Width = 75
    Height = 49
    Caption = 'Accept'
    ModalResult = 1
    TabOrder = 0
  end
  object btnReject: TButton
    Left = 480
    Top = 212
    Width = 75
    Height = 49
    Caption = 'Reject'
    ModalResult = 2
    TabOrder = 1
  end
end

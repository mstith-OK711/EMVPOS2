object fmGiftRestrict: TfmGiftRestrict
  Left = 332
  Top = 174
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Gift Card Restrictions'
  ClientHeight = 473
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 292
    Height = 16
    Caption = 'Select restrictions for gift card to be activated:'
  end
  object Button1: TButton
    Left = 8
    Top = 64
    Width = 505
    Height = 49
    Caption = 'No Restrictions - All Products Can Be Purchased'
    TabOrder = 0
    OnClick = OnGiftCardRestrict1Click
  end
  object Button2: TButton
    Left = 8
    Top = 160
    Width = 505
    Height = 49
    Caption = 'No Alcohol, Tobacco, or Lottery Products Can Be Purchased'
    TabOrder = 1
    OnClick = OnGiftCardRestrict2Click
  end
  object Button3: TButton
    Left = 8
    Top = 256
    Width = 505
    Height = 49
    Caption = 'Only Fuel Can Be Purchased'
    TabOrder = 2
    OnClick = OnGiftCardRestrict3Click
  end
  object Button4: TButton
    Left = 16
    Top = 400
    Width = 497
    Height = 49
    Caption = 'Recharge - Use Existing Restrictions'
    TabOrder = 3
    OnClick = OnGiftCardRestrict4Click
  end
  object ElasticForm1: TElasticForm
    DesignScreenWidth = 1032
    DesignScreenHeight = 748
    DesignPixelsPerInch = 96
    DesignFormWidth = 534
    DesignFormHeight = 507
    DesignFormClientWidth = 526
    DesignFormClientHeight = 473
    DesignFormLeft = 332
    DesignFormTop = 174
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Version = 700.000000000000000000
    Left = 488
    Top = 8
  end
end

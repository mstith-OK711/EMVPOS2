object ScaleWeightFrm: TScaleWeightFrm
  Left = 972
  Top = 194
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Scale Weight'
  ClientHeight = 356
  ClientWidth = 537
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    537
    356)
  PixelsPerInch = 96
  TextHeight = 13
  object Display: TPLSLED7SegDisplay
    Left = 16
    Top = 16
    Width = 505
    Height = 177
    BrightColor = clRed
    DimColor = 48
    BackColor = clBlack
    Digits = 4
    DecimalPlaces = 1
    Spacing = 4
    Gap = 2
    SegWidth = 10
    SegShape = ssDoubleEdge
    Anchors = [akLeft, akTop, akRight]
  end
  object btnAccept: TButton
    Left = 40
    Top = 248
    Width = 145
    Height = 89
    Caption = 'Accept'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
  end
  object btnReject: TButton
    Left = 344
    Top = 248
    Width = 153
    Height = 89
    Caption = 'Reject'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 2
  end
  object btnManual: TButton
    Left = 208
    Top = 272
    Width = 113
    Height = 65
    Caption = 'Manual Override'
    TabOrder = 3
    Visible = False
    OnClick = btnManualClick
  end
end

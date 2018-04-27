unit ScaleWeight;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PLSLED7Seg, POSBtn, ExtCtrls, Buttons, StdCtrls;

const
  KEYCOUNT = 12;

type
  TScaleWeightFrm = class(TForm)
    Display: TPLSLED7SegDisplay;
    btnAccept: TButton;
    btnReject: TButton;
    btnManual: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnManualClick(Sender: TObject);
  private
    { Private declarations }
    FDefHeight : integer;
    FPOSButtons : array[0..KEYCOUNT-1] of TPOSTouchButton;
    procedure FormCenter();
    procedure POSButtonClick(Sender: TObject);
    procedure BuildKeypad( kpTop: integer ; rows, columns : byte ; keytops : array of string ; OnPress : TNotifyEvent );
  public
    { Public declarations }
    procedure SetValue(const Value: currency);
  end;

var
  ScaleWeightFrm: TScaleWeightFrm;

implementation

{$R *.dfm}

uses
  ExceptLog;

var
  Keytops  : array[1..11] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0');

procedure TScaleWeightFrm.SetValue(const Value: currency);
begin
  Display.Enabled := (Value <> 9999);
  if Display.Enabled then
    Display.Value := Value
  else
    if not btnManual.Visible then
      btnManual.Visible := True;
end;

procedure TScaleWeightFrm.FormShow(Sender: TObject);
var
  AX, RX, i : integer;
begin
  Height := FDefHeight;
  FormCenter;
  for i := 0 to pred(KEYCOUNT) do
    if assigned(FPosButtons[i]) then
      FPosButtons[i].Visible := False;

  btnManual.Visible := False;
  Display.Value := 0;

  AX := btnAccept.Left;
  RX := btnReject.Left;
  btnAccept.Left := RX;
  btnReject.Left := AX;
end;

procedure TScaleWeightFrm.FormCreate(Sender: TObject);
begin
  FDefHeight := Height;
  FormCenter;
end;

procedure TScaleWeightFrm.FormCenter;
begin
  Left := (screen.Width - Width) div 2;
  Top := (screen.Height - Height) div 2;
end;

procedure TScaleWeightFrm.BuildKeypad(kpTop: integer; rows, columns: byte;
  keytops: array of string; OnPress : TNotifyEvent);
var
  r, c : byte;
  glyphs : TBitMap;
  gh, gs, keyidx, leftside : integer;
  kc, keycap : string;
begin
  glyphs := TBitMap.Create;
  glyphs.LoadFromResourceName(HInstance, 'SMALLBTN');
  gh := glyphs.Height;
  gs := (gh * 110) div 100;
  leftside := (Self.Width - (gs * columns)) div 2;
  for r := 0 to pred(rows) do
    for c := 0 to pred(columns) do
    begin
      keyidx := (r * columns) + c;
      if keyidx <= pred(length(keytops)) then
      begin
        kc := format('%d%d', [r, c]);
        FPOSButtons[keyidx] := TPOSTouchButton.Create(Self);
        with FPOSButtons[keyidx] do
        begin
          Parent      := Self;
          Name        := 'ScaleWeight' + kc;
          Top         := kpTop + (r * gs);
          Left        := leftside + (c * gs);
          KeyRow      := r;
          KeyCol      := c;
          Height      := gh;
          Width       := gh;
          Visible     := True;
          OnClick     := OnPress;
          KeyCode     := kc;
          FrameStyle  := bfsNone;
          WordWrap    := True;
          Tag         := keyidx;
          Glyph       := glyphs;
          NumGlyphs   := 14;
          ShowHint := False;

          Font.Name := 'System';
          Font.Color := clBlack;
          Font.Size := 12;
        end;

        keycap := keytops[keyidx];
        try
          StrToInt(keycap);
          with FPOSButtons[keyidx] do
          begin
            KeyType := 'NUM';
            KeyVal  := KeyTops[keyidx];
            Caption := keycap;
            Frame := 4;
          end;
        except
          if keycap = 'CLR' then
            with FPOSButtons[keyidx] do
            begin
              KeyType := 'CLR - Clear';
              Caption := 'Clear';
              Frame := 14;
            end;
        end;
        FPosButtons[keyidx].MaskColor := Self.Color;
      end;
    end;
end;

procedure TScaleWeightFrm.POSButtonClick(Sender: TObject);
var
  sKeyType, sKeyVal, sPreset : string;
begin
  if (Sender is TPOSTouchButton) then
  begin
    with TPOSTouchButton(Sender) do
    begin
      sKeyType := KeyType;
      sKeyVal  := KeyVal;
      sPreset  := KeyPreset;
    end;
    if sKeyType = 'CLR - Clear' then
    begin
      if Display.Value = 0 then
        Self.ModalResult := mrCancel;
      Display.Value := 0;
    end
    else if sKeyType = 'NUM' then
      Display.Value := Display.Value * 10 + (0.1 * StrToInt(sKeyVal));
  end;
end;

procedure TScaleWeightFrm.btnManualClick(Sender: TObject);
var
  i, bottom : integer;
begin
  if not assigned(FPOSButtons[0]) then
    BuildKeypad( btnManual.Top + btnManual.Height + 30, 4, 3, KeyTops, Self.POSButtonClick)
  else
    for i := 0 to pred(KEYCOUNT) do
      if assigned(FPosButtons[i]) then
        FPosButtons[i].Visible := True;

  i := pred(length(keytops));
  bottom := FPosButtons[i].Top + FPosButtons[i].Height;
  Self.Height := bottom + 30;
  FormCenter;
end;

end.

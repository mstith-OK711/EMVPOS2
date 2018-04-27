unit AnimBt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls,Buttons, Dialogs;

type

  TMySpeedButton = class(TSpeedButton)
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    destructor Destroy; override;
  end;

  TAnimate = class(TCustomControl)
  private
    First  : Boolean;
    FButton : TMySpeedButton;
    FBitMap : TBitmap;
    FButtonGlyph : TBitmap;
    FFrameCount : integer;
    FFrame : Integer;
    FStartFrame : Integer;
    FEndFrame : Integer;
    Timer : TTimer;
    FInterval : integer;
    FLoop : boolean;
    FReverse : boolean;
    FPlay : boolean;
    FSound : integer;
    { Picture frame }
    FFramewidth    : Integer;
    FFrameheight   : Integer;
    FFrametop      : Integer;
    FFrameleft     : Integer;
    { Button : }
    FButtonLeft    : Integer;
    FButtonTop     : Integer;
    FButtonWidth   : Integer;
    FButtonHeight  : Integer;
    FButtonCaption : ShortString;
    { Label : }
    FLabelLeft     : Integer;
    FLabelTop      : Integer;
    FLabelWidth    : Integer;
    FLabelHeight   : Integer;
    FLabelCaption  : ShortString;
    FLabel         : TLabel;
    FLabelFont     : TFont;
    FButtonFont    : TFont;
    FTransparentColor : TColor;
    FOnChangeFrame : TNotifyEvent;
    FOnButtonClick : TNotifyEvent;
    FSaleid        : Integer;
    procedure SetFrame(Value : Integer);
    procedure SetInterval(Value : integer);
    procedure SetBitMap(Value : TBitMap);

    { Button }
    procedure SetButtonGlyph(Value : TBitMap);
    procedure SetButtonLeft(Value : integer);
    procedure SetButtonTop(Value : integer);
    procedure SetButtonWidth(Value : integer);
    procedure SetButtonHeight(Value : integer);
    procedure SetButtonCaption(Value : shortstring);
    procedure SetButtonFont(Value : TFont);

    { Picture frame }
    procedure SetFrameWidth(Value : Integer);
    function  GetFrameWidth : Integer;
    procedure SetFrameHeight(Value : Integer);
    function  GetFrameHeight : Integer;
    procedure SetFrameTop(Value : Integer);
    function  GetFrameTop : Integer;
    procedure SetFrameLeft(Value : Integer);
    function  GetFrameLeft : Integer;


    function  GetButtonLeft : Integer;
    function  GetButtonTop : Integer;
    function  GetButtonWidth  : Integer;
    function  GetButtonHeight : Integer;
    function  GetButtonCaption : ShortString;
    function  GetButtonGlyph : TBitmap;
    function  GetButtonFont   : TFont;

    { Label: }

    procedure SetLabelLeft(Value : integer);
    procedure SetLabelTop(Value : integer);
    procedure SetLabelWidth(Value : integer);
    procedure SetLabelHeight(Value : integer);
    procedure SetLabelCaption(Value : shortstring);
    procedure SetLabelFont(Value : TFont);

    function  GetLabelLeft : Integer;
    function  GetLabelTop : Integer;
    function  GetLabelWidth  : Integer;
    function  GetLabelHeight : Integer;
    function  GetLabelCaption : ShortString;
    function  GetLabelFont   : TFont;
    procedure SetPlay(Onn : boolean);
    function  CreateMyButton : TMySpeedButton;

    function  GetSaleid : Integer;
    procedure SetSaleid(Value : Integer);
  protected
    procedure Refresh;
    procedure Paint; override;
    procedure TimeHit(Sender : TObject);
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;
  published
    property Interval : integer read FInterval write SetInterval;
    {Note: FrameCount must precede Frame in order for initialization to be correct}
    property FrameCount : integer read FFrameCount write FFrameCount default 1;
    property Frame : Integer read FFrame write SetFrame;
    property StartFrame : Integer read FStartFrame write FStartFrame;
    property EndFrame : Integer read FEndFrame write FEndFrame;
    property BitMap : TBitMap read FBitMap write SetBitMap;
    property Play : boolean read FPlay write SetPlay;
    property Sound : integer read FSound write FSound;
    property Reverse: boolean read FReverse write FReverse;
    property Loop: boolean read FLoop write FLoop default True;
    property Height default 90;
    property Width default 90;
    property SaleID     : Integer read GetSaleId write SetSaleID default 0;
    property Framewidth : Integer read GetFramewidth write SetFramewidth default 20;
    property Frameheight: Integer read GetFrameheight write SetFrameheight default 50;
    property Frametop   : Integer read GetFrametop   write SetFrametop;
    property Frameleft  : Integer read GetFrameleft  write SetFrameleft;
    property OnChangeFrame: TNotifyEvent read FOnChangeFrame
                            write FOnChangeFrame;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property Font;
    property LabelFont    : TFont read GetLabelFont write SetLabelFont;
    property ButtonFont   : TFont read GetButtonFont write SetButtonFont;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property Visible;
    { Button : }
    property ButtonLeft    : Integer read GetButtonLeft  write SetButtonLeft default 1;
    property ButtonTop     : Integer read GetButtonTop   write SetButtonTop default 1;
    property ButtonWidth   : Integer read GetButtonWidth write SetButtonWidth default 70;
    property ButtonHeight  : Integer read GetButtonHeight write SetButtonHeight default 30;
    property ButtonCaption : ShortString  read GetButtonCaption write SetButtonCaption ;
    property ButtonGlyph   : TBitMap read GetButtonGlyph write SetButtonGlyph;
    { Label : }
    property LabelLeft    : Integer read GetLabelLeft  write SetLabelLeft default 10;
    property LabelTop     : Integer read GetLabelTop   write SetLabelTop default 10;
    property LabelWidth   : Integer read GetLabelWidth write SetLabelWidth default 50;
    property LabelHeight  : Integer read GetLabelHeight write SetLabelHeight default 20;
    property LabelCaption : ShortString  read GetLabelCaption write SetLabelCaption ;
  end;

procedure Register;

implementation

function TAnimate.GetSaleid : integer;
begin  Result := FSaleid; End;

procedure TAnimate.SetSaleid(Value : Integer);
begin  FSaleid := Value;  End;

{ Picture frame: }

function TAnimate.GetFrameWidth : integer;
begin  Result := FFramewidth; End;

procedure TAnimate.SetFrameWidth(Value : Integer);
begin  FFrameWidth := Value; Refresh; End;

function TAnimate.GetFrameHeight : integer;
begin  Result := FFrameHeight; End;

procedure TAnimate.SetFrameHeight(Value : Integer);
begin  FFrameHeight := Value; Refresh; End;

function TAnimate.GetFrameTop : integer;
begin  Result := FFrameTop; End;

procedure TAnimate.SetFrameTop(Value : Integer);
begin  FFrameTop := Value; Refresh; End;

function TAnimate.GetFrameLeft : integer;
begin  Result := FFrameleft; End;

procedure TAnimate.SetFrameLeft(Value : Integer);
begin  FFrameLeft := Value; Refresh; End;

{ Button : }

procedure TAnimate.SetButtonLeft (Value : Integer);
begin  FButton.Left := Value; Refresh; End;

procedure TAnimate.SetButtonTop (Value : Integer);
begin  FButton.Top := Value; Refresh; End;

procedure TAnimate.SetButtonWidth (Value : Integer);
begin  FButton.Width := Value; Refresh; End;

procedure TAnimate.SetButtonHeight (Value : Integer);
begin FButton.Height := Value; Refresh; End;

procedure TAnimate.SetButtonCaption (Value : ShortString);
begin  FButton.Caption := Value; Refresh; End;

function TAnimate.GetButtonLeft : Integer;
begin  Result := FButton.Left; End;

function  TAnimate.GetButtonTop : Integer;
begin  Result := FButton.Top; End;

function  TAnimate.GetButtonWidth  : Integer;
begin  Result := FButton.Width;  End;

function  TAnimate.GetButtonHeight : Integer;
begin  Result :=  FButton.Height; End;

function  TAnimate.GetButtonCaption : ShortString;
begin  Result := FButton.Caption; End;

procedure TAnimate.SetButtonFont (Value : TFont);
begin  FButton.Font := Value; Refresh; End;

function  TAnimate.GetButtonFont : TFont;
begin  Result := FButton.Font; End;

{ Label : }

procedure TAnimate.SetLabelLeft (Value : Integer);
begin  FLabel.Left := Value; Refresh; End;

procedure TAnimate.SetLabelTop (Value : Integer);
begin  FLabel.Top := Value; Refresh; End;

procedure TAnimate.SetLabelWidth (Value : Integer);
begin  FLabel.Width := Value; Refresh; End;

procedure TAnimate.SetLabelHeight (Value : Integer);
begin FLabel.Height := Value; Refresh; End;

procedure TAnimate.SetLabelCaption (Value : ShortString);
begin  FLabel.Caption := Value; Refresh; End;

procedure TAnimate.SetLabelFont (Value : TFont);
begin  FLabel.Font := Value; Refresh; End;

function TAnimate.GetLabelLeft : Integer;
begin  Result := FLabel.Left; End;

function  TAnimate.GetLabelTop : Integer;
begin  Result := FLabel.Top; End;

function  TAnimate.GetLabelWidth  : Integer;
begin  Result := FLabel.Width;  End;

function  TAnimate.GetLabelHeight : Integer;
begin  Result :=  FLabel.Height; End;

function  TAnimate.GetLabelCaption : ShortString;
begin  Result := FLabel.Caption; End;

function  TAnimate.GetLabelFont : TFont;
begin  Result := FLabel.Font; End;

{------------------------------------------------------------------------------}
function TAnimate.CreateMyButton : TMySpeedButton;
begin
  Result := TMySpeedButton.Create (Self);
  Result.Visible := True;
  Result.Enabled := True;
  Result.NumGlyphs := 1;
  Result.Caption := FButtonCaption;
  Result.Left    := FButtonLeft;
  Result.Top     := FButtonTop;
  Result.Height  := FButtonHeight;
  Result.Width   := FButtonWidth;
  Result.Parent  := Self;
end;

constructor TAnimate.Create(AOwner: TComponent);
begin
inherited Create(AOwner);
{ Width := 30;
 Height := 30; }
 FBitMap := TBitMap.Create;
 FrameCount := 1;
 ControlStyle := ControlStyle +[csOpaque];
 FLoop := True;
 FSound := 0;
 FTransparentColor := -1;
 { We create the button }
 FButtonLeft    := 1;
 FButtonTop     := 1;
 FButtonWidth   := 70;
 FButtonHeight  := 30;
 FButtonCaption := '$ 0.00';
 FFramewidth    := 25;
 FButton        := CreateMyButton;
 { We create the label }
 FLabelCaption  := 'Pump1';
 Flabel         := TLabel.Create(Self);
 FLabel.Visible := True;
 FLabel.Enabled := True;
 FLabel.Left    := 10;
 FLabel.Top     := 80;
 FLabel.Caption := 'Pump1';
 FLabel.Width   := 70;
 FLabel.Height  := 30;
 FLabel.Parent  := Self;
 FLabel.Font    := LabelFont;

 First := True;
end;

destructor TAnimate.Destroy;
begin
Timer.Free;
FBitMap.Free;
inherited Destroy;
end;

procedure TAnimate.SetButtonGlyph(Value : TBitMap);
begin
FButton.Glyph.Assign(Value);
end;

function TAnimate.GetButtonGlyph : TBitmap;
Begin
 GetButtonGlyph := FButton.Glyph;
end;

procedure TAnimate.SetBitMap(Value : TBitMap);
begin
FBitMap.Assign(Value);
(* Height := FBitMap.Height;
   if Height = 0 then Height := 30;  {so something will display}
*)
end;

procedure TAnimate.SetInterval(Value : Integer);
begin
if Value <> FInterval then
  begin
  Timer.Free;
  Timer := Nil;
  if FPlay and (Value > 0) then
    begin
    Timer := TTimer.Create(Self);
    Timer.Interval := Value;
    Timer.OnTimer := TimeHit;
    end;
  FInterval := Value;
  end;
end;


procedure TAnimate.SetPlay(Onn : boolean);
begin
if Onn <> FPlay then
  begin
  FPlay := Onn;
  if not Onn then
    begin
    Timer.Free;
    Timer := Nil;
    end
  else if FInterval > 0 then
    begin
    if FStartFrame > 0 then
      SetFrame(FStartFrame - 1);

    Timer := TTimer.Create(Self);
    Timer.Interval := FInterval;
    Timer.OnTimer := TimeHit;
    end;
  end;
end;

procedure TAnimate.SetFrame(Value : Integer);
var
  Temp : Integer;
begin
if Value < 0 then
  Temp := FFrameCount - 1
else
  begin
    if (FPlay = True) and (FEndFrame > 0) then
      Temp := Value Mod FEndFrame
    else
      Temp := Value Mod FFrameCount;
  end;
if Temp <> FFrame then
  begin
    if FPlay = True then
      begin
        if Temp < (FStartFrame - 1) then
          FFrame := (FStartFrame - 1)
        else
          FFrame := Temp;
      end
    else
      FFrame := Temp;

    if Assigned(FOnChangeFrame) then FOnChangeFrame(Self);
    Invalidate;
  end;
end;

procedure TAnimate.TimeHit(Sender : TObject);
  procedure ChkStop;
  begin
  if not FLoop then
    begin
    FPlay := False;
    Timer.Free;
    Timer := Nil;
    end;
  end;

begin
if FReverse then
  begin
    Frame := Frame-1;
    if FStartFrame > 0 then
      begin
        if FFrame = (FStartFrame - 1) then ChkStop;
      end
    else
      begin
        if FFrame = 0 then ChkStop;
      end;
  end
else
  begin
    Frame := Frame+1;
    if FEndFrame > 0 then
      begin
        if FFrame = FEndFrame-1 then ChkStop;
      end
    else
      begin
        if FFrame = FrameCount-1 then ChkStop;
      end;

  end;
end;

procedure TAnimate.Refresh;
Begin
 { First we delete the old canvas, and repaint the whole thing... }
 if csDesigning in ComponentState then
  Begin
   Canvas.Brush.Color := clSilver;
   Canvas.FillRect(Rect(0, 0, 1500, 1000));
   Canvas.Refresh;
   Paint;
  End;
End;

procedure TAnimate.Paint;
var
  ARect, BRect : TRect;
  X : Integer;
begin
{ We draw a frame around the whole thing }
Canvas.Brush.Color := clBlack;
ARect.Top := 0; ARect.Left := 0;
ARect.Right := Width - 0; ARect.Bottom := Height - 0;
Canvas.FrameRect (ARect);
Canvas.Pen.Color := clWhite;
Canvas.Moveto (1,Height - 2);
Canvas.Lineto (1,1);
Canvas.Lineto (Width - 2,1);
Canvas.Pen.Color := clGray;
Canvas.Lineto (Width - 2,Height - 2);
Canvas.Lineto (1,Height - 2);

ARect := Rect(FFrameLeft,FFrameTop,FFramewidth + FFrameLeft,FFrameheight + FFrameTop);
if FBitMap.Height > 0 then
  begin
  X := FFramewidth*FFrame;
  BRect := Rect(X ,0, X + FFrameWidth , FFrameheight);
  Canvas.CopyRect(ARect, FBitmap.Canvas, BRect);
  end
else
  begin   {fill with something}
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(BoundsRect);
  end;
if csDesigning in ComponentState then
  begin    {to add visibility when designing}
   FButton.Paint;
   FLabel.Repaint;
  end;

 if First and Assigned(FOnButtonClick) then
  Begin
    First := False;
    FButton.OnClick := FOnButtonClick;
    FButton.Glyph  := FButtonGlyph;
  End;
end;
{------------------------------------------------TTimerSpeedButton }

destructor TMySpeedButton.Destroy;
begin
  inherited Destroy;
end;

procedure TMySpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown (Button, Shift, X, Y);
end;

procedure TMySpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
begin
  inherited MouseUp (Button, Shift, X, Y);
end;


procedure TMySpeedButton.Paint;
begin
  inherited Paint;
end;

procedure Register;
begin
  RegisterComponents('Animation', [TAnimate]);
end;

end.

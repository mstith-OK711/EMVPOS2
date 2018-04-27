unit indicator;

interface

uses Classes, Controls, Graphics;

type
  TIndStatus = (tisNotOK, tisWarn, tisOK);
  TIndicator = class(TCustomControl)
  private
    FStatus : TIndStatus;
    FImgs : array[tisNotOK..tisOK] of TBitmap;
    procedure SetStatus(const Value: TIndStatus);
    function GetBm: Graphics.TBitmap;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Status : TIndStatus write SetStatus;
    property Bm : TBitmap read GetBm;
  published
    property Top;
    property Left;
    property Height default 32;
    property Width default 32;
    property Visible;
  end;


implementation

uses
  Math,
  Windows;

{ TPPStatus }

{$R 'indicators.res'}

constructor TIndicator.Create(AOwner: TComponent);
var
  x : TIndStatus;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle +[csOpaque];

  for x := low(TIndStatus) to high(TIndStatus) do 
    FImgs[x] := Graphics.TBitmap.Create;

  FImgs[tisNotOK].LoadFromResourceName(HInstance, 'NOTOK');
  FImgs[tisWarn].LoadFromResourceName(HInstance, 'WARN');
  FImgs[tisOK].LoadFromResourceName(HInstance, 'OK');

  for x := low(TIndStatus) to high(TIndStatus) do
  begin 
    FImgs[x].Transparent := True;
    FImgs[x].TransparentMode := tmFixed;
    FImgs[x].TransparentColor := FImgs[x].Canvas.Pixels[0,0];
  end;

  Height := 32;
  Width :=  32;

  FStatus := tisNotOK;
end;

destructor TIndicator.Destroy;
var
  x : TIndStatus;
begin
  for x := low(TIndStatus) to high(TIndStatus) do 
    FImgs[x].Destroy;
  inherited;
end;

function TIndicator.GetBm: Graphics.TBitmap;
begin
  GetBm := FImgs[Fstatus];
end;

procedure TIndicator.Paint;
begin
  Inherited Canvas.Draw(0, 0, FImgs[FStatus]);  //paint coordinates relative to Control's Canvas
end;

procedure TIndicator.SetStatus(const Value: TIndStatus);
begin
  if Value <> FStatus then
  begin
    FStatus := Value;
    Paint;
  end;
end;

end.

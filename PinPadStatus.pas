unit PinPadStatus;

interface

uses Classes, Controls, Graphics;

type
  TPPStatus = class(TCustomControl)
  private
    FOnline : boolean;
    FImgs : array[False..True] of TBitmap;
    procedure SetOnline(const Value: boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Online : boolean write SetOnline;
  published
    property Top;
    property Left;
    property Height default 30;
    property Width default 30;
    property Visible;
  end;


implementation

uses
  Math,
  Windows;

{ TPPStatus }

{$R 'pinpad.res'}

constructor TPPStatus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle +[csOpaque];

  FImgs[False] := Graphics.TBitmap.Create;
  FImgs[True] := Graphics.TBitmap.Create;

  FImgs[False].LoadFromResourceName(HInstance, 'PPOFFLINE');
  FImgs[True].LoadFromResourceName(HInstance, 'PPONLINE');

  Height := max(FImgs[False].Height, FImgs[True].Height);
  Width :=  max(FImgs[False].Width,  FImgs[True].Width);

  FOnline := False;
end;

destructor TPPStatus.Destroy;
begin
  FImgs[False].Destroy;
  FImgs[True].Destroy;
  inherited;
end;

procedure TPPStatus.Paint;
begin
  Inherited Canvas.Draw(0, 0, FImgs[FOnline]);  //paint coordinates relative to Control's Canvas
end;

procedure TPPStatus.SetOnline(const Value: boolean);
begin
  if Value <> FOnline then
  begin
    FOnline := Value;
    Paint;
  end;
end;

end.

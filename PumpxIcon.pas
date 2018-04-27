unit PumpxIcon;
//20080102a...
// This unit from c:\Laitude\POSTools\PumpIcon except
// TPumpIcon changed to TPumpxIcon, TPumpHint to TPumpxHint and TBaloonWindow to TBaloonxWindow
//...20080102a
interface

uses
  WinTypes, 
  Messages, 
  Classes, 
  Graphics, 
  Controls,
  PumpLockSup,
  ExtCtrls;


const
  {$I ConditionalCompileSymbols.txt}
  {$I PumpStateTags.INC}
  {$IFNDEF PUMP_ICON_EXT}  // FR_* constant definitions moved to PumpStateTags.inc - 20080104
  FR_IDLENOCAT  = 0;
  FR_UPSTART    = 1;
  FR_UPEND      = 6;
  FR_FLOWSTART  = 7;
  FR_FLOWEND    = 8;
  FR_PAY        = 9 ;
  FR_STOP       = 11;
  FR_HELP       = 12;
  FR_VISA       = 13;
  FR_AUTHORIZED = 14;
  FR_WARNSTART  = 9;
  FR_WARNEND    = 10;
  FR_DRIVEOFF   = 10;
  FR_COMMDOWN   = 15;
  FR_RESERVED   = 16;
  FR_IDLECATOFF = 17;
  FR_IDLECATON  = 18;
  FR_VISAAUTH   = 19;
  FR_MC         = 20;
  FR_MCAUTH     = 21;
  FR_DISC       = 22;
  FR_DISCAUTH   = 23;
  FR_AMEX       = 24;
  FR_AMEXAUTH   = 25;
  FR_FLEETONE      = 26;
  FR_FLEETONEAUTH  = 27;
  FR_VOYAGER       = 28;
  FR_VOYAGERAUTH   = 29;
  FR_WEX           = 30;
  FR_WEXAUTH       = 31;
  //Gift
  FR_GIFT          = 32;
  FR_GIFTAUTH      = 33;
  FR_VISAWAIT      = 34;
  FR_MCWAIT        = 35;
  FR_DISCWAIT      = 36;
  FR_AMEXWAIT      = 37;
  FR_FLEETONEWAIT  = 38;
  FR_VOYAGERWAIT   = 39;
  FR_WEXWAIT       = 40;
  FR_GIFTWAIT      = 41;

  FR_VISAFAIL      = 42;
  FR_MCFAIL        = 43;
  FR_DISCFAIL      = 44;
  FR_AMEXFAIL      = 45;
  FR_FLEETONEFAIL  = 46;
  FR_VOYAGERFAIL   = 47;
  FR_WEXFAIL       = 48;
  FR_GIFTFAIL      = 49;

  SOUND_CALL = 1;
  SOUND_COLLECT = 2;
  SOUND_DRIVEOFF = 3;
  {$ENDIF}

type

  TPShape = (sRoundRect, sRectangle);
  TTextAlign = (taCenter, taLeft, taRight);
  TBaloonAlign = (alRight, alLeft, alCenter);

  TBaloonxWindow = class(TCustomControl)
  private
    Tail, TailLeft, NoTail: TBitmap;
    Underground: TBitmap;

    //procedure DrawTransparentBitmap(ahdc: HDC;
    //                                xStart, yStart, x1,y1,x2,y2: Word);

    procedure Show(var Rect: TRect; x, y: Integer; Text: String; Shape: TPShape;
                   TextAlign: TTextAlign; DivChar: Char);
    procedure WMMouseMove(var Msg: TMessage); message wm_MouseMove;
    {$IFDEF WIN32}
    procedure WMMouseDown(var Msg: TMessage); message wm_LButtonDown;
    {$ENDIF}
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
  public
    Align: TBaloonAlign;
    Showing: Boolean;
    HideIfMouseMove: Boolean;
    {$IFDEF WIN32}
    HideIfMouseClick: Boolean;
    {$ENDIF}

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Activate(Point: TPoint; Text: String; Shape: TPShape;
                       TextAlign: TTextAlign; DivChar: Char); virtual;
    procedure Deactivate;
  end;

  TPumpxHint = class(TComponent)
  private
    FAlign: TBaloonAlign;
    FColor: TColor;
    FFont: TFont;
    FDivisionChar: Char;
    FHideIfMouseMove: Boolean;
    {$IFDEF WIN32}
    FHideIfMouseClick: Boolean;
    {$ENDIF}
    FShape: TPShape;
    FTextAlign: TTextAlign;

    PumpHintWindow: TBaloonxWindow;
    LastX, LastY: Integer;
  protected
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Show(Text: String; x,y : integer);
    procedure Hide;
    function IsShowing: Boolean;
    function GetX: Integer;
    function GetY: Integer;
  published
    property Align: TBaloonAlign read FAlign write FAlign;
    property Color: TColor read FColor write FColor;
    property Font: TFont read FFont write FFont;
    property DivisionChar: Char read FDivisionChar write FDivisionChar;
    property HideIfMouseMove: Boolean read FHideIfMouseMove write FHideIfMouseMove;
    {$IFDEF WIN32}
    property HideIfMouseClick: Boolean read FHideIfMouseClick write FHideIfMouseClick;
    {$ENDIF}
    property Shape: TPShape read FShape write FShape;
    property TextAlign: TTextAlign read FTextAlign write FTextAlign;
  end;



  TButtonxState=(bsUp,bsDown,bsExclusive);

  TPumpxIcon = class(TCustomControl)
  private
    First  : Boolean;

    FIsDown:           Boolean;
    FMouseDown:        Boolean;
    FState:            TButtonxState;

    //20080107...
//    {$IFDEF PUMP_ICON_EXT}
//    FBitMap : array [0..FR_MAX - 1] of TBitmap;
//    {$ELSE}
    {$IFNDEF PUMP_ICON_EXT}
    //...20080107
    FBitMap : TBitmap;
    {$ENDIF}
    FFrameCount : integer;
    FFrame : Integer;
    FStartFrame : Integer;
    FEndFrame : Integer;
    PlayTimer : TTimer;
    HelpTimer : TTimer;
    HintTimer : TTimer;
    DragTimer : TTimer;
    LongPressTimer : TTimer;
    PumpHint  : TPumpxHint;
    FInterval : integer;
    FLoop : boolean;
    FReverse : boolean;
    FPlay : boolean;
    FSound : integer;
    FSkip : boolean;

    FIdleFrame : integer;

    FDragFrame : boolean;

    { Picture frame }
    FFramewidth    : Integer;
    FFrameheight   : Integer;
    FFrametop      : Integer;
    FFrameleft     : Integer;

    { Button : Bottom of pump icon - $ amounts go here by default}
    FButtonLeft    : Integer;
    FButtonTop     : Integer;
    FButtonWidth   : Integer;
    FButtonHeight  : Integer;
    FButtonCaption : TCaption;
    FButtonFont    : TFont;
    FButtonColor   : TColor;

    { Label : Top of pump icon}
    FLabelLeft     : Integer;
    FLabelTop      : Integer;
    FLabelWidth    : Integer;
    FLabelHeight   : Integer;
    FLabelCaption  : TCaption;
    FSavLabelCaption  : TCaption;
    FLabelFont     : TFont;
    FLabelColor    : TColor;


    FTransparentColor : TColor;
    FOnChangeFrame : TNotifyEvent;

    FOnButtonClick : TNotifyEvent;

//    FSaleid        : Integer;
//    FSaleType      : Integer;
    FPumpNo        : Integer;

    FPumpOnLine    : boolean;
    FCATEnabled    : boolean;
    FCATOnLine     : boolean;
    FCardType      : integer;

    FCATHintInterval   : integer;
    FCATHintTimeout    : integer;


    FHelpShowing   : boolean;
    FLastFrame     : integer;
    FLastPlayState : boolean;

    FPrinterError     : boolean;
    FPrinterPaperLow  : boolean;
    FPrinterPaperOut  : boolean;

    FSale1Status       : integer;
    FSale1Hose         : integer;
    FSale1Type         : integer;
    FSale1Amount       : currency;
    FSale1PrePayAmount : currency;
    FSale1PresetAmount : currency;
    FSale1Volume       : currency;
    FSale1UnitPrice    : currency;
    FSale1ID           : integer;
    FSale1CollectTime  : TDateTime;
    {$IFDEF ODOT_VMT}
    FSale1VMTFee       : currency;
    FSale1VMTReceiptData : WideString;
    {$ENDIF}

    FSale2Status       : integer;
    FSale2Hose         : integer;
    FSale2Type         : integer;
    FSale2Amount       : currency;
    FSale2PrePayAmount : currency;
    FSale2Volume       : currency;
    FSale2UnitPrice    : currency;
    FSale2ID           : integer;
    FSale2CollectTime  : TDateTime;
    {$IFDEF ODOT_VMT}
    FSale2VMTFee       : currency;
    FSale2VMTReceiptData : WideString;
    {$ENDIF}
    FAllowed           : string;
    FErrorCode         : string;
    FErrorString       : string;
    FPLStatus          : TPumpLockStatus;

    FOnLongPress       : TNotifyEvent;

    procedure SetFrame(Value : Integer);
    procedure DispFrame(Value : Integer);
    procedure SetInterval(Value : integer);
    //20080107...
//    {$IFDEF PUMP_ICON_EXT}
//    function GetBitMap() : TBitMap;
//    {$ENDIF}
    {$IFNDEF PUMP_ICON_EXT}
    //...20080107
    procedure SetBitMap(Value : TBitMap);
    {$ENDIF}  //20080107

    { Button }
    procedure SetButtonLeft(Value : integer);
    procedure SetButtonTop(Value : integer);
    procedure SetButtonWidth(Value : integer);
    procedure SetButtonHeight(Value : integer);
    procedure SetButtonCaption(Value : TCaption);
    procedure SetButtonFont(Value : TFont);   virtual;
    function  GetButtonLeft : Integer;
    function  GetButtonTop : Integer;
    function  GetButtonWidth  : Integer;
    function  GetButtonHeight : Integer;
    function  GetButtonCaption : TCaption;
    function  GetButtonFont   : TFont;  virtual;
    procedure SetButtonColor(Value : TColor); virtual;
    function  GetButtonColor   : TColor; virtual;

    { Picture frame }
    procedure SetFrameWidth(Value : Integer);
    function  GetFrameWidth : Integer;
    procedure SetFrameHeight(Value : Integer);
    function  GetFrameHeight : Integer;
    procedure SetFrameTop(Value : Integer);
    function  GetFrameTop : Integer;
    procedure SetFrameLeft(Value : Integer);
    function  GetFrameLeft : Integer;

    procedure ButtonFontChanged(Sender : TObject);
    procedure LabelFontChanged(Sender : TObject);

    { Label: }

    procedure SetCATHintInterval(Value : integer);
    procedure SetCATHintTimeout(Value : integer);

    procedure SetLabelLeft(Value : integer);
    procedure SetLabelTop(Value : integer);
    procedure SetLabelWidth(Value : integer);
    procedure SetLabelHeight(Value : integer);
    procedure SetLabelCaption(Value : TCaption);
    procedure SetLabelFont(Value : TFont);  virtual;
    procedure SetLabelColor(Value : TColor); virtual;

    function  GetLabelLeft : Integer;
    function  GetLabelTop : Integer;
    function  GetLabelWidth  : Integer;
    function  GetLabelHeight : Integer;
    function  GetLabelCaption : TCaption;
    function  GetLabelFont   : TFont; virtual;
    function  GetLabelColor   : TColor; virtual;

    procedure SetCATEnabled(Value : boolean);
    procedure SetCATOnLine(Value : boolean);

    procedure SetPlay(Onn : boolean);

//    function  GetSaleid : Integer;
//    procedure SetSaleid(Value : Integer);

    procedure SetHelpShowing(ShowHelp : boolean);

//    function  GetSaleType : Integer;
//    procedure SetSaleType(Value : Integer);

    procedure DrawTheLabel;
    procedure DrawTheButton;
    procedure UpdateIdleFrame;
    function GetPLS: TPumpLockStatus;
    procedure SetPLS(const Value: TPumpLockStatus);
    procedure LPTimerExp(Sender : TObject);
  protected
    ButtonInit : boolean;
//    procedure Refresh; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
    procedure Paint; override;

    procedure PlayTimeHit(Sender : TObject);
    procedure HelpTimeHit(Sender : TObject);
    procedure HintTimeHit(Sender : TObject);
    function  InsideBtn(X,Y: Integer): boolean;
    
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DragCanceled(); override;
    procedure DragTimerExp(Sender : TObject);
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;
    procedure CheckCATStatus;
    procedure ClearSale1;
    procedure ClearSale2;
    procedure SetBounds(aLeft, aTop, aWidth, aHeight : integer); override;

  published
    property Interval : integer read FInterval write SetInterval;
    property CATHintInterval : integer read FCATHintInterval write SetCATHintInterval;
    property CATHintTimeout  : integer read FCATHintTimeout  write SetCATHintTimeout;

    {Note: FrameCount must precede Frame in order for initialization to be correct}
    property FrameCount : integer read FFrameCount write FFrameCount default 1;
    property Frame : Integer read FFrame write SetFrame;
    property StartFrame : Integer read FStartFrame write FStartFrame;
    property EndFrame : Integer read FEndFrame write FEndFrame;
    //20080107...
//    {$IFDEF PUMP_ICON_EXT}
//    property BitMap : TBitMap read GetBitMap write SetBitMap;
//    {$ELSE}
    {$IFNDEF PUMP_ICON_EXT}
    //...20080107
    property BitMap : TBitMap read FBitMap write SetBitMap;
    {$ENDIF}
    property Play : boolean read FPlay write SetPlay;
    property Sound : integer read FSound write FSound;
    property Reverse: boolean read FReverse write FReverse;
    property Loop: boolean read FLoop write FLoop default True;
    property Height default 90;
    property Width default 90;

//    property SaleID     : Integer read GetSaleId write SetSaleID default 0;
//    property SaleType   : Integer read GetSaleType write SetSaleType default 0;
    property IdleFrame  : Integer read FIdleFrame write FIdleFrame default 0;
    property PumpNo     : Integer read FPumpNo write FPumpNo default 0;
    property PumpOnLine  : boolean read FPumpOnLine write FPumpOnLine default False;
    property CATEnabled  : boolean read FCATEnabled write SetCATEnabled default False;
    property CATOnLine   : boolean read FCATOnLine write SetCATOnLine default False;
    property CardType    : integer read FCardType write FCardType default 0;

    property Sale1Status       : integer      read FSale1Status write FSale1Status default 0;
    property Sale1Hose         : integer      read FSale1Hose write FSale1Hose default 0;
    property Sale1Type         : integer      read FSale1Type write FSale1Type default 0;
    property Sale1Amount       : currency     read FSale1Amount write FSale1Amount;
    property Sale1PrePayAmount : currency     read FSale1PrePayAmount write FSale1PrePayAmount;
    property Sale1PresetAmount : currency     read FSale1PresetAmount write FSale1PresetAmount;
    property Sale1Volume       : currency     read FSale1Volume write FSale1Volume;
    property Sale1UnitPrice    : currency     read FSale1UnitPrice write FSale1UnitPrice;
    property Sale1ID           : integer      read FSale1ID write FSale1ID default 0;
    property Sale1CollectTime  : TDateTime    read FSale1CollectTime write FSale1CollectTime;
    {$IFDEF ODOT_VMT}
    property Sale1VMTFee       : currency     read FSale1VMTFee write FSale1VMTFee;
    property Sale1VMTReceiptData : WideString read FSale1VMTReceiptData write FSale1VMTReceiptData;
    {$ENDIF}

    property Sale2Status       : integer      read FSale2Status write FSale2Status default 0;
    property Sale2Hose         : integer      read FSale2Hose write FSale2Hose default 0;
    property Sale2Type         : integer      read FSale2Type write FSale2Type default 0;
    property Sale2Amount       : currency     read FSale2Amount write FSale2Amount;
    property Sale2PrePayAmount : currency     read FSale2PrePayAmount write FSale2PrePayAmount;
    property Sale2Volume       : currency     read FSale2Volume write FSale2Volume;
    property Sale2UnitPrice    : currency     read FSale2UnitPrice write FSale2UnitPrice;
    property Sale2ID           : integer      read FSale2ID write FSale2ID default 0;
    property Sale2CollectTime  : TDateTime    read FSale2CollectTime write FSale2CollectTime;
    {$IFDEF ODOT_VMT}
    property Sale2VMTFee       : currency     read FSale2VMTFee write FSale2VMTFee;
    property Sale2VMTReceiptData : WideString read FSale2VMTReceiptData write FSale2VMTReceiptData;
    {$ENDIF}

    property Allowed           : string       read FAllowed write FAllowed;
    property ErrorCode         : string       read FErrorCode write FErrorCode;
    property ErrorString       : string       read FErrorString write FErrorString;


    property HelpShowing    : boolean read FHelpShowing write SetHelpShowing default False;
    property LastFrame      : integer read FLastFrame write FLastFrame default 0;
    property LastPlayState  : boolean read FLastPlayState write FLastPlayState default False;

    property PrinterError  : boolean read FPrinterError write FPrinterError default False;
    property PrinterPaperLow  : boolean read FPrinterPaperLow write FPrinterPaperLow default False;
    property PrinterPaperOut  : boolean read FPrinterPaperOut write FPrinterPaperOut default False;

    property Framewidth : Integer read GetFramewidth write SetFramewidth default 20;
    property Frameheight: Integer read GetFrameheight write SetFrameheight default 50;
    property Frametop   : Integer read GetFrametop   write SetFrametop;
    property Frameleft  : Integer read GetFrameleft  write SetFrameleft;
    property OnChangeFrame: TNotifyEvent read FOnChangeFrame
                            write FOnChangeFrame;
    property DragMode;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnClick;
    property Font;
    property Top;
    property Left;


    property LabelColor   : TColor read GetLabelColor write SetLabelColor;
    property LabelFont    : TFont read GetLabelFont write SetLabelFont;
    property ButtonColor  : TColor read GetButtonColor write SetButtonColor;


    property ButtonFont   : TFont read GetButtonFont write SetButtonFont;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property Visible;
    { Button : }
    property ButtonLeft    : Integer read GetButtonLeft  write SetButtonLeft default 1;
    property ButtonTop     : Integer read GetButtonTop   write SetButtonTop default 1;
    property ButtonWidth   : Integer read GetButtonWidth write SetButtonWidth default 70;
    property ButtonHeight  : Integer read GetButtonHeight write SetButtonHeight default 30;
    property ButtonCaption : TCaption read GetButtonCaption write SetButtonCaption ;
    { Label : }
    property LabelLeft    : Integer read GetLabelLeft  write SetLabelLeft default 10;
    property LabelTop     : Integer read GetLabelTop   write SetLabelTop default 10;
    property LabelWidth   : Integer read GetLabelWidth write SetLabelWidth default 50;
    property LabelHeight  : Integer read GetLabelHeight write SetLabelHeight default 20;
    property LabelCaption : TCaption read GetLabelCaption write SetLabelCaption ;
    property SavLabelCaption : TCaption read FSavLabelCaption write FSavLabelCaption ;

    property PumpLockStatus : TPumpLockStatus read GetPLS write SetPLS default plsDisabled;
    property OnLongPress : TNotifyEvent read FOnLongPress write FOnLongPress;
  end;

  procedure LogIt(sID : String);


{$IFDEF PUMP_ICON_EXT}
  procedure LoadPumpFrames(const InstancePrefix : String);
  procedure CalcPumpFrameMaxSize();
  procedure FreePumpFrames;

var
  PFMHeight, PFMWidth : integer;
{$ENDIF}

implementation


{$R PUMPSND.RES}
{$R PUMPHINT.RES}

{$IFDEF PUMP_ICON_EXT}
uses
  Math,
  SysUtils,
  MMSystem,
  ExceptLog;

var
  PumpIconFrames : array [0..FR_MAX - 1] of TBitmap;
{$ENDIF}

procedure TPumpxIcon.UpdateIdleFrame;
begin

  if FCATEnabled then
    begin
      if FCATOnLine then
        FIdleFrame := FR_IDLECATON
      else
        FIdleFrame := FR_IDLECATOFF;
    end
  else
    FIdleFrame := FR_IDLENOCAT ;

  if FFrame in [FR_IDLENOCAT, FR_IDLECATON, FR_IDLECATOFF] then
    Frame := FIdleFrame;

end;

procedure TPumpxIcon.SetCATEnabled(Value : boolean);
begin
  FCATEnabled := Value;
  UpdateIdleFrame;
end;

procedure TPumpxIcon.SetCATOnLine(Value : boolean);
begin
  FCATOnLine := Value;
  UpdateIdleFrame;
end;

procedure TPumpxIcon.ClearSale1;
begin

  Sale1Status        := 0;
  Sale1Hose          := 0;
  Sale1Type          := 0;
  Sale1Amount        := 0;
  Sale1PrePayAmount  := 0;
  Sale1Volume        := 0;
  Sale1UnitPrice     := 0;
  Sale1ID            := 0;
  Sale1CollectTime   := 0;
  {$IFDEF ODOT_VMT}
  Sale1VMTFee        := 0;
  Sale1VMTReceiptData := '';
  {$ENDIF}
  Allowed            := '0';
  ErrorCode          := '0';
  ErrorString        := '';

end;

procedure TPumpxIcon.ClearSale2;
begin

  Sale2Status        := 0;
  Sale2Hose          := 0;
  Sale2Type          := 0;
  Sale2Amount        := 0;
  Sale2PrePayAmount  := 0;
  Sale2Volume        := 0;
  Sale2UnitPrice     := 0;
  Sale2ID            := 0;
  Sale2CollectTime   := 0;
  {$IFDEF ODOT_VMT}
  Sale2VMTFee        := 0;
  Sale2VMTReceiptData := '';
  {$ENDIF}

end;

procedure TPumpxIcon.CheckCATStatus;
var
HintText : string;
begin

  HintTimer.Enabled := False;
  PumpHint.Hide;
  HintText := '';
  if PrinterError then
    HintText := 'Printer Error@';

  if PrinterPaperOut then
    HintText := HintText + 'Printer Paper Empty'
  else if PrinterPaperLow then
    HintText := HintText + 'Printer Paper Low';

  if HintText > '' then
    begin
      PumpHint.Show(HintText, Left + Trunc(Width /2)  , Top);
      HintTimer.Enabled := True;
      HintTimer.Interval := FCATHintTimeout;
    end;

end;

procedure TPumpxIcon.HintTimeHit(Sender : TObject);
begin
  HintTimer.Enabled := False;
  if PumpHint.IsShowing then
    begin
      PumpHint.Hide;
      HintTimer.Interval := FCATHintInterval;
      HintTimer.Enabled := True;
    end
  else
    CheckCATStatus;

end;

procedure TPumpxIcon.SetHelpShowing(ShowHelp : boolean);
begin

  if ShowHelp then
    begin
      FHelpShowing := True;
      //Moved to POS
      (*{$IFDEF 711}
      PlaySound( 'HELP711', HInstance, SND_ASYNC or SND_RESOURCE) ;
      {$ELSE}
      PlaySound( 'PUMPHELP', HInstance, SND_ASYNC or SND_RESOURCE) ;
      {$ENDIF}
      //PlaySound( 'HELP', HInstance, SND_ASYNC or SND_RESOURCE) ;*)
      //Moved to POS
      LastFrame := FFrame;
      LastPlayState := FPlay;
      SetFrame(FR_HELP);
      HelpTimer.Free;
      HelpTimer := Nil;
      HelpTimer := TTimer.Create(Self);
      HelpTimer.Interval := FCATHintInterval;
      HelpTimer.OnTimer := HelpTimeHit;
    end
  else
    begin
      FHelpShowing := False;
      if LastFrame > 0 then
        begin
         SetFrame(LastFrame);
         Play := LastPlayState;
        end;
      HelpTimer.Free;
      HelpTimer := Nil;
    end;



end;

procedure TPumpxIcon.HelpTimeHit(Sender : TObject);
begin
  SetHelpShowing(False);
end;


//function TPumpxIcon.GetSaleid : integer;
//begin  Result := FSaleid; End;

//procedure TPumpxIcon.SetSaleid(Value : Integer);
//begin  FSaleid := Value;  End;

//function TPumpxIcon.GetSaleType : integer;
///begin  Result := FSaleType; End;

//procedure TPumpxIcon.SetSaleType(Value : Integer);
//begin  FSaleType := Value;  End;

{ Picture frame: }

procedure TPumpxIcon.SetCATHintInterval(Value : Integer);
begin
  if (Value < 1) or (Value > 180) then
    FCATHintInterval := 15 * 1000
  else
    FCATHintInterval := Value * 1000;
end;

procedure TPumpxIcon.SetCATHintTimeout(Value : Integer);
begin
  if (Value < 1) or (Value > 180) then
    FCATHintTimeout := 3 * 1000
  else
    FCATHintTimeout := Value * 1000;
end;



function TPumpxIcon.GetFrameWidth : integer;
begin  Result := FFramewidth; End;

procedure TPumpxIcon.SetFrameWidth(Value : Integer);
begin  FFrameWidth := Value; Refresh; End;

function TPumpxIcon.GetFrameHeight : integer;
begin  Result := FFrameHeight; End;

procedure TPumpxIcon.SetFrameHeight(Value : Integer);
begin  FFrameHeight := Value; Refresh; End;

function TPumpxIcon.GetFrameTop : integer;
begin  Result := FFrameTop; End;

procedure TPumpxIcon.SetFrameTop(Value : Integer);
begin  FFrameTop := Value; Refresh; End;

function TPumpxIcon.GetFrameLeft : integer;
begin  Result := FFrameleft; End;

procedure TPumpxIcon.SetFrameLeft(Value : Integer);
begin  FFrameLeft := Value; Refresh; End;

{ Button : }

procedure TPumpxIcon.SetButtonLeft (Value : Integer);
begin  FButtonLeft := Value; Refresh; End;

procedure TPumpxIcon.SetButtonTop (Value : Integer);
begin  FButtonTop := Value; Refresh; End;

procedure TPumpxIcon.SetButtonWidth (Value : Integer);
begin  FButtonWidth := Value; Refresh; End;

procedure TPumpxIcon.SetButtonHeight (Value : Integer);
begin FButtonHeight := Value; Refresh; End;

procedure TPumpxIcon.SetButtonCaption (Value : TCaption);
begin

  FButtonCaption := Value;
  if Parent <> nil   then
    DrawTheButton;
//  else
    Refresh;

End;

function TPumpxIcon.GetButtonLeft : Integer;
begin  Result := FButtonLeft; End;

function  TPumpxIcon.GetButtonTop : Integer;
begin  Result := FButtonTop; End;

function  TPumpxIcon.GetButtonWidth  : Integer;
begin  Result := FButtonWidth;  End;

function  TPumpxIcon.GetButtonHeight : Integer;
begin  Result :=  FButtonHeight; End;

function  TPumpxIcon.GetButtonCaption : TCaption;
begin  Result := FButtonCaption; End;

procedure TPumpxIcon.SetButtonFont (Value : TFont);
begin
 FButtonFont := Value;
// Refresh;
End;

function  TPumpxIcon.GetButtonFont : TFont;
begin
  Result := FButtonFont;
//  Refresh;
End;


procedure TPumpxIcon.ButtonFontChanged (Sender : TObject);
begin
 Refresh;
End;

procedure TPumpxIcon.LabelFontChanged (Sender : TObject);
begin
 Refresh;
End;


{ Label : }

procedure TPumpxIcon.SetLabelColor (Value : TColor);
begin
  FLabelColor := Value;
  Refresh;

End;

function  TPumpxIcon.GetLabelColor : TColor;
begin
  Result := FLabelColor;

End;

procedure TPumpxIcon.SetButtonColor (Value : TColor);
begin
  FButtonColor := Value;
  Refresh;

End;

function  TPumpxIcon.GetButtonColor : TColor;
begin
  Result := FButtonColor;

End;


procedure TPumpxIcon.SetLabelLeft (Value : Integer);
begin  FLabelLeft := Value; Refresh; End;

procedure TPumpxIcon.SetLabelTop (Value : Integer);
begin  FLabelTop := Value; Refresh; End;

procedure TPumpxIcon.SetLabelWidth (Value : Integer);
begin  FLabelWidth := Value; Refresh; End;

procedure TPumpxIcon.SetLabelHeight (Value : Integer);
begin FLabelHeight := Value; Refresh; End;

procedure TPumpxIcon.SetLabelCaption (Value : TCaption);
begin  FLabelCaption := Value; Refresh; End;

procedure TPumpxIcon.SetLabelFont (Value : TFont);
begin  FLabelFont := Value; Refresh; End;

function TPumpxIcon.GetLabelLeft : Integer;
begin  Result := FLabelLeft; End;

function  TPumpxIcon.GetLabelTop : Integer;
begin  Result := FLabelTop; End;

function  TPumpxIcon.GetLabelWidth  : Integer;
begin  Result := FLabelWidth;  End;

function  TPumpxIcon.GetLabelHeight : Integer;
begin  Result :=  FLabelHeight; End;

function  TPumpxIcon.GetLabelCaption : TCaption;
begin  Result := FLabelCaption; End;

function  TPumpxIcon.GetLabelFont : TFont;
begin
  Result := FLabelFont;
  Refresh;
End;
{------------------------------------------------------------------------------}

constructor TPumpxIcon.Create(AOwner: TComponent);
//20080107...
//{$IFDEF PUMP_ICON_EXT}
//var
//  j : integer;
//{$ENDIF}
//...20080107
begin

 ButtonInit := False;

inherited Create(AOwner);

 //20080107...
// {$IFDEF PUMP_ICON_EXT}
//  for j := 0 to FR_MAX - 1 do
//  begin
//    FBitMap[j] := TBitMap.Create;
//  end;
// {$ELSE}
 {$IFNDEF PUMP_ICON_EXT}
 //...20080107
 FBitMap := TBitMap.Create;
 {$ENDIF}
 FrameCount := 1;
 ControlStyle := ControlStyle +[csOpaque];
 FLoop := True;
 FSound := 0;
 FTransparentColor := -1;
 { We create the button }
 FButtonLeft    := 2;
 FButtonTop     := 1;
 FButtonWidth   := 70;
 FButtonHeight  := 30;
 FButtonCaption := '$ 0.00';
 FFramewidth    := 25;
 FButtonFont := TFont.Create;
 FButtonFont.OnChange := ButtonFontChanged;
 FButtonColor    := clSilver;

 FLabelColor    := clSilver;
 FLabelLeft    := 2;
 FLabelTop     := 2;
 FLabelCaption := 'Pump1';
 FLabelWidth   := 70;
 FLabelHeight  := 30;
 FLabelFont    := TFont.Create;
 FLabelFont.OnChange := LabelFontChanged;

 FState := bsUp;
 FMouseDown:= False;
 FIsDown := False;
 FSkip := False;

 First := True;
 ButtonInit := True;

 PumpHint := TPumpxHint.Create(Self);
 HintTimer := TTimer.Create(Self);
 HintTimer.Enabled := False;
 HintTimer.OnTimer := HintTimeHit;

 DragTimer := TTimer.Create(Self);
 DragTimer.Enabled := False;
 DragTimer.OnTimer := DragTimerExp;
 DragTimer.Interval := 500;

  Self.Color := PLColors[Self.FPLStatus];
  Framewidth    := PFMWidth;
  Frameheight   := PFMHeight;
  Frameleft     := 5;
  Frametop      := 19;

  Labelfont.color  := clBlack;
  Labelfont.name   := 'Arial';
  Labelfont.style  := [fsBold];
  ButtonFont.color  := clBlack;
  ButtonFont.name   := 'Arial';
  ButtonFont.style  := [fsBold];

  LongPressTimer := TTimer.Create(Self);
  LongPressTimer.Enabled := False;
  LongPressTimer.OnTimer := LPTimerExp;
  LongPressTimer.Interval := 2000;
end;

destructor TPumpxIcon.Destroy;
//20080107...
//{$IFDEF PUMP_ICON_EXT}
//var
//  j : integer;
//{$ENDIF}
//...20080107
begin
  PlayTimer.Free;
  HelpTimer.Free;
  HintTimer.Free;

  //20080107...
//  {$IFDEF PUMP_ICON_EXT}
//  for j := 0 to FR_MAX - 1 do
//  begin
//    try
//      FBitMap[j].Free;
//    except
//    end;
//  end;
//  {$ELSE}
  {$IFNDEF PUMP_ICON_EXT}
  //...20080107
  FBitMap.Free;
  {$ENDIF}
  FLabelFont.Free;
  FButtonFont.Free;
  inherited Destroy;
end;

//20080107...
//{$IFDEF PUMP_ICON_EXT}
//function TPumpxIcon.GetBitMap() : TBitMap;
//begin
//  GetBitMap := FBitMap[FFrame];
//end;
//{$ENDIF}
//...20080107

{$IFNDEF PUMP_ICON_EXT}  //20080107
procedure TPumpxIcon.SetBitMap(Value : TBitMap);
begin
  //20080107...
//  {$IFDEF PUMP_ICON_EXT}
//  if ((FFrame >= 0) and (FFrame < FR_MAX)) then
//    FBitMap[FFrame].Assign(Value);
//  {$ELSE}
  //...20080107
  FBitMap.Assign(Value);
//20080107  {$ENDIF}
(* Height := FBitMap.Height;
   if Height = 0 then Height := 30;  {so something will display}
*)
end;
{$ENDIF}  // not PUMP_ICON_EXT //20080107

procedure TPumpxIcon.SetInterval(Value : Integer);
begin
if Value <> FInterval then
  begin
  PlayTimer.Free;
  PlayTimer := Nil;
  if FPlay and (Value > 0) then
    begin
    PlayTimer := TTimer.Create(Self);
    PlayTimer.Interval := Value;
    PlayTimer.OnTimer := PlayTimeHit;
    end;
  FInterval := Value;
  end;
end;


procedure TPumpxIcon.SetPlay(Onn : boolean);
begin
if Onn <> FPlay then
  begin
  FPlay := Onn;
  if not Onn then
    begin
    PlayTimer.Free;
    PlayTimer := Nil;
    end
  else if FInterval > 0 then
    begin
    if FStartFrame > 0 then
      SetFrame(FStartFrame - 1);

    PlayTimer := TTimer.Create(Self);
    PlayTimer.Interval := FInterval;
    PlayTimer.OnTimer := PlayTimeHit;
    end;
  end;
end;

procedure TPumpxIcon.SetFrame(Value : Integer);
var
  Temp : Integer;
begin
  {$IFDEF PUMP_ICON_EXT}
  // If PumpNo not yet initialized, then only set the frame number (i.e., do not paint screen).
  if ((PumpNo = 0) and (Value >= 0) and (Value < FR_MAX)) then
  begin
    // Pump number is zero only when initially creating the pump icons.
    FFrame := Value;
    exit;
  end;
  {$ENDIF}

  if (Value <> FR_HELP) and (HelpShowing) then
  begin
    LastFrame := 0;  //  This tells SetHelpShowing not to update the Frame
    HelpShowing := False;
  end;
  
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
    else FFrame := Temp;
  end;

  if Assigned(FOnChangeFrame) then FOnChangeFrame(Self);

  DispFrame(FFrame);
end;

procedure TPumpxIcon.DispFrame(Value : Integer);
var
  {$IFNDEF PUMP_ICON_EXT}
  X : Integer;
  {$ENDIF}
  ARect, BRect : Trect;
begin
  ARect := Rect(FFrameLeft,FFrameTop,FFramewidth + FFrameLeft,FFrameheight + FFrameTop);
  {$IFDEF PUMP_ICON_EXT}
  if PumpIconFrames[Value].Height > 0 then
  begin
    BRect := Rect(0 ,0, FFrameWidth , FFrameheight);
    Canvas.CopyRect(ARect, PumpIconFrames[Value].Canvas, BRect);
  end;
  {$ELSE}
  if FBitMap.Height > 0 then
  begin
    X := FFramewidth*Value;
    BRect := Rect(X ,0, X + FFrameWidth , FFrameheight);
    Canvas.CopyRect(ARect, FBitmap.Canvas, BRect);
  end;
  {$ENDIF}
end;

procedure TPumpxIcon.PlayTimeHit(Sender : TObject);
  procedure ChkStop;
  begin
  if not FLoop then
    begin
    FPlay := False;
    PlayTimer.Free;
    PlayTimer := Nil;
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


//procedure TPumpxIcon.Refresh;
//Begin
 { First we delete the old canvas, and repaint the whole thing... }
// if csDesigning in ComponentState then
//  Begin
//   Canvas.Brush.Color := clSilver;
//   Canvas.FillRect(Rect(0, 0, 1500, 1000));
//   Canvas.Refresh;
//   Paint;
//  End;

//End;


procedure TPumpxIcon.Paint;
var
 TmpRect:TRect;
  ARect, BRect : TRect;
  {$IFNDEF PUMP_ICON_EXT}
  X : Integer;
  {$ENDIF}
begin
{ We draw a frame around the whole thing }

ARect.Top := 0; ARect.Left := 0;
ARect.Right := Width - 0; ARect.Bottom := Height - 0;

Canvas.Brush.Color := Color;
ARect := Rect(Self.FLabelLeft, Self.FLabelTop + Self.FLabelHeight, Self.FLabelLeft + Self.FLabelWidth, Self.FButtonTop);
Canvas.FillRect(ARect);

Canvas.Brush.Color := clBlack;
Canvas.FrameRect (ARect);
Canvas.Pen.Color := clWhite;
Canvas.Moveto (1,Height - 2);
Canvas.Lineto (1,1);
Canvas.Lineto (Width - 2,1);
Canvas.Pen.Color := clGray;
Canvas.Lineto (Width - 2,Height - 2);
Canvas.Lineto (1,Height - 2);

ARect := Rect(FFrameLeft,FFrameTop,FFramewidth + FFrameLeft,FFrameheight + FFrameTop);

{$IFDEF PUMP_ICON_EXT}
if PumpIconFrames[FFrame].Height > 0 then
  begin
  BRect := Rect(0 ,0, FFrameWidth , FFrameheight);
  Canvas.CopyRect(ARect, PumpIconFrames[FFrame].Canvas, BRect);
  end
{$ELSE}
if FBitMap.Height > 0 then
  begin
  X := FFramewidth*FFrame;
  BRect := Rect(X ,0, X + FFrameWidth , FFrameheight);
  Canvas.CopyRect(ARect, FBitmap.Canvas, BRect);
  end
{$ENDIF}
else
  begin   {fill with something}
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(BoundsRect);
  end;

  if First and Assigned(FOnButtonClick) then
    Begin
      First := False;
    End;

  TmpRect := Rect(1,1,Width-1,Height-1);

  if (FState = bsDown) then
    begin
     InflateRect(TmpRect,1,1);
     Frame3D(Canvas,TmpRect,clBlack,clBtnHighLight,1);
     Frame3D(Canvas,TmpRect,clBtnShadow,clBtnFace,1);
    end;

  if (FState = bsUp) then
     begin
       InflateRect(TmpRect,1,1);
       Frame3D(Canvas,TmpRect,clBtnHighLight,clBlack,1);
       Frame3D(Canvas,TmpRect,clBtnFace,clBtnShadow,1);
     end;

  DrawTheLabel;
  DrawTheButton;

end;


procedure TPumpxIcon.DrawTheLabel;
var
Flags,MidX,MidY: Integer;
DC:THandle; { Col:TColor; }
tmprect:TRect;
begin


  Canvas.Font := FLabelFont;
  DC := Canvas.Handle; { reduce calls to GetHandle }
  //Flags := DT_SINGLELINE;


  tmpRect := Rect(FLabelLeft,FLabelTop,FLabelLeft+FLabelWidth,FLabelTop + FLabelHeight );

//  if Canvas.Pixels[FLabelLeft+1,FLabelTop+1] <> FLabelColor then
//    begin
      Canvas.Brush.Color := FLabelColor;
      Canvas.FillRect(TmpRect);
//    end;

  { calculate width and height of text: }
//  DrawText(DC, PChar(FLabelCaption), Length(FLabelCaption), tmpRect, Flags or DT_CALCRECT);

  MidY := tmpRect.Bottom - tmpRect.Top;
  MidX := tmpRect.Right-tmpRect.Left;
  Flags := DT_CENTER;
  OffsetRect(tmpRect,FLabelWidth div 2 - MidX div 2,FLabelHeight div 2 - MidY div 2);
  Flags := Flags or DT_SINGLELINE or DT_NOCLIP;
//  if (FState = bsDown) then
//    OffsetRect(tmpRect,1,1);

  SetBkMode(DC, TRANSPARENT);

  if not Enabled then
  begin
    SetTextColor(DC,ColorToRGB(clBtnHighLight));
    OffsetRect(tmpRect,1,1);
    DrawText(DC, PChar(FLabelCaption), Length(FLabelCaption), tmpRect, Flags);
    OffsetRect(tmpRect,-1,-1);
    SetTextColor(DC,ColorToRGB(clBtnShadow));
  end
  else
    SetTextColor(DC,FLabelFont.Color);

  DrawText(DC, PChar(FLabelCaption), Length(FLabelCaption), tmpRect, Flags);

end;

procedure TPumpxIcon.DrawTheButton;
var
Flags,MidX,MidY: Integer;
DC:THandle; { Col:TColor; }
tmprect:TRect;
begin

  tmpRect := Rect(FButtonLeft,FButtonTop,FButtonLeft+FButtonWidth ,FButtonTop + FButtonHeight );

  Frame3D(Canvas,TmpRect,clBtnHighLight,clBlack,1);

  Canvas.Brush.Color := FButtonColor;
  Canvas.FillRect(TmpRect);

  Canvas.Font := FButtonFont;
  DC := Canvas.Handle; { reduce calls to GetHandle }
  //Flags := DT_SINGLELINE;

 (*
  if Canvas.Pixels[FButtonLeft+1,FButtonTop+1] <> FButtonColor then
    begin
      Canvas.Brush.Color := FButtonColor;
      Canvas.FillRect(TmpRect);
    end;
   *)

  { calculate width and height of text: }
//  DrawText(DC, PChar(FButtonCaption), Length(FButtonCaption), tmpRect, Flags or DT_CALCRECT);

  MidY := tmpRect.Bottom - tmpRect.Top;
  MidX := tmpRect.Right-tmpRect.Left;
  Flags := DT_CENTER;
  OffsetRect(tmpRect,FLabelWidth div 2 - MidX div 2,FLabelHeight div 2 - MidY div 2);
  Flags := Flags or DT_SINGLELINE or DT_NOCLIP;
//  if (FState = bsDown) then
//    OffsetRect(tmpRect,1,1);

  SetBkMode(DC, TRANSPARENT);

  if not Enabled then
  begin
    SetTextColor(DC,ColorToRGB(clBtnHighLight));
    OffsetRect(tmpRect,1,1);
    DrawText(DC, PChar(FButtonCaption), Length(FButtonCaption), tmpRect, Flags);
    OffsetRect(tmpRect,-1,-1);
    SetTextColor(DC,ColorToRGB(clBtnShadow));
  end
  else
    SetTextColor(DC,FButtonFont.Color);

  if (FLabelCaption = '1') and (FButtonCaption = '') then
    SetTextColor(DC,clYellow);

  DrawText(DC, PChar(FButtonCaption), Length(FButtonCaption), tmpRect, Flags);

end;

procedure TPumpxIcon.LPTimerExp(Sender: TObject);
begin
  if not FIsDown then Exit
  else FIsDown := False;
  TTimer(Sender).Enabled := False;
  if Assigned(OnLongPress) then
    OnLongPress(Self);
  FMouseDown := False;
  FState := bsUp;
  if Sound > SOUND_CALL then
    Sound := 0;
  Paint;
end;

procedure TPumpxIcon.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  if FIsDown then Exit
  else FIsDown := not FIsDown;
  if InsideBtn(X,Y) then
    begin
      FMouseDown := True;
      FState := bsDown;
      Paint;
      sleep(100);
      LongPressTimer.Enabled := True;
    end;
  PlaySound( 'BUTTONSND', HInstance, SND_ASYNC or SND_RESOURCE) ;
  inherited MouseDown(Button,Shift,X,Y);
end;

procedure TPumpxIcon.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  LongPressTimer.Enabled := False;

  if not FIsDown then Exit
  else FIsDown := not FIsDown;

  inherited MouseUp(Button,Shift,X,Y);

  if Assigned(OnMouseUp) then OnMouseUp(Self,Button,Shift,X,Y);

  FMouseDown := False;
  FState := bsUp;
  if Sound > SOUND_CALL then
    Sound := 0;
  Paint;

end;

function TPumpxIcon.InsideBtn(X,Y: Integer): boolean;
begin
  Result := PtInRect(Rect(0,0,Width,Height),Point(X,Y));
end;

procedure LogIt(sID: string );
var
  TF: TextFile;
begin

{ Procedure commented to speed up processing in stores... }

  Assignfile(TF,'c:\Button.log');
  if Not(FileExists('c:\button.log')) Then
    Rewrite(TF)
  else
    Append(TF);

  WriteLn(TF, sID );
  Closefile(TF);

end;


(*procedure TBaloonxWindow.DrawTransparentBitmap(ahdc: HDC;
                                 xStart, yStart, x1,y1,x2,y2: Word);
var
  TransparentColor: TColor;
  cColor          : TColorRef;
  bmAndBack,
  bmAndObject,
  bmAndMem,
  bmSave,
  bmBackOld,
  bmObjectOld,
  bmMemOld,
  bmSaveOld       : HBitmap;
  hdcMem,
  hdcBack,
  hdcObject,
  hdcTemp,
  hdcSave         : HDC;
  ptSize          : TPoint;
begin
  { set the transparent to black }
  TransparentColor := clYellow;
  TransparentColor := TransparentColor or $02000000;

  hdcTemp := CreateCompatibleDC (ahdc);
  if Align = alCenter then
   SelectObject(hdcTemp, NoTail.Handle) { select the bitmap }
  else if Align = alRight then
   SelectObject(hdcTemp, Tail.Handle) { select the bitmap }
  else
   SelectObject(hdcTemp, TailLeft.Handle);

  { convert bitmap dimensions from device to logical points }
  ptSize.x := x2-x1;
  ptSize.y := y2-y1;
  DPToLP (hdcTemp, ptSize, 1);  { convert from device logical points }

  { create some DCs to hold temporary data }
  hdcBack   := CreateCompatibleDC(ahdc);
  hdcObject := CreateCompatibleDC(ahdc);
  hdcMem    := CreateCompatibleDC(ahdc);
  hdcSave   := CreateCompatibleDC(ahdc);

  { create a bitmap for each DC }

  { monochrome DC }
  bmAndBack   := CreateBitmap (ptSize.x, ptSize.y, 1, 1, nil);
  bmAndObject := CreateBitmap (ptSize.x, ptSize.y, 1, 1, nil);

  bmAndMem    := CreateCompatibleBitmap (ahdc, ptSize.x, ptSize.y);
  bmSave      := CreateCompatibleBitmap (ahdc, ptSize.x, ptSize.y);

  { each DC must select a bitmap object to store pixel data }
  bmBackOld   := SelectObject (hdcBack, bmAndBack);
  bmObjectOld := SelectObject (hdcObject, bmAndObject);
  bmMemOld    := SelectObject (hdcMem, bmAndMem);
  bmSaveOld   := SelectObject (hdcSave, bmSave);

  { set proper mapping mode }
  SetMapMode (hdcTemp, GetMapMode (ahdc));

  { save the bitmap sent here, because it will be overwritten }
  BitBlt (hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, x1, y1, SRCCOPY);

  { set the background color of the source DC to the color.
    contained in the parts of the bitmap that should be transparent }
  cColor := SetBkColor (hdcTemp, TransparentColor);

  { create the object mask for the bitmap by performing a BitBlt()
    from the source bitmap to a monochrome bitmap }
  BitBlt (hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, x1, y1, SRCCOPY);

  { set the background color of the source DC back to the original color }
  SetBkColor (hdcTemp, cColor);

  { create the inverse of the object mask }
  BitBlt (hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, NOTSRCCOPY);

  { copy the background of the main DC to the destination }
  BitBlt (hdcMem, 0, 0, ptSize.x, ptSize.y, ahdc, xStart, yStart, SRCCOPY);

  { mask out the places where the bitmap will be placed }
  BitBlt (hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);

  { mask out the transparent colored pixels on the bitmap }
  BitBlt (hdcTemp, x1, y1, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);

  { XOR the bitmap with the background on the destination DC }
  BitBlt (hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, x1, y1, SRCPAINT);

  { copy the destination to the screen }
  BitBlt (ahdc, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0, SRCCOPY);

  { place the original bitmap back into the bitmap sent here }
  BitBlt (hdcTemp, x1, y1, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);

  { delete the memory bitmaps }
  DeleteObject (SelectObject (hdcBack, bmBackOld));
  DeleteObject (SelectObject (hdcObject, bmObjectOld));
  DeleteObject (SelectObject (hdcMem, bmMemOld));
  DeleteObject (SelectObject (hdcSave, bmSaveOld));

  { delete the memory DCs }
  DeleteDC (hdcMem);
  DeleteDC (hdcBack);
  DeleteDC (hdcObject);
  DeleteDC (hdcSave);
//  DeleteDC (hdcTemp);
end;*)

{ TBaloonxWindow }

constructor TBaloonxWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  HideIfMouseMove := TPumpxHint(AOwner).HideIfMouseMove;
  {$IFDEF WIN32}
  HideIfMouseClick := TPumpxHint(AOwner).HideIfMouseClick;
  {$ENDIF}
  Tail := TBitmap.Create;
  Tail.Handle := LoadBitmap(hInstance, 'TAIL');
  TailLeft := TBitmap.Create;
  TailLeft.Handle := LoadBitmap(hInstance, 'TAILLEFT');
  NoTail := TBitmap.Create;
  NoTail.Handle := LoadBitmap(hInstance, 'NOTAIL');
  Underground := TBitmap.Create;
end;

destructor TBaloonxWindow.Destroy;
begin
  Underground.Free;
  TailLeft.Free;
  Tail.Free;
  NoTail.Free;
  inherited Destroy;
end;

procedure TBaloonxWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  {$IFDEF WIN32}
  with Params do
  begin
    Style := WS_POPUP;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    if NewStyleControls then ExStyle := WS_EX_TOOLWINDOW;
  end;
  {$ELSE}
  with Params do
  begin
    if HideIfMouseMove then Style := WS_POPUP
    else Style := WS_POPUP or WS_DISABLED;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
  end;
  {$ENDIF}
end;

procedure TBaloonxWindow.Show(var Rect: TRect; x, y: Integer; Text: String; Shape: TPShape;
                             TextAlign: TTextAlign; DivChar: Char);
var
  Wid, RectBeg, Pix, MirFill, MaxPlus, TextO: Integer;
  q, i: Integer;
  MaxWidth, FontHeight: Integer;
  SL: TStringList;
  h: Integer;
  DC: hDC;
begin
  if Length(Text) <> 0 then
  begin
    if Align = alRight then
    begin
      MirFill := 12;
      RectBeg := 10;
      MaxPlus := 21;
      TextO := 15;
      Pix := 3;
    end
    else if Align = alLeft then
    begin
      MirFill := 12;
      RectBeg := 2;
      MaxPlus := 13;
      TextO := 8;
      Pix := 0;
    end
    else
    begin
      MirFill := 12;
      RectBeg := 2;
      MaxPlus := 13;
      TextO := 8;
      Pix := 3;
    end;


    SL := TStringList.Create;
    with Underground.Canvas do
    begin
      q := 1;
      for i := 1 to Length(Text) do
      if Text[i] = '@' then
      begin
        SL.Add(Copy(Text, q, i - q));
        q := i + 1;
      end;
      SL.Add(Copy(Text, q, Length(Text)));

      MaxWidth := 0;

      FontHeight := 0;
      for i := 0 to SL.Count - 1 do
      begin
        FontHeight := FontHeight + TextHeight(SL[i]);
        h := TextWidth(SL[i]);
        if MaxWidth < h then
          MaxWidth := h;
      end;
      x := x - Trunc((MaxWidth + 23) / 2);
      Underground.Width := MaxWidth + 23;
      Underground.Height := y - (y - FontHeight - 2) ;

      if Align = alLeft then
      begin
        Wid := Underground.Width;
        dec(x, Wid);
        MirFill := Wid - 12;
        Pix := Wid - 4;
      end;

      DC := GetDC(0);
//      BitBlt(Underground.Canvas.Handle, 0, 0, Underground.Width, Underground.Height, DC,
//             x, y - FontHeight - 2, SrcCopy);
      BitBlt(Underground.Canvas.Handle, 0, 0, Underground.Width, Underground.Height, DC,
           x , y , SrcCopy);
      ReleaseDC(0, DC);

      Brush.Color := clBlack;
      if Shape = sRoundRect then
       RoundRect(RectBeg + 2, 2,
                 MaxWidth + MaxPlus + 2, FontHeight + 5, 15, 15)
      else
       Rectangle(RectBeg + 2, 2,
                 MaxWidth + MaxPlus + 2, FontHeight + 5);
      Brush.Color := Color;
      if Shape = sRoundRect then
       RoundRect(RectBeg, 0,
                 MaxWidth + MaxPlus, FontHeight + 3, 15, 15)
      else
       Rectangle(RectBeg, 0,
                 MaxWidth + MaxPlus, FontHeight + 3);

//      DrawTransparentBitmap(Underground.Canvas.Handle,
//                            Wid, FontHeight - 2, 0, 0, 15, 21);

//      DrawTransparentBitmap(Underground.Canvas.Handle,
//                            Wid, FontHeight - 2, 0, 0, 0, 0);

      FloodFill(MirFill, FontHeight - 3, clBlack, fsBorder);

      Pixels[Pix, FontHeight + 13] := Color;
      Pixels[Pix, FontHeight + 14] := Color;
      Pixels[Pix + 1, FontHeight + 15] := Color;

      h := 1;
      for i := 0 to SL.Count - 1 do
       begin
        if TextAlign = taLeft then
         TextOut(TextO, h, SL[i])
        else
         begin
          q := TextWidth(SL[i]);
          if TextAlign = taCenter then
           begin
            q := MaxWidth div 2 - q div 2;
            TextOut(q + TextO, h, SL[i])
           end
          else
           TextOut(MaxWidth - q + TextO, h, SL[i]);
         end;
        inc(h, TextHeight(SL[i]));
       end;
     end;
    SL.Free;

  with Rect do
   begin
    left := x ;
//    top := y - FontHeight - 2;
    top := y;
    right := x + MaxWidth + 23;
  //  bottom := y + 18;
    bottom := y  + FontHeight + 2;
   end;

  end;
end;

procedure TBaloonxWindow.WMMouseMove(var Msg: TMessage);
begin
  {$IFDEF WIN32}
  if HideIfMouseMove then {$ENDIF}
   Deactivate;
end;

{$IFDEF WIN32}
procedure TBaloonxWindow.WMMouseDown(var Msg: TMessage);
begin
  if HideIfMouseClick then Deactivate;
end;
{$ENDIF}

procedure TBaloonxWindow.Paint;
begin
  Canvas.Draw(0, 0, Underground);
end;

procedure TBaloonxWindow.Deactivate;
begin
  Showing := False;
  DestroyHandle;
end;

procedure TBaloonxWindow.Activate(Point: TPoint; Text: String; Shape: TPShape;
                                                              TextAlign: TTextAlign;
                                                              DivChar: Char);
var
  Rect: TRect;
begin

  if Showing then DestroyHandle;
  Show(Rect, Point.x, Point.y , Text, Shape, TextAlign, DivChar);
  BoundsRect := Rect;

  SetWindowPos(Handle, HWND_TOPMOST, Rect.Left, Rect.Top, 0,
    0, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE);
  Showing := True;

end;

{ TPumpxHint }

constructor TPumpxHint.Create(aOwner: TComponent);
begin

  inherited Create(aOwner);
  FDivisionChar := '@';
  FFont := TFont.Create;
  FFont.Name := 'Arial';
  FFont.Size := 8;
  FFont.Color := clBlack;
  FFont.Style := [];
  FColor := clYellow;
  FShape := sRoundRect;
  FAlign := alCenter;
  FHideIfMouseMove := False;
  PumpHintWindow := TBaloonxWindow.Create(Self);

end;

destructor TPumpxHint.Destroy;
begin
  if PumpHintWindow <> nil then Hide;
  FFont.Free;
  inherited Destroy;
end;

procedure TPumpxHint.Show(Text: String; X, Y : integer);
var
  Point: TPoint;
begin
  if Text <> '' then
   begin
    if PumpHintWindow <> nil then Hide;
//    PumpHintWindow := TBaloonxWindow.Create(Self);
    PumpHintWindow.CreateHandle;
    PumpHintWindow.Underground.Canvas.Font.Assign(Font);
    PumpHintWindow.Color := FColor;
    Point.x := x;
    Point.Y := y;
    PumpHintWindow.Align := Align;
    PumpHintWindow.Activate(Point, Text, FShape, FTextAlign, FDivisionChar);
   end;
end;

procedure TPumpxHint.Hide;
begin
  if PumpHintWindow <> nil then
    begin
      PumpHintWindow.Deactivate;
    end;
end;

function TPumpxHint.IsShowing: Boolean;
begin
  if PumpHintWindow <> nil then
   Result := PumpHintWindow.Showing
  else
   Result := False;
end;

function TPumpxHint.GetX: Integer;
begin
  if IsShowing then Result := LastX
  else Result := -1;
end;

function TPumpxHint.GetY: Integer;
begin
  if IsShowing then Result := LastY
  else Result := -1;
end;



//20080102a...
//procedure Register;
//begin
//  RegisterComponents('POS', [TPumpxIcon]);
//end;
//...20080102a

procedure TPumpxIcon.DragTimerExp(Sender: TObject);
begin
  if FDragFrame then
  begin
    FDragFrame := False;
    DispFrame(FFrame);
  end
  else
  begin
    FDragFrame := True;
    DispFrame(FR_RESERVED);
  end;
end;

procedure TPumpxIcon.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := False;
  if Assigned(OnDragOver) then
  begin
    Accept := True;
    OnDragOver(Self, Source, X, Y, State, Accept);
  end;
  if State = dsDragEnter then 
  begin
    // blink the frames
    DragTimer.Enabled := Accept;
    TpumpxIcon(Source).DragTimer.Enabled := Accept;
  end
  else if State = dsDragLeave then 
  begin
    // Stop the blinking
    DragTimer.Enabled := False;
    TpumpxIcon(Source).DragTimer.Enabled := False;
    // show the original frames
    DispFrame(FFrame);
    TpumpxIcon(Source).DispFrame(TpumpxIcon(Source).FFrame);
  end;
end;

procedure TPumpxIcon.DragCanceled();
begin
  // stop the blinking
  DragTimer.Enabled := False;
  // show the original frame
  DispFrame(FFrame);
end;

function TPumpxIcon.GetPLS: TPumpLockStatus;
begin
  GetPLS := Self.FPLStatus;
end;

procedure TPumpxIcon.SetPLS(const Value: TPumpLockStatus);
begin
  if Value = Self.FPLStatus then exit;
  Self.FPLStatus := Value;
  Self.Color := PLColors[Value];
end;

procedure TPumpxIcon.SetBounds(aLeft, aTop, aWidth, aHeight: integer);
begin
  if (aHeight <> Height) then
  begin
    case PFMHeight of
      70 : begin
             Labelheight   := 16;
             FrameTop      := 21;
             ButtonHeight  := 20;
           end;
      50 : begin
             Labelheight   := 12;
             FrameTop      := 16;
             ButtonHeight  := 16;
           end;
      else begin
             Labelheight   := 12;
             FrameTop      := 16;
             ButtonHeight  := 16;
             UpdateExceptLog('Unexpected PFMHeight: %d', [PFMHeight]);
           end;
    end;
    ButtonTop     := aHeight - ButtonHeight - 2;
  end;
  if (aWidth <> Width) then
  begin
    LabelWidth    := aWidth - 4;
    Buttonwidth   := aWidth - 4;
  end;
  inherited;
end;

{$IFDEF PUMP_ICON_EXT}

procedure LoadPumpFrames(const InstancePrefix : String);
var
  i : integer;
begin
  for i := 0 to FR_MAX - 1 do
  try
    PumpIconFrames[i] := TBitMap.Create;
    PumpIconFrames[i].LoadFromResourceName(HInstance, Format('%s%3.3d', [InstancePrefix, i]));
  except
    UpdateExceptLog('Cannot load icon frame %s%3.3d', [InstancePrefix, i]);
  end;
end;

procedure CalcPumpFrameMaxSize();
var
  i : integer;
begin
  PFMHeight := 0;
  PFMWidth := 0;
  for i := 0 to FR_MAX - 1 do
    if assigned(PumpIconFrames[i]) then
      with PumpIconFrames[i] do
      begin
        PFMHeight := max(PFMHeight, height);
        PFMWidth  := max(PFMWidth,  width);
      end;
end;

procedure FreePumpFrames();
var
  i : integer;
begin
  for i := 0 to FR_MAX - 1 do
  try
    PumpIconFrames[i].Free;
  except
  end;
end;

initialization
  PFMWidth  := 0;
  PFMHeight := 0;
{$ENDIF}

end.


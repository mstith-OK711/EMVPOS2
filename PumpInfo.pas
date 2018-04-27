{-----------------------------------------------------------------------------
 Unit Name: PumpInfo
 Author:    Gary Whetton
 Date:      4/13/2004 4:18:47 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PumpInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RXCtrls, LatTypes;  //...20080102a

type
  TfmPumpInfo = class(TForm)
    LB: TTextListBox;
    btnExit: TButton;
    btnRefresh: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
    FPumps: TPumpArray;
    procedure SetPumps(const Value: TPumpArray);
  public
    { Public declarations }
    PumpNo : integer;
    procedure LoadLB;
    property Pumps : TPumpArray read FPumps write SetPumps;
  end;

var
  fmPumpInfo: TfmPumpInfo;

implementation

uses
  PumpxIcon,
  PumpLockSup;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmPumpInfo.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpInfo.FormShow(Sender: TObject);
begin
  fmPumpInfo.Caption := 'Pump# ' + IntToStr(PumpNo) + ' Information';
  LoadLB;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpInfo.btnRefreshClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpInfo.btnRefreshClick(Sender: TObject);
begin
  LoadLB;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpInfo.btnExitClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpInfo.btnExitClick(Sender: TObject);
begin
  LB.Clear;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPumpInfo.LoadLB
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPumpInfo.LoadLB;
var
  S : string;
  PI : TPumpxIcon;
begin

  LB.Clear;
  PI := Pumps[PumpNo];

  S := 'Pump On Line - ';
  if PI.PumpOnLine then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'CAT On Line - ';
  if PI.CATOnLine then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  LB.Items.Add('Pump Lock Status: ' + PLEnumToString(PI.PumpLockStatus));

  S := 'Card Type - ' + IntToStr(PI.CardType);
  case PI.CardType of
  0 : ;
  2 : s := S + ' M/C';
  3 : s := S + ' Visa';
  5 : s := S + ' Amex';
  7 : s := S + ' Discover';
  50: s := S + ' Fleet One';
  70: s := S + ' Gift Card';
  else
    s := S + ' Default'
  end;
  LB.Items.Add(s);

  S := 'Help Showing - ';
  if PI.HelpShowing then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'Last Frame - ' + IntToStr(PI.LastFrame);
  LB.Items.Add(s);

  S := 'Last Play State - ';
  if PI.LastPlayState then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'Sound - ' + IntToStr(PI.Sound);
  LB.Items.Add(s);

  S := 'Printer Error - ';
  if PI.PrinterError then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'Paper Low - ';
  if PI.PrinterPaperLow then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'Paper Out - ';
  if PI.PrinterPaperOut then
    s := S + ' True'
  else
    s := S + ' False';
  LB.Items.Add(s);

  S := 'Sale 1 Status - ';
  case PI.Sale1Status of
  1 : s := S + ' Ready'    ;
  2 : s := S + ' Held'     ;
  3 : s := S + ' Paid'     ;
  4 : s := S + ' Reserved' ;
  else
    s := S + IntToStr(PI.Sale1Status);
  end;
  LB.Items.Add(s);

  S := 'Sale 1 Hose - ' + IntToStr(PI.Sale1Hose);
  LB.Items.Add(s);

  S := 'Sale 1 Type - ';
  case PI.Sale1Type of
  1 : s := S + ' Regular'    ;
  2 : s := S + ' Prepay'     ;
  3 : s := S + ' CAT'     ;
  else
    s := S + IntToStr(PI.Sale1Type);
  end;
  LB.Items.Add(s);

  S := 'Sale 1 Amount - ' + CurrToStr(PI.Sale1Amount);
  LB.Items.Add(s);

  S := 'Sale 1 Pre Pay Amount - ' + CurrToStr(PI.Sale1PrePayAmount);
  LB.Items.Add(s);

  S := 'Sale 1 Volume - ' + CurrToStr(PI.Sale1Volume);
  LB.Items.Add(s);

  S := 'Sale 1 Unit Price - ' + CurrToStr(PI.Sale1UnitPrice);
  LB.Items.Add(s);

  S := 'Sale 1 ID - ' + IntToStr(PI.Sale1ID);
  LB.Items.Add(s);

  S := 'Sale 1 Collect Time - ' + DateTimeToStr(PI.Sale1CollectTime);
  LB.Items.Add(s);

  S := 'Sale 2 Status - ';
  case PI.Sale2Status of
  1 : s := S + ' Ready'    ;
  2 : s := S + ' Held'     ;
  3 : s := S + ' Paid'     ;
  4 : s := S + ' Reserved' ;
  else
    s := S + IntToStr(PI.Sale2Status);
  end;
  LB.Items.Add(s);

  S := 'Sale 2 Hose - ' + IntToStr(PI.Sale2Hose);
  LB.Items.Add(s);

  S := 'Sale 2 Type - ';
  case PI.Sale2Type of
  1 : s := S + ' Regular'    ;
  2 : s := S + ' Prepay'     ;
  3 : s := S + ' CAT'     ;
  else
    s := S + IntToStr(PI.Sale2Type);
  end;
  LB.Items.Add(s);

  S := 'Sale 2 Amount - ' + CurrToStr(PI.Sale2Amount);
  LB.Items.Add(s);

  S := 'Sale 2 Pre Pay Amount - ' + CurrToStr(PI.Sale2PrePayAmount);
  LB.Items.Add(s);

  S := 'Sale 2 Volume - ' + CurrToStr(PI.Sale2Volume);
  LB.Items.Add(s);

  S := 'Sale 2 Unit Price - ' + CurrToStr(PI.Sale2UnitPrice);
  LB.Items.Add(s);

  S := 'Sale 2 ID - ' + IntToStr(PI.Sale2ID);
  LB.Items.Add(s);

  S := 'Sale 2 Collect Time - ' + DateTimeToStr(PI.Sale2CollectTime);
  LB.Items.Add(s);

end;

procedure TfmPumpInfo.SetPumps(const Value: TPumpArray);
begin
  FPumps := Value;
end;

end.

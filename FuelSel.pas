{-----------------------------------------------------------------------------
 Unit Name: FuelSel
 Author:    Gary Whetton
 Date:      9/11/2003 3:00:57 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit FuelSel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB,
  StdCtrls, POSMain, Math, ElastFrm;

type
  TfmFuelSelect = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ElasticForm1: TElasticForm;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    PumpNo : short;
    ItemSelected : boolean;

    SaleHose         : array[1..3] of byte;
    SaleType         : array[1..3] of byte;
    SaleAmount       : array[1..3] of currency;
    SalePrePayAmount : array[1..3] of currency;
    SaleVolume       : array[1..3] of currency;
    SaleID           : array[1..3] of integer;
    SaleCollectTime  : array[1..3] of TDateTime;
    SaleName         : array[1..3] of String;
    procedure SetCap( ndx : short; cap : string; btnSaleId : integer);
  end;

var
  fmFuelSelect: TfmFuelSelect;
  KeyBuff: array[0..200] of Char;
  BuffPtr: short;
  SearchOption : TLocateOptions;


implementation

uses POSDM, POSLog;

{$R *.DFM}


{-----------------------------------------------------------------------------
  Name:      TfmFuelSelect.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelSelect.FormShow(Sender: TObject);
var
Idx, Ndx, x : short;
ListRec : string;
SaleIDUnSorted : array[1..3] of integer;
SaleIDSorted : array[1..3] of integer;

begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  try
    with POSDataMod.IBGradeQuery do
      begin

        Close;
        SQL.Clear;
        SQL.Add('SELECT G.Name FROM PumpDef P, Grade G ' +
         'WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And ' +
         'P.GradeNo = G.GradeNo)');
        ParamByName('pPumpNo').AsInteger := fmFuelSelect.PumpNo;
        ParamByName('pHoseNo').AsInteger := SaleHose[1];
        Open;
        if NOT EOF then
          begin
            SaleName[1] := FieldbyName('Name').AsString;
          end;
        Close;

        SQL.Clear;
        SQL.Add('SELECT G.Name FROM PumpDef P, Grade G ' +
         'WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And ' +
         'P.GradeNo = G.GradeNo)');
        ParamByName('pPumpNo').AsInteger := fmFuelSelect.PumpNo;
        ParamByName('pHoseNo').AsInteger := SaleHose[2];
        Open;
        if NOT EOF then
          begin
            SaleName[2] := FieldbyName('Name').AsString;
          end;
        Close;

        SQL.Clear;
        SQL.Add('SELECT G.Name FROM PumpDef P, Grade G ' +
         'WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And ' +
         'P.GradeNo = G.GradeNo)');
        ParamByName('pPumpNo').AsInteger := fmFuelSelect.PumpNo;
        ParamByName('pHoseNo').AsInteger := SaleHose[3];
        Open;
        if NOT EOF then
          begin
            SaleName[3] := FieldbyName('Name').AsString;
          end;
        Close;
      end;
  except
    fmPOS.POSError('Grade Not Found');
    close;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    exit;
  end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  Label1.Caption := 'Pump# ' + IntToStr(PumpNo);

  Button1.Visible := False;
  Button2.Visible := False;
  Button3.Visible := False;

  Button1.Caption := '';
  Button2.Caption := '';
  Button3.Caption := '';

  SaleIDUnSorted[1] := SaleID[1];
  SaleIDUnSorted[2] := SaleID[2];
  SaleIDUnSorted[3] := SaleID[3];

  for Ndx := 3 downto 1 do
    begin
      SaleIDSorted[Ndx] := MaxIntValue(SaleIDUnSorted);
      for x := 1 to 3 do
        if SaleIDSorted[Ndx] = SaleIDUnsorted[x] then
          SaleIDUnsorted[x] := 0;
    end;

  X := 1;
  for Ndx := 1 to 3 do
    begin
      if SaleIDSorted[Ndx] = 0 then
        continue;

      if SaleIDSorted[Ndx] = SaleID[1] then
        Idx := 1
      else if SaleIDSorted[Ndx] = SaleID[2] then
        Idx := 2
      else
        Idx := 3;

      If SalePrepayAmount[Idx] <> 0 Then
        SaleAmount[Idx] := -1*(SalePrepayAmount[Idx] - SaleAmount[Idx]);
      ListRec :=  TimeToStr(SaleCollectTime[Idx]) + '  ' + Format('%-16s',[SaleName[Idx]])
                       + Format('%9s',[(FormatFloat('###,###.00',SaleVolume[Idx]))])
                       + Format('%9s',[(FormatFloat('###,###.00 ;(#,###.00)',SaleAmount[Idx]))]);

      SetCap( x , Listrec, SaleID[Idx]);
      Inc(x);

    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelSelect.SetCap
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ndx : short; cap : string; btnSaleID : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelSelect.SetCap(ndx : short; cap : string; btnSaleID : integer);
begin
      case ndx of
      1:
        begin
          Button1.Caption := cap;
          Button1.Visible := True;
          Button1.Tag := btnSaleID;
        end;
      2:
        begin
          Button2.Caption := cap;
          Button2.Visible := True;
          Button2.Tag := btnSaleID;
        end;
      3:
        begin
          Button3.Caption := cap;
          Button3.Visible := True;
          Button3.Tag := btnSaleID;
        end;
      end;


end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelSelect.Button1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelSelect.Button1Click(Sender: TObject);
begin

  fmPOS.nSelectedSaleID := Button1.Tag;
  fmPOS.nSelectedPumpNo := PumpNo;
  ItemSelected := True;
  close;

end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelSelect.Button2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelSelect.Button2Click(Sender: TObject);
begin
  fmPOS.nSelectedSaleID := Button2.Tag;
  fmPOS.nSelectedPumpNo := PumpNo;
  ItemSelected := True;
  close;

end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelSelect.Button3Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelSelect.Button3Click(Sender: TObject);
begin

  fmPOS.nSelectedSaleID := Button3.Tag;
  fmPOS.nSelectedPumpNo := PumpNo;
  ItemSelected := True;
  close;

end;

end.

unit ViewGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ElastFrm, RXCtrls, Grids;

type
  TfmViewGrid = class(TForm)
    SG: TStringGrid;
    btnClose: TRxSpeedButton;
    ElasticForm1: TElasticForm;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GridFileName : string;
    procedure ParseRec;
    procedure FindNextComma;
  end;

var
  fmViewGrid: TfmViewGrid;

  TF : TextFile;
  TFRec : string;

  FldNdx: integer;
  StartPtr, CurPtr, LastPtr, MaxPtr: integer;
  StartPos: integer;
  Fld:array[1..75] of string;
  MaxNdx : short;

implementation

{$R *.DFM}

procedure TfmViewGrid.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  SG.ColCount := 0;
  SG.RowCount := 0;

end;

procedure TfmViewGrid.FormShow(Sender: TObject);
var
FirstRec : boolean;
RecCount : short;
begin

  SG.ColCount := 0;
  SG.RowCount := 0;

  SG.RowCount   := 50;
  SG.FixedRows  := 1;

  MaxNdx := 0;

  if FileExists(GridFileName) then
    begin
      assignfile(TF, GridFileName);
      reset(TF);
      FirstRec := True;
      RecCount := 0;
      while not eof(TF) do
        begin
          readln(TF, TFRec);
          Inc(RecCount);
          if RecCount >= SG.RowCount then
            SG.RowCount := SG.RowCount + 50;
          ParseRec;
          if FirstRec then
            SG.ColCount := MaxNdx;
          for FldNdx := 1 to MaxNdx do
            SG.Cells[Pred(FldNdx), Pred(RecCount)] := Fld[FldNdx];
        end;
      CloseFile(TF);
    end;

end;


procedure TfmViewGrid.ParseRec;
begin

  for FldNdx := 1 to 75 do
    Fld[FldNdx] := '';

  FldNdx := 1;
  StartPtr := 1;
  MaxPtr := ( Length(TFRec) - 1 );
  LastPtr := 1;
  StartPos := 1;

  for FldNdx := 1 to 75 do
    begin
      FindNextComma;
      Fld[FldNdx] := Copy(TFRec,StartPos,(CurPtr - LastPtr));
      StartPos := CurPtr + 1;
      LastPtr := CurPtr + 1;
      StartPtr := CurPtr +1;
      if CurPtr >= MaxPtr then
        break;
    end;

  if MaxNdx = 0 then
    MaxNdx := FldNdx;


end;

procedure TfmViewGrid.FindNextComma;
begin

  for CurPtr := StartPtr to MaxPtr do
    begin
      if (TFRec[CurPtr] = ',') then
        break;
    end;
  if (CurPtr > MaxPtr) then
    if TFRec[CurPtr] <> ',' then  // incase there is no comma after the last element
      CurPtr := MaxPtr + 2;

end;
















end.

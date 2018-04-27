unit pluload;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, DB, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    PLUTable: TTable;
    PLUTableNumber: TBCDField;
    PLUTableUPC: TBCDField;
    PLUTableName: TStringField;
    PLUTableDeptLink: TSmallintField;
    PLUTablePrice: TCurrencyField;
    PLUTableOnHand: TFloatField;
    PLUTableTax1: TBooleanField;
    PLUTableTax2: TBooleanField;
    PLUTableTax3: TBooleanField;
    PLUTableTax4: TBooleanField;
    PLUTableTax5: TBooleanField;
    PLUTableTax6: TBooleanField;
    PLUTableDisc: TBooleanField;
    PLUTableDlyCount: TFloatField;
    PLUTableDlyCost: TFloatField;
    PLUTableDlySales: TFloatField;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ParseRec;
    procedure FindNextComma;
  end;

var
  Form1: TForm1;

  TF : TextFile;
  TFRec : string;

  FldNdx: integer;
  StartPtr, CurPtr, LastPtr, MaxPtr: integer;
  StartPos: integer;
  Fld:array[1..20] of string;

  EBYDept : integer;


implementation

{$R *.DFM}


procedure TForm1.BitBtn1Click(Sender: TObject);
begin


  PLUTable.Active := True;
  AssignFile(TF, 'CLRK2378.TXT');
  {$I-}
  Reset(TF);
  {$I+}
  if IOResult = 0 then
    begin
      while NOT EOF(TF) do
        begin
          Readln(TF, TFRec);
          ParseRec;
          Label1.Caption := fld[2];
          Label1.Refresh;
          with PLUTable do
            begin
              Insert;
              FieldByName('Number').Value              := Fld[1];
              FieldByName('Name').Value                := Fld[2];
              FieldByName('UPC').Value                 := Fld[3];
              FieldByName('Price').Value               := Fld[7];

              FieldByName('Tax1').AsBoolean  := False ;
              FieldByName('Tax2').AsBoolean  := False ;
              FieldByName('Tax3').AsBoolean  := False ;
              FieldByName('Tax4').AsBoolean  := False ;
              FieldByName('Tax5').AsBoolean  := False ;
              FieldByName('Tax6').AsBoolean  := False ;
              FieldByName('Disc').AsBoolean  := True ;

              EBYDept := StrToInt(Fld[10]);

              case EBYDept of
              1,2,3,4,31,38,75,91,94,95,96 :
                 begin
                   FieldByName('DeptLink').Value  := 1  ;
                   FieldByName('Tax1').AsBoolean  := True  ;
                 end;
              46,48,72,86 :
                 begin
                   FieldByName('DeptLink').Value  := 5  ;
                   FieldByName('Tax1').AsBoolean  := True  ;
                 end;
              13,47,57,58 :
                 begin
                   FieldByName('DeptLink').Value  := 7  ;
                   FieldByName('Tax2').AsBoolean  := True  ;
                 end;
              5,6,7,8,9,10,11,12,15,16,19,20,27,34,35,36,37,52,53,73,74,76,78,79,80,81,82,83,84 :
                 begin
                   FieldByName('DeptLink').Value  := 11  ;
                   FieldByName('Tax1').AsBoolean  := True  ;
                 end;
              17,18,21,44,55,56 :
                 begin
                   FieldByName('DeptLink').Value  := 12  ;
                   FieldByName('Tax1').AsBoolean  := True  ;
                 end;
              else
                 begin
                   FieldByName('DeptLink').Value  := 6  ;
                   FieldByName('Tax1').AsBoolean  := True  ;
                 end;


              end;
              try
                Post;
              except
                cancel;
              end;

            end;
        end;                       {end while not eof}
      CloseFile(TF);
      PLUTable.Active := False;

    end;                           { end io result }

end;

procedure TForm1.ParseRec;
begin

  FldNdx := 1;
  StartPtr := 1;
  MaxPtr := ( Length(TFRec) - 1 );
  LastPtr := 1;
  StartPos := 1;

  for FldNdx := 1 to 20 do
    begin
      FindNextComma;
      Fld[FldNdx] := Copy(TFRec,StartPos,(CurPtr - LastPtr));
      StartPos := CurPtr + 1;
      LastPtr := CurPtr + 1;
      StartPtr := CurPtr +1;
    end;

end;

procedure TForm1.FindNextComma;
begin

  for CurPtr := StartPtr to MaxPtr do
    begin
      if TFRec[CurPtr] = ',' then
        break;
    end;

end;





end.

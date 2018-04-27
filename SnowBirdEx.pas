
{-----------------------------------------------------------------------------
 Unit Name: SnowBirdEx
 Author:    Ron Payne
 Date:      2005/09/27
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit SnowBirdEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, POSDM, DB, FileCtrl;

procedure CreateSnowBirdExportFile (TerminalNo, ShiftNo : Integer; OpName : String);

implementation

uses POSMain, POSMsg, ExceptLog;

//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------
{-----------------------------------------------------------------------------
  Name:      CreateSnowBirdExportFile
  Author:    Ron Payne
  Date:      2005/09/27
  Arguments: TerminalNo, ShiftNo : Integer; OpName : String
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CreateSnowBirdExportFile (TerminalNo, ShiftNo : Integer; OpName : String);
const
  cDel: Char = ',';
  MAX_FUEL_GRADE = 10;
var
  sFname            : String;
  sPriceFname       : string;
  sFileFolder       : string;
  sFilePath         : string;
  TF                : TextFile;
//  nFuelTotalID      : Integer;
//  OpenDate          : TDateTime;
//  Year, Month, Day  : Word;

//  aHTls             : array[1..20, 1..2] of Currency;
//  aGTls             : array[1..20, 1..2] of Currency;
//  aPTls             : array[1..20, 1..2] of Currency;

//  nHIdx           : Integer;
//  nPct            : double;

//  nStartBatchID    : integer;

//  ShiftZCount : integer;
  BusDate : tdatetime;

//  nDeclinedSum : Double;
//  nDeclinedCount : Integer;

  EODStartDate : TDateTime;
  EODEndDate : TDateTime;
  FuelVolume : array [1..MAX_FUEL_GRADE] of double;
  FuelAmount : array [1..MAX_FUEL_GRADE] of double;
  iGrade : integer;
  MaxPumpNo : integer;
  MaxPumpUsed : integer;
  iPumpNo : integer;
  j : integer;
begin

//  DecodeDate(Now, Year, Month, Day);


  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
//20060712...
//  with POSDataMod.IBTempQuery do
//  begin
//    Close;SQL.Clear;
//    SQL.Add('Select MAX(OpenDate) OpenDate From Totals');
//    SQL.Add('Where ShiftNo = ' + IntToStr(ShiftNo));
//    if TerminalNo > 0 then
//      SQL.Add('And TerminalNo = ' + IntToStr(TerminalNo));
//    Open;
//    BusDate := FieldByName('OpenDate').AsDateTime;
//    Close;
//  sFname := '\SBS' + Format('%1.1d',[ ShiftNo ]) +
//                   Format('%2.2d',[ TerminalNo ]) +
//                   FormatDateTime('yyyymmdd', BusDate) + '.exp';
//  sPriceFname := '\SBP' + Format('%1.1d',[ ShiftNo ]) +
//                   Format('%2.2d',[ TerminalNo ]) +
//                   FormatDateTime('yyyymmdd', BusDate) + '.exp';
//  end;
  BusDate := Now();
  sFname := '\SBS101' +   // always encode file name for shift #1 / terminal #1
                   FormatDateTime('yyyymmdd', BusDate) + '.exp';
  sPriceFname := '\SBP101' +  // always encode file name for shift #1 / terminal #1
                   FormatDateTime('yyyymmdd', BusDate) + '.exp';
  //...20060712
  // ShiftNo = 0  : End of Day file
  // ShiftNo <> 0 : End of Shift file

  //----------------------------------------------------------------------------
  // Determine the path for the export file

  if (EODExportPath = '') then
  begin
     { No export Path specified, we copy the files in the EXE path }
    sFileFolder := '\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude'
  end
  else
  begin
    { If necessary create the data directory }
    if (not(DirectoryExists(EODExportPath))) then
    begin
      MkDir(EODExportPath);
      if IOResult <> 0 then  { Create Error }
        sFileFolder := ExtractFileDir(Application.ExeName)
      else                   { Everything O.K. }
        sFileFolder := EODExportPath
    end
    else
    begin
      sFileFolder := EODExportPath;
    end;
  end;


  // **************** Fuel Price File *********************************
  sFilePath := sFileFolder + sPriceFname;
  AssignFile(TF, sFilePath);
  ReWrite(TF);
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    try
      Close();
      SQL.Clear();
      SQL.Add('select * from grade order by GradeNo');
      open();
      while (not EOF) do
      begin
        iGrade := FieldByName('GradeNo').AsInteger;
        WriteLn(TF, Format(',1,%1.1d,%8.3f', [iGrade, FieldByName('CashPrice').AsCurrency]));
        Next();
      end;  //while
    except
      UpdateExceptLog('SnowBirdEx - Error fuel prices from Grade.');
    end;
  end;  // with
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

  System.CloseFile(TF);

  // **************** Fuel Sales File *********************************

  sFilePath := sFileFolder + sFname;

  AssignFile(TF, sFilePath);
//  if FileExists(sFilePath) then
//    Append(TF)
//  else
    ReWrite(TF);

  EODStartDate := 0.0;  // To be set from DB below.
  EODEndDate := Now();


  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close();
    SQL.Clear();
    SQL.Add('Select * From Totals Where TotalNo = 0'  );
    open();
    if (RecordCount > 0) then
    begin
      EODStartDate := FieldByName('OpenDate').AsDateTime;
    end;
    close();
    SQL.Clear();
    SQL.Add('Select max(PumpNo) as MaxPumpNo from PumpDef'  );
    open();
    if (RecordCount > 0) then MaxPumpNo := FieldByName('MaxPumpNo').AsInteger
                         else MaxPumpNo := 0;
    close();
    SQL.Clear();
    SQL.Add('Select max(PumpNo) as MaxPumpUsed from FuelTran'  );
    open();
    if (RecordCount > 0) then MaxPumpUsed := FieldByName('MaxPumpUsed').AsInteger
                         else MaxPumpUsed := 0;
    close();
    if (MaxPumpUsed > MaxPumpNo) then
      MaxPumpNo := MaxPumpUsed;            // Should not happen (but just to make sure all sales are represented).
    if (EODStartDate > 0.0) then
    begin

      //Write header for sales file
      WriteLn(TF, ',head,' + FormatDateTime('mmddyyhhnnss', EODStartDate) +
                       ',' + FormatDateTime('mmddyyhhnnss', EODEndDate));

      // Write Sales records
      for iPumpNo := 1 to MaxPumpNo do
      begin
        for j := Low(FuelVolume) to High(FuelVolume) do
        begin
          FuelVolume[j] := 0.0;
          FuelAmount[j] := 0.0;
        end;
        try
          SQL.Clear();
          SQL.Add('select sum(Volume) as PumpVolume, sum(Amount) as PumpAmount, p.GradeNo');
          SQL.Add(' from FuelTran f, PumpDef p where f.PumpNo = p.PumpNo and f.HoseNo = p.HoseNo');
          SQL.Add('   and f.PumpNo = :pPumpNo and f.Completed=1');
          SQL.Add('   and f.CollectTime >= :pStart and f.CollectTime < :pEnd');
          SQL.Add(' group by p.gradeno');
          ParamByName('pPumpNo').AsInteger := iPumpNo;
          ParamByName('pStart').AsDateTime := EODStartDate;
          ParamByName('pEnd').AsDateTime   := EODEndDate;
          open();
          while (not EOF) do
          begin
            iGrade := FieldByName('gradeno').AsInteger;
            if ((iGrade >= Low(FuelVolume)) and (iGrade <= High(FuelVolume))) then
            begin
              FuelVolume[iGrade] := FuelVolume[iGrade] + FieldByName('PumpVolume').AsCurrency;
              FuelAmount[iGrade] := FuelAmount[iGrade] + FieldByName('PumpAmount').AsCurrency;  //20060612 - change FuelVolume to FuelAmount
            end
            else
            begin
              UpdateExceptLog('SnowBirdEx - Invalid Fuel Grade: ' + IntToStr(iGrade));
            end;
            Next();
          end;  //while
        except
          UpdateExceptLog('SnowBirdEx - Error extracting fuel totals from FuelTran. PumpNo: ' + IntToStr(iPumpNo));
        end;
        for iGrade := Low(FuelVolume) to High(FuelVolume) do
        begin
          if ((iGrade <= 3) or (FuelVolume[iGrade] > 0.0)) then
          begin
            WriteLn(TF, Format(',uhoset,%d,%1.1d,%8.3f,%8.3f', [iPumpNo, iGrade, FuelVolume[iGrade], FuelAmount[iGrade]]));
          end;
        end;  // for iGrade := ...
      end;  // for iPumpNo :=


      // Write pump meter records
      for iPumpNo := 1 to MaxPumpNo do
      begin
        for j := Low(FuelVolume) to High(FuelVolume) do
        begin
          FuelVolume[j] := 0.0;
          FuelAmount[j] := 0.0;
        end;
        try
          SQL.Clear();
          SQL.Add('select max(VolumeTL) as PumpVolume, max(CashTL) as PumpCashAmount, max(CreditTL) as PumpCreditAmount, p.GradeNo');
          SQL.Add(' from PumpTls t, PumpDef p where t.PumpNo = p.PumpNo and t.HoseNo = p.HoseNo');
          SQL.Add('   and t.PumpNo = :pPumpNo');
          SQL.Add('   and t.DateTimeRead >= :pStart and t.DateTimeRead < :pEnd');
          SQL.Add(' group by p.gradeno');
          ParamByName('pPumpNo').AsInteger := iPumpNo;
          ParamByName('pStart').AsDateTime := EODStartDate;
          ParamByName('pEnd').AsDateTime   := EODEndDate;
          open();
          while Not EOF do
          begin
            iGrade := FieldByName('GradeNo').AsInteger;
            if ((iGrade >= Low(FuelVolume)) and (iGrade <= High(FuelVolume))) then
            begin
              FuelVolume[iGrade] := FieldByName('PumpVolume').AsCurrency;
              FuelAmount[iGrade] := FieldByName('PumpCashAmount').AsCurrency + FieldByName('PumpCreditAmount').AsCurrency;
            end
            else
            begin
              UpdateExceptLog('SnowBirdEx - Invalid Fuel Grade: ' + IntToStr(iGrade));
            end;
            Next();
          end;  //while
        except
          UpdateExceptLog('SnowBirdEx - Error extracting meter totals from PumpTls. PumpNo: ' + IntToStr(iPumpNo));
        end;
        for iGrade := Low(FuelVolume) to High(FuelVolume) do
        begin
          if (FuelVolume[iGrade] > 0.0) then
          begin
            WriteLn(TF, Format(',rhoset,%d,%1.1d,%8.3f,%8.3f', [iPumpNo, iGrade, FuelVolume[iGrade], FuelAmount[iGrade]]));
          end;
        end;  // for iGrade := ...
      end;  // for iPumpNo :=
    end
    else
    begin
      UpdateExceptLog('SnowBirdEx - No record in Totals with TotalNo=0');
    end; // if (EODStartDate > 0.0)
  end;  // with

  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

  System.CloseFile(TF);

end; {end procedure CreateSnowBirdExportFile}

end.

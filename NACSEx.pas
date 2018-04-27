{-----------------------------------------------------------------------------
 Unit Name: NACSEx
 Author:    Gary Whetton
 Date:      9/11/2003 3:05:52 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}


unit NACSEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, POSDM, DB, FileCtrl;

procedure CreateNACSExportFile (ShiftNo : Integer; OpName : String);

implementation

uses POSMain, POSMsg;

//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    CreateNACSExportFile                                         |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   OpName, ShiftNo                                              |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      EODExportPath, IBTempQuery, nShiftNo, POSDataMod             |
|                                                                            |
| LOCALS:       aGTls, aHTls, aPTls, cDel, Day, Month, nCurPump,             |
|               nFuelTotalID, nHIdx, nPct, OpenDate, sFname, sLn, TF, Year   |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure CreateNACSExportFile (ShiftNo : Integer; OpName : String);
const
  cDel: Char = ',';
var
  sFname           : String;
  TF               : TextFile;
  nFuelTotalID     : Integer;
  OpenDate         : TDateTime;
  Year, Month, Day : Word;


  aHTls    : array[1..20,1..2] of Currency;
  aGTls   : array[1..20,1..2] of Currency;
  aPTls : array[1..20,1..2] of Currency;

  nHIdx : Integer;
  nPct : double;


 begin
  DecodeDate(Now, Year, Month, Day);

  sFname := '\Latitude.exp';

  // ShiftNo = 0  : End of Day file
  // ShiftNo <> 0 : End of Shift file

  //----------------------------------------------------------------------------
  { We load the data path from the Database }
  If EODExportPath = '' Then
     { No export Path specified, we copy the files in the EXE path }
    sFname := ExtractFileDir(Application.ExeName) + sFname
  Else
    Begin
     { We check and if necessary create the data directory }
      if Not(DirectoryExists(EODExportPath)) then
        Begin
          MkDir(EODExportPath);
          if IOResult <> 0 then  { Create Error }
            sFname := ExtractFileDir(Application.ExeName) + sFname
          else                   { Everything O.K. }
            sFname := EODExportPath + sFname;
        end
      Else
        sFname := EODExportPath + sFname ;
    End;

  AssignFile(TF, sFname);
  if FileExists(sFName) then
    Append(TF)
  else
    ReWrite(TF);

//  If ShiftNo <> 0 Then  // We include the operator name in the End of Shift file
//    Begin
//      WriteLn(TF, 'Operator = ' + POSMain.CurrentUser);
//    End;

   with POSDataMod.IBTempQuery do
     begin
       if ShiftNo <> 0 then
         WriteLn( TF, '"EOS",' + InttoStr(ShiftNo) + ',' +
           '"' + FormatDateTime('yyyymmdd', Now) + '"' + cDel +
           '"' + FormatDateTime('hh:mm', Now ) + '"')
       else
         WriteLn( TF, '"EOD",' +
           '"' + FormatDateTime('yyyymmdd', Now) + '"' + cDel +
           '"' + FormatDateTime('hh:mm', Now ) + '"');

       Close; SQL.Clear;
       SQL.Add('Select * From Totals Where TotalNo = 0'  );
       Open;
       OpenDate := FieldByName('OpenDate').AsDateTime;

       { First we write the times for the whole day... }

       if RecordCount > 0 Then
         begin
         // Header Record
           WriteLn( TF,
             '"DAYOPEN","' + FormatDateTime('yyyymmdd', OpenDate) + '"' + cDel +
             '"' + FormatDateTime('hh:mm', OpenDate) + '"' );
         end;
       Close;

       If ShiftNo <> 0 Then  // We include a Shift Start and End in the End of Shift file
         Begin
           SQL.Clear;
           SQL.Add('Select * From Totals Where TotalNo = ' + IntToStr(ShiftNo) );
           Open;
           OpenDate := FieldByName('OpenDate').AsDateTime;
           { Now we write the times for the current Shift... }
           if RecordCount > 0 Then
             begin
             // Header Record
               WriteLn( TF,
                 '"SHIFTOPEN","' + FormatDateTime('yyyymmdd', OpenDate) + '"' + cDel +
                 '"' + FormatDateTime('hh:mm', OpenDate) + '"' + cDel + IntToStr(ShiftNo) );
             end;
         End;
       Close;
     end;

  // *** Store Totals ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select * ');
        If ShiftNo > 0 Then
          SQL.Add('From Totals Where TotalNo = ' + IntToStr(ShiftNo))
        Else
          SQL.Add('From Totals Where TotalNo = 0');
      Open;

      // Write Reset Count
      WriteLn(TF,
        '"ZCOUNT"' + cDel +
        FieldByName('ResetCount').AsString );

      // Write Current GT
      WriteLn(TF,
        '"CURGT"' + cDel +
        FormatFloat('#.00', FieldByName('CurGT').AsCurrency) );

      // Write Beginning GT
      WriteLn(TF,
        '"BEGGT"' + cDel +
        FormatFloat('#.00', FieldByName('BegGT').AsCurrency) );

      // Write Total Daily Sales
      WriteLn(TF,
        '"DLYSLS"' + cDel +
        FormatFloat('#.00', FieldByName('DlyDS').AsCurrency) );

      // Write Net Daily Sales
      WriteLn(TF,
        '"NETSLS"' + cDel +
        FormatFloat('#.00', FieldByName('DlyND').AsCurrency) );

      // Write Prepay Received
      WriteLn(TF,
        '"PPYRCVD"' + cDel +
        FieldByName('DlyPrePayCount').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyPrePayRcvd').AsCurrency) );

      // Write Prepay Used
      WriteLn(TF,
        '"PPYUSED"' + cDel +
        FieldByName('DlyPrePayCountUsed').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyPrePayUsed').AsCurrency) );

      // Write Prepay Refund
      WriteLn(TF,
        '"PPYRFND"' + cDel +
        FieldByName('DlyPrePayRfndCount').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyPrePayRfnd').AsCurrency) );

      // Write Transaction Count
      WriteLn(TF,
        '"TRANS"' + cDel +
        FieldByName('DlyTransCount').AsString );

      // Write Item Count
      WriteLn(TF,
        '"ITEMS"' + cDel +
        FieldByName('DlyItemCount').AsString );

      // Write NoSale Count
      WriteLn(TF,
        '"NOSALE"' + cDel +
        FieldByName('DlyNoSaleCount').AsString );

      // Write Voids
      WriteLn(TF,
        '"VOID"' + cDel +
        FieldByName('DlyVoidCount').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyVoidAmount').AsCurrency) );

      // Write Return
      WriteLn(TF,
        '"RETURN"' + cDel +
        FieldByName('DlyRtrnCount').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyRtrnAmount').AsCurrency) );

      // Write Cancel
      WriteLn(TF,
        '"CANCEL"' + cDel +
        FieldByName('DlyCancelCount').AsString + cDel +
        FormatFloat('#.00', FieldByName('DlyCancelAmount').AsCurrency) );

      // Write Return Tax
      WriteLn(TF,
        '"RTRNTAX"' + cDel +
        FormatFloat('#.00', FieldByName('DlyReturnTax').AsCurrency) );

      // Write Non Tax
      WriteLn(TF,
        '"NONTAX"' + cDel +
        FormatFloat('#.00', FieldByName('DlyNoTax').AsCurrency) );

       Close;
    end;

  // *** Sales Tax ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('SELECT TS.TaxNo, Sum(TS.DlyCount) DlyCount, ' +
       'Sum(TS.DlyTaxableSales) DlyTaxableSales, Min(T.Name) Name,' +
       'Sum(TS.DlyTaxCharged) DlyTaxCharged, Min(T.Rate) Rate FROM TaxShift TS, Tax T ' +
       'WHERE (TS.TaxNo = T.TaxNo)');
      if ShiftNo > 0 then
        SQL.Add('And (TS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY TS.TaxNo');
      SQL.Add('ORDER BY TS.TaxNo');

      Open;
      while Not EOF do
        begin
          if FieldByName('DlyCount').AsInteger > 0 then
            begin
              WriteLn(TF,
               '"TAX"' + cDel +
               FieldByName('TaxNo').AsString + cDel +
               FieldByName('Rate').AsString + cDel +
               FormatFloat('#.00', FieldByName('DlyTaxableSales').AsCurrency) + cDel +
               FormatFloat('#.00', FieldByName('DlyTaxCharged').AsCurrency) );
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end;

    // *** Discounts ***
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT DS.DiscNo, Sum(DS.DlyCount) DlyCount, ' +
       'Sum(DS.DlyAmount) DlyAmount, Min(D.Name) Name FROM DiscShift DS, Disc D ' +
       'WHERE (DS.DiscNo = D.DiscNo)');
      if ShiftNo > 0 then
        SQL.Add('And (DS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY DS.DiscNo');
      SQL.Add('ORDER BY DS.DiscNo');
      Open;
      while Not EOF do
        begin
          if FieldByName('DlyCount').AsInteger > 0 then
            begin
              WriteLn(TF,
               '"DISC"' + cDel +
               FieldByName('DiscNo').AsString + cDel +
               FieldByName('DlyCount').AsString + cDel +
               FormatFloat('#.00', FieldByName('DlyAmount').AsCurrency) );
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end; {with TempQuery}

    // *** Mix Match Totals ***
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT MS.MMNo, Sum(MS.DlyCount) DlyCount, ' +
       'Sum(MS.DlyAmount) DlyAmount, Min(MM.Name) Name FROM MixMatchShift MS, MixMatch MM ' +
       'WHERE (MS.MMNo = MM.MMNo)');
      if ShiftNo > 0 then
        SQL.Add('And (MS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY MS.MMNo');
      SQL.Add('ORDER BY MS.MMNo');

      Open;
      while Not EOF do
        begin
          if FieldByName('DlyCount').AsInteger > 0 then
            begin
              WriteLn(TF,
               '"MIXMATCH"' + cDel +
               FieldByName('MMNo').AsString + cDel +
               FieldByName('DlyCount').AsString + cDel +
               FormatFloat('#.00', FieldByName('DlyAmount').AsCurrency) );
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end; {with TempQuery}

  // *** Dept Records ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select DS.DeptNo, Sum(DS.DlyCount) DlyCount, ' +
       'Sum(DS.DlySales) DlySales, Min(D.Name) Name, Min(D.GrpNo) GroupNo ' +
       'From DepShift DS Inner Join Dept D On (DS.DeptNo = D.DeptNo) ' +
       'Where DS.DlyCount <> 0 ');
      If ShiftNo > 0 Then
        SQL.Add('Where DS.ShiftNo  = ' + IntToStr(ShiftNo) + ' ');
      SQL.Add('Group By DS.DeptNo ');
      SQL.Add('Order By DS.DeptNo');
      Open;

      while Not EOF do
        begin
          WriteLn(TF,
           '"DPT"' + cDel +
           FieldByName('DeptNo').AsString + cDel +
           '"' + Trim(FieldByName('Name').AsString) + '"' + cDel +
           FormatFloat('#.####', FieldByName('DlyCount').AsCurrency) + cDel +
           FormatFloat('#.00', FieldByName('DlySales').AsCurrency) + cDel +
           FieldByName('GroupNo').AsString );
          Next;
        end;
      Close;
    end; {with TempQuery - Dept}


  // *** Plu Records ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select PS.PluNo, Sum(PS.DlyCount) DlyCount, ' +
       'Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(P.DeptNo) DptNo ' +
       'From PluShift PS Inner Join Plu P On (PS.PluNo = P.PluNo) ' +
       'Where PS.DlyCount <> 0  ');
      If ShiftNo > 0 Then
        SQL.Add('And PS.ShiftNo  = ' + IntToStr(ShiftNo) + ' ');
      SQL.Add('Group By PS.PluNo ');
      SQL.Add('Order By PS.PluNo');
      Open;

      while Not EOF do
        begin
          WriteLn(TF,
           '"PLU"' + cDel +
           FieldByName('PluNo').AsString + cDel +
           '"' + Trim(FieldByName('Name').AsString) + '"' + cDel +
           FormatFloat('#.##', FieldByName('DlyCount').AsCurrency) + cDel +
           FormatFloat('#.00', FieldByName('DlySales').AsCurrency) + cDel +
           FieldByName('DptNo').AsString);
          Next;
        end;
      Close;
    end; {with TempQuery - PLU}

  // *** Media Records ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select MS.MediaNo, Sum(MS.DlyCount) DlyCount, ' +
       'Sum(MS.DlySales) DlySales, Min(M.Name) Name ' +
       'From MedShift MS Inner Join Media M On (MS.MediaNo = M.MediaNo) ');
      If ShiftNo > 0 Then
        SQL.Add('Where MS.ShiftNo  = ' + IntToStr(ShiftNo) + ' ');
      SQL.Add('Group By MS.MediaNo ');
      SQL.Add('Order By MS.MediaNo');
      Open;

      while Not EOF do
        begin
          WriteLn(TF,
           '"MED"' + cDel +
           FieldByName('MediaNo').AsString + cDel +
           '"' + Trim(FieldByName('Name').AsString) + '"' + cDel +
           FieldByName('DlyCount').AsString + cDel +
           FormatFloat('#.00', FieldByName('DlySales').AsCurrency) );
          Next;
        end;
      Close;
    end; {with TempQuery - Media}

  // *** Bank Function Records ***
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select BS.BankNo, Sum(BS.DlyCount) DlyCount, ' +
       'Sum(BS.DlySales) DlySales, Min(B.Name) Name ' +
       'From BankShift BS Inner Join BankFunc B On (BS.BankNo = B.BankNo) ');
      If ShiftNo > 0 Then
        SQL.Add('Where BS.ShiftNo  = ' + IntToStr(ShiftNo) + ' ');
      SQL.Add('Group By BS.BankNo ');
      SQL.Add('Order By BS.BankNo');
      Open;

      while Not EOF do
        begin
          WriteLn(TF,
           '"BFN"' + cDel +
           FieldByName('BankNo').AsString + cDel +
           '"' + Trim(FieldByName('Name').AsString) + '"' + cDel +
           FieldByName('DlyCount').AsString + cDel +
           FormatFloat('#.00', FieldByName('DlySales').AsCurrency) );
          Next;
        end;
      Close;
    end; {with TempQuery - Bank}


  for nHIdx := 1 to 20 do
    begin
      aHTls[nHIdx,1] := 0;
      aHTls[nHIdx,2] := 0;
      aGTls[nHIdx,1] := 0;
      aGTls[nHIdx,2] := 0;
      aPTls[nHIdx,1] := 0;
      aPTls[nHIdx,2] := 0;
    end;

  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      // Get Last Fuel Totals (TlNo)
      SQL.Add('SELECT Max(TlNo) FROM PumpTls');
      Open;
      nFuelTotalID := Fields[0].AsInteger;
      Close; SQL.Clear;
    end;
  // **** Get Fuel Totals ****
  with POSDataMod.IBTempQuery do
    begin
      // Build SQL Statement
      SQL.Clear;
      SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
      SQL.Add('WHERE (T.TlNo = ' + IntToStr(nFuelTotalID) + ') ' );
      SQL.Add('AND (T.PumpNo = D.PumpNo) AND (T.HoseNo = D.HoseNo) ');
      SQL.Add('AND (D.GradeNo = G.GradeNo) ');
      SQL.Add('ORDER BY T.PumpNo, T.HoseNo');
      Open;

      while not EOF do {Begin Processing Query}
        begin
          WriteLn(TF,
           '"PUMPTLS"' + cDel +
           FieldByName('PumpNo').AsString + cDel +
           FieldByName('HoseNo').AsString + cDel +
           '"' + FormatDateTime('yyyymmdd', FieldByName('DateTimeRead').AsDateTime) + '"' + cDel +
           '"' + FormatDateTime('hh:mm',FieldByName('DateTimeRead').AsDateTime) + '"' + cDel +
           FormatFloat('#.0000', FieldByName('VolumeTl').AsCurrency) + cDel +
           FormatFloat('#.00', ( FieldByName('CashTl').AsCurrency + FieldByName('CreditTl').AsCurrency)) );

          nHIdx := FieldByName('HoseNo').AsInteger;
          aHTls[nHIdx,1] := aHTls[nHIdx,1] + FieldByName('VolumeTl').AsCurrency;
          aHTls[nHIdx,2] := aHTls[nHIdx,2] + FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency;

          nHIdx := FieldByName('GradeNo').AsInteger;
          if (nHIdx > 0) and (nHIdx < 21) then
            begin
              aGTls[nHIdx,1] := aGTls[nHIdx,1] + FieldByName('VolumeTl').AsCurrency;
              aGTls[nHIdx,2] := aGTls[nHIdx,2] + FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency;
            end;

          nHIdx := FieldByName('ProdNo1').AsInteger;
          nPct  := (FieldByName('Pct1').AsCurrency / 100);
          if (nHIdx > 0) and (nHIdx < 21) and ( nPct > 0 ) then
            begin
              aPTls[nHIdx,1] := aPTls[nHIdx,1] + (FieldByName('VolumeTl').AsCurrency * nPct);
              aPTls[nHIdx,2] := aPTls[nHIdx,2] +
               ((FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency) * nPct);
            end;

          nHIdx := FieldByName('ProdNo2').AsInteger;
          nPct  := (FieldByName('Pct2').AsCurrency / 100);
          if (nHIdx > 0) and (nHIdx < 21) and ( nPct > 0 ) then
            begin
              aPTls[nHIdx,1] := aPTls[nHIdx,1] + (FieldByName('VolumeTl').AsCurrency * nPct);
              aPTls[nHIdx,2] := aPTls[nHIdx,2] +
               ((FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency) * nPct);
            end;

          Next;
        end; {while not EOF}
      Close;

      // **** Hose Totals ****
      for nHIdx := 1 to 10 do
        if (aHTls[nHIdx, 1] > 0) then         // Volume > 0
          begin
            WriteLn(TF,
             '"HOSETLS"' + cDel +
             IntToStr(nHIdx)  + cDel +
             FloatToStr(aHTls[nHIdx,1]) + cDel +   // Volume
             FloatToStr(aHTls[nHIdx,2]) );         //Amount
          end;

      // Build SQL Statement
      SQL.Clear;
      SQL.Add('SELECT * FROM Grade ');
      SQL.Add(' ORDER BY GradeNo');
      Open;

      while not EOF do {Begin Processing Query}
        begin
          nHIdx := FieldByName('GradeNo').AsInteger;
          if (nHIdx > 0) and (nHIdx < 21) then
            begin
              WriteLn(TF,
               '"GRADETLS"' + cDel +
               IntToStr(nHIdx)  + cDel +           // GradeNumber
               '"' + FieldByName('Name').AsString + '",' +        //GradeName
                FormatFloat('#.0000', (aGTls[nHIdx,1])) + cDel +          //Volume
                FormatFloat('#.00', (aGTls[nHIdx,2])) );                //Amount
            end;
          Next;
        end; {while not EOF}
      Close;

      // Build SQL Statement
      SQL.Clear;
      SQL.Add('SELECT * FROM Product ');
      SQL.Add(' ORDER BY ProdNo');
      Open;

      while not EOF do {Begin Processing Query}
        begin
          nHIdx := FieldByName('ProdNo').AsInteger;
          if (nHIdx > 0) and (nHIdx < 21) then
            begin
              WriteLn(TF,
               '"PRODTLS"' + cDel +
               IntToStr(nHIdx)  + cDel +           // ProductNumber
               '"' + FieldByName('Name').AsString + '",' +        //ProductName
                FormatFloat('#.0000', (aPTls[nHIdx,1])) + cDel +          //Volume
                FormatFloat('#.00', (aPTls[nHIdx,2])) );                //Amount
            end;
          Next;
        end; {while not EOF}
      Close;
    end;

  // Fuel Price Changes...
  with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('Select FP.* From FuelPrice FP Join Grade G On ' +
       '(FP.GradeNo = G.GradeNo) Order By FP.GradeNo, FP.DateRead, FP.TimeRead' );
      Open;
      while Not EOF do
      begin
        WriteLn(TF,
         '"FUELPRCCNG"' + cDel +
         FieldByName('GradeNo').AsString  + cDel +
         '"' + FormatDateTime('yyyymmdd', FieldByName('DateRead').AsDateTime) + '"' + cDel +
         '"' + FormatDateTime('hh:mm',FieldByName('TimeRead').AsDateTime) + '"' + cDel +
         FormatFloat('#.0000', FieldByName('QtyClose').AsCurrency) + cDel +
         FormatFloat('#.000', FieldByName('NewPrice').AsCurrency) );
        Next;
      end;

      Close; SQL.Clear;
      SQL.Add('Delete From FuelPrice');
      ExecSQL;
      Close;
    end; {with TempQuery - Fuel Prices}

 WriteLn(TF, '"ENDRPT"' );
 CloseFile(TF);

(*
{----------- Export Competitor Pricing ----------}

 If ShiftNo = 0 Then
  Begin
     If EODExportPath = '' Then
       sFname := ExtractFileDir(Application.ExeName) + '\Comp.dat'
     Else
       sFname := EODExportPath + '\Comp.dat';

    AssignFile(TF, sFname);
    ReWrite(TF);

     // Competitor Prices...
     with POSDataMod.TempQuery do
     begin
       Close; SQL.Clear;

       SQL.Add('Select P.CompNo, P.CompDate, P.CompTime, P.Grade1Price, P.Grade2Price, P.Grade3Price, N.CompName');
       SQL.Add(' from CompPrice P, CompNames N where P.CompName = N.CompNo and P.SendState = 0 order by P.CompNo');
       Open;

       while Not EOF do
       begin
         WriteLn(TF,
          FieldByName('CompNo').AsString + cDel +
          '"' + FormatDateTime('yyyymmdd', FieldByName('CompDate').AsDateTime) + '"' + cDel +
          '"' + FormatDateTime('hh:mm',FieldByName('CompTime').AsDateTime) + '"' + cDel +
          '"' + FieldByName('CompName').AsString + '"' + cDel +
          FieldByName('Grade1Price').AsString + cDel +
          FieldByName('Grade2Price').AsString + cDel +
          FieldByName('Grade3Price').AsString);
         Next;
       end;

       Close; SQL.Clear;
       SQL.Add('Update CompPrice set SendState = 1');
 //    ExecSQL;
       Close;
     end; {with TempQuery - Competitor Prices}

    CloseFile(TF);
  End;
{----------- Export Fuel Deliveries Pricing ----------}

 If ShiftNo = 0 Then
  Begin
     If EODExportPath = '' Then
       sFname := ExtractFileDir(Application.ExeName) + '\Delivery.dat'
     Else
       sFname := EODExportPath + '\Delivery.dat';

    AssignFile(TF, sFname);
    ReWrite(TF);

     // Competitor Prices...
     with POSDataMod.TempQuery do
     begin
       Close; SQL.Clear;

       SQL.Add('Select * from FuelDel where SendState = 0 order by DelNo');
       Open;

       while Not EOF do
       begin
         WriteLn(TF,
          FieldByName('DelNo').AsString + cDel +
          '"' + FormatDateTime('yyyymmdd', FieldByName('DelDate').AsDateTime) + '"' + cDel +
          FieldByName('Manifest').AsString  + cDel +
          '"' + FieldByName('LowProduct').AsString + '"' + cDel +
          FieldByName('LowQty').AsString + cDel +
          '"' + FieldByName('HighProduct').AsString + '"' + cDel +
          FieldByName('HighQty').AsString);
         Next;
       end;

       Close; SQL.Clear;
       SQL.Add('Update FuelDel set SendState = 1');
 //    ExecSQL;
       Close;
     end; {with TempQuery - Competitor Prices}

    CloseFile(TF);
  End;
*)

end; {end procedure CreateExportFile}

end.

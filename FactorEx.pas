{-----------------------------------------------------------------------------
 Unit Name: FactorEx
 Author:    Gary Whetton
 Date:      9/11/2003 2:56:51 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit FactorEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, POSDM, DB, FileCtrl;

procedure CreateFactorExportFile (TerminalNo, ShiftNo : Integer; OpName : String);

implementation

uses POSMain, POSMsg, RptUtils;

//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------
{-----------------------------------------------------------------------------
  Name:      CreateFactorExportFile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo : Integer; OpName : String
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CreateFactorExportFile (TerminalNo, ShiftNo : Integer; OpName : String);
const
  cDel: Char = ',';
var
  sFname            : String;
  TF                : TextFile;
  nFuelTotalID      : Integer;
  OpenDate          : TDateTime;
  Year, Month, Day  : Word;

  aHTls             : array[1..20, 1..2] of Currency;
  aGTls             : array[1..20, 1..2] of Currency;
  aPTls             : array[1..20, 1..2] of Currency;

  nHIdx           : Integer;
  nPct            : double;

  nStartBatchID    : integer;

  ShiftZCount : integer;
  BusDate : tdatetime;

  nDeclinedSum : Double;
  nDeclinedCount : Integer;
  intrans : boolean;
begin

  DecodeDate(Now, Year, Month, Day);
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;

  if ShiftNo = 0 then
  begin
    sFname := '\Latitude.exp'
  end
  else
  begin
    with POSDataMod.IBRptSQL02Main do
    begin
      Assert(not open, 'IBRptSQL02Main is open');
      SQL.Clear;
      SQL.Add('Select MAX(OpenDate) OpenDate From Totals');
      SQL.Add('Where ShiftNo = :pShiftNo');
      if TerminalNo > 0 then
      begin
        SQL.Add('And TerminalNo = :pTerminalNo');
        ParamByName('pTerminalNo').AsInteger := TerminalNo;
      end;
      ParamByName('pShiftNo').AsInteger := ShiftNo;
      ExecQuery;
      BusDate := FieldByName('OpenDate').AsDateTime;
      Close;
      sFname := '\S' + Format('%1.1d',[ ShiftNo ]) +
                       Format('%2.2d',[ TerminalNo ]) +
                       FormatDateTime('mmdd', BusDate) + '.exp';
    end;
  end;
  // ShiftNo = 0  : End of Day file
  // ShiftNo <> 0 : End of Shift file

  //----------------------------------------------------------------------------
  { We load the data path from the Database }
  If EODExportPath = '' Then
     { No export Path specified, we copy the files in the EXE path }
    sFname := '\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude' + sFname
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

  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    if ShiftNo <> 0 then
         WriteLn( TF, '"EOS       ",' +
           '"' + FormatDateTime('yyyymmdd', Now) + '"' + cDel +
           '"' + FormatDateTime('hh:mm', Now ) + '"' + cDel +
           InttoStr(ShiftNo) + ',' +  InttoStr(TerminalNo)  )
    else
      WriteLn( TF, '"EOD       ",' +
           '"' + FormatDateTime('yyyymmdd', Now) + '"' + cDel +
           '"' + FormatDateTime('hh:mm', Now ) + '"');

    SQL.Text := 'Select * From Totals Where TotalNo = 0';
    ExecQuery;
    OpenDate := FieldByName('OpenDate').AsDateTime;

    { First we write the times for the whole day... }

    if RecordCount > 0 Then
    begin
      // Header Record
      WriteLn( TF,
             '"DAYOPEN   ","' + FormatDateTime('yyyymmdd', OpenDate) + '"' + cDel +
             '"' + FormatDateTime('hh:mm', OpenDate) + '"' );
    end;
    Close;

    If ShiftNo > 0 Then  // We include a Shift Start and End in the End of Shift file
    Begin
      SQL.Text := 'Select MAX(OpenDate) OpenDate From Totals Where ShiftNo = :pShiftNo';
      if TerminalNo = 0 then
      begin
        SQL.Add('GROUP By ShiftNo');
        SQL.Add('ORDER By ShiftNo');
      end
      else
      begin
        SQL.Add(' And TerminalNo = :pTerminalNo');
        ParamByName('pTerminalNo').AsInteger := TerminalNo;
      end;
      ParamByName('pShiftNo').AsInteger := ShiftNo;
      ExecQuery;
      OpenDate := FieldByName('OpenDate').AsDateTime;
      { Now we write the times for the current Shift... }
      if RecordCount > 0 Then
      begin
        // Header Record
        WriteLn( TF,
                 '"SHIFTOPEN ","' + FormatDateTime('yyyymmdd', OpenDate) + '"' + cDel +
                 '"' + FormatDateTime('hh:mm', OpenDate) + '"' + cDel + IntToStr(ShiftNo) );
      end;
      Close;
    End;
    if TerminalNo > 0 then
    begin
      SQL.Text := 'SELECT ResetCount FROM Terminal Where TerminalNo = :pTerminalNo';
      ParamByName('pTerminalNo').AsInteger := TerminalNo;
      ExecQuery;
      if RecordCount > 0 Then
        ShiftZCount := FieldByName('ResetCount').AsInteger
      else
        ShiftZCount := 0;
      Close;
    end
    else
      ShiftZCount := 0;


  end;

  // *** Store Totals ***
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('SELECT Max(TRANSNUMBER) TransNumber, ');
    SQL.Add('Max(RESETCOUNT) ResetCount, ');
    SQL.Add('Max(OPENDATE) OpenDate, ');
    SQL.Add('Max(CLOSEDATE) CloseDate, ');
    SQL.Add('Max(BEGGT) BegGT, ');
    SQL.Add('Max(CURGT) CurGT, ');
    SQL.Add('Sum(DLYND) DlyND, ');
    SQL.Add('Sum(DLYDS) DlyDS, ');
    SQL.Add('Sum(DLYPREPAYCOUNT) DlyPrePayCount, ');
    SQL.Add('Sum(DLYPREPAYRCVD) DlyPrePayRcvd, ');
    SQL.Add('Sum(DLYPREPAYCOUNTUSED) DlyPrePayCountUsed, ');
    SQL.Add('Sum(DLYPREPAYUSED) DlyPrePayUsed, ');
    SQL.Add('Sum(DLYPREPAYRFNDCOUNT) DlyPrePayRfndCount, ');
    SQL.Add('Sum(DLYPREPAYRFND) DlyPrePayRfnd, ');
    SQL.Add('Sum(DLYTRANSCOUNT) DlyTransCount, ');
    SQL.Add('Sum(DLYITEMCOUNT) DlyItemCount, ');
    SQL.Add('Sum(DLYNOSALECOUNT) DlyNoSaleCount, ');
    SQL.Add('Sum(DLYRETURNTAX) DlyReturnTax, ');
    SQL.Add('Sum(DLYNOTAX) DlyNoTax, ');

    SQL.Add('Sum(FUELCOUNT) FuelCount, ');
    SQL.Add('Sum(FUELAMOUNT) FuelAmount, ');
    SQL.Add('Sum(MDSECOUNT) MdseCount, ');
    SQL.Add('Sum(MDSEAMOUNT) MdseAmount, ');
    SQL.Add('Sum(FMCOUNT) FMCount, ');
    SQL.Add('Sum(FMAMOUNT) FMAmount, ');

    SQL.Add('Sum(DLYVOIDCOUNT) DlyVoidCount, ');
    SQL.Add('Sum(DLYVOIDAMOUNT) DlyVoidAmount, ');
    SQL.Add('Sum(DLYPORCOUNT) DlyPORCount, ');
    SQL.Add('Sum(DLYPORAMOUNT) DlyPORAmount, ');
    SQL.Add('Sum(DLYRTRNCOUNT) DlyRtrnCount, ');
    SQL.Add('Sum(DLYRTRNAMOUNT) DlyRtrnAmount, ');
    SQL.Add('Sum(DLYCANCELCOUNT) DlyCancelCount, ');
    SQL.Add('Sum(DLYCANCELAMOUNT) DlyCancelAmount, ');
    SQL.Add('Sum(DLYCATCOUNT) DlyCATCount, ');
    SQL.Add('Sum(DLYCATAMOUNT) DlyCATAmount FROM TOTALS ');

    if ((TerminalNo = 0) and (ShiftNo = 0)) then
    begin
      SQL.Add('WHERE TotalNo = 0');
    end
    else
      AddTSsql(SQL, 'Totals', TerminalNo, ShiftNo, False);
    if ((TerminalNo > 0) and (ShiftNo = 0)) then
      SQL.Add('GROUP BY TerminalNo ORDER BY TerminalNo' )
    else if ((TerminalNo = 0) and (ShiftNo > 0)) then
      SQL.Add('GROUP BY ShiftNo ORDER BY ShiftNo' );
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;

    // Write Reset Count

    if (ShiftNo > 0) and (TerminalNo > 0) then
    begin
      WriteLn(TF,
            '"ZCOUNT    "' + cDel +
            Format('%6.6d', [ShiftZCount]) );
    end
    else
    begin
      WriteLn(TF,
            '"ZCOUNT    "' + cDel +
            Format('%6.6d', [FieldByName('ResetCount').AsInteger]) );
    end;

    // Write Current GT
    WriteLn(TF,
        '"CURGT     "' + cDel +
        FormatFloat('0000000000.00', FieldByName('CurGT').AsCurrency) );

    // Write Beginning GT
    WriteLn(TF,
        '"BEGGT     "' + cDel +
        FormatFloat('0000000000.00', FieldByName('BegGT').AsCurrency) );

    // Write Total Daily Sales
    WriteLn(TF,
        '"DLYSLS    "' + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyDS').AsCurrency) );

    // Write Net Daily Sales
    WriteLn(TF,
        '"NETSLS    "' + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyND').AsCurrency) );

    // Write Fuel Only Count & Amount
    WriteLn(TF,
        '"FUELONLY  "' + cDel +
        Format('%6.6d', [FieldByName('FuelCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('FuelAmount').AsCurrency) );

    // Write Mdse Only Count & Amount
    WriteLn(TF,
        '"MDSEONLY  "' + cDel +
        Format('%6.6d', [FieldByName('MdseCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('MdseAmount').AsCurrency) );

    // Write Fuel & Mdse Count & Amount
    WriteLn(TF,
        '"FUELMDSE  "' + cDel +
        Format('%6.6d', [FieldByName('FMCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('FMAmount').AsCurrency) );

    // Write Prepay Received
    WriteLn(TF,
        '"PPYRCVD   "' + cDel +
        Format('%6.6d', [FieldByName('DlyPrePayCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyPrePayRcvd').AsCurrency) );

    // Write Prepay Used
    WriteLn(TF,
        '"PPYUSED   "' + cDel +
        Format('%6.6d', [FieldByName('DlyPrePayCountUsed').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyPrePayUsed').AsCurrency) );

    // Write Prepay Refund
    WriteLn(TF,
        '"PPYRFND   "' + cDel +
        Format('%6.6d', [FieldByName('DlyPrePayRfndCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyPrePayRfnd').AsCurrency) );

    // Write Transaction Count
    WriteLn(TF,
        '"TRANS     "' + cDel +
        Format('%6.6d', [FieldByName('DlyTransCount').AsInteger]) );

    // Write Item Count
    WriteLn(TF,
        '"ITEMS     "' + cDel +
        Format('%6.6d', [FieldByName('DlyItemCount').AsInteger]) );

    // Write NoSale Count
    WriteLn(TF,
        '"NOSALE    "' + cDel +
        Format('%6.6d', [FieldByName('DlyNoSaleCount').AsInteger]) );

    // Write Voids
    WriteLn(TF,
        '"VOID      "' + cDel +
        Format('%6.6d', [FieldByName('DlyVoidCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyVoidAmount').AsCurrency) );

    //Build 18
    // Write Voids
    WriteLn(TF,
        '"OVERRIDE  "' + cDel +
        Format('%6.6d', [FieldByName('DlyPORCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyPORAmount').AsCurrency) );
    //Build 18

    // Write Return
    WriteLn(TF,
        '"RETURN    "' + cDel +
        Format('%6.6d', [FieldByName('DlyRtrnCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyRtrnAmount').AsCurrency) );

    // Write Cancel
    WriteLn(TF,
        '"CANCEL    "' + cDel +
        Format('%6.6d', [FieldByName('DlyCancelCount').AsInteger]) + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyCancelAmount').AsCurrency) );

    // Write Return Tax
    WriteLn(TF,
        '"RTRNTAX   "' + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyReturnTax').AsCurrency) );

    // Write Non Tax
    WriteLn(TF,
        '"NONTAX    "' + cDel +
        FormatFloat('0000000000.00', FieldByName('DlyNoTax').AsCurrency) );

    Close;

    SQL.Clear;
    SQL.Add('SELECT TS.TaxNo, Sum(TS.DlyCount) DlyCount, ' +
     'Sum(TS.DlyTaxableSales) DlyTaxableSales, Min(T.Name) Name,' +
     'Sum(TS.DlyTaxCharged) DlyTaxCharged, Min(T.Rate) Rate FROM TaxShift TS, Tax T ' +
     'WHERE (TS.TaxNo = T.TaxNo)');
    AddTSsql(SQL, 'TS', TerminalNo, ShiftNo, False);
    SQL.Add('GROUP BY TS.TaxNo');
    SQL.Add('ORDER BY TS.TaxNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);

    ExecQuery;
    while Not EOF do
    begin
      if FieldByName('DlyCount').AsInteger > 0 then
      begin
        WriteLn(TF,
         '"TAX       "' + cDel +
         Format('%3.3d', [FieldByName('TaxNo').AsInteger]) + cDel + '"' +
         Format('%-30s', [FieldByName('Name').AsString]) + '"' + cDel +
         FormatFloat('000.0000', FieldByName('Rate').AsCurrency) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlyTaxableSales').AsCurrency) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlyTaxCharged').AsCurrency) );
      end;
      Next;
    end;  {while Not EOF}
    Close;

    // *** Discounts ***
    SQL.Clear;
    SQL.Add('SELECT DS.DiscNo, Sum(DS.DlyCount) DlyCount, ' +
     'Sum(DS.DlyAmount) DlyAmount, Min(D.Name) Name FROM DiscShift DS, Disc D ' +
     'WHERE (DS.DiscNo = D.DiscNo)');
    AddTSsql(SQL, 'DS', TerminalNo, ShiftNo, False);
    SQL.Add('GROUP BY DS.DiscNo');
    SQL.Add('ORDER BY DS.DiscNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    while Not EOF do
    begin
      if FieldByName('DlyCount').AsInteger > 0 then
      begin
        WriteLn(TF,
         '"DISC      "' + cDel +
         Format('%3.3d', [FieldByName('DiscNo').AsInteger]) + cDel +
         Format('%6.6d', [FieldByName('DlyCount').AsInteger]) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlyAmount').AsCurrency) );
      end;
      Next;
    end;  {while Not EOF}
    Close;

    SQL.Clear;
    SQL.Add('SELECT MS.MMNo, Sum(MS.DlyCount) DlyCount, ' +
     'Sum(MS.DlyAmount) DlyAmount, Min(MM.Name) Name FROM MixMatchShift MS, MixMatch MM ' +
     'WHERE (MS.MMNo = MM.MMNo)');
    AddTSsql(SQL, 'MS', TerminalNo, ShiftNo, False);
    SQL.Add('GROUP BY MS.MMNo');
    SQL.Add('ORDER BY MS.MMNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    while Not EOF do
    begin
      if FieldByName('DlyCount').AsInteger > 0 then
      begin
        WriteLn(TF,
         '"MIXMATCH  "' + cDel +
         Format('%3.3d', [FieldByName('MMNo').AsInteger]) + cDel +
         Format('%6.6d', [FieldByName('DlyCount').AsInteger]) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlyAmount').AsCurrency) );
      end;
      Next;
    end;  {while Not EOF}
    Close;

  // *** Dept Records ***
    SQL.Clear;
    SQL.Add('Select DS.DeptNo, Sum(DS.DlyCount) DlyCount, ' +
     'Sum(DS.DlySales) DlySales, Min(D.Name) Name, Min(D.GrpNo) GroupNo, Min(G.Fuel) GrpFuel ' +
     'From DepShift DS, Dept D, Grp G  ' +
     'Where DS.DeptNo = D.DeptNo And D.GrpNo = G.GrpNo And (DS.DlyCount <> 0 or DS.DlySales <> 0) ');
    AddTSsql(SQL, 'DS', TerminalNo, ShiftNo, False);
    SQL.Add('Group By DS.DeptNo ');
    SQL.Add('Order By DS.DeptNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    while Not EOF do
    begin
      if FieldByName('GrpFuel').AsInteger = 1 then  {Qty Format String 1=Fuel}
      begin
        WriteLn(TF,
         '"DPT       "' + cDel +
         Format('%3.3d', [FieldByName('DeptNo').AsInteger]) + cDel +
         '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
         FormatFloat('0000000000.000', FieldByName('DlyCount').AsCurrency) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlySales').AsCurrency) + cDel +
         Format('%3.3d', [FieldByName('GroupNo').AsInteger]) );
      end
      else
      begin
        WriteLn(TF,
         '"DPT       "' + cDel +
         Format('%3.3d', [FieldByName('DeptNo').AsInteger]) + cDel +
         '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
         FormatFloat('0000000000', FieldByName('DlyCount').AsCurrency) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlySales').AsCurrency) + cDel +
         Format('%3.3d', [FieldByName('GroupNo').AsInteger]) );
      end;
      Next;
    end;
    Close;

  // *** Plu Records ***
    Close; SQL.Clear;
    SQL.Add('Select PS.PluNo, PS.PLUModifier, Sum(PS.DlyCount) DlyCount, ' +
     'Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(P.HostKey) HostKey, Min(P.DeptNo) DptNo, Min(PS.Price) Price ' +
     'From PluShift PS Inner Join Plu P On (PS.PluNo = P.PluNo) ' +
     'Where PS.DlyCount <> 0  ');
    AddTSsql(SQL, 'PS', TerminalNo, ShiftNo, False);
    SQL.Add('Group By PS.PluNo, PS.PLUModifier ');
    SQL.Add('Order By PS.PluNo, PS.PLUModifier');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;

    while Not EOF do
    begin
      WriteLn(TF,
       '"PLU       "' + cDel +
       FormatFloat('000000000000', FieldByName('PluNo').AsCurrency) + cDel +
       '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
       FormatFloat('000000.00', FieldByName('DlyCount').AsCurrency) + cDel +
       FormatFloat('0000000000.00', FieldByName('DlySales').AsCurrency) + cDel +
       Format('%3.3d', [FieldByName('DptNo').AsInteger]) + cDel +
       FormatFloat('000000.00', FieldByName('Price').AsCurrency) + cDel +
       Format('%3.3d', [FieldByName('PLUModifier').AsInteger]) + cDel +
       '"' + Format('%-20s', [Trim(FieldByName('HostKey').AsString)]) + '"' );
      Next;
    end;
    Close;

  // *** Media Records ***
    Close; SQL.Clear;
    SQL.Add('Select MS.MediaNo, Sum(MS.DlyCount) DlyCount, ' +
     'Sum(MS.DlySales) DlySales, Min(M.Name) Name ' +
     'From MedShift MS, Media M Where (MS.MediaNo = M.MediaNo) ');
    AddTSsql(SQL, 'MS', TerminalNo, ShiftNo, False);
    SQL.Add('Group By MS.MediaNo ');
    SQL.Add('Order By MS.MediaNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;

    while Not EOF do
    begin
      WriteLn(TF,
       '"MED       "' + cDel +
       Format('%3.3d', [FieldByName('MediaNo').AsInteger]) + cDel +
       '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
       Format('%6.6d', [FieldByName('DlyCount').AsInteger]) + cDel +
       FormatFloat('0000000000.00', FieldByName('DlySales').AsCurrency) );
      Next;
    end;
    Close;
    if (TerminalNo = 0) and (ShiftNo = 0) and (nCreditAuthType = CDTSRV_FIFTH_THIRD) then
    begin
      SQL.Clear;
      SQL.Add('Select Sum(Amount) as DeclinedSum, Count(*) from CCBatch B ');
      SQL.Add('inner join CCRtb R on B.BatchID = R.BatchID where ');
      SQL.Add('(R.DayID = (Select ResetCount from Totals where TotalNo = 0)) ');
      SQL.Add('and B.HostID = :pHostID and B.CardType <> ''04'' and B.BatchNo=0 and ');
      SQL.Add('B.LocalApproved=1 and B.TransGroup=1');
      parambyname('pHostID').AsInteger := CDTSRV_FIFTH_THIRD;
      ExecQuery;
      try
        nDeclinedSum := FieldByName('DeclinedSum').AsCurrency * -1;
        nDeclinedCount := FieldByName('Count').AsInteger;
      except
        nDeclinedSum := 0;
        nDeclinedCount := 0;
      end;
      Close;
      if nDeclinedCount > 0 then
      begin
        writeln(TF,
          '"MED       "' + cDel +
          format('%3.3d', [100]) + cDel +
          '"' + Format('%-30s', ['Uncap Credit']) + '"' + cDel +
          FormatFloat( '000000', nDeclinedCount) + cDel +
          FormatFloat('000000000.00', nDeclinedSum) );
      end;
      SQL.Clear;
      SQL.Add('Select Sum(Amount) as DeclinedSum, Count(*) from CCBatch B ');
      SQL.Add('inner join CCRtb R on B.BatchID = R.BatchID where ');
      SQL.Add('(R.DayID = (Select ResetCount from Totals where TotalNo = 0)) ');
      SQL.Add('and B.HostID = :pHostID and B.CardType <> ''04'' and B.BatchNo=0 and ');
      SQL.Add('B.LocalApproved=1 and B.TransGroup=1');
      parambyname('pHostID').AsInteger := CDTSRV_FIFTH_THIRD;
      ExecQuery;
      try
        nDeclinedSum := FieldByName('DeclinedSum').AsCurrency * -1;
        nDeclinedCount := FieldByName('Count').AsInteger;
      except
        nDeclinedSum := 0;
        nDeclinedCount := 0;
      end;
      if nDeclinedCount > 0 then
      begin
        writeln(TF,
          '"MED       "' + cDel +
          format('%3.3d', [100]) + cDel +
          '"' + Format('%-30s', ['Uncap Debit']) + '"' + cDel +
          FormatFloat( '000000', nDeclinedCount) + cDel +
          FormatFloat('000000000.00', nDeclinedSum) );
      end;
      Close;
    end;

  // *** Bank Function Records ***
    SQL.Clear;
    SQL.Add('Select BS.BankNo, Sum(BS.DlyCount) DlyCount, ' +
     'Sum(BS.DlySales) DlySales, Min(B.Name) Name ' +
     'From BankShift BS, BankFunc B Where (BS.BankNo = B.BankNo) ');
    AddTSsql(SQL, 'BS', TerminalNo, ShiftNo, False);
    SQL.Add('Group By BS.BankNo ');
    SQL.Add('Order By BS.BankNo');
    AddTSParams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;

    while Not EOF do
      begin
        WriteLn(TF,
         '"BFN       "' + cDel +
         Format('%3.3d', [FieldByName('BankNo').AsInteger]) + cDel +
         '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
         Format('%6.6d', [FieldByName('DlyCount').AsInteger]) + cDel +
         FormatFloat('0000000000.00', FieldByName('DlySales').AsCurrency) );
        Next;
      end;
    Close;
  end; {with TempQuery - Bank}

  if ShiftNo = 0 then
  begin
    if Setup.MeterReport = 1 then
    begin
      for nHIdx := 1 to 20 do
      begin
        aHTls[nHIdx,1] := 0;
        aHTls[nHIdx,2] := 0;
        aGTls[nHIdx,1] := 0;
        aGTls[nHIdx,2] := 0;
        aPTls[nHIdx,1] := 0;
        aPTls[nHIdx,2] := 0;
      end;

      with POSDataMod.IBRptSQL02Main do
      begin
        Assert(not open, 'IBRptSQL02Main is open');
        // Get Last Fuel Totals (TlNo)
        SQL.Text := 'SELECT Max(TlNo) FROM PumpTls';
        ExecQuery;
        nFuelTotalID := Fields[0].AsInteger;
        Close;
      // **** Get Fuel Totals ****
        // Build SQL Statement
        SQL.Clear;
        SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
        SQL.Add('WHERE (T.TlNo = :pFuelTotalId)');
        SQL.Add('AND (T.PumpNo = D.PumpNo) AND (T.HoseNo = D.HoseNo) ');
        SQL.Add('AND (D.GradeNo = G.GradeNo) ');
        SQL.Add('ORDER BY T.PumpNo, T.HoseNo');
        ParamByName('pFuelTotalId').AsInteger := nFuelTotalID;
        ExecQuery;

        while not EOF do {Begin Processing Query}
        begin
          WriteLn(TF,
           '"PUMPTLS   "' + cDel +
           Format('%2.2d', [FieldByName('PumpNo').AsInteger]) + cDel +
           Format('%2.2d', [FieldByName('HoseNo').AsInteger]) + cDel +
           '"' + FormatDateTime('yyyymmdd', FieldByName('DateTimeRead').AsDateTime) + '"' + cDel +
           '"' + FormatDateTime('hh:mm',FieldByName('DateTimeRead').AsDateTime) + '"' + cDel +
           FormatFloat('000000000000.0000', FieldByName('VolumeTl').AsCurrency) + cDel +
           FormatFloat('000000000000.00', ( FieldByName('CashTl').AsCurrency + FieldByName('CreditTl').AsCurrency)) );

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
             '"HOSETLS   "' + cDel +
             Format('%2.2d', [nHIdx])  + cDel +
             FormatFloat('000000000000.0000', (aHTls[nHIdx,1])) + cDel +   // Volume
             FormatFloat('000000000000.0000', (aHTls[nHIdx,2])) );         //Amount
          end;

        // Build SQL Statement
        SQL.Text := 'SELECT * FROM Grade ORDER BY GradeNo';
        ExecQuery;

        while not EOF do {Begin Processing Query}
        begin
          nHIdx := FieldByName('GradeNo').AsInteger;
          if (nHIdx > 0) and (nHIdx < 21) then
          begin
            WriteLn(TF,
             '"GRADETLS  "' + cDel +
             Format('%2.2d', [nHIdx])  + cDel +           // GradeNumber
             '"' + Format('%-20s', [FieldByName('Name').AsString]) + '",' +        //GradeName
              FormatFloat('000000000000.0000', (aGTls[nHIdx,1])) + cDel +          //Volume
              FormatFloat('000000000000.00', (aGTls[nHIdx,2])) );                //Amount
          end;
          Next;
        end; {while not EOF}
        Close;

        // Build SQL Statement
        SQL.Text := 'SELECT * FROM Product ORDER BY ProdNo';
        ExecQuery;

        while not EOF do {Begin Processing Query}
        begin
          nHIdx := FieldByName('ProdNo').AsInteger;
          if (nHIdx > 0) and (nHIdx < 21) then
          begin
            WriteLn(TF,
             '"PRODTLS   "' + cDel +
             Format('%2.2d', [nHIdx])  + cDel +           // ProductNumber
             '"' + Format('%-20s', [FieldByName('Name').AsString]) + '",' +        //ProductName
              FormatFloat('000000000000.0000', (aPTls[nHIdx,1])) + cDel +          //Volume
              FormatFloat('000000000000.00', (aPTls[nHIdx,2])) );                //Amount
          end;
          Next;
        end; {while not EOF}
        Close;
      end;
    end
    else
    begin
      with POSDataMod.IBRptSQL02Main do
      begin
        Assert(not open, 'IBRptSQL02Main is open');
        SQL.Text := 'SELECT * FROM Grade Order By GradeNo ';
        ExecQuery;
        while Not EOF do
        begin
          WriteLn(TF,
           '"GRADETLS  "' + cDel +
           Format('%3.3d', [FieldByName('GradeNo').AsInteger]) + cDel +
           '"' + Format('%-30s', [Trim(FieldByName('Name').AsString)]) + '"' + cDel +
           FormatFloat('000000000000.0000', FieldByName('TLVol').AsCurrency) + cDel +  //Volume
           FormatFloat('0000000000.00', FieldByName('TLAmount').AsCurrency) );
          Next;
        end;
        Close;
      end; {with TempQuery - Grade}
    end;


    // Fuel Price Changes...
    with POSDataMod.IBRptSQL02Main do
    begin
      Assert(not open, 'IBRptSQL02Main is open');
      SQL.Clear;
      SQL.Add('Select FP.* From FuelPrice FP Join Grade G On ' +
       '(FP.GradeNo = G.GradeNo) Order By FP.GradeNo, FP.DateRead, FP.TimeRead' );
      ExecQuery;
      while Not EOF do
      begin
        WriteLn(TF,
         '"FUELPRCCNG"' + cDel +
         Format('%2.2d', [FieldByName('GradeNo').AsInteger]) + cDel +
         '"' + FormatDateTime('yyyymmdd', FieldByName('DateRead').AsDateTime) + '"' + cDel +
         '"' + FormatDateTime('hh:mm',FieldByName('TimeRead').AsDateTime) + '"' + cDel +
         FormatFloat('000000000000.0000', FieldByName('QtyClose').AsCurrency) + cDel +
         FormatFloat('000000000000.000', FieldByName('NewPrice').AsCurrency) );
        Next;
      end;
      Close;

      SQL.Text := 'Delete From FuelPrice';
      ExecQuery;
      Close;

      SQL.Text := 'SELECT StartingBatch FROM Totals WHERE TotalNo = :pShiftNo';
      ParamByName('pShiftNo').AsInteger := ShiftNo;
      ExecQuery;
      nStartBatchID := FieldByName('StartingBatch').AsInteger;
      Close;

      // === Sales By Card Type ===
      SQL.Clear;
      SQL.Add('SELECT CT.ShortName, Count(*) as Cnt, Sum(CB.Amount) as Amt');
      SQL.Add('FROM CCBatch CB LEFT OUTER JOIN CCCardTypes CT ON (CB.CardType = CT.CardType)');
      SQL.Add('WHERE ((CB.HostID > 0) and (CB.BatchID >= :pStartID) And (CB.Collected = 1))');
      if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
          SQL.Add(' AND CB.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
      SQL.Add('GROUP BY CT.ShortName');
      SQL.Add('ORDER BY CT.ShortName');
      ParamByName('pStartID').AsInteger := nStartBatchID;
      ExecQuery;
      while Not EOF do
      begin
        WriteLn(TF,
         '"CARDSUMRY "' + cDel +
         '"' + Format('%-10s', [Trim(FieldByName('ShortName').AsString)]) + '"' + cDel +
         Format('%4.4d', [FieldByName('Cnt').AsInteger]) + cDel +
         FormatFloat('0000000000.00', FieldByName('Amt').AsCurrency) );
        Next;
      end;
      Close;
    end; {with ReportQuery }
  end;

  WriteLn(TF, '"ENDRPT"' );
  System.CloseFile(TF);

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
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {end procedure CreateExportFile}

end.

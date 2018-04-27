{-----------------------------------------------------------------------------
 Unit Name: Reports
 Author:    Gary Whetton
 Date:      4/13/2004 4:20:31 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit Reports;

{$I ConditionalCompileSymbols.txt}

interface
uses SysUtils, Forms, POSMain, Windows, POSPrt,
     POSMisc, Classes;

procedure LineOut(const sLine: shortstring);
procedure ReportHdr(const sTitle: shortstring; const pause : boolean = True);
procedure ReportFtr;
procedure HourlySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
procedure HourlySnoopReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);

procedure DailySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
//20060706...
function PrintDiscTotals(const DayId         : integer;
                         const TerminalNo    : integer;
                         const ShiftNo       : integer;
                         const bFuelDiscOnly : boolean; const bConsolidateShifts : boolean) : currency;
//...20060706
procedure PrintDSTotals(sCaption: shortstring; nQty: Double; nAmount: Double);
procedure GroupSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
procedure CategorySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
procedure MediaSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
procedure BankSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);

procedure PrintFuelTotalsReport(const DayId : integer);
procedure PrintFuelMeterReport(const DayId : integer);


procedure PrintFailedToActivateReport(const DayId : integer; const ReportRegNo : integer; const ReportShift : integer);
procedure PrintPLUReport(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
procedure PrintPLUReportToDisk(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
procedure PrintResetChit(ResetType : string);
procedure PrintCashDropReport(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
procedure CCSalesReport(ShiftNo: Integer; StartBatch: Integer; EndBatch: Integer);
procedure PrintCreditTotalsReport(ShiftNo: Integer; nStartBatchID: Integer; nEndBatchID: Integer);

procedure CCBatchReport(BatchID, BatchDayID, CurDayID: Integer; OpenDate : TDateTime; Settled : boolean );

procedure CCRptByCardType( StartBatchID: Integer; EndBatchID: Integer;GiftAmount:currency;GiftCount:integer);
procedure CCRptUncollected;
procedure CCTermSrvCheck;
//bp...
procedure CCHostTotals(const DayID : integer);
procedure CCLocalTotals(const DayID : integer);
//...bp
procedure CCBatchSummary;
procedure CCSetupReport;
procedure CCRSOut(sLabel:String; sData: String);
procedure PluListingReport;
procedure LogReportMarker( const sLine: shortstring);

procedure CCRptUncollectedLocal;
procedure Print2Disk(sLine : Shortstring);
//inv3...
procedure PrintInventoryReport(const InvoiceID : string);
//...inv3
procedure PrintInventoryDeptReport(const DeptNo : integer; const DeptName : string);

procedure PrintMOBatchReport;

type
  pDeptRec = ^TDeptRec;
  TDeptRec = Record
    DeptNo : Integer;
    DeptName : string;
    DeptDlyCount : currency;
    DeptDlySales : Currency;
    DeptGroupNo : integer;
  end;

  pMediaRec = ^TMediaRec;
  TMediaRec = record
    MediaNo : Integer;
    MediaName : string;
    MediaDlyCount : Integer;
    MediaDlySales : Currency;
  end;

const
   PRINT_ALL : Boolean = False;
   bPrinterOK : Boolean = True;


implementation
uses POSDM, ExceptLog,
     RptUtils,
     StrUtils;

const
  {$I LatitudeConst.Inc}
  FF = #27#100#4;
  LF = #10;

type
  THourlyShiftRec = record
    Time : TDateTime;
    NSLCount : smallint;
    RP1Count : smallint;
    CNLCount : smallint;
    CNLAmount: currency;
    ERCCount : smallint;
    ERCAmount: currency;
    RTNCount : smallint;
    RTNAmount: currency;
  end;
  pHourlyShiftRec = ^THourlyShiftRec;
  
var
  TF: TextFile;
  bPrintingPLU : boolean;


{-----------------------------------------------------------------------------
  Name:      ReportHdr
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const sTitle: shortstring
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ReportHdr(const sTitle: shortstring; const pause : boolean = True);
begin
  if pause and (not fmPOS.PrintPaused) then
    PausePrint;
  LineOut( '========================================');
  LineOut( 'Report : ' + sTitle);
  LineOut( 'Store  : ' + Setup.NUMBER);
  LineOut( 'Report Date  : ' + DateToStr(Date));
  LineOut( 'Report Time  : ' + TimeToStr(Time));
  LineOut( 'User   : ' + CurrentUserID + ' ' + CurrentUser);
  LineOut( '----------------------------------------');
end; {procedure ReportHdr}

{-----------------------------------------------------------------------------
  Name:      LogReportMarker
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const sLine: shortstring
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure LogReportMarker( const sLine: shortstring);
begin
  try
    AssignFile(TF, sReportLogName);
    if FileExists(sReportLogName) then
    try
      Append(TF);
    except
      CloseFile(TF);
      try
        Append(TF);
      except
      end;
    end
    else
    try
      ReWrite(TF);
    except
      closefile(TF);
      try
        rewrite(TF);
      except
      end;
    end;
    WriteLn( TF, sLine);
    CloseFile(TF);
  except
  end;
end;


{-----------------------------------------------------------------------------
  Name:      ReportFtr
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ReportFtr;
begin
  if not(PRINT_ALL) then
  begin
    LineOut('');
    LineOut('       ****  End Of Report  ****');
    LineOut(''); LineOut('');
  end
  else
  begin
    LineOut('');
    LineOut('');
    LineOut('');
  end;
  bPrinterOK := True;
  if fmPOS.PrintPaused then
    ResumePrint;
end; {procedure ReportFtr}

{-----------------------------------------------------------------------------
  Name:      PrintResetChit
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ResetType : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintResetChit(ResetType : string);
begin
  LineOut('');
  LineOut('***  End Of ' + ResetType + ' - Totals Are Reset ***');
  LineOut('');
  LineOut('');
end; {procedure ReportFtr}

{-----------------------------------------------------------------------------
  Name:      LineOut
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const sLine: shortstring
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure LineOut( const sLine: shortstring);
begin
  if (bReceiptActive = 0) and (fmPOS.ReportToDisk) then     // Print Report To File (Testing Only)
  begin
    AssignFile(TF, sReportLogName);
    if FileExists(sReportLogName) then
      Append(TF)
    else
      ReWrite(TF);
    WriteLn( TF, sLine);
    CloseFile(TF);
  end
  else if bReceiptActive > 0 then
  begin
    try
      case bReceiptActive of
        DRIVER_DIRECT :
          begin
            fmPOS.DCOMPrinter.AddLine(PRT_NORMALTEXT, sLine + LF) ;
          end;
        DRIVER_OPOS :
          begin
            fmPOS.DCOMPrinter.AddLine(PRT_NORMALTEXT, sLine + LF );
          end;
      end;
    except
      on E: Exception do
      begin
        fmPOS.ReconnectPrinter('PrintReceipt ', e.message, 1);
      end;
    end;

    if (fmPOS.ReportToDisk) and (not bPrintingPLU) then
    begin
      try
        AssignFile(TF, sReportLogName);
        if FileExists(sReportLogName) then
        try
          Append(TF);
        except
          Closefile(TF);
          try
            Append(TF);
          except
          end;
        end
        else
        try
          ReWrite(TF);
        except
          closefile(TF);
          try
            rewrite(TF);
          except
          end;
        end;
        WriteLn( TF, sLine);
        CloseFile(TF);
      except
      end;
    end;
  end;
end; {procedure PrintReceipt}


{ *************** REPORTS  *************** }

{-----------------------------------------------------------------------------
  Name:      HourlySalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure HourlySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  nTotalTrans : Double;
  nTotalSales : Double;
  TmpStr : string;
  intrans : boolean;
begin
  nTotalTrans := 0;
  nTotalSales := 0;

  //Build 23
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  //Build 23
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT H.HourNo, ');
    SQL.Add('Sum(H.DlyCount) DlyCount, Sum(H.DlySales) DlySales');
    SQL.Add('FROM HOURLYSHIFT H');
    SQL.Add('WHERE dayid = :pDayId and DlyCount <> 0 ');
    AddTSsql(SQL, 'H', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY H.HourNo');
    SQL.Add('ORDER BY H.HourNo');
    if bLogging then UpdateZlog('Hourly Report Open');
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ParamByName('pDayId').AsInteger := DayId;
    ExecQuery;

    TmpStr := 'Hourly Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut('Time Start   # of Trans  Sales Amt');
    LineOut('-----------  ----------  ------------');

    while not EOF do
    begin
      { Format Record }
      LineOut( FormatDateTime('hh:mm AM/PM', FieldByName('HourNo').Value) +
       Format('  %10s  %12s',[FormatFloat('##,###,##0', FieldByName('DlyCount').Value),
       FormatFloat('#,###,###.00 ;#,###,###.00-',FieldByName('DlySales').Value)]));
      nTotalTrans := nTotalTrans + FieldByName('DlyCount').Value;
      nTotalSales := nTotalSales + FieldByName('DlySales').Value;
      Next;
    end;

    LineOut( '-----------  ----------  ------------');
    LineOut( Format('    TOTAL:   %10s  %12s',[FormatFloat('##,###,##0', nTotalTrans),
     FormatFloat('#,###,###.00 ;#,###,###.00-',nTotalSales)]));

    ReportFtr;


    if bLogging then UpdateZlog('Hourly Report Close');
    Close;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure HourlySalesReport}

procedure HourlySnoopReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  TmpStr : string;
  phsr : pHourlyShiftRec;
  data : TList;  
  i : integer;
  intrans : boolean;
begin
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT H.HourNo, ');
    SQL.Add('Sum(H.NoSaleCount) NSLCount, sum(H.SalesRptCount) RP1Count,');
    SQL.Add('Sum(H.VoidCount)   ERCCount, Sum(H.VoidAmount)    ERCAmount,');
    SQL.Add('Sum(H.RtrnCount)   RTNCount, Sum(H.RtrnAmount)    RTNAmount,');
    SQL.Add('Sum(H.CancelCount) CNLCount, Sum(H.CancelAmount)  CNLAmount');
    SQL.Add('FROM HOURLYSHIFT H where DayId = :pDayId');
    AddTSsql(SQL, 'H', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY H.HourNo');
    SQL.Add('ORDER BY H.HourNo');
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ParamByName('pDayId').AsInteger := DayId;
    if bLogging then UpdateZlog('Hourly Snoop Report Open');
    ExecQuery;
    data := TList.Create();
    while not EOF do
    begin
      new(phsr);
      phsr^.Time := FieldByName('HourNo').AsDateTime;
      phsr^.NSLCount  := FieldByName('NSLCount').AsInteger;
      phsr^.RP1Count  := FieldByName('RP1Count').AsInteger;
      phsr^.CNLCount  := FieldByName('CNLCount').AsInteger;
      phsr^.CNLAmount := FieldByName('CNLAmount').AsCurrency;
      phsr^.RTNCount  := FieldByName('RTNCount').AsInteger;
      phsr^.RTNAmount := FieldByName('RTNAmount').AsCurrency;
      phsr^.ERCCount  := FieldByName('ERCCount').AsInteger;
      phsr^.ERCAmount := FieldByName('ERCAmount').AsCurrency;
      data.Add(phsr);
      next;
    end;

    TmpStr := 'Hourly Activity - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut(' Time      NO    Sales      Cancels   ');
    LineOut(' Start    SALEs Reports  CNT  Amount  ');
    LineOut('--------  ----- -------  --- ---------');

    for i := 0 to Pred(data.Count) do
    begin
      phsr := Data[i];
      LineOut(Format('%8s  %5d %6d   %3d %9.2f', 
                     [FormatDateTime('hh:nn AM/PM', phsr.Time), 
                      phsr.NSLCount, 
                      phsr.RP1Count, 
                      phsr.CNLCount, 
                      phsr.CNLAmount]));
    end;
    LineOut('');
    
    LineOut(' Time       Returns      Err Corrects ');
    LineOut(' Start    CNT  Amount    CNT  Amount  ');
    LineOut('--------  --- ---------  --- ---------');

    for i := 0 to Pred(data.Count) do
    begin
      phsr := Data[i];
      LineOut(Format('%8s  %3d %9.2f  %3d %9.2f', 
                     [FormatDateTime('hh:nn AM/PM', phsr.Time), 
                      phsr.RTNCount, 
                      phsr.RTNAmount, 
                      phsr.ERCCount, 
                      phsr.ERCAmount]));
    end;
    LineOut('');
    
    DisposeTlistItems(data);
    data.Free;
    
    ReportFtr;

    if bLogging then UpdateZlog('Hourly Snoop Report Close');
    Close;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure HourlySalesReport}


{-----------------------------------------------------------------------------
  Name:      DailySalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure DailySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  TotalTaxes : Currency;
  TotalDisc : Currency;
  {$IFNDEF PDI_PROMOS}
  TotalMM : Currency;
  {$ENDIF}
  TmpStr : string;
  ShiftZCount : integer;
  InsideSales, FuelGallons : currency;
  intrans : boolean;
begin

  TotalTaxes := 0;
//20060706  TotalDisc := 0;
  {$IFNDEF PDI_PROMOS}
  TotalMM := 0;
  {$ENDIF}
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT GEN_ID(TRANSNO_GEN,0) TransNumber, ');
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
    SQL.Add('Sum(TILLTIMEOUTCOUNT) TillTimeOutCount, ');
    SQL.Add('Sum(STARTINGTILL) StartingTill, ');
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
    SQL.Add('Sum(DLYRTRNCOUNT) DlyRtrnCount, ');
    SQL.Add('Sum(DLYRTRNAMOUNT) DlyRtrnAmount, ');
    SQL.Add('Sum(DLYCANCELCOUNT) DlyCancelCount, ');
    SQL.Add('Sum(DLYCANCELAMOUNT) DlyCancelAmount, ');
    SQL.Add('Sum(DLYPORCOUNT) DlyPORCount, ');
    SQL.Add('Sum(DLYPORAMOUNT) DlyPORAmount, ');
    SQL.Add('Sum(DLYCATCARWASHCOUNT) DlyCATCarwashCount, ');
    SQL.Add('Sum(DLYCATCARWASHAMOUNT) DlyCATCarwashAmount, ');
    SQL.Add('Sum(DLYCATCOUNT) DlyCATCount, ');
    SQL.Add('Sum(DLYCATAMOUNT) DlyCATAmount FROM TOTALS ');

    if (TerminalNo = 0) and (ShiftNo = 0) then
    begin
      SQL.Add('WHERE TotalNo = 0');
    end
    else
      AddTSsql(SQL, 'Totals', TerminalNo, ShiftNo, bConsolidateShifts);
    if (TerminalNo > 0) and (ShiftNo = 0) then
      SQL.Add('GROUP BY TerminalNo ORDER BY TerminalNo' )
    else if ((TerminalNo = 0) and (ShiftNo > 0)) then
      SQL.Add('GROUP BY ShiftNo ORDER BY ShiftNo' );
    if bLogging then UpdateZlog('Daily Sales Report Open');
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;

    if RecordCount = 0 then
    begin
      UpdateExceptLog('Daily Sales Report Close - Error EOF');
      close;
      if not intrans then
        POSDataMod.IBRptTrans.Commit;
      exit;
    end;

    TmpStr := 'Daily Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    if EODInProgress then
    begin
      LineOut( 'End Of Day Reset - ' + Format('%6.6d', [POSDataMod.IBRptSQL02Main.FieldByName('ResetCount').AsInteger]) + 'Z Store #'+ setup.number);
      LineOut( 'Open Date   : ' + DateToStr(POSDataMod.IBRptSQL02Main.FieldByName('OpenDate').AsDateTime));
      LineOut( 'Open Time   : ' + TimeToStr(POSDataMod.IBRptSQL02Main.FieldByName('OpenDate').AsDateTime));
      LineOut( 'Close Date  : ' + DateToStr(Date));
      LineOut( 'Close Time  : ' + TimeToStr(Time));
    end
    else if EOSInProgress then
    begin
      ShiftZCount := 0;
      if TerminalNo > 0 then
      begin
        with POSDataMod.IBRptSQL02Sub1 do
        begin
          Assert(not Open, 'IBRptSQL02Sub1 is open');
          SQL.Text := 'SELECT ResetCount FROM Terminal Where TerminalNo = :pTerminalNo';
          parambyname('pTerminalNo').AsString := IntToStr(TerminalNo);
          if bLogging then UpdateZlog('Daily Sales Report Open - ResetCount');
          ExecQuery;
          if RecordCount > 0 then
            ShiftZCount := FieldByName('ResetCount').AsInteger
          else ShiftZCount := 1;
          Close;
          if bLogging then UpdateZlog('Daily Sales Report Close - ResetCount');
        end;
      end;


      LineOut( 'End Of Shift Reset - ' + Format('%6.6d', [ShiftZCount]) + 'Z');
      LineOut( 'Open Date   : ' + DateToStr(POSDataMod.IBRptSQL02Main.FieldByName('OpenDate').AsDateTime));
      LineOut( 'Open Time   : ' + TimeToStr(POSDataMod.IBRptSQL02Main.FieldByName('OpenDate').AsDateTime));
      LineOut( 'Close Date  : ' + DateToStr(POSDataMod.IBRptSQL02Main.FieldByName('CloseDate').AsDateTime));
      LineOut( 'Close Time  : ' + TimeToStr(POSDataMod.IBRptSQL02Main.FieldByName('CloseDate').AsDateTime));
    end;

    LineOut( '----------------------------------------');
    LineOut( 'Latitude   ' + GetFileVersionStr('\Latitude\Latitude.exe') );
    LineOut( 'SysMgr     ' + GetFileVersionStr('\Latitude\SysMgr.exe') );
    LineOut( 'Credit Srv ' + GetFileVersionStr('\Latitude\CreditServer.exe') );
    LineOut( 'Fuel Srv   ' + GetFileVersionStr('\Latitude\FuelProg.exe') );
    LineOut( 'CAT Srv    ' + GetFileVersionStr('\Latitude\CATSrvr.exe') );
    LineOut( 'Rcpt Srv   ' + GetFileVersionStr('\Latitude\ReceiptSrvr.exe') );
    LineOut( 'MO Srv     ' + GetFileVersionStr('\Latitude\MOServer.exe'));
    LineOut( 'POS AutoUd ' + GetFileVersionStr('\Latitude\LatitudeUpdate.exe') );
    LineOut( '----------------------------------------');

    PrintDSTotals('Curr Grand Total', 0, FieldByName('CurGT').AsCurrency);

    PrintDSTotals('Begin Grand Total', 0, FieldByName('BegGT').AsCurrency);
    PrintDSTotals('Net Daily Sales', 0, FieldByName('DlyND').AsCurrency);
    PrintDSTotals('Total Daily Sales', 0, FieldByName('DlyDS').AsCurrency);
    PrintDSTotals('# of Transactions', FieldByName('DlyTransCount').AsInteger, 0);
    PrintDSTotals('# of Items', FieldByName('DlyItemCount').AsInteger, 0);
    PrintDSTotals('# of No Sales', FieldByName('DlyNoSaleCount').AsInteger, 0);
    //Build 18
    PrintDSTotals('Price Overrides', FieldByName('DlyPORCount').AsInteger, FieldByName('DlyPORAmount').AsCurrency);
    //Build 18
    PrintDSTotals('# of Till Timeouts', FieldByName('TillTimeOutCount').AsInteger, 0);
    if ShiftNo > 0 then
      PrintDSTotals('Starting Till', 0, FieldByName('StartingTill').AsCurrency );

    PrintDSTotals('Prepay Sales Rcvd', FieldByName('DlyPrePayCount').AsInteger,
    FieldByName('DlyPrePayRcvd').AsCurrency);
    PrintDSTotals('Prepay Sales Used', FieldByName('DlyPrePayCountUsed').AsInteger,
    FieldByName('DlyPrePayUsed').AsCurrency);
    PrintDSTotals('Prepay Sales Rfnd', FieldByName('DlyPrePayRfndCount').AsInteger,
    FieldByName('DlyPrePayRfnd').AsCurrency);

    //cwh...
    //Build 23
    if Setup.CarWashInterfaceType > 1 then
    begin
      LineOut('');
      PrintDSTotals('PAP Carwashes',0, FieldByName('DlyCATCarwashAmount').AsCurrency);
      PrintDSTotals('# PAP Carwashes', FieldByName('DlyCATCarwashCount').AsInteger, 0);
      LineOut('');
    end;
    //Build 23
    //...cwh

    LineOut('');
    PrintDSTotals('Outside Sales',0, FieldByName('DlyCATAmount').AsCurrency);
    PrintDSTotals('# Outside Sales', FieldByName('DlyCATCount').AsInteger, 0);
    LineOut('');

    LineOut('');
    PrintDSTotals('Mdse Only Sales', FieldByName('MdseCount').AsInteger, FieldByName('MdseAmount').AsCurrency);
    PrintDSTotals('Fuel Only Sales', FieldByName('FuelCount').AsInteger, FieldByName('FuelAmount').AsCurrency);
    PrintDSTotals('F&M  Only Sales', FieldByName('FMCount').AsInteger, FieldByName('FMAmount').AsCurrency);
    LineOut('');

    LineOut('Taxable Sales');
    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not Open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('SELECT TS.TaxNo, Sum(TS.DlyCount) DlyCount, ');
      SQL.Add('Sum(TS.DlyTaxableSales) DlyTaxableSales, Min(T.Name) Name, ');
      //20040908...
      SQL.Add('Sum(TS.FSTaxExemptSales) FSTaxExemptSales, ');
      //...20040908
      SQL.Add('Sum(TS.DlyTaxCharged) DlyTaxCharged, Min(T.Rate) Rate FROM TaxShift TS, Tax T ');
      SQL.Add('WHERE DayId = :pDayId and TS.TaxNo = T.TaxNo ');
      AddTSsql(SQL, 'TS', TerminalNo, ShiftNo, bConsolidateShifts);
      SQL.Add('GROUP BY TS.TaxNo ORDER BY TS.TaxNo ');
      AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
      parambyname('pDayId').AsInteger := DayId;
      if bLogging then UpdateZlog('Daily Sales Report Open - Tax');
      ExecQuery;
      while Not EOF do
      begin
        if FieldByName('DlyCount').AsInteger > 0 then
        begin
          PrintDSTotals(FieldByName('Name').AsString + ' Sales', 0, FieldByName('DlyTaxableSales').AsCurrency);
          //20040908...
          PrintDSTotals(FieldByName('Name').AsString + ' Exempt', 0, FieldByName('FSTaxExemptSales').AsCurrency);
          //...20040908
          PrintDSTotals(FieldByName('Name').AsString + ' TxColct', 0, FieldByName('DlyTaxCharged').AsCurrency);
          TotalTaxes := TotalTaxes + FieldByName('DlyTaxCharged').asCurrency;
        end;
        Next;
      end;  {while Not EOF}
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - Tax');
    end; {with IBRptSQL02Sub1}

    // Print Total Taxes Charged
    LineOut('');
    PrintDSTotals('Total Taxes Charged', 0, TotalTaxes);
    LineOut('');

    PrintDSTotals('Non Taxable Sales',0, FieldByName('DlyNoTax').AsCurrency);
    {$IFDEF HUCKS_REPORTS}  //20070103c
    //Request that Voids standout on Daily Summary Report
    LineOut('');
    PrintDSTotals('*** Voids ***',FieldByName('DlyVoidCount').AsInteger,
                  FieldByName('DlyVoidAmount').AsCurrency);
    LineOut('');
    {$ELSE}
    PrintDSTotals('Voids',FieldByName('DlyVoidCount').AsInteger,
                  FieldByName('DlyVoidAmount').AsCurrency);
    {$ENDIF}
    PrintDSTotals('Returns',FieldByName('DlyRtrnCount').AsInteger, FieldByName('DlyRtrnAmount').AsCurrency);
    PrintDSTotals('Cancels',FieldByName('DlyCancelCount').AsInteger,
     FieldByName('DlyCancelAmount').AsCurrency);

    LineOut('');
    LineOut('Discounts');

    TotalDisc := PrintDiscTotals(DayId, TerminalNo, ShiftNo, False, bConsolidateShifts);
    //...20060706
    LineOut('');
    if FieldByName('DlyDS').AsCurrency <> 0 then
      LineOut('Discount as % of Total Sales = ' +
       FormatFloat('##0.00%', ( Abs(TotalDisc)/ FieldByName('DlyDS').AsCurrency * 100)) );  ////20070227h (mult. value by 100)

    {$IFNDEF PDI_PROMOS}
    LineOut('');
    LineOut('Mix Match');
    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('SELECT MS.MMNo, Sum(MS.DlyCount) DlyCount, ');
      SQL.Add('Sum(MS.DlyAmount) DlyAmount, Min(MM.Name) Name FROM MixMatchShift MS, MixMatch MM ');
      SQL.Add('WHERE DayID = :pDayID and MS.MMNo = MM.MMNo ');
      AddTSsql(SQL, 'MS', TerminalNo, ShiftNo, bConsolidateShifts);
      SQL.Add('GROUP BY MS.MMNo ORDER BY MS.MMNo');
      parambyname('pDayId').AsInteger := DayId;
      AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
      ExecQuery;
      if bLogging then UpdateZlog('Daily Sales Report Open - M&M');
      while Not EOF do
      begin
        if FieldByName('DlyCount').AsInteger > 0 then
        begin
          PrintDSTotals(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger, FieldByName('DlyAmount').AsCurrency);
          TotalMM := TotalDisc + FieldByName('DlyAmount').AsCurrency;
        end;
        Next;
      end;  {while Not EOF}
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - M&M');
    end; {with TempQuery}

    LineOut('');
    if FieldByName('DlyDS').AsCurrency <> 0 then
      LineOut('Mix Match as % of Total Sales = ' +
       FormatFloat('##0.00%', ( Abs(TotalMM)/ FieldByName('DlyDS').AsCurrency)) );

    LineOut('');
    if FieldByName('DlyDS').AsCurrency <> 0 then
      LineOut('TL Disc as % of Total Sales = ' +
       FormatFloat('##0.00%', ( Abs(TotalDisc + TotalMM) / FieldByName('DlyDS').AsCurrency)) );
    {$ENDIF}
    LineOut('');

    InsideSales := POSDataMod.IBRptSQL02Main.FieldByName('DlyND').AsCurrency;
    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('select sum(dlysales) fuelsales from depshift ds, dept d, grp g ');
      SQL.Add('where ds.dayid = :pDayId and ds.deptno = d.deptno and d.grpno = g.grpno and g.fuel = 1');
      AddTSsql(SQL, 'ds', TerminalNo, ShiftNo, bConsolidateShifts);
      AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
      parambyname('pDayId').AsInteger := DayId;
      ExecQuery;
      if bLogging then UpdateZlog('Daily Sales Report Open - Fuel');
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('FuelSales').AsCurrency;
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - Fuel');
    end;

    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('select sum(dlysales) LotterySales from depshift ds, dept d ');
      SQL.Add('where ds.dayid = :pDayId and ds.deptno = d.deptno and d.grpno = 100');
      AddTSsql(SQL, 'ds', TerminalNo, ShiftNo, bConsolidateShifts);
      AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
      parambyname('pDayId').AsInteger := DayId;
      ExecQuery;
      if bLogging then UpdateZlog('Daily Sales Report Open - Lottery');
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('LotterySales').AsCurrency;
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - Lottery');
    end;

    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('select sum(dlysales) MoneyOrderSales from depshift ds, dept d ');
      SQL.Add('where ds.dayid = :pDayId and ds.deptno = d.deptno and d.grpno = 500');
      AddTSsql(SQL, 'ds', TerminalNo, ShiftNo, bConsolidateShifts);
      AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
      parambyname('pDayId').AsInteger := DayId;
      ExecQuery;
      if bLogging then UpdateZlog('Daily Sales Report Open - MO');
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('MoneyOrderSales').AsCurrency;
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - MO');
    end;

    PrintDSTotals('Inside Sales',  0, InsideSales);

    FuelGallons := 0;
    with POSDataMod.IBRptSQL02Sub1 do
    begin
      Assert(not open, 'IBRptSQL02Sub1 is open');
      SQL.Clear;
      SQL.Add('select sum(dlycount) FuelGallons from depshift ds, dept d ');
      SQL.Add('where ds.dayid = :pDayId and ds.deptno = d.deptno and d.grpno = 99');
      AddTSsql(SQL, 'ds', TerminalNo, ShiftNo, bConsolidateShifts);
      AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
      parambyname('pDayId').AsInteger := DayId;
      ExecQuery;
      if bLogging then UpdateZlog('Daily Sales Report Open - Gallons');
      if NOT Eof then
        FuelGallons := FieldByName('FuelGallons').AsCurrency;
      Close;
      if bLogging then UpdateZlog('Daily Sales Report Close - Gallons');
    end;

    PrintDSTotals('Fuel Gallons ', 0, FuelGallons);

    ReportFtr;

    if bLogging then UpdateZlog('Daily Sales Report Close');
    Close; {IBRptSQL02Main}

  end; {with POSDataMod.IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure DailySalesReport}

//20060706...
function PrintDiscTotals(const DayId         : integer;
                         const TerminalNo    : integer;
                         const ShiftNo       : integer;
                         const bFuelDiscOnly : boolean;
                         const bConsolidateShifts : boolean) : currency;
var
  TotalDiscount : currency;
  bNeedFuelDiscHeader : boolean;
begin
  TotalDiscount := 0.0;
  bNeedFuelDiscHeader := bFuelDiscOnly;
  with POSDataMod.IBRptSQL02Sub1 do
  begin
    Assert(Transaction.InTransaction, 'IBRptSQL02Sub1 transaction not started');
    Assert(not open, 'IBRptSQL02Sub1 is open');
    SQL.Clear;
    {$IFDEF PDI_PROMOS}
    SQL.Add('SELECT PS.PromoNo, Count(PS.PromoNo) PromoCount, Sum(PS.DlyCount) DlyCount, ');
    SQL.Add('Sum(PS.DlyAmount) DlyAmount, Min(P.PromoName) Name FROM PromoShift PS, PROMOTIONS P ' );
    SQL.Add('WHERE ps.dayid = :pDayId and PS.PromoNo = P.PromoNo ');
    AddTSsql(SQL, 'PS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY PS.PromoNo ORDER BY PS.PromoNo');
    {$ELSE}
    SQL.Add('SELECT DS.DiscNo, Sum(DS.DlyCount) DlyCount, ');
    SQL.Add('Sum(DS.DlyAmount) DlyAmount, Min(D.Name) Name FROM DiscShift DS, Disc D ' );
    SQL.Add('WHERE ds.dayid = :pDayId and DS.DiscNo = D.DiscNo ');
    if (bFuelDiscOnly) then
      SQL.Add('and D.RecType = ''F''');
    AddTSsql(SQL, 'DS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY DS.DiscNo ');
    SQL.Add('ORDER BY DS.DiscNo');
    {$ENDIF}
    AddTSparams(POSDataMod.IBRptSQL02Sub1, TerminalNo, ShiftNo);
    parambyname('pDayId').AsInteger := DayId;
    if bLogging then UpdateZlog('Daily Sales Report Open - Discount');
    ExecQuery;
    while Not EOF do
    begin
      if FieldByName('DlyCount').AsInteger > 0 then
      begin
        if (bNeedFuelDiscHeader) then
        begin
          bNeedFuelDiscHeader := False;
          LineOut('');
          LineOut('  ****** Discount Totals for Fuel ***** ');
          LineOut('           Name         Count     Amount');
          LineOut(' -------------------------------------- ');
        end;
        //20070312... Adjust counts and amounts for multi List Promotions
        {$IFDEF PDI_PROMOS}
        PrintDSTotals(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger / FieldByName('PromoCount').AsInteger, FieldByName('DlyAmount').AsCurrency / FieldByName('PromoCount').AsInteger);
        TotalDiscount := TotalDiscount + FieldByName('DlyAmount').AsCurrency / FieldByName('PromoCount').AsInteger;
        {$ELSE}
        PrintDSTotals(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger, FieldByName('DlyAmount').AsCurrency);
        TotalDiscount := TotalDiscount + FieldByName('DlyAmount').AsCurrency;
        {$ENDIF}
        //...20070312
      end;
      Next;
    end;  {while Not EOF}
   Close;
   if bLogging then UpdateZlog('Daily Sales Report Close - Discount');
  end; {with TempQuery}
  PrintDiscTotals := TotalDiscount;
end;  // function PrintDiscTotals
//...20060706

{-----------------------------------------------------------------------------
  Name:      PrintDSTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: sCaption: shortstring; nQty: Double; nAmount: Double
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintDSTotals(sCaption: shortstring; nQty: Double; nAmount: Double);
begin
  LineOut( Format('%-20.20s %7s %11s',[sCaption,
   FormatFloat('###,###', nQty),
   FormatFloat('###,###.00 ;###,###.00-', nAmount)]));
end; {procedure PrintDSTotals}


{-----------------------------------------------------------------------------
  Name:      GroupSalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure GroupSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  nTotalQty   : Double;
  nTotalSales : Double;
  nGroupQty   : Double;
  nGroupSales : Double;

  sLastGrp : shortstring;
  sQtyStr : shortstring;
  TmpStr : string;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  nTotalQty   := 0;
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT D.GrpNo, DS.DeptNo, Min(D.Name) DeptName, ');
    SQL.Add('Min(G.Name) GrpName, Min(G.Fuel) GrpFuel, Sum(DS.DlyCount) DlyCount, ');
    SQL.Add('Sum(DS.DlySales) DlySales ');
    SQL.Add('FROM DEPSHIFT DS, DEPT D, GRP G ');
    SQL.Add('WHERE DS.DayId = :pDayId and DS.DeptNo = D.DeptNo And D.GrpNo = G.GrpNo And DS.DlySales <> 0 ');
    AddTSsql(SQL, 'DS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY D.GrpNo, DS.DeptNo ORDER BY D.GrpNo, DS.DeptNo ');
    parambyname('pDayId').AsInteger := DayId;
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    if bLogging then UpdateZlog('Group Report Open');
    if Recordcount > 0 then
      sLastGrp := FieldByName('GrpName').AsString
    else
      sLastGrp := 'NO GROUP SALES';

    TmpStr := 'Group Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut('Group / Category  Qty         Sales Amt');
    LineOut('----------------- ----------- ----------');

    LineOut( sLastGrp );
    nGroupQty   := 0;
    nGroupSales := 0;
    nTotalSales := 0;
    while not EOF do {Begin Processing Query}
    begin

      if FieldByName('GrpFuel').AsInteger = 1 then  {Qty Format String 1=Fuel}
        sQtyStr := '###,###.000'
      else
        sQtyStr := '###,###,###';

      LineOut( Format( '  %-15.15s %11s %11s',[FieldByName('DeptName').AsString,
       FormatFloat( sQtyStr, FieldByName('DlyCount').AsCurrency),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nGroupQty   := nGroupQty + FieldByName('DlyCount').AsCurrency;
      nGroupSales := nGroupSales + FieldByName('DlySales').AsCurrency;
      nTotalQty   := nTotalQty + FieldByName('DlyCount').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;

      Next;

      {Check to Print Group Footer/Header}
      if EOF or (sLastGrp <> FieldByName('GrpName').AsString) then {End Of Group}
      begin {Print Group Footer}
        LineOut( Format( '  %15.15s %11s %11s',['Group Total:',
         FormatFloat( sQtyStr, nGroupQty),
         FormatFloat('###,###.00 ;###,###.00-',nGroupSales)]));

        if not EOF then
        begin {Reset & Print Group Header}
          sLastGrp := FieldByName('GrpName').AsString;
          nGroupQty   := 0;
          nGroupSales := 0;
          LineOut('');
          LineOut(sLastGrp);
        end;
      end; {sLastGrp <> GrpName}

    end; {while not EOF}
    {Print Report Footer}

    LineOut('');
    LineOut( Format( '  %15.15s %11s %11s',['REPORT TOTAL:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    ReportFtr;


    if bLogging then UpdateZlog('Group Report Close');
    Close; {IBRptSQL02Main}
  end; {with IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure GroupSalesReport}


{-----------------------------------------------------------------------------
  Name:      CategorySalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CategorySalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  nTotalSales : Double;
  TmpStr : string;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    // Build SQL Statement
    Assert(not Open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('SELECT DS.DeptNo, Min(D.Name) DeptName, Sum(DS.DlyCount) DlyCount, ');
    SQL.Add('Sum(DS.DlySales) DlySales, Min(D.GrpNo) GroupNo, Min(G.Fuel) GrpFuel ');
    //SQL.Add('Sum(DS.DlySales) DlySales, Min(G.Fuel) GrpFuel ');
    SQL.Add('FROM DepShift DS, Dept D, Grp G ');
    SQL.Add('WHERE DS.DayId = :pDayId and DS.DeptNo = D.DeptNo And D.GrpNo = G.GrpNo ');
    AddTSsql(SQL, 'DS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY DS.DeptNo ');
    SQL.Add('ORDER BY DS.DeptNo ');
    parambyname('pDayId').AsInteger := DayId;
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    if bLogging then UpdateZlog('Category Report Open');
    TmpStr := 'Dept Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut('');
    LineOut('#    Description     Qty     Sales Amt');
    LineOut('---- --------------- ------- -----------');
    nTotalSales := 0;

    //DeptList := Tlist.Create;

    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('GrpFuel').AsInteger = 1 then  {Qty Format String 1=Fuel}
      begin
        LineOut( Format( '%4d %-11.11s %11s %11s',[FieldByName('DeptNo').AsInteger,
         FieldByName('DeptName').Value,
         FormatFloat( '###,###.000', FieldByName('DlyCount').AsCurrency),
         FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));
         {New(DeptRec);
         DeptRec^.DeptName := FieldByName('DeptName').Value;
         DeptRec^.DeptNo := FieldByName('DeptNo').AsInteger;
         DeptRec^.DeptDlyCount := FieldByName('DlyCount').AsCurrency;
         DeptRec^.DeptDlySales := FieldByName('DlySales').AsCurrency;
         DeptRec^.DeptGroupNo := fieldbyname('GroupNo').AsInteger;
         DeptList.Add(DeptRec);}
      end
      else
      begin
        LineOut( Format( '%4d %-15.15s %7s %11s',[FieldByName('DeptNo').AsInteger,
         FieldByName('DeptName').Value,
         FormatFloat( '###,###', FieldByName('DlyCount').AsInteger),
         FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));
      end;

      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;

      Next;

    end; {while not EOF}
    {Print Report Footer}
    LineOut( '---- --------------- ------- -----------');
    LineOut( Format( '     %15.15s %7s %11s',['REPORT TOTAL:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    ReportFtr;


    if bLogging then UpdateZlog('Category Report Close');
    Close; {IBRptSQL02Main}
  end; {with IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure CategorySalesReport}

{-----------------------------------------------------------------------------
  Name:      MediaSalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure MediaSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  nTotalSales : Double;
  TmpStr : string;
  nDeclinedSum : Double;
  nDeclinedCount : Integer;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT MS.MediaNo, Min(M.Name) Name, ');
    SQL.Add('Sum(MS.DlyCount) DlyCount, Sum(MS.DlySales) DlySales ');
    SQL.Add('FROM MEDSHIFT MS, MEDIA M ');
    SQL.Add('WHERE MS.DayId = :pDayId and MS.MediaNo = M.MediaNo ');
    AddTSsql(SQL, 'MS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY MS.MediaNo ');
    SQL.Add('ORDER BY MS.MediaNo ');
    parambyname('pDayId').AsInteger := DayId;
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    if bLogging then UpdateZlog('Media Report Open');
    TmpStr := 'Media Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut( '#    Description     Qty     Sales Amt');
    LineOut( '---- --------------- ------- -----------');
    nTotalSales := 0;

    //MediaList := TList.Create;

    while not EOF do {Begin Processing Query}
    begin

      LineOut( Format( '%4d %-15.15s %7s %11s',[FieldByName('MediaNo').AsInteger,
       FieldByName('Name').Value,
       FormatFloat( '###,###', FieldByName('DlyCount').AsInteger),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;

      Next;

    end; {while not EOF}
    Close; {IBRptSQL02Main}
    //Deduct declined offline transactions
    if (TerminalNo = 0) and (ShiftNo = 0) and (nCreditAuthType = CDTSRV_FIFTH_THIRD) then
    begin
      Assert(not open, 'IBRptSQL02Main is open');
      SQL.Clear;
      SQL.Add('Select Sum(Amount) as DeclinedSum, Count(*) from CCBatch B ');
      SQL.Add('inner join CCRtb R on B.BatchID = R.BatchID where ');
      SQL.Add('(R.DayID = :pDayId) ');
      SQL.Add('and B.HostID = :pHostID and B.CardType <> ''04'' and B.BatchNo=0 and ');
      SQL.Add('B.LocalApproved=1 and B.TransGroup=1');
      parambyname('pDayId').AsInteger := DayId;
      parambyname('pHostID').AsInteger := CDTSRV_FIFTH_THIRD;
      ExecQuery;
      try
        //20060531...
        if FieldByName('DeclinedSum').AsString = '' then
          nDeclinedSum := 0
        else
        //...20060531
          nDeclinedSum := FieldByName('DeclinedSum').AsCurrency * -1;
        nDeclinedCount := FieldByName('Count').AsInteger;
      except
        nDeclinedSum := 0;
        nDeclinedCount := 0;
      end;
      Close;
      if nDeclinedCount > 0 then
      begin
        LineOut( Format( '%4d %-15.15s %7s %11s',[100,
         'Uncap Credit',
         FormatFloat( '###,###', nDeclinedCount),
         FormatFloat('###,###.00 ;###,###.00-',nDeclinedSum)]));
        nTotalSales := nTotalSales + nDeclinedSum;
      end;
      SQL.Clear;
      SQL.Add('Select Sum(Amount) as DeclinedSum, Count(*) from CCBatch B ');
      SQL.Add('inner join CCRtb R on B.BatchID = R.BatchID where ');
      SQL.Add('(R.DayID = :pDayId) ');
      SQL.Add('and B.HostID = :pHostID and B.CardType = ''04'' and B.BatchNo=0 and ');
      SQL.Add('B.LocalApproved=1 and B.TransGroup=1');
      parambyname('pDayId').AsInteger := DayId;
      parambyname('pHostID').AsInteger := CDTSRV_FIFTH_THIRD;
      ExecQuery;
      try
        //20060531...
        if FieldByName('DeclinedSum').AsString = '' then
          nDeclinedSum := 0
        else
        //...20060531
          nDeclinedSum := FieldByName('DeclinedSum').AsCurrency * -1;
        nDeclinedCount := FieldByName('Count').AsInteger;
      except
        nDeclinedSum := 0;
        nDeclinedCount := 0;
      end;
      if nDeclinedCount > 0 then
      begin
        LineOut( Format( '%4d %-15.15s %7s %11s',[101,
         'Uncap Debit',
         FormatFloat( '###,###', nDeclinedCount),
         FormatFloat('###,###.00 ;###,###.00-',nDeclinedSum)]));
        nTotalSales := nTotalSales + nDeclinedSum;
      end;
      Close;
    end;



    {Print Report Footer}
    LineOut( '---- --------------- ------- -----------');
    LineOut( Format( '     %15.15s %7s %11s',['REPORT TOTAL:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    ReportFtr;


    if bLogging then UpdateZlog('Media Report Close');
  end; {with IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure MediaSalesReport}


{-----------------------------------------------------------------------------
  Name:      BankSalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure BankSalesReport(DayId, TerminalNo, ShiftNo: Integer; const bConsolidateShifts : boolean);
var
  nTotalSales : Double;
  TmpStr : string;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    Assert(not Open, 'IBRptSQL02Main is open');
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT BS.BankNo, Min(B.Name) Name, ');
    SQL.Add('Sum(BS.DlyCount) DlyCount, Sum(BS.DlySales) DlySales ');
    SQL.Add('FROM BANKSHIFT BS, BANKFUNC B ');
    SQL.Add('WHERE bs.dayid = :pDayId and BS.BankNo = B.BankNo ');
    AddTSsql(SQL, 'BS', TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY BS.BankNo ');
    SQL.Add('ORDER BY BS.BankNo ');
    parambyname('pDayId').AsInteger := DayId;
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;
    if bLogging then UpdateZlog('Bank Report Open');
    TmpStr := 'Bank Functions - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

    LineOut( '#    Description     Qty     Sales Amt');
    LineOut( '---- --------------- ------- -----------');
    nTotalSales := 0;

    while not EOF do {Begin Processing Query}
    begin
      LineOut( Format( '%4d %-15.15s %7s %11s',[FieldByName('BankNo').AsInteger,
       FieldByName('Name').AsString,
       FormatFloat( '###,###', FieldByName('DlyCount').AsInteger),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      Next;

    end; {while not EOF}
    Close;
    {Print Report Footer}
    LineOut( '---- --------------- ------- -----------');
    LineOut( Format( '     %15.15s %7s %11s',['REPORT TOTAL:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    ReportFtr;


    if bLogging then UpdateZlog('Bank Report Close');
    Close;SQL.Clear;
  end; {with IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure BankSalesReport}


{-----------------------------------------------------------------------------
  Name:      PrintFuelMeterReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintFuelMeterReport(const DayId : integer);
var

  aHTls    : array[1..20,1..2] of Currency;
  aGTls   : array[1..20,1..2] of Currency;
  aPTls : array[1..20,1..2] of Currency;

  nHIdx, nCurPump: Integer;
  nPct : double;
  sLn: shortstring;
  intrans : boolean;
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
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
    SQL.Add('WHERE t.dayid = :pDayId and t.TlNo = :pFuelTotalID ' );
    SQL.Add('AND T.PumpNo = D.PumpNo AND T.HoseNo = D.HoseNo ');
    SQL.Add('AND D.GradeNo = G.GradeNo ');
    SQL.Add('ORDER BY T.PumpNo, T.HoseNo');
    parambyname('pFuelTotalID').AsInteger := nFuelTotalID;
    parambyname('pDayId').AsInteger := DayId;
    ExecQuery;
    if bLogging then UpdateZlog('Meter Report Open');
    ReportHdr('Fuel Totals - Store');

    LineOut( 'Pump Hose Grade Volume       Dollars');
    LineOut( '---- ---- ----- ------------ -----------');


    nCurPump := 0;
    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('PumpNo').AsInteger <> nCurPump then
      begin
        sLn := Format( '%4d ',[FieldByName('PumpNo').AsInteger]);
        nCurPump := FieldByName('PumpNo').AsInteger;
      end
      else
        sLn := '     ';

      sLn := sLn + Format( '%4d ',[FieldByName('HoseNo').AsInteger]) +
        Format( '%-3.3s   ',[FieldByName('Name').AsString]) +
        Format( '%12s ' , [FormatFloat('###,###.000 ;###,###.000-',FieldByName('VolumeTl').AsCurrency)]) +
        Format( '%11s' , [FormatFloat('###,###.00 ;###,###.00-',(FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency))]);
      LineOut( sLn );
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
    if bLogging then UpdateZlog('Meter Report Close');
    {Print Report Footer}
    LineOut('');
    LineOut('HOSE TOTALS:');
    for nHIdx := 1 to 10 do
      if (aHTls[nHIdx, 1] > 0) then         // Volume > 0
        Lineout( '     ' +
         Format( '%4d ',[nHIdx]) + '      ' +
         Format( '%12s ' , [FormatFloat('###,###.000 ;###,###.000-',aHTls[nHIdx,1])]) +
         Format( '%11s' , [FormatFloat('###,###.00 ;###,###.00-',aHTls[nHIdx,2])])) ;

    // Build SQL Statement
    SQL.Text := 'SELECT * FROM Grade ORDER BY GradeNo';
    ExecQuery;

    LineOut('');
    LineOut('GRADE TOTALS:');

    while not EOF do {Begin Processing Query}
    begin
      nHIdx := FieldByName('GradeNo').AsInteger;
      if (nHIdx > 0) and (nHIdx < 21) then
      begin
        Lineout(
         Format( ' %-14.14s ', [FieldByName('Name').AsString]) +
         Format( '%12s ' , [FormatFloat('###,###.000 ;###,###.000-',aGTls[nHIdx,1])]) +
         Format( '%11s' , [FormatFloat('###,###.00 ;###,###.00-',aGTls[nHIdx,2])])) ;
      end;

      Next;
    end; {while not EOF}
    Close;

    // Build SQL Statement
    SQL.Text := 'SELECT * FROM Product ORDER BY ProdNo';
    ExecQuery;

    LineOut('');
    LineOut('PRODUCT TOTALS:');

    while not EOF do {Begin Processing Query}
    begin
      nHIdx := FieldByName('ProdNo').AsInteger;
      if (nHIdx > 0) and (nHIdx < 21) then
      begin
        Lineout(
         Format( ' %-14.14s ', [FieldByName('Name').AsString]) +
         Format( '%12s ' , [FormatFloat('###,###.000 ;###,###.000-',aPTls[nHIdx,1])]) +
         Format( '%11s' , [FormatFloat('###,###.00 ;###,###.00-',aPTls[nHIdx,2])])) ;
      end;

      Next;
    end; {while not EOF}
    Close;

    ReportFtr;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure FuelMeter Report}


{-----------------------------------------------------------------------------
  Name:      PrintFuelTotalsReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintFuelTotalsReport(const DayId : integer) ;
var
  sLn: shortstring;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT Min(D.DeptNo) DeptNo, Min(D.Name) Name, Sum(DlyCount) DlyCount, ');
    SQL.Add('Sum(DlySales) DlySales FROM DepShift DS, ' );
    SQL.Add('Dept D, Grp G Where ds.DayId = :pDayId and ((DS.DeptNo = D.DeptNo) AND (D.GrpNo = G.GrpNo)) ');
    SQL.Add('AND G.Fuel = 1 GROUP BY D.DeptNo ORDER BY D.DeptNo ');
    ParamByName('pDayId').AsInteger := DayId;
    ExecQuery;
    if bLogging then UpdateZlog('Fuel Totals Report Open');
    ReportHdr('Fuel Sales Totals - Store');

    LineOut( 'Dept Name       Volume       Dollars');
    LineOut( '---- ---------- ------------ -----------');

    while not EOF do {Begin Processing Query}
    begin
      sLn := Format( '%4d ', [FieldByName('DeptNo').AsInteger]) +
        Format( '%-10.10s ', [FieldByName('Name').AsString]) +
        Format( '%12s ' , [FormatFloat('###,###.000 ;###,###.000-',FieldByName('DlyCount').AsCurrency)]) +
        Format( '%11s' , [FormatFloat('###,###.00 ;###,###.00-',(FieldByName('DlySales').AsCurrency))]);
      LineOut( sLn );
      Next;
    end; {while not EOF}
    Close;
    if bLogging then UpdateZlog('Fuel Totals Report Close');
    // Build SQL Statement
    SQL.Text := 'SELECT * FROM Grade Order By GradeNo ';
    ExecQuery;
    if bLogging then UpdateZlog('NR Fuel Totals Report Open');
    LineOut( ' ');
    LineOut('NR Fuel Grade Totals ');
    LineOut( ' ');
    LineOut( 'Grade   Name        Price');
    LineOut( '       Volume               Dollars');
    LineOut( '----------------------------------------');
    while not EOF do {Begin Processing Query}
    begin
      sLn := Format( '%4d ',[FieldByName('GradeNo').AsInteger]) +
        Format( '%-10.10s ',[FieldByName('Name').AsString]) +
        Format( '%10s',[FormatFloat('###,###.000 ;###,###.000-',FieldByName('CashPrice').AsCurrency) ]);
      LineOut( sLn );
      sLn :=  Format( '%19s ' , [FormatFloat('###,###.000 ;###,###.000-',FieldByName('TLVol').AsCurrency)]) +
        Format( '%19s' , [FormatFloat('###,###.00 ;###,###.00-',(FieldByName('TLAmount').AsCurrency))]);
      LineOut( sLn );
      Next;
    end; {while not EOF}
    Close;
    if bLogging then UpdateZlog('NE Fuel Totals Report Close');
    ReportFtr;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure FuelTotals Report}


procedure PrintFailedToActivateReport(const DayId : integer; const ReportRegNo : integer; const ReportShift : integer);
var
  ReportTransNo : integer;
  IdxRegNo : integer;
  IdxShift : integer;
  IdxTime : integer;
  IdxUser : integer;
  ItemRegNo : integer;
  ItemShift : integer;
  ReceiptSeqLine : string;
  TmpStr : string;
  CardNo : string;
  LineID : integer;
  bSkipRecord : boolean;
  intrans : boolean;
begin
  if bLogging then
    UpdateZlog('Activation Void Report Open');
  TmpStr := 'Failed Activation - ';
  if (ReportRegNo > 0) then
    TmpStr := TmpStr + 'REG' + IntToStr(ReportRegNo);
  if (ReportShift > 0) then
    TmpStr := TmpStr + ' S#' + IntToStr(ReportShift) ;
  ReportHdr(TmpStr);
  TmpStr := '----------------------------------------';
  LineOut(TmpStr);

  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;

  with POSDataMod.IBRptSQL03Main do
  begin
    Assert(not open, 'IBRptSQL03Main is open');
    Assert(not POSDataMod.IBRptSQL03Sub1.open, 'IBRptSQL03Sub1 is open');
    Assert(not POSDataMod.IBRptSQL03Sub2.open, 'IBRptSQL03Sub2 is open');
    Assert(not POSDataMod.IBRptSQL03Sub3.open, 'IBRptSQL03Sub3 is open');
    try
      POSDataMod.IBRptSQL03Sub2.SQL.Clear();
      POSDataMod.IBRptSQL03Sub2.SQL.Add('select LineType from receipt where dayid = :pDayId and LineType = :pLineType and TransactionNo = :pTransactionNo  and SeqNumber = :pSeqNumber');
      POSDataMod.IBRptSQL03Sub2.ParamByName('pDayId').AsInteger := DayId;
      POSDataMod.IBRptSQL03Sub2.ParamByName('pLineType').AsString := SALE_DATA_LINE_TYPE_MESSAGE;
      POSDataMod.IBRptSQL03Sub3.SQL.Clear();
      POSDataMod.IBRptSQL03Sub3.SQL.Add('select CCPrintLine1, CCPrintLine2 from receipt where dayid = :pDayId and SaleType = :pSaleType and LineID = :pLineID');
      POSDataMod.IBRptSQL03Sub3.ParamByName('pDayId').AsInteger := DayId;
      POSDataMod.IBRptSQL03Sub3.ParamByName('pSaleType').AsString := 'Sale';
      POSDataMod.IBRptSQL03Sub1.Close();
      POSDataMod.IBRptSQL03Sub1.SQL.Clear();
      POSDataMod.IBRptSQL03Sub1.SQL.Add('select Data from PosLog where dayid = :pDayId and LogNo = :pLogNo and RecType = :pRecType');
      POSDataMod.IBRptSQL03Sub1.ParamByName('pDayId').AsInteger := DayId;
      POSDataMod.IBRptSQL03Sub1.ParamByName('pRecType').AsString := 'SEQ';
      Close();
      SQL.Clear();
      SQL.Add('select * from receipt where DayId = :pDayId and SaleType = :pSaleType and ((CCCardType = :pCT1) or (CCCardType = :pCT2) or (CCCardType = :pCT3)) order by TransactionNo');
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pSaleType').AsString := 'Void';
      ParamByName('pCT1').AsString := CT_STORE_VALUE;
      ParamByName('pCT2').AsString := CT_PUSH_PIN;
      ParamByName('pCT3').AsString := CT_PHONE;
      ExecQuery();
      while not EOF do
      begin
        ItemRegNo := 0;
        ItemShift := 0;
        ReportTransNo := FieldByName('TransactionNo').AsInteger;

        ReceiptSeqLine := '';
        if (ReportTransNo > 0) then
        begin
          // Get additional transaction information from POSLog DB table:
          POSDataMod.IBRptSQL03Sub1.ParamByName('pLogNo').AsInteger := ReportTransNo;
          POSDataMod.IBRptSQL03Sub1.ExecQuery();
          if (not POSDataMod.IBRptSQL03Sub1.EOF) then
          begin
            ReceiptSeqLine := POSDataMod.IBRptSQL03Sub1.FieldByName('Data').AsString;
            // Extract shift and register numbers from logged receipt sequence line.
            IdxRegNo := Pos('Reg', ReceiptSeqLine);
            if (IdxRegNo > 0) then
            begin
              try
                ItemRegNo := StrToInt(Trim(Copy(ReceiptSeqLine, IdxRegNo + 4, 3)));
              except
                ItemRegNo := 0;
              end;
            end
            else
            begin
              ItemRegNo := 0;
            end;
            IdxShift := Pos('Shift', ReceiptSeqLine);
            if (IdxShift > 0) then
            begin
              try
                ItemShift := StrToInt(Trim(Copy(ReceiptSeqLine, IdxShift + 6, 3)));
              except
                ItemShift := 0;
              end;
            end
            else
            begin
              ItemShift := 0;
            end;
          end;
          POSDataMod.IBRptSQL03Sub1.Close();
        end;

        // Check to see if this item matches RegNo/Shift for report (zero implies no check)
        if (((ItemRegNo = ReportRegNo) or (ReportRegNo = 0) or (ItemRegNo = 0)) and
            ((ItemShift = ReportShift) or (ReportShift = 0) or (ItemShift = 0))) then
        begin
          {
          Some voided activation products do not need to be reported
          (for example, cards declined because they were already active or
          items that were simply error corrected off the sales list prior to activation.
          Skip these items)
          }
          POSDataMod.IBRptSQL03Sub2.ParamByName('pTransactionNo').AsInteger := ReportTransNo;
          POSDataMod.IBRptSQL03Sub2.ParamByName('pSeqNumber').AsInteger := FieldByName('SeqNumber').AsInteger + 1;
          POSDataMod.IBRptSQL03Sub2.ExecQuery();
          bSkipRecord := POSDataMod.IBRptSQL03Sub2.Eof;
          POSDataMod.IBRptSQL03Sub2.Close();
          if (bSkipRecord) then
          begin
            Next();
            continue;
          end;
          // Decrypt card number
          CardNo := Trim(FieldbyName('CCCardNo').AsString);
          // Format report record
          LineOut('Product: ' + FieldByName('SaleName').AsString);
          if (Trim(FieldByName('CCAuthorizer').AsString) <> '') then
            LineOut('AuthID: ' + FieldByName('CCAuthorizer').AsString);
          LineID := FieldByName('LineID').AsInteger;
          LineOut('LineID: ' + IntToStr(LineID));
          if (CardNo <> '') then
            LineOut('CardNo: ' + CardNo);
          if (Trim(FieldByName('CCPin').AsString) <> '') then
            LineOut('Card PIN:' + FieldByName('CCPin').AsString);
          if (LineID > 0) then
          begin
            POSDataMod.IBRptSQL03Sub3.ParamByName('pLineID').AsInteger := LineID;
            POSDataMod.IBRptSQL03Sub3.ExecQuery();
            if (not POSDataMod.IBRptSQL03Sub3.Eof) then  // Message from matching original activation attemmpt.
            begin
              if (Trim(POSDataMod.IBRptSQL03Sub3.FieldByName('CCPrintLine1').AsString) <> '') then
                LineOut(POSDataMod.IBRptSQL03Sub3.FieldByName('CCPrintLine1').AsString);
              if (Trim(POSDataMod.IBRptSQL03Sub3.FieldByName('CCPrintLine2').AsString) <> '') then
                LineOut(POSDataMod.IBRptSQL03Sub3.FieldByName('CCPrintLine2').AsString);
            end;
            POSDataMod.IBRptSQL03Sub3.Close();
          end;
          LineOut('*** AUTO VOID ***');
          if (Trim(FieldByName('CCPrintLine1').AsString) <> '') then
            LineOut(FieldByName('CCPrintLine1').AsString);
          TmpStr := 'Shift #' + IntToStr(ItemShift) + ' - Register #' + IntToStr(ItemRegNo);
          IdxUser := Pos('UserID', ReceiptSeqLine);
          if (IdxUser > 0) then
            TmpStr := TmpStr + ' - ' + Copy(ReceiptSeqLine, IdxUser, 11);
          LineOut(TmpStr);
          TmpStr := 'TransNo: ' + Format('%6.6d', [ReportTransNo]);
          IdxTime := Pos('Time', ReceiptSeqLine);
          if (IdxTime > 0) then
            TmpStr := TmpStr + ' - ' + Copy(ReceiptSeqLine, IdxTime + 5, 8);
          LineOut(TmpStr);
          LineOut('');
        end;  // if terminal/shift matches
        Next();
      end;  // while not EOF
      Close();
    except
      on E : Exception do
      begin
        UpdateExceptLog( 'PrintFailedToActivateReport ' + e.message);
      end;
    end;
  end;  // with

  if bLogging then
    UpdateZlog('Activation Void Report Close');
  ReportFtr;
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end;  // procedure PrintFailedToActivateReport

{-----------------------------------------------------------------------------
  Name:      PrintPLUReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo : Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintPLUReport(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
var
  nDeptQty: Double;
  nDeptSales: Double;
  nTotalSales: Double;
  sLastDept: string[32];
  sNameStr : string;
  TmpStr : string;
  intrans : boolean;
begin
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL03Main do
  begin
    Assert(not open, 'IBRptSQL03Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT DeptNo, PLUNo, Sum(DlyCnt) As DlyCount, ');
    SQL.Add('Sum(DlySls) AS DlySales, min(PName) as Name, min(DNAME) as DeptName, ');
    //20060717b...
//    SQL.Add('Min(Modifiername) As ModifierName From PLUReport ');
    SQL.Add('Min(Modifiername) As ModName ');
    {$IFDEF PLU_MOD_DEPT}
    SQL.Add('From PLUReportDeptMod ');
    {$ELSE}
    SQL.Add('From PLUReport ');
    {$ENDIF}
    //...20060717b
    SQL.Add('Where dayid=:pDayId');
    AddTSsql(SQL, {$IFDEF PLU_MOD_DEPT}'PLUReportDeptMod'{$ELSE}'PLUReport'{$ENDIF}, TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY DeptNo, PLUNo, PName, DName, ModifierName');
    //SQL.Add('GROUP BY DeptNo, PLUNo ');
    SQL.Add('ORDER BY DeptNo, PLUNo ');
    AddTSparams(POSDataMod.IBRptSQL03Main, TerminalNo, ShiftNo);
    ParamByName('pDayId').AsInteger := DayId;
    ExecQuery;
    if bLogging then UpdateZlog('PLU Report Open');
    TmpStr := 'PLU Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

//           0123456789012345678901234567890123456789
    LineOut('Category / PLU         Qty    Sales Amt');
    LineOut('---------------------- ------ ----------');
//           1234 12345678901234567 123456 12345678901
//                                  99,999 999,999.99-
    nDeptQty := 0;
    nDeptSales  := 0;
    nTotalSales := 0;
    if RecordCount > 0 then
      sLastDept := FieldByName('DeptName').AsString
    else
      sLastDept := 'NO DEPARTMENT SALES';
    LineOut(sLastDept);

    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('ModName').AsString = '' then
        sNameStr := FieldByName('Name').AsString
      else
      begin
        with POSDataMod.IBRptSQL03Sub1 do
        begin
          SQL.Clear;
          SQL.Add('Select ModifierName as ModName from Modifier where ModifierGroup = :pModifierGroup ');
          SQL.Add('and ModifierNo = :pModifierNo');
          parambyname('pModifierGroup').AsString := POSDataMod.IBRptSQL03Main.fieldbyname('PluNo').AsString;
          parambyname('pModifierNo').AsString := POSDataMod.IBRptSQL03Main.fieldbyname('ModName').AsString;
          ExecQuery;
          if RecordCount > 0 then
            sNameStr := Trim(FieldByName('ModName').AsString) + ' ' +  POSDataMod.IBRptSQL03Main.FieldByName('Name').AsString
          else
            sNameStr := POSDataMod.IBRptSQL03Main.FieldByName('Name').AsString;
          close;
          //sNameStr := Trim(FieldByName('ModifierName').AsString) + ' ' +  FieldByName('Name').AsString;
        end;
      end;
      //LineOut( Format( '%6.6s %-17.17s %6.6s %11.11s',[
      LineOut( Format( '%12.12s %-12.12s %4.4s %9.9s',[
        FieldByName('PluNo').AsString,
        sNameStr,
        //FormatFloat( '##,###', FieldByName('DlyCount').AsCurrency),
        FormatFloat( '####', FieldByName('DlyCount').AsCurrency),
        //FormatFloat('##,###.00 ;##,###.00-',FieldByName('DlySales').AsCurrency)]));
        FormatFloat('#####.00 ;#####.00-',FieldByName('DlySales').AsCurrency)]));

      nDeptSales := nDeptSales + FieldByName('DlySales').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      nDeptQty := nDeptQty + FieldByName('DlyCount').AsCurrency;
      Next;

      if EOF or (sLastDept <> FieldByName('DeptName').AsString) then
      begin {Print Dept Footer}
        //LineOut( Format( '%6.6s %17.17s %6.6s %11.11s',['','Category Total:',
        LineOut( Format( '%12.12s %12.12s %4.4s %9.9s',['','Category Total:',
          //FormatFloat( '##,###', nDeptQty),
          FormatFloat( '####', nDeptQty),
          //FormatFloat('##,###.00 ;##,###.00-',nDeptSales)]));
          FormatFloat('#####.00 ;#####.00-',nDeptSales)]));

        if not EOF then
        begin {Reset & Print Dept Header}
          sLastDept := FieldByName('DeptName').AsString;
          nDeptQty   := 0;
          nDeptSales := 0;
          LineOut(''); LineOut(sLastDept);
        end;
      end; {sLastDept <> DeptName}

    end; {while not EOF}

    {Print Report Footer}
    LineOut('---------------------- ------ ----------');
    LineOut( Format( '%4.4s %17.17s %7s %9s',['','REPORT TOTAL:', '',
     FormatFloat('##,###.00 ;##,###.00-', nTotalSales)]));

    Close;
    if bLogging then UpdateZlog('PLU Report Close');
    ReportFtr;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
  bPrintingPLU := false;
end; {procedure PrintReport}

procedure PrintPLUReportToDisk(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
var
  nDeptQty: Double;
  nDeptSales: Double;
  nTotalSales: Double;
  sLastDept: string[32];
  sNameStr : string;
  TmpStr : string;
  intrans : boolean;
begin
  bPrintingPLU := true;
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL03Main do
  begin
    Assert(not open, 'IBRptSQL03Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT DeptNo, PLUNo, Sum(DlyCnt) As DlyCount, ');
    SQL.Add('Sum(DlySls) AS DlySales, min(PName) as Name, min(DNAME) as DeptName, ');
    //20060717b...
//    SQL.Add('Min(Modifiername) As ModifierName From PLUReport ');
    SQL.Add('Min(Modifiername) As ModName ');
    {$IFDEF PLU_MOD_DEPT}
    SQL.Add('From PLUReportDeptMod ');
    {$ELSE}
    SQL.Add('From PLUReport ');
    {$ENDIF}
    //...20060717b
    SQL.Add('Where DayId=:pDayId');
    AddTSsql(SQL, {$IFDEF PLU_MOD_DEPT}'PLUReportDeptMod'{$ELSE}'PLUReport'{$ENDIF}, TerminalNo, ShiftNo, bConsolidateShifts);
    SQL.Add('GROUP BY DeptNo, PLUNo, PName, DName, ModifierName');
    //SQL.Add('GROUP BY DeptNo, PLUNo ');
    SQL.Add('ORDER BY DeptNo, PLUNo ');
    AddTSparams(POSDataMod.IBRptSQL03Main, TerminalNo, ShiftNo);
    ParamByName('pDayId').AsInteger := DayId;

    ExecQuery;
    if bLogging then UpdateZlog('PLU Report Open');
    TmpStr := 'PLU Sales - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    Print2Disk( '========================================');
    Print2Disk( 'Report : ' + TmpStr);
    Print2Disk( 'Report Date  : ' + DateToStr(Date));
    Print2Disk( 'Report Time  : ' + TimeToStr(Time));
    Print2Disk( 'User  : ' + CurrentUserID + ' ' + CurrentUser);
    Print2Disk( '----------------------------------------');

//           0123456789012345678901234567890123456789
    Print2Disk('Category / PLU         Qty    Sales Amt');
    Print2Disk('---------------------- ------ ----------');
//           1234 12345678901234567 123456 12345678901
//                                  99,999 999,999.99-
    nDeptQty := 0;
    nDeptSales  := 0;
    nTotalSales := 0;
    if RecordCount > 0 then
      sLastDept := FieldByName('DeptName').AsString
    else
      sLastDept := 'NO DEPARTMENT SALES';
    Print2Disk(sLastDept);

    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('ModName').AsString = '' then
        sNameStr := FieldByName('Name').AsString
      else
      begin
        with POSDataMod.IBRptSQL03Sub1 do
        begin
          Assert(not open, 'IBRptSQL03Sub1 is open');
          SQL.Clear;
          SQL.Add('Select ModifierName as ModName from Modifier where ModifierGroup = :pModifierGroup ');
          SQL.Add('and ModifierNo = :pModifierNo');
          parambyname('pModifierGroup').AsString := POSDataMod.IBRptSQL03Main.fieldbyname('PluNo').AsString;
          parambyname('pModifierNo').AsString := POSDataMod.IBRptSQL03Main.fieldbyname('ModName').AsString;
          execquery;
          if RecordCount > 0 then
            sNameStr := Trim(FieldByName('ModName').AsString) + ' ' +  POSDataMod.IBRptSQL03Main.FieldByName('Name').AsString
          else
            sNameStr := POSDataMod.IBRptSQL03Main.FieldByName('Name').AsString;
          close;
          //sNameStr := Trim(FieldByName('ModifierName').AsString) + ' ' +  FieldByName('Name').AsString;
        end;
      end;
      Print2Disk( Format( '%12.12s %-15.15s %4.4s %9.9s',[
        FieldByName('PluNo').AsString,
        sNameStr,
        //FormatFloat( '##,###', FieldByName('DlyCount').AsCurrency),
        FormatFloat( '####', FieldByName('DlyCount').AsCurrency),
        //FormatFloat('##,###.00 ;##,###.00-',FieldByName('DlySales').AsCurrency)]));
        FormatFloat('#####.00 ;#####.00-',FieldByName('DlySales').AsCurrency)]));

      nDeptSales := nDeptSales + FieldByName('DlySales').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      nDeptQty := nDeptQty + FieldByName('DlyCount').AsCurrency;
      Next;

      if EOF or (sLastDept <> FieldByName('DeptName').AsString) then
      begin {Print Dept Footer}
        Print2Disk( Format( '%12.12s %15.15s %4.4s %9.9s',['','Category Total:',
          //FormatFloat( '##,###', nDeptQty),
          FormatFloat( '####', nDeptQty),
          //FormatFloat('##,###.00 ;##,###.00-',nDeptSales)]));
          FormatFloat('#####.00 ;#####.00-',nDeptSales)]));

        if not EOF then
        begin {Reset & Print Dept Header}
          sLastDept := FieldByName('DeptName').AsString;
          nDeptQty   := 0;
          nDeptSales := 0;
          Print2Disk(''); Print2Disk(sLastDept);
        end;
      end; {sLastDept <> DeptName}

    end; {while not EOF}

    {Print Report Footer}
    Print2Disk('---------------------- ------ ----------');
    Print2Disk( Format( '%4.4s %17.17s %7s %12s',['','REPORT TOTAL:', '',
     FormatFloat('##,###.00 ;##,###.00-', nTotalSales)]));

    Close;
    if bLogging then UpdateZlog('PLU Report Close');
    Print2Disk('');
    Print2Disk('       ****  End Of Report  ****');
    Print2Disk(''); Print2Disk('');
    SQL.Clear;
  end; {with IBRptSQL03Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure PrintReport}



{-----------------------------------------------------------------------------
  Name:      PrintCashDropReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo : Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintCashDropReport(DayId, TerminalNo, ShiftNo : Integer; const bConsolidateShifts : boolean);
var
  nDropTl: Currency;
  TmpStr : string;
  intrans : boolean;
begin
  if TerminalNo < 0 then TerminalNo := 0;
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    if DayId = 0 then
      DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    // Build SQL Statement
    SQL.Add('SELECT * FROM CashDrop Where dayid = :pDayId');
    AddTSsql(SQL, 'CashDrop', TerminalNo, ShiftNo, bConsolidateShifts, 'DropShift');
    SQL.Add('ORDER BY TerminalNo, DropShift, DropTime');
    ParamByName('pDayId').AsInteger := DayId;
    AddTSparams(POSDataMod.IBRptSQL02Main, TerminalNo, ShiftNo);
    ExecQuery;;
    if bLogging then UpdateZlog('Cash Drop Report Open');
    TmpStr := 'Cash Drops - ';
    if TerminalNo > 0 then
      TmpStr := TmpStr + 'Terminal ' + IntToStr(TerminalNo) + ' ';
    if ShiftNo > 0 then
      TmpStr := TmpStr + 'Shift ' + IntToStr(ShiftNo) ;
    ReportHdr(TmpStr);

//           0123456789012345678901234567890123456789
    LineOut('Drop Time Term Shift  Amount    Trans# ');
    LineOut('--------- ---- ----- -------- ---------');
//           12341234567812341123412345678123123456
//           99:99 xx   99    9   9,999.99   999999
    nDropTl  := 0;
    LineOut(' ');

    while not EOF do {Begin Processing Query}
    begin
      LineOut( Format( '%8s   %2s    %1s   %8s   %6s',[
        FormatDateTime('hh:mm am/pm', FieldByName('DropTime').AsDateTime),
        Format( '%2.1d', [FieldByName('TerminalNo').AsInteger]),
        Format( '%1.1d', [FieldByName('DropShift').AsInteger]),
        FormatFloat( '#,###.00', FieldByName('DropAmount').AsCurrency),
        Format('%6.6d', [FieldByName('DropTransNo').AsInteger])]));
      nDropTl := nDropTl + FieldByName('DropAmount').AsCurrency;
      Next;
    end; {while not EOF}
    {Print Report Footer}
    LineOut('---------------------- ------ ----------');
    LineOut( Format( '%21s%8s',['REPORT TOTAL:',
     FormatFloat('#,###.00', nDropTl)]));
    Close;
    if bLogging then UpdateZlog('Cash Drop Report Close');
    ReportFtr;
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure PrintReport}


{-----------------------------------------------------------------------------
  Name:      CCSalesReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ShiftNo: Integer; StartBatch: Integer; EndBatch: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CCSalesReport(ShiftNo: Integer; StartBatch: Integer; EndBatch: Integer);
var
  nTotalTrans : Double;
  nTotalSales : Double;
  i: Integer;
  sCardName: shortstring;
  intrans : boolean;
begin
  if ShiftNo < 0 then ShiftNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Text := 'SELECT * FROM CCSetup';
    ExecQuery;
    if bLogging then UpdateZlog('CCSales Report Open');
  end;

  with POSDataMod.IBRptSQL02Sub1 do
  begin
    Assert(not open, 'IBRptSQL02Sub1 is open');
    SQL.Clear;
    SQL.Add('SELECT CardType, Count(*) Trans, Sum(Amount) Sales FROM CCBatch ');
    SQL.Add('WHERE (HostId > 0) and BatchID BETWEEN :pStartID And :pEndID And Collected = 1 ');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');

    ParamByName('pStartID').AsInteger := StartBatch;
    ParamByName('pEndID').AsInteger := EndBatch;
    SQL.Add('GROUP BY CardType');
    SQL.Add('ORDER BY CardType');
    ExecQuery;

    if RecordCount = 0 then
      begin
        LineOut(' *** NO TRANSACTIONS *** ');
        LineOut(''); LineOut('');
      end
    else
      begin
        if ShiftNo > 0 then
          ReportHdr('Credit Card Sales - Shift# ' + IntToStr(ShiftNo))
         else
           ReportHdr('Credit Card Sales - Store');

        LineOut('Card Type            Trans    Sales');
        LineOut('-------------------- -------- -----------');

        nTotalTrans := 0;
        nTotalSales := 0;
        while not EOF do {Begin Processing Query}
        begin

          sCardName := FieldByName('CardType').AsString; // Default to CardType in CCBatch
          For i := 1 to 12 do // Get CardType (Full Name) From CCSetup
            begin
              if Copy(FieldByName('CardType').AsString,1,2) =
               Copy(POSDataMod.IBRptSQL02Main.FieldByName('CardType'+IntToStr(i)).AsString,1,2) then
                begin
                  sCardName := POSDataMod.IBRptSQL02Main.FieldByName('CardType'+IntToStr(i)).AsString;
                end;
            end; {For i}
          LineOut( Format( '%-20.20s %8.8s %11.11s', [sCardName,
           FormatFloat('###,### ;###,###-', FieldByName('Trans').AsCurrency),
           FormatFloat('###,###.00 ;###,###.00-', FieldByName('Sales').AsCurrency)]));

           nTotalTrans := nTotalTrans + FieldByName('Trans').AsCurrency;
           nTotalSales := nTotalSales + FieldByName('Sales').AsCurrency;

          Next;
        end; {while not EOF}

        {Print Report Footer}
        LineOut('-------------------- -------- -----------');
        LineOut( Format( '%20.20s %8.8s %11.11s',['REPORT TOTAL:',
         FormatFloat('###,### ;###,###-', nTotalTrans),
         FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));
      end;

    // Show Uncollected Batches
    Close;
    SQL.Text := 'SELECT BatchNo, Count(*) Trans FROM CCBatch WHERE Collected = 0 and HostID > 0';
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
    SQL.Add('GROUP BY BatchNo ');
    SQL.Add('ORDER BY BatchNo');
    ExecQuery;

    // List Uncollected Batches
    while Not EOF do
    begin
      LineOut('');
      LineOut('- BATCH: ' + IntToStr(FieldByName('BatchNo').AsInteger) +
       ' NOT COLLECTED!');
      Next;
    end; {while not EOF}
    ReportFtr;

    // Check to see if Terminal needs Service
    Close;
    SQL.Text := 'SELECT Count(*) Auth70s FROM CCBatch WHERE AuthCode = 70 and HostId > 0';
    ExecQuery;

    if FieldByName('Auth70s').AsInteger > 3 then
    begin
      LineOut('');
      LineOut('* WARNING: TERMINAL MAY NEED SERVICE!');
      LineOut('');
    end;

    Close;
  end; {with ReportQuery}

  POSDataMod.IBRptSQL02Main.Close;
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
  if bLogging then UpdateZlog('CCSales Report Close');
end; {procedure CCSalesReport}


procedure PrintCreditTotalsReport(ShiftNo: Integer; nStartBatchID: Integer; nEndBatchID: Integer);
begin
  CCSalesReport(ShiftNo, nStartBatchID, nEndBatchID);
end; { procedure PrintCreditTotalsReport}


{-----------------------------------------------------------------------------
  Name:      CCBatchReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: BatchID, BatchDayID, CurDayID: Integer; OpenDate : TDateTime; Settled : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCBatchReport(BatchID, BatchDayID, CurDayID: Integer; OpenDate : TDateTime; Settled : boolean );
var
  nBatchCount: Integer;
  nBatchAmt: Currency;
  cReader: shortstring;
  sBatchStatus : string;
  CardSettleStatus : short;
  AmountGiftActivated : currency;
  CountGiftActivated : integer;
  TranCode : integer;
  cardno : string;
  intrans : boolean;
begin
  AmountGiftActivated := 0;
  CountGiftActivated := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT CB.HostID, CB.BatchID, CB.BatchNo, CB.SeqNo, CB.AcctNumber, CB.NBSTranCode, CB.Collected, CB.Posted, ');
    SQL.Add('CB.OrigSource, CT.ShortName,  CB.EntryType, CB.Amount As Amt ');
    SQL.Add('FROM CCBatch CB LEFT OUTER JOIN CCCardTypes CT ON (CB.CardType = CT.CardType) ');
    SQL.Add('WHERE ((CB.BatchID = :pBatchID)) and CB.HostId > 0');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND CB.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
    SQL.Add('ORDER BY CB.BatchID, CB.BatchNo, CB.SeqNo ' );
    ParamByName('pBatchID').AsInteger := BatchID;
    ExecQuery;
    if bLogging then UpdateZlog('Credit Totals Report Open');
    {ACCT#                CARD AMNT $   SEQ#
    1234567890123456789012345678901234567890
    ------------------- - ---- -------- ----
    1234567890123456789 I XXXX 9999.99- 8123 }

    nBatchCount := RecordCount;
    nBatchAmt := 0;
    if nBatchCount > 0 then
    begin
      // ===== Print Detail Header ====
      LineOut('');
      LineOut('BATCH CONTROL # ' + Format('%9.9d', [FieldByName('BatchID').AsInteger]));
      LineOut('BATCH ID      # ' + Format('%9.9d', [FieldByName('BatchNo').AsInteger]));
      LineOut('BATCH OPEN DATE ' + FormatDateTime('hh:mm am/pm', OpenDate));
      LineOut('BATCH DAY ID    ' + Format('%6.6d', [BatchDayID]));
      LineOut('CURRENT DAY ID  ' + Format('%6.6d', [CurDayID])  );
      if Settled then
        sBatchStatus := 'BATCH STATUS - COLLECTED'
      else
        sBatchStatus := 'BATCH STATUS - UNCOLLECTED';
      LineOut(sBatchStatus);

      LineOut('');
      if BatchDayID = CurDayID then
      begin
        LineOut('ACCT#                  CARD   AMNT $  INV#');
        LineOut('------------------- -- ---- -------- -----');
      end;

      while Not EOF do
      begin
        CardSettleStatus := 0;
        if (FieldByName('Collected').AsInteger = 1) then
          CardSettleStatus := CardSettleStatus + 1;
        if (FieldByName('Posted').AsInteger = 1) then
          CardSettleStatus := CardSettleStatus + 2;
        cReader := IntToStr(CardSettleStatus);
        //  NBS credit server did not use Latitude codes for transaction types.
        //  Change below assumes NBS no longer handling gift cards.
        try
          TranCode := StrToInt(Trim(FieldByName('NBSTranCode').AsString));
        except
          TranCode := RT_PROTOCOL;  // any value that will not match below
        end;
        if (TranCode = RT_ACTIVATE) then
        begin
          cReader := cReader + 'A';
          AmountGiftActivated := AmountGiftActivated + fieldbyname('Amt').AsCurrency;
          inc(CountGiftActivated);
        end
        else if (TranCode = RT_GIFT_RELOAD) then
        //...53j
        begin
          cReader := cReader + 'R';
          AmountGiftActivated := AmountGiftActivated + fieldbyname('Amt').AsCurrency;
          inc(CountGiftActivated);
        end
        else //Gift
              if FieldByName('EntryType').AsString = 'M' then
                cReader := cReader + 'M'
        else if Trim(FieldByName('OrigSource').AsString) = 'CATSrvr' then
          cReader := cReader + 'I';

        if BatchDayID = CurDayID then
        begin
          if (fmPOS.UseCISPEncryption(FieldByName('HostID').AsInteger)) then
          begin
            if (Pos(PFSCHAR, FieldByName('AcctNumber').AsString) > 0) then  //ecab
              cardno := Format('ECAB %14.14s', [copy(FieldByName('AcctNumber').AsString,1,4)])
            else if (Pos('#', FieldByName('AcctNumber').AsString) > 0) then
              cardno := Format('%19.19s', [copy(FieldByName('AcctNumber').AsString, 1,4)])
            else
              cardno := fmPos.MaskCardNumber(FieldByName('AcctNumber').AsString);
            LineOut(Format( '%19.19s %-2.2s %-4.4s%9.9s %2.2d%3.3d',[
              cardno,
              cReader,
              LeftStr(FieldByName('ShortName').AsString,4),
              FormatFloat('###.00 ;###.00-',FieldByName('Amt').AsCurrency),
              FieldByName('BatchNo').AsInteger,
              FieldByName('SeqNo').AsInteger] ));
          end
          else
          begin
            LineOut(Format( '%19.19s %-2.2s %-4.4s%9.9s %2.2d%3.3d',[
              FieldByName('AcctNumber').AsString,
              cReader,
              LeftStr(FieldByName('ShortName').AsString,4),
              FormatFloat('###.00 ;###.00-',FieldByName('Amt').AsCurrency),
              FieldByName('BatchNo').AsInteger,
              FieldByName('SeqNo').AsInteger] ));
          end;
        end;

        nBatchAmt := nBatchAmt + FieldByName('Amt').AsCurrency;

        Next;
      end;  {while Not EOF}

      if BatchDayID = CurDayID then
      begin
        LineOut('');
        LineOut('M: MANUAL            I: ISLAND READER');
        //Gift
        LineOut('A: GIFT ACTIVATE     R: GIFT RECHARGE');
        //Gift
        LineOut('');
      end;

      CCRptByCardType( BatchID, BatchID, AmountGiftActivated, CountGiftActivated);

      // === Total Batch Counts / Sales ===
      LineOut('');
      if (CountGiftActivated > 0) and (AmountGiftActivated > 0) then
        LineOut(Format('BATCH - COUNT  %4.4d  TOTAL  $ %-9.9s',
         [nBatchCount, FormatFloat('##,###.00 ;##,###.00-', (nBatchAmt-AmountGiftActivated))]) )
      else
        LineOut(Format('BATCH - COUNT  %4.4d  TOTAL  $ %-9.9s',
         [nBatchCount, FormatFloat('##,###.00 ;##,###.00-', nBatchAmt)]) );
      LineOut('');
      LineOut('* * * * * * * * * * * * * * * * * * * *');
    end {if BatchCount > 0}
    else
    begin
      LineOut('*** NO TRANSACTIONS ***');
    end;

    Close;
    if bLogging then UpdateZlog('Credit Totals Report Close');
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {CCBatchReport}


{-----------------------------------------------------------------------------
  Name:      CCRptByCardType
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: StartBatchID: Integer; EndBatchID: Integer;GiftAmount:currency;GiftCount:integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CCRptByCardType(StartBatchID: Integer; EndBatchID: Integer;GiftAmount:currency;GiftCount:integer);
var
  TotalCount : Integer;
  TotalAMount : Currency;
  intrans : boolean;
begin
  TotalCount := 0;
  TotalAmount := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Sub1 do
  begin
    Assert(not open, 'IBRptSQL02Sub1 is open');
    // === Sales By Card Type ===
    SQL.Clear;
    SQL.Add('SELECT CT.ShortName, Min(CT.CardType) as CardType, Count(*) as Cnt, Sum(CB.Amount) as Amt ');
    SQL.Add('FROM CCBatch CB LEFT OUTER JOIN CCCardTypes CT ON (CB.CardType = CT.CardType) ');
    SQL.Add('WHERE (CB.BatchID BETWEEN :pStartID And :pEndID) and CB.HostID > 0');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND CB.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
    SQL.Add('GROUP BY CT.ShortName ');
    SQL.Add('ORDER BY CT.ShortName');
    ParamByName('pStartID').AsInteger := StartBatchID;
    ParamByName('pEndID').AsInteger := EndBatchID;
    ExecQuery;
    if bLogging then UpdateZlog('CC by Card Report Open');
    while Not EOF do
    begin
      TotalCount := TotalCount + FieldByName('Cnt').AsInteger;
      TotalAmount := TotalAmount + FieldByName('Amt').AsCurrency;
      if FieldByName('CardType').AsString <> CT_GIFT then
        LineOut(Format('%-5.5s - COUNT  %4.4d  TOTAL  $ %-9.9s',[
        FieldByName('ShortName').AsString,
        FieldByName('Cnt').AsInteger,
        FormatFloat('##,###.00 ;##,###.00-',FieldByName('Amt').AsCurrency)]))
      else
        LineOut(Format('%-5.5s - COUNT  %4.4d  TOTAL  $ %-9.9s',[
        FieldByName('ShortName').AsString,
        (FieldByName('Cnt').AsInteger - GiftCount),
        FormatFloat('##,###.00 ;##,###.00-',(FieldByName('Amt').AsCurrency - GiftAmount))]));
      Next;
    end;
    Close;
    if bLogging then UpdateZlog('CC by Card Report Close');
  end; {with IBRptSQL02Sub1 }
  if (GiftCount > 0) and (GiftAmount > 0) then
    LineOut(Format('%-5.5s - COUNT  %4.4d  TOTAL  $ %-9.9s',[
    'P1A/R',
    GiftCount,
    FormatFloat('##,###.00 ;##,###.00-', GiftAmount)]));
  LineOut('-----------------------------------------');
  LineOut(Format('%-5.5s - COUNT  %4.4d  TOTAL  $ %-9.9s',[
    'Total',
    TotalCount,
    FormatFloat('##,###.00 ;##,###.00-',(TotalAmount))]));
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure CCRptByCardType}


{-----------------------------------------------------------------------------
  Name:      CCRptUncollected
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCRptUncollected;
var
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Show Uncollected Batches
    SQL.Clear;
    SQL.Add('SELECT B.BatchID, Count(*) as RecCnt, Sum(B.Amount) as Amt ');
    SQL.Add('FROM CCBatch B JOIN CCRTB R ON (B.BatchID = R.BatchID) ');
    SQL.Add('WHERE (R.Balanced = 0) and (B.HostID > 0)');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND B.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
    SQL.Add('GROUP BY B.BatchID ');
    SQL.Add('ORDER BY B.BatchID');
    ExecQuery;
    if bLogging then UpdateZlog('Uncollected Report Open');
    if RecordCount > 0 then
    begin
      LineOut('');
      LineOut('UNCOLLECTED BATCHES:');
      // List Uncollected Batches
      while Not EOF do
      begin
        LineOut('');
        LineOut(Format('%9.9d - COUNT  %3.3d  TOTAL  $ %9.9s', [
        FieldByName('BatchID').AsInteger,
        FieldByName('RecCnt').AsInteger,
        FormatFloat('##,###.00 ;##,###.00-', FieldByName('Amt').AsCurrency)]) );
        Next;
      end; {while not EOF}
    end;
    Close;
    if bLogging then UpdateZlog('CC Uncollected Report Close');
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure CCRptUncollected}


{-----------------------------------------------------------------------------
  Name:      CCTermSrvCheck
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCTermSrvCheck;
var
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;

  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
   // Check to see if Terminal needs Service
   SQL.Clear;
   SQL.Add('SELECT Count(*) Auth70s FROM CCBatch ');
   SQL.Add('WHERE AuthCode = ''70'' and Hostid = :pHostID');
   ParamByName('pHostID').AsInteger := CDTSRV_NBS;
   ExecQuery;
   if FieldByName('Auth70s').AsInteger > 3 then
   begin
     LineOut('');
     LineOut('* WARNING: TERMINAL MAY NEED SERVICE!');
     LineOut('');
   end;
   close;
 end; {with TempQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure CCTermSrvCheck}


{-----------------------------------------------------------------------------
  Name:      CCBatchSummary
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCBatchSummary;
var
  BatchStatus : string;
  intrans : boolean;
begin
  // Summary by BatchID
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('Select B.BatchID, Sum(B.Amount) as Amt, Count(B.BatchID) as RecCnt, ');
    SQL.Add('Max(R.OpenDate) as OpenDate, Max(R.Balanced) as Bal, Max(R.DayID) as DayID ');
    SQL.Add('From CCBatch B JOIN CCRTB R On (B.BatchID = R.BatchID) ');
    SQL.Add('WHERE B.HostId > 0');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND B.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' and R.DayID = (Select ResetCount from Totals where TotalNo = 0) ');
    SQL.Add('Group By B.BatchID ');
    SQL.Add('Order By B.BatchID');
    ExecQuery;
    if bLogging then UpdateZlog('Batch Summary Report Open');
    {0123456789012345678901234567890123456789
     Batch ID Count  Amount     Opened    Day
     --------- --- ---------- ----------- ---
     U 9999999 999 99,999.99- mm/dd hh:mm 999     }

    if RecordCount > 0 Then
    begin
      LineOut('');
      LineOut('BATCH SUMMARY:');
      LineOut('');
      LineOut('Batch ID Count  Amount     Opened    Day');
      LineOut('--------- --- ---------- ----------- ---');
    end;
    while Not EOF do
    begin
      if FieldByName('Bal').AsInteger = 1 then
        BatchStatus := ' '
      else
        BatchStatus := 'U';
      LineOut( Format('%1.1s %7.7d %3.3d %10.10s %11.11s %3.3s',[
        BatchStatus,
        FieldByName('BatchID').AsInteger,
        FieldByName('RecCnt').AsInteger,
        FormatFloat('##,###.00 ;##,###.00-',FieldByName('Amt').AsCurrency),
        FormatDateTime('mm/dd hh:mm',FieldByName('OpenDate').AsDateTime),
        Copy(Format('%7.7d', [FieldByName('DayID').AsInteger]), 5, 3) ] ));
      Next;
    end; {while not EOF}
    Close;
    if bLogging then UpdateZlog('Batch Summary Report Close');
  end; {with ReportQuery}
  // Summary by DayID

  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('Select Sum(B.Amount) as Amt, Count(B.BatchID) as RecCnt, ');
    SQL.Add('Min(R.OpenDate) as OpenDate, Max(R.DayID) as DayID ');
    SQL.Add('From CCBatch B JOIN CCRTB R On (B.BatchID = R.BatchID) ');
    SQL.Add('Where B.HostID > 0');
    if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
        SQL.Add('AND B.TransGroup <> ' + IntToStr(TG_PROTOCOL) + ' ');
    SQL.Add('Group By R.DayID ');
    SQL.Add('Order By R.DayID');
    ExecQuery;
    if bLogging then UpdateZlog('Day Summary Report Open');
    {0123456789012345678901234567890123456789
     Batch ID Count  Amount     Opened    Day
     --------- --- ---------- ----------- ---
     U 9999999 999 99,999.99- mm/dd hh:mm 999     }

    if RecordCount > 0 Then
    begin
      LineOut('');
      LineOut('DAY SUMMARY:');
      LineOut('');
      LineOut('         Count  Amount     Opened    Day');
      LineOut('          --- ---------- ----------- ---');
    end;
    while Not EOF do
    begin
      //if (CountGiftActivated > 0) and (AmountGiftActivated > 0) then
      LineOut( Format('          %3.3d %10.10s %11.11s %3.3s',[
        FieldByName('RecCnt').AsInteger,
        FormatFloat('##,###.00 ;##,###.00-',FieldByName('Amt').AsCurrency),
        FormatDateTime('mm/dd hh:mm',FieldByName('OpenDate').AsDateTime),
        Copy(Format('%7.7d', [FieldByName('DayID').AsInteger]), 5, 3) ] ));
      Next;
    end; {while not EOF}
    Close;
    if bLogging then UpdateZlog('Day Summary Report Close');
    LineOut('');
    LineOut('');
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      CCHostTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const DayID : integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//bp...
procedure CCHostTotals(const DayID : integer);
// Report showing card totals (by card category) from the host settlement totals for the day indicated by DayID.
var
  SettlementTotals : THostTotals;
  intrans : boolean;
begin
  ReportHdr(' - Host Totals Information -');
  // Extract record in DB left by by credit server when EOD was processed.
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear();
    SQL.Add('Select * from CCHostTotals');
    SQL.Add(' where DayID = :pDayID and BatchID = 0');
    ParamByName('pDayID').AsInteger := DayID;
    ExecQuery();
    if (EOF) then
      begin
        LineOut('ERROR - no totals for DayID=' + IntToStr(DayID));
      end
    else  // i.e., record located in DB
      begin
        SettlementTotals.DayID      := FieldByName('DayID').AsInteger;
        SettlementTotals.BatchID    := FieldByName('BatchID').AsInteger;
        SettlementTotals.CreateDate := FieldByName('CreateDate').AsDateTime;
        SettlementTotals.GrandTotal := FieldByName('GrandTotal').AsCurrency;
        SettlementTotals.FeeAmount  := FieldByName('FeeAmount').AsCurrency;
        SettlementTotals.NetAmount  := FieldByName('NetAmount').AsCurrency;
        SettlementTotals.CCCount    := FieldByName('CreditCount').AsInteger;
        SettlementTotals.CCAmount   := FieldByName('CreditAmount').AsCurrency;
        SettlementTotals.CCRefCnt   := FieldByName('CreditRefCnt').AsInteger;
        SettlementTotals.CCRefund   := FieldByName('CreditRefund').AsCurrency;
        SettlementTotals.TECount    := FieldByName('TECount').AsInteger;
        SettlementTotals.TEAmount   := FieldByName('TEAmount').AsCurrency;
        SettlementTotals.DSCount    := FieldByName('DiscoverCount').AsInteger;
        SettlementTotals.DSAmount   := FieldByName('DiscoverAmount').AsCurrency;
        SettlementTotals.DSRefCnt   := FieldByName('DiscoverRefCnt').AsInteger;
        SettlementTotals.DSRefund   := FieldByName('DiscoverRefund').AsCurrency;
        //53f...
        SettlementTotals.VMCount    := FieldByName('VISAMCCount').AsInteger;
        SettlementTotals.VMAmount   := FieldByName('VISAMCAmount').AsCurrency;
        SettlementTotals.VMRefCnt   := FieldByName('VISAMCRefCnt').AsInteger;
        SettlementTotals.VMRefund   := FieldByName('VISAMCRefund').AsCurrency;
        //...53f
        SettlementTotals.AOCount    := FieldByName('AuthOnlyCount').AsInteger;
        SettlementTotals.AOAmount   := FieldByName('AuthOnlyAmount').AsCurrency;
        SettlementTotals.DBCount    := FieldByName('DebitCount').AsInteger;
        SettlementTotals.DBAmount   := FieldByName('DebitAmount').AsCurrency;
        SettlementTotals.DBRefCnt   := FieldByName('DebitRefCnt').AsInteger;
        SettlementTotals.DBRefund   := FieldByName('DebitRefund').AsCurrency;
        SettlementTotals.FLCount    := FieldByName('FleetCount').AsInteger;
        SettlementTotals.FLAmount   := FieldByName('FleetAmount').AsCurrency;
        SettlementTotals.CSCount    := FieldByName('CashCount').AsInteger;
        SettlementTotals.CSAmount   := FieldByName('CashAmount').AsCurrency;
        SettlementTotals.PRCount    := FieldByName('ProprietaryCount').AsInteger;
        SettlementTotals.PRAmount   := FieldByName('ProprietaryAmount').AsCurrency;
        SettlementTotals.PRRefCnt   := FieldByName('ProprietaryRefCnt').AsInteger;
        SettlementTotals.PRRefund   := FieldByName('ProprietaryRefund').AsCurrency;
        SettlementTotals.CKCount    := FieldByName('CheckCount').AsInteger;
        SettlementTotals.CKAmount   := FieldByName('CheckAmount').AsCurrency;
        SettlementTotals.EFCount    := FieldByName('FoodstampCount').AsInteger;
        SettlementTotals.EFAmount   := FieldByName('FoodstampAmount').AsCurrency;
        SettlementTotals.EFRefCnt   := FieldByName('FoodstampRefCnt').AsInteger;
        SettlementTotals.EFRefund   := FieldByName('FoodstampRefund').AsCurrency;
        SettlementTotals.ECCount    := FieldByName('CashBenefitCount').AsInteger;
        SettlementTotals.ECAmount   := FieldByName('CashBenefitAmount').AsCurrency;
        SettlementTotals.ECRefCnt   := FieldByName('CashBenefitRefCnt').AsInteger;
        SettlementTotals.ECRefund   := FieldByName('CashBenefitRefund').AsCurrency;
        SettlementTotals.SV1Count   := FieldByName('GiftActivateCount').AsInteger;
        SettlementTotals.SV1Amount  := FieldByName('GiftActivateAmount').AsCurrency;
        SettlementTotals.SV2Count   := FieldByName('GiftPurchaseCount').AsInteger;
        SettlementTotals.SV2Amount  := FieldByName('GiftPurchaseAmount').AsCurrency;
        SettlementTotals.SV3Count   := FieldByName('GiftReplaceCount').AsInteger;
        SettlementTotals.SV3Amount  := FieldByName('GiftReplaceAmount').AsCurrency;
        SettlementTotals.SV4Count   := FieldByName('GiftRechargeCount').AsInteger;
        SettlementTotals.SV4Amount  := FieldByName('GiftRechargeAmount').AsCurrency;
        //53d...
        SettlementTotals.OLCount    := 0;  // not maintained by host
        SettlementTotals.OLAmount   := 0.0; 
        //...53d
        fmPOS.CardTotalsDateCode := DATE_CODE_SETTLE_CLEAR;
        //POSPrt.PrintCardTotals(@SettlementTotals);
        PrintCardTotals(@SettlementTotals);
      end;
    Close();
  end;  // with
  if not intrans then
    POSDataMod.IBRptTrans.Commit;

end;  // procedure CCHostTotals

{-----------------------------------------------------------------------------
  Name:      CCLocalTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const DayID : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCLocalTotals(const DayID : integer);
// Report showing local card totals (by card category) for the day indicated by DayID.
var
  SettlementTotals : THostTotals;
  intrans : boolean;
begin
  ReportHdr(' - Local Totals Information -');
  // Extract record in DB left by by credit server as each card was processed.
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear();
    SQL.Add('Select min(OpenTime) as CreateDate,');       // (todo) - Is this the best timestamp from ccRTB to use?
    SQL.Add(' sum(TotSales) as SumTotSales, sum(TotCredits) as SumTotCredits,');
    SQL.Add(' sum(CreditCount) as SumCreditCount, sum(CreditAmount) as SumCreditAmount,');
    SQL.Add(' sum(CreditRefCnt) as SumCreditRefCnt, sum(CreditRefund) as SumCreditRefund,');
    SQL.Add(' sum(TECount) as SumTECount, sum(TEAmount) as SumTEAmount,');
    SQL.Add(' sum(DiscoverCount) as SumDiscoverCount, sum(DiscoverAmount) as SumDiscoverAmount,');
    SQL.Add(' sum(DiscoverRefCnt) as SumDiscoverRefCnt, sum(DiscoverRefund) as SumDiscoverRefund,');
    SQL.Add(' sum(VISAMCCount) as SumVISAMCCount, sum(VISAMCAmount) as SumVISAMCAmount,');
    SQL.Add(' sum(VISAMCRefCnt) as SumVISAMCRefCnt, sum(VISAMCRefund) as SumVISAMCRefund,');
    SQL.Add(' sum(AuthOnlyCount) as SumAuthOnlyCount, sum(AuthOnlyAmount) as SumAuthOnlyAmount,');
    SQL.Add(' sum(DebitCount) as SumDebitCount, sum(DebitAmount) as SumDebitAmount,');
    SQL.Add(' sum(DebitRefCnt) as SumDebitRefCnt, sum(DebitRefund) as SumDebitRefund,');
    SQL.Add(' sum(FleetCount) as SumFleetCount, sum(FleetAmount) as SumFleetAmount,');
    SQL.Add(' sum(CashCount) as SumCashCount, sum(CashAmount) as SumCashAmount,');
    SQL.Add(' sum(ProprietaryCount) as SumProprietaryCount, sum(ProprietaryAmount) as SumProprietaryAmount,');
    SQL.Add(' sum(ProprietaryRefCnt) as SumProprietaryRefCnt, sum(ProprietaryRefund) as SumProprietaryRefund,');
    SQL.Add(' sum(CheckCount) as SumCheckCount, sum(CheckAmount) as SumCheckAmount,');
    SQL.Add(' sum(FoodstampCount) as SumFoodstampCount, sum(FoodstampAmount) as SumFoodstampAmount,');
    SQL.Add(' sum(FoodstampRefCnt) as SumFoodstampRefCnt, sum(FoodstampRefund) as SumFoodstampRefund,');
    SQL.Add(' sum(CashBenefitCount) as SumCashBenefitCount, sum(CashBenefitAmount) as SumCashBenefitAmount,');
    SQL.Add(' sum(CashBenefitRefCnt) as SumCashBenefitRefCnt, sum(CashBenefitRefund) as SumCashBenefitRefund,');
    SQL.Add(' sum(GiftActivateCount) as SumGiftActivateCount, sum(GiftActivateAmount) as SumGiftActivateAmount,');
    SQL.Add(' sum(GiftPurchaseCount) as SumGiftPurchaseCount, sum(GiftPurchaseAmount) as SumGiftPurchaseAmount,');
    SQL.Add(' sum(GiftReplaceCount) as SumGiftReplaceCount, sum(GiftReplaceAmount) as SumGiftReplaceAmount,');
    //53d...
//    SQL.Add(' sum(GiftRechargeCount) as SumGiftRechargeCount, sum(GiftRechargeAmount) as SumGiftRechargeAmount');
    SQL.Add(' sum(GiftRechargeCount) as SumGiftRechargeCount, sum(GiftRechargeAmount) as SumGiftRechargeAmount,');
    SQL.Add(' sum(OfflineCount) as SumOfflineCount, sum(OfflineAmount) as SumOfflineAmount');
    //...53d
    SQL.Add(' from CCRTB');
    SQL.Add(' where DayID = :pDayID');
    ParamByName('pDayID').AsInteger := DayID;
    ExecQuery();
    if (EOF) then
      begin
        LineOut('ERROR - no totals for DayID=' + IntToStr(DayID));
      end
    else  // i.e., record located in DB
      begin
        SettlementTotals.DayID      := DayID;
        SettlementTotals.BatchID    := 0;
        SettlementTotals.CreateDate := FieldByName('CreateDate').AsDateTime;
        SettlementTotals.GrandTotal := FieldByName('SumTotSales').AsCurrency - FieldByName('SumTotCredits').AsCurrency;
        SettlementTotals.FeeAmount  := 0.0;  // (todo) - How is local fee amount determined?
        SettlementTotals.NetAmount  := SettlementTotals.GrandTotal - SettlementTotals.FeeAmount;
        SettlementTotals.CCCount    := FieldByName('SumCreditCount').AsInteger;
        SettlementTotals.CCAmount   := FieldByName('SumCreditAmount').AsCurrency;
        SettlementTotals.CCRefCnt   := FieldByName('SumCreditRefCnt').AsInteger;
        SettlementTotals.CCRefund   := FieldByName('SumCreditRefund').AsCurrency;
        SettlementTotals.TECount    := FieldByName('SumTECount').AsInteger;
        SettlementTotals.TEAmount   := FieldByName('SumTEAmount').AsCurrency;
        SettlementTotals.DSCount    := FieldByName('SumDiscoverCount').AsInteger;
        SettlementTotals.DSAmount   := FieldByName('SumDiscoverAmount').AsCurrency;
        SettlementTotals.DSRefCnt   := FieldByName('SumDiscoverRefCnt').AsInteger;
        SettlementTotals.DSRefund   := FieldByName('SumDiscoverRefund').AsCurrency;
        SettlementTotals.VMCount    := FieldByName('SumVISAMCCount').AsInteger;
        SettlementTotals.VMAmount   := FieldByName('SumVISAMCAmount').AsCurrency;
        SettlementTotals.VMRefCnt   := FieldByName('SumVISAMCRefCnt').AsInteger;
        SettlementTotals.VMRefund   := FieldByName('SumVISAMCRefund').AsCurrency;
        SettlementTotals.AOCount    := FieldByName('SumAuthOnlyCount').AsInteger;
        SettlementTotals.AOAmount   := FieldByName('SumAuthOnlyAmount').AsCurrency;
        SettlementTotals.DBCount    := FieldByName('SumDebitCount').AsInteger;
        SettlementTotals.DBAmount   := FieldByName('SumDebitAmount').AsCurrency;
        SettlementTotals.DBRefCnt   := FieldByName('SumDebitRefCnt').AsInteger;
        SettlementTotals.DBRefund   := FieldByName('SumDebitRefund').AsCurrency;
        SettlementTotals.FLCount    := FieldByName('SumFleetCount').AsInteger;
        SettlementTotals.FLAmount   := FieldByName('SumFleetAmount').AsCurrency;
        SettlementTotals.CSCount    := FieldByName('SumCashCount').AsInteger;
        SettlementTotals.CSAmount   := FieldByName('SumCashAmount').AsCurrency;
        SettlementTotals.PRCount    := FieldByName('SumProprietaryCount').AsInteger;
        SettlementTotals.PRAmount   := FieldByName('SumProprietaryAmount').AsCurrency;
        SettlementTotals.PRRefCnt   := FieldByName('SumProprietaryRefCnt').AsInteger;
        SettlementTotals.PRRefund   := FieldByName('SumProprietaryRefund').AsCurrency;
        SettlementTotals.CKCount    := FieldByName('SumCheckCount').AsInteger;
        SettlementTotals.CKAmount   := FieldByName('SumCheckAmount').AsCurrency;
        SettlementTotals.EFCount    := FieldByName('SumFoodstampCount').AsInteger;
        SettlementTotals.EFAmount   := FieldByName('SumFoodstampAmount').AsCurrency;
        SettlementTotals.EFRefCnt   := FieldByName('SumFoodstampRefCnt').AsInteger;
        SettlementTotals.EFRefund   := FieldByName('SumFoodstampRefund').AsCurrency;
        SettlementTotals.ECCount    := FieldByName('SumCashBenefitCount').AsInteger;
        SettlementTotals.ECAmount   := FieldByName('SumCashBenefitAmount').AsCurrency;
        SettlementTotals.ECRefCnt   := FieldByName('SumCashBenefitRefCnt').AsInteger;
        SettlementTotals.ECRefund   := FieldByName('SumCashBenefitRefund').AsCurrency;
        SettlementTotals.SV1Count   := FieldByName('SumGiftActivateCount').AsInteger;
        SettlementTotals.SV1Amount  := FieldByName('SumGiftActivateAmount').AsCurrency;
        SettlementTotals.SV2Count   := FieldByName('SumGiftPurchaseCount').AsInteger;
        SettlementTotals.SV2Amount  := FieldByName('SumGiftPurchaseAmount').AsCurrency;
        SettlementTotals.SV3Count   := FieldByName('SumGiftReplaceCount').AsInteger;
        SettlementTotals.SV3Amount  := FieldByName('SumGiftReplaceAmount').AsCurrency;
        SettlementTotals.SV4Count   := FieldByName('SumGiftRechargeCount').AsInteger;
        SettlementTotals.SV4Amount  := FieldByName('SumGiftRechargeAmount').AsCurrency;
        //53d...
//        fmPOS.CardTotalsDateCode := '';  // DATE_CODE_LOCAL
        fmPOS.CardTotalsDateCode := DATE_CODE_LOCAL;
        SettlementTotals.OLCount    := FieldByName('SumOfflineCount').AsInteger;
        SettlementTotals.OLAmount   := FieldByName('SumOfflineAmount').AsCurrency;
        //...53d
        //POSPrt.PrintCardTotals(@SettlementTotals);
        PrintCardTotals(@SettlementTotals);
        {$IFDEF HUCKS_REPORTS}  //20071107d...
        // Adjust where reports cut at request of Huck's Data Analysts
        PrintSeq;
        {$ENDIF}                //...20071107d
        //...20071106
      end;
    Close();
  end;  // with
  if not intrans then
    POSDataMod.IBRptTrans.Commit;

end;  // procedure CCLocalTotals
//...bp


{-----------------------------------------------------------------------------
  Name:      CCSetupReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCSetupReport;
var
  i: Integer;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;

  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Text := 'Select * From CCSetup';
    ExecQuery;
    ReportHdr('Credit Card Setup Report');

    LineOut('TERMINAL:');
    LineOut('----------------------------------------');
    CCRSOut('Version:', FieldByName('SWVersion').AsString );
    CCRSOut('Company No:', FieldByName('CompanyNo').AsString );
    CCRSOut('Terminal Type:',FieldByName('TerminalType').AsString );
    CCRSOut('Company No:',FieldByName('CompanyNo').AsString );
    CCRSOut('Unit ID:',FieldByName('UnitID').AsString );
    CCRSOut('Terminal ID:',FieldByName('TerminalID').AsString );
    CCRSOut('Batch Limit:',FieldByName('BatchLimit').AsString );
    CCRSOut('Retry Minutes:',FieldByName('RetryMins').AsString );
    CCRSOut('Force Up Hours',FieldByName('ForceUpHrs').AsString );

    LineOut('');
    LineOut('NETWORK PHONE NUMBERS:');
    LineOut('----------------------------------------');
    CCRSOut('Primary',FieldByName('PrimaryPhone').AsString );
    CCRSOut('Alternate',FieldByName('AlternatePhone').AsString );
    CCRSOut('Help Desk',FieldByName('HelpDeskNo').AsString );
    CCRSOut('Bank Card',FieldByName('BankCardNo').AsString );
    CCRSOut('WEX',FieldByName('WEXNo').AsString );
    CCRSOut('Amex',FieldByName('AmexNo').AsString );
    CCRSOut('WEX',FieldByName('WEXNo').AsString );
    CCRSOut('Diners',FieldByName('DinersNo').AsString );
    CCRSOut('Voyager',FieldByName('VoyagerNo').AsString );
    CCRSOut('IAES',FieldByName('IAESNo').AsString );
    CCRSOut('Discover',FieldByName('DiscoverNo').AsString );
    CCRSOut('PH&H',FieldByName('PHHNo').AsString );
    LineOut('');

    LineOut('UNIT:');
    LineOut('----------------------------------------');
    LineOut('Name:');
    LineOut(FieldByName('UnitName').AsString);
    LineOut('Address:');
    LineOut(FieldByName('UnitAddress').AsString);
    LineOut('City:');
    LineOut(FieldByName('UnitCity').AsString);
    LineOut('State:');
    LineOut(FieldByName('UnitState').AsString);
    LineOut('');

    LineOut('OPERATIONAL - Card Limits');
    LineOut('----------------------------------------');
    for i := 1 To 12 do
    begin
      if FieldByName('CardType'+IntToStr(i)).AsString <> '' Then
      begin
        LineOut(FieldByName('CardType'+IntToStr(i)).AsString);
        CCRSOut('   No Auth Limit:', FieldByName('NoAuth'+IntToStr(i)).AsString);
        CCRSOut('   Fall Back Limit:', FieldByName('FallBack'+IntToStr(i)).AsString);
        CCRSOut('   CAT Pre-Auth:', FieldByName('CATPreAuth'+IntToStr(i)).AsString);
        CCRSOut('   CAT Limit:', FieldByName('CATLimit'+IntToStr(i)).AsString);
        LineOut('');
      end;
    end; {for 1 to 12}
    ReportFtr;
    Close;
  end; {with POSDataMod.TempQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure CCSetupReport}


{-----------------------------------------------------------------------------
  Name:      CCRSOut
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: sLabel:String; sData: String
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CCRSOut(sLabel:String; sData: String);
begin
  LineOut( Format('%-25.25s %10.10s', [sLabel, sData]));
end; {procedure CCRSOut}


// Complete List of PLU#s by Dept
{-----------------------------------------------------------------------------
  Name:      PluListingReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PluListingReport;
var
  LastDeptNo: Integer;
  TaxDisc: String[2];
  intrans : boolean;
begin
  LastDeptNo := 0;
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('Select P.DeptNo, P.PluNo, P.Name PluName, P.Price, D.Name DeptName, P.Disc, P.TaxNo ');
    SQL.Add('From PLU P Join Dept D On (P.DeptNo = D.DeptNo) ');
    SQL.Add('Order By P.DeptNo, P.PluNo' );
    ExecQuery;
    if bLogging then UpdateZlog('PLU Listing Report Open');
    // 1234567890123456789012345678901234567890
    ReportHdr('PLU Listing Report');
    LineOut('Plu#         Name              Price  TD');
    LineOut('------------ ----------------- ------ --');

    while Not EOF do
    begin
      // Check if New Dept
      if LastDeptNo <> FieldByName('DeptNo').AsInteger then
      begin
        if LastDeptNo > 0 Then LineOut('');
        LineOut(FieldByName('DeptName').AsString);
        LastDeptNo := FieldByName('DeptNo').AsInteger;
      end;

      TaxDisc := ' ';
      If FieldByName('TaxNo').AsInteger > 0 Then
        TaxDisc := 'T';
      If FieldByName('Disc').AsInteger > 0 Then
        TaxDisc := TaxDisc + 'D';
      LineOut(
       Format('%12.12s %-17.17s %6.6s %2.2s', [
        FieldByName('PluNo').AsString,
        FieldByName('PluName').AsString,
        FormatFloat('###.00', FieldByName('Price').AsCurrency),
        TaxDisc]) );
      Next;
    end;

    LineOut('------- ---------------------- ------ --');
    ReportFtr;

    Close;
    if bLogging then UpdateZlog('PLU Listing Report Close');
  end; {with ReportQuery}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure PluListingReport}

procedure CCRptUncollectedLocal;
var
  cardno : string;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear;
    SQL.Add('Select CB.HostID, CB.SeqNo, CB.AcctNumber, CB.CardType, ');
    SQL.Add('CB.OrigSource, CT.ShortName,  CB.Amount As Amt ');
    SQL.Add('FROM CCBatch CB LEFT OUTER JOIN CCCardTypes CT ON (CB.CardType = CT.CardType) ');
    SQL.Add('WHERE CB.HostID = :pHostID and CB.TransGroup = 1 and CB.LocalApproved = 1 and CB.BatchNo = 0 ');
    SQL.Add('Order by CB.CardType, CB.SeqNo ' );
    parambyname('pHostID').AsInteger := CDTSRV_FIFTH_THIRD;
    ExecQuery;
    {ACCT#                CARD AMNT $   SEQ#
    1234567890123456789012345678901234567890
    ------------------- - ---- -------- ----
    1234567890123456789 I XXXX 9999.99- 8123 }
    if RecordCount > 0 then
    begin
      LineOut('');
      LineOut('UNCOLLECTED LOCAL APPROVALS');
      LineOut('ACCT#                 CARD AMNT $   INV#');
      LineOut('------------------- - ---- -------- ----');
    end;
    while not eof do
    begin
      if (fmPOS.UseCISPEncryption(FieldByName('HostID').AsInteger)) then
      begin
        if (Pos(PFSCHAR, FieldByName('AcctNumber').AsString) > 0) then  //ecab
          cardno := Format('ECAB %14.14s', [copy(FieldByName('AcctNumber').AsString,1,4)])
        else if (Pos('#', FieldByName('AcctNumber').AsString) > 0) then
          cardno := Format('%19.19s', [copy(FieldByName('AcctNumber').AsString, 1,4)])
        else
          cardno := fmPos.MaskCardNumber(FieldByName('AcctNumber').AsString);
        LineOut(Format( '%19.19s %-2.2s %-4.4s%7.7s %2.2d%3.3d',[
              cardno,
              FieldByName('CardType').AsString,
              FieldByName('ShortName').AsString,
              FormatFloat('###.00 ;###.00-',FieldByName('Amt').AsCurrency),
              0,
              FieldByName('SeqNo').AsInteger] ));
      end
      else
      begin
        LineOut(Format( '%19.19s %-2.2s %-4.4s%7.7s %2.2d%3.3d',[
              FieldByName('AcctNumber').AsString,
              FieldByName('CardType').AsString,
              FieldByName('ShortName').AsString,
              FormatFloat('###.00 ;###.00-',FieldByName('Amt').AsCurrency),
              0,
              FieldByName('SeqNo').AsInteger] ));
      end;
      Next;
    end;
    Close;
  end;
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end;

procedure Print2Disk(sLine : shortstring);
begin
  try
    AssignFile(TF, sReportLogName);
    if FileExists(sReportLogName) then
    try
      Append(TF);
    except
      Closefile(TF);
      try
        Append(TF);
      except
      end;
    end
    else
    try
      ReWrite(TF);
    except
      closefile(TF);
      try
        rewrite(TF);
      except
      end;
    end;
    WriteLn( TF, sLine);
    CloseFile(TF);
  except
  end;
end;

//inv3...
procedure PrintInventoryReport(const InvoiceID : string);
var
  ChangeDate : TDateTime;
  ItemsReceived : integer;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Clear();
    SQL.Add('select a.UPCText as UPCText, a.PLUNo as PLUNo, a.UserNo as UserNo, a.ChangeDate as ChangeDate,');
    SQL.Add(' u.ImportTime as ImportTime, p.OnHand as OnHand, a.Adjustment as Adjustment, p.name as Name');
    SQL.Add(' from invAudit a join invUPCScanned u on a.SeqNo = u.AuditSeqNo join plu p');
    SQL.Add(' on cast(p.UPC as double precision) = cast(a.UPCText as double precision)');
    SQL.Add(' where a.InvoiceID = :pInvoiceID and a.Receive = 1  order by a.ChangeDate, a.UPCText');
    ParamByName('pInvoiceID').AsString := InvoiceID;
    ExecQuery();
    ChangeDate := 0;
    ItemsReceived := 0;
    while not eof do
    begin
      if (ChangeDate <> FieldByName('ChangeDate').AsDateTime) then
      begin
        if (ChangeDate <> 0) then
        begin
          LineOut('------------ ------------ ------ -------');
          LineOut(Format('%-25.25s %6d', ['Total Items Received:', ItemsReceived]));
        end;
        ChangeDate := FieldByName('ChangeDate').AsDateTime;
        LineOut(' ');
        LineOut(' ');
        LineOut('** I N V E N T O R Y   R E C E I P T **');
        LineOut('Invoice: ' + InvoiceID);
        LineOut('Received: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', ChangeDate));
        LineOut('Imported: ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', FieldByName('ImportTime').AsDateTime));
        LineOut('By User:   ' + FieldByName('UserNo').AsString);
        LineOut(' ');
        LineOut('----------------------------------------');
        LineOut('    UPC          PLU     RECEIVED COUNT');
        LineOut('<Description>');
        LineOut('------------ ------------ ------ -------');
      end;
      LineOut(Format('%12.12s %12.0f %6d %6d', [FieldByName('UPCText').AsString, FieldByName('PLUNo').AsCurrency, FieldByName('Adjustment').AsInteger, FieldByName('OnHand').AsInteger]));
      LineOut('<' + FieldByName('Name').AsString + '>');
      Inc(ItemsReceived, FieldByName('Adjustment').AsInteger);
      Next();
    end;  // while not eof
  end;  // with
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
  if (ChangeDate <> 0) then
  begin
    LineOut('------------ ------------ ------ -------');
    LineOut(Format('%-25.25s %6d', ['Total Items Received:', ItemsReceived]));
    LineOut(' ');
    ReportFtr();
    LineOut(' ');
    LineOut(' ');
    LineOut(' ');
    LineOut(' ');
    LineOut(' ');
  end;
end;
//...inv3
procedure PrintInventoryDeptReport(const DeptNo : integer; const DeptName : string);
var
  TotalItemsOnHand : integer;
  UPCText : string;
  BreakablePLUCount : integer;
  LargeUnit : string;
  SmallUnit : string;
  intrans : boolean;
begin
  TotalItemsOnHand := 0;
  LargeUnit := 'larger unit';
  SmallUnit := 'individual item';
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Check to see if department has UPCs that can be broken down (e.g., cigarette cartons)
    SQL.Clear();
    SQL.Add('select count(*) as BreakablePLUCount from PLU where DeptNo = :pDeptNo  and (BreakDownLink <> 0)');
    ParamByName('pDeptNo').AsInteger := DeptNo;
    ExecQuery();
    BreakablePLUCount := FieldByName('BreakablePLUCount').AsInteger;
    Close();
    if (BreakablePLUCount > 0) then
    begin
      SQL.Clear();
      SQL.Add('select distinct I.UnitName from (PLU P inner join InvUnits I on P.UnitID = I.UnitID)');
      SQL.Add(' where P.DeptNo = :pDeptNo and (I.UnitName is not null) and (P.BreakDownLink <> 0)');
      ParamByName('pDeptNo').AsInteger := DeptNo;
      ExecQuery();
      if (RecordCount = 1) then
        LargeUnit := LowerCase(Trim(FieldByName('UnitName').AsString));
      Close();
      SQL.Clear();
      SQL.Add('select distinct I.UnitName from PLU P inner join InvUnits I on P.UnitID = I.UnitID');
      SQL.Add(' where P.DeptNo = :pDeptNo and (I.UnitName is not null) and ((BreakDownLink = 0) or (BreakDownLink is null))');
      ParamByName('pDeptNo').AsInteger := DeptNo;
      ExecQuery();
      if (RecordCount = 1) then
        SmallUnit := LowerCase(Trim(FieldByName('UnitName').AsString));
      Close();
    end;
    SQL.Text := 'select PLUNo, UPC, Name, OnHand from PLU where DeptNo = :pDeptNo  and (BreakDownLink = 0 or BreakDownLink is null)';
    ParamByName('pDeptNo').AsInteger := DeptNo;
    ExecQuery();

    LineOut(' ');
    LineOut(' ');
    LineOut('*** INVENTORY ON HAND BY DEPARTMENT ***');
    if (BreakablePLUCount > 0) then
    begin
      LineOut('(by ' + SmallUnit + ' w/out ' + LargeUnit + ' data)');
    end;
    LineOut('DEPT: ' + DeptName);
    LineOut( '========================================');
    LineOut( 'Report Date  : ' + DateToStr(Date));
    LineOut( 'Report Time  : ' + TimeToStr(Time));
    LineOut( 'User  : ' + CurrentUserID + ' ' + CurrentUser);
    LineOut( '----------------------------------------');
    LineOut(' ');
    LineOut('----------------------------------------');
    LineOut('    UPC          PLU      ON HAND COUNT');
    LineOut('<Description>');
    LineOut('------------ ------------ --------------');
    while not eof do
    begin
      UPCText := '';  // formatfloat
      LineOut(Format('%12.0f %12.0f %13d', [FieldByName('UPC').AsCurrency, FieldByName('PLUNo').AsCurrency, FieldByName('OnHand').AsInteger]));
      LineOut('<' + FieldByName('Name').AsString + '>');
      Inc(TotalItemsOnHand, FieldByName('OnHand').AsInteger);
      Next();
    end;  // while not eof
    Close();

    LineOut('------------ ------------ --------------');
    LineOut(Format('%-32.32s %6d', ['Total Items On Hand:', TotalItemsOnHand]));
    LineOut(' ');
    // If department has UPCs that can be broken down (e.g., cigarette cartons),
    // then also provide a report on the carton UPCs.
    if (BreakablePLUCount > 0) then
    begin
      SQL.Text := 'select PLUNo, UPC, Name, OnHand from PLU where DeptNo = :pDeptNo  and BreakDownLink > 0';
      ParamByName('pDeptNo').AsInteger := DeptNo;
      ExecQuery();
      LineOut(' ');
      LineOut(' ');
      LineOut('*** INVENTORY ON HAND BY DEPARTMENT ***');
      LineOut('(by ' + LargeUnit + ' w/out ' + SmallUnit + ' data)');
      LineOut('DEPT: ' + DeptName);
      LineOut( '========================================');
      LineOut( 'Report Date  : ' + DateToStr(Date));
      LineOut( 'Report Time  : ' + TimeToStr(Time));
      LineOut( 'User  : ' + CurrentUserID + ' ' + CurrentUser);
      LineOut( '----------------------------------------');
      LineOut(' ');
      LineOut('----------------------------------------');
      LineOut('    UPC          PLU      ON HAND COUNT');
      LineOut('<Description>');
      LineOut('------------ ------------ --------------');
      TotalItemsOnHand := 0;
      while not eof do
      begin
        UPCText := '';  // formatfloat
        LineOut(Format('%12.0f %12.0f %13d', [FieldByName('UPC').AsCurrency, FieldByName('PLUNo').AsCurrency, FieldByName('OnHand').AsInteger]));
        LineOut('<' + FieldByName('Name').AsString + '>');
        Inc(TotalItemsOnHand, FieldByName('OnHand').AsInteger);
        Next();
      end;  // while not eof
      Close();
      LineOut('------------ ------------ --------------');
      LineOut(Format('%-32.32s %6d', ['Total Items On Hand:', TotalItemsOnHand]));
    end;  //if (BreakablePLUCount > 0)
  end;  // with
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
  LineOut(' ');
  ReportFtr();
  LineOut(' ');
  LineOut(' ');
  LineOut(' ');
  LineOut(' ');
  LineOut(' ');
end;

{-----------------------------------------------------------------------------
  Name:      PrintMOBatchReport
  Author:
  Date:      2008-12-04
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintMOBatchReport;
var
  sLn: shortstring;
  sum : currency;
  intrans : boolean;
begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  with POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    // Build SQL Statement
    SQL.Text := 'SELECT serialno, docvalue, purchts, transno, voided, voidts, posted from moneyorder where batched=0 and voided=0 order by serialno';
    ExecQuery;
    if bLogging then UpdateZlog('MO Batch Report Open');
    ReportHdr('MO Batch - Store');

    LineOut( 'Serial No    Value   Trans  ');
    LineOut( '---------- --------- ------ ');
    sum := 0.0;
    while not EOF do {Begin Processing Query}
    begin
      sum := sum + FieldByName('docvalue').AsCurrency;
      sLn := Format( '******%-4.4s ', [rightstr(FieldByName('serialno').AsString, 4)]) +
        Format( '%9.2f ', [FieldByName('docvalue').AsCurrency]) +
        Format( '%6d ', [FieldByName('transno').AsInteger]);
      LineOut( sLn );
      Next;
    end; {while not EOF}
    LineOut( '---------- --------- ------ ');
    LineOut( '           ' + Format('%9.2f ', [sum]) + '       ');
    LineOut(' ');
    Close;
    if bLogging then UpdateZlog('MO Batch Report Close');
    ReportFtr;


    SQL.Text := 'SELECT serialno, docvalue, purchts, transno, voided, voidts, posted from moneyorder where batched=0 and voided=1 order by serialno';
    ExecQuery;
    if bLogging then UpdateZlog('MO Voids Report Open');
    ReportHdr('Voided Money Orders - Store');

    LineOut( 'Serial No    Value   ');
    LineOut( '---------- --------- ');
    sum := 0.0;
    while not EOF do {Begin Processing Query}
    begin
      sum := sum + FieldByName('docvalue').AsCurrency;
      sLn := Format( '%-10.10s ', [FieldByName('serialno').AsString]) +
        Format( '%9.2f ', [FieldByName('docvalue').AsCurrency]);
      LineOut( sLn );
      Next;
    end; {while not EOF}
    LineOut( '---------- --------- ');
    LineOut( '           ' + Format( '%9.2f ', [sum]));
    LineOut(' ');
    Close;
    if bLogging then UpdateZlog('MO Voids Report Close');
    ReportFtr;
  end; {with IBRptSQL02Main}
  if not intrans then
    POSDataMod.IBRptTrans.Commit;
end; {procedure PrintMOBatchReport Report}



end.

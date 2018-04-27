{-----------------------------------------------------------------------------
 Unit Name: CloseDay
 Author:    Gary Whetton
 Date:      9/11/2003 2:53:50 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit CloseDay;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  //20041209_CISP...
  //MainMenu,
  //...20041209_CISP
  StdCtrls, Buttons, POSDM, DB, FileCtrl, WinTypes, WinProcs, SysUtils ;

const
  {$I ConditionalCompileSymbols.txt}

  MAX_DAYS_TO_KEEP_BATCH : integer = 30;  // Parameter used to remove old batch entries // eventually move to DB.
  MAX_DAYS_TO_KEEP_HOST_TOTALS : integer = 183;  // Parameter used to remove old host totals // eventually move to DB.

  MAX_DAYS_TO_KEEP_INVENTORY_AUDIT : integer = 60;  // Parameter used to remove old inventory audit entries // eventually move to DB.
  MAX_DAYS_TO_KEEP_INVENTORY_IMPORT : integer = 60;  // Parameter used to remove old inventory import entries // eventually move to DB.

function GetExportPath(AppPath : string): string;
procedure ExportDayAgnostic(dirpath : string);
procedure ExportTable(sPath, sTable, sOrderBy: shortstring; sSplitBy :char; DayId : integer = 0);
procedure ZipTotals(const DayId: integer; const apppath : string; const dirpath : string);
procedure CreateExportFile (TerminalNo, ShiftNo : Integer; OpName : String);

procedure ResetDay;
procedure SaveTotals(const dirpath : string);
procedure SaveLogfile(const dayid : integer; const dirpath : string);
procedure RemoveFile( FileName : string);
function WinExecAndWait32(FileName:String; Visibility : integer):integer;
procedure CleanUpDir(DirPath, FileMask: String; DaysOld : integer);

var
sBackUpCmd, sBakName, sBakFileName : string;


implementation

uses POSMain, POSMisc, POSMsg, FactorEx, PDIEx,
  ExceptLog, POSPost,
{$IFDEF LEATHERS}
  SnowBirdEx,
{$ENDIF}
  IBHeader,
{$IFDEF DAX_SUPPORT}
 StrUtils,
 DateUtils,              //20071128e
{$ENDIF}
  IBSQL,
  AESEx;

{-----------------------------------------------------------------------------
  Name:      WinExecAndWait32
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: FileName : String; Visibility : integer
  Result:    integer
  Purpose:
-----------------------------------------------------------------------------}
function WinExecAndWait32(FileName : String; Visibility : integer):integer;
var
zAppName:array[0..512] of char;
zCurDir:array[0..255] of char;
WorkDir:String;
StartupInfo:TStartupInfo;
ProcessInfo:TProcessInformation;
//cwe  ThisResult : lpdword;
begin
  StrPCopy(zAppName,FileName);
  GetDir(0,WorkDir);
  StrPCopy(zCurDir,WorkDir);
  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
                       zAppName, { pointer to command line string}
                       nil, { pointer to process security attributes }
                       nil, { pointer to thread security attributes }
                       false, { handle inheritance flag }
                       CREATE_NEW_CONSOLE or { creation flags } NORMAL_PRIORITY_CLASS,
                       nil, { pointer to new environment block }
                       nil, { pointer to current directory name }
                       StartupInfo, { pointer to STARTUPINFO }
                       ProcessInfo) then Result := -1 { pointer to PROCESS_INF }
  else
  begin
    WaitforSingleObject(ProcessInfo.hProcess, 300000);   // five minute timeout - just in case
    CloseHandle( ProcessInfo.hProcess );
    CloseHandle( ProcessInfo.hThread );
    Result := 0;
  end;
end;

function GetExportPath(AppPath : string): string;
var
  dirname, dirpath, zippath : string;
  i : integer;
begin
  if not (DirectoryExists(AppPath + 'History')) then
    CreateDir(AppPath + 'History');
  for i := 1 to 10 do
  begin
    dirname := FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ]);
    dirpath := AppPath + 'History' + PathDelim + dirname;
    zippath := AppPath + 'History' + PathDelim + dirname + '.Zip';
    if not(DirectoryExists(dirpath)) and not (FileExists(zippath)) then
      if CreateDir(dirpath) then
        break;
  end;
  Result := dirpath;
end;

procedure ExportDayAgnostic(dirpath : string);
begin
  fmPOSMsg.ShowMsg('', 'Saving Totals...');
  SaveTotals(dirpath);
  fmPOSMsg.ShowMsg('', 'Exporting System Totals...');
  ExportTable(dirpath, 'Totals', '', cDel);
  ExportTable(dirpath, 'Disc', '', cDel);
  {$IFDEF PDI_PROMOS}
  ExportTable(dirpath, 'Promotions', '', cDel);
  ExportTable(dirpath, 'PromoLists', '', cDel);
  {$ENDIF}
  ExportTable(dirpath, 'Dept', '', cDel);
  ExportTable(dirpath, 'Media', '', cDel);
  ExportTable(dirpath, 'Hourly', '', cDel);
  ExportTable(dirpath, 'Grade', '', cDel);
  ExportTable(dirpath, 'Tax', '', cDel);
  ExportTable(dirpath, 'PLU', '', cDel);
  ExportTable(dirpath, 'MIXMatch', '', cDel);
  ExportTable(dirpath, 'GRP', '', cDel);
  ExportTable(dirpath, 'NFPLUExp','', cDel);
  ExportTable(dirpath, 'BankFunc', '', cDel);
end;

{-----------------------------------------------------------------------------
  Name:      ResetDay
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ResetDay();
var
  ResetCount, MaxBatchID : integer;
begin

  // Write Data to Comma Delim Text & Zip-It Up
  with POSDataMod.IBRptSQL01Main do
  begin
    Assert(not open, 'IBRptSQL01Main is open');
    fmPOSMsg.ShowMsg('', 'Clearing Daily Totals...');
    UpdateZLog('Clearing Daily Totals');
    SQL.Text := 'EXECUTE PROCEDURE PROD_DELETE_NEW';
    ExecQuery;
    Close;

    {$IFDEF PDI_PROMOS}
    SQL.Text := 'DELETE FROM PROMOSHIFT';
    ExecQuery;
    Close;
    {$ENDIF}

    SQL.Clear;
    SQL.Text := 'DELETE FROM PLU Where DelFlag = 1';
    ExecQuery;
    Close;

    //20070227d...
    // Remove orphaned PLUMOD records
    SQL.Text := 'DELETE FROM PLUMOD WHERE PLUNO in (SELECT DISTINCT pm.PLUNO FROM PLUMOD pm LEFT JOIN PLU p on pm.PLUNO = p.PLUNO WHERE p.PLUNO is NULL)';
    ExecQuery;
    Close;

    SQL.Text := 'DELETE FROM PLUImport Where Posted = 1 and ((cast(''Now'' as timestamp) - PostDate) > 7)';
    ExecQuery;
    Close;

    SQL.Text := 'DELETE FROM CWTrans';
    ExecQuery;
    Close;

    SQL.Text := 'DELETE FROM CWMsgLog';
    ExecQuery;
    Close;

    SQL.Text := 'DELETE FROM CWAudit';
    ExecQuery;
    Close;
  end; {with TempQuery}

  fmPOSMsg.ShowMsg('', 'Updating System Totals...');

  with POSDataMod.IBRptSQL01Main do
  begin
    Assert(not open, 'IBRptSQL01Main is open');
    // UPDATE Totals Record
    SQL.Text := 'UPDATE Totals SET ' +
     'ResetCount = ResetCount + 1,' +
     'BegGT = CurGT,' +
     'Training = 0,' +
     'DlyND = 0,' +
     'DlyDS = 0,' +
     'DlyPrePayCount = 0,' +
     'DlyPrePayRcvd = 0,' +
     'DlyPrePayCountUsed = 0,' +
     'DlyPrePayUsed = 0,' +
     'DlyPrePayRfndCount = 0,' +
     'DlyPrePayRfnd = 0,' +
     'DlyTransCount = 0,' +
     'DlyItemCount = 0,' +
     'DlyNoSaleCount = 0,' +
     'DlyReturnTax = 0,' +
     'DlyNoTax = 0,' +
     'FuelCount = 0,' +
     'FuelAmount = 0,' +
     'MdseCount = 0,' +
     'MdseAmount = 0,' +
     'FMCount = 0,' +
     'FMAmount = 0,' +
     'DlyVoidCount = 0,' +
     'DlyVoidAmount = 0,' +
     'DlyRtrnCount = 0,' +
     'DlyRtrnAmount = 0,' +
     //Build 18
     'DlyPORCount = 0,' +
     'DlyPORAmount = 0,' +
     //Build 18
     'DlyCancelCount = 0,' +
     'DlyCancelAmount = 0,' +
     //cwh...
     'DlyCATCarwashCount = 0,' +
     'DlyCATCarwashAmount = 0,' +
     //...cwh
     'DlyCATCount = 0,' +
     'DlyCATAmount = 0,' +
     'StartingTill = 0,' +
     'TillTimeOutCount = 0,' +
     'CurShift = 1,' +
     'StartingBatch = :pStartBatch,' +
     'OpenDate = :pDate, ' +
     'CloseDate = null ';
    ParamByName('pStartBatch').AsInteger := (nCreditBatchID + 1);
    ParamByName('pDate').AsDateTime := Now();
    ExecQuery;
    Close;

    SQL.Text := 'Select ResetCount, OpenDate from Totals Where TotalNo = 0';
    ExecQuery;
    ResetCount := FieldByName('ResetCount').AsInteger;
    OpenDate   := FieldByName('OpenDate').AsDateTime;
    Close;

    SQL.Text := 'Select Max(BatchID) MaxID From CCRTB';
    ExecQuery;
    MaxBatchID := FieldByName('MaxID').AsInteger;
    Close;

    SQL.Text := 'Update CCRTB Set OpenDate = :pOpenDate, DayID = :pDayID Where BatchID = :pBatchID';
    ParamByName('pBatchID').AsInteger   := MaxBatchID;
    ParamByName('pDayID').AsInteger     := ResetCount;
    ParamByName('pOpenDate').AsDateTime := OpenDate;
    ExecQuery;
    Close;

    SQL.Text := 'UPDATE Terminal SET CurShift = 1';
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'XMD Logs...');
    {$IFDEF FF_PROMO}
    //20080128a
    if (Setup.DBVersionID >= DB_VERSION_ID_FF_PROMO) then
    begin
      SQL.Text := 'DELETE FROM FFAwardActivity where CouponPosted = 1 or CouponDate < :pCouponDate';
      ParamByName('pCouponDate').AsDateTime := Now() - 30 {days};
      ExecQuery();
      Close();
      SQL.Text := 'DELETE FROM FFAwardDefinition where CouponActive = 1 and CouponDate < :pCouponDate';
      ParamByName('pCouponDate').AsDateTime := Now() - 30 {days};
      ExecQuery();
      Close();
    end;
    {$ENDIF}
    SQL.Text := 'DELETE FROM XMDCouponActivity where Posted = 1';
    ExecQuery;
    fmPOSMsg.ShowMsg('', 'Security Logs...');
    Close;

    SQL.Text := 'DELETE FROM SecurityLog';
    ExecQuery;
    Close;

    SQL.Text := 'DELETE FROM CATStatus';
    ExecQuery;
    Close;

    SQL.Text := 'SET GENERATOR LOGID_GEN TO 1 ';
    ExecQuery;
    Close;

    SQL.Text := 'SET GENERATOR MSGID_GEN TO 1 ';
    ExecQuery;
    Close;

    SQL.Text := 'SET GENERATOR MSGIDNo_GEN TO 1 ';
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'Clearing old batch entries...');
    SQL.Text := 'DELETE FROM CCBatch WHERE ((cast(''Now'' as timestamp) - CreateTime) > :pMAXDaysToKeepBatch)';
    ParamByName('pMAXDaysToKeepBatch').AsInteger := MAX_DAYS_TO_KEEP_BATCH;
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'Clearing old host totals...');
    SQL.Text := 'DELETE FROM CCHostTotals WHERE ((cast(''Now'' as timestamp) - CreateDate) > :pMAXDaysToKeepHostTotals)';
    ParamByName('pMAXDaysToKeepHostTotals').AsInteger := MAX_DAYS_TO_KEEP_HOST_TOTALS;
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'Clearing old inventory audit records...');
    SQL.Text := 'DELETE FROM InvAudit WHERE ((cast(''Now'' as timestamp) - ChangeDate) > :pMAXDaysToKeepInventoryAudit)';
    ParamByName('pMAXDaysToKeepInventoryAudit').AsInteger := MAX_DAYS_TO_KEEP_INVENTORY_AUDIT;
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'Clearing old inventory import records...');
    SQL.Text := 'DELETE FROM InvUPCScanned WHERE ((cast(''Now'' as timestamp) - ImportTime) > :pMAXDaysToKeepInventoryImport)';
    ParamByName('pMAXDaysToKeepInventoryImport').AsInteger := MAX_DAYS_TO_KEEP_INVENTORY_IMPORT;
    ExecQuery;
    Close;

    fmPOSMsg.ShowMsg('', 'Clearing old Fuel Price Change Logs...');
    SQL.Text := 'DELETE FROM FuelPriceChangeLog WHERE posted <> 1 and ((cast(''Now'' as timestamp) - TS) > :pMAXDaysToKeep)';
    ParamByName('pMAXDaysToKeep').AsInteger := 15;
    ExecQuery;
    Close;

    nShiftNo := 1;
    curSale.nTransNo := 0;
    SQL.Text := 'Select terminalno from Terminal order by terminalno';
    ExecQuery;
    while not EOF do
    begin
      fmPOSMsg.ShowMsg('', 'Initializing Shift# 1 Terminal# ' + IntToStr(Fields[0].AsInteger));
      InitShiftTotals(Fields[0].AsInteger, 1);  // create shift one for all terminals
      next;
    end;
    Close;
  end; {with TempQuery - Move CCBatch to CCBatchHist}
  InitShiftTotals(99, 1); // Create Fuel shift

  fmPOSMsg.Close;

end; {procedure ResetDay}


{-----------------------------------------------------------------------------
  Name:      CleanUpDir
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: DirPath, FileMask: String; DaysOld : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CleanUpDir(DirPath, FileMask: String; DaysOld : integer);
var
  sr : TSearchRec;
begin
  if FindFirst(DirPath + PathDelim + FileMask , faAnyFile, sr) = 0 then
  begin
    repeat
      if (sr.Name <> 'Viewer') and (sr.Name[1] <> '.') and ((sr.Attr and faDirectory) = faDirectory) then    // FIXME: bad form, but this is called from a minimum number of places
      begin
        if (DaysBetween(Now, FileDateToDateTime(sr.Time)) > DaysOld) then
        begin
          CleanUpDir(DirPath + PathDelim + sr.Name + PathDelim, '*.*', DaysOld);
          try
            if not RemoveDir(DirPath + PathDelim + sr.Name) then
              RaiseLastOSError;
          except
            on E: Exception do
              UpdateExceptLog('Cannot delete directory %s%s%s - Exception %s - %s', [DirPath, PathDelim, sr.Name, E.ClassName, AnsiReplaceStr(E.Message, #13#10, ' - ')]);
          end;
        end;
      end
      else if (sr.Attr and faDirectory) = 0 then
      begin
        if ((Now - FileDateToDateTime(sr.Time)) > DaysOld) then
          try
            if not DeleteFile(DirPath + PathDelim + sr.name) then
              RaiseLastOSError;
          except
            on E: Exception do
              UpdateExceptLog('Cannot delete file %s%s%s - Exception %s - %s', [DirPath, PathDelim, sr.Name, E.ClassName, AnsiReplaceStr(E.Message, #13#10, ' - ')]);
          end;
      end
      else
    until (FindNext(sr) <> 0);
    FindClose(sr);
  end;
end;


{-----------------------------------------------------------------------------
  Name:      SaveTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
Procedure SaveTotals(const dirpath : string);
Var
  f    : Textfile;
  Day  : Byte;
Begin
  Day := DayofWeek(Now);
  Assign (f, dirpath + PathDelim + 'Totals' + IntToStr(Day) + '.txt');
  Rewrite (f);
  Writeln(f, 'Date : ' + DateTimeToStr(Now));
  With POSDataMod.IBRptSQL02Main do
  begin
    Assert(not open, 'IBRptSQL02Main is open');
    SQL.Text := 'SELECT * FROM Totals ORDER BY TotalNo';
    ExecQuery;
    while not EOF do
    begin
      If FieldByName('TotalNo').AsInteger = 0 Then
        Writeln(f,'Totals ' + DateToStr(Now) + ' :')
      Else
        Writeln(f,'Totals Shift # ' + FieldByName('TotalNo').AsString);
      Writeln(f);
      Writeln(f,'Reset Count        :' + FieldByName('ResetCount').AsString);
      Writeln(f,'Begin Grand Total  :' + FieldByName('BegGT').AsString);
      Writeln(f,'Training           :' + FieldByName('Training').AsString);
      Writeln(f,'DlyND              :' + FieldByName('DlyND').AsString);
      Writeln(f,'DlyDS              :' + FieldByName('DlyDS').AsString);
      Writeln(f,'DlyPrePayCount     :' + FieldByName('DlyPrePayCount').AsString);
      Writeln(f,'DlyPrePayRcvd      :' + FieldByName('DlyPrePayRcvd').AsString);
      Writeln(f,'DlyPrePayCountUsed :' + FieldByName('DlyPrePayCountUsed').AsString);
      Writeln(f,'DlyPrePayUsed      :' + FieldByName('DlyPrePayUsed').AsString);
      Writeln(f,'DlyPrePayRfndCound :' + FieldByName('DlyPrePayRfndCount').AsString);
      Writeln(f,'DlyPrePayRfnd      :' + FieldByName('DlyPrePayRfnd').AsString);
      Writeln(f,'DlyTransCount      :' + FieldByName('DlyTransCount').AsString);
      Writeln(f,'DlyItemCount       :' + FieldByName('DlyItemCount').AsString);
      Writeln(f,'DlyNoSaleCount     :' + FieldByName('DlyNoSaleCount').AsString);
      Writeln(f,'DlyReturnTax       :' + FieldByName('DlyReturnTax').AsString);
      Writeln(f,'DlyNoTax           :' + FieldByName('DlyNoTax').AsString);
      Writeln(f,'FuelCount          :' + FieldByName('FuelCount').AsString);
      Writeln(f,'FuelAmount         :' + FieldByName('FuelAmount').AsString);
      Writeln(f,'MdseCount          :' + FieldByName('MdseCount').AsString);
      Writeln(f,'MdseAmount         :' + FieldByName('MdseAmount').AsString);
      Writeln(f,'FMCount            :' + FieldByName('FMCount').AsString);
      Writeln(f,'FMAmount           :' + FieldByName('FMAmount').AsString);
      Writeln(f,'DlyVoidCount       :' + FieldByName('DlyVoidCount').AsString);
      Writeln(f,'DlyVoidAmount      :' + FieldByName('DlyVoidAmount').AsString);
      Writeln(f,'DlyRtrnCount       :' + FieldByName('DlyRtrnCount').AsString);
      Writeln(f,'DlyRtrnAmount      :' + FieldByName('DlyRtrnAmount').AsString);
      Writeln(f,'DlyCancelCount     :' + FieldByName('DlyCancelCount').AsString);
      Writeln(f,'DlyCancelAmount    :' + FieldByName('DlyCancelAmount').AsString);
      Writeln(f, '-------------------------------------------------------');
      Writeln(f);
      Next;
    end;
    Close;
  end;
  Close(f);
End; {procedure SaveTotals}


{-----------------------------------------------------------------------------
  Name:      SaveLogfile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
Procedure SaveLogfile(const dayid : integer; const dirpath : string);
Var
  f    : Textfile;
  Day  : Byte;
Begin

  fmPOSMsg.ShowMsg('', 'Exporting Electronic Journal...');
  Day := DayofWeek(Now);
  Assign (f, dirpath + PathDelim + 'Logfile' + IntToStr(Day) + '.txt');
  Rewrite (f);
  Writeln(f, 'Date : ' + DateTimeToStr(Now));
  with POSDataMod.IBRptSQL02Main do
  begin
    SQL.Text := 'SELECT * FROM POSLog where dayid=:pDayId ORDER BY LogID';
    ParamByName('pDayId').AsInteger := Dayid;
    ExecQuery;
    while not EOF do
    begin
      Writeln(f, FieldByName('LogNo').AsString + '|' +
                 FieldByName('RecType').AsString   + '|' +
                 FieldByName('Data').AsString   + '|' +
                 FormatDateTime('yyyy-mm-dd hh:mm:ss', FieldByName('TimeStmp').AsDatetime));
      Next;
    end;
    Writeln(f, '-------------------------------------------------------');
    Writeln(f, ' End of File ');
    Close;
  end;
  Close(f);
End; {procedure SaveLogFile}

function StringifyField(field : TIBXSQLVAR): string;
begin
  if (field.SQLType = SQL_TIMESTAMP) or (field.SQLType = SQL_TYPE_DATE) or (field.SQLType = SQL_TYPE_TIME) then
  begin
    if field.AsDatetime = 0 then Result := ''
    else Result := FormatDateTime('yyyy-mm-dd hh:mm:ss.sss', field.AsDatetime);
  end
  else if (field.SQLType = SQL_VARYING) or (field.SQLType = SQL_TEXT) then
  begin
    if TrimRight(Field.AsString) = '' then Result := ''
    else Result := '"' + Field.AsString + '"';
  end
  else
    Result := Field.AsString;
end;


{Export Table into CSV Format with First Line = Column Names}
{-----------------------------------------------------------------------------
  Name:      ExportTable
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: sTable, sOrderBy : shortstring
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ExportTable(sPath, sTable, sOrderBy: shortstring; sSplitBy: char; DayId : integer);
var
  i: Integer;
  sBuf, sFname: String;
  TF: TextFile;
begin
  if sSplitBy = ',' then
    sFname := sPath + PathDelim + sTable + '.csv'
  else
    sFname := sPath + PathDelim + sTable + '.txt';
  AssignFile(TF, sFname );
  ReWrite(TF);
  with POSDataMod.IBRptSQL02Main do
  begin
    SQL.Clear;
    SQL.Add('SELECT * FROM ' + sTable);
    if DayId <> 0 then
      SQL.Add('Where DayId = :pDayId');
    if sOrderBy <> '' then
      SQL.Add('Order by ' + sOrderBy);
    try
      if DayId <> 0 then
        ParamByName('pDayId').AsInteger := DayId;
      ExecQuery;
    except
      on E : Exception do
      begin
        UpdateExceptLog('(ExportTable) Error Executing: "' + SQL.Text + '" ' + E.Message );
        CloseFile(TF);
        Exit;
      end;
    end;
    // Export Column Names
    sBuf := Fields[0].Name;
    for i := 1 to FieldCount-1 do
      sBuf := sBuf + sSplitBy + Fields[i].Name;
    WriteLn(TF, sBuf);

    // Export Column Data
    while not EOF do
    begin
      sBuf := '';
      sBuf := StringifyField(Fields[0]);
      for i := 1 to FieldCount-1 do
        sBuf := sBuf + sSplitBy + StringifyField(Fields[i]);
      WriteLn(TF, sBuf);
      Next;
    end;

    Close;
  end;  {with IBRptSQL02Main}
  CloseFile(TF);

end; {procedure ExportTable}


procedure copyfile(const sourcepath : string; const destpath: string; const fn : string);
var
  FromName, ToName : array[0..200] of char;
begin
  strpcopy (FromName, sourcepath + PathDelim + fn);
  strpcopy (ToName, destpath + PathDelim + fn);
  windows.CopyFile(FromName, ToName, False);
end;

procedure copyglob(const sourcepath : string; const destpath : string; const glob : string);
var
  sr : TSearchRec;
begin
  if FindFirst(sourcepath + PathDelim + glob, faAnyFile, sr) = 0 then
  begin
    repeat
      copyfile(sourcepath, destpath, sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;


procedure movefile(const sourcepath : string; const destpath : string; const fn : string);
begin
  renamefile(sourcepath + PathDelim + fn, destpath + PathDelim + fn);
end;

{ Move a glob of files to a path }
procedure moveglob(const sourcepath : string; const destpath : string; const glob : string);
var
  sr : TSearchRec;
begin
  if FindFirst(sourcepath + PathDelim + glob, faAnyFile, sr) = 0 then
  begin
    repeat
      renamefile(sourcepath + PathDelim + sr.Name, destpath + PathDelim + sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end
  else
    UpdateZLog('No file matching ' + glob + ' found in ' + sourcepath);
end;


{-----------------------------------------------------------------------------
  Name:      ZipTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ZipTotals(const DayId : integer; const apppath : string; const dirpath : string);
// dirpath is w/o trailing PathDelim
var
  s :  string;
  cDel : char;
  i : short;
  StartTime : TDateTime;

begin
  if Setup.ExportDelimiter = 0 then
    cDel := ','
  else
    cDel := '|';

  // Export Tables To CommaDelim (*.csv)
  //fmPOS.CloseTables;

  SaveLogFile(dayid, dirpath);

  fmPOSMsg.ShowMsg('', 'Exporting Discounts...');
  ExportTable(dirpath, 'DiscShift', '', cDel, DayId);
  {$IFDEF PDI_PROMOS}
  ExportTable(dirpath, 'PromoShift', '', cDel, DayId);
  {$ENDIF}
  fmPOSMsg.ShowMsg('', 'Exporting Receipts ...');
  ExportTable(dirpath, 'Receipt', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Mix Match ...');
  ExportTable(dirpath, 'MixMatchShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Departments...');
  ExportTable(dirpath, 'DepShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Media...');
  ExportTable(dirpath, 'MedShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Bank Functions...');
  ExportTable(dirpath, 'BankShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting PLU...');
  ExportTable(dirpath, 'PluShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Hourly...');
  ExportTable(dirpath, 'HourlyShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Fuel Transactions...');
  ExportTable(dirpath, 'FuelTran', 'SaleID', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Pump Totals...');
  ExportTable(dirpath, 'PumpTls', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Tax...');
  ExportTable(dirpath, 'TaxShift', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Credit Auth Log...');
  ExportTable(dirpath, 'CCAuth', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Credit Batch Log...');
  ExportTable(dirpath, 'CCBatch', 'HostID, BatchID, BatchNo, SeqNo', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Credit Host Totals...');
  ExportTable(dirpath, 'CCHostTotals', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Credit Message Log...');
  ExportTable(dirpath, 'CCMsgLog', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Credit Batch Totals...');
  ExportTable(dirpath, 'CCRTB', 'BatchID', cDel, DayId);
  fmPOSMsg.ShowMsg('','Exporting Credit Signatures...');
  ExportTable(dirpath, 'PinPadSignature', '', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting Security Logs...');
  ExportTable(dirpath, 'SecurityLog', 'MSGTime', cDel, DayId);
  fmPOSMsg.ShowMsg('', 'Exporting XMD Logs...');
  ExportTable(dirpath, 'XMDCouponActivity', 'CouponDate', cDel, DayId);
  {$IFDEF FF_PROMO}   //20080128a
  if (Setup.DBVersionID >= DB_VERSION_ID_FF_PROMO) then
  begin
    fmPOSMsg.ShowMsg('', 'Exporting FF Award Logs...');
    ExportTable(dirpath, 'FFAwardActivity', 'CouponDate', cDel, DayId);
  end;
  {$ENDIF}
  fmPOSMsg.ShowMsg('', 'Exporting CAT Logs...');
  ExportTable(dirpath, 'CATStatus', 'CATNo', cDel, DayId);
  if Setup.CarwashInterfaceType <> 1 then
  begin
    fmPOSMsg.ShowMsg('', 'Exporting Carwash Transactions...');
    ExportTable(dirpath, 'CWTrans', '', cDel, DayId);
    fmPOSMsg.ShowMsg('', 'Exporting Carwash Message Log...');
    ExportTable(dirpath, 'CWMsgLog', '', cDel, DayId);

    fmPOSMsg.ShowMsg('', 'Exporting Carwash Audit Info...');
    StartTime := Now();
    while (fCarwashTotals) do  // wait for carwash server to complete
    begin
      Application.ProcessMessages;
      sleep(20);
      if TimerExpired(StartTime, 30) then
        fCarwashTotals := False;
    end;
    ExportTable(dirpath, 'CWAudit', '', cDel, DayId);
  end;

  //inv2...
  fmPOSMsg.ShowMsg('', 'Exporting Inventory Audit...');
  ExportTable(dirpath, 'InvAudit', 'SeqNo', cDel, DayId);
  //...inv2
  
  fmPOSMsg.ShowMsg('', 'Exporting Card Type Shift...');
  ExportTable(dirpath, 'MedCardTypeShift', '', cDel, DayId);

  fmPOSMsg.ShowMsg('', 'Exporting FlowRates...');
  ExportTable(dirpath, 'flowrate', '', cDel, DayId);

  // move/copy all the rest of the files into place
  moveglob (AppPath, dirpath, 'RPTLOG?.TXT');
  moveglob (AppPath, dirpath, '*.LOG');
  copyglob (AppPath, dirpath, RightStr( '00' + Trim(Setup.NUMBER), 3 ) + '_' + FormatDateTime('YYYYMMDD',Now()) + '*.cec');
  moveglob (AppPath, dirpath, '*.exp');
  movefile (AppPath, dirpath, 'PBDNLD');
  try
    movefile ('c:\Program Files\Borland\Interbase', dirpath, 'Interbase.log');
  except
  end;
  {$IFDEF DAX_SUPPORT}
  s := 'POS_' + RightStr('000' + Trim(Setup.Number), 3) + '_' + FormatDateTime('YYYY-MM-DD',IncDay(Now(),-1)) + '.txt';
  movefile (AppPath + PathDelim + 'History', dirpath, s);
  {$ENDIF}

  fmPOSMsg.ShowMsg('', 'Archiving Data...');
  with fmPOS.Zipper do
  begin
    AutoSave := False;
    FileName := dirpath + '.Zip';
    AddFiles (dirpath + PathDelim + '*.*', 0);
    Save;
    CloseArchive;
  end;

  fmPOSMsg.ShowMsg('', 'Copying to Backup...');
  copyfile(extractFilePath(dirpath + '.Zip'), '\\' + fmPOS.BackupTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude\History', extractfilename(dirpath + '.Zip'));

  if cDel = '|' then
    s := 'TXT'
  else
    s := 'CSV';
  copyfile(dirpath, '\\' + fmPOS.BackupTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude', 'Totals.' + s);
  copyfile(dirpath, '\\' + fmPOS.BackupTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude', 'Grade.' + s);

  fmPOSMsg.ShowMsg('', 'Cleaning Up Backup Data...');
  if (fmPOS.BackUpTerminalNo > 0) and (fmPOS.BackUpTerminalUNCName > '') then
  begin
    for i := 1 to 10 do
    begin
      s := '\\' + fmPOS.BackUpTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude\DataLog' + IntToStr(i) + '.txt';
      RemoveFile( s);
    end;
    s := '\\' + fmPOS.BackUpTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude\CATLog.txt';
    RemoveFile( s);
    s := '\\' + fmPOS.BackUpTerminalUNCName + '\' + fmPOS.BackupTerminalAppDrive + '\Latitude\FuelLog.txt';
    RemoveFile( s);
  end;


  //fmPOS.OpenTables(True);

end; {procedure ZipTotals}



{-----------------------------------------------------------------------------
  Name:      RemoveFile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: FileName : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure RemoveFile( FileName : string);
var
F : Textfile;
begin
  if FileExists(FileName) then
  begin
    AssignFile(F, FileName);
    try
      Erase(F);
    except
      {$I-}
      CloseFile(F);
      {$I+}
      try
        AssignFile(F, FileName);
        Erase(F);
      except
        fmPOS.POSError('Error Deleting ' + Filename);
      end;
    end;
  end;
end;


//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------
{-----------------------------------------------------------------------------
  Name:      CreateExportFile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo : Integer; OpName : String
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CreateExportFile (TerminalNo, ShiftNo : Integer; OpName : String);
begin
  case Setup.EODExport of
    2 :  CreateFactorExportFile( TerminalNo, ShiftNo, OpName );
    3 :  CreatePDIExportFile( TerminalNo, ShiftNo, OpName );   // GMM: Added TerminalNo
    4 :  CreateAESExportFile( ShiftNo, OpName );
    5 :  CreateFactorExportFile( TerminalNo, ShiftNo, OpName );
    {$IFDEF LEATHERS}
    6 :  CreateSnowBirdExportFile( TerminalNo, ShiftNo, OpName );
    {$ENDIF}
  end;
end; {end procedure CreateExportFile}

//20071128c (NOTE:  procedure SavePLUSales() moved to unit Receipt)

end.

{-----------------------------------------------------------------------------
 Unit Name: SysMgrImport
 Author:    Gary Whetton
 Date:      4/13/2004 4:23:13 PM
 Revisions: Build Number   Date      Author


-----------------------------------------------------------------------------}
unit SysMgrImport;

{$I ConditionalCompileSymbols.txt}

interface

uses SysUtils;


  
procedure ImportSysMgrPLU();
procedure ActivatePLUImport();
procedure ActivateDeptImport();
{$IFDEF FF_PROMO}
procedure ActivateSysMgrFuelFirstPromo();
{$ENDIF}

implementation
uses Classes,  
     Forms,    // Application object
     DateUtils,
     StrUtils,
     IBSQL,    // cursor selection
     JCLDebug, // backtraces
     JclHashMapsCustom,  // Cursors
     JCLContainerIntf, JCLHashMaps, // unitmap
     xmlrpctypes, xmlrpcclient, Reports, POSPrt,
     POSMain, POSDM, POSMisc, POSMsg, ExceptLog;
const

  // Action codes
  IMPORT_ACTION_DISCOUNT_DELETE            = 'DSCDEL';
  IMPORT_ACTION_DISCOUNT_UPDATE            = 'DSCUPD';
  IMPORT_ACTION_PLU_DELETE                 = 'PLUDEL';
  IMPORT_ACTION_PLU_UPDATE                 = 'PLUUPD';
  IMPORT_ACTION_VOLUME_DISC_DELETE         = 'VDSDEL';
  IMPORT_ACTION_VOLUME_DISC_UPDATE         = 'VDSUPD';
  {$IFDEF FF_PROMO}
  IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE    = 'FFPDEL';
  IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE    = 'FFPUPD';
  {$ENDIF}
  IMPORT_ACTION_DEPT_MAP                   = 'DEPMAP';
  IMPORT_ACTION_DEPT_DELETE                = 'DEPDEL';
  IMPORT_ACTION_DEPT_UPDATE                = 'DEPUPD';

  IMPORT_ACTION_RPT_DELETE                 = 'RPTDEL';
  IMPORT_ACTION_RPT_UPDATE                 = 'RPTUPD';
  IMPORT_ACTION_PCMAP_DELETE               = 'PCMDEL';
  IMPORT_ACTION_PCMAP_UPDATE               = 'PCMUPD';

  // Field numbers used in import file:
  FLD_IMPORT_ACTION               =  1;
  FLD_IMPORT_ACTIVATE_DATE        =  2;
  FLD_IMPORT_ACTIVATE_TIME        =  3;
  FLD_IMPORT_RECORD_TYPE          =  4;
  FLD_IMPORT_PLU_NUMBER           =  5;
  FLD_IMPORT_UPC                  =  6;
  FLD_IMPORT_NAME                 =  7;
  FLD_IMPORT_DEPARTMENT_NUMBER    =  8;
  FLD_IMPORT_PRICE                =  9;
  FLD_IMPORT_SPLIT_QUANTITY       = 10;
  FLD_IMPORT_SPLIT_PRICE          = 11;
  FLD_IMPORT_DISCOUNT             = 12;
  FLD_IMPORT_FOOD_STAMPABLE       = 13;
  FLD_IMPORT_WIC                  = 14;
  FLD_IMPORT_TAX_NUMBER           = 15;
  FLD_IMPORT_MODIFIER_GROUP       = 16;
  FLD_IMPORT_MODIFIER_NUMBER      = 17;
  FLD_IMPORT_MODIFIER_NAME        = 18;
  FLD_IMPORT_LINKED_PLU           = 19;
  FLD_IMPORT_PRODUCT_GROUP_NUMBER = 20;
  FLD_IMPORT_ITEM_NUMBER          = 21;
  FLD_IMPORT_VENDOR_NUMBER        = 22;
  FLD_IMPORT_VENDOR_NAME          = 23;
  FLD_IMPORT_PACK_SIZE            = 24;
  FLD_IMPORT_RETAIL_PRICE         = 25;
  FLD_IMPORT_BREAKDOWN_LINK       = 26;
  FLD_IMPORT_BREAKDOWN_ITEM_COUNT = 27;
  FLD_IMPORT_ITEM_IS_SOLD         = 28;
  FLD_IMPORT_ITEM_IS_PURCHASED    = 29;
  FLD_IMPORT_UNIT_NAME            = 30;
  FLD_IMPORT_ITEM_ACTIVATION      = 31;
  FLD_IMPORT_ITEM_SWIPE           = 32;
  FLD_IMPORT_MRC                  = 33;

  FLD_IMPORT_GROUP_NUMBER         = 16;
  FLD_IMPORT_HALO                 = 17;
  FLD_IMPORT_LALO                 = 18;
  FLD_IMPORT_RESTRICTION_CODE     = 19;
  FLD_IMPORT_SUBTRACTING          = 20;
  FLD_IMPORT_MAX_COUNT            = 21;

  FLD_IMPORT_COUPON_CODE          =  5;
  FLD_IMPORT_COUPON_RECEIPT_DATA  =  6;

  FLD_IMPORT_DEPT_MAP_FROM        =  5;
  FLD_IMPORT_DEPT_MAP_TO          =  6;

  FLD_IMPORT_RPT_VENDOR           =  5;

  FLD_IMPORT_PCM_PRODCODE         =  5;
  FLD_IMPORT_PCM_UPC              =  6;

type
  pIntMap = ^TIntMap;
  TIntMap = record
    iFrom : integer;
    iTo   : integer;
  end;
  
  EImportParse = class(Exception);
  EImportTooEarly = class(Exception);

  pIntCurrRec = ^TIntCurrRec;
  TIntCurrRec = record
    i : integer;
    c : currency;
  end;

var
  bLogFileInitialized : boolean;
  bErrorLogInitialized : boolean;
  sImportFileHeader : string;
  ImportLog : TextFile;
  ImportErrLog : TextFile;

  sImportLogName : string;
  sImportErrLogName : string;

  DeptMapList : TList;
  
  LogBuffer : TStrings = nil;



function ProcessImportFile(const sFName : string) : Boolean; forward;
procedure ActivateDeptUpdate(var Cursors : TIBSQLBuilder); forward;
procedure ActivateDeptDelete(var Cursors : TIBSQLBuilder); forward;
procedure ActivatePLUUpdate(var Cursors : TIBSQLBuilder ; var unitmap : IJclStrStrMap; const PCR : TStrings = nil; const DS : TList = nil); forward;
procedure ActivatePLUDelete(var Cursors : TIBSQLBuilder); forward;
procedure ActivateDiscountDelete(var Cursors : TIBSQLBuilder); forward;
procedure ActivateDiscountUpdate(var Cursors : TIBSQLBuilder); forward;
procedure ActivateVolumeDiscountUpdate(var Cursors : TIBSQLBuilder); forward;
procedure ActivateVolumeDiscountDelete(var Cursors : TIBSQLBuilder); forward;
{$IFDEF FF_PROMO}
procedure ImportSysMgrFuelFirstPromo(const InputString     : Tstrings;
                                     const sImportAction   : string;
                                     const iImportNo       : integer;
                                     const tActivationDate : TDateTime;
                                     const sRecordType     : string;
                                     var Cursors : TIBSQLBuilder); forward;
//  function ActivateFuelFirstPromoDelete() : boolean; forward;
//  function ActivateFuelFirstPromoUpdate() : boolean; forward;
{$ENDIF}
procedure ClearPLUKey(var Cursors : TIBSQLBuilder; ClearPLUNo : currency); forward;
procedure ClearDeptKey(var Cursors : TIBSQLBuilder; ClearDeptNo : integer); forward;
function ClearTouchKey(var Cursors : TIBSQLBuilder;
                       const KeyboardIndex : integer;
                       const ButtonIndex : integer;
                       var sSQLErrMsg : string) : boolean; forward;
procedure LogImportMessage(const sMessage     : string;
                           const bToLogFile   : boolean;
                           const bToErrorFile : boolean); forward;
procedure ImportSysMgrDeptMap(const InputString     : Tstrings;
                              const sImportAction   : string;
                              const iImportNo       : integer;
                              const tActivationDate : TDateTime;
                              const sRecordType     : string;
                              var DML : TList); forward;
function ValidateDeptMap(DeptMapList : TList) : boolean; forward;
procedure MapDeptNumbers(); forward;

procedure SaveImportReject(const rejString : string); forward;
procedure SaveImportEarly(const rejString : string); forward;

function GetUnitMap(Cursors : TIBSQLBuilder) : IJclStrStrMap; forward;
function RecordsExist(Cursor : TIBSQL ; recordid : integer) : Boolean; forward;
function ValueGet(Cursor : TIBSQL; def : integer) : integer; forward;

procedure ImportSysMgrRPT(const InputString     : Tstrings;
                          const sImportAction   : string;
                          const iImportNo       : integer;
                          const tActivationDate : TDateTime;
                          const sRecordType     : string;
                          var Cursors : TIBSQLBuilder); forward;
procedure ImportSysMgrPCMAP(const InputString     : Tstrings;
                            const sImportAction   : string;
                            const iImportNo       : integer;
                            const tActivationDate : TDateTime;
                            const sRecordType     : string;
                            var Cursors : TIBSQLBuilder); forward;

function DeptListSorter(Item1, Item2: Pointer): Integer;
begin
  Result := pIntCurrRec(Item1).i - pIntCurrRec(Item2).i;
end;

function DeptSumSearch(inlist : TList; findme : integer) : Integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to inlist.Count - 1 do
  begin
    if pIntCurrRec(inlist.Items[i]).i = findme then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure SumDept(const AList : Tlist; const dept : integer; const value : currency);
var
  iloc : integer;
  currec : pIntCurrRec;
begin
  iloc := DeptSumSearch(AList, dept);
  if iloc < 0 then
  begin
    new(currec);
    currec.i := dept;
    currec.c := value;
    AList.Add(currec);
    AList.Sort(DeptListSorter);
  end
  else
    pIntCurrRec(Alist.Items[iloc]).c := pIntCurrRec(Alist.Items[iloc]).c + value;
end;

{-----------------------------------------------------------------------------
  Name:      ImportSysMgrPLU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ImportSysMgrPLU();
var
  Err : Boolean;
begin
  bLogFileInitialized := false;
  bErrorLogInitialized := false;
  sImportFileHeader := ' ********** Import Started ' + FormatDateTime('yyyy-mm-dd hh:mm:ss ', Now() ) + '  **********';
  sImportLogName := ExtractFileDir(Application.ExeName) + '\ImportChg.log';
  sImportErrLogName := ExtractFileDir(Application.ExeName) + '\ImportErr.log';

  {$IFDEF FALSE}
   fmPOSMsg.ShowMsg('Posting prior import','');
   if (not POSDataMod.IBTransaction.InTransaction) then
     POSDataMod.IBTransaction.StartTransaction;
   with POSDataMod.IBTempQuery do
   begin
     try
       Close();
       SQL.Clear();
       SQL.Add('Update PLUImport set Posted=1');
       ExecSQL;
       if (POSDataMod.IBTransaction.InTransaction) then
         POSDataMod.IBTransaction.Commit;
     except
       on E : Exception do
       begin
         if POSDataMod.IBTransaction.InTransaction then
           POSDataMod.IBTransaction.Rollback;
         LogImportMessage('Unable to post prior import attempt: ' + e.message, true, true);
         exit;
       end;
     end;
   end;
  {$ENDIF FALSE}
  Err := False;
  try
    fmPOSMsg.ShowMsg('Checking for Import','Files');
    LogImportMessage('Checking for Import Files', true, true);
    if FileExists('\Latitude\Update\LatitudeImp.try') then
    begin
      RenameFile('\Latitude\Update\LatitudeImp.try', '\Latitude\Update\LatitudeImp.txt');
      if not ProcessImportFile('\Latitude\Update\LatitudeImp.txt') then
        Err := True;
    end;
    if not ProcessImportFile('\Latitude\Update\LatitudePLU.txt') then
      Err := True;
    if not ProcessImportFile('\Latitude\Update\LatitudeVDS.txt') then
      Err := True;
    if Err then
      fmPOS.POSError('Import Error:  Call Support');
  finally
    fmPOSMsg.Close;
    LogImportMessage('', true, False);  // flush log buffer
  end;
                   
end;  //procedure ImportSysMgrPLU


procedure ParseImportAction ( const InString : Tstrings; const field : integer; var res : String) ;
var
  sTmp : String;
begin
  try
    sTmp := UpperCase(InString[FLD_IMPORT_ACTION-1]);
    res := sTmp;
    if ((sTmp <> IMPORT_ACTION_DISCOUNT_DELETE) and
          (sTmp <> IMPORT_ACTION_DISCOUNT_UPDATE) and
          {$IFDEF FF_PROMO}
          (sTmp <> IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE) and
          (sTmp <> IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE) and
          {$ENDIF}
          (sTmp <> IMPORT_ACTION_DEPT_MAP) and
          (sTmp <> IMPORT_ACTION_DEPT_DELETE) and
          (sTmp <> IMPORT_ACTION_DEPT_UPDATE) and
          (sTmp <> IMPORT_ACTION_VOLUME_DISC_DELETE) and
          (sTmp <> IMPORT_ACTION_VOLUME_DISC_UPDATE) and
          (sTmp <> IMPORT_ACTION_PLU_DELETE     ) and
          (sTmp <> IMPORT_ACTION_PLU_UPDATE     ) and
          (sTmp <> IMPORT_ACTION_RPT_DELETE    ) and
          (sTmp <> IMPORT_ACTION_RPT_UPDATE    ) and
          (sTmp <> IMPORT_ACTION_PCMAP_DELETE    ) and
          (sTmp <> IMPORT_ACTION_PCMAP_UPDATE    ) 
        ) then
      raise EImportParse.Create('Invalid action code from import file: ' + sTmp)
  except
    raise EImportParse.Create('cannot parse action code in field ' + inttostr(field) + ' "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : Tstrings; const field : integer; fn : string; def : TDateTime; var res : TDateTime); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToDateTime(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse date/time in field "' + fn +  '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : TStrings; const field : integer; fn : string; var res : String); overload;
begin
  try
    res := InString[field-1];
  except
    raise EImportParse.Create('cannot parse string in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : Tstrings; const field : integer; fn : string; def : Integer; var res : Integer); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToInt(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse Integer in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : TStrings; const field : integer; fn : string; def : shortint; var res : shortint); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToInt(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse ShortInt in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : TStrings; const field : integer; fn : string; def : smallint; var res : smallint); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToInt(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse SmallInt in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : TStrings; const field : integer; fn : string; def : smallint; var res : longword); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToInt64(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse longword in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

procedure ParseImport ( const InString : Tstrings; const field : integer; fn : string; def : currency; var res : currency); overload;
begin
  try
    if (InString[field-1] <> '') then
      res := StrToCurr(InString[field-1])
    else
      res := def;
  except
    raise EImportParse.Create('cannot parse currency in field "' + fn + '" (' + inttostr(field) + ') "' + instring.DelimitedText + '"');
  end;
end;

function SplitString(const instring : string) : TStrings;
var
  i : integer;
  t : string;
  ss : TStrings;
begin
  ss := TStringList.Create();
  t := instring;
  repeat
    i := PosEx('|', t);
    if i > 0 then
    begin
      ss.Add(AnsiLeftStr(t, i-1));
      t := RightStr(t, length(t) - i);
    end
    else
      ss.Add(t);
  until (i = 0) or (ss.Count > 99);
  SplitString := ss;
end;

function ProcessImportFile(const sFName : string) : Boolean;
var
  InFile : textfile;
  InString : TStrings;
  readstring : string;
  j : integer;
  ofm : Byte;
  elog : TStrings;
  eline : integer;
  Cursors : TIBSqlBuilder;
  Goodcnt, BadCnt : cardinal;
  
  iProcessedCount : integer;
  
  iImportPLUImportNo : integer;
  iImportDeptImportNo : integer;
  tImportDate : TDateTime;
  sImportStatus : string;
  sImportImportAction : string;
  tImportActivationDate : TDateTime;
  tImportActivationTime : TDateTime;
  sImportRecType	: string;
  sImportPLUNo : string;
  sImportUPC : string;
  sImportName : string;
  iImportDeptNo : integer;
  cImportPrice : currency;
  iImportSplitQty : integer;
  cImportSplitPrice : currency;
  iImportDisc : smallint;
  iImportFS : shortint;
  iImportWIC : shortint;
  iImportTaxNo : shortint;
  iImportModifierGroup : integer;
  iImportModifierNo : integer;
  sImportModifierName : string;
  cImportLinkedPLU : currency;
  iImportProdGrpNo : integer;
  cImportItemNo : currency;
  iImportVendorNo : integer;
  sImportVendorName : string;
  sImportPackSize : string;
  cImportRetailPrice : currency;
  cImportBreakdownLink : currency;
  iImportBreakdownItemCount : integer;
  iImportItemIsSold : shortint;
  iImportItemIsPurchased : shortint;
  sImportUnitName : string;
  iImportGroupNo : integer;
  cImportHALO : currency;
  cImportLALO : currency;
  iImportRestrictionCode : integer;
  iImportSubtracting : integer;
  iImportMAXCount : integer;
  iImportItemActivation : integer;
  iImportItemSwipe : integer;
  lwMRC : longword;


begin
  Result := True;
  Include(JclStackTrackingOptions, stRawMode);
  Include(JclStackTrackingOptions, stStaticModuleList);
  JclStartExceptionTracking;
  
  if not FileExists(sFName) then
  begin
    LogImportMessage('Import file not found: ' + sFName, true, false);
    exit;
  end;
  
  Cursors := POSDataMod.CursorBuild();  // comes with it's own brand new IBTransaction
  Cursors.Transaction.Name := 'SysMgrImport_ProcessImportFile_Cursors_Transaction';
  iImportPLUImportNo := -1;
  iProcessedCount := 0;
  // big try.  wrap everything in case something goes HORRIBLY wrong.
  try
    Goodcnt := 0;
    BadCnt := 0;
    Cursors.Transaction.StartTransaction();
    Cursors.AddCursor('DPT-Import','INSERT INTO DeptImport( DeptImportNo, ImportDate, Posted, PostDate, Status, ImportAction,' +
                                     'Activationdate, ActivationTime, RecType, DeptNo, Name, GrpNo, ' +
                                     'Disc, HALO, LALO, RestrictionCode, Subtracting, TaxNo, FS, WIC, MAXCount)' +
                                     'Values ( :pDeptImportNo, :pImportDate, :pPosted, :pPostDate, :pStatus, :pImportAction, ' +
                                     ':pActivationdate, :pActivationTime, :pRecType, :pDeptNo, :pName, :pGrpNo, ' +
                                     ':pDisc, :pHALO, :pLALO, :pRestrictionCode, :pSubtracting, :pTaxNo, :pFS, :pWIC, :pMaxCount)');
    Cursors.AddCursor('PLU-Import','INSERT INTO PluImport( PLUImportNo, ImportDate, Posted, PostDate, Status, ImportAction, '+
                                    'Activationdate, ActivationTime, RecType, PLUNumber, UPCNumber, Name, '+
                                    'DeptNo, UnitPrice, SplitQty, SplitPrice, Disc, FS, WIC, TaxNo, ModifierGroup, '+
                                    'ModifierNo, ModifierName, LinkedPLU, VendorNo, ProductGroup, '+
                                    'ItemNo, VendorName, PackSize, RetailPrice, '+
                                    'BreakdownLink, BreakdownItemCount, ItemIsSold, ItemIsPurchased, UnitName, '+
                                    'ItemNeedsActivation, ItemNeedsSwipe, MediaRestrictionCode)'+
                                    'Values ( :pPLUImportNo, :pImportDate, :pPosted, :pPostDate, :pStatus, :pImportAction, '+
                                    ':pActivationdate, :pActivationTime, :pRecType, :pPLUNumber, :pUPCNumber, :pName, '+
                                    ':pDeptNo, :pUnitPrice, :pSplitQty, :pSplitPrice, :pDisc, :pFS, :pWIC, :pTaxNo, :pModifierGroup, '+
                                    ':pModifierNo, :pModifierName, :pLinkedPLU, :pVendorNo, :pProductGroup, '+
                                    ':pItemNo, :pVendorName, :pPackSize, :pRetailPrice, '+
                                    ':pBreakdownLink, :pBreakdownItemCount, :pItemIsSold, :pItemIsPurchased, :pUnitName, '+
                                    ':pItemNeedsActivation, :pItemNeedsSwipe, :pMediaRestrictionCode)');
    Cursors.AddCursor('DPT-MaxImpNo','select max(DeptImportNo) as Result from DeptImport');
    Cursors.AddCursor('PLU-MaxImpNo','select max(PLUImportNo) as Result from PLUImport');
    
    LogImportMessage('Import file found: ' + sFName, true, false);
    AssignFile(InFile, sFName);
    ofm := FileMode;
    reset(InFile);
    FileMode := ofm;
    fmPOSMsg.TopMsg.Caption := 'Importing PLU/UPCs';
    iImportPLUImportNo := ValueGet(Cursors['PLU-MaxImpNo'],0);
    iImportDeptImportNo := ValueGet(Cursors['DPT-MaxImpNo'],0);
    
    LogImportMessage('MAX  PLUImportNo = ' + IntToStr(iImportPLUImportNo), true, false);
    LogImportMessage('MAX DeptImportNo = ' + IntToStr(iImportDeptImportNo), true, false);
    if (iImportPLUImportNo < iImportDeptImportNo) then
      iImportPLUImportNo := iImportDeptImportNo;
    if iImportPLUImportNo < 1 then
      iImportPLUImportNo := 1;
    
    while not System.Eof(InFile) do
    begin
      readln(InFile, readstring);
      InString := splitstring(readstring);
      Inc(iImportPLUImportNo);
      LogImportMessage('#: ' + IntToStr(iImportPLUImportNo) + ' - Input record read: ' + readstring, true, false);
      tImportDate := Now();
      sImportStatus := '';
      try  // try for each record
        
        ParseImportAction(InString, FLD_IMPORT_ACTION, sImportImportAction);
        ParseImport(InString, FLD_IMPORT_ACTIVATE_DATE, 'Activation Date', tImportDate, tImportActivationDate);
        ParseImport(InString, FLD_IMPORT_ACTIVATE_TIME, 'Activation Time', 0, tImportActivationTime);
        ParseImport(InString, FLD_IMPORT_RECORD_TYPE, 'Record Type', sImportRecType);

        if (tImportActivationTime + tImportActivationDate) > Now() then
          raise EImportTooEarly.CreateFmt('Import attempted %f hours too early', [hourspan(Now(),tImportActivationTime + tImportActivationDate)]);

        if (sImportImportAction = IMPORT_ACTION_DEPT_MAP) then
          ImportSysMgrDeptMap(InString, sImportImportAction,
                              iImportPLUImportNo, tImportActivationDate,
                              sImportRecType, DeptMapList)
            {$IFDEF FF_FALSE}
        else if ((sImportImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE) or
                   (sImportImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE)) then
          ImportSysMgrFuelFirstPromo(InString, sImportImportAction,
                                     iImportPLUImportNo, tImportActivationDate,
                                     sImportRecType, Cursors)
            {$ENDIF}
        else if ((sImportImportAction = IMPORT_ACTION_RPT_DELETE) or
                  (sImportImportAction = IMPORT_ACTION_RPT_UPDATE)) then
          ImportSysMgrRPT(InString, sImportImportAction,
                          iImportPLUImportNo, tImportActivationDate,
                          sImportRecType, Cursors)
        else if ((sImportImportAction = IMPORT_ACTION_PCMAP_DELETE) or
                  (sImportImportAction = IMPORT_ACTION_PCMAP_UPDATE)) then
          ImportSysMgrPCMAP(InString, sImportImportAction,
                              iImportPLUImportNo, tImportActivationDate,
                              sImportRecType, Cursors)
        else
        begin
          // not deptmap or ffpromo
          ParseImport (InString, FLD_IMPORT_PLU_NUMBER, 'PLU #', sImportPLUNo);
          ParseImport (InString, FLD_IMPORT_UPC, 'UPC', sImportUPC);
          {$IFDEF INCLUDE_UPC_CHECK_DIGIT}
          if ((sImportUPC <> '')
              and (sImportImportAction <> IMPORT_ACTION_DISCOUNT_DELETE)
              and (sImportImportAction <> IMPORT_ACTION_VOLUME_DISC_DELETE)
              and (sImportImportAction <> IMPORT_ACTION_PLU_DELETE) ) then
            if (sImportUPC = fmPOS.ValidateUPCCheckDigit(sImportUPC, sImportUPC)) then
              raise EImportParse.Create('Invalid check digit on UPC: ' + sImportUPC);
          {$ENDIF}
          ParseImport (InString, FLD_IMPORT_NAME, 'name', sImportName);
          ParseImport (InString, FLD_IMPORT_DEPARTMENT_NUMBER, 'dept. no.', 0, iImportDeptNo);
          ParseImport (InString, FLD_IMPORT_PRICE, 'price', 0.0, cImportPrice);
          ParseImport (InString, FLD_IMPORT_SPLIT_QUANTITY, 'split qty.', 0, iImportSplitQty);
          ParseImport (InString, FLD_IMPORT_SPLIT_PRICE, 'split price', 0, cImportSplitPrice);
          ParseImport (InString, FLD_IMPORT_DISCOUNT, 'discount', 0, iImportDisc);
          ParseImport (InString, FLD_IMPORT_FOOD_STAMPABLE, 'FS', 0, iImportFS);
          ParseImport (InString, FLD_IMPORT_WIC, 'WIC', 0, iImportWIC);
          ParseImport (InString, FLD_IMPORT_TAX_NUMBER, 'tax no', 0, iImportTaxNo);
          
          if ((sImportImportAction = IMPORT_ACTION_DEPT_DELETE) or
                (sImportImportAction = IMPORT_ACTION_DEPT_UPDATE)) then
          begin
            // parse out Dept fields
            ParseImport (InString, FLD_IMPORT_GROUP_NUMBER, 'group number', 0, iImportGroupNo);
            ParseImport (InString, FLD_IMPORT_HALO, 'HALO', 0, cImportHALO);
            ParseImport (InString, FLD_IMPORT_LALO, 'LALO', 0, cImportLALO);
            ParseImport (InString, FLD_IMPORT_RESTRICTION_CODE, 'Restriction Code', 0, iImportRestrictionCode);
            ParseImport (InString, FLD_IMPORT_SUBTRACTING, 'Subtracting flag', 0, iImportSubtracting);
            ParseImport (InString, FLD_IMPORT_MAX_COUNT, 'Dept. MAX Count', 0, iImportMAXCount);
          end
          else if ((sImportImportAction = IMPORT_ACTION_PLU_DELETE) or
                   (sImportImportAction = IMPORT_ACTION_PLU_UPDATE)) then
          begin
            // parse out PLU fields
            ParseImport (InString, FLD_IMPORT_MODIFIER_GROUP, 'Modifier Group', 0, iImportModifierGroup);
            ParseImport (InString, FLD_IMPORT_MODIFIER_NUMBER, 'Modifier number', 0, iImportModifierNo);
            ParseImport (InString, FLD_IMPORT_MODIFIER_NAME, 'Modifier name', sImportModifierName);
            ParseImport (InString, FLD_IMPORT_LINKED_PLU, 'linked plu', 0.0, cImportLinkedPLU);
            ParseImport (InString, FLD_IMPORT_PRODUCT_GROUP_NUMBER, 'prod. grp. no.', 0, iImportProdGrpNo);
            ParseImport (InString, FLD_IMPORT_ITEM_NUMBER, 'item no', 0.0, cImportItemNo);
            ParseImport (InString, FLD_IMPORT_VENDOR_NUMBER, 'vendor no', 0, iImportVendorNo);
            ParseImport (InString, FLD_IMPORT_VENDOR_NAME, 'vendor name', sImportVendorName);
            ParseImport (InString, FLD_IMPORT_PACK_SIZE, 'pack size', sImportPackSize);
            ParseImport (InString, FLD_IMPORT_RETAIL_PRICE, 'retail price', 0.0, cImportRetailPrice);
            ParseImport (InString, FLD_IMPORT_BREAKDOWN_LINK, 'breakdown link', 0.0, cImportBreakdownLink);
            ParseImport (InString, FLD_IMPORT_BREAKDOWN_ITEM_COUNT, 'breakdown item count', 0, iImportBreakdownItemCount);
            ParseImport (InString, FLD_IMPORT_ITEM_IS_SOLD, 'item sold flag', 0, iImportItemIsSold);
            ParseImport (InString, FLD_IMPORT_ITEM_IS_PURCHASED, 'item purchased flag', 0, iImportItemIsPurchased);
            ParseImport (InString, FLD_IMPORT_UNIT_NAME, 'unit name', sImportUnitName);
            ParseImport (InString, FLD_IMPORT_ITEM_ACTIVATION, 'item needs activation flag', 0, iImportItemActivation);
            ParseImport (InString, FLD_IMPORT_ITEM_SWIPE, 'item needs swipe flag', 0, iImportItemSwipe);
            ParseImport (InString, FLD_IMPORT_MRC, 'media restriction code', 0, lwMRC);
          end
          else if ((sImportImportAction = IMPORT_ACTION_VOLUME_DISC_DELETE) or
                   (sImportImportAction = IMPORT_ACTION_VOLUME_DISC_UPDATE)) then
          begin
            iImportModifierGroup := 0;
            iImportModifierNo := 0;
            ParseImport (InString, FLD_IMPORT_MODIFIER_NAME, 'Modifier name', sImportModifierName);
            cImportLinkedPLU := 0;
            iImportVendorNo := 0;
            sImportVendorName := '';
            sImportPackSize := '';
            cImportRetailPrice := 0;
            cImportBreakdownLink := 0;
            iImportBreakdownItemCount := 0;
            iImportItemIsSold := 0;
            iImportItemIsPurchased := 0;
            sImportUnitName := '';
            iImportItemActivation := 0;
            iImportItemSwipe := 0;
            lwMRC := 0;
          end;
          
          if ((sImportImportAction = IMPORT_ACTION_DEPT_DELETE) or
                (sImportImportAction = IMPORT_ACTION_DEPT_UPDATE)) then
          begin
            with Cursors['DPT-Import'] do
            begin
              ParamByName('pDeptImportNo').AsInteger     := iImportPLUImportNo;
              ParamByName('pImportDate').AsDateTime      := Now();
              ParamByName('pPosted').AsInteger           := 0;
              ParamByName('pPostDate').AsDateTime        := 0;
              ParamByName('pStatus').AsString            := '';
              ParamByName('pImportAction').AsString      := sImportImportAction;
              ParamByName('pActivationDate').AsDateTime  := tImportActivationDate;
              ParamByName('pActivationTime').AsDateTime  := tImportActivationTime;
              ParamByName('pRecType').AsString           := sImportRecType;
              ParamByName('pDeptNo').AsInteger           := iImportDeptNo;
              ParamByName('pName').AsString              := sImportName;
              ParamByName('pGrpNo').AsInteger            := iImportGroupNo;
              ParamByName('pDisc').AsInteger             := iImportDisc;
              ParamByName('pHALO').AsCurrency            := cImportHALO;
              ParamByName('pLALO').AsCurrency            := cImportLALO;
              ParamByName('pRestrictionCode').AsInteger  := iImportRestrictionCode;
              ParamByName('pSubtracting').AsInteger      := iImportSubtracting;
              ParamByName('pTaxNo').AsInteger            := iImportTaxNo;
              ParamByName('pFS').AsInteger               := iImportFS;
              ParamByName('pWIC').AsInteger              := iImportWIC;
              ParamByName('pMAXCount').AsInteger         := iImportMAXCOUNT;
              ExecQuery();
            end;
          end
          else
          begin
            with Cursors['PLU-Import'] do
            begin
              ParamByName('pPLUImportNo').AsInteger      := iImportPLUImportNo;
              ParamByName('pImportDate').AsDateTime      := Now();
              ParamByName('pPosted').AsInteger           := 0;
              ParamByName('pPostDate').AsDateTime        := 0;
              ParamByName('pStatus').AsString            := '';
              ParamByName('pImportAction').AsString      := sImportImportAction;
              ParamByName('pActivationDate').AsDateTime  := tImportActivationDate;
              ParamByName('pActivationTime').AsDateTime  := tImportActivationTime;
              ParamByName('pRecType').AsString           := sImportRecType;
              ParamByName('pPLUNumber').AsString         := sImportPLUNo;
              ParamByName('pUPCNumber').AsString         := sImportUPC;
              ParamByName('pName').AsString              := sImportName;
              ParamByName('pDeptNo').AsInteger           := iImportDeptNo;
              ParamByName('pUnitPrice').AsCurrency       := cImportPrice;
              ParamByName('pSplitQty').AsInteger         := iImportSplitQty;
              ParamByName('pSplitPrice').AsCurrency      := cImportSplitPrice;
              ParamByName('pDisc').AsInteger             := iImportDisc;
              ParamByName('pFS').AsInteger               := iImportFS;
              ParamByName('pWIC').AsInteger              := iImportWIC;
              ParamByName('pTaxNo').AsInteger            := iImportTaxNo;
              ParamByName('pModifierGroup').AsCurrency   := iImportModifierGroup;
              ParamByName('pModifierNo').AsInteger       := iImportModifierNo;
              ParamByName('pModifierName').AsString      := sImportModifierName;
              ParamByName('pLinkedPLU').AsCurrency       := cImportLinkedPLU;
              ParamByName('pVendorNo').AsInteger         := iImportVendorNo;
              ParamByName('pProductGroup').AsInteger     := iImportProdGrpNo;
              ParamByName('pItemNo').AsCurrency          := cImportItemNo;
              ParamByName('pVendorName').AsString        := sImportVendorName;
              ParamByName('pPackSize').AsString          := sImportPackSize;
              ParamByName('pRetailPrice').AsCurrency     := cImportRetailPrice;
              ParamByName('pBreakdownLink').AsCurrency   := cImportBreakdownLink;
              ParamByName('pBreakdownItemCount').AsInteger := iImportBreakdownItemCount;
              ParamByName('pItemIsSold').AsInteger       := iImportItemIsSold;
              ParamByName('pItemIsPurchased').AsInteger  := iImportItemIsPurchased;
              ParamByName('pUnitName').AsString          := sImportUnitName;
              ParamByName('pItemNeedsActivation').AsInteger := iImportItemActivation;
              ParamByName('pItemNeedsSwipe').AsInteger   := iImportItemSwipe;
              ParamByName('pMediaRestrictionCode').AsInt64 := lwMRC;
              ExecQuery();
            end;
          end; // PLU insert
        end; // not deptmap or ffpromo
        Inc(Goodcnt);
      except
        on E : EImportParse do
        begin
          Inc(BadCnt);
          Result := False;
          SaveImportReject(readstring);
          InString.Free();
          LogImportMessage('Import #: ' + IntToStr(iImportPLUImportNo) + ' - Failed (skipping record): ' + e.message, true, true);
        end;
        on E : EImportTooEarly do
        begin
          SaveImportEarly(readstring);
          InString.Free();
          LogImportMessage('Import #: ' + IntToStr(iImportPLUImportNo) + ' - rejecting for later import: ' + e.message, true, true);
        end;
        on E : Exception do
        begin
          InString.Free();
          raise;
        end;
      end;
      //end;
      inc(iProcessedCount);
      if (iProcessedCount mod 10) = 0 then
      begin
        fmPOSMsg.BottomMsg.Caption := 'Accepted: ' + inttostr(Goodcnt) + '   Rejected: '+ inttostr(BadCnt);
        fmPOSMsg.Refresh;
        Application.ProcessMessages;
      end;
    end;  // while not System.Eof
    Cursors.Transaction.Commit();
    CloseFile(InFile);
    DeleteFile(sFName);

    {$B-}
    // Verify that any specified department mappings is valid.
    if ((DeptMapList <> nil) and not ValidateDeptMap(DeptMapList)) then
    begin
      Result := False;
      LogImportMessage('Department mapping not valid:', true, true);
      for j := 0 to DeptMapList.Count - 1 do
      begin
        try
          Dispose(DeptMapList.Items[j])
        except
        end;
      end;
      DeptMapList.Free();
    end;  // if ((not bValidDeptMap) and (DeptMapList <> nil))

  except
    on E : Exception do
    begin
      Result := False;
      if Cursors.Transaction.InTransaction then
        Cursors.Transaction.Rollback;
      LogImportMessage('Import #: ' + IntToStr(iImportPLUImportNo) + ' - Failed: ' + e.message, true, true);
      elog := TStringList.Create;
      elog.Add( E.Message);
      JclLastExceptStackListToStrings(elog, False, True, True, False);
      for eline := 0 to elog.Count-1 do
        LogImportMessage('Import #: ' + IntToStr(iImportPLUIMportNo) + ' | ' + elog.Strings[eline], false, true);
    end;
  end;  // try except
  Cursors.Free;
  JclStopExceptionTracking;

end;  //procedure ProcessImportFile

procedure ImportSysMgrDeptMap(const InputString     : Tstrings;
                              const sImportAction   : string;
                              const iImportNo       : integer;
                              const tActivationDate : TDateTime;
                              const sRecordType     : string;
                              var DML : TList);
var
  iImportDeptMapFrom : integer;
  iImportDeptMapTo : integer;
  qIntMap : pIntMap;
  j : integer;
begin
  ParseImport(InputString, FLD_IMPORT_DEPT_MAP_FROM, 'Dept Map From', 0, iImportDeptMapFrom);
  ParseImport(InputString, FLD_IMPORT_DEPT_MAP_TO, 'Dept Map To',  0, iImportDeptMapTo);
  // Setup entry in list to change "from" dept. number to "to" dept. number
  if (iImportDeptMapFrom = iImportDeptMapTo) then
  begin
    // Non-fatal (mapping a department number to itself)
    LogImportMessage('#: ' + IntToStr(iImportNo) + ' - Ignore identity mapping for dept: ' + IntToStr(iImportDeptMapTo), true, false);
    exit;
  end
  else if ((iImportDeptMapFrom <= 0) or (iImportDeptMapFrom <= 0)) then
    raise Exception.Create('Invalid mapping for dept: ' + IntToStr(iImportDeptMapFrom) + ' -> ' + IntToStr(iImportDeptMapTo));

  // Verify that a department is not being mapped to two different department numbers.
  if (DML <> nil) then
  begin
    for j := 0 to DML.Count - 1 do
    begin
      qIntMap := DML.Items[j];
      if (qIntMap^.iFrom = iImportDeptMapFrom) then  // Potential problem if a mapping from the same dept. already specified.
      begin
        if (qIntMap^.iTo = iImportDeptMapTo) then
        begin
          LogImportMessage('#: ' + IntToStr(iImportNo) + ' - Ignore duplicate mapping for dept: ' + IntToStr(iImportDeptMapFrom) + ' -> ' + IntToStr(iImportDeptMapTo), true, False);
          exit;  // non-fatal (just a duplicate entry)
        end
        else // Trying to map the same dept. number to multiple departments.
          raise Exception.Create(' - Invalid multiple maps from dept: ' + IntToStr(iImportDeptMapFrom) + ' -> ' + IntToStr(iImportDeptMapTo));
      end;
    end;
  end;  // if ((bValidDeptMap) and (DML <> nil))
        // If individual entry checks out, then add it (one final check will be made against the final map).
  
  if (DML = nil) then
    DML := TList.Create();
  New(qIntMap);
  qIntMap^.iFrom := iImportDeptMapFrom;
  qIntMap^.iTo   := iImportDeptMapTo;
  DML.Add(qIntMap)

end;


function ValidateDeptMap(DeptMapList : TList) : boolean;
{
Validate the remapping of department numbers.
}
var
  qIntMap : pIntMap;
  qIntMap2 : pIntMap;
  j : integer;
  j2 : integer;
  bFound : boolean;
  bNewDeptNo : boolean;
  ReturnVal : boolean;
begin
  ReturnVal := true;  // Initial assumption
  if (DeptMapList <> nil) then
  begin
    for j := 0 to DeptMapList.Count - 1 do
    begin
      qIntMap := DeptMapList.Items[j];
      // Check to see if the dept. being mapped to has another mapping specified (from)
      // (if so, then there is no danger of this map entry having an issue with overwritting
      // an existing department)
      bFound := False;  // Initial assumption
      for j2 := 0 to DeptMapList.Count - 1 do
      begin
        qIntMap2 := DeptMapList.Items[j2];
        if (qIntMap2^.iFrom = qIntMap^.iTo) then
        begin
          bFound := True;
          break;
        end;
      end;  //for j2 := 0 to DeptMapList.Count - 1
      // If the dept. being mapped to is not also being mapped from, then this needs to be a new dept.
      if (not bFound) then
      begin
        if (not POSDataMod.IBTransaction.InTransaction) then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBTempQuery do
        begin
          Close();
          SQL.Clear();
          SQL.Add('select DeptNo from Dept where DeptNo = :pDeptNo');
          ParamByName('pDeptNo').AsInteger := qIntMap^.iTo;
          Open();
          bNewDeptNo := EOF;
          Close();
        end;  // with
        if (POSDataMod.IBTransaction.InTransaction) then
          POSDataMod.IBTransaction.Commit;
        if (not bNewDeptNo) then
        begin
          ReturnVal := False;
          LogImportMessage('Invalid mapping to existing department: ' + IntToStr(qIntMap^.iTo), true, true);
        end;
      end;  // if (not bFound) then
    end;  // for j := 0 to DeptMapList.Count -1
  end;  // if (DeptMapList <> nil)
  ValidateDeptMap := ReturnVal;
end;  // function ValidateDeptMap



procedure MapDeptNumbers();
{
Map the dept. numbers according to the mappings specified by DeptMapList.
Map list has already been validated.
}
var
  bFound : boolean;
  bNewDeptNo : boolean;
  qIntMap : pIntMap;
  qIntMap2 : pIntMap;
//  TableName : string;
  TempDeptNo : integer;
  UpdatedFromDeptNo : integer;
  LastFromDeptNo : integer;
  j : integer;
  j2 : integer;
begin
  if (DeptMapList <> nil) then
  begin
    // Process the entries of the map list until it is empty, selecting entries in an order to prevent
    // two departments from  being temporarly mapped to the same department numbers.
    {$IFDEF DEV_TEST}
    fmPOSMsg.Close;
    {$ENDIF}
    TempDeptNo := 0;
    UpdatedFromDeptNo := 0;
    qIntMap := nil;
    while (DeptMapList.Count > 0) do
    begin
      // The previously updated "from" department number no longer exists in the database,
      // so if there is an entry mapping "to" that number, it should be safe to handle that entry next.
      if (UpdatedFromDeptNo > 0) then
      begin
        qIntMap := nil;  // Initial assumption (if not located below, then following will search for another entry).
        for j2 := 0 to DeptMapList.Count - 1 do
        begin
          qIntMap2 := DeptMapList.Items[j2];
          if (qIntMap2^.iTo = UpdatedFromDeptNo) then
          begin
            qIntMap := qIntMap2;  // map this entry next.
            DeptMapList.Remove(qIntMap2);
            DeptMapList.Pack();
            break;
          end;
        end;  // for j2 := 0 to DeptMapList.Count - 1
      end;  //if (UpdatedFromDeptNo > 0)
      // If above search for the next dept. mapping canidate is unsuccessful, then
      // look for an entry mapping to a new department number.
      if (qIntMap = nil) then
      begin
        bFound := False;  // Initial assumption
        for j := 0 to DeptMapList.Count - 1 do
        begin
          qIntMap := DeptMapList.Items[j];
          if (not POSDataMod.IBTransaction.InTransaction) then
            POSDataMod.IBTransaction.StartTransaction;
          with POSDataMod.IBTempQuery do
          begin
            Close();
            SQL.Clear();
            SQL.Add('select DeptNo from Dept where DeptNo = :pDeptNo');
            ParamByName('pDeptNo').AsInteger := qIntMap^.iTo;
            Open();
            bNewDeptNo := EOF;
            Close();
          end;  // with
          if (POSDataMod.IBTransaction.InTransaction) then
            POSDataMod.IBTransaction.Commit;
          if (bNewDeptNo) then
          begin
            bFound := True;
            DeptMapList.Remove(qIntMap);
            DeptMapList.Pack();
            break;              // Found an entry mapping to a new (i.e., unused) departemnt number.
          end;  // if (bNewDeptNo)
        end;  // for j := 0 to DeptMapList.Count - 1
        // If next mapping canidate still not located, then create a dummy map entry to a new dept.
        // (i.e., change the last map entry from A -> B to New -> B and add a new entry A -> new.)
        if (not bFound) then
        begin
          // Determine a non-existing department number.
          if (TempDeptNo = 0) then
          begin
            if (not POSDataMod.IBTransaction.InTransaction) then
              POSDataMod.IBTransaction.StartTransaction;
            with POSDataMod.IBTempQuery do
            begin
              Close();
              SQL.Clear();
              SQL.Add('select Max(DeptNo) as MAXDeptNo from Dept');
              Open();
              TempDeptNo := FieldByName('MAXDeptNo').AsInteger + 1;
              Close();
            end;  // with
            if (POSDataMod.IBTransaction.InTransaction) then
              POSDataMod.IBTransaction.Commit;
          end
          else
          begin
            Inc(TempDeptNo);  // Actually same value could be re-used (just cannot be existing dept. number).
          end;
          LastFromDeptNo := qIntMap^.iFrom;
          qIntMap^.iFrom := TempDeptNo;
          New(qIntMap);
          qIntMap^.iFrom := LastFromDeptNo;
          qIntMap^.iTo := TempDeptNo;
        end;  // if (not bFound)
      end;  // if (qIntMap = nil)
      // Map this entry by updating all references in database from the old to the new department number.
      UpdatedFromDeptNo := qIntMap^.iFrom;
      (*
      if (not POSDataMod.IBTransaction.InTransaction) then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        try
          Close();
          SQL.Clear();
          TableName := 'TouchKybd';
          SQL.Add('Update TouchKybd set KeyVal = :pToDeptNo where KeyVal = :pFromDeptNo and RecType like ''DPT%''');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'Receipt';
          SQL.Add('Update Receipt set SaleNo = :pToDeptNo where SaleNo = :pFromDeptNo and ((LineType = ''DPT'') or (LineType = ''FUL''))');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'SuspendSale';
          SQL.Add('Update SuspendSale set SaleNo = :pToDeptNo where SaleNo = :pFromDeptNo and ((LineType = ''DPT'') or (LineType = ''FUL''))');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'Setup';
          SQL.Add('Update Setup set GiftCardDeptNo = :pToDeptNo where GiftCardDeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'PLUMod';
          SQL.Add('Update PLUMod set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'NFPLU';
          SQL.Add('Update NFPLU set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'Kiosk';
          SQL.Add('Update Kiosk set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'Grade';
          SQL.Add('Update Grade set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'PLU';
          SQL.Add('Update PLU set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'DepShift';
          SQL.Add('Update DepShift set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          Close();
          SQL.Clear();
          TableName := 'Dept';
          SQL.Add('Update Dept set DeptNo = :pToDeptNo where DeptNo = :pFromDeptNo');
          ParamByName('pToDeptNo').AsInteger := qIntMap^.iTo;
          ParamByName('pFromDeptNo').AsInteger := qIntMap^.iFrom;
          ExecSQL;
          if (POSDataMod.IBTransaction.InTransaction) then
          begin
            POSDataMod.IBTransaction.Commit;
            LogImportMessage('Mapped dept. # ' + IntToStr(qIntMap^.iFrom) + ' to #' + IntToStr(qIntMap^.iTo), true, false);
          end;
        except
          on E : Exception do
          begin
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Rollback;
            LogImportMessage('Unable to change dept. # ' + IntToStr(qIntMap^.iFrom) + ' to #' + IntToStr(qIntMap^.iTo) + ' in table ' + TableName + '  :' + e.message, true, true);
          end;
        end;  // try/except
      end;  // with
      if (POSDataMod.IBTransaction.InTransaction) then
        POSDataMod.IBTransaction.Commit;
      *)
            LogImportMessage('[DEBUG]Mapped dept. # ' + IntToStr(qIntMap^.iFrom) + ' to #' + IntToStr(qIntMap^.iTo), true, false);
      Dispose(qIntMap);
    end;  // while (DeptMapList.Count > 0)
  end;  //  if (DeptMapList <> nil)
end;  // procedure MapDeptNumbers



{$IFDEF FF_PROMO}
procedure ImportSysMgrFuelFirstPromo(const InputString     : Tstrings;
                                     const sImportAction   : string;
                                     const iImportNo       : integer;
                                     const tActivationDate : TDateTime;
                                     const sRecordType     : string;
                                     var Cursors           : TIBSqlBuilder
                                    );
var
  sImportCouponCode : string;
  sImportReceiptData : string;
  bNeedInsert : boolean;
  Cursor : TIBSQL;
begin
  ParseImport(InputString, FLD_IMPORT_COUPON_CODE, 'FF Coupon Code', sImportCouponCode);
  ParseImport(InputString, FLD_IMPORT_COUPON_RECEIPT_DATA, 'FF Coupon Receipt Data', sImportReceiptData);
  if (sImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE) then
  begin
    Cursors.AddCursorINE('FFAD-DeAct','update FFAwardDefinition set CouponActive = CouponActive - 2' +
                                       'where CouponCode = :pCouponCode and ' +
                                       'CouponType = :pCouponType and ' +
                                       'CouponActive >= :pCouponActive');
    with Cursors['FFAD-DeAct'] do
    begin
      try
        ParamByName('pCouponCode').AsString        := sImportCouponCode;
        ParamByName('pCouponActive').AsInteger     := 0;
        ParamByName('pCouponType').AsInteger       := COUPON_TYPE_FF_TEMPLATE;
        ExecQuery;
      except
        on E : Exception do
          LogImportMessage('Coupon Code: ' + sImportCouponCode + ' - Failed while updating (for delete) FFAwardDefinition: ' + e.message, true, true);
      end;
    end;  // with
  end  // if (sImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE)
  else if (sImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE) then
    begin
      Cursors.AddCursorINE('FFAD-Exists','select CouponCode from FFAwardDefinition' +
                                          ' where CouponCode = :pCouponCode and CouponType = :pCouponType and CouponActive = :pCouponActive');
      try
        with Cursors['FFAD-Exists'] do
        begin
          ParamByName('pCouponCode').AsString := sImportCouponCode;
          ParamByName('pCouponType').AsInteger := COUPON_TYPE_FF_TEMPLATE;
          ParamByName('pCouponActive').AsInteger := 0;
          ExecQuery();
          bNeedInsert := EOF;
          Close();
        end;
        if (bNeedInsert) then
        begin
          Cursors.AddCursorINE('FFAD-Insert','insert into FFAwardDefinition' +
                                               ' (CouponCode, CouponDate, CouponType, CouponActive, CouponReceiptData)' +
                                               ' values (:pCouponCode, :pCouponDate, :pCouponType, :pCouponActive, :pCouponReceiptData)');
          Cursor := Cursors['FFAD-Insert'];
        end
        else
        begin
          Cursors.AddCursorINE('FFAD-Update','update FFAwardDefinition' +
                                               ' set CouponDate = :pCouponDate, CouponReceiptData = :pCouponReceiptData)' +
                                               ' where CouponCode = :pCouponCode and CouponType = :pCouponType and CouponActive = :pCouponActive');
          Cursor := Cursors['FFAD-Update'];
        end;
        with Cursor do
        begin
          ParamByName('pCouponCode').AsString        := sImportCouponCode;
          ParamByName('pCouponActive').AsInteger     := 0;
          ParamByName('pCouponDate').AsDateTime      := Now();
          ParamByName('pCouponType').AsInteger       := COUPON_TYPE_FF_TEMPLATE;
          ParamByName('pCouponReceiptData').AsString := sImportReceiptData;
          ExecQuery;
        end;
      except
        on E : Exception do
          LogImportMessage('Coupon Code: ' + sImportCouponCode + ' - Failed while updating FFAwardDefinition: ' + e.message, true, true);
      end;
  end;  // else if (sImportAction = IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE)
end;  // procedure ImportSysMgrFuelFirstPromo

procedure ActivateSysMgrFuelFirstPromo();
var
  sImportCouponCode : string;
//  sImportReceiptData : string;
  bRecordExists : boolean;
begin

  // Loop through all imported entries that are not yet active.

  if (not POSDataMod.IBTransaction.InTransaction) then
    POSDataMod.IBTransaction.StartTransaction;
//  with POSDataMod.IBTempQuery do
//  begin
  try
    POSDataMod.IBTempQuery.Close();
    POSDataMod.IBTempQuery.SQL.Clear();
    POSDataMod.IBTempQuery.SQL.Add('select * from FFAwardDefinition');
    POSDataMod.IBTempQuery.SQL.Add(' where CouponType = :pCouponType and CouponActive = :pCouponActive');
    POSDataMod.IBTempQuery.ParamByName('pCouponType').AsInteger := COUPON_TYPE_FF_TEMPLATE;
    POSDataMod.IBTempQuery.ParamByName('pCouponActive').AsInteger := 0;
    POSDataMod.IBTempQuery.Open();
    LogImportMessage('Checking for Fuel First promotion changes.', true, false);
    while (not POSDataMod.IBTempQuery.EOF) do
    begin
      sImportCouponCode := POSDataMod.IBTempQuery.FieldByName('CouponCode').AsString;
      if (not POSDataMod.IBTempTrans2.InTransaction) then
        POSDataMod.IBTempTrans2.StartTransaction;
//      with POSDataMod.IBTempQuery2 do
//      begin

      try

        // Look for a matching active record.

        POSDataMod.IBTempQuery2.Close();
        POSDataMod.IBTempQuery2.SQL.Clear();
        POSDataMod.IBTempQuery2.SQL.Add('select * from FFAwardDefinition');
        POSDataMod.IBTempQuery2.SQL.Add(' where CouponCode = :pCouponCode and CouponType = :pCouponType and CouponActive = :pCouponActive');
        POSDataMod.IBTempQuery2.ParamByName('pCouponCode').AsString := sImportCouponCode;
        POSDataMod.IBTempQuery2.ParamByName('pCouponType').AsInteger := COUPON_TYPE_FF_TEMPLATE;
        POSDataMod.IBTempQuery2.ParamByName('pCouponActive').AsInteger := 1;
        POSDataMod.IBTempQuery2.Open();
        bRecordExists := (POSDataMod.IBTempQuery2.RecordCount > 0);
        POSDataMod.IBTempQuery2.Close();
        POSDataMod.IBTempQuery2.SQL.Clear();
        // If matching active record already exist, then it must be deleted so that
        // the new record can be made active (CouponActive is a primary key field).
        if (bRecordExists) then
        begin
          if (not POSDataMod.IBTempTrans1.InTransaction) then
            POSDataMod.IBTempTrans1.StartTransaction;
          POSDataMod.IBTempQry1.Close();
          POSDataMod.IBTempQry1.SQL.Clear();
          POSDataMod.IBTempQry1.SQL.Add('delete from FFAwardDefinition');
          POSDataMod.IBTempQry1.SQL.Add(' where CouponType = :pCouponType and CouponActive = :pCouponActive');
          POSDataMod.IBTempQry1.ParamByName('pCouponType').AsInteger := COUPON_TYPE_FF_TEMPLATE;
          POSDataMod.IBTempQry1.ParamByName('pCouponActive').AsInteger := 1;
          try
            POSDataMod.IBTempQry1.ExecSQL();
          except
            on E : Exception do
            begin
              if POSDataMod.IBTempTrans1.InTransaction then
                POSDataMod.IBTempTrans1.Rollback;
              LogImportMessage('CouponCode: ' + sImportCouponCode + ' - Failed while deleting FFAwardDefinition: ' + e.message, true, true);
            end;
          end;
          POSDataMod.IBTempQry1.Close();
          if (POSDataMod.IBTempTrans1.InTransaction) then
            POSDataMod.IBTempTrans1.Commit;
        end;

        // Make inactive imported record active.

        POSDataMod.IBTempQuery2.SQL.Add('update FFAwardDefinition set CouponActive = 1');
        POSDataMod.IBTempQuery2.SQL.Add(' where CouponCode = :pCouponCode and CouponType = :pCouponType and CouponActive = :pCouponActive');
        POSDataMod.IBTempQuery2.ParamByName('pCouponCode').AsString := sImportCouponCode;
        POSDataMod.IBTempQuery2.ParamByName('pCouponType').AsInteger := COUPON_TYPE_FF_TEMPLATE;
        POSDataMod.IBTempQuery2.ParamByName('pCouponActive').AsInteger := 0;
        POSDataMod.IBTempQuery2.ExecSQL;
        if (POSDataMod.IBTempTrans2.InTransaction) then
          POSDataMod.IBTempTrans2.Commit;
        LogImportMessage('Activate CouponCode: ' + sImportCouponCode, true, false);
      except
        on E : Exception do
        begin
          if POSDataMod.IBTempTrans2.InTransaction then
            POSDataMod.IBTempTrans2.Rollback;
          LogImportMessage('CouponCode: ' + sImportCouponCode + ' - Failed while updating FFAwardDefinition: ' + e.message, true, true);
        end;
      end;
      POSDataMod.IBTempQuery2.Close();


//      end;  // with
      POSDataMod.IBTempQuery.Next();
    end;  // while (not EOF)
    POSDataMod.IBTempQuery.Close();
  except
    on E : Exception do
    begin
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Rollback;
      LogImportMessage('Failed trying to activate FF promotions: ' + e.message, true, true);
    end;
  end;
  LogImportMessage('', true, false);  // flush log buffer

//  end;  // with
end;  // procedure ActivateSysMgrFuelFirstPromo
{$ENDIF}

procedure ActivatePLUImport();
var
  iErrorCount : integer;
  iProcessedCount : integer;
  iActivatePLUImportNo : integer;
  sActivatePLUImportNo : string;
  sActivateAction : string;
  sActivatePLUNumber : string;
  sActivateUPCNumber : string;
  sActivateName : string;
  Cursors : TIBSqlBuilder;
  UnitMap : IJclStrStrMap;
  elog : TStrings;
  eline : integer;

  bDax : boolean;
  bForceDax : boolean;
  bOldRptToDisk : boolean;
  rpcproxy : string;
  rpcport : integer;
  RpcCaller: TRpcCaller;
  RpcFunction: IRpcFunction;
  RpcArray: IRpcArray;
  RpcResult: IRpcResult;
  i : integer;
  cursum : currency;
  PCR : TStrings;
  DS : TList;
begin
  Include(JclStackTrackingOptions, stRawMode);
  Include(JclStackTrackingOptions, stStaticModuleList);
  JclStartExceptionTracking;

  PCR := nil;
  DS := nil;
  try
    Cursors := POSDataMod.CursorBuild();  // comes with it's own brand new IBTransaction
    Cursors.Transaction.Name := 'SysMgrImport_ActivatePLUImport_Cursors_Transaction';

    bLogFileInitialized := false;
    bErrorLogInitialized := false;
    sImportFileHeader := ' ********** Activate Started ' + FormatDateTime('yyyy-mm-dd  hh:mm:ss', Now() ) + '  **********';
    sImportLogName := ExtractFileDir(Application.ExeName) + '\ImportChg.log';
    sImportErrLogName := ExtractFileDir(Application.ExeName) + '\ImportErr.log';

    fmPOSMsg.TopMsg.Caption := 'Mapping Departments';
    fmPOSMsg.ShowMsg('Mapping Departments','');
    MapDeptNumbers();

    fmPOSMsg.TopMsg.Caption := 'Activating PLU/UPCs';
    fmPOSMsg.ShowMsg('Activating PLU/UPCs','');
    iProcessedCount := 0;

    iErrorCount := 0;
    Cursors.Transaction.StartTransaction;
    Cursors.AddCursor('PLU-ToDo','select * from PluImport where Posted = 0 order by PLUImportNo');
    Cursors.AddCursor('PLU-Post','update PLUImport set Posted = 1, PostDate = :pPostDate where PLUImportNo = :pPLUImportNo');
    Cursors.AddCursor('PLU-UpdateUPC', 'select UPCNumber from PluImport where Posted = 0 and ImportAction = ''PLUUPD''');
    Cursors.AddCursor('PLU-QTY', 'update pluimport set qtyoh = :pQtyOH where Posted = 0 and UPCNumber = :pUPCNumber');
    Cursors.AddCursor('PLU-ClearQty','Update PLUImport set qtyoh = NULL where Posted = 0');

    try
      bForceDax := fmPOS.Config.Bool['DAX_XMLRPC_FORCE'];
    except
      bForceDax := False;
    end;

    rpcport := 7080;
    try
      rpcproxy := fmPOS.Config.Str['DAX_XMLRPC_HOST'];
      rpcport := fmPOS.Config.Int['DAX_XMLRPC_PORT'];
      bDax := Setup.DAXSupport;
    except
      bDax := False;
    end;

    if bDax then
    begin
      fmPOSMsg.ShowMsg('Activating PLU/UPCs','Aquiring QoH from Dax');

      RpcCaller := TRpcCaller.Create;
      RpcCaller.HostName := rpcproxy;
      RpcCaller.HostPort := rpcport;

      RpcFunction := TRpcFunction.Create;
      RpcFunction.ObjectMethod := 'getboh';
      RpcFunction.AddItem(Setup.DAXStoreID);

//In [3]: proxy.getboh('s070.ok7-eleven.com', ['00028200003843','00028200003782'])
//Out[3]: [['00028200003843', 291.0], ['00028200003782', 25.0]]

      LogImportMessage('Getting UPC list to query Dax about', True, False);
      with Cursors['PLU-ClearQty'] do
      begin
        ExecQuery();
        Close();
      end;
      RpcArray := TRpcArray.Create;
      with Cursors['PLU-UpdateUPC'] do
      begin
        ExecQuery();
        while (not EOF) do
        begin
          RpcArray.AddItem(FieldByName('UPCNumber').AsString);
          next;
        end;
        Close();
      end;
      LogImportMessage(Format('Calling RPC with %d items', [RpcArray.Count]), True, False);
      RpcFunction.AddItem(RpcArray);
      RpcResult := RpcCaller.Execute(RpcFunction);
      if RpcResult.IsError then
      begin
        fmPOS.POSError('Error getting quantities from Dax');
        LogImportMessage(Format('Error executing xml-rpc: (%d) %s', [RpcResult.ErrorCode, RpcResult.ErrorMsg]), True, True);
        bDax := False;
      end;
      LogImportMessage('RPC call finished', True, False);
      if RpcResult.IsArray then
      begin
        RpcArray := RpcResult.AsArray;
        for I := 0 to RpcArray.Count - 1 do
        try
          if RpcArray[I].IsArray then
            With Cursors['PLU-QTY'] do
            begin
              ParamByName('pUPCNumber').AsString := RpcArray[I].AsArray.Items[0].AsString;
              ParamByName('pQtyOH').AsCurrency := RpcArray[I].AsArray.Items[1].AsFloat;
              ExecQuery();
              Close();
            end;
        except
          on E: Exception do
          begin
            LogImportMessage('Exception attempting to store QTY: ' + E.Message, True, True);
          end;
        end;
      end;
      LogImportMessage('Done updating QOH locally', True, False);

    end
    else
      if bForceDax then
      begin
        fmPOS.POSError('Dax numbers required for import, but not configured');
        LogImportMessage('Dax not configured completely', True, True);
        exit;
      end;
    if bDax then
    begin
      PCR := TStringList.Create;
      PCR.Add(Format('%6s  %6s %6s   %8s   %8s',['Orig', 'New', 'Net', 'Qty OH', 'Extended']));
      DS := TList.Create;
    end;
    fmPOSMsg.ShowMsg('Activating PLU/UPCs',' ');
    
    with Cursors['PLU-ToDo'] do
    begin
      ExecQuery();
      if (EOF) then
        LogImportMessage('No qualifying imported PLU/discount items to activate.', true, false);
      while (not EOF) do
      begin
        try
          iActivatePLUImportNo := FieldByName('PLUImportNo').AsInteger;
          sActivatePLUImportNo := IntToStr(iActivatePLUImportNo);
          sActivateAction := UpperCase(FieldByName('ImportAction').AsString);
          sActivatePLUNumber := FieldByName('PLUNumber').AsString;
          sActivateUPCNumber := FieldByName('UPCNumber').AsString;
          sActivateName      := FieldByName('Name').AsString;
          LogImportMessage('Import #: ' + sActivatePLUImportNo +
                             ', Action=' + sActivateAction    +
                             ', PLU='  + sActivatePLUNumber +
                             ', UPC='  + sActivateUPCNumber +
                             ', Name=' + sActivateName, true, false);
          if (sActivateAction = IMPORT_ACTION_PLU_UPDATE) then
            ActivatePLUUpdate(Cursors,UnitMap,PCR, DS)
          else if (sActivateAction = IMPORT_ACTION_PLU_DELETE) then
            ActivatePLUDelete(Cursors)
          else if (sActivateAction = IMPORT_ACTION_DISCOUNT_DELETE) then
            ActivateDiscountDelete(Cursors)
          else if (sActivateAction = IMPORT_ACTION_DISCOUNT_UPDATE) then
            ActivateDiscountUpdate(Cursors)
          else if (sActivateAction = IMPORT_ACTION_VOLUME_DISC_DELETE) then
            ActivateVolumeDiscountDelete(Cursors)
          else if (sActivateAction = IMPORT_ACTION_VOLUME_DISC_UPDATE) then
            ActivateVolumeDiscountUpdate(Cursors)
          //else if (sActivateAction = IMPORT_ACTION_FUEL_FIRST_PROMO_DELETE) then
          //  ActivateFuelFirstPromoDelete(Cursors)
          //else if (sActivateAction = IMPORT_ACTION_FUEL_FIRST_PROMO_UPDATE) then
          //  ActivateFuelFirstPromoUpdate(Cursors)
          else
            raise Exception.Create ('Invalid action code from PLUImport: ' + sActivateAction);
          with Cursors['PLU-Post'] do
          begin
            try
              ParamByName('pPLUImportNo').AsInteger := iActivatePLUImportNo;
              ParamByName('pPostDate').AsDateTime := Now();
              LogImportMessage('Posting PLU import record', true, false);
              ExecQuery();
              Close();
              Inc(iProcessedCount);
            except
                on E : Exception do
                  raise Exception.Create('Failed to post PLUImport: ' + E.message);
            end; // try..except
          end; // with
          
        except
          on E : EAccessViolation do
            raise;
          on E : Exception do
          begin
            Inc(iErrorCount);
            LogImportMessage('PLUImportNo: ' + sActivatePLUImportNo + ' - Failed while posting PLUImport: ' + E.message, true, true);
          end;
        end;
        if (iProcessedCount mod 10) = 0 then
        begin
          fmPOSMsg.BottomMsg.Caption := 'Records processed: ' + IntToStr(iProcessedCount);
          fmPOSMsg.Refresh;
          Application.ProcessMessages;
        end;
        Next();
      end;  // while (not EOF)
      Close();
    end;  // with
    Cursors.Transaction.Commit;
    if (iErrorCount <> 0) then
      fmPOS.POSError('PLU Activation Error:  Call Support');

    if (PCR <> nil) and (DS <> nil) then // only true if bDax is True and creation worked
    begin
      PCR.Add('');
      PCR.Add('');
      PCR.Add('Subtotals by Department');
      cursum := 0;
      for i := 0 to DS.Count - 1 do
      begin
        with pIntCurrRec(DS.Items[i])^ do
        begin
          PCR.Add(Format('%04d            %8.2f',[i,c]));
          cursum := cursum + c;
        end;
        Dispose(DS.Items[i]);
      end;

      PCR.Add('-------------------------');
      PCR.Add(Format('Total           %8.2f',[cursum]));
      bOldRptToDisk := fmPos.ReportToDisk;
      fmPos.ReportToDisk := True;
      LogReportMarker('^^^PPC');
      ReportHdr('Price Change', False);
      for i := 0 to PCR.Count - 1 do
        LineOut(PCR.Strings[i]);
      ReportFtr;
      printseq;
      LogReportMarker('^^^END');
      fmPos.ReportToDisk := bOldRptToDisk;
    end;
    PCR.Free;
    DS.Free;
  except
    on E : Exception do
    begin
      LogImportMessage('Activation Failed: ' + e.message, true, true);
      elog := TStringList.Create;
      elog.Add( E.Message);
      JclLastExceptStackListToStrings(elog, False, True, True, False);
      for eline := 0 to elog.Count-1 do
        LogImportMessage('Import Process: | ' + elog.Strings[eline], false, true);
      fmPOS.POSError('PLU Activation Error:  Call Support');
    end;
  end;  // try except
  LogImportMessage('', true, false);  // flush log buffer
  Cursors.Free();
  JclStopExceptionTracking;

end;  // procedure ActivatePLUImport



procedure ActivateDeptImport();
var
  iErrorCount : integer;
  iProcessedCount : integer;
  iActivateDeptImportNo : integer;
  sActivateDeptImportNo : string;
  sActivateAction : string;
  sActivateDeptNo : string;
  sActivateName : string;
  Cursors : TIBSqlBuilder;

begin

  sImportFileHeader := ' ********** Activate Started ' + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now() ) + '  **********';
  sImportLogName := ExtractFileDir(Application.ExeName) + '\ImportChg.log';
  sImportErrLogName := ExtractFileDir(Application.ExeName) + '\ImportErr.log';

  fmPOSMsg.TopMsg.Caption := 'Maping Departments';
  fmPOSMsg.ShowMsg('Maping Departments','');
  MapDeptNumbers();

  fmPOSMsg.TopMsg.Caption := 'Activating Departments';
  fmPOSMsg.ShowMsg('Activating Departments','');
  iProcessedCount := 0;

  iErrorCount := 0;
  if (not POSDataMod.IBInventoryTrans.InTransaction) then
    POSDataMod.IBInventoryTrans.StartTransaction;
  if (not POSDataMod.IBTransaction.InTransaction) then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close();
    SQL.Clear();
    SQL.Add('select * from DeptImport where Posted = 0 order by DeptImportNo');
    Open();
    if (EOF) then
      LogImportMessage('No qualifying imported Departments to activate.', true, false);
    while (not EOF) do
    begin
      iActivateDeptImportNo := FieldByName('DeptImportNo').AsInteger;
      sActivateDeptImportNo := IntToStr(iActivateDeptImportNo);
      sActivateAction := UpperCase(FieldByName('ImportAction').AsString);
      sActivateDeptNo := FieldByName('DeptNo').AsString;
      sActivateName      := FieldByName('Name').AsString;
      LogImportMessage('Import #: ' + sActivateDeptImportNo +
                       ', Action=' + sActivateAction    +
                       ', Dept='  + sActivateDeptNo +
                       ', Name=' + sActivateName, true, false);
      if (sActivateAction = IMPORT_ACTION_DEPT_UPDATE) then
        ActivateDeptUpdate(Cursors)
      else if (sActivateAction = IMPORT_ACTION_DEPT_DELETE) then
        ActivateDeptDelete(Cursors)
      else
      begin
        Inc(iErrorCount);
        LogImportMessage('#' + sActivateDeptImportNo + ':  Invalid action code from DeptImport: ' + sActivateAction, true, true);
      end;
      if (iErrorCount > 0) then
        break;

      // Post import
      with POSDataMod.IBQryInventory do
      begin
        try
          Close();
          SQL.Clear();
          SQL.Add('update DeptImport set Posted = 1, PostDate = :pPostDate where DeptImportNo = :pDeptImportNo');
          ParamByName('pDeptImportNo').AsInteger := iActivateDeptImportNo;
          ParamByName('pPostDate').AsDateTime := Now();
          LogImportMessage('Posting Dept import record', true, false);
          ExecSQL();
          Inc(iProcessedCount);
        except
          on E : Exception do
          begin
            LogImportMessage('DeptImportNo: ' + sActivateDeptImportNo + ' - Failed while posting DeptImport: ' + e.message, true, true);
            break;
          end;
        end;
      end;  // with
      if (iProcessedCount mod 10) = 0 then
      begin
        fmPOSMsg.BottomMsg.Caption := 'Records processed: ' + IntToStr(iProcessedCount);
        fmPOSMsg.Refresh;
        Application.ProcessMessages;
      end;
      Next();
    end;  // while (not EOF)
    Close();
  end;  // with
  if (POSDataMod.IBTransaction.InTransaction) then
    POSDataMod.IBTransaction.Commit;
  if (iErrorCount = 0) then
  begin
    if (POSDataMod.IBInventoryTrans.InTransaction) then
      POSDataMod.IBInventoryTrans.Commit;
  end
  else
  begin
    if (POSDataMod.IBInventoryTrans.InTransaction) then
      POSDataMod.IBInventoryTrans.Rollback;
    fmPOS.POSError('Dept Activation Error:  See ' + sImportErrLogName);
  end;
  LogImportMessage('', true, false);  // flush log buffer

end;  // procedure ActivateDeptImport


// plu plu plu

procedure AddDPTInsertCursor (var Cursors : TIBSQLBuilder);
begin
  Cursors.AddCursor('DPT-Insert', 'insert into Dept (DeptNo, Name, GrpNo, DISC,' +
                                    ' HALO, LALO, RestrictionCode, Subtracting,' +
                                    ' TaxNo, FS, WIC, MaxCount)' +
                                    ' values (:pDeptNo, :pName, :pGrpNo, :pDISC,' +
                                    ' :pHALO, :pLALO, :pRestrictionCode, :pSubtracting,' +
                                    ' :pTaxNo, :pFS, :pWIC, :pMaxCount)');
end;

procedure AddDPTUpdateCursor (var Cursors : TIBSQLBuilder);
begin
  Cursors.AddCursor('DPT-Update','update Dept set Name = :pName, GrpNo = :pGrpNo, DISC = :pDISC,' +
                                   ' HALO = :pHALO, LALO = :pLALO, RestrictionCode = :pRestrictionCode, Subtracting = :pSubtracting,' +
                                   ' TaxNo = :pTaxNo, FS = :pFS, WIC = :pWIC, MaxCount = :pMAXCount' +
                                   ' where DeptNo = :pDeptNo');
end;

procedure ActivateDeptUpdate(var Cursors : TIBSQLBuilder);
var
  bNeedToInsert : boolean;
  sDeptNo : string;
  iDeptNo : integer;
  elog : TStrings;
  eline : integer;
  Cursor : TIBSQL;
begin
  sDeptNo := trim(Cursors['DPT-ToDo'].FieldByName('DeptNo').AsString);
  if (sDeptNo <> '') then
    try
      iDeptNo := StrToInt(sDeptNo);
    except
      LogImportMessage('Exception converting Dept number.', true, true);
      raise;
    end
  else
    raise Exception.Create('Dept no is empty');
  
  try
    if not Cursors.ContainsKey('DPT-Exists') then
      Cursors.AddCursor('DPT-Exists', 'select * from Dept where DeptNo = :pDeptNo');
    with Cursors['DPT-Exists'] do
    begin
      ParamByName('pDeptNo').AsInteger := iDeptNo;
      ExecQuery();
      bNeedToInsert := EOF;
      Close();
    end;
    if (bNeedToInsert) then
    begin
      if not Cursors.ContainsKey('DPT-Insert') then
        AddDPTInsertCursor(Cursors);
      Cursor := Cursors['DPT-Insert'];
      LogImportMessage('Inserting Dept record', true, false);
    end
    else
    begin
      if not Cursors.ContainsKey('DPT-Update') then
        AddDPTUpdateCursor(Cursors);
      Cursor := Cursors['DPT-Update'];
      LogImportMessage('Updating Dept record', true, false);
    end;
    with Cursor do
    begin
      ParamByName('pDeptNo').AsInteger := iDeptNo;
      ParamByName('pName').AsString := Cursors['DPT-ToDo'].FieldByName('Name').AsString;
      ParamByName('pGrpNo').AsInteger := Cursors['DPT-ToDo'].FieldByName('GrpNo').AsInteger;
      ParamByName('pDISC').AsInteger := Cursors['DPT-ToDo'].FieldByName('Disc').AsInteger;
      ParamByName('pHALO').AsCurrency := Cursors['DPT-ToDo'].FieldByName('HALO').AsCurrency;
      ParamByName('pLALO').AsCurrency := Cursors['DPT-ToDo'].FieldByName('LALO').AsCurrency;
      ParamByName('pRestrictionCode').AsInteger := Cursors['DPT-ToDo'].FieldByName('RestrictionCode').AsInteger;
      ParamByName('pSubtracting').AsInteger := Cursors['DPT-ToDo'].FieldByName('Subtracting').AsInteger;
      ParamByName('pTaxNo').AsInteger := Cursors['DPT-ToDo'].FieldByName('TaxNo').AsInteger;
      ParamByName('pFS').AsInteger := Cursors['DPT-ToDo'].FieldByName('FS').AsInteger;
      ParamByName('pWIC').AsInteger := Cursors['DPT-ToDo'].FieldByName('WIC').AsInteger;
      ParamByName('pMaxCount').AsInteger := Cursors['DPT-ToDo'].FieldByName('MaxCount').AsInteger;
      ExecQuery();
    end;
  except
    on E : Exception do
    begin
      LogImportMessage('DPT: ' + sDeptNo + ' - Exec SQL failed: ' + e.message, true, true);
      elog := TStringList.Create;
      elog.Add( E.Message);
      JclLastExceptStackListToStrings(elog, False, True, True, False);
      for eline := 0 to elog.Count-1 do
        LogImportMessage('Import Dept#: ' + IntToStr(iDeptNo) + ' | ' + elog.Strings[eline], false, true);
      raise;
    end;
  end; 
end;  // procedure ActivateDeptUpdate

procedure ActivateDeptDelete(var Cursors : TIBSQLBuilder);
var
  sDeptNo : string;
  iDeptNo : integer;
begin
  sDeptNo := trim(Cursors['DPT-ToDo'].FieldByName('DeptNo').AsString);
  if (sDeptNo <> '') then
    iDeptNo := StrToInt(sDeptNo)
  else
    raise Exception.Create ('Invalid Dept No');
  
  // (todo) - Add checks to make sure delete is legal (i.e., Dept not represented in certain tables)
  if not Cursors.ContainsKey('DPT-DelFlag') then
    Cursors.AddCursor('DPT-DelFlag','update Dept set DelFlag = 1 where DeptNo = :pDeptUNo');
  with Cursors['DPT-DelFlag'] do
  begin
    try
      ParamByName('pDeptNo').AsInteger := iDeptNo;
      LogImportMessage('Marking Dept record for delete', true, false);
      ExecQuery();
    except
      on E : Exception do
        raise Exception.Create('SQL Update Dept DelFlag: ' + e.message);
    end;
  end;  // with

  // Clear any buttons preset for the department just deleted.
  ClearDeptKey(Cursors,iDeptNo);
end;  // procedure ActivateDeptDelete


// plu plu plu

procedure AddPLUInsertCursor (var Cursors : TIBSQLBuilder);
begin
  Cursors.AddCursor('PLU-Insert','insert into PLU (PLUNo, UPC, Name, DeptNo, Price,' +
                                   ' Disc, TaxNo, SplitQty, SplitPrice,' +
                                   ' VendorNo, ProdGrpNo, FS, WIC,' +
                                   ' LinkedPLU, ModifierGroup, ItemNo,' +
                                   ' BreakdownLink, BreakdownItemCount,' +
                                   ' ItemIsSold, ItemIsPurchased, UnitID,' +
                                   ' RetailPrice, PackSize, ItemNeedsActivation,' +
                                   ' ItemNeedsSwipe, MediaRestrictionCode)' +
                                   ' values (:pPLUNO, :pUPC, :pName, :pDeptNo, :pPrice,' +
                                   ' :pDisc, :pTaxNo, :pSplitQty, :pSplitPrice,' +
                                   ' :pVendorNo, :pProdGrpNo, :pFS, :pWIC,' +
                                   ' :pLinkedPLU, :pModifierGroup, :pItemNo,' +
                                   ' :pBreakdownLink, :pBreakdownItemCount,' +
                                   ' :pItemIsSold, :pItemIsPurchased, :pUnitID,' +
                                   ' :pRetailPrice, :pPackSize, :pItemNeedsActivation,' +
                                   ' :pItemNeedsSwipe, :pMediaRestrictionCode) ');
end;

procedure AddPLUUpdateCursor (var Cursors : TIBSQLBuilder);
begin
  Cursors.AddCursor('PLU-Update','update PLU set UPC = :pUPC, Name = :pName, DeptNo = :pDeptNo, Price = :pPrice,' +
                                   ' Disc = :pDisc, TaxNo = :pTaxNo, SplitQty = :pSplitQty, SplitPrice = :pSplitPrice,' +
                                   ' VendorNo = :pVendorNo, ProdGrpNo = :pProdGrpNo, FS = :pFS, WIC = :pWIC,' +
                                   ' LinkedPLU = :pLinkedPLU, ModifierGroup = :pModifierGroup, ItemNo = :pItemNo,' +
                                   ' BreakdownLink = :pBreakdownLink, BreakdownItemCount = :pBreakdownItemCount,' +
                                   ' ItemIsSold = :pItemIsSold, ItemIsPurchased = :pItemIsPurchased, UnitID = :pUnitID,' +
                                   ' RetailPrice = :pRetailPrice, PackSize = :pPackSize,' +
                                   ' ItemNeedsActivation = :pItemNeedsActivation, ItemNeedsSwipe = :pItemNeedsSwipe,' +
                                   ' MediaRestrictionCode = :pMediaRestrictionCode, DelFlag = 0' +
                                   ' where PLUNo = :pPLUNo');
end;

procedure AddDSCInsertCursor(var Cursors : TIBSQLBuilder);
begin
  Cursors.AddCursor('DSC-Insert', 'insert into Disc (DiscNo, Name, ReduceTax, Amount, RecType)' +
                                    ' values (:pDiscNo, :pName, :pReduceTax, :pAmount, :pRecType)');
end;

procedure AddMMInsertCursor(var Cursors : TIBSQLBuilder);
begin
  if (Setup.DBVersionID >= DB_VERSION_ID_MIX_MATCH_EXP_DATE) then
    Cursors.AddCursor('MM-Insert','insert into MixMatch (MMNo, Name, Qty, Price, MMType1, MMType2, MMMethod,' +
                                    ' MMNo1A, MMNo2A, RecType, MMNo1, MMNo2, DiscountPrice, ContinueDiscount, ExpirationDate)' +
                                    ' values (:pMMNo, :pName, :pQty, :pPrice, :pMMType1, :pMMType2, :pMMMethod,' +
                                    ' :pMMNo1A, :pMMNo2A, :pRecType, :pMMNo1, :pMMNo2, :pDiscountPrice, :pContinueDiscount, :pExpirationDate)')
  else
    Cursors.AddCursor('MM-Insert','insert into MixMatch (MMNo, Name, Qty, Price, MMType1, MMType2, MMMethod,' +
                                    ' MMNo1A, MMNo2A, RecType, MMNo1, MMNo2, DiscountPrice, ContinueDiscount)' +
                                    ' values (:pMMNo, :pName, :pQty, :pPrice, :pMMType1, :pMMType2, :pMMMethod,' +
                                    ' :pMMNo1A, :pMMNo2A, :pRecType, :pMMNo1, :pMMNo2, :pDiscountPrice, :pContinueDiscount)');
end;

procedure AddMMUpdateCursor(var Cursors : TIBSQLBuilder);
begin
  if (Setup.DBVersionID >= DB_VERSION_ID_MIX_MATCH_EXP_DATE) then
    Cursors.AddCursor('MM-Update', 'update MixMatch set Name = :pName, Qty = :pQty, Price = :pPrice, ExpirationDate =:pExpirationDate where MMNo = :pMMNo')
  else
    Cursors.AddCursor('MM-Update', 'update MixMatch set Name = :pName, Qty = :pQty, Price = :pPrice where MMNo = :pMMNo');
end;

procedure ActivatePLUUpdate(var Cursors : TIBSQLBuilder ; var unitmap : IJclStrStrMap; const PCR : TStrings = nil; const DS : TList = nil);
var
  bNeedToInsert : boolean;
  sPLUNumber : string;
  cPLUNumber : currency;
  sUPC : string;
  cUPC : currency;
  iUnitID : integer;
  sUnitName : string;
  Cursor : TIBSQL;
  elog : TStrings;
  eline : integer;
  origprice, newprice, qoh : currency;
begin
  sPLUNumber := trim(Cursors['PLU-ToDo'].FieldByName('PLUNumber').AsString);
  if (sPLUNumber <> '') then
    try
      cPLUNumber := StrToCurr(sPLUNumber);
    except
      raise Exception.Create('Exception converting PLU number.');
    end
  else
    raise Exception.Create('Required field (PLU number) missing.');

  sUPC := trim(Cursors['PLU-ToDo'].FieldByName('UPCNumber').AsString);
  if (sUPC = '') then
  begin
    // UPC value not provided. Default to PLU value
    sUPC := sPLUNumber;
    cUPC := CPLUNumber;
  end
  else
  begin
    try
      cUPC := StrToCurr(sUPC);
    except
      on E : Exception do
        raise Exception.Create('Exception converting UPC. ' + E.Message);
    end;
  end;
  
  if UnitMap = nil then
    UnitMap := GetUnitMap(Cursors);
  // Determine unit name:
  iUnitID := 0;  // Default value (unit may be specified)
  sUnitName := Trim(Cursors['PLU-ToDo'].FieldByName('UnitName').AsString);
  if (sUnitName <> '') then
    if UnitMap.ContainsKey(sUnitName) then
      iUnitID := StrToInt(UnitMap.GetValue(sUnitName))
    else
      raise Exception.Create('No unit ID for unit: "' + sUnitName + '"');
  origprice := 0;
  try
    if not Cursors.ContainsKey('PLU-Exists') then
      Cursors.AddCursor('PLU-Exists', 'select pluno, price from PLU where PLUNo = :pPLUNo');
    with Cursors['PLU-Exists'] do
    begin
      ParamByName('pPLUNo').AsCurrency := cPLUNumber;
      ExecQuery();
      bNeedToInsert := EOF;
      if not bNeedToInsert then
        origprice := FieldByName('price').AsCurrency;
      Close();
    end;
    if (bNeedToInsert) then
    begin
      if not Cursors.ContainsKey('PLU-Insert') then
        AddPLUInsertCursor(Cursors);
      Cursor := Cursors['PLU-Insert'];
      LogImportMessage('Inserting PLU record', true, false);
    end
    else
    begin
      if not Cursors.ContainsKey('PLU-Update') then
        AddPLUUpdateCursor(Cursors);
      Cursor := Cursors['PLU-Update'];
      LogImportMessage('Updating PLU record', true, false);
      if not Cursors['PLU-ToDo'].FieldByName('QtyOH').IsNull then
      begin
        newprice := Cursors['PLU-ToDo'].FieldByName('UnitPrice').AsCurrency;
        qoh := Cursors['PLU-ToDo'].FieldByName('QtyOH').AsCurrency;
        if origprice <> newprice then
        begin
          SumDept(DS, Cursors['PLU-ToDo'].FieldByName('DeptNo').AsInteger,qoh*(newprice-origprice));
          PCR.Add(Format('%-15s %-20s ',[sUPC, Cursors['PLU-ToDo'].FieldByName('Name').AsString]));
          PCR.Add(Format('%6.2f->%6.2f=%6.2f x %8.2f = %8.2f',[origprice,newprice,newprice-origprice,qoh,qoh*(newprice-origprice)]));
        end;
      end;
    end;
    with Cursor do begin
      ParamByName('pPLUNo').AsCurrency := cPLUNumber;
      ParamByName('pUPC').AsCurrency := cUPC;
      ParamByName('pName').AsString := Cursors['PLU-ToDo'].FieldByName('Name').AsString;
      ParamByName('pDeptNo').AsInteger := Cursors['PLU-ToDo'].FieldByName('DeptNo').AsInteger;
      ParamByName('pPrice').AsCurrency := Cursors['PLU-ToDo'].FieldByName('UnitPrice').AsCurrency;
      ParamByName('pDisc').AsInteger := Cursors['PLU-ToDo'].FieldByName('Disc').AsInteger;
      ParamByName('pTaxNo').AsInteger := Cursors['PLU-ToDo'].FieldByName('TaxNo').AsInteger;
      ParamByName('pSplitQty').AsInteger := Cursors['PLU-ToDo'].FieldByName('SplitQty').AsInteger;
      ParamByName('pSplitPrice').AsCurrency := Cursors['PLU-ToDo'].FieldByName('SplitPrice').AsCurrency;
      ParamByName('pVendorNo').AsInteger := Cursors['PLU-ToDo'].FieldByName('VendorNo').AsInteger;
      ParamByName('pProdGrpNo').AsInteger := Cursors['PLU-ToDo'].FieldByName('ProductGroup').AsInteger;
      ParamByName('pFS').AsInteger := Cursors['PLU-ToDo'].FieldByName('FS').AsInteger;
      ParamByName('pWIC').AsInteger := Cursors['PLU-ToDo'].FieldByName('WIC').AsInteger;
      ParamByName('pLinkedPLU').AsCurrency := Cursors['PLU-ToDo'].FieldByName('LinkedPLU').AsCurrency;
      ParamByName('pModifierGroup').AsCurrency := Cursors['PLU-ToDo'].FieldByName('ModifierGroup').AsInteger;
      ParamByName('pItemNo').AsCurrency := Cursors['PLU-ToDo'].FieldByName('ItemNo').AsCurrency;
      ParamByName('pBreakDownLink').AsCurrency := Cursors['PLU-ToDo'].FieldByName('BreakDownLink').AsCurrency;
      ParamByName('pBreakDownItemCount').AsInteger := Cursors['PLU-ToDo'].FieldByName('BreakDownItemCount').AsInteger;
      ParamByName('pItemIsSold').AsInteger := Cursors['PLU-ToDo'].FieldByName('ItemIsSold').AsInteger;
      ParamByName('pItemIsPurchased').AsInteger := Cursors['PLU-ToDo'].FieldByName('ItemIsPurchased').AsInteger;
      ParamByName('pUnitID').AsInteger := iUnitID;
      ParamByName('pRetailPrice').AsCurrency := Cursors['PLU-ToDo'].FieldByName('RetailPrice').AsCurrency;
      ParamByName('pPackSize').AsString := Cursors['PLU-ToDo'].FieldByName('PackSize').AsString;
      ParamByName('pItemNeedsActivation').AsInteger := Cursors['PLU-ToDo'].FieldByName('ItemNeedsActivation').AsInteger;
      ParamByName('pItemNeedsSwipe').AsInteger := Cursors['PLU-ToDo'].FieldByName('ItemNeedsSwipe').AsInteger;
      ParamByName('pMediaRestrictionCode').AsInt64 := Cursors['PLU-ToDo'].FieldByName('MediaRestrictionCode').AsInt64;
      (*  PLU table                PLUImport table
          ------------------------+-----------------------------
          PLUImportNo	INTEGER NOT NULL,
          ImportDate	TIMESTAMP,
          Posted	SMALLINT,
          PostDate	TIMESTAMP,
          Status	VARCHAR(50),
          ImportAction	VARCHAR(10),
          ActivationDate	TIMESTAMP,
          ActivationTime	TIMESTAMP,
          RecType	VARCHAR(10),
          PLUNo	MONEY NOT NULL,       PLUNumber	VARCHAR(20)
          UPC	MONEY,                  UPCNumber	VARCHAR(20)
          Name	VARCHAR(30),          *
          DeptNo	SMALLINT,                       Integer
          Price	MONEY,                UnitPrice
          OnHand	MONEY,
          Disc	SMALLINT,             *
          TaxNo	SMALLINT,             *
          SplitQty	INTEGER,          *
          SplitPrice	MONEY,          *
          VendorNo	INTEGER,          *
          ProdGrpNo	INTEGER,          ProductGroup
          FS	SMALLINT,               *
          WIC	SMALLINT,               *
          LinkedPLU	MONEY,            *
          Subtracting	SMALLINT,
          ModifierGroup	MONEY,                    Integer
          DelFlag	SMALLINT,
          HostKey	VARCHAR(20),
          ItemNo	MONEY,              *
          RetailPrice	MONEY,          *
          BreakdownLink	MONEY,
          BreakdownItemCount	INTEGER,
          ItemIsSold	SMALLINT,
          ItemIsPurchased	SMALLINT,
          UnitID	INTEGER,
          PackSize	VARCHAR(10),      *
          ModifierNo	INTEGER
          ModifierName	VARCHAR(20)
          VendorName	VARCHAR(40)
      *)
      ExecQuery();
    end;
  except
    on E : Exception do
    begin
      LogImportMessage('PLU: ' + sPLUNumber + ' - Exec SQL failed: ' + e.message, true, true);
      elog := TStringList.Create;
      elog.Add( E.Message);
      JclLastExceptStackListToStrings(elog, False, True, True, False);
      for eline := 0 to elog.Count-1 do
        LogImportMessage('Import #: ' + IntToStr(Cursors['PLU-ToDo'].FieldByName('PLUImportNo').AsInteger) + ' | ' + elog.Strings[eline], false, true);
      raise;
    end;
  end;
end;  // function ActivatePLUUpdate

procedure ActivatePLUDelete(var Cursors : TIBSQLBuilder);
var
  sPLUNumber : string;
  cPLUNumber : currency;
  sCheckPLU : string;
  cCheckPLU : currency;
  iLinkedPLUCount : integer;
begin
  iLinkedPLUCount := 0;
  cPLUNumber := 0.0;  // Reset below (prevents compiler warning;
  sPLUNumber := trim(Cursors['PLU-ToDo'].FieldByName('PLUNumber').AsString);
  if (sPLUNumber <> '') then
    cPLUNumber := StrToCurr(sPLUNumber);
  if not Cursors.ContainsKey('PLU-Delflag') then
    Cursors.AddCursor('PLU-Delflag', 'update PLU set DelFlag = 1 where PLUNo = :pPLUNo');
  with Cursors['PLU-Delflag'] do
  begin
    try
      ParamByName('pPLUNo').AsCurrency := cPLUNumber;
      LogImportMessage('Marking PLU record for delete', true, false);
      ExecQuery();
      Close()
    except
      on E : Exception do
        raise Exception.Create('SQL update PLU DelFlag: ' + E.message)
    end;
  end;  // with
  
  // Remove references to linked PLUs.  (First just query so log messages can be formatted.)
  if (cPLUNumber > 0.0) then
  begin
    if not Cursors.ContainsKey('PLU-LinkPLU') then
      Cursors.AddCursor('PLU-LinkPLU', 'select PLUNo from PLU where LinkedPLU = :pLinkedPLU');
    with Cursors['PLU-LinkPLU'] do    
    begin
      try
        ParamByName('pLinkedPLU').AsCurrency := cPLUNumber;
        LogImportMessage('Removing link', true, false);
        ExecQuery();
        while (not EOF) do
        begin
          Inc(iLinkedPLUCount);
          cCheckPLU := FieldByName('PLUNo').AsCurrency;
          sCheckPLU := CurrToStr(cCheckPLU);
          LogImportMessage('PLU: ' + sPLUNumber + ' has link from PLU: ' + scheckPLU, true, false);
          Next();
        end;  // while
      except
          on E : Exception do
            raise Exception.Create('SQL failed on checking Linked PLU: ' + e.message);
      end;
      Close();
    end;  // with
  end;  //if (RetVal and (cPLUNumber > 0.0))
        // If the PLU being deleted has links from other PLUs, then remove the links.
  if (iLinkedPLUCount > 0) then
  begin
    if not Cursors.ContainsKey('PLU-DelLink') then
      Cursors.AddCursor('PLU-DelLink','update PLU set LinkedPLU = 0 where LinkedPLU = :pPLUNo');
    with Cursors['PLU-DelLink'] do
    begin
      try
        ParamByName('pPLUNo').AsCurrency := cPLUNumber;
        LogImportMessage('PLU: ' + sPLUNumber + ' Removing PLU references from other PLUs', true, false);
        ExecQuery();
        Close();
      except
        on E : Exception do
          raise Exception.Create('SQL failed on updating Linked PLU: ' + e.message);
      end;
    end;  // with
  end; //    iLinkedPLUCount > 0
    
  // Clear any buttons preset for the PLU just deleted.
  ClearPLUKey(Cursors,cPLUNumber);
end;  // procedure ActivatePLUDelete

procedure ActivateDiscountDelete(var Cursors : TIBSQLBuilder);
var
  iDiscNumber : integer;
begin
  iDiscNumber := Cursors['PLU-ToDo'].FieldByName('Disc').AsInteger;
  if (iDiscNumber <= 0) then
    raise Exception.Create('Invalid discount number: ' + IntToStr(iDiscNumber));
  if not Cursors.ContainsKey('DSC-PLUDel') then
    Cursors.AddCursor('DSC-PLUDel','update PLU set Disc = 0 where Disc = :pDisc');
  with Cursors['DSC-PLUDel'] do
  begin
    ParamByName('pDisc').AsInteger := iDiscNumber;
    LogImportMessage('Removing Disc from PLU', true, false);
    ExecQuery();
  end;
  if not Cursors.ContainsKey('DSC-Del') then
    Cursors.AddCursor('DSC-Del','delete from Disc where DiscNo = :pDiscNo');
  with Cursors['DSC-Del'] do
  begin
    ParamByName('pDiscNo').AsInteger := iDiscNumber;
    LogImportMessage('Deleting Disc record', true, false);
    ExecQuery();
  end;  // with
end;  // procedure ActivateDiscountDelete

procedure ActivateDiscountUpdate(var Cursors : TIBSQLBuilder);
var
  iDiscNumber : integer;
  Cursor : TIBSQL;
  bNeedToInsert : boolean;
begin
  iDiscNumber := Cursors['PLU-ToDo'].FieldByName('Disc').AsInteger;
  if (iDiscNumber <= 0) then
    raise Exception.Create('Invalid discount number: ' + IntToStr(iDiscNumber));

  if not Cursors.ContainsKey('DSC-Exists') then
    Cursors.AddCursor('DSC-Exists','select DiscNo from Disc where DiscNo = :pDiscNo');
  with Cursors['DSC-Exists'] do
  begin
    ParamByName('pDiscNo').AsInteger := iDiscNumber;
    ExecQuery();
    bNeedToInsert := EOF;
    Close();
  end;
  if bNeedToInsert then
  begin
    Cursors.AddCursorINE('DSC-Insert','insert into Disc (DiscNo, Name, ReduceTax, Amount, RecType)' +
                                        ' values (:pDiscNo, :pName, :pReduceTax, :pAmount, :pRecType)');
    LogImportMessage('Inserting Disc record', true, false);
    Cursor := Cursors['DSC-Insert'];
  end
  else
  begin
    Cursors.AddCursorINE('DSC-Update','update Disc set Name = :pName, ReduceTax = :pReduceTax,' +
                                        ' Amount = :pAmount, RecType = :pRecType' +
                                        ' where DiscNo = :pDiscNo');
    LogImportMessage('Updating Disc record', true, false);
    Cursor := Cursors['DSC-Update'];
  end;
  with Cursor do
  begin
    ParamByName('pDiscNo').AsInteger := iDiscNumber;
    ParamByName('pName').AsString := Copy(Cursors['PLU-ToDo'].FieldByName('Name').AsString, 1, 20);
    ParamByName('pReduceTax').AsInteger := Cursors['PLU-ToDo'].FieldByName('TaxNo').AsInteger;
    ParamByName('pAmount').AsCurrency := Cursors['PLU-ToDo'].FieldByName('UnitPrice').AsCurrency;
    ParamByName('pRecType').AsString := Copy(Cursors['PLU-ToDo'].FieldByName('RecType').AsString, 1, 1);
    (*  DISC table                PLUImport table
        ------------------------+-----------------------------
        DISCNO	SMALLINT NOT NULL,  Disc  SMALLINT,
        NAME	VARCHAR(20),          Name Varchar(30),
        REDUCETAX	SMALLINT,         TaxNo smallint,
        AMOUNT	MONEY,              UnitPrice MONEY,
        RECTYPE	CHAR(1),            RecType VARCHAR(10),
                                    PLUImportNo	INTEGER NOT NULL,
                                    ImportDate	TIMESTAMP,
                                    Posted	SMALLINT,
                                    PostDate	TIMESTAMP,
                                    Status	VARCHAR(50),
                                    ImportAction	VARCHAR(10),
                                    ActivationDate	TIMESTAMP,
                                    ActivationTime	TIMESTAMP,
                                    RecType	VARCHAR(10),
    *)
    ExecQuery();
  end;  // with
end;  // function ActivateDiscountUpdate

procedure ActivateVolumeDiscountDelete(var Cursors : TIBSQLBuilder);
{
Update the database to deactivate a volume discount (e.g. 3 for $1.49).
The query Cursors['PLU-ToDo'] is assumed to hold the selected data from PLUImport.
The transaction for this SQL
is setup and commited by the caller if all import upgrades are OK.
}
var
  iDiscNumber : integer;
  cPLUNumber : currency;
begin
  // Extract applicable parameters from the query to PLUImport.
  cPLUNumber := Cursors['PLU-ToDo'].FieldByName('PLUNumber').AsCurrency;
  if (cPLUNumber <= 0) then
    raise Exception.Create('Invalid PLU number for volume discount: ' + CurrToStr(cPLUNumber));
  Cursors.AddCursorINE('VDS-GetDiscNo','select D.DiscNo, D.Name from Disc D right outer join MixMatch M ' +
                                         'on D.DiscNo = M.MMNo where M.MMNo1 = :pNNno1 and M.MMType1 = :pMMType1');
  with Cursors['VDS-GetDiscNo'] do
  begin
    ParamByName('pNNno1').AsCurrency := cPLUNumber;
    ParamByName('pMMType1').AsInteger := MM_PLU;
    ExecQuery();
    if (not EOF) then
      iDiscNumber := FieldByName('DiscNo').AsInteger
    else
      iDiscNumber := 0;
    Close();
    // If discount previously defined, then modify it so that it is no longer active;
    // otherewise, issue warning.
    if (iDiscNumber > 0) then
    begin
      // Update mix match record so that it no longer represents a PLU discount.
      Cursors.AddCursorINE('VDS-DAMM','update MixMatch set MMType1 = :pMMType1 where MMNo = :pMMNo');
      with Cursors['VDS-DAMM'] do
      begin
        LogImportMessage('Marking MixMatch record as inactive', true, false);
        ParamByName('pMMType1').AsInteger := -MM_PLU;
        ParamByName('pMMNo').AsInteger := iDiscNumber;
        ExecQuery();
      end;
    end
    else
      LogImportMessage('WARNING:  Volume discount to delete does not exist for PLU: ' + CurrToStr(cPLUNumber), true, false);
  end;
end;  // function ActivateVolumeDiscountDelete

procedure ActivateVolumeDiscountUpdate(var Cursors : TIBSQLBuilder);
{
Update the database for a volume discount (e.g. 3 for $1.49).
The query Cursors['PLU-ToDo'] is assumed to hold the selected data from PLUImport.
The transaction for this SQL is setup and commited by the caller if all import upgrades are OK.
}
var
  bNeedToInsert : boolean;
  iDiscNumber : integer;
  iReduceTax : integer;
  iMMNumber : integer;
  cPLUNumber : currency;
  tExpirationDate : TDateTime;
  iSplitQty : integer;
  cSplitPrice : currency;
  sRecordType : string;
  sDiscountName : string;
  sDiscountNameInDiscTable : string;
begin
  // Extract applicable parameters from the query to PLUImport.
  cPLUNumber := Cursors['PLU-ToDo'].FieldByName('PLUNumber').AsCurrency;
  if (cPLUNumber <= 0) then
    raise Exception.Create('Invalid PLU number for volume discount: ' + CurrToStr(cPLUNumber));
  
  tExpirationDate := Cursors['PLU-ToDo'].FieldByName('ActivationTime').AsDateTime;
  
  iSplitQty := Cursors['PLU-ToDo'].FieldByName('SplitQty').AsInteger;
  if (iSplitQty <= 0) then
    raise Exception.Create('Invalid split quantity for volume discount: ' + IntToStr(iSplitQty));
  
  cSplitPrice := Cursors['PLU-ToDo'].FieldByName('SplitPrice').AsCurrency;
  if (cSplitPrice <= 0.0) then
    raise Exception.CreateFmt('Invalid price for volume discount on %.0g: %.2g', [cPLUNumber, cSplitPrice]);
  
  sDiscountName := Copy(Cursors['PLU-ToDo'].FieldByName('ModifierName').AsString, 1, 20);
  sRecordType := Copy(Cursors['PLU-ToDo'].FieldByName('RecType').AsString, 1, 1);
  if (sRecordType = '') then
    sRecordType := 'D';
  
  Cursors.AddCursorINE('VDS-GetDiscNoQty','select D.DiscNo, D.Name, D.ReduceTax from Disc D right outer join MixMatch M on D.DiscNo = M.MMNo' +
                                            ' where M.MMNo1 = :pNNno1 and M.MMType1 = :pMMType1 and M.Qty = :pQty');
  with Cursors['VDS-GetDiscNoQty'] do
  begin
    ParamByName('pQty').AsInteger := iSplitQty;
    ParamByName('pNNno1').AsCurrency := cPLUNumber;
    ParamByName('pMMType1').AsInteger := MM_PLU;
    ExecQuery();
    bNeedToInsert := EOF;
    if (bNeedToInsert) then
    begin
      sDiscountNameInDiscTable := '';
      iDiscNumber := 0;
      iReduceTax := 0;
    end
    else
    begin
      sDiscountNameInDiscTable := FieldByName('Name').AsString;
      iDiscNumber := FieldByName('DiscNo').AsInteger;
      iReduceTax := FieldByName('ReduceTax').AsInteger;
    end;
    Close();
  end;
  // If discount not previously defined, then define it;
  // otherewise alter it.
  if (bNeedToInsert) then
  begin
    Cursors.AddCursorINE('DSC-MaxDiscNo','select MAX(DiscNo) as Result from Disc');
    Cursors.AddCursorINE('DSC-MaxMMNo','select MAX(MMNo) as Result from MixMatch');
    iDiscNumber := ValueGet(Cursors['DSC-MaxDiscNo'],0);
    iMMNumber := ValueGet(Cursors['DSC-MaxMMNo'],0);
    if (iMMNumber > iDiscNumber) then
      iDiscNumber := iMMNumber;
    if iDiscNumber < 1 then
      iDiscNumber := 1;
    iDiscNumber := iDiscNumber + 1;
    
    if not Cursors.ContainsKey('DSC-Insert') then
      AddDSCInsertCursor(Cursors);
    with Cursors['DSC-Insert'] do
    begin
      ParamByName('pDiscNo').AsInteger := iDiscNumber;
      ParamByName('pName').AsString := sDiscountName;
      ParamByName('pReduceTax').AsInteger := Cursors['PLU-ToDo'].FieldByName('TaxNo').AsInteger;
      ParamByName('pAmount').AsCurrency := Cursors['PLU-ToDo'].FieldByName('UnitPrice').AsCurrency;
      ParamByName('pRecType').AsString := sRecordType;
      ExecQuery();
      Close()
    end;
    
    if not Cursors.ContainsKey('MM-Insert') then
      AddMMInsertCursor(Cursors);
    with Cursors['MM-Insert'] do
    begin
      // Add new mix match record.
      LogImportMessage('Inserting Volume Mix Match record', true, false);
      if (Setup.DBVersionID >= DB_VERSION_ID_MIX_MATCH_EXP_DATE) then
      begin
        if tExpirationDate = 0 then
          ParamByName('pExpirationDate').IsNull := True
        else
          ParamByName('pExpirationDate').AsDateTime := tExpirationDate;
      end
      else
        if (tExpirationDate > 0.0) then
          LogImportMessage('DB version does not support specified expiration date.  Expiration date ignored in insert.', true, true);
      ParamByName('pMMNo').AsInteger := iDiscNumber;
      ParamByName('pName').AsString := sDiscountName;
      ParamByName('pQty').AsInteger := iSplitQty;
      ParamByName('pPrice').AsCurrency := cSplitPrice;
      ParamByName('pMMType1').AsInteger := MM_PLU;
      ParamByName('pMMType2').AsInteger := -1;
      ParamByName('pMMMethod').AsInteger := 0;
      ParamByName('pMMNo1A').AsInteger := 0;
      ParamByName('pMMNo2A').AsInteger := 0;
      ParamByName('pRecType').AsInteger := 1;
      ParamByName('pMMNo1').AsCurrency := cPLUNumber;
      ParamByName('pMMNo2').AsCurrency := 0;
      ParamByName('pDiscountPrice').AsCurrency := 0.0;
      ParamByName('pContinueDiscount').AsInteger := -1;
      ExecQuery();
    end;
  end
  else
  begin
    // Update mix match record for the volume discount.
    LogImportMessage('Updating MixMatch record', true, false);
    if not Cursors.ContainsKey('MM-Update') then
      AddMMUpdateCursor(Cursors);
    with Cursors['MM-Update'] do
    begin
      if (Setup.DBVersionID >= DB_VERSION_ID_MIX_MATCH_EXP_DATE) then
      begin
        if tExpirationDate = 0 then
          ParamByName('pExpirationDate').IsNull := True
        else
          ParamByName('pExpirationDate').AsDateTime := tExpirationDate;
      end
      else
        if (tExpirationDate > 0.0) then
          LogImportMessage('DB version does not support specified expiration date.  Expiration date ignored in update.', true, true);

      ParamByName('pMMNo').AsInteger := iDiscNumber;
      ParamByName('pName').AsString := sDiscountName;
      ParamByName('pQty').AsInteger := iSplitQty;
      ParamByName('pPrice').AsCurrency := cSplitPrice;
      ExecQuery();
      Close();
    end;
    // Update any applicable Disc fields (some are ignored when linked to the MixMatch table).
    if (sDiscountNameInDiscTable <> sDiscountName) or (iReduceTax <> Cursors['PLU-ToDo'].FieldByName('TaxNo').AsInteger) then
    begin
      Cursors.AddCursorINE('DSC-NameUpdate','update Disc set Name = :pName, ReduceTax = :pReduceTax where DiscNo = :pDiscNo');
      LogImportMessage(format('Updating Disc record for %d', [iDiscNumber]), true, false);
      with Cursors['DSC-NameUpdate'] do
      begin
        ParamByName('pDiscNo').AsInteger := iDiscNumber;
        ParamByName('pName').AsString := sDiscountName;
        ParamByName('pReduceTax').AsInteger := Cursors['PLU-ToDo'].FieldByName('TaxNo').AsInteger;
        ExecQuery();
        Close();
      end;
    end;  // with
  end;
end;  // function ActivateVolumeDiscountUpdate

procedure ClearPLUKey(var Cursors : TIBSQLBuilder; ClearPLUNo : currency);
{
Remove any key definitions for the given PLU number.
}
var
  RetVal : boolean;
  sClearPLUNo : string;
  sCheckPLUNo : string;
  sCheckKeyType : string;
  KeyboardIndex : integer;
  ButtonIndex : integer;
  j1 : integer;
  j2 : integer;
  sTempMsg : string;
  sSQLErrorMessage : string;
begin
  RetVal := True;  // Initaial assumption
  if (ClearPLUNo > 0.0) then
  begin
    sClearPLUNo := Trim(CurrToStr(ClearPLUNo));
    for j1 := 0 to 40 do
    begin
      KeyboardIndex := j1;
      for j2 := 1 to MaxKeyNo do
      begin
        ButtonIndex := j2;
        sCheckKeyType := Copy(KybdArray[KeyboardIndex, ButtonIndex].KeyType, 1, 3);
        if (sCheckKeyType = 'PPL') then
        begin
          sCheckPLUNo := Trim(KybdArray[KeyboardIndex, ButtonIndex].KeyVal);
          if (sCheckPLUNo = sClearPLUNo) then
          begin
            sTempMsg := 'Preset key found to clear: PLU = ' + sClearPLUNo + ' - [' + IntToStr(KeyboardIndex) + ',' + IntToStr(ButtonIndex) + '].code = ' + KybdArray[KeyboardIndex, ButtonIndex].KeyCode;
            LogImportMessage(sTempMsg, true, false);
            if (not ClearTouchKey(Cursors, KeyboardIndex, ButtonIndex, sSQLErrorMessage)) then
            begin
              RetVal := false;
              sTempMsg := 'ClearPLUKey - update TouchKyBd failed: PLU = ' + sClearPLUNo + ' - [' + IntToStr(KeyboardIndex) + ',' + IntToStr(ButtonIndex) + '].code =' + KybdArray[KeyboardIndex, ButtonIndex].KeyCode + ' : '  + sSQLErrorMessage;
              LogImportMessage(sTempMsg, true, true);
              UpdateExceptLog(sTempMsg);
              break;
            end;
            KybdArray[KeyboardIndex, ButtonIndex].BtnLabel := '';
            KybdArray[KeyboardIndex, ButtonIndex].KeyCaption := '';
          end;
        end;
      end;  // for j2 := 1 to MaxKeyNo
      if (not RetVal) then
        break;                   // Do not keep checking if error detected above.
    end;  //for j1 := 1 to 40
  end;  //if (ClearPLUNo > 0.0)
end;  // function ClearPLUKey

procedure ClearDeptKey(var Cursors : TIBSQLBuilder; ClearDeptNo : integer);
{
Remove any key definitions for the given Department number.
}
var
  RetVal : boolean;
  sClearDeptNo : string;
  sCheckDeptNo : string;
  sCheckKeyType : string;
  KeyboardIndex : integer;
  ButtonIndex : integer;
  j1 : integer;
  j2 : integer;
  sTempMsg : string;
  sSQLErrorMessage : string;
begin
  RetVal := True;  // Initaial assumption
  if (ClearDeptNo > 0) then
  begin
    sClearDeptNo := Trim(IntToStr(ClearDeptNo));
    for j1 := 0 to 40 do
    begin
      KeyboardIndex := j1;
      for j2 := 1 to MaxKeyNo do
      begin
        ButtonIndex := j2;
        sCheckKeyType := Copy(KybdArray[KeyboardIndex, ButtonIndex].KeyType, 1, 3);
        if (sCheckKeyType = 'DPT') then
        begin
          sCheckDeptNo := Trim(KybdArray[KeyboardIndex, ButtonIndex].KeyVal);
          if (sCheckDeptNo = sClearDeptNo) then
          begin
            sTempMsg := 'Preset key found to clear: Dept = ' + sClearDeptNo + ' - [' + IntToStr(KeyboardIndex) + ',' + IntToStr(ButtonIndex) + '].code = ' + KybdArray[KeyboardIndex, ButtonIndex].KeyCode;
            LogImportMessage(sTempMsg, true, false);
            if (not ClearTouchKey(Cursors,KeyboardIndex, ButtonIndex, sSQLErrorMessage)) then
            begin
              RetVal := false;
              sTempMsg := 'ClearDeptKey - update TouchKyBd failed: Dept = ' + sClearDeptNo + ' - [' + IntToStr(KeyboardIndex) + ',' + IntToStr(ButtonIndex) + '].code =' + KybdArray[KeyboardIndex, ButtonIndex].KeyCode + ' : '  + sSQLErrorMessage;
              LogImportMessage(sTempMsg, true, true);
              UpdateExceptLog(sTempMsg);
              break;
            end;
            KybdArray[KeyboardIndex, ButtonIndex].BtnLabel := '';
            KybdArray[KeyboardIndex, ButtonIndex].KeyCaption := '';
          end;
        end;
      end;  // for j2 := 1 to MaxKeyNo
      if (not RetVal) then
        break;                   // Do not keep checking if error detected above.
    end;  //for j1 := 1 to 40
  end;  //if (ClearDeptNo > 0)
end;  // function ClearDeptKey


function ClearTouchKey(var Cursors : TIBSQLBuilder;
                       const KeyboardIndex : integer;
                       const ButtonIndex : integer;
                       var sSQLErrMsg : string) : boolean;
var
  RetVal : boolean;
begin
  RetVal := True;    // initial assumption
  sSQLErrMsg := '';  // initial assumption
  try
    Cursors.AddCursorINE('TKB-Update','update TouchKyBd set PreSet = :pPreSet,' +
                                        ' BtnColor = :pBtnColor, BtnShape = :pBtnShape,' +
                                        ' BtnFont = :pBtnFont, BtnFontColor = :pBtnFontColor,' +
                                        ' BtnFontSize = :pBtnFontSize, BtnFontBold = :pBtnFontBold,' +
                                        ' BtnLabel = :pBtnLabel, KeyVal = :pKeyVal, MgrLock = :pMgrLock,' +
                                        ' RecType = :pRecType' +
                                        ' where AltNo = :pAltNo and MenuNo = :pMenuNo and code = :pCode');

    with Cursors['TKB-Update'] do
    begin
      ParamByName('pPreSet').AsString:= '';
      ParamByName('pBtnColor').AsString:= 'Cyan';
      ParamByName('pBtnShape').AsInteger := 1;
      ParamByName('pBtnFont').AsString:= 'Arial';
      ParamByName('pBtnFontColor').AsString := 'clBlack';
      ParamByName('pBtnFontSize').AsInteger := 10;
      ParamByName('pBtnFontBold').AsInteger := 1;
      ParamByName('pBtnLabel').AsString:= '';
      ParamByName('pKeyVal').AsString:= '';
      ParamByName('pMgrLock').AsInteger := 0;
      ParamByName('pRecType').AsString:= '';
      ParamByName('pAltNo').AsInteger  := KybdArray[KeyboardIndex, ButtonIndex].AltNo;
      ParamByName('pMenuNo').AsInteger := KybdArray[KeyboardIndex, ButtonIndex].MenuNo;
      ParamByName('pCode').AsString    := KybdArray[KeyboardIndex, ButtonIndex].KeyCode;
      ExecQuery;
      Close();
    end;  // with
  except
    on E : Exception do
    begin
      RetVal := false;
      sSQLErrMsg := e.message;
    end;  // on
  end;  // try/except
  ClearTouchKey := RetVal;
end;  // Function ClearTouchKey

procedure LogImportMessage(const sMessage     : string;
                           const bToLogFile   : boolean;
                           const bToErrorFile : boolean);
begin

  if LogBuffer = nil then
    LogBuffer := TStringList.Create;
  if (bToLogFile) then
  begin
    if sMessage <> '' then
      LogBuffer.Add(Format('%s %s', [FormatDateTime('yyyy-mm-dd hh:mm:ss.zzz', Now), sMessage]))
    else
    begin
      AssignFile(ImportLog, sImportLogName);
      if FileExists(sImportLogName) then
        Append(ImportLog)
      else
        ReWrite(ImportLog);
      if (not bLogFileInitialized) then
      begin
        WriteLn(ImportLog, sImportFileHeader);
        bLogFileInitialized := true;
      end;
      Write(ImportLog, LogBuffer.Text);
      LogBuffer.Clear;
      LogBuffer.Capacity := 0;
      CloseFile(ImportLog);
    end;
  end;

  if (bToErrorFile) then
  begin
    AssignFile(ImportErrLog, sImportErrLogName);
    if FileExists(sImportErrLogName) then
      Append(ImportErrLog)
    else
      ReWrite(ImportErrLog);
    if (not bErrorLogInitialized) then
    begin
      WriteLn(ImportErrLog, sImportFileHeader);
      bErrorLogInitialized := true;
    end;
    WriteLn(ImportErrLog, sMessage);
    CloseFile(ImportErrLog);
  end;
end;  // procedure LogImportMessage

procedure SaveImportReject(const rejString : string);
var
  TF     : TextFile;
  TFName : string;
begin
  try
    TFName := ExtractFileDir(Application.ExeName) + '\Update\LatitudePLU.rej' ;
    If Fileexists (TFName) and (Now() - FileDateToDateTime(FileAge(TFName)) >= 1) Then
      DeleteFile(TFName);
    AssignFile(TF, TFName);
    if FileExists(TFName) then
      Append(TF)
    else
      ReWrite(TF);
    WriteLn(TF, rejString);
    CloseFile(TF);
  except
  end;
end;

procedure SaveImportEarly(const rejString : string);
var
  TF     : TextFile;
  TFName : string;
begin
  try
    TFName := ExtractFileDir(Application.ExeName) + '\Update\LatitudeImp.try' ;
    If Fileexists (TFName) and (Now() - FileDateToDateTime(FileAge(TFName)) >= 1) Then
      DeleteFile(TFName);
    AssignFile(TF, TFName);
    if FileExists(TFName) then
      Append(TF)
    else
      ReWrite(TF);
    WriteLn(TF, rejString);
    CloseFile(TF);
  except
  end;
end;


function GetUnitMap(Cursors : TIBSQLBuilder) : IJclStrStrMap;
var
  ibq : TIBSQL;
  UnitMap : IJclStrStrMap;
begin
  UnitMap := TJclStrStrHashMap.Create();
  Cursors.AddCursor('UnitMap-Sel','select UnitID, UnitName from INVUNITS');
  ibq := Cursors['UnitMap-Sel'];
  ibq.ExecQuery();
  while (not ibq.EOF) do
  begin
    UnitMap.PutValue(trim(ibq.FieldByName('UnitName').AsString),IntToStr(ibq.FieldByName('UnitID').AsInteger));
    ibq.next();
  end;
  ibq.close();
  Cursors.Remove('UnitMap-Sel');
  GetUnitMap := UnitMap;
end;

function RecordsExist(Cursor : TIBSQL ; recordid : integer) : Boolean;
begin
  with Cursor do
  begin
    ParamByName(':recordid').AsInteger := recordid;
    ExecQuery();
    RecordsExist := FieldByName('count').AsInteger > 0;
    Close();
  end;
end;

function ValueGet(Cursor : TIBSQL ; def : integer) : integer;
begin
  with Cursor do
  begin
    ExecQuery();
    if EOF then
      ValueGet := def
    else
      ValueGet := FieldByName('Result').AsInteger;
    Close();
  end;
end;

procedure RPTDel (Cursors : TIBSqlBuilder ; VendorNo : integer);
begin
  with Cursors['RPT-Del'] do
  begin
    try
      ParamByName('pVendorNo').AsInteger := VendorNo;
      ExecQuery;
      Close;
    except
      on E : Exception do
        LogImportMessage('Vendor: ' + IntToStr(VendorNo) + ' - Failed while deleting RecieptPinText' + e.message, true, true);
    end;
  end;  // with
end;

procedure ImportSysMgrRPT(const InputString     : Tstrings;
                          const sImportAction   : string;
                          const iImportNo       : integer;
                          const tActivationDate : TDateTime;
                          const sRecordType     : string;
                          var Cursors           : TIBSqlBuilder
                         );
var
  iVendorNo, i : integer;
  Verbage : TStrings;
  tstr : string;
  done : boolean;
begin
  ParseImport(InputString, FLD_IMPORT_RPT_VENDOR, 'RPT Vendor', 0, iVendorNo);
  if iVendorNo = 0 then
    raise EImportParse.Create('Invalid Vendor number "' + InputString[FLD_IMPORT_RPT_VENDOR - 1] + '" - ' + InputString.DelimitedText);
  Cursors.AddCursorINE('RPT-Del','Delete from ReceiptPINText where VendorNumber = :pVendorNo');
  if (sImportAction = IMPORT_ACTION_RPT_UPDATE) then
  begin
    Cursors.AddCursorINE('RPT-Insert','insert into ReceiptPINText (VendorNumber, LineNumber, ReceiptText) values (:pVendorNo, :pLine, :pText)');
    done := False;
    i := FLD_IMPORT_RPT_VENDOR + 1;
    Verbage := TStringList.Create();
    try
      repeat
        try
          ParseImport(InputString, i, 'Record Type', tstr);
          Verbage.Add(tstr);
          inc(i);
        except
          on E: EImportParse do
            done := True;
        end;
      until done or (i > (FLD_IMPORT_RPT_VENDOR + 100));
      RPTDel(Cursors, iVendorNo);
      for i := 1 to Verbage.Count do
      with Cursors['RPT-Insert'] do
      begin
        ParamByName('pVendorNo').AsInteger := iVendorNo;
        ParamByName('pLine').AsInteger := i;
        ParamByName('pText').AsString := Verbage.Strings[i - 1];
        ExecQuery;
      end;

    finally
      Verbage.Free();
    end;
  end
  else if (sImportAction = IMPORT_ACTION_RPT_DELETE) then
    RPTDel(Cursors, iVendorNo);

end;

procedure ImportSysMgrPCMAP(const InputString     : Tstrings;
                            const sImportAction   : string;
                            const iImportNo       : integer;
                            const tActivationDate : TDateTime;
                            const sRecordType     : string;
                            var Cursors           : TIBSqlBuilder
                           );
var
  sProdCode : string;
  cUPC : currency;
begin
  ParseImport(InputString, FLD_IMPORT_PCM_PRODCODE, 'PCM ProdCode', sProdCode);
  ParseImport(InputString, FLD_IMPORT_PCM_UPC, 'PCM UPC', 0.0, cUPC);
  Cursors.AddCursorINE('PCM-Del','Delete from ProductCodeMap where ProdCode = :pProdCode');
  Cursors.AddCursorINE('PCM-Insert', 'Insert into ProductCodeMap (ProdCode, UPC) values (:pProdCode,:pUPC)');
  with Cursors['PCM-Del'] do
  begin
    ParamByName('pProdCode').AsString := sProdCode;
    ExecQuery;
    Close();
  end;
  if sImportAction = IMPORT_ACTION_PCMAP_UPDATE then
    with Cursors['PCM-Insert'] do
    begin
      ParamByName('pProdCode').AsString := sProdCode;
      ParamByName('pUPC').AsCurrency := cUPC;
      ExecQuery;
      Close();
    end;
end;

end.

{-----------------------------------------------------------------------------
 Unit Name: FactorImport
 Author:    Gary Whetton
 Date:      9/11/2003 2:57:50 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit FactorImport;

interface


uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const
C_IMPORTACTION      =   1;
C_RECTYPE           =   2;
C_ACTIVATIONDATE    =   3;
C_ACTIVATIONTIME    =   4;
C_PLUNUMBER         =   5;
C_UPCNUMBER         =   6;
C_NAME              =   7;
C_DEPTNO            =   8;
C_UNITPRICE         =   9;
C_SPLITQTY          =  10;
C_SPLITPRICE        =  11;
C_DISC              =  12;
C_FS                =  13;
C_WIC               =  14;
C_TAXNO             =  15;
C_MODIFIERGROUP     =  16;
C_MODIFIERNO        =  17;
C_MODIFIERNAME      =  18;
C_LINKEDPLU         =  19;
C_VENDORNO          =  20;
C_PRODUCTGROUP      =  21;
C_ITEMNO            =  22;
C_VENDORNAME        =  23;
C_PACKSIZE          =  24;
C_RETAILPRICE       =  25;
C_DISCNAME          =  26;
C_MMTYPE1           =  27;
C_MMTYPE2           =  28;
C_MMNO1             =  29;
C_MMNO2             =  30;


procedure ImportFactorPLU;
procedure ImportFromText;
procedure PostImport;
procedure ParseRec;
function FindNextComma(Start, MaxLen : Integer) : Integer;
procedure LogErr(ErrMsg : string);
procedure LogImport;
function  FormatRec: string;

var
  ImportFile, ImportLog, ImportErrLog : TextFile;
  ImportRec, LogRec : string;

  ImportLogName, ImportErrLogName : string;


  FldNdx: integer;
  StartPtr, CurPtr, LastPtr, MaxPtr: integer;
  StartPos: integer;
  Fld:array[1..40] of string;
  tmpImportAction   : string;
  tmpRecType        : string;
  tmpActivationDate : TDateTime;
  tmpActivationTime : TDateTime;
  tmpPLUNumber      : string;
  tmpUPCNumber      : string;
  tmpName           : string;
  tmpDeptNo         : integer;
  tmpUnitPrice      : currency;
  tmpDisc           : integer;
  tmpFS             : integer;
  tmpWIC            : integer;
  tmpTaxNo          : integer;
  tmpSplitQty       : integer;
  tmpSplitPrice     : currency;
  tmpModifierGroup  : integer;
  tmpModifierNo     : integer;
  tmpModifierName   : string;
  tmpLinkedPLU      : currency;
  tmpVendorNo       : integer;
  tmpProductGroup   : integer;
  //Build 23
  tmpItemNo         : Currency;
  tmpVendorName     : string;
  tmpPackSize       : string;
  tmpRetailPrice    : Currency;
  //Build 23

  RecNumber, GoodRecCount, BadRecCount : integer;

  ImportFileName    : string;

  PLUImportNo : integer;

  FileNameList : TStringList;


  nPLU, nUPC  : currency;

implementation

uses POSDM, POSMsg;

{-----------------------------------------------------------------------------
  Name:      ImportFactorPLU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure ImportFactorPLU;
begin
  ImportFromText;
  //PostImport;
  fmPOSMsg.Close;
end;


{-----------------------------------------------------------------------------
  Name:      ImportFromText
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure ImportFromText;
var
  FileAttrs : integer;
  sr : TSearchRec;
  path : string;
  ndx : integer;
  FileDate : integer;
  Shortname : string;
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  fmPOSMsg.ShowMsg('Reading Factor PLU Import', '');
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select Max(PLUImportNo) PLUImportNo from PLUImport');
    Open;
    PLUImportNo := FieldByName('PLUImportNo').AsInteger;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;

  ImportLogName := ExtractFileDir(Application.ExeName) + '\PLUImport\ImportChg.log';
  ImportErrLogName := ExtractFileDir(Application.ExeName) + '\PLUImport\ImportErr.log';

  AssignFile(ImportLog, ImportLogName);
  ReWrite(ImportLog);

  WriteLn(ImportLog, ImportFileName);
  WriteLn(ImportLog, 'Import Started ' + FormatDateTime('mmmm d, yyyy  hh:mm AM/PM', Now() ));

  AssignFile(ImportErrLog, ImportErrLogName);
  ReWrite(ImportErrLog);

  WriteLn(ImportErrLog, ImportFileName);
  WriteLn(ImportErrLog, 'Import Started ' + FormatDateTime('mmmm d, yyyy  hh:mm AM/PM', Now() ));



  FileNameList := TStringList.Create;
  FileNameList.Sorted := true;
  FileAttrs := 0;
  path := ExtractFileDir(Application.ExeName) + '\PLUImport\ScanData.*';
  FileAttrs := FileAttrs + faAnyFile;
  if FindFirst(path, FileAttrs, sr) = 0 then
  begin
    if (sr.Attr and FileAttrs) = sr.Attr then
    begin
      FileDate := FileAge(ExtractFileDir(Application.ExeName) + '\PLUImport\' +sr.name);
      FileNameList.Add(inttostr(FileDate)+'^'+ExtractFileDir(Application.ExeName) + '\PLUImport\' + sr.name);
    end;
    while FindNext(sr) = 0 do
    begin
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        FileDate := FileAge(ExtractFileDir(Application.ExeName) + '\PLUImport\' +sr.name);
        FileNameList.Add(inttostr(FileDate)+'^'+ExtractFileDir(Application.ExeName) + '\PLUImport\' + sr.name);
        //FileNameList.Add(inttostr(FileDate)+'^'+sr.name);
      end;
    end;
    FindClose(sr);
  end;

  if FileNameList.Count > 0 then
  begin
    for ndx := 0 to FileNameList.Count - 1 do
    begin
      ImportFileName := copy(FileNameList.Strings[ndx],pos('^',FileNameList.Strings[ndx])+1,length(FileNameList.Strings[ndx])-pos('^',FileNameList.Strings[ndx])+1);
      AssignFile(ImportFile, ImportFileName);
      {$I-}
      Reset(ImportFile);
      {$I+}
      GoodRecCount := 0;
      BadRecCount  := 0;
      RecNumber    := 0;
      if IOResult = 0 then
      begin
        ShortName := copy(ImportFileName,pos('.',ImportFileName),length(ImportFileName)-pos('.',ImportFileName)+1);
        ShortName := 'SCANDATA' + ShortName;
        fmPOSMsg.ShowMsg('Reading Factor PLU Import '+ShortName, '');
        while NOT EOF(ImportFile) do
        begin
          Readln(ImportFile, ImportRec);
          ParseRec;
          tmpImportAction    := Fld[C_IMPORTACTION];
          tmpRecType         := Fld[C_RECTYPE];

          if Fld[C_ACTIVATIONDATE] <> '' then
          try
            tmpActivationDate  := StrToDate(Fld[C_ACTIVATIONDATE])
          except
            tmpActivationDate := 0;
          end
          else
            tmpActivationDate := 0;

          if Fld[C_ACTIVATIONTIME] <> '' then
          try
            tmpActivationTime  := StrToDate(Fld[C_ACTIVATIONTIME])
          except
            tmpActivationTime := 0;
          end
          else
            tmpActivationTime := 0;

          tmpPLUNumber := Fld[C_PLUNUMBER];
          tmpUPCNumber := Fld[C_UPCNUMBER];
          tmpName := Fld[C_NAME];

          if Fld[C_DEPTNO] <> '' then
          try
            tmpDeptNo := StrToInt(Fld[C_DEPTNO]);
          except
            tmpDeptNo := 0;
          end
          else
            tmpDeptNo := 0;

          if Fld[C_UNITPRICE] <> '' then
          try
            tmpUnitPrice := StrToCurr(Fld[C_UNITPRICE]);
          except
            tmpUnitPrice := 0;
          end
          else
            tmpUnitPrice := 0;

          if Fld[C_DISC] <> '' then
          try
            tmpDisc := StrToInt(Fld[C_DISC]);
          except
            tmpDisc := 0;
          end
          else
            tmpDisc := 0;

          if Fld[C_FS] <> '' then
          try
            tmpFS := StrToInt(Fld[C_FS]);
          except
            tmpFS := 0;
          end
          else
            tmpFS := 0;

          if Fld[C_WIC] <> '' then
          try
            tmpWIC := StrToInt(Fld[C_WIC]);
          except
            tmpWIC := 0;
          end
          else
            tmpWIC := 0;

          if Fld[C_TAXNO] <> '' then
          try
            tmpTaxNo := StrToInt(Fld[C_TAXNO]);
          except
            tmpTaxNo := 0;
          end
          else
            tmpTaxNo := 0;

          if Fld[C_SPLITQTY] <> '' then
          try
            tmpSplitQty := StrToInt(Fld[C_SPLITQTY]);
          except
            tmpSplitQty := 0;
          end
          else
            tmpSplitQty := 0;

          if Fld[C_SPLITPRICE] <> '' then
          try
            tmpSplitPrice := StrToCurr(Fld[C_SPLITPRICE]);
          except
            tmpSplitPrice := 0;
          end
          else
            tmpSplitPrice := 0;

          if Fld[C_MODIFIERGROUP] <> '' then
          try
            tmpModifierGroup := StrToInt(Fld[C_MODIFIERGROUP]);
          except
            tmpModifierGroup := 0;
          end
          else
            tmpModifierGroup := 0;

          if Fld[C_MODIFIERNO] <> '' then
          try
            tmpModifierNo := StrToInt(Fld[C_MODIFIERNO]);
          except
            tmpModifierNo := 0;
          end
          else
            tmpModifierNo := 0;

          tmpModifierName := Fld[C_MODIFIERNAME];

          if Fld[C_LINKEDPLU] <> '' then
          try
            tmpLinkedPLU := StrToCurr(Fld[C_LINKEDPLU]);
          except
            tmpLinkedPLU := 0;
          end
          else
            tmpLinkedPLU := 0;

          if Fld[C_VENDORNO] <> '' then
          try
            tmpVendorNo := StrToInt(Fld[C_VENDORNO]);
          except
            tmpVendorNo := 0;
          end
          else
            tmpVendorNo := 0;

          if Fld[C_PRODUCTGROUP] <> '' then
          try
            tmpProductGroup := StrToInt(Fld[C_PRODUCTGROUP]);
          except
            tmpProductGroup := 0;
          end
          else
            tmpProductGroup := 0;

          if Fld[C_ITEMNO] <> '' then
          try
            tmpItemNo := StrToCurr(Fld[C_ITEMNO]);
          except
            tmpItemNo := 0;
          end
          else
            tmpItemNo := 0;

          try
            tmpVendorName := Fld[C_VENDORNAME];
          except
            tmpVendorName := '';
          end;

          try
            tmpPackSize := Fld[C_PACKSIZE];
          except
            tmpPackSize := '0';
          end;

          if Fld[C_RetailPrice] <> '' then
          try
            tmpRetailPrice := StrToCurr(Fld[C_RetailPrice]);
          except
            tmpRetailPrice := 0.00;
          end
          else
            tmpRetailPrice := 0.00;
                  //Build 23

          if tmpPLUNumber <> '' then
          try
            nPLU := StrToCurr(tmpPLUNumber);
          except
            nPLU := 0;
          end
          else
            nPLU := 0;

          if tmpUPCNumber <> '' then
          try
            nUPC := StrToCurr(tmpUPCNumber);
          except
            nUPC := 0;
          end
          else
            nUPC := 0;


          if (nPLU = 0) and (nUPC = 0) then
          begin
            Inc(BadRecCount);
            LogErr('PLU and UPC are Null');
          end
          else if (tmpDeptNo = 0) then
          begin
            Inc(BadRecCount);
            LogErr('Dept No is Null');
          end
          else
          begin
            Inc(GoodRecCount);
            LogImport;
            Inc(PLUImportNo);
            if not POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.StartTransaction;
            with POSDataMod.IBTempQuery do
            begin
              Close;SQL.Clear;
              SQL.Add('INSERT INTO PluImport( PLUImportNo, ImportDate, Posted, PostDate, Status, ImportAction, ');
              SQL.Add('Activationdate, ActivationTime, RecType, PLUNumber, UPCNumber, Name, ');
              SQL.Add('DeptNo, UnitPrice, SplitQty, SplitPrice, Disc, FS, WIC, TaxNo, ModifierGroup, ');
              SQL.Add('ModifierNo, ModifierName, LinkedPLU, VendorNo, ProductGroup, ');
              SQL.Add('ItemNo, VendorName, PackSize, RetailPrice)');
              SQL.Add('Values ( :pPLUImportNo, :pImportDate, :pPosted, :pPostDate, :pStatus, :pImportAction, ');
              SQL.Add(':pActivationdate, :pActivationTime, :pRecType, :pPLUNumber, :pUPCNumber, :pName, ');
              SQL.Add(':pDeptNo, :pUnitPrice, :pSplitQty, :pSplitPrice, :pDisc, :pFS, :pWIC, :pTaxNo, :pModifierGroup, ');
              SQL.Add(':pModifierNo, :pModifierName, :pLinkedPLU, :pVendorNo, :pProductGroup, ');
              SQL.Add(':pItemNo, :pVendorName, :pPackSize, :pRetailPrice) ');
              ParamByName('pPLUImportNo').AsInteger      := PLUImportNo;
              ParamByName('pImportDate').AsDateTime      := Now();
              ParamByName('pPosted').AsInteger           := 0;
              ParamByName('pPostDate').AsDateTime        := 0;
              ParamByName('pStatus').AsString            := '';
              ParamByName('pImportAction').AsString      := tmpImportAction;
              ParamByName('pActivationDate').AsDateTime  := tmpActivationDate;
              ParamByName('pActivationTime').AsDateTime  := tmpActivationTime;
              ParamByName('pRecType').AsString           := tmpRecType;
              ParamByName('pPLUNumber').AsString         := tmpPLUNumber;
              ParamByName('pUPCNumber').AsString         := tmpUPCNumber;
              ParamByName('pName').AsString              := tmpName;
              ParamByName('pDeptNo').AsInteger           := tmpProductGroup;//tmpDeptNo;
              ParamByName('pUnitPrice').AsCurrency       := tmpUnitPrice;
              ParamByName('pSplitQty').AsInteger         := tmpSplitQty;
              ParamByName('pSplitPrice').AsCurrency      := tmpSplitPrice;
              ParamByName('pDisc').AsInteger             := tmpDisc;
              ParamByName('pFS').AsInteger               := tmpFS;
              ParamByName('pWIC').AsInteger              := tmpWIC;
              ParamByName('pTaxNo').AsInteger            := tmpTaxNo;
              ParamByName('pModifierGroup').AsInteger    := tmpModifierGroup;
              ParamByName('pModifierNo').AsInteger       := tmpModifierNo;
              ParamByName('pModifierName').AsString     := tmpModifierName;
              ParamByName('pLinkedPLU').AsCurrency       := tmpLinkedPLU;
              ParamByName('pVendorNo').AsInteger         := tmpVendorNo;
              ParamByName('pProductGroup').AsInteger     := tmpDeptNo;//tmpProductGroup;
              ParamByName('pItemNo').AsCurrency          := tmpItemNo;
              ParamByName('pVendorName').AsString        := tmpVendorName;
              ParamByName('pPackSize').AsString          := tmpPackSize;
              ParamByName('pRetailPrice').AsCurrency     := tmpRetailPrice;
              //Build 23
              try
                ExecSQL;
                if POSDataMod.IBTransaction.InTransaction then
                  POSDataMod.IBTransaction.Commit;
              except
                on E : Exception do
                begin
                  if POSDataMod.IBTransaction.InTransaction then
                    POSDataMod.IBTransaction.Rollback;
                  WriteLn(ImportErrLog, 'Rollback in Import Insert' + ImportFileName);
                end;
              end;
            end;
            fmPOSMsg.ShowMsg('', IntToStr(GoodRecCount) + ' Accepted ' +  IntToStr(BadRecCount) + ' Rejected');
          end;
          Application.ProcessMessages;
        end;                       {end while not eof}

        CloseFile(ImportFile);

        try
          Erase(ImportFile);
        except
        end;

        WriteLn(ImportLog, IntToStr(GoodRecCount) + ' Records Added from ' + ImportFileName);
        WriteLn(ImportLog, 'Import Complete ' + FormatDateTime('mmmm d, yyyy  hh:mm AM/PM', Now() ));

        WriteLn(ImportErrLog, IntToStr(BadRecCount) + ' Records Excluded from ' + ImportFileName);
        WriteLn(ImportErrLog, 'Import Complete ' + FormatDateTime('mmmm d, yyyy  hh:mm AM/PM', Now() ));

        PostImport;

      end;                           { end io result }
    end;
  end;
  CloseFile(ImportLog);
  CloseFile(ImportErrLog);

end;


{-----------------------------------------------------------------------------
  Name:      FormatRec
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
function FormatRec;
begin

  Inc(RecNumber);
  FormatRec :=  'Source Rec# : ' + IntToStr(RecNumber) + ',' +
                'Action : ' + Fld[C_IMPORTACTION] + ',' +
                'Type : ' + Fld[C_RECTYPE] + ',' +
                'Activation Date: ' + Fld[C_ACTIVATIONDATE] + ',' +
                'Activation Time : ' + Fld[C_ACTIVATIONTIME] + ',' +
                'PLU Number : ' + Fld[C_PLUNUMBER] + ',' +
                'UPC Number : ' + Fld[C_UPCNUMBER] + ',' +
                'Name : ' + Fld[C_NAME] + ',' +
                'Dept No : ' + Fld[C_DEPTNO] + ',' +
                'Price : ' + Fld[C_UNITPRICE] + ',' +
                'Split Qty : ' + Fld[C_SPLITQTY] + ',' +
                'Split Price : ' + Fld[C_SPLITPRICE] + ',' +
                'Disc : ' + Fld[C_DISC] + ',' +
                'FS : ' + Fld[C_FS] + ',' +
                'WIC : ' + Fld[C_WIC] + ',' +
                'Tax No : ' + Fld[C_TAXNO] + ',' +
                'Modifier Group : ' + Fld[C_MODIFIERGROUP] + ',' +
                'Modifier No : ' + Fld[C_MODIFIERNO] + ',' +
                'Modifier Name : ' + Fld[C_MODIFIERNAME] + ',' +
                'Linked PLU : ' + Fld[C_LINKEDPLU] + ',' +
                'Vendor : ' + Fld[C_VENDORNO] + ',' +
                'Product Group : ' + Fld[C_PRODUCTGROUP] + ',' +
                'Item No : ' + Fld[C_ITEMNO] + ',' +
                'Vendor Name : ' + Fld[C_VENDORNAME] + ',' +
                'Pack Size : ' + Fld[C_PACKSIZE] + ',' +
                'Retail Price : ' + Fld[C_RETAILPRICE];


end;


{-----------------------------------------------------------------------------
  Name:      LogErr
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ErrMsg : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogErr(ErrMsg : string);
begin

  WriteLn(ImportErrLog, Copy(ErrMsg + StringOfChar(' ', 51), 1, 50) +  FormatRec);

end;


{-----------------------------------------------------------------------------
  Name:      LogImport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogImport;
begin

  WriteLn(ImportLog, FormatRec);

end;


{-----------------------------------------------------------------------------
  Name:      ParseRec
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure ParseRec;
var
  FldNdx, CurPtr : Integer;
begin
  StartPtr := 1;
  MaxPtr := ( Length(ImportRec)  );
  LastPtr := 1;
  StartPos := 1;
  for FldNdx := 1 to 40 do
  begin
    CurPtr := FindNextComma(StartPtr, MaxPtr);
    if Copy(ImportRec, StartPos, 1) = '"' then
      Fld[FldNdx] := Copy(ImportRec, StartPos + 1,((CurPtr - LastPtr ) - 2) )
    else
      Fld[FldNdx] := Copy(ImportRec,StartPos,(CurPtr - LastPtr));
    StartPos := CurPtr + 1;
    LastPtr := CurPtr + 1;
    StartPtr := CurPtr +1;
    if StartPtr > MaxPtr then break;
  end;
end;

function FindNextComma(Start, MaxLen : Integer) : Integer;
var
  CurPtr : Integer;
begin
  for CurPtr := StartPtr to MaxPtr do
  begin
    if ImportRec[CurPtr] = ',' then
      break;
  end;
  FindNextComma := CurPtr;
end;


{-----------------------------------------------------------------------------
  Name:      PostImport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PostImport;
var
PrimaryNo, SecNo : currency;
HostKey : string;
PLUFound  : currency;
//cwe  BasePrice : currency;
BaseName  : string;
CurModifierGroup : currency;
DeptFound : integer;
Status : string;
ModCount : integer;
begin
  fmPOSMsg.ShowMsg('Processing PLU Imports', ' ');
  GoodRecCount := 0;
  BadRecCount  := 0;
  if not POSDataMod.IBTempTrans2.InTransaction then
      POSDataMod.IBTempTrans2.StartTransaction;
  with POSDataMod.IBTempQuery2 do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from PLUImport Where Posted = 0 And ActivationDate <= ''Now''');
    Open;
    While NOT EOF do
    begin
      Status := 'Posted';
      HostKey   := FieldByName('PLUNumber').AsString;
      try
        PrimaryNo := StrToCurr(FieldByName('PLUNumber').AsString);
      except
        PrimaryNo := 0;
      end;

      try
        SecNo     := StrToCurr(FieldByName('UPCNumber').AsString);
      except
        SecNo     := 0;
      end;

      if PrimaryNo = 0 then
      begin
        HostKey := FieldByName('UPCNumber').AsString;
        PrimaryNo := SecNo;
        SecNo := 0;
      end;

      //Build 23
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        close;SQL.Clear;
        SQL.Add('Insert into Vendor (VendorNo, Name) ');
        SQL.Add('Values (:pVendorNo, :pName)');
        parambyname('pVendorNo').AsInteger := POSDataMod.IBTempQuery2.fieldbyname('VendorNo').AsInteger;
        parambyname('pName').AsString := copy(POSDataMod.IBTempQuery2.fieldbyname('VendorName').AsString,1,30);
        try
          ExecSQL;
        except
        end;
      end;
      //Build 23

      if POSDataMod.IBTempQuery2.FieldByName('ImportAction').AsString = 'D' then
      begin
        with POSDataMod.IBTempQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Update PLU set DelFlag = 1 Where PLUNo = :pPLUNo');
          ParamByName('pPLUNo').AsCurrency := PrimaryNo;
          ExecSQL;
        end;
      end
      else
      begin
        with POSDataMod.IBTempQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Select Count(*) DeptCount From Dept where DeptNo = :pDeptNo');
          ParamByName('pDeptNo').AsCurrency := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
            //POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
          Open;
          DeptFound := FieldByName('DeptCount').AsInteger;
          Close;
        end;
        if DeptFound = 0 then
        begin
          Status := 'Invalid Department Link';
          Inc(BadRecCount);
        end
        else
        begin
          with POSDataMod.IBTempQuery do
          begin
            Close;SQL.Clear;
            SQL.Add('Select PLUNo, Name, Price, ModifierGroup From PLU where PLUNo = :pPLUNo');
            ParamByName('pPLUNo').AsCurrency := PrimaryNo;
            Open;
            PLUFound := FieldByName('PLUNo').AsCurrency;
            //BasePrice := FieldByName('Price').AsCurrency;
            BaseName  := FieldByName('Name').AsString;
            CurModifierGroup := FieldByName('ModifierGroup').AsCurrency;
            Close;
            if PLUFound = 0 then
            begin
              if POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger = 0 then
              begin
                SQL.Clear;
                SQL.Add('INSERT INTO Plu( PLUNo, UPC, Name, ');
                SQL.Add('DeptNo, Price, SplitQty, SplitPrice, Disc, FS, WIC, TaxNo, ModifierGroup, ');
                SQL.Add('LinkedPLU, VendorNo, ProdGrpNo, ');
                SQL.Add('ItemNo, RetailPrice, HostKey)');
                SQL.Add('Values ( :pPLUNo, :pUPC, :pName, ');
                SQL.Add(':pDeptNo, :pPrice, :pSplitQty, :pSplitPrice, :pDisc, :pFS, :pWIC, :pTaxNo, :pModifierGroup, ');
                //Build 23
                //SQL.Add(':pLinkedPLU, :pVendorNo, :pProdGrpNo, :pHostKey) ');
                SQL.Add(':pLinkedPLU, :pVendorNo, :pProdGrpNo, :pItemNo, :pRetailPrice, :pHostKey) ');
                //Build 23
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pUPC').AsCurrency           := SecNo;
                ParamByName('pName').AsString            := POSDataMod.IBTempQuery2.FieldByName('Name').AsString;
                ParamByName('pDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
                  //POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                ParamByName('pPrice').AsCurrency         := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
                ParamByName('pSplitQty').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
                ParamByName('pSplitPrice').AsCurrency    := POSDataMod.IBTempQuery2.FieldByName('SplitPrice').AsCurrency;
                ParamByName('pDisc').AsInteger           := POSDataMod.IBTempQuery2.FieldByName('Disc').AsInteger;
                ParamByName('pFS').AsInteger             := POSDataMod.IBTempQuery2.FieldByName('FS').AsInteger  ;
                ParamByName('pWIC').AsInteger            := POSDataMod.IBTempQuery2.FieldByName('WIC').AsInteger;
                ParamByName('pTaxNo').AsInteger          := POSDataMod.IBTempQuery2.FieldByName('TaxNo').AsInteger;
                ParamByName('pModifierGroup').AsInteger  := 0;
                ParamByName('pLinkedPLU').AsCurrency     := POSDataMod.IBTempQuery2.FieldByName('LinkedPLU').AsCurrency;
                ParamByName('pVendorNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('VendorNo').AsInteger ;
                ParamByName('pProdGrpNo').AsInteger      := POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                //Build 23
                parambyname('pItemNo').AsCurrency        := POSDataMod.IBTempQuery2.fieldbyname('ItemNo').AsCurrency;
                parambyname('pRetailPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('RetailPrice').AsCurrency;
                //Build 23
                ParamByName('pHostKey').AsString   := HostKey;
              end
              else
              begin
                SQL.Clear;
                SQL.Add('INSERT INTO Plu( PLUNo, UPC, Name, ');
                SQL.Add('DeptNo, Price, SplitQty, SplitPrice, Disc, FS, WIC, TaxNo, ModifierGroup, ');
                SQL.Add('LinkedPLU, VendorNo, ProdGrpNo, ');   //20040908 - last comma was missing
                SQL.Add('ItemNo, RetailPrice, HostKey) ');
                SQL.Add('Values ( :pPLUNo, :pUPC, :pName, ');
                SQL.Add(':pDeptNo, :pPrice, :pSplitQty, :pSplitPrice, :pDisc, :pFS, :pWIC, :pTaxNo, :pModifierGroup, ');
                //Build 23
                //SQL.Add(':pLinkedPLU, :pVendorNo, :pProdGrpNo, :pHostKey) ');
                SQL.Add(':pLinkedPLU, :pVendorNo, :pProdGrpNo, :pItemNo, :pRetailPrice, :pHostKey) ');
                //Build 23
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pUPC').AsCurrency           := SecNo;
                ParamByName('pName').AsString            := POSDataMod.IBTempQuery2.FieldByName('Name').AsString;
                ParamByName('pDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
                  //POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                ParamByName('pPrice').AsCurrency         := 0;
                ParamByName('pSplitQty').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
                ParamByName('pSplitPrice').AsCurrency    := POSDataMod.IBTempQuery2.FieldByName('SplitPrice').AsCurrency;
                ParamByName('pDisc').AsInteger           := POSDataMod.IBTempQuery2.FieldByName('Disc').AsInteger;
                ParamByName('pFS').AsInteger             := POSDataMod.IBTempQuery2.FieldByName('FS').AsInteger  ;
                ParamByName('pWIC').AsInteger            := POSDataMod.IBTempQuery2.FieldByName('WIC').AsInteger;
                ParamByName('pTaxNo').AsInteger          := POSDataMod.IBTempQuery2.FieldByName('TaxNo').AsInteger;
                ParamByName('pModifierGroup').AsCurrency  := PrimaryNo;
                ParamByName('pLinkedPLU').AsCurrency     := POSDataMod.IBTempQuery2.FieldByName('LinkedPLU').AsCurrency;
                ParamByName('pVendorNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('VendorNo').AsInteger ;
                ParamByName('pProdGrpNo').AsInteger      := POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                //Build 23
                parambyname('pItemNo').AsCurrency        := POSDataMod.IBTempQuery2.fieldbyname('ItemNo').AsCurrency;
                parambyname('pRetailPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('RetailPrice').AsCurrency;
                //Build 23
                ParamByName('pHostKey').AsString   := HostKey;
              end;
              try
                ExecSQL;
                Inc(GoodRecCount);
              except
                on E : Exception do
                begin
                  Inc(BadRecCount);
                  //ShowMessage(E.Message);
                end;
              end;
            end
            else // PLU was found so update
            begin
              if POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger = 0 then
              begin
                SQL.Clear;
                SQL.Add('Update Plu Set Name = :pName, ');
                SQL.Add('DeptNo = :pDeptNo, Price = :pPrice, SplitQty = :pSplitQty, ');
                SQL.Add('SplitPrice = :pSplitPrice, Disc = :pDisc, FS = :pFS, WIC = :pWIC, TaxNo = :pTaxNo, ');
                //Build 23
                //SQL.Add('LinkedPLU = :pLinkedPLU, VendorNo = :pVendorNo, ProdGrpNo = :pProdGrpNo');
                SQL.Add('LinkedPLU = :pLinkedPLU, VendorNo = :pVendorNo, ProdGrpNo = :pProdGrpNo, ');
                SQL.Add('ItemNo = :pItemNo, RetailPrice = :pRetailPrice ');
                //Build 23
                SQL.Add('Where PLUNo = :pPLUNo');
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pName').AsString            := POSDataMod.IBTempQuery2.FieldByName('Name').AsString;
                ParamByName('pDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
                  //POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                ParamByName('pPrice').AsCurrency         := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
                ParamByName('pSplitQty').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
                ParamByName('pSplitPrice').AsCurrency    := POSDataMod.IBTempQuery2.FieldByName('SplitPrice').AsCurrency;
                ParamByName('pDisc').AsInteger           := POSDataMod.IBTempQuery2.FieldByName('Disc').AsInteger;
                ParamByName('pFS').AsInteger             := POSDataMod.IBTempQuery2.FieldByName('FS').AsInteger  ;
                ParamByName('pWIC').AsInteger            := POSDataMod.IBTempQuery2.FieldByName('WIC').AsInteger;
                ParamByName('pTaxNo').AsInteger          := POSDataMod.IBTempQuery2.FieldByName('TaxNo').AsInteger;
                ParamByName('pLinkedPLU').AsCurrency     := POSDataMod.IBTempQuery2.FieldByName('LinkedPLU').AsCurrency;
                ParamByName('pVendorNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('VendorNo').AsInteger ;
                //Build 23
                parambyname('pItemNo').AsCurrency        := POSDataMod.IBTempQuery2.fieldbyname('ItemNo').AsCurrency;
                parambyname('pRetailPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('RetailPrice').AsCurrency;
                //Build 23
                ParamByName('pProdGrpNo').AsInteger   := POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
              end
              else
              begin
                SQL.Clear;
                SQL.Add('Update Plu Set Name = :pName, ');
                SQL.Add('DeptNo = :pDeptNo, SplitQty = :pSplitQty, ');
                SQL.Add('SplitPrice = :pSplitPrice, Disc = :pDisc, FS = :pFS, WIC = :pWIC, TaxNo = :pTaxNo, ');
                //Build 23
                //SQL.Add('ModifierGroup = :pModifierGroup, LinkedPLU = :pLinkedPLU, VendorNo = :pVendorNo, ProdGrpNo = :pProdGrpNo');
                SQL.Add('ModifierGroup = :pModifierGroup, LinkedPLU = :pLinkedPLU, VendorNo = :pVendorNo, ');
                SQL.Add('ProdGrpNo = :pProdGrpNo, ItemNo = :pItemNo, RetailPrice = :pRetailPrice ');
                //Build 23
                SQL.Add('Where PLUNo = :pPLUNo');
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pName').AsString            := POSDataMod.IBTempQuery2.FieldByName('Name').AsString;
                ParamByName('pDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
                  //POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                ParamByName('pSplitQty').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
                ParamByName('pSplitPrice').AsCurrency    := POSDataMod.IBTempQuery2.FieldByName('SplitPrice').AsCurrency;
                ParamByName('pDisc').AsInteger           := POSDataMod.IBTempQuery2.FieldByName('Disc').AsInteger;
                ParamByName('pFS').AsInteger             := POSDataMod.IBTempQuery2.FieldByName('FS').AsInteger  ;
                ParamByName('pWIC').AsInteger            := POSDataMod.IBTempQuery2.FieldByName('WIC').AsInteger;
                ParamByName('pTaxNo').AsInteger          := POSDataMod.IBTempQuery2.FieldByName('TaxNo').AsInteger;
                ParamByName('pModifierGroup').AsCurrency := PrimaryNo;
                ParamByName('pLinkedPLU').AsCurrency     := POSDataMod.IBTempQuery2.FieldByName('LinkedPLU').AsCurrency;
                ParamByName('pVendorNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('VendorNo').AsInteger ;
                ParamByName('pProdGrpNo').AsInteger   := POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
                //Build 23
                parambyname('pItemNo').AsCurrency        := POSDataMod.IBTempQuery2.fieldbyname('ItemNo').AsCurrency;
                parambyname('pRetailPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('RetailPrice').AsCurrency;
                //Build 23
              end;
              try
                ExecSQL;
                Inc(GoodRecCount);
              except
                on E : Exception do
                begin
                  Inc(BadRecCount);
                  //ShowMessage(E.Message);
                end;
              end;
            end;


            if (CurModifierGroup > 0) then
            begin  //try to update price in PLUMod
              SQL.Clear;
              SQL.Add('Select Count(*) ModCount From PluMod ');
              SQL.Add('Where PLUNo = :pPLUNo and PLUModifier = :pPLUModifier');
              ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
              ParamByName('pPLUModifier').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger ;
              Open;
              ModCount := FieldByName('ModCount').AsInteger;
              Close;
              if ModCount = 0 then
              begin
                SQL.Clear;
                SQL.Add('Insert Into PluMod (PLUNo, PLUModifier, PLUPrice, PLUModifierGroup)');
                SQL.Add('Values (:pPLUNo, :pPLUModifier, :pPLUPrice, :pPLUModifierGroup)');
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pPLUPrice').AsCurrency      := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
                ParamByName('pPLUModifier').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
                ParamByName('pPLUModifierGroup').AsCurrency := PrimaryNo;
              end
              else
              begin
                SQL.Clear;
                SQL.Add('Update PluMod Set PLUPrice = :pPLUPrice ');
                SQL.Add('Where PLUNo = :pPLUNo and PLUModifier = :pPLUModifier');
                ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
                ParamByName('pPLUPrice').AsCurrency      := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
                ParamByName('pPLUModifier').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger ;
              end;
              try
                ExecSQL;
              except
                on E : Exception do
                begin
                  //ShowMessage('Update PLUMod ' + E.Message);
                end;
              end;
              if ModCount = 0 then
              begin
                SQL.Clear;
                SQL.Add('Insert Into Modifier (ModifierGroup, ModifierNo, ModifierName, ModifierValue, ModifierDefault)');
                SQL.Add('Values (:pModifierGroup, :pModifierNo, :pModifierName, :pModifierValue, :pModifierDefault)');
                ParamByName('pModifierGroup').AsCurrency   := PrimaryNo;
                ParamByName('pModifierNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
                ParamByName('pModifierName').AsString      := Copy(POSDataMod.IBTempQuery2.FieldByName('ModifierName').AsString, 1, 10);
                ParamByName('pModifierValue').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
                ParamByName('pModifierDefault').AsInteger  := 0;
                try
                  ExecSQL;
                except
                  on E : Exception do
                  begin
                    //ShowMessage('Insert Active Modifier ' + E.Message);
                  end;
                end;
              end
              else
              begin
                SQL.Clear;
                SQL.Add('Update Modifier Set ModifierName = :pModifierName ');
                SQL.Add('where ModifierGroup = :pModifierGroup and ModifierNo = :pModifierNo');
                ParamByName('pModifierGroup').AsCurrency   := PrimaryNo;
                ParamByName('pModifierNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
                ParamByName('pModifierName').AsString      := Copy(POSDataMod.IBTempQuery2.FieldByName('ModifierName').AsString, 1, 10);
                try
                  ExecSQL;
                except
                  on E : Exception do
                  begin
                    //ShowMessage('Insert Active Modifier ' + E.Message);
                  end;
                end;
              end;
            end
            else if (CurModifierGroup = 0) and (POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger > 0) then
            begin
              SQL.Clear;
              SQL.Add('Select ModifierName From PLUImport');
              SQL.Add('Where UPCNumber = :pUPCNumber and ModifierNo = 1');
              ParamByName('pUPCNumber').AsCurrency   := PrimaryNo;
              Open;
              if NOT EOF then
                BaseName := FieldByName('ModifierName').AsString;
              Close;
              SQL.Clear;
              SQL.Add('Insert Into ModifierGroup (ModifierGroupNo, ModifierGroupName)');
              SQL.Add('Values (:pModifierGroupNo, :pModifierGroupName)');
              ParamByName('pModifierGroupNo').AsCurrency  := PrimaryNo;
              ParamByName('pModifierGroupName').AsString  := Copy(BaseName, 1, 20);

              try
                ExecSQL;
              except
                on E : Exception do
                begin
                  //ShowMessage('Insert Modifier Group' + E.Message);
                end;
              end;
              SQL.Clear;
              SQL.Add('Insert Into Modifier (ModifierGroup, ModifierNo, ModifierName, ModifierValue, ModifierDefault)');
              SQL.Add('Values (:pModifierGroup, :pModifierNo, :pModifierName, :pModifierValue, :pModifierDefault)');
              ParamByName('pModifierGroup').AsCurrency   := PrimaryNo;
              ParamByName('pModifierNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
              ParamByName('pModifierName').AsString      := Copy(POSDataMod.IBTempQuery2.FieldByName('ModifierName').AsString, 1, 10);
              ParamByName('pModifierValue').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
              ParamByName('pModifierDefault').AsInteger  := 0;
              try
                ExecSQL;
              except
                on E : Exception do
                begin
                  //ShowMessage('Insert Active Modifier ' + E.Message);
                end;
              end;
              SQL.Clear;
              SQL.Add('Insert Into PluMod (PLUNo, PLUModifier, PLUPrice, PLUModifierGroup)');
              SQL.Add('Values (:pPLUNo, :pPLUModifier, :pPLUPrice, :pPLUModifierGroup)');
              ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
              ParamByName('pPLUPrice').AsCurrency      := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
              ParamByName('pPLUModifier').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger ;
              ParamByName('pPLUModifierGroup').AsCurrency := PrimaryNo;
              try
                ExecSQL;
              except
                on E : Exception do
                begin
                  //ShowMessage('Insert Active PLUMod ' + E.Message);
                end;
              end;
            end;
          end;
        end;
      end;

      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Update PLUImport Set Posted = 1, PostDate = ''Now'', Status = :pStatus');
        SQL.Add('Where PLUImportNo = :pPLUImportNo ');
        ParamByName('pPLUImportNo').AsInteger := POSDataMod.IBTempQuery2.FieldByName('PLUImportNo').AsInteger;
        ParamByName('pStatus').AsString := Status;
        ExecSQL;
      end;

      fmPOSMsg.ShowMsg('', IntToStr(GoodRecCount) + ' Posted ' +  IntToStr(BadRecCount) + ' Rejected');
      Application.ProcessMessages;
      Next;
    end;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if POSDataMod.IBTempTrans2.InTransaction then
    POSDataMod.IBTempTrans2.Commit;

end;

end.

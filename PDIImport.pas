{-----------------------------------------------------------------------------
 Unit Name: PDIImport
 Author:    Gary Whetton
 Date:      9/11/2003 3:09:30 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PDIImport;
{$I ConditionalCompileSymbols.txt}
interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, StrUtils, Variants;

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
{$IFDEF MULTI_TAX}
  C_TAXATTRIBOFFSET   =  20;
{$ENDIF}
  //Added for Promotion Discount types
  C_FIXED_PRICE       =  'Fix Price';
  C_DISC_PERCENT      =  'Disc Prcnt';
  C_DISC_AMOUNT       =  'Disc Amt';
  //Added for Promotion Item List Types
  C_ITEMLIST_TYPE_ITEM = 'ITEM';
  C_ITEMLIST_TYPE_DEPT = 'DEPT';

procedure ImportPDIPLU;
procedure ImportFromText;
procedure PostImport;
procedure ParseRec;
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
  tmpModifierGroup  : currency;
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
  CurrentRecType    : string;
  LastRecType       : string;
  //Build 23

  RecNumber, GoodRecCount, BadRecCount, ItemNumber : integer;

  ImportFileName    : string;

  PLUImportNo : integer;

  FileNameList : TStringList;


  nPLU, nUPC  : currency;

implementation

uses POSDM, POSMsg, Kiosk, POSMain;

var
  KioskFrame : tKioskFrame;


{-----------------------------------------------------------------------------
  Name:      ImportPDIPLU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ImportPDIPLU;
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

  FldLen : integer;
  TempAmount : double;
  TempName : string;
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  fmPOSMsg.ShowMsg('Reading PDI Import', '');
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('DELETE FROM PLUImport');   //GMM:  Clear Import log
    Open;
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
  path := ExtractFileDir(Application.ExeName) + '\PLUImport\PBDNLD.*';
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
      ItemNumber    :=0;
      if IOResult = 0 then
      begin
        ShortName := copy(ImportFileName,pos('.',ImportFileName)+1,length(ImportFileName)-pos('.',ImportFileName)+1);
        fmPOSMsg.ShowMsg('Reading PDI Import '+ShortName, '');
        LastRecType := '';
        CurrentRecType := '';
        // Locate First Item Header Record
        repeat
          Readln(ImportFile, ImportRec);
        {$IFDEF PDI_PROMOS}
        until (copy(ImportRec,1,4) = '0100') or (eof(importfile) or (copy(ImportRec,1,4) = '0110') or (copy(ImportRec,1,4) = '0117') or (copy(ImportRec,1,4) = '0120') or (copy(ImportRec,1,4) = '0121'));
        {$ELSE}
        until (copy(ImportRec,1,4) = '0100') or (eof(importfile) or (copy(ImportRec,1,4) = '0110'));
        {$ENDIF}
        while NOT EOF(ImportFile) do
        begin
          // Parse Record until another Item Header Record, a second Item Retail Record, or EOF is reached
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
            tmpModifierGroup := StrToCurr(Fld[C_MODIFIERGROUP]);
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

          If ((Fld[C_PACKSIZE] <> '') and not (VarIsNull(Fld[C_PACKSIZE]))) then
          try
            tmpPackSize := CurrtoStr(StrtoCurr(Fld[C_PACKSIZE]));
          except
            tmpPackSize := '0';
          end
          else
            tmpPackSize := '0';

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
          // GMM: Commented out exception at request of PDI
          {if (tmpRetailPrice = 0) and (FLD[C_IMPORTACTION] <> 'D') then
          begin
            inc(BadRecCount);
            LogErr('Price is 0.00');
          end
          else }
          if (nPLU = 0) and (nUPC = 0) and (FLD[C_IMPORTACTION] <> 'D') then
          begin
            Inc(BadRecCount);
            LogErr('PLU and UPC are Null');
          end
          // GMM: Commented out exception
          {else if (tmpDeptNo = 0) and (FLD[C_IMPORTACTION] <> 'D') then
          begin
            Inc(BadRecCount);
            LogErr('Dept No is Null');
          end }
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
              ParamByName('pDeptNo').AsInteger           := tmpDeptNo;
              ParamByName('pUnitPrice').AsCurrency       := tmpUnitPrice;
              ParamByName('pSplitQty').AsInteger         := tmpSplitQty;
              ParamByName('pSplitPrice').AsCurrency      := tmpSplitPrice;
              ParamByName('pDisc').AsInteger             := tmpDisc;
              ParamByName('pFS').AsInteger               := tmpFS;
              ParamByName('pWIC').AsInteger              := tmpWIC;
              ParamByName('pTaxNo').AsInteger            := tmpTaxNo;
              ParamByName('pModifierGroup').AsCurrency    := tmpModifierGroup;
              ParamByName('pModifierNo').AsInteger       := tmpModifierNo;
              ParamByName('pModifierName').AsString     := tmpModifierName;
              ParamByName('pLinkedPLU').AsCurrency       := tmpLinkedPLU;
              ParamByName('pVendorNo').AsInteger         := tmpVendorNo;
              ParamByName('pProductGroup').AsInteger     := tmpProductGroup;
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

//  Inc(RecNumber);
  FormatRec :=  'Source Rec# : ' + IntToStr(RecNumber) + ',' +
                'Item # : ' + IntToStr(ItemNumber) + ',' +
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

  if ErrMsg = 'Unhandled Record Type' then
    Writeln(ImportErrLog, Copy(ErrMsg + StringOfChar(' ', 51), 1, 50) + ImportRec)
  else
    WriteLn(ImportErrLog, Copy(ErrMsg + StringOfChar(' ', 51), 1, 50) +  FormatRec);
  inc(BadRecCount);
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
  Name:      ProcessItemHeader
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0100
-----------------------------------------------------------------------------}
procedure ProcessItemHeader;
var
  Index : integer;

begin
    For Index := 1 to 40 Do
      Fld[Index] := '';
    Fld[C_RECTYPE] := copy(ImportRec,1,4);
    Fld[C_ITEMNO] := copy(ImportRec,5,6);
    Fld[C_UPCNUMBER] := floattostr(strtofloat(copy(ImportRec,23,12)));
    Fld[C_NAME] := copy(ImportRec,35,30);
    Fld[C_IMPORTACTION] := copy(ImportRec,73,1);
end;

{-----------------------------------------------------------------------------
  Name:      ProcessItemHeaderGTIN
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0110
-----------------------------------------------------------------------------}
procedure ProcessItemHeaderGTIN;
var
  Index : integer;

begin
    For Index := 1 to 40 Do
      Fld[Index] := '';
    Fld[C_RECTYPE] := copy(ImportRec,1,4);
    Fld[C_ITEMNO] := copy(ImportRec,5,6);
    Fld[C_UPCNUMBER] := floattostr(strtofloat(copy(ImportRec,26,15)));
    Fld[C_NAME] := copy(ImportRec,41,30);
    Fld[C_IMPORTACTION] := copy(ImportRec,79,1);
end;


procedure SaveVendor (VendorNo : integer; VendorName : string);
var
  VendorFound : integer;

begin
    if (VendorNo <> 0) then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select Count(*) VendorCount From Vendor where VendorNo = :pVendorNo');
        ParamByName('pVendorNo').AsInteger := VendorNo;
        Open;
        VendorFound := FieldByName('VendorCount').AsInteger;
        Close;
        if VendorFound = 0 then
        begin
          close;SQL.Clear;
          SQL.Add('Insert into Vendor (VendorNo, Name) ');
          SQL.Add('Values (:pVendorNo, :pName)');
        end
        else
        begin
          close;SQL.Clear;
          SQL.Add('UPDATE Vendor SET Name = :pName ');
          SQL.Add('WHERE VendorNo = :pVendorNo');
        end;
        parambyname('pVendorNo').AsInteger := VendorNo;
        parambyname('pName').AsString := VendorName;
        try
          ExecSQL;
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Commit;
        except
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Rollback;
        end;
      end;
    end;
 end;

procedure SaveDept (DeptNo : integer);
var
  DeptFound : integer;

begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select Count(*) DeptCount From DEPT where DeptNo = :pDeptNo');
        ParamByName('pDeptNo').AsInteger := DeptNo;
        Open;
        DeptFound := FieldByName('DeptCount').AsInteger;
        Close;
        if ((DeptFound = 0) and (DeptNo <> 0)) then                             //20060911b (add check for DeptNo <> 0)
        begin
          close;SQL.Clear;
          SQL.Add('Insert into DEPT (DeptNo, NAME) ');
          SQL.Add('Values (:pDeptNo, ''Added from PDI Import'')');
          parambyname('pDeptNo').AsInteger := DeptNo;
          LogErr('WARNING: DEPT ' + InttoStr(DeptNo) + ' not found - Added to Dept table');
          try
            ExecSQL;
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Commit;
          except
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Rollback;
          end;
        end;
      end;
 end;

procedure SaveRestriction (DeptNo : integer; Restriction : string; RestrictionValue : string);
var
  RestrictionFound : string;
  RestrictionChange : boolean;
  RestrictionCode : integer;

begin
  if DeptNo > 0 then
  begin
      RestrictionChange := false;
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select RestrictionCode From DEPT where DeptNo = :pDeptNo');
        ParamByName('pDeptNo').AsInteger := DeptNo;
        Open;
        RestrictionFound := FieldByName('RestrictionCode').AsString;
        Close;
        if RestrictionFound = '' then
        begin
          if RestrictionValue = 'Y' then
          begin
            RestrictionChange := true;
          end;
        end
        else
        begin
          SQL.Clear;
          SQL.Add('Select Name From Restriction where RestrictionCode = :pRestrictionCode');
          ParamByName('pRestrictionCode').AsInteger := StrtoInt(RestrictionFound);
          Open;
          RestrictionChange := ((FieldByName('Name').AsString <> Restriction) AND (RestrictionValue = 'Y'));
          Close;
        end;
        if RestrictionChange then
        begin
          SQL.Clear;
          SQL.Add('Select RestrictionCode From Restriction where Name = :pRestriction');
          ParamByName('pRestriction').AsString := Restriction;
          Open;
          RestrictionCode := FieldByName('RestrictionCode').AsInteger;
          Close;
          SQL.Clear;
          SQL.Add('UPDATE DEPT SET ');
          SQL.Add('RestrictionCode = :pRestrictionCode ');
          SQL.Add('WHERE DeptNo = :pDeptNo ');
          parambyname('pRestrictionCode').AsInteger := RestrictionCode;
          parambyname('pDeptNo').AsInteger := DeptNo;
          LogErr('WARNING: DEPT ' + InttoStr(DeptNo) + ' changed Restriction for ' + Restriction);
          try
            ExecSQL;
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Commit;
          except
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Rollback;
          end;
        end;
      end;
  end;
 end;
{$IFDEF MULTI_TAX}
procedure SavePLUTax (PLUNo : String; Attribute : string; TaxValue : string; IndivTaxNo : string);
begin
  //20060911c...
  If IndivTaxNo = '' then         //Initialize New PLU TaxNos to 0
    IndivTaxNo := '0';
  If TaxValue = 'Y' then          //If a MultTax Attribute is Y, set TaxNo = 0 for Mult Tax flag
    IndivTaxNo := '0';
  //...20060911c
  if StrtoInt(IndivTaxNo) = 0 then
  begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select PLUNo From PLUTax where PLUNo = :pPLUNo and TaxNo = :pTaxNo ');
        ParamByName('pPLUNo').AsCurrency := StrtoCurr(PLUNo);
        ParamByName('pTaxNo').AsInteger := StrtoInt(RightStr(Attribute,2)) - C_TAXATTRIBOFFSET;
        Open;
        if eof then
        begin
          Close;SQL.Clear;
          if TaxValue = 'Y' then
          begin
            SQL.Add('INSERT INTO PLUTax (PLUNo, TaxNo) VALUES (:pPLUNo, :pTaxNo) ');
            ParamByName('pPLUNo').AsCurrency := StrtoCurr(PLUNo);
            ParamByName('pTaxNo').AsInteger := StrtoInt(RightStr(Attribute,2)) - C_TAXATTRIBOFFSET;
          end
        end
        else
        begin
          Close;SQL.Clear;
          if TaxValue = 'N' then
          begin
            SQL.Add('DELETE From PLUTax where PLUNo = :pPLUNo and TaxNo = :pTaxNo ');
            ParamByName('pPLUNo').AsCurrency := StrtoCurr(PLUNo);
            ParamByName('pTaxNo').AsInteger := StrtoInt(RightStr(Attribute,2)) - C_TAXATTRIBOFFSET;
          end;
        end;
        if SQL.Text <> '' then
          try
            ExecSQL;
          except
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Rollback;
          end;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
  end;
 end;
{$ENDIF}
{-----------------------------------------------------------------------------
  Name:      SignedNumberStr
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: SignedNumber  999999- , 999999+
  Result:    String with Preceding sign, if needed   -999999 , 999999
  Purpose:   Process PDI/RMS Record Format 0100
-----------------------------------------------------------------------------}
function SignedNumberStr ( SignedNumber : string) : string;

begin
  if RightStr(SignedNumber,1) = '-' then
    SignedNumberStr := '-' + Trim(LeftStr(SignedNumber, Length(SignedNumber)-1))
  else
    SignedNumberStr := Trim(LeftStr(SignedNumber, Length(SignedNumber)-1));
end;

{-----------------------------------------------------------------------------
  Name:      SignedNumberValue
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: SignedNumber  99999.9999- , 99999.9999+
  Result:    Value with Preceding sign, if needed   -99999.9999 , 99999.9999
  Purpose:   Process PDI/RMS Record Format 0100
-----------------------------------------------------------------------------}
function SignedNumberValue ( SignedNumber : string) : Currency;

begin
  if RightStr(SignedNumber,1) = '-' then
    SignedNumberValue := StrtoCurr('-' + Trim(LeftStr(SignedNumber, Length(SignedNumber)-1)))
  else
    SignedNumberValue := StrtoCurr(Trim(LeftStr(SignedNumber, Length(SignedNumber)-1)));
end;


{-----------------------------------------------------------------------------
  Name:      ProcessItemRetailPricing
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0101
-----------------------------------------------------------------------------}
procedure ProcessItemRetailPricing;
var
  TempAmount : double;
begin
    inc(ItemNumber);
    if LastRecType = CurrentRecType then
      Fld[C_RECTYPE] := copy(ImportRec,1,4);
    Fld[C_MODIFIERNO] := copy(ImportRec,11,1);
    Fld[C_MODIFIERNAME] := copy(ImportRec,19,10);
    TempAmount := strtofloat(copy(ImportRec,12,7))/1000;
    Fld[C_PACKSIZE] := floattostr(TempAmount);
    TempAmount := strtofloat(SignedNumberStr(copy(importRec,42,11)))/100;;
    Fld[C_RETAILPRICE] := floattostr(TempAmount);
    Fld[C_UNITPRICE] := floattostr(TempAmount);
    //Fld[C_SPLITQTY] := SignedNumberStr(copy(importRec,53,6));
    Fld[C_SPLITQTY] := Fld[C_PACKSIZE];
    //TempAmount := strtofloat(SignedNumberStr(copy(importRec,59,11)))/100;;
    //Fld[C_SPLITPRICE] := floattostr(TempAmount);
    Fld[C_SPLITPRICE] := Fld[C_RETAILPRICE];
    Fld[C_UPCNUMBER] := floattostr(strtofloat(copy(ImportRec,70,16)));
    Fld[C_MODIFIERGROUP] := CurrtoStr(StrtoCurr(Fld[C_ITEMNO]));
end;

{-----------------------------------------------------------------------------
  Name:      ProcessUserDefinedSupplemental
  Author:    Glen Martin
  Date:      13-Jun-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0102
-----------------------------------------------------------------------------}
procedure ProcessUserDefinedSupplemental;
var
  TempName : string;
begin
  TempName := copy(ImportRec,14,3);
  if copy(ImportRec,13,1) = 'N' then       //Numeric
  begin
    if trim(TempName) = 'L02' then
      Fld[C_TAXNO] := CurrtoStr(SignedNumberValue(copy(ImportRec,24,10))/10000)
    else if trim(TempName) = 'L03' then
      Fld[C_DEPTNO] := CurrtoStr(SignedNumberValue(copy(ImportRec,24,10))/10000)
    else if trim(TempName) = 'L04' then
      LogErr('Received Numeric data for User Defined Field 04.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L05' then
      LogErr('Received Numeric data for User Defined Field 05.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L06' then
      Fld[C_LINKEDPLU] := CurrtoStr(SignedNumberValue(copy(ImportRec,24,10))/10000)
    else if trim(TempName) = 'L07' then
      LogErr('Received Numeric data for User Defined Field 07.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L08' then
      LogErr('Received Numeric data for User Defined Field 08.  Expected Alpha (Y/N) value.')
    {$IFDEF MULTI_TAX}
    else if trim(TempName) = 'L21' then
      LogErr('Received Numeric data for User Defined Field 21.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L22' then
      LogErr('Received Numeric data for User Defined Field 22.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L23' then
      LogErr('Received Numeric data for User Defined Field 23.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L24' then
      LogErr('Received Numeric data for User Defined Field 24.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L25' then
      LogErr('Received Numeric data for User Defined Field 25.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L26' then
      LogErr('Received Numeric data for User Defined Field 26.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L27' then
      LogErr('Received Numeric data for User Defined Field 27.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L28' then
      LogErr('Received Numeric data for User Defined Field 28.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L29' then
      LogErr('Received Numeric data for User Defined Field 29.  Expected Alpha (Y/N) value.')
    else if trim(TempName) = 'L30' then
      LogErr('Received Numeric data for User Defined Field 30.  Expected Alpha (Y/N) value.')
    {$ENDIF}   ;
  end

  else if copy(ImportRec,13,1) = 'A' then  //Alpha
  begin
   if trim(TempName) = 'L02' then
      Fld[C_TAXNO] := Trim(copy(ImportRec,24,10))
    else if trim(TempName) = 'L03' then
      Fld[C_DEPTNO] := Trim(copy(ImportRec,24,10))
    else if trim(TempName) = 'L04' then
      if (Trim(copy(ImportRec,24,1)) = 'Y') then
        Fld[C_FS] := '1'
      else
        Fld[C_FS] := '0'
    else if trim(TempName) = 'L05' then
      if (Trim(copy(ImportRec,24,1)) = 'Y') then
        Fld[C_WIC] := '1'
      else
        Fld[C_WIC] := '0'
    else if trim(TempName) = 'L06' then
      Fld[C_LINKEDPLU] := Trim(copy(ImportRec,24,10))
    else if trim(TempName) = 'L07' then
      SaveRestriction(StrtoInt(Fld[C_DEPTNO]),'Spirits',Trim(copy(ImportRec,24,1)))
    else if trim(TempName) = 'L08' then
      SaveRestriction(StrtoInt(Fld[C_DEPTNO]),'Tobacco',Trim(copy(ImportRec,24,1)))
    {$IFDEF MULTI_TAX}
    else if trim(TempName) = 'L21' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L22' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L23' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L24' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L25' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L26' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L27' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L28' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L29' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'L30' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,24,1)),Fld[C_TAXNO])
    {$ENDIF}          ;
  end;
  if trim(TempName) = 'L03'  then
    SaveDept(StrtoInt(FLD[C_DEPTNO]));

end;


{-----------------------------------------------------------------------------
  Name:      ProcessItemVendorCost
  Author:    Glen Martin
  Date:      3-May-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0103
-----------------------------------------------------------------------------}
procedure ProcessItemVendorCost;
begin
    if Fld[C_VENDORNO] = '' then
      Fld[C_VENDORNO] := copy(ImportRec,11,6);
    SaveVendor(StrtoInt(copy(ImportRec,11,6)), FLD[C_VENDORNAME]);
end;

{-----------------------------------------------------------------------------
  Name:      ProcessSellUnitAttribute
  Author:    Glen Martin
  Date:      27-Apr-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0105
-----------------------------------------------------------------------------}
procedure ProcessSellUnitAttribute;
var
  FldLen : integer;
  TempName : string;
begin
  TempName := copy(ImportRec,15,8);
  FldLen := strtoint(copy(ImportRec,39,2));
  if copy(ImportRec,38,1) = 'N' then       //Numeric
  begin
    if trim(TempName) = 'LAT02' then
      Fld[C_TAXNO] := SignedNumberStr(copy(ImportRec,54-FldLen,FldLen))
    else if trim(TempName) = 'LAT03' then
      Fld[C_DEPTNO] := SignedNumberStr(copy(ImportRec,54-FldLen,FldLen))
    else if trim(TempName) = 'LAT04' then
      LogErr('Received Numeric data for attribute LAT04.  Expected Y/N value.')
    else if trim(TempName) = 'LAT05' then
      LogErr('Received Numeric data for attribute LAT05.  Expected Y/N value.')
    else if trim(TempName) = 'LAT06' then
      Fld[C_LINKEDPLU] := SignedNumberStr(copy(ImportRec,54-FldLen,FldLen))
    else if trim(TempName) = 'LAT07' then
      LogErr('Received Numeric data for attribute LAT07.  Expected Y/N value.')
    else if trim(TempName) = 'LAT08' then
      LogErr('Received Numeric data for attribute LAT08.  Expected Y/N value.')
    {$IFDEF MULTI_TAX}
    else if trim(TempName) = 'LAT21' then
      LogErr('Received Numeric data for attribute LAT21.  Expected Y/N value.')
    else if trim(TempName) = 'LAT22' then
      LogErr('Received Numeric data for attribute LAT22.  Expected Y/N value.')
    else if trim(TempName) = 'LAT23' then
      LogErr('Received Numeric data for attribute LAT23.  Expected Y/N value.')
    else if trim(TempName) = 'LAT24' then
      LogErr('Received Numeric data for attribute LAT24.  Expected Y/N value.')
    else if trim(TempName) = 'LAT25' then
      LogErr('Received Numeric data for attribute LAT25.  Expected Y/N value.')
    else if trim(TempName) = 'LAT26' then
      LogErr('Received Numeric data for attribute LAT26.  Expected Y/N value.')
    else if trim(TempName) = 'LAT27' then
      LogErr('Received Numeric data for attribute LAT27.  Expected Y/N value.')
    else if trim(TempName) = 'LAT28' then
      LogErr('Received Numeric data for attribute LAT28.  Expected Y/N value.')
    else if trim(TempName) = 'LAT29' then
      LogErr('Received Numeric data for attribute LAT29.  Expected Y/N value.')
    else if trim(TempName) = 'LAT30' then
      LogErr('Received Numeric data for attribute LAT30.  Expected Y/N value.')
    {$ENDIF}      ;
  end

  else if copy(ImportRec,38,1) = 'A' then  //Alpha
  begin
    if trim(TempName) = 'LAT02' then
      Fld[C_TAXNO] := Trim(copy(ImportRec,42,FldLen))
    else if trim(TempName) = 'LAT03' then
      Fld[C_DEPTNO] := Trim(copy(ImportRec,42,FldLen))
    else if trim(TempName) = 'LAT04' then
      LogErr('Received Alpha-numeric data for attribute LAT04.  Expected Y/N value.')
    else if trim(TempName) = 'LAT05' then
      LogErr('Received Alpha-numeric data for attribute LAT05.  Expected Y/N value.')
    else if trim(TempName) = 'LAT06' then
      Fld[C_LINKEDPLU] := Trim(copy(ImportRec,42,FldLen))
    else if trim(TempName) = 'LAT07' then
      LogErr('Received Alpha-numeric data for attribute LAT07.  Expected Y/N value.')
    else if trim(TempName) = 'LAT08' then
      LogErr('Received Alpha-numeric data for attribute LAT08.  Expected Y/N value.')
    {$IFDEF MULTI_TAX}
    else if trim(TempName) = 'LAT21' then
      LogErr('Received Alpha-numeric data for attribute LAT21.  Expected Y/N value.')
    else if trim(TempName) = 'LAT22' then
      LogErr('Received Alpha-numeric data for attribute LAT22.  Expected Y/N value.')
    else if trim(TempName) = 'LAT23' then
      LogErr('Received Alpha-numeric data for attribute LAT23.  Expected Y/N value.')
    else if trim(TempName) = 'LAT24' then
      LogErr('Received Alpha-numeric data for attribute LAT24.  Expected Y/N value.')
    else if trim(TempName) = 'LAT25' then
      LogErr('Received Alpha-numeric data for attribute LAT25.  Expected Y/N value.')
    else if trim(TempName) = 'LAT26' then
      LogErr('Received Alpha-numeric data for attribute LAT26.  Expected Y/N value.')
    else if trim(TempName) = 'LAT27' then
      LogErr('Received Alpha-numeric data for attribute LAT27.  Expected Y/N value.')
    else if trim(TempName) = 'LAT28' then
      LogErr('Received Alpha-numeric data for attribute LAT28.  Expected Y/N value.')
    else if trim(TempName) = 'LAT29' then
      LogErr('Received Alpha-numeric data for attribute LAT29.  Expected Y/N value.')
    else if trim(TempName) = 'LAT30' then
      LogErr('Received Alpha-numeric data for attribute LAT30.  Expected Y/N value.');
    {$ENDIF}      ;
  end

  else if copy(ImportRec,38,1) = 'Y' then   //Yes/No   //GMM: Added for Y/N support
  begin
    if trim(TempName) = 'LAT02' then
      Fld[C_TAXNO] := Trim(copy(ImportRec,42,1))
    else if trim(TempName) = 'LAT03' then
      Fld[C_DEPTNO] := Trim(copy(ImportRec,42,1))
    else if trim(TempName) = 'LAT04' then
      if (Trim(copy(ImportRec,42,1)) = 'Y') then
        Fld[C_FS] := '1'
      else
        Fld[C_FS] := '0'
    else if trim(TempName) = 'LAT05' then
      if (Trim(copy(ImportRec,42,1)) = 'Y') then
        Fld[C_WIC] := '1'
      else
        Fld[C_WIC] := '0'
    else if trim(TempName) = 'LAT06' then
      Fld[C_LINKEDPLU] := Trim(copy(ImportRec,42,1))
    else if trim(TempName) = 'LAT07' then
      SaveRestriction(StrtoInt(Fld[C_DEPTNO]),'Spirits',Trim(copy(ImportRec,42,1)))
    else if trim(TempName) = 'LAT08' then
      SaveRestriction(StrtoInt(Fld[C_DEPTNO]),'Tobacco',Trim(copy(ImportRec,42,1)))
    {$IFDEF MULTI_TAX}
    else if trim(TempName) = 'LAT21' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT22' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT23' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT24' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT25' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT26' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT27' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT28' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT29' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO])
    else if trim(TempName) = 'LAT30' then
      SavePLUTax(Fld[C_UPCNUMBER],trim(TempName),Trim(copy(ImportRec,42,1)),Fld[C_TAXNO]);
    {$ENDIF}      ;
  end;
  if trim(TempName) = 'LAT03' then
    SaveDept(StrtoInt(FLD[C_DEPTNO]));

end;

{-----------------------------------------------------------------------------
  Name:      ProcessItemVendorCostGTIN
  Author:    Glen Martin
  Date:      3-May-2006
  Arguments: None
  Result:    None
  Purpose:   Process PDI/RMS Record Format 0113
-----------------------------------------------------------------------------}
procedure ProcessItemVendorCostGTIN;
begin
    if Fld[C_VENDORNO] = '' then
      Fld[C_VENDORNO] := copy(ImportRec,11,6);
    SaveVendor(StrtoInt(copy(ImportRec,11,6)), FLD[C_VENDORNAME]);
end;

{$IFDEF MULTI_TAX}
  procedure ClearPLUTax(PLUNo : String);
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('DELETE FROM PLUTax Where PLUNo = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := StrtoCurr(PLUNo);
      ExecSQL;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;
{$ENDIF}
{$IFDEF PDI_PROMOS}
//20061018... Process Promotion Lists
{-----------------------------------------------------------------------------
  Name:      ProcessPromoList
  Author:    Glen Martin
  Date:      18-Oct-2006
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ProcessPromoList;
var
  CurrentRecType, LastRecType : String;
  ActionType : String;
  ListID : Currency;
  ListDesc : String;
  ListType : Integer;
//  ParentLink : Integer;

  procedure ProcessPromoListItems;
  var
    ItemID : Currency;
    ItemType : String;
    ItemModifier : string;
    ItemSellQty  : Currency;
  begin
    ItemType := '';
    ItemID := 0;
    ItemSellQty := 0.0;
    if ListType = 1 then
    begin
      ItemType := C_ITEMLIST_TYPE_ITEM;
      ItemID := StrtoCurr(copy(ImportRec,16,15));
      ItemModifier := trim(copy(ImportRec,31,10));
      ItemSellQty := strtofloat(copy(importRec,41,7))/1000;
    end
    else if ListType = 2 then
    begin
      ItemType := C_ITEMLIST_TYPE_DEPT;
      ItemID := StrtoCurr(copy(ImportRec,48,6));
    end;
    if ItemType <> '' then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        //Add list entry
        Close;SQL.Clear;
        SQL.Add('INSERT INTO PROMOLISTS (LISTNO, LISTNAME, ITEMNO, LISTTYPE, MODIFIERNAME, SELLQTY) VALUES (:pListNo, ');
        SQL.Add(':pListName, :pItemNo, :pItemType, :pItemModifier, :pItemSellQty) ');
        ParamByName('pListNo').AsCurrency := ListID;
        ParamByName('pListName').AsString := ListDesc;
        ParamByName('pItemNo').AsCurrency := ItemID;
        ParamByName('pItemType').AsString := ItemType;
        ParamByName('pItemModifier').AsString := ItemModifier;
        ParamByName('pItemSellQty').AsCurrency := ItemSellQty;
        ExecSQL;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
    end;
    while ((not eof(ImportFile)) and ((copy(ImportRec,1,4) = '0117') or (copy(ImportRec,1,4) = '0118'))) do
    begin
      Readln(ImportFile,ImportRec);
      LastRecType := CurrentRecType;
      CurrentRecType := trim(copy(ImportRec,1,4));
      if copy(ImportRec,1,4) = '0118' then
      begin
        if ActionType = 'A' then
          ProcessPromoListItems;
      end
      else if copy(ImportRec,1,4) = '0117' then
        ProcessPromoList;
    end;
  end;

begin
  CurrentRecType := trim(copy(ImportRec,1,4));
  LastRecType := '';
  ActionType := copy(ImportRec,5,1);
  ListID := StrtoCurr(copy(ImportRec,6,6));
  ListDesc := trim(copy(ImportRec,12,30));
  ListType := StrtoInt(copy(ImportRec,42,1));
//  ParentLink := StrtoInt(copy(ImportRec,43,6));
  fmPOSMsg.ShowMsg('', 'Processing Promotion List : ' +  ListDesc);
  Application.ProcessMessages;

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
//Remove existing list entries, if any
    SQL.Clear;
    SQL.Add('DELETE FROM PROMOLISTS Where ListNo = :pListNo');
    ParamByName('pListNo').AsCurrency := ListID;
    ExecSQL;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  while ((not eof(ImportFile)) and ((copy(ImportRec,1,4) = '0117') or (copy(ImportRec,1,4) = '0118'))) do
  begin
    Readln(ImportFile,ImportRec);
      LastRecType := CurrentRecType;
      CurrentRecType := trim(copy(ImportRec,1,4));
    if copy(ImportRec,1,4) = '0118' then
    begin
      if ActionType = 'A' then
        ProcessPromoListItems;
    end
    else if copy(ImportRec,1,4) = '0117' then
      ProcessPromoList;
  end;
end;
//...20061018

//20061023... Process Combo Records
{-----------------------------------------------------------------------------
  Name:      ProcessCombo
  Author:    Glen Martin
  Date:      18-Oct-2006
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ProcessCombo;
var
  CurrentRecType, LastRecType : String;
  ActionType : String;
  PromoID : Currency;
  PromoDesc : String;
  EffStartDate : TDateTime;
  EffStopDate : TDateTime;
//  StartTime : TDateTime;
  SunFlag : integer;
  SunStartTime: string;
  SunStopTime: string;
  MonFlag : integer;
  MonStartTime: string;
  MonStopTime: string;
  TueFlag : integer;
  TueStartTime: string;
  TueStopTime: string;
  WedFlag : integer;
  WedStartTime: string;
  WedStopTime: string;
  ThuFlag : integer;
  ThuStartTime: string;
  ThuStopTime: string;
  FriFlag : integer;
  FriStartTime: string;
  FriStopTime: string;
  SatFlag : integer;
  SatStartTime: string;
  SatStopTime: string;

  procedure ProcessComboDetails;
  var
//    ItemID : Currency;
//    ItemType : String;
    ListID : Currency;
    PromoTypeNum : Integer;
    PromoTypeStr : String;
    PromoPrice : Currency;
    PromoQty : Integer;
  begin
    ListID := StrtoCurr(copy(ImportRec,11,6));
    PromoQty := StrtoInt(copy(ImportRec,17,4));
    PromoTypeNum := StrtoInt(copy(ImportRec,21,1));
    if PromoTypeNum = 1 then
    begin
      PromoTypeStr := C_FIXED_PRICE; //Fixed price
      PromoPrice := strtofloat(SignedNumberStr(copy(importRec,22,11)))/100;
    end
    else if PromoTypeNum = 2 then
    begin
      PromoTypeStr := C_DISC_AMOUNT; //Discounted Price
      PromoPrice := strtofloat(SignedNumberStr(copy(importRec,37,11)))/100;
    end
    else if PromoTypeNum = 3 then
    begin
      PromoTypeStr := C_DISC_PERCENT; //Discount Percent
      PromoPrice := Strtofloat(copy(ImportRec,33,4))/100;
    end
    else
    begin
      PromoTypeStr := '';
      PromoPrice := 0;
    end;
  if ActionType = 'A' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      //Add entry
      Close;SQL.Clear;
      SQL.Add('INSERT INTO PROMOTIONS (PROMONO, LISTNO, PROMONAME, MATCHQTY, PROMOVALUE, PROMOTYPE, ');
      SQL.Add(' EFFSTARTDATE, EFFSTOPDATE, SUNFLAG, SUNSTARTTIME, SUNSTOPTIME, MONFLAG, MONSTARTTIME, MONSTOPTIME, ');
      SQL.Add('TUEFLAG, TUESTARTTIME, TUESTOPTIME, WEDFLAG, WEDSTARTTIME, WEDSTOPTIME, THUFLAG, THUSTARTTIME, THUSTOPTIME, ');
      SQL.Add('FRIFLAG, FRISTARTTIME, FRISTOPTIME, SATFLAG, SATSTARTTIME, SATSTOPTIME) ');
      SQL.Add('VALUES (:pPromoNo, :pListNo, :pPromoName, :pMatchQty, :pPromoValue, :pPromoType, ');
      SQL.Add(':pEffStartDate, :pEffStopDate, :pSunFlag, :pSunStartTime, :pSunStopTime, :pMonFlag, :pMonStartTime, :pMonStopTime, ');
      SQL.Add(':pTueFlag, :pTueStartTime, :pTueStopTime, :pWedFlag, :pWedStartTime, :pWedStopTime, ');
      SQL.Add(':pThuFlag, :pThuStartTime, :pThuStopTime, :pFriFlag, :pFriStartTime, :pFriStopTime, :pSatFlag, :pSatStartTime, :pSatStopTime) ');
      ParamByName('pPromoNo').AsCurrency := PromoID;
      ParamByName('pListNo').AsCurrency := ListID;
      ParamByName('pPromoName').AsString := PromoDesc;
      ParamByName('pMatchQty').AsInteger := PromoQty;
      ParamByName('pPromoValue').AsCurrency := PromoPrice;
      ParamByName('pPromoType').AsString := PromoTypeStr;
      ParamByName('pEffStartDate').AsDateTime := EffStartDate;
      ParamByName('pEffStopDate').AsDateTime := EffStopDate;
      ParamByName('pSunFlag').AsInteger := SunFlag;
      ParamByName('pSunStartTime').AsString := SunStartTime;
      ParamByName('pSunStopTime').AsString := SunStopTime;
      ParamByName('pMonFlag').AsInteger := MonFlag;
      ParamByName('pMonStartTime').AsString := MonStartTime;
      ParamByName('pMonStopTime').AsString := MonStopTime;
      ParamByName('pTueFlag').AsInteger := TueFlag;
      ParamByName('pTueStartTime').AsString := TueStartTime;
      ParamByName('pTueStopTime').AsString := TueStopTime;
      ParamByName('pWedFlag').AsInteger := WedFlag;
      ParamByName('pWedStartTime').AsString := WedStartTime;
      ParamByName('pWedStopTime').AsString := WedStopTime;
      ParamByName('pThuFlag').AsInteger := ThuFlag;
      ParamByName('pThuStartTime').AsString := ThuStartTime;
      ParamByName('pThuStopTime').AsString := ThuStopTime;
      ParamByName('pFriFlag').AsInteger := FriFlag;
      ParamByName('pFriStartTime').AsString := FriStartTime;
      ParamByName('pFriStopTime').AsString := FriStopTime;
      ParamByName('pSatFlag').AsInteger := SatFlag;
      ParamByName('pSatStartTime').AsString := SatStartTime;
      ParamByName('pSatStopTime').AsString := SatStopTime;
      ExecSQL;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;
  end;

begin
  CurrentRecType := trim(copy(ImportRec,1,4));
  LastRecType := '';
  ActionType := copy(ImportRec,5,1);
  PromoID := StrtoCurr(copy(ImportRec,6,6));
  PromoDesc := trim(copy(ImportRec,12,30));
  fmPOSMsg.ShowMsg('', 'Processing Combo : ' +  PromoDesc);
  Application.ProcessMessages;
  EffStartDate := StrtoDateTime(copy(ImportRec,64,2) + '/' + copy(ImportRec, 66,2) + '/' + copy(ImportRec,60,4));
  EffStopDate := StrtoDateTime(copy(ImportRec,76,2) + '/' + copy(ImportRec, 78,2) + '/' + copy(ImportRec,72,4));
  if copy(ImportRec,53,1) = 'Y' then
    SunFlag := 1
  else
    SunFlag := 0;
  SunStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  SunStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,54,1) = 'Y' then
    MonFlag := 1
  else
    MonFlag := 0;
  MonStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  MonStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,55,1) = 'Y' then
    TueFlag := 1
  else
    TueFlag := 0;
  TueStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  TueStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,56,1) = 'Y' then
    WedFlag := 1
  else
    WedFlag := 0;
  WedStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  WedStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,57,1) = 'Y' then
    ThuFlag := 1
  else
    ThuFlag := 0;
  ThuStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  ThuStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,58,1) = 'Y' then
    FriFlag := 1
  else
    FriFlag := 0;
  FriStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  FriStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if copy(ImportRec,59,1) = 'Y' then
    SatFlag := 1
  else
    SatFlag := 0;
  SatStartTime := copy(ImportRec,68,2) + ':' + copy(ImportRec, 70,2);
  SatStopTime := copy(ImportRec,80,2) + ':' + copy(ImportRec, 82,2);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
//Remove existing list entries, if any
    Close;SQL.Clear;
    SQL.Add('DELETE FROM PROMOTIONS Where PromoNo = :pPromoNo');
    ParamByName('pPromoNo').AsCurrency := PromoID;
    ExecSQL;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  while ((not eof(ImportFile)) and ((copy(ImportRec,1,4) = '0119') or (copy(ImportRec,1,4) = '0120'))) do
  begin
    Readln(ImportFile,ImportRec);
      LastRecType := CurrentRecType;
      CurrentRecType := trim(copy(ImportRec,1,4));
    if copy(ImportRec,1,4) = '0120' then
    begin
      if ActionType = 'A' then
        ProcessComboDetails;
    end
    else if copy(ImportRec,1,4) = '0119' then
      ProcessCombo;
  end;
end;
//...20061023

//20061020... Process Mix Match Records
{-----------------------------------------------------------------------------
  Name:      ProcessMixMatch
  Author:    Glen Martin
  Date:      20-Oct-2006
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ProcessMixMatch;
var
  CurrentRecType : String;
  ActionType : String;
  PromoID : Currency;
  ListID : Currency;
  PromoDesc : String;
  PromoTypeNum : Integer;
  PromoTypeStr : String;
  PromoPrice : Currency;
  PromoQty : Integer;
  EffStartDate : TDateTime;
  EffStopDate : TDateTime;
//  StartTime : TDateTime;
  SunFlag : integer;
  SunStartTime: string;
  SunStopTime: string;
  MonFlag : integer;
  MonStartTime: string;
  MonStopTime: string;
  TueFlag : integer;
  TueStartTime: string;
  TueStopTime: string;
  WedFlag : integer;
  WedStartTime: string;
  WedStopTime: string;
  ThuFlag : integer;
  ThuStartTime: string;
  ThuStopTime: string;
  FriFlag : integer;
  FriStartTime: string;
  FriStopTime: string;
  SatFlag : integer;
  SatStartTime: string;
  SatStopTime: string;

begin
  CurrentRecType := trim(copy(ImportRec,1,4));
  ActionType := copy(ImportRec,5,1);
  PromoID := StrtoCurr(copy(ImportRec,6,6));
  PromoDesc := trim(copy(ImportRec,12,30));
  fmPOSMsg.ShowMsg('', 'Processing Mix Match : ' +  PromoDesc);
  Application.ProcessMessages;
  ListID := StrtoCurr(copy(ImportRec,52,6));
  PromoQty := StrtoInt(copy(ImportRec,89,4));
  PromoTypeNum := StrtoInt(copy(ImportRec,93,1));
  if PromoTypeNum = 1 then
  begin
    PromoTypeStr := C_FIXED_PRICE; //Fixed price
    PromoPrice := strtofloat(SignedNumberStr(copy(importRec,94,11)))/100;
  end
  else if PromoTypeNum = 2 then
  begin
    PromoTypeStr := C_DISC_AMOUNT; //Discounted Price
    PromoPrice := strtofloat(SignedNumberStr(copy(importRec,109,11)))/100;
  end
  else if PromoTypeNum =3 then
  begin
    PromoTypeStr := C_DISC_PERCENT; //Discount Percent
    PromoPrice := Strtofloat(copy(ImportRec,105,4))/100;
  end
  else
  begin
    PromoTypeStr := '';
    PromoPrice := 0;
  end;
  EffStartDate := StrtoDateTime(copy(ImportRec,62,2) + '/' + copy(ImportRec, 64,2) + '/' + copy(ImportRec,58,4));
  EffStopDate := StrtoDateTime(copy(ImportRec,74,2) + '/' + copy(ImportRec, 76,2) + '/' + copy(ImportRec,70,4));
  if copy(ImportRec,82,1) = 'Y' then
    SunFlag := 1
  else
    SunFlag := 0;
  SunStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  SunStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,83,1) = 'Y' then
    MonFlag := 1
  else
    MonFlag := 0;
  MonStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  MonStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,84,1) = 'Y' then
    TueFlag := 1
  else
    TueFlag := 0;
  TueStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  TueStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,85,1) = 'Y' then
    WedFlag := 1
  else
    WedFlag := 0;
  WedStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  WedStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,86,1) = 'Y' then
    ThuFlag := 1
  else
    ThuFlag := 0;
  ThuStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  ThuStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,87,1) = 'Y' then
    FriFlag := 1
  else
    FriFlag := 0;
  FriStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  FriStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);
  if copy(ImportRec,88,1) = 'Y' then
    SatFlag := 1
  else
    SatFlag := 0;
  SatStartTime := copy(ImportRec,66,2) + ':' + copy(ImportRec, 68,2);
  SatStopTime := copy(ImportRec,78,2) + ':' + copy(ImportRec, 80,2);

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
//Remove existing entries, if any
    Close;SQL.Clear;
    SQL.Add('DELETE FROM PROMOTIONS Where PromoNo = :pPromoNo');
    ParamByName('pPromoNo').AsCurrency := PromoID;
    ExecSQL;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if ActionType = 'A' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      //Add entry
      Close;SQL.Clear;
      SQL.Add('INSERT INTO PROMOTIONS (PROMONO, LISTNO, PROMONAME, MATCHQTY, PROMOVALUE, PROMOTYPE, ');
      SQL.Add(' EFFSTARTDATE, EFFSTOPDATE, SUNFLAG, SUNSTARTTIME, SUNSTOPTIME, MONFLAG, MONSTARTTIME, MONSTOPTIME, ');
      SQL.Add('TUEFLAG, TUESTARTTIME, TUESTOPTIME, WEDFLAG, WEDSTARTTIME, WEDSTOPTIME, THUFLAG, THUSTARTTIME, THUSTOPTIME, ');
      SQL.Add('FRIFLAG, FRISTARTTIME, FRISTOPTIME, SATFLAG, SATSTARTTIME, SATSTOPTIME) ');
      SQL.Add('VALUES (:pPromoNo, :pListNo, :pPromoName, :pMatchQty, :pPromoValue, :pPromoType, ');
      SQL.Add(':pEffStartDate, :pEffStopDate, :pSunFlag, :pSunStartTime, :pSunStopTime, :pMonFlag, :pMonStartTime, :pMonStopTime, ');
      SQL.Add(':pTueFlag, :pTueStartTime, :pTueStopTime, :pWedFlag, :pWedStartTime, :pWedStopTime, ');
      SQL.Add(':pThuFlag, :pThuStartTime, :pThuStopTime, :pFriFlag, :pFriStartTime, :pFriStopTime, :pSatFlag, :pSatStartTime, :pSatStopTime) ');
      ParamByName('pPromoNo').AsCurrency := PromoID;
      ParamByName('pListNo').AsCurrency := ListID;
      ParamByName('pPromoName').AsString := PromoDesc;
      ParamByName('pMatchQty').AsInteger := PromoQty;
      ParamByName('pPromoValue').AsCurrency := PromoPrice;
      ParamByName('pPromoType').AsString := PromoTypeStr;
      ParamByName('pEffStartDate').AsDateTime := EffStartDate;
      ParamByName('pEffStopDate').AsDateTime := EffStopDate;
      ParamByName('pSunFlag').AsInteger := SunFlag;
      ParamByName('pSunStartTime').AsString := SunStartTime;
      ParamByName('pSunStopTime').AsString := SunStopTime;
      ParamByName('pMonFlag').AsInteger := MonFlag;
      ParamByName('pMonStartTime').AsString := MonStartTime;
      ParamByName('pMonStopTime').AsString := MonStopTime;
      ParamByName('pTueFlag').AsInteger := TueFlag;
      ParamByName('pTueStartTime').AsString := TueStartTime;
      ParamByName('pTueStopTime').AsString := TueStopTime;
      ParamByName('pWedFlag').AsInteger := WedFlag;
      ParamByName('pWedStartTime').AsString := WedStartTime;
      ParamByName('pWedStopTime').AsString := WedStopTime;
      ParamByName('pThuFlag').AsInteger := ThuFlag;
      ParamByName('pThuStartTime').AsString := ThuStartTime;
      ParamByName('pThuStopTime').AsString := ThuStopTime;
      ParamByName('pFriFlag').AsInteger := FriFlag;
      ParamByName('pFriStartTime').AsString := FriStartTime;
      ParamByName('pFriStopTime').AsString := FriStopTime;
      ParamByName('pSatFlag').AsInteger := SatFlag;
      ParamByName('pSatStartTime').AsString := SatStartTime;
      ParamByName('pSatStopTime').AsString := SatStopTime;
      ExecSQL;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;
  while ((not eof(ImportFile)) and (copy(ImportRec,1,4) = '0121')) do
  begin
    Readln(ImportFile,ImportRec);
      LastRecType := CurrentRecType;
      CurrentRecType := trim(copy(ImportRec,1,4));
    if copy(ImportRec,1,4) = '0121' then
    begin
      ProcessMixMatch;
    end;
  end;
end;
{$ENDIF}
//...20061020

{-----------------------------------------------------------------------------
  Name:      ParseRec
  Author:    Glen Martin
  Date:      23-Apr-2006
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ParseRec;

begin
  CurrentRecType := trim(copy(ImportRec,1,4));
  Repeat
    inc(RecNumber);
    if CurrentRecType = '0100' then
    begin
      ProcessItemHeader;
      {$IFDEF MULTI_TAX}
      ClearPLUTax(FLD[C_UPCNUMBER]);
      {$ENDIF}
    end
    else if CurrentRecType = '0101' then
      ProcessItemRetailPricing
    else if CurrentRecType = '0102' then
    begin
      if Fld[C_ImportAction] <> 'D' then
        ProcessUserDefinedSupplemental;
    end
    else if CurrentRecType = '0103' then
      ProcessItemVendorCost
    else if CurrentRecType = '0105' then
      ProcessSellUnitAttribute
    else if CurrentRecType = '0110' then
    begin
      ProcessItemHeaderGTIN;
      {$IFDEF MULTI_TAX}
      ClearPLUTax(FLD[C_UPCNUMBER]);
      {$ENDIF}
    end
    else if CurrentRecType = '0113' then
      ProcessItemVendorCostGTIN
//20061018... Process Promo Lists
    {$IFDEF PDI_PROMOS}
    else if CurrentRecType = '0117' then
    begin
      ProcessPromoList;
    end
    else if CurrentRecType = '0119' then
    begin
      ProcessCombo;
    end
    else if CurrentRecType = '0121' then
    begin
      ProcessMixMatch;
    end
    {$ENDIF}
    else
    begin
      Fld[C_RECTYPE] := CurrentRecType;
      LogErr('Unhandled Record Type');
      {$IFNDEF PDI_PROMOS}
      CurrentRecType := LastRecType;
      {$ENDIF}
    end;
    {$IFDEF PDI_PROMOS}
    if ((eof(ImportFile)) and ((CurrentRecType <> '0117') and (CurrentRecType <> '0119'))) then
      CurrentRecType := ''
    else
    begin
      //Read the next record unless a Promo List, Mix Match, or Combo was just processed
      If ((CurrentRecType <> '0117') and (CurrentRecType <> '0121') and (CurrentRecType <> '0119')) then
        Readln(ImportFile,ImportRec);
      LastRecType := CurrentRecType;
    {$ELSE}
    Readln(ImportFile,ImportRec);
    LastRecType := CurrentRecType;
    if eof(ImportFile) then
      CurrentRecType := ''
    else
    {$ENDIF}
      CurrentRecType := trim(copy(ImportRec,1,4));
  {$IFDEF PDI_PROMOS}
    end;
  Until ((CurrentRecType = '') or ((CurrentRecType = '0100') and (LastRecType <> '0119')) or (CurrentRecType = '0110') or ((CurrentRecType = '0101') and (LastRecType <> '0100') and (LastRecType <> '0110')));
  {$ELSE}
  Until ((CurrentRecType = '0100') or (CurrentRecType = '0110') or ((CurrentRecType = '0101') and ((LastRecType <> '0100') and (LastRecType <> '0110'))) or (eof(ImportFile)));
  {$ENDIF}
//...20061018
end;


{-----------------------------------------------------------------------------
  Name:      PostImport
  Author:    Glen Martin
  Date:      1-May-2006
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PostImport;

var
  Status : string;
  HostKey : string;
  PrimaryNo, SecNo : currency;

  procedure SetPLUKeys;
  begin
      HostKey   := '';
      PrimaryNo := 0;
      SecNo := 0;
      if POSDataMod.IBTempQuery2.FieldByName('PLUNumber').AsString = '' then
        PrimaryNo := 0
      else
        try
          PrimaryNo := StrToCurr(POSDataMod.IBTempQuery2.FieldByName('PLUNumber').AsString);
        except
          PrimaryNo := 0;
        end;

      try
        SecNo     := StrToCurr(POSDataMod.IBTempQuery2.FieldByName('UPCNumber').AsString);
      except
        SecNo     := 0;
      end;

      if PrimaryNo = 0 then
      begin
        PrimaryNo := SecNo;
        //SecNo := 0;
      end;
      HostKey := CurrtoStr(PrimaryNo);

  end;

  procedure DeletePLU;
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Update PLU set DelFlag = 1 Where PLUNo = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := PrimaryNo;
      ExecSQL;
      Status := 'PLU Deleted';
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;

  procedure ValidateDepartment (DeptNo : Integer);
  var
    DeptFound : integer;

  begin
        if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBTempQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Select Count(*) DeptCount From Dept where DeptNo = :pDeptNo');
          ParamByName('pDeptNo').AsCurrency := DeptNo;
          Open;
          DeptFound := FieldByName('DeptCount').AsInteger;
          Close;
        end;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        if DeptFound = 0 then
        begin
          Status := 'Invalid Department Link';
          Inc(BadRecCount);
        end;
  end;

  procedure SavePLU;
  var
    PLUFound  : currency;
    BaseName  : string;
    //20071107f... (moved to unit POSMain)
//    procedure UpdateKioskPrice(PLUNo : currency; PLUPrice : currency; DeptNo : integer; ModifierNo : integer);
//    begin
//      //If Kiosk qualified item
////      if ((DeptNo >= 60) and (DeptNo <=80) and (ModifierNo = 0)) then
////20070621c Changed to accommodate single Item modifiers
//      if ((DeptNo >= 60) and (DeptNo <=80) and (ModifierNo <= 1)) then
//      begin
//        //Update Kiosk Store database with current price
//        try
//          with POSDataMod.KioskOrderQry do
//          begin
//            Close;SQL.Clear;
//            ConnectionString := fmPOS.BuildKioskConnectionString;
//            SQL.Add('UPDATE tblMenuItems ');
//            SQL.Add('SET mi_Price = ' + CurrtoStr(PLUPrice) +  ', mi_DisplayPrice = ' + CurrtoStr(PLUPrice) + ' ');
//            SQL.Add('WHERE mi_Number = ''' + CurrtoStr(PLUNo) + ''' AND mi_Class_ID = 1');
//            ExecSQL;
//            Close;
//          end
//        except
//        end;
//      end;
//    end;
    //...20071107f

  begin
    //20070226... Do not save PLUs with 0 unit prices
    if POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency > 0 then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select PLUNo, Name From PLU where PLUNo = :pPLUNo');
        ParamByName('pPLUNo').AsCurrency := PrimaryNo;
        Open;
        PLUFound := FieldByName('PLUNo').AsCurrency;
        BaseName  := FieldByName('Name').AsString;
        Close;
        SQL.Clear;
        if PLUFound = 0 then
        begin
          SQL.Add('INSERT INTO Plu( PLUNo, UPC, Name, ');
          SQL.Add('DeptNo, Price, SplitQty, SplitPrice, Disc, FS, WIC, TaxNo, ModifierGroup, ');
          SQL.Add('LinkedPLU, VendorNo, ProdGrpNo, ');
          SQL.Add('ItemNo, RetailPrice, HostKey, PackSize)');
          SQL.Add('Values ( :pPLUNo, :pUPC, :pName, ');
          SQL.Add(':pDeptNo, :pPrice, :pSplitQty, :pSplitPrice, :pDisc, :pFS, :pWIC, :pTaxNo, :pModifierGroup, ');
          SQL.Add(':pLinkedPLU, :pVendorNo, :pProdGrpNo, :pItemNo, :pRetailPrice, :pHostKey, :pPackSize) ');
        end
        else
        begin
          SQL.Add('Update Plu Set Name = :pName, ');
          SQL.Add('DeptNo = :pDeptNo, Price = :pPrice, SplitQty = :pSplitQty, ');
          SQL.Add('SplitPrice = :pSplitPrice, Disc = :pDisc, FS = :pFS, WIC = :pWIC, TaxNo = :pTaxNo, ');
          SQL.Add('ModifierGroup = :pModifierGroup, LinkedPLU = :pLinkedPLU, VendorNo = :pVendorNo, ProdGrpNo = :pProdGrpNo, ');
          SQL.Add('ItemNo = :pItemNo, RetailPrice = :pRetailPrice, HostKey = :pHostKey, PackSize = :pPacksize ');
          SQL.Add('Where PLUNo = :pPLUNo and UPC = :pUPC');
        end;
        ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
        ParamByName('pUPC').AsCurrency           := SecNo;
        ParamByName('pName').AsString            := POSDataMod.IBTempQuery2.FieldByName('Name').AsString;
        ParamByName('pDisc').AsInteger           := POSDataMod.IBTempQuery2.FieldByName('Disc').AsInteger;
        ParamByName('pFS').AsInteger             := POSDataMod.IBTempQuery2.FieldByName('FS').AsInteger  ;
        ParamByName('pWIC').AsInteger            := POSDataMod.IBTempQuery2.FieldByName('WIC').AsInteger;
        ParamByName('pTaxNo').AsInteger          := POSDataMod.IBTempQuery2.FieldByName('TaxNo').AsInteger;
        if POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger <= 1 then
        begin
          ParamByName('pDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
          ParamByName('pModifierGroup').AsInteger  := 0;
          ParamByName('pPrice').AsCurrency         := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
          parambyname('pPackSize').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('Packsize').AsCurrency;
          ParamByName('pSplitQty').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
          ParamByName('pSplitPrice').AsCurrency    := POSDataMod.IBTempQuery2.FieldByName('SplitPrice').AsCurrency;
        end
        else
        begin
          ParamByName('pDeptNo').AsInteger         := 0;
          ParamByName('pModifierGroup').AsCurrency  := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
          ParamByName('pPrice').AsCurrency         := 0;
          parambyname('pPackSize').AsCurrency   := 0;
          ParamByName('pSplitQty').AsInteger       := 0;
          ParamByName('pSplitPrice').AsCurrency    := 0;
        end;
        ParamByName('pLinkedPLU').AsCurrency     := POSDataMod.IBTempQuery2.FieldByName('LinkedPLU').AsCurrency;
        ParamByName('pVendorNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('VendorNo').AsInteger ;
        ParamByName('pProdGrpNo').AsInteger      := POSDataMod.IBTempQuery2.FieldByName('ProductGroup').AsInteger;
        parambyname('pItemNo').AsCurrency        := POSDataMod.IBTempQuery2.fieldbyname('ItemNo').AsCurrency;
        parambyname('pRetailPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('RetailPrice').AsCurrency;
        ParamByName('pHostKey').AsString   := HostKey;
        try
          ExecSQL;
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Commit;
          Inc(GoodRecCount);
        except
          on E : Exception do
          begin
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Rollback;
            Status := 'Error saving PLU record';
            Inc(BadRecCount);
          end;
        end;
        //20071107f... (moved to unit POSMain)
////        if ((Status <> 'Error saving PLU record') and (KioskFrame.KioskActive)) then
//        if ((Status <> 'Error saving PLU record') and (bKioskActive)) then
//        begin
//          UpdateKioskPrice(PrimaryNo,POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency,POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger,POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger);
//        end;
        //...20071107f
      end;
    end
    else
    begin
      Status := 'Invalid PLU:  Price = 0.00';
      Inc(BadRecCount);
    end;
    //...20070226
  end;

  procedure UpdateModifierPrice (UPCNumber : string);
  var
    BaseName  : string;
    HasModifier : boolean;

  begin
    if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
    with POSDataMod.IBTempQry1 do
    begin
      close;SQL.Clear;
      HasModifier := false;
      SQL.Add('Select count(*) as ModifierCount from PLUImport where ModifierNo > 1 ');
      SQL.Add('and UPCNumber = :pUPCNumber');
      parambyname('pUPCNumber').AsString := UPCNumber;
      open;
      if fieldbyname('ModifierCount').AsInteger > 0 then
        HasModifier := true;
      close;
    end;
    if HasModifier then
    begin
      with POSDataMod.IBTempQry1 do
      begin
        SQL.Clear;
        SQL.Add('Select Name From PLUImport');
        SQL.Add('Where UPCNumber = :pUPCNumber and ModifierNo = 1');
        ParamByName('pUPCNumber').AsString   := currtostr(PrimaryNo);
        Open;
        if NOT EOF then
          BaseName := FieldByName('Name').AsString;
        Close;
        SQL.Clear;
        SQL.Add('Select ModifierGroupNo From ModifierGroup');
        SQL.Add('Where ModifierGroupNo = :pModifierGroupNo');
        ParamByName('pModifierGroupNo').AsCurrency  := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
        Open;
        if EOF then
        begin
          Close;
          SQL.Clear;
          SQL.Add('Insert Into ModifierGroup (ModifierGroupNo, ModifierGroupName)');
          SQL.Add('Values (:pModifierGroupNo, :pModifierGroupName)');
        end
        else
        begin
          Close;
          SQL.Clear;
          SQL.Add('UPDATE ModifierGroup SET ModifierGroupName = :pModifierGroupName');
          SQL.Add('WHERE (ModifierGroupNo = :pModifierGroupNo)');
        end;
        ParamByName('pModifierGroupNo').AsCurrency  := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
        ParamByName('pModifierGroupName').AsString  := Copy(BaseName, 1, 20);

        try
          ExecSQL;
          if POSDataMod.IBTempTrans1.InTransaction then
            POSDataMod.IBTempTrans1.Commit;
        except
          on E : Exception do
          begin
            if POSDataMod.IBTempTrans1.InTransaction then
              POSDataMod.IBTempTrans1.Rollback;
          end;
        end;
      end;
      if not POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.StartTransaction;
      with POSDataMod.IBTempQry1 do
      begin
        SQL.Clear;
        SQL.Add('Select ModifierNo From Modifier');
        SQL.Add('Where ModifierGroup = :pModifierGroup and ModifierNo = :pModifierNo');
        ParamByName('pModifierGroup').AsCurrency  := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
        ParamByName('pModifierNo').AsInteger  := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
        Open;
        if EOF then
        begin
          Close;
          SQL.Clear;
          SQL.Add('Insert Into Modifier (ModifierGroup, ModifierNo, ModifierName, ModifierValue, ModifierDefault)');
          SQL.Add('Values (:pModifierGroup, :pModifierNo, :pModifierName, :pModifierValue, :pModifierDefault)');
        end
        else
        begin
          Close;
          SQL.Clear;
          SQL.Add('UPDATE Modifier SET ModifierName = :pModifierName, ModifierValue = :pModifierValue,');
          SQL.Add(' ModifierDefault = :pModifierDefault');
          SQL.Add('WHERE (ModifierGroup = :pModifierGroup and ModifierNo = :pModifierNo)');
        end;
        ParamByName('pModifierGroup').AsCurrency   := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
        ParamByName('pModifierNo').AsInteger       := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
        ParamByName('pModifierName').AsString      := Copy(POSDataMod.IBTempQuery2.FieldByName('ModifierName').AsString, 1, 10);
        ParamByName('pModifierValue').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
        ParamByName('pModifierDefault').AsInteger  := 0;
        try
          ExecSQL;
          if POSDataMod.IBTempTrans1.InTransaction then
            POSDataMod.IBTempTrans1.Commit;
        except
          on E : Exception do
          begin
            if POSDataMod.IBTempTrans1.InTransaction then
              POSDataMod.IBTempTrans1.Rollback;
          end;
        end;
      end;
      if not POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.StartTransaction;
      with POSDataMod.IBTempQry1 do
      begin
        SQL.Clear;
        SQL.Add('Select PLUNo From PLUMod');
        SQL.Add('Where PLUModifier = :pModifierNo and PLUNo = :pPLUNo');
        ParamByName('pPLUNo').AsCurrency  := PrimaryNo;
        ParamByName('pModifierNo').AsInteger  := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger;
        Open;
        if EOF then
        begin
          Close;
          SQL.Clear;
          SQL.Add('Insert Into PluMod (PLUNo, PLUModifier, PLUPrice, PLUModifierGroup, PackSize, DeptNo, SplitQty, SplitPrice)');
          SQL.Add('Values (:pPLUNo, :pPLUModifier, :pPLUPrice, :pPLUModifierGroup, :pPLUPackSize, :pPLUDeptNo, :pPLUSplitQty, :pPLUSplitPrice)');
        end
        else
        begin
          Close;
          SQL.Clear;
          SQL.Add('Update PluMod Set PLUPrice = :pPLUPrice, PackSize = :pPLUPackSize, DeptNo = :pPLUDeptNo, PLUModifierGroup = :pPLUModifierGroup, SplitQty = :pPLUSplitQty, SplitPrice = :pPLUSplitPrice ');
          SQL.Add('Where PLUNo = :pPLUNo and PLUModifier = :pPLUModifier');
        end;
        ParamByName('pPLUNo').AsCurrency         := PrimaryNo;
        ParamByName('pPLUPrice').AsCurrency      := POSDataMod.IBTempQuery2.FieldByName('UnitPrice').AsCurrency;
        ParamByName('pPLUModifier').AsInteger    := POSDataMod.IBTempQuery2.FieldByName('ModifierNo').AsInteger ;
        ParamByName('pPLUModifierGroup').AsCurrency := POSDataMod.IBTempQuery2.FieldByName('ModifierGroup').AsCurrency;
        parambyname('pPLUPackSize').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('Packsize').AsCurrency;
        ParamByName('pPLUDeptNo').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('DeptNo').AsInteger;
        parambyname('pPLUSplitPrice').AsCurrency   := POSDataMod.IBTempQuery2.fieldbyname('SplitPrice').AsCurrency;
        ParamByName('pPLUSplitQty').AsInteger         := POSDataMod.IBTempQuery2.FieldByName('SplitQty').AsInteger;
        try
          ExecSQL;
          if POSDataMod.IBTempTrans1.InTransaction then
            POSDataMod.IBTempTrans1.Commit;
        except
          on E : Exception do
          begin
            if POSDataMod.IBTempTrans1.InTransaction then
              POSDataMod.IBTempTrans1.Rollback;
          end;
        end;
      end;
    end;
  end;

  procedure UpdateProcessingStatus (PLUImportNo : Integer);
  begin
      if Status = 'Processing' then
        Status := 'Posted';
      if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Update PLUImport Set Posted = 1, PostDate = ''Now'', Status = :pStatus');
        SQL.Add('Where PLUImportNo = :pPLUImportNo ');
        ParamByName('pPLUImportNo').AsInteger := PLUImportNo;
        ParamByName('pStatus').AsString := Status;
        ExecSQL;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
      end;

      fmPOSMsg.ShowMsg('', IntToStr(GoodRecCount) + ' Posted ' +  IntToStr(BadRecCount) + ' Rejected');
      Application.ProcessMessages;

  end;

begin

  fmPOSMsg.ShowMsg('Processing PLU Imports', ' ');
  GoodRecCount := 0;
  BadRecCount  := 0;
  if not POSDataMod.IBTempTrans2.InTransaction then
      POSDataMod.IBTempTrans2.StartTransaction;
  with POSDataMod.IBTempQuery2 do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * from PLUImport Where Posted = 0 And ActivationDate <= ''Now''');
    Open;
    While NOT EOF do
    begin
      Status := 'Processing';
      SetPLUKeys;
      if FieldByName('ImportAction').AsString = 'D' then
        DeletePLU
      else //Add or update
      begin
        ValidateDepartment (FieldByName('DeptNo').AsInteger);
        if Status = 'Processing' then
        begin
          SavePLU;
          if Status = 'Processing' then
            UpdateModifierPrice (fieldbyname('UPCNumber').AsString);
        end;
      end;
      UpdateProcessingStatus (FieldByName('PLUImportNo').AsInteger);
      Next;
    end;
  end;
  POSDataMod.IBTempQuery2.Close;
  if POSDataMod.IBTempTrans2.InTransaction then
      POSDataMod.IBTempTrans2.Commit;

end;

end.

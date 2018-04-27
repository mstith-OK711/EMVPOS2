{-----------------------------------------------------------------------------
 Unit Name: PDIEx
 Author:    Gary Whetton
 Date:      9/11/2003 3:08:29 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PDIEx;
{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, POSDM, DB, FileCtrl;

const
  cDel: Char = ',';

type

  pSRec = ^TSRec;
  TSRec = record
    TlType     : short;     // 1 = Store, 2 = Register, 3 = Shift
    PDIVal     : string[6];
    DataVal    : currency;
  end;

  //20070321... Changed Double to Currency to avoid type conflicts
  pPLUSalesRec = ^TPLUSalesRec;
  TPLUSalesRec = record
    PLUNo : Currency;
    PackSize : Currency;
    QtySold : Currency;
    UnitCost : Currency;
    UnitRetail : Currency;
    ExtRetail : Currency;
    ItemDesc : String;
    PromoID : Integer;
  end;
  //...20070321

var
  SRec     : pSRec;
  SRecList : TList;

  PLUSalesRec : pPLUSalesRec;
  PLUSalesList : TList;

  sFname           : String;
  TF               : TextFile;
  nCurFuelTlID     : Integer;
  nPrevFuelTlID    : Integer;
  OpenDate         : TDateTime;
  Year, Month, Day : Word;

  aCurGradeTls     : array[1..20,1..2] of Currency;
  aPrevGradeTls    : array[1..20,1..2] of Currency;

  nHIdx, nCurPump: Integer;
  nPct : double;
  sLn: shortstring;

  nTlType : short;

  sTableName, sFieldName, sKeyVal : string;
  sPDICountVal, sLookUpPDICountVal, sPDIVal, sLookUpPDIVal : string;
  sPDIAmountVal, sLookUpPDIAmountVal : string;
  sDataType : short;

  ndx, idx : short;

  sShiftNo : string;


  sName : array[1..12] of string[6];   //GMM:  Expanded to 12 for Type 2202 Transaction Records
  cData : array[1..12] of currency;

  bFound : boolean;
  nDataType : short;
  cUpdateVal1 : currency;
  cUpdateVal2 : currency;
  i : short;

  maxndx : short;
  cnt : integer;
  PLUFound : boolean;

procedure CreatePDIExportFile (TerminalNo : Integer; ShiftNo : Integer; OpName : String);


implementation

uses POSMain, POSMsg, StrUtils, DateUtils, Math;

{$IFDEF PDI_PROMOS}
function ComputePLUPromoQty(TransactionNo : Currency; PLUNo : Currency;PromoNo : Currency;PLUName : String;SoldQty : Currency) : Currency;
var
  TempQty : Currency;

begin
  if not POSDataMod.IBTempTrans2.InTransaction then
    POSDataMod.IBTempTrans2.StartTransaction;
  with POSDataMod.IBTempQuery2 do
  begin
    Close;SQL.Clear;
    SQL.Add('Select MatchQty, r.qty ');
    SQL.Add('from promotions p inner join receipt r on p.promono = r.saleno ');
    SQL.Add('inner join promolists pl on p.ListNo = pl.Listno ');
    SQL.Add('where p.promono = :pPromoNo and pl.itemno = :pPLUNo and r.transactionno = :pTransNo ');
    Parambyname('pPromoNo').AsCurrency := PromoNo;
    Parambyname('pPLUNo').AsCurrency := PLUNo;
    Parambyname('pTransNo').AsCurrency := TransactionNo;
    open;
    TempQty := fieldbyName('MatchQty').AsCurrency * fieldbyName('qty').AsCurrency;
    close;
  end;
  if POSDataMod.IBTempTrans2.InTransaction then
    POSDataMod.IBTempTrans2.Commit;

  ComputePLUPromoQty := min(SoldQty,TempQty);
end;

function LookupPLUPackSize(PLUNo : Currency;PLUName : String) : Currency;
var
  TempPackSize : Double;

begin
  TempPackSize := 0;
  if not POSDataMod.IBTempTrans2.InTransaction then
    POSDataMod.IBTempTrans2.StartTransaction;
  with POSDataMod.IBTempQuery2 do
  begin
    Close;SQL.Clear;
    SQL.Add('Select P.PluNo, P.Name, Mod.ModifierName, P.Packsize PLUPackSize, PM.PackSize ModPacksize, PM.PLUModifier, P.ModifierGroup ');
    SQL.Add('From Plu P ');
    SQL.Add('LEFT JOIN PluMod PM On (P.PLUNO = PM.PLUNO) and (P.ModifierGroup = PM.PLUModifierGroup) ');
    SQL.Add('LEFT JOIN Modifier Mod On (P.ModifierGroup = Mod.ModifierGroup) and (PM.PLUModifier = Mod.ModifierNo) ');
    SQL.Add('WHERE P.PLUNo = :pPLUNo ');
    SQL.Add('Group By P.PluNo, P.Name, Mod.ModifierName, P.Packsize, PM.PackSize, PM.PLUModifier, P.ModifierGroup ');
    SQL.Add('Order By P.PluNo ');
    Parambyname('pPLUNo').AsCurrency := PLUNo;
    open;
    if fieldbyName('ModifierGroup').AsInteger = 0 then
      TempPackSize := fieldbyName('PLUPackSize').AsCurrency
    else
    begin
      if LeftStr(PLUName,10) = fieldbyName('ModifierName').AsString then
        TempPackSize := fieldbyName('ModPackSize').AsCurrency
      else
        while not (EOF) and (TempPackSize = 0) do
        begin
          if LeftStr(PLUName,10) = fieldbyName('ModifierName').AsString then
            TempPackSize := fieldbyName('ModPackSize').AsCurrency;
          Next;
        end;
    end;
    close;
  end;
  if POSDataMod.IBTempTrans2.InTransaction then
    POSDataMod.IBTempTrans2.Commit;

  LookupPLUPackSize := TempPackSize;
end;
{$ENDIF}

//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------
{-----------------------------------------------------------------------------
  Name:      CreatePDIExportFile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ShiftNo : Integer; OpName : String
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CreatePDIExportFile (TerminalNo : Integer; ShiftNo : Integer; OpName : String);
var
  cnt : Integer;
  curTransNo : Integer;
  PLUPromoQty : Currency;

 begin

  DecodeDate(Now, Year, Month, Day);

  {sFname := '\Latitude.PDI';}  // GMM: Modified Export file name to DRPIN per PDI
   sFname := '\DRPIN';
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

//  write PDI Date/Location Header record - '0000'
  WriteLn( TF, '0000' + FormatDateTime('yyyymmdd', Now) +
              Format('%4.4d',[StrToInt(Setup.Number)]) + trim(InttoStr(ShiftNo))); // changed '0' to trim(InttoStr(ShiftNo))

  SRecList := TList.Create;

  // *** PDI Store Totals Export ***
  if not POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.StartTransaction;
  with POSDataMod.IBPDIQuery do
    begin
      Close;
      SQL.Clear;
      if ShiftNo = 0 then      // Store Totals
        SQL.Add('Select * From PDIIF Where TlType = 1 AND TRANSTYPE = 0 Order By PDINo')
      else if not bSyncShiftChange then // Register Totals
        SQL.Add('Select * From PDIIF Where TlType = 2 AND TRANSTYPE = 0 Order By PDINo')
      else                     // Shift Totals
        SQL.Add('Select * From PDIIF Where TlType = 3 AND TRANSTYPE = 0 Order By PDINo');
      Open;
      while Not EOF do
        begin

          nTlType         := FieldByName('TLTYPE').AsInteger;
          sDataType       := FieldByName('DATATYPE').AsInteger;
          if sDataType = 1 then
          begin
            sPDICountVal    := '';
            sPDIAmountVal   := FieldByName('PDIVAL').AsString;
          end
          else
          begin
            sPDICountVal    := FieldByName('PDIVAL').AsString;
            sPDIAmountVal   := '';
          end;
          sTableName      := FieldByName('TABLENAME').AsString;
          sFieldName      := FieldByName('FIELDNAME').AsString;
          sKeyVal         := FieldByName('KEYVAL').AsString;

          if not POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.StartTransaction;
          POSDataMod.IBTempQuery.Close;
          POSDataMod.IBTempQuery.SQL.Clear;

          if sTableName = 'GradeTotalsQuery' then
          begin
            POSDataMod.IBTempQuery.SQL.Add('SELECT G.GradeNo, MIN(CASHPRICE) CashPrice, MIN(CreditPrice) CreditPrice, MIN(TLVOL) TlVol, ');
            POSDataMod.IBTempQuery.SQL.Add('MIN(TLAmount) TlAmount, SUM(DLYCOUNT) DLYCOUNT, SUM(DLYSALES) DLYSALES, MIN(TLVOL) - SUM(DLYCOUNT) BegVol, ');
            If ShiftNo > 0 then
              POSDataMod.IBTempQuery.SQL.Add('MIN(TLAmount) - SUM(DLYSALES) BegSales, ShiftNo ')
            else
              POSDataMod.IBTempQuery.SQL.Add('MIN(TLAmount) - SUM(DLYSALES) BegSales ');
            POSDataMod.IBTempQuery.SQL.Add('FROM Grade G JOIN DEPSHIFT D ON G.DeptNo = D.DeptNo ');
            If ShiftNo > 0 then
              POSDataMod.IBTempQuery.SQL.Add(' WHERE ShiftNo = ' + InttoStr(ShiftNo) + ' GROUP BY GradeNo, ShiftNo ')
            else
              POSDataMod.IBTempQuery.SQL.Add('GROUP BY GradeNo ');
          end
          else
          begin
              POSDataMod.IBTempQuery.SQL.Add('Select SUM(' +
                      sFieldName +
                      ') ' + sFieldName);
              if sKeyVal <> '' then
                POSDataMod.IBTempQuery.SQL.Add(' , ' + sKeyVal);
              POSDataMod.IBTempQuery.SQL.Add(' FROM ' + sTableName + ' ');
              if nTlType = 1 then
              begin
                if sTableName = 'Totals' then
                  POSDataMod.IBTempQuery.SQL.Add('Where TotalNo = 0');
              end
              else if nTlType = 2 then
                POSDataMod.IBTempQuery.SQL.Add('Where ShiftNo = ' + InttoStr(ShiftNo) + ' and TerminalNo = ' + InttoStr(TerminalNo))
              else
                POSDataMod.IBTempQuery.SQL.Add('Where ShiftNo = ' + InttoStr(ShiftNo));
              if sKeyVal <> '' then
                POSDataMod.IBTempQuery.SQL.Add(' GROUP BY ' + sKeyVal);
          end;
          POSDataMod.IBTempQuery.Open;
          while NOT POSDataMod.IBTempQuery.EOF do
            begin

              //replace # in pdival string with shift no
              sLookUpPDICountVal := sPDICountVal;
              sLookUpPDIAmountVal := sPDIAmountVal;

                  if Pos('#', sLookUpPDICountVal) > 0 then
                    sLookUpPDICountVal[Pos('#', sLookUpPDICountVal)] := InttoStr(ShiftNo)[1];
                  if Pos('#', sLookUpPDIAmountVal) > 0 then
                    sLookUpPDIAmountVal[Pos('#', sLookUpPDIAmountVal)] := InttoStr(ShiftNo)[1];
                  if Pos('%', sLookUpPDICountVal) > 0 then
                    sLookUpPDICountVal[Pos('%', sLookUpPDICountVal)] := InttoStr(TerminalNo)[1];
                  if Pos('%', sLookUpPDIAmountVal) > 0 then
                    sLookUpPDIAmountVal[Pos('%', sLookUpPDIAmountVal)] := InttoStr(TerminalNo)[1];
                  if Pos('@@', sLookUpPDICountVal) > 0 then
                    if Length(sLookUpPDICountVal) > Pos('@@', sLookUpPDICountVal) + 1 then
                      sLookUpPDICountVal := LeftStr(sLookupPDICountVal,Pos('@@', sLookUpPDICountVal)-1) + FormatFloat('00',POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsCurrency) + RightStr(sLookupPDICountVal,Length(sLookUpPDICountVal) - (Pos('@@', sLookUpPDICountVal)+1))
                    else
                      sLookUpPDICountVal := LeftStr(sLookupPDICountVal,Pos('@@', sLookUpPDICountVal)-1) + FormatFloat('00',POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsCurrency);
                  if Pos('@@', sLookUpPDIAmountVal) > 0 then
                    if Length(sLookUpPDIAmountVal) > Pos('@@', sLookUpPDIAmountVal) + 1 then
                      sLookUpPDIAmountVal := LeftStr(sLookupPDIAmountVal,Pos('@@', sLookUpPDIAmountVal)-1) + FormatFloat('00',POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsCurrency) + RightStr(sLookupPDIAmountVal,Length(sLookUpPDIAmountVal) - (Pos('@@', sLookUpPDIAmountVal)+1))
                    else
                      sLookUpPDIAmountVal := LeftStr(sLookupPDIAmountVal,Pos('@@', sLookUpPDIAmountVal)-1) + FormatFloat('00',POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsCurrency);
                  if Pos('&&', sLookUpPDICountVal) > 0 then
                    if Length(sLookUpPDICountVal) > Pos('&&', sLookUpPDICountVal) + 1 then
                      sLookUpPDICountVal := LeftStr(sLookupPDICountVal,Pos('&&', sLookUpPDICountVal)-1) + FormatFloat('00',Hourof(POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsDateTime)) + RightStr(sLookupPDICountVal,Length(sLookUpPDICountVal) - (Pos('&&', sLookUpPDICountVal)+1))
                    else
                      sLookUpPDICountVal := LeftStr(sLookupPDICountVal,Pos('&&', sLookUpPDICountVal)-1) + FormatFloat('00',Hourof(POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsDateTime));
                  if Pos('&&', sLookUpPDIAmountVal) > 0 then
                    if Length(sLookUpPDIAmountVal) > Pos('&&', sLookUpPDIAmountVal) + 1 then
                      sLookUpPDIAmountVal := LeftStr(sLookupPDIAmountVal,Pos('&&', sLookUpPDIAmountVal)-1) + FormatFloat('00',Hourof(POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsDateTime)) + RightStr(sLookupPDIAmountVal,Length(sLookUpPDIAmountVal) - (Pos('&&', sLookUpPDIAmountVal)+1))
                    else
                      sLookUpPDIAmountVal := LeftStr(sLookupPDIAmountVal,Pos('&&', sLookUpPDIAmountVal)-1) + FormatFloat('00',Hourof(POSDataMod.IBTempQuery.FieldByName(sKeyVal).AsDateTime));

              cUpdateVal1 := 0;
              cUpdateVal2 := 0;
                  cUpdateVal1 := POSDataMod.IBTempQuery.FieldByName(sFieldName).AsCurrency;
                  cUpdateVal2 := POSDataMod.IBTempQuery.FieldByName(sFieldName).AsCurrency;
              if Length(sLookUpPDICountVal) > 0 then
                begin
                  bFound := False;
                  for cnt := 0 to SRecList.Count - 1 do
                    begin
                      SRec := SRecList.Items[cnt];
                      if (SRec^.PDIVal = sLookUpPDICountVal) then
                        begin
                          bFound := True;
                          break;
                        end;
                    end;

                  if bFound then
                    begin
                      SRec^.DataVal := SRec^.DataVal + cUpdateVal1;
                    end
                  else
                    begin
                      New(SRec);
                      SRec^.TlType   := nTlType;
                      SRec^.PDIVal   := sLookUpPDICountVal;
                      SRec^.DataVal  := cUpdateVal1;
                      SRecList.Add(SRec);
                    end;
                end;

              if Length(sLookUpPDIAmountVal) > 0 then
                begin
                  bFound := False;
                  for cnt := 0 to SRecList.Count - 1 do
                    begin
                      SRec := SRecList.Items[cnt];
                      if (SRec^.PDIVal = sLookUpPDIAmountVal) then
                        begin
                          bFound := True;
                          break;
                        end;
                    end;

                  if bFound then
                    begin
                      SRec^.DataVal := SRec^.DataVal + cUpdateVal2;
                    end
                  else
                    begin
                      New(SRec);
                      SRec^.TlType   := nTlType;
                      SRec^.PDIVal   := sLookUpPDIAmountVal;
                      SRec^.DataVal  := cUpdateVal2;
                      SRecList.Add(SRec);
                    end;
                end;

              POSDataMod.IBTempQuery.Next;
            end;
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Commit;
          POSDataMod.IBPDIQuery.Next;
        end;
    end;
  if POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.Commit;
    //empty list to disk six at a time

  if SRecList.Count > 0 then
    begin

      ndx := 0;
      maxndx := SRecList.count - 1;
      while True do
        begin

          for cnt := 1 to 6 do
            begin
              sName[cnt] := '';
              cData[cnt] := 0;
            end;

          for cnt := 0 to 5 do
            if ndx + cnt <= MaxNdx then
            begin
              SRec := SRecList.Items[ndx + cnt];
              sName[cnt+1] := SRec^.PDIVal;
              cData[cnt+1] := SRec^.DataVal * 100;
            end;

  // PDI Daily Report Record - 1000
  // Record Type  - '1000'
  // Identifier1  - 6   Alpha
  // Data      1  - 999999999v99-
  // Identifier2  - 6   Alpha
  // Data      2  - 999999999v99-
  // Identifier3  - 6   Alpha
  // Data      3  - 999999999v99-
  // Identifier4  - 6   Alpha
  // Data      4  - 999999999v99-
  // Identifier5  - 6   Alpha
  // Data      5  - 999999999v99-
  // Identifier6  - 6   Alpha
  // Data      6  - 999999999v99-
  //  space fill Identifiers and Zero fill data


          WriteLn(TF,  '1000' +
                Format('%-6s',[sName[1]]) +
                FormatFloat('00000000000 ;00000000000-', cData[1] ) +
                Format('%-6s',[sName[2]]) +
                FormatFloat('00000000000 ;00000000000-', cData[2] ) +
                Format('%-6s',[sName[3]]) +
                FormatFloat('00000000000 ;00000000000-', cData[3] ) +
                Format('%-6s',[sName[4]]) +
                FormatFloat('00000000000 ;00000000000-', cData[4] ) +
                Format('%-6s',[sName[5]]) +
                FormatFloat('00000000000 ;00000000000-', cData[5] ) +
                Format('%-6s',[sName[6]]) +
                FormatFloat('00000000000 ;00000000000-', cData[6] ) );

          inc(ndx, 6);
          if ndx > SRecList.Count - 1 then
            break;

        end;

      for cnt := 0 to SRecList.Count - 1 do
        begin
          SRec := SRecList.Items[cnt];
          Dispose(SRec);
        end;
      SRecList.Destroy;
    end;


  // *** PDI Store Totals Export ***
  if not POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.StartTransaction;
  with POSDataMod.IBPDIQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * From PDIIF Where TRANSTYPE = 1 Order By TransNo');
    SRecList := TList.Create;
    curTransNo := 0;
    Open;
    while Not EOF do
    begin
      curTransNo := FieldByName('TRANSNO').AsInteger;
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      POSDataMod.IBTempQuery.Close;
      POSDataMod.IBTempQuery.SQL.Clear;
      POSDataMod.IBTempQuery.SQL.Add(FieldByName('SQLTEXT').AsString);
      POSDataMod.IBTempQuery.Open;
      If NOT POSDataMod.IBTempQuery.EOF then //20060719 Only write the header if records exist
      begin
        //  write PDI Transaction Header record - '2200'
        WriteLn( TF, '2200' + Format('%2.2d',[curTransNo])+ ' ');
      end;
      while NOT POSDataMod.IBTempQuery.EOF do
      begin
        For cnt := 0 to POSDataMod.IBTempQuery.FieldCount-1  do
        begin
          sFieldName := POSDataMod.IBTempQuery.FieldList[cnt].FieldName;
          sPDIVal := sFieldName;
          sLookUpPDIVal := sPDIVal;
          cUpdateVal1 := 0;
          cUpdateVal1 := POSDataMod.IBTempQuery.FieldByName(sFieldName).AsCurrency;
          if Length(sLookUpPDIVal) > 0 then
          begin
            New(SRec);
            SRec^.TlType   := nTlType;
            SRec^.PDIVal   := sLookUpPDIVal;
            SRec^.DataVal  := cUpdateVal1;
            SRecList.Add(SRec);
          end;
        end;
        //empty list to disk twelve at a time

        if SRecList.Count > 0 then
        begin
          ndx := 0;
          maxndx := SRecList.count - 1;
          while True do
          begin
            for cnt := 1 to 12 do
            begin
              sName[cnt] := '';
              cData[cnt] := 0;
            end;

            for cnt := 0 to 11 do
              if ndx + cnt <= MaxNdx then
              begin
                SRec := SRecList.Items[ndx + cnt];
                sName[cnt+1] := SRec^.PDIVal;
                // cData[cnt+1] := SRec^.DataVal * 100;  //20060719 Send actual integer values
                cData[cnt+1] := SRec^.DataVal;
              end;

            // PDI Transaction Entry Detail Record - 2202
            // Record Type  - '2202'
            // Identifier1  - 6   Alpha
            // Data      1  - 999999999999999v99-
            // Identifier2  - 6   Alpha
            // Data      2  - 999999999999999v99-
            // Identifier3  - 6   Alpha
            // Data      3  - 999999999999999v99-
            // Identifier4  - 6   Alpha
            // Data      4  - 999999999999999v99-
            // Identifier5  - 6   Alpha
            // Data      5  - 999999999999999v99-
            // Identifier6  - 6   Alpha
            // Data      6  - 999999999999999v99-
            // Identifier7  - 6   Alpha
            // Data      7  - 999999999999999v99-
            // Identifier8  - 6   Alpha
            // Data      8  - 999999999999999v99-
            // Identifier9  - 6   Alpha
            // Data      9  - 999999999999999v99-
            // Identifier10 - 6   Alpha
            // Data      10 - 999999999999999v99-
            // Identifier11 - 6   Alpha
            // Data      11 - 999999999999999v99-
            // Identifier12 - 6   Alpha
            // Data      12 - 999999999999999v99-
            //  space fill Identifiers and Zero fill data

            WriteLn(TF,  '2202' +
                    Format('%-6s',[sName[1]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[1] ) +
                    Format('%-6s',[sName[2]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[2] ) +
                    Format('%-6s',[sName[3]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[3] ) +
                    Format('%-6s',[sName[4]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[4] ) +
                    Format('%-6s',[sName[5]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[5] ) +
                    Format('%-6s',[sName[6]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[6] ) +
                    Format('%-6s',[sName[7]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[7] ) +
                    Format('%-6s',[sName[8]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[8] ) +
                    Format('%-6s',[sName[9]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[9] ) +
                    Format('%-6s',[sName[10]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[10] ) +
                    Format('%-6s',[sName[11]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[11] ) +
                    Format('%-6s',[sName[12]]) +
                    FormatFloat('00000000000000000 ;00000000000000000-', cData[12] ) );
            inc(ndx, 12);
            if ndx > SRecList.Count - 1 then
              break;

          end;

          for cnt := 0 to SRecList.Count - 1 do
          begin
            SRec := SRecList.Items[cnt];
            Dispose(SRec);
          end;
          SRecList.Destroy;
          SRecList := TList.Create;
        end;
        POSDataMod.IBTempQuery.Next;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSDataMod.IBPDIQuery.Next;
    end;
  end;
  if POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.Commit;


  // Export PLU Sales Totals

  // *** Plu Records ***
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      PLUSalesList := Tlist.Create;
      {$IFDEF PDI_PROMOS}
      SQL.Add('SELECT TransactionNo, SaleNo, SaleName, Qty, Price, ExtPrice, SavDiscable, Disc ');
      SQL.Add('FROM Receipt WHERE LineType = ''PLU'' ');
      SQL.Add('ORDER BY SaleNo, Disc, Price ');
      Open;
      while not EOF do
      begin
        PLUPromoQty := 0;
        if fieldbyName('Disc').AsInteger = 1 then
        begin
          PLUPromoQty := ComputePLUPromoQty(fieldbyName('TransactionNo').AsCurrency, fieldbyName('SaleNo').AsCurrency,fieldbyName('SavDiscable').AsCurrency,fieldbyName('SaleName').AsString,fieldbyName('Qty').AsCurrency);
          cnt := 0;
          PLUFound := False;
          while ((cnt < PLUSalesList.Count) and not (PLUFound)) do
          begin
            PLUSalesRec := PLUSalesList.Items[cnt];
            //20070320 Changed to generate a single Promotion record instead of multiple
//            if ((fieldbyName('SaleNo').AsCurrency = PLUSalesRec^.PLUNo) and (fieldbyName('SavDiscable').AsCurrency = PLUSalesRec^.PromoID)) then
            //20070321 Changed fieldbyName('SavDiscable').AsCurrency to PLUSalesRec^.PromoID
//            if ((fieldbyName('SaleNo').AsCurrency = PLUSalesRec^.PLUNo) and (fieldbyName('SavDiscable').AsCurrency > 0)) then
            if ((fieldbyName('SaleNo').AsCurrency = PLUSalesRec^.PLUNo) and (PLUSalesRec^.PromoID > 0)) then
            begin
              PLUSalesRec^.QtySold := PLUSalesRec^.QtySold + PLUPromoQty;
              if fieldbyName('Qty').AsCurrency > PLUPromoQty then
                PLUSalesRec^.ExtRetail := PLUSalesRec^.ExtRetail + fieldbyName('ExtPrice').AsCurrency - (fieldbyName('Price').AsCurrency * (fieldbyName('Qty').AsCurrency - PLUPromoQty))
              else
                PLUSalesRec^.ExtRetail := PLUSalesRec^.ExtRetail + fieldbyName('ExtPrice').AsCurrency;
              PLUFound := true;
            end
            else
              inc(cnt);
          end;
          if not (PLUFound) then
          begin
            New(PLUSalesRec);
            PLUSalesRec^.PLUNo := fieldbyName('SaleNo').AsCurrency;
            PLUSalesRec^.PackSize := LookupPLUPackSize(fieldbyName('SaleNo').AsCurrency, fieldbyName('SaleName').AsString);
            PLUSalesRec^.QtySold := PLUPromoQty;
            PLUSalesRec^.UnitCost := 0;
            PLUSalesRec^.UnitRetail := 0;
            if fieldbyName('Qty').AsCurrency > PLUPromoQty then
              PLUSalesRec^.ExtRetail := fieldbyName('ExtPrice').AsCurrency - (fieldbyName('Price').AsCurrency * (fieldbyName('Qty').AsCurrency - PLUPromoQty))
            else
              PLUSalesRec^.ExtRetail := fieldbyName('ExtPrice').AsCurrency;
            PLUSalesRec^.ItemDesc := fieldbyName('SaleName').AsString;
            PLUSalesRec^.PromoID := fieldbyName('SavDiscable').AsInteger;
            PLUSalesList.Add(PLUSalesRec);
          end;
          PLUPromoQty := fieldbyName('Qty').AsCurrency - PLUPromoQty;
        end;
        if ((fieldbyName('Disc').AsInteger = 0) or (PLUPromoQty > 0)) then
        begin
          cnt := 0;
          PLUFound := False;
          while ((cnt < PLUSalesList.Count) and not (PLUFound)) do
          begin
            PLUSalesRec := PLUSalesList.Items[cnt];
            if ((fieldbyName('SaleNo').AsCurrency = PLUSalesRec^.PLUNo) and (fieldbyName('Price').AsCurrency = PLUSalesRec^.UnitRetail) and (PLUSalesRec^.PromoID = 0)) then
            begin
              if PLUPromoQty > 0 then
              begin
                PLUSalesRec^.QtySold := PLUSalesRec^.QtySold + PLUPromoQty;
                PLUSalesRec^.ExtRetail := PLUSalesRec^.ExtRetail + fieldbyName('Price').AsCurrency * PLUPromoQty;
              end
              else
              begin
                PLUSalesRec^.QtySold := PLUSalesRec^.QtySold + fieldbyName('Qty').AsCurrency;
                PLUSalesRec^.ExtRetail := PLUSalesRec^.ExtRetail + fieldbyName('Price').AsCurrency * fieldbyName('Qty').AsCurrency;
              end;
              PLUFound := true;
            end
            else
              inc(cnt);
          end;
          if not (PLUFound) then
          begin
            New(PLUSalesRec);
            PLUSalesRec^.PLUNo := fieldbyName('SaleNo').AsCurrency;
            PLUSalesRec^.PackSize := LookupPLUPackSize(fieldbyName('SaleNo').AsCurrency, fieldbyName('SaleName').AsString);
            PLUSalesRec^.UnitCost := 0;
            PLUSalesRec^.UnitRetail := fieldbyName('Price').AsCurrency;
            if (fieldbyName('Qty').AsCurrency > PLUPromoQty) and (PLUPromoQty > 0) then
            begin
              PLUSalesRec^.ExtRetail := fieldbyName('Price').AsCurrency * PLUPromoQty;
              PLUSalesRec^.QtySold := PLUPromoQty;
            end
            else
            begin
              PLUSalesRec^.ExtRetail := fieldbyName('ExtPrice').AsCurrency;
              PLUSalesRec^.QtySold := fieldbyName('Qty').AsCurrency;
            end;
            PLUSalesRec^.ItemDesc := fieldbyName('SaleName').AsString;
            PLUSalesRec^.PromoID := 0;
            PLUSalesList.Add(PLUSalesRec);
          end;
        end;
        Next;
      end;
      Close;
      {$ELSE}
      // GMM:  Added Packsize to support record format 2505 Changed Min(P.Price) to PS.Price
      SQL.Add('Select PS.PluNo, P.Name, Mod.ModifierName, P.Packsize PLUPackSize, PM.PackSize ModPacksize, PS.PLUModifier, PS.Price As Price, Sum(PS.DlyCount) As DlyCount, ');
      SQL.Add('Sum(PS.DlySales) As DlySales From PluShift PS Inner Join Plu P On (PS.PluNo = P.PluNo) ');
      SQL.Add('LEFT JOIN PluMod PM On (PS.PLUNO = PM.PLUNO) and (PS.PLUModifier = PM.PLUModifier) ');
      SQL.Add('LEFT JOIN Modifier Mod On (P.ModifierGroup = Mod.ModifierGroup) and (PS.PLUModifier = Mod.ModifierNo) ');
      SQL.Add('Where PS.DlyCount <> 0 ');
      If ShiftNo > 0 Then
        SQL.Add('And PS.ShiftNo  = :pShiftNo ');
      SQL.Add('Group By PS.PluNo, P.Name, Mod.ModifierName, P.Packsize, PM.PackSize, PS.PLUModifier, PS.Price ');   // GMM: Added Packsize and Price
      SQL.Add('Order By PS.PluNo');
      if ShiftNo > 0 then
        Parambyname('pShiftNo').AsString := inttostr(ShiftNo);
      Open;

      while Not EOF do
        begin
          New(PLUSalesRec);
          PLUSalesRec^.PLUNo := fieldbyName('PLUNo').AsCurrency;
          if FieldByName('PluModifier').AsInteger > 0 then
            if FieldByName('ModPackSize').isNull then
              PLUSalesRec^.PackSize := 1
            else
              PLUSalesRec^.PackSize := FieldByName('ModPackSize').AsCurrency
          else
            if FieldByName('PLUPackSize').isNull then
              PLUSalesRec^.PackSize := 1
            else
              PLUSalesRec^.PackSize := FieldByName('PLUPackSize').AsCurrency;
          PLUSalesRec^.QtySold := fieldbyName('DlyCount').AsCurrency;
          PLUSalesRec^.UnitCost := 0;
          PLUSalesRec^.UnitRetail := fieldbyName('Price').AsCurrency;
          PLUSalesRec^.ExtRetail := fieldbyName('DlySales').AsCurrency;
          if FieldByName('PluModifier').AsInteger > 0 then
            PLUSalesRec^.ItemDesc := leftStr(fieldbyName('ModifierName').AsString + fieldbyName('Name').AsString + StringofChar(' ',30),30)
          else
            PLUSalesRec^.ItemDesc := leftStr(fieldbyName('Name').AsString + StringofChar(' ',30),30);
          PLUSalesRec^.PromoID := 0;
          PLUSalesList.Add(PLUSalesRec);
          Next;
        end;
      Close;
      {$ENDIF}
        // GMM:  changed from format 2500 to 2505
   // PLU/Item Sales Record (2505)
   //  Record Type       4      '2505'
   //  Sales Type        1      'I'
   //  Item number      15      999999999999999
   //  Item Pack Size    8      9999v9999
   //  Quantity Sold    12      9999999v9999-
   //  Unit Cost        12      9999999v9999-
   //  Unit Retail      10      9999999v99-
   //  Extended Retail  10      9999999v99-

{
          if FieldByName('PluModifier').AsInteger > 0 then
          begin
            //20060829a...
            if FieldByName('ModPackSize').isNull then
            begin
              WriteLn(TF,  '2505I' + FormatFloat('000000000000000', FieldByName('PluNo').AsCurrency) +
               FormatFloat('00000000', (1.0 * 10000)) +
               FormatFloat('00000000000 ;00000000000-', (FieldByName('DlyCount').AsCurrency * 10000) ) +
               FormatFloat('00000000000 ;00000000000-', 0 ) +
               FormatFloat('000000000 ;000000000-', (FieldByName('Price').AsCurrency * 100)) +
               FormatFloat('000000000 ;000000000-', (FieldByName('DlySales').AsCurrency * 100) ) );
            end
            else
            //...20060829a
            begin
              WriteLn(TF,  '2505I' + FormatFloat('000000000000000', FieldByName('PluNo').AsCurrency) +
               FormatFloat('00000000', (FieldByName('ModPackSize').AsCurrency * 10000)) +
               FormatFloat('00000000000 ;00000000000-', (FieldByName('DlyCount').AsCurrency * 10000) ) +
               FormatFloat('00000000000 ;00000000000-', 0 ) +
               FormatFloat('000000000 ;000000000-', (FieldByName('Price').AsCurrency * 100)) +
               FormatFloat('000000000 ;000000000-', (FieldByName('DlySales').AsCurrency * 100) ) );
            end;
          end
          else
          begin
            //20060829a...
            if FieldByName('PLUPackSize').isNull then
            begin
              WriteLn(TF,  '2505I' + FormatFloat('000000000000000', FieldByName('PluNo').AsCurrency) +
               FormatFloat('00000000', (1.0 * 10000)) +
               FormatFloat('00000000000 ;00000000000-', (FieldByName('DlyCount').AsCurrency * 10000) ) +
               FormatFloat('00000000000 ;00000000000-', 0 ) +
               FormatFloat('000000000 ;000000000-', (FieldByName('Price').AsCurrency * 100)) +
               FormatFloat('000000000 ;000000000-', (FieldByName('DlySales').AsCurrency * 100) ) );
            end
            else
            //...20060829a
            begin
              WriteLn(TF,  '2505I' + FormatFloat('000000000000000', FieldByName('PluNo').AsCurrency) +
               FormatFloat('00000000', (FieldByName('PLUPackSize').AsCurrency * 10000)) +
               FormatFloat('00000000000 ;00000000000-', (FieldByName('DlyCount').AsCurrency * 10000) ) +
               FormatFloat('00000000000 ;00000000000-', 0 ) +
               FormatFloat('000000000 ;000000000-', (FieldByName('Price').AsCurrency * 100)) +
               FormatFloat('000000000 ;000000000-', (FieldByName('DlySales').AsCurrency * 100) ) );
            end;
          end;
          Next;
        end;
      Close;
}
      for cnt := 0 to PLUSalesList.Count-1 do
      begin
        PLUSalesRec := PLUSalesList.Items[cnt];
        Write(TF,  '2505I' + FormatFloat('000000000000000', PLUSalesRec^.PLUNo) +
          FormatFloat('00000000', (PLUSalesRec^.PackSize * 10000)) +
          FormatFloat('00000000000 ;00000000000-', (PLUSalesRec^.QtySold * 10000) ) +
          FormatFloat('00000000000 ;00000000000-', PLUSalesRec^.UnitCost ) +
          FormatFloat('000000000 ;000000000-', (PLUSalesRec^.UnitRetail * 100)) +
          FormatFloat('000000000 ;000000000-', (PLUSalesRec^.ExtRetail * 100) ) +
          leftstr(PLUSalesRec^.ItemDesc  + StringofChar(' ',30),30));
        if PLUSalesRec^.PromoID = 0 then
          Writeln(TF,StringofChar(' ',40))
        else
          Writeln(TF,leftStr(CurrtoStr(PLUSalesRec^.PromoID) + StringofChar(' ',40),40));
      end;
      for cnt := 0 to PLUSalesList.Count-1 do
      begin
        PLUSalesRec := PLUSalesList.Items[cnt];
        Dispose(PLUSalesRec);
      end;
      PLUSalesList.Destroy;
    end; {with TempQuery - PLU}

  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  // Start of Fuel Meter Readings

  try
    i := Setup.FuelInterfaceType;
  except
    i := 1;
  end;
  if (i < 1) or (i > 2) then
    i := 1;

//  if i > 1 then
//    begin
      for cnt := 1 to 20 do
        begin
          aCurGradeTls[cnt,1] := 0;
          aCurGradeTls[cnt,2] := 0;
          aPrevGradeTls[cnt,1] := 0;
          aPrevGradeTls[cnt,2] := 0;
        end;
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('SELECT CurPumpTlID, PrevPumpTlID FROM Totals where TotalNo = 0');
          Open;
          nCurFuelTlID  := FieldByName('CurPumpTlID').AsInteger;
          nPrevFuelTlID := FieldByName('PrevPumpTlID').AsInteger;
          Close;
          SQL.Clear;
        end;

      // **** Get Fuel Totals ****
      if boolean(Setup.MeterReport) then
      begin
        with POSDataMod.IBTempQuery do
        begin
          // Build SQL Statement  to get current hose totals
          SQL.Clear;
          SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
          SQL.Add('WHERE (T.TlNo = ' + IntToStr(nCurFuelTlID) + ') ' );
          SQL.Add('AND (T.PumpNo = D.PumpNo) AND (T.HoseNo = D.HoseNo) ');
          SQL.Add('AND (D.GradeNo = G.GradeNo) ');
          SQL.Add('ORDER BY T.PumpNo, T.HoseNo');

          try
            Open;
            while not EOF do {Begin Processing Query}
              begin
                nHIdx := FieldByName('GradeNo').AsInteger;
                if (nHIdx > 0) and (nHIdx < 21) then
                  begin
                    aCurGradeTls[nHIdx,1] := aCurGradeTls[nHIdx,1] + FieldByName('VolumeTl').AsCurrency;
                    aCurGradeTls[nHIdx,2] := aCurGradeTls[nHIdx,2] + FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency;
                  end;
                Next;
              end; {while not EOF}
            Close;
          except
          end;

          // Build SQL Statement to get previous hose totals
          SQL.Clear;
          SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
          SQL.Add('WHERE (T.TlNo = ' + IntToStr(nPrevFuelTlID) + ') ' );
          SQL.Add('AND (T.PumpNo = D.PumpNo) AND (T.HoseNo = D.HoseNo) ');
          SQL.Add('AND (D.GradeNo = G.GradeNo) ');
          SQL.Add('ORDER BY T.PumpNo, T.HoseNo');
          try
            Open;

            while not EOF do {Begin Processing Query}
              begin
                nHIdx := FieldByName('GradeNo').AsInteger;
                if (nHIdx > 0) and (nHIdx < 21) then
                  begin
                    aPrevGradeTls[nHIdx,1] := aPrevGradeTls[nHIdx,1] + FieldByName('VolumeTl').AsCurrency;
                    aPrevGradeTls[nHIdx,2] := aPrevGradeTls[nHIdx,2] + FieldByName('CreditTl').AsCurrency + FieldByName('CashTl').AsCurrency;
                  end;
                Next;
              end; {while not EOF}
            Close;
          except
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


       //  Gasoline Meter Readings (3100)
       //  Record Type               4      '3100'
       //  Hose Number               2      99
       //  Fuel Type                 3      Alpha - what ?
       //  Ending Dollar Meter      12      999999999v99-
       //  Begining Dollar Meter    12      999999999v99-
       //  Test Dollars             12      999999999v99-
       //  Adjustment Dollars       12      999999999v99-
       //  Retail Price per Unit     8      999v9999-
       //  Dollars Converted         8      999v9999-
       //  Ending Gallon Meter      12      999999999v99-
       //  Beginning Gallon Meter   12      999999999v99-
       //  Test Gallons             12      999999999v99-
       //  Adjustment Gallons       12      999999999v99-
       //  Tax Free Gallons          8      99999v99-
       //  Discounted Gallons        8      99999v99-
       //  Net Dollars              10      9999999v99-
       //  Net Gallons              10      9999999v99-
       //  Dollar Meter Roll Flag    1      Y/N
       //  Gallon Meter Roll Flag    1      Y/N


                  // Second Index Value - 1 = Volume   2 = Dollars
                  WriteLn(TF,
                    '3100' +
                     Format('%2.2d',[nHIdx]) +
                     Format('%3.3d',[nHIdx]) +   // GMM: Added per PDI Request
                     FormatFloat('00000000000 ;00000000000-', (aCurGradeTls[nHIdx,2] * 100) ) +  //Ending Dollar Meter
                     FormatFloat('00000000000 ;00000000000-', (aPrevGradeTls[nHIdx,2] * 100) ) + //Beginning Dollar Meter
                     FormatFloat('00000000000 ;00000000000-', 0 ) +   //Test Dollars
                     FormatFloat('00000000000 ;00000000000-', 0 ) +   //Adjustment Dollars
                     FormatFloat('0000000 ;0000000-', (FieldByName('CashPrice').AsCurrency * 10000) ) + //Retail Price Per Unit
                     FormatFloat('0000000 ;0000000-', 0 ) + //Dollars Converted
                     FormatFloat('00000000000 ;00000000000-', (aCurGradeTls[nHIdx,1] * 100) ) +  //Ending Gallon Meter
                     FormatFloat('00000000000 ;00000000000-', (aPrevGradeTls[nHIdx,1] * 100) ) + //Beginning Gallon Meter
                     FormatFloat('00000000000 ;00000000000-', 0 ) + //Test Gallons
                     FormatFloat('00000000000 ;00000000000-', 0 ) + //Adjustment Gallons
                     FormatFloat('0000000 ;0000000-', 0 ) + //Tax Free Gallons
                     FormatFloat('0000000 ;0000000-', 0 ) + //Discounted Gallons
                     FormatFloat('000000000 ;000000000-', 0 ) + //Net Dollars
                     FormatFloat('000000000 ;000000000-', 0 ) + //Net Gallons
                     'N' + // Dollar Meter Roll Flag
                     'N' ); // Gallon Meter Roll Flag

                end;
              Next;
            end; {while not EOF}
          Close;

        end;
      end
      else
      begin
        with POSDataMod.IBTempQuery do
        begin
          // Build SQL Statement  to get current hose totals
          SQL.Clear;
          // SQL.Add('Select * from Grade order by GradeNo');
          SQL.Add('SELECT G.GradeNo, MIN(CASHPRICE) CashPrice, MIN(CreditPrice) CreditPrice, MIN(TLVOL) TlVol, ');
          SQL.Add('MIN(TLAmount) TlAmount, SUM(DLYCOUNT) DLYCOUNT, SUM(DLYSALES) DLYSALES, MIN(TLVOL) - SUM(DLYCOUNT) BegVol, ');
          If ShiftNo > 0 then
            SQL.Add('MIN(TLAmount) - SUM(DLYSALES) BegSales, ShiftNo ')
          else
            SQL.Add('MIN(TLAmount) - SUM(DLYSALES) BegSales ');
          SQL.Add('FROM Grade G JOIN DEPSHIFT D ON G.DeptNo = D.DeptNo ');
          If ShiftNo > 0 then
            SQL.Add(' WHERE ShiftNo = ' + InttoStr(ShiftNo) + ' GROUP BY GradeNo, ShiftNo ')
          else
            SQL.Add('GROUP BY GradeNo ');
          open;
          while not eof do
          begin
            WriteLn(TF,
                    '3100' +
                     Format('%2.2d',[fieldbyname('GradeNo').AsInteger]) +
                     Format('%3.3d',[fieldbyname('GradeNo').AsInteger]) +   // GMM: Added per PDI Request
                     FormatFloat('00000000000 ;00000000000-', (fieldbyname('TLAmount').AsCurrency * 100) ) +  //Ending Dollar Meter
                     FormatFloat('00000000000 ;00000000000-', (fieldbyname('BegSales').AsCurrency * 100) ) + //Beginning Dollar Meter
                     FormatFloat('00000000000 ;00000000000-', 0 ) +   //Test Dollars
                     FormatFloat('00000000000 ;00000000000-', 0 ) +   //Adjustment Dollars
                     FormatFloat('0000000 ;0000000-', (FieldByName('CashPrice').AsCurrency * 10000) ) + //Retail Price Per Unit
                     FormatFloat('0000000 ;0000000-', 0 ) + //Dollars Converted
                     FormatFloat('00000000000 ;00000000000-', (fieldbyname('TLVol').AsCurrency * 100) ) +  //Ending Gallon Meter
                     FormatFloat('00000000000 ;00000000000-', (fieldbyname('BegVol').AsCurrency * 100) ) + //Beginning Gallon Meter
                     FormatFloat('00000000000 ;00000000000-', 0 ) + //Test Gallons
                     FormatFloat('00000000000 ;00000000000-', 0 ) + //Adjustment Gallons
                     FormatFloat('0000000 ;0000000-', 0 ) + //Tax Free Gallons
                     FormatFloat('0000000 ;0000000-', 0 ) + //Discounted Gallons
                     FormatFloat('000000000 ;000000000-', 0 ) + //Net Dollars
                     FormatFloat('000000000 ;000000000-', 0 ) + //Net Gallons
                     'N' + // Dollar Meter Roll Flag
                     'N' ); // Gallon Meter Roll Flag
            next;
          end;
          close;
        end;
      end;
       if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
//    end;


 CloseFile(TF);

end; {end procedure CreateExportFile}

end.

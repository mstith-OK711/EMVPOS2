unit AESEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, POSDM, DB, FileCtrl;

procedure CreateAESExportFile (ShiftNo : Integer; OpName : String);
procedure InsertAESExportTable(TypeValue : integer;  KeyValue, KeyDscr : string; Count, Amount, Credit, Cash : currency);
procedure InsertPLUAESExportTable(TypeValue : integer;  KeyValue, UPCNo, ModifierNo, KeyDscr : string; Count, Amount : currency);
procedure ImportAESValues(UPCNo,ItemPrice:Real; Descr,Dept,Modifier,FoodStamp,CodeType:string);

implementation

uses POSMain, POSMsg;
Var
SeqNo : integer;
OpenDate         : TDateTime;
AESShiftNo : integer;
StoreNumber, StoreName : string;


//--------------------------------------------------------------------------
// Export Back Office Interface Files
//--------------------------------------------------------------------------

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    InsertAESExportTable                                         |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Amount, Cash, Count, Credit, KeyDscr, KeyValue, TypeValue    |
|                                                                            |
| CALLED BY:    CreateAESExportFile                                          |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      AESShiftNo, IBTempQuery, OpenDate, POSDataMod, SeqNo,        |
|               StoreName, StoreNumber                                       |
|                                                                            |
| LOCALS:       (none)                                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure InsertAESExportTable(TypeValue : integer;  KeyValue, KeyDscr : string; Count, Amount,credit,cash : currency);
begin
  Inc(SeqNo);
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.ADD('Insert Into AESExport( BusDate, StoreNumber, StoreName, SeqNo, Shift, TypeVal, KeyVal, UPCVal, ModifierVal, KeyDscr, TLCount, TLAmount,TLACredit,TLACash )');
      SQL.ADD('Values (:pBusDate, :pStoreNumber, :pStoreName, :pSeqNo, :pShift, :pTypeVal, :pKeyVal, :pUPCVal, :pModifierVal, :pKeyDscr, :pTLCount, :pTLAmount,:pTLACredit,:pTLACash)');
      ParamByName('pBusDate').AsDateTime := OpenDate;
      ParamByName('pStoreNumber').AsString := StoreNumber;
      ParamByName('pStoreName').AsString := StoreName;
      ParamByName('pSeqNo').AsInteger   := SeqNo;
      ParamByName('pShift').AsInteger   := AESShiftNo;
      ParamByName('pTypeVal').AsInteger := TypeValue;
      ParamByName('pKeyVal').AsString   := KeyValue;
      ParamByName('pUPCVal').AsString   := '';
      ParamByName('pModifierVal').AsString   := '';
      ParamByName('pKeyDscr').AsString  := KeyDscr;
      ParamByName('pTLCount').AsCurrency  := Count;
      ParamByName('pTLAmount').AsCurrency := Amount;
      ParamByName('pTLACredit').AsCurrency := Credit;
      ParamByName('pTLACash').AsCurrency := Cash;
      ExecSQL;
      Close;
    end;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    InsertPLUAESExportTable                                      |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Amount, Count, KeyDscr, KeyValue, ModifierNo, TypeValue,     |
|               UPCNo                                                        |
|                                                                            |
| CALLED BY:    CreateAESExportFile                                          |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      AESShiftNo, IBTempQuery, OpenDate, POSDataMod, SeqNo,        |
|               StoreName, StoreNumber                                       |
|                                                                            |
| LOCALS:       (none)                                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure InsertPLUAESExportTable(TypeValue : integer;  KeyValue, UPCNo, ModifierNo, KeyDscr : string; Count, Amount : currency);
begin
  Inc(SeqNo);
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.ADD('Insert Into AESExport( BusDate, StoreNumber, StoreName, SeqNo, Shift, TypeVal, KeyVal, UPCVal, ModifierVal, KeyDscr, TLCount, TLAmount )');
      SQL.ADD('Values (:pBusDate, :pStoreNumber, :pStoreName, :pSeqNo, :pShift, :pTypeVal, :pKeyVal, :pUPCVal, :pModifierVal, :pKeyDscr, :pTLCount, :pTLAmount)');
      ParamByName('pBusDate').AsDateTime := OpenDate;
      ParamByName('pStoreNumber').AsString := StoreNumber;
      ParamByName('pStoreName').AsString := StoreName;
      ParamByName('pSeqNo').AsInteger   := SeqNo;
      ParamByName('pShift').AsInteger   := AESShiftNo;
      ParamByName('pTypeVal').AsInteger := TypeValue;
      ParamByName('pKeyVal').AsString   := KeyValue;
      ParamByName('pUPCVal').AsString   := UPCNo;
      ParamByName('pModifierVal').AsString   := ModifierNo;
      ParamByName('pKeyDscr').AsString  := KeyDscr;
      ParamByName('pTLCount').AsCurrency  := Count;
      ParamByName('pTLAmount').AsCurrency := Amount;
      ExecSQL;
      Close;
    end;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    ImportAESValues                                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   CodeType, Dept, Descr, FoodStamp, ItemPrice, Modifier, UPCNo |
|                                                                            |
| CALLED BY:    CreateAESExportFile                                          |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      IBTempQuery, POSDataMod                                      |
|                                                                            |
| LOCALS:       (none)                                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure ImportAESValues(UPCNo,ItemPrice:Real; Descr,Dept,Modifier,FoodStamp,CodeType:string);
begin
  with POSDataMod.IBTempQuery do
  begin
    close;SQL.Clear;
    SQL.Add('Insert into PLU (PLUNo,UPC,NAME,Price,DeptNo,ModifierGroup,FS)');
    SQL.Add('Values (:PLUNo,:UPCNumber,:NameIn,:PriceIn,:DeptIn,:ModifierIn,:FoodStampIn) ');
    ParamByName('PLUNo').asstring := floattostr(UPCNo);
    if CodeType = 'P' then ParamByName('UPCNumber').asstring := '0'
    else ParamByName('UPCNumber').asstring := floattostr(UPCNo);
    ParamByName('NameIn').asstring := Descr;
    ParamByName('PriceIn').asstring := floattostr(ItemPrice);
    ParamByName('DeptIn').asstring := Dept;
    ParamByName('ModifierIn').asstring := '0';
    if foodstamp <> 'Y' then FoodStamp := '0';
    ParamByName('FoodStampIn').asstring := FoodStamp;
    try
      ExecSQL;
    except
      Close;SQL.Clear;
      if modifier <> '1' then
      begin
        SQL.Add('Update PLU SET UPC = :UPCNumber, NAME = :NameIn, SplitPrice = :PriceIn, ');
        SQL.Add('DeptNo = :DeptIn, SplitQty = :ModifierIn, FS = :FoodStampIn,ModifierGroup = :tempIn ');
        ParamByName('PriceIn').asstring := floattostr(ItemPrice);
        ParamByName('ModifierIn').asstring := Modifier;
        ParamByName('TempIn').asstring := '0';
      end
      else
      begin
        SQL.Add('Update PLU SET UPC = :UPCNumber, NAME = :NameIn, Price = :PriceIn, ');
        SQL.Add('DeptNo = :DeptIn, ModifierGroup = :TempIn, FS = :FoodStampIn ');
        ParamByName('PriceIn').asstring := floattostr(ItemPrice);
        ParamByName('TempIn').asstring := '0';
      end;
      SQL.Add('Where PLUNo = :UPCNumber');
      if CodeType = 'P' then ParamByName('UPCNumber').asstring := '0'
      else ParamByName('UPCNumber').asstring := floattostr(UPCNo);
      ParamByName('NameIn').asstring := Descr;
      ParamByName('DeptIn').asstring := Dept;
      if foodstamp = 'Y' then FoodStamp := '1' else FoodStamp := '0';
      ParamByName('FoodStampIn').asstring := FoodStamp;
      ExecSQL;
    end;
    close;
  end;
end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    CreateAESExportFile                                          |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   OpName, ShiftNo                                              |
|                                                                            |
| CALLED BY:    CreateExportFile                                             |
|                                                                            |
| CALLS:        ImportAESValues, InsertAESExportTable,                       |
|               InsertPLUAESExportTable, ShowMsg                             |
|                                                                            |
| GLOBALS:      AESData, AESImportQry, AESShiftNo, fmPOSMsg, IBTempQry1,     |
|               IBTempQuery, IBTempTrans1, IBTransaction, OpenDate,          |
|               POSDataMod, SeqNo, StoreName, StoreNumber                    |
|                                                                            |
| LOCALS:       aGTls, aHTls, aPTls, Day, Month, nCurPump, nFuelTotalID,     |
|               nHIdx, nPct, sLn, Year                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure CreateAESExportFile (ShiftNo : Integer; OpName : String);
var
  nFuelTotalID     : Integer;
  Year, Month, Day : Word;

  aHTls    : array[1..20,1..2] of Currency;
  aGTls   : array[1..20,1..2] of Currency;
  aPTls : array[1..20,1..2] of Currency;

  nHIdx : Integer;
  nPct : double;

 begin

  DecodeDate(Now, Year, Month, Day);
  SeqNo := 0;
  OpenDate := Now;
  AESShiftNo := ShiftNo;
  if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
  with POSDataMod.IBTempQry1 do
    begin
      Close; SQL.Clear;
      SQL.Add('Select * from setup');
      Open;
      StoreNumber := FieldByName('Number').AsString;
      StoreName   := FieldByName('Name').AsString;
      close;
    end;

  // *** Store Totals ***
  with POSDataMod.IBTempQry1 do
    begin
      Close; SQL.Clear;
      SQL.Add('Select * ');
        If ShiftNo > 0 Then
          SQL.Add('From Totals Where TotalNo = ' + IntToStr(ShiftNo))
        Else
          SQL.Add('From Totals Where TotalNo = 0');
      Open;

      // Write Reset Count

      InsertAESExportTable(1001, '', '', FieldByName('ResetCount').AsInteger, 0,0,0 ); //Reset Count

      // Write Current GT
      InsertAESExportTable(1002, '', '', 0, FieldByName('CurGT').AsCurrency,0,0 );

      // Write Beginning GT
      InsertAESExportTable(1003, '', '', 0, FieldByName('BegGT').AsCurrency,0,0 );

      // Write Total Daily Sales
      InsertAESExportTable(1004, '', '', 0, FieldByName('DlyDS').AsCurrency,0,0 );

      // Write Net Daily Sales
      InsertAESExportTable(1005, '', '', 0, FieldByName('DlyND').AsCurrency,0,0 );

      // Write Prepay Received
      InsertAESExportTable(1006, '', '', FieldByName('DlyPrePayCount').AsCurrency, FieldByName('DlyPrePayRcvd').AsCurrency,0,0 );

      // Write Prepay Used
      InsertAESExportTable(1007, '', '', FieldByName('DlyPrePayCountUsed').AsCurrency, FieldByName('DlyPrePayUsed').AsCurrency,0,0 );

      // Write Prepay Refund
      InsertAESExportTable(1008, '', '', FieldByName('DlyPrePayRfndCount').AsCurrency, FieldByName('DlyPrePayRfnd').AsCurrency,0,0 );

      // Write Transaction Count
      InsertAESExportTable(1009, '', '', FieldByName('DlyTransCount').AsCurrency, 0,0,0 );

      // Write Item Count
      InsertAESExportTable(1010, '', '', FieldByName('DlyItemCount').AsCurrency, 0,0,0 );

      // Write NoSale Count
      InsertAESExportTable(1011, '', '', FieldByName('DlyNoSaleCount').AsCurrency, 0,0,0 );

      // Write Voids
      InsertAESExportTable(1012, '', '', FieldByName('DlyVoidCount').AsCurrency, FieldByName('DlyVoidAmount').AsCurrency,0,0 );

      // Write Return
      InsertAESExportTable(1013, '', '', FieldByName('DlyRtrnCount').AsCurrency, FieldByName('DlyRtrnAmount').AsCurrency,0,0 );

      // Write Cancel
      InsertAESExportTable(1014, '', '', FieldByName('DlyCancelCount').AsCurrency, FieldByName('DlyCancelAmount').AsCurrency,0,0 );

      // Write Return Tax
      InsertAESExportTable(1015, '', '', 0, FieldByName('DlyReturnTax').AsCurrency,0,0 );

      // Write Non Tax
      InsertAESExportTable(1016, '', '', 0, FieldByName('DlyNoTax').AsCurrency,0,0 );

      Close;
    end;

  // *** Sales Tax ***
  with POSDataMod.IBTempQry1 do
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

              InsertAESExportTable(1500, FieldByName('TaxNo').AsString,
                                         FieldByName('Name').AsString,
                                         FieldByName('DlyTaxableSales').AsCurrency,
                                         FieldByName('DlyTaxCharged').AsCurrency,0,0 );
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end;

    // *** Discounts ***
  with POSDataMod.IBTempQry1 do
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
              InsertAESExportTable(1600, FieldByName('DiscNo').AsString,
                                         FieldByName('Name').AsString,
                                         FieldByName('DlyCount').AsCurrency,
                                         FieldByName('DlyAmount').AsCurrency,0,0 );
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end; {with TempQuery}

    // *** Mix Match Totals ***
  with POSDataMod.IBTempQry1 do
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
              InsertAESExportTable(1700, FieldByName('MMNo').AsString,
                                         FieldByName('Name').AsString,
                                         FieldByName('DlyCount').AsCurrency,
                                         FieldByName('DlyAmount').AsCurrency ,0,0);
            end;
          Next;
        end;  {while Not EOF}
      Close;
    end; {with TempQuery}

  // *** Dept Records ***
  with POSDataMod.IBTempQry1 do
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
          InsertAESExportTable(2000, FieldByName('DeptNo').AsString,
                                     FieldByName('Name').AsString,
                                     FieldByName('DlyCount').AsCurrency,
                                     FieldByName('DlySales').AsCurrency ,0,0);
          Next;
        end;
      Close;
    end; {with TempQuery - Dept}


  // *** Plu Records ***
  with POSDataMod.IBTempQry1 do
    begin
      Close; SQL.Clear;
      SQL.Add('Select PS.PluNo, Min(PS.PLUModifier) PLUModifier, Sum(PS.DlyCount) DlyCount, ' +
       'Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(P.DeptNo) DptNo, Min(P.UPC) UPCNo ' +
       'From PluShift PS Inner Join Plu P On (PS.PluNo = P.PluNo) ' +
       'Where PS.DlyCount <> 0  ');
      If ShiftNo > 0 Then
        SQL.Add('And PS.ShiftNo  = ' + IntToStr(ShiftNo) + ' ');
      SQL.Add('Group By PS.PluNo ');
      SQL.Add('Order By PS.PluNo');
      Open;

      while Not EOF do
        begin
          InsertPLUAESExportTable(3000, FieldByName('PLUNo').AsString,
                                     FieldByName('UPCNo').AsString,
                                     FieldByName('PLUModifier').AsString,
                                     FieldByName('Name').AsString,
                                     FieldByName('DlyCount').AsCurrency,
                                     FieldByName('DlySales').AsCurrency );
          Next;
        end;
      Close;
    end; {with TempQuery - PLU}

  // *** Media Records ***
  with POSDataMod.IBTempQry1 do
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
          InsertAESExportTable(4000, FieldByName('MediaNo').AsString,
                                     FieldByName('Name').AsString,
                                     FieldByName('DlyCount').AsCurrency,
                                     FieldByName('DlySales').AsCurrency ,0,0);
          Next;
        end;
      Close;
    end; {with TempQuery - Media}

  // *** Bank Function Records ***
  with POSDataMod.IBTempQry1 do
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
          InsertAESExportTable(5000, FieldByName('BankNo').AsString,
                                     FieldByName('Name').AsString,
                                     FieldByName('DlyCount').AsCurrency,
                                     FieldByName('DlySales').AsCurrency,0,0 );
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

  with POSDataMod.IBTempQry1 do
    begin
      Close; SQL.Clear;
      // Get Last Fuel Totals (TlNo)
      SQL.Add('SELECT Max(TlNo) FROM PumpTls');
      Open;
      nFuelTotalID := Fields[0].AsInteger;
      Close; SQL.Clear;
    end;
  // **** Get Fuel Totals ****
  with POSDataMod.IBTempQry1 do
    begin
      // Build SQL Statement
      SQL.Clear;
      SQL.Add('SELECT * FROM PumpTls T, Grade G, PumpDef D ');
      SQL.Add('WHERE (T.TlNo = ' + IntToStr(nFuelTotalID) + ') ' );
      SQL.Add('AND (T.PumpNo = D.PumpNo) AND (T.HoseNo = D.HoseNo) ');
      SQL.Add('AND (D.GradeNo = G.GradeNo) ');
      SQL.Add('ORDER BY T.PumpNo, T.HoseNo');
      Open;

//cwe      nCurPump := 0;
      while not EOF do {Begin Processing Query}
        begin
          InsertAESExportTable(9000, FieldByName('PumpNo').AsString + FieldByName('HoseNo').AsString,
                                     'Pump# ' + FieldByName('PumpNo').AsString + ' Hose# ' + FieldByName('HoseNo').AsString,
                                     FieldByName('VolumeTL').AsCurrency,
                                     FieldByName('CreditTL').AsCurrency + FieldByName('CashTl').AsCurrency,
                                     fieldbyname('CreditTL').ascurrency, fieldbyname('CashTL').ascurrency  );



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
             InsertAESExportTable(9100, IntToStr(nHIdx),
                                       'Hose# ' + IntToStr(nHIdx),
                                        aHTls[nHIdx,1],
                                        aHTls[nHIdx,2],0,0);
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
              InsertAESExportTable(9200, IntToStr(nHIdx),
                                         FieldByName('Name').AsString,
                                         aGTls[nHIdx,1],
                                         aGTls[nHIdx,2],0,0);
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
              InsertAESExportTable(9300, IntToStr(nHIdx),
                                         FieldByName('Name').AsString,
                                         aPTls[nHIdx,1],
                                         aPTls[nHIdx,2],0,0);
            end;
          Next;
        end; {while not EOF}
      Close;
    end;
  if POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.Commit;
  fmPOSMsg.ShowMsg('Importing AES2000 Updates...', '');
  PosDataMod.Aesdata.Connected := true;
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    close;SQL.Clear;
    SQL.Add('Select * from SetUp');
    open;
    with POSDataMod.AESImportQry do
    begin
      close;
      // Build SQL Statement
      SQL.Clear;
      SQL.Add('Select * from AES.PosDeviceItemUpdate ');
      SQL.Add('where StoreID = :InId');
      ParamByName('InId').asstring := POSDataMod.IBTempQuery.fieldbyname('Number').value;
      open;
      //execsql;
      while not eof do
      begin
        ImportAESValues(fieldbyname('code').AsCurrency, fieldbyname('Price').AsCurrency, fieldbyname('Descr').asstring,
        fieldbyname('POSDeptCode').asstring, fieldbyname('Modifier').asstring,
        fieldbyname('FoodStampFlag').asstring,fieldbyname('codetype').asstring);
        next;
      end;
      close;
    end;
    close;
  end;
  PosDataMod.AesData.Connected := false;
  POSDataMod.AESData.Close;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
end; {end procedure CreateExportFile}

//**************** Import goes here *******************

end. 

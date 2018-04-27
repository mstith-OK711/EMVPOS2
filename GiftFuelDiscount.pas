unit GiftFuelDiscount;

{$I ConditionalCompileSymbols.txt}

interface
uses SysUtils;
  {$IFDEF CASH_FUEL_DISC}
  function ApplyDiscount(const DiscNo : integer; const SearchLineType : string; const QualifyingMedia : currency) : currency;
  procedure DropGiftFuelDiscount(const SearchLineType : string);
  {$ELSE}
  function ApplyDiscount(DiscNo : integer) : currency;
  procedure DropGiftFuelDiscount;
  {$ENDIF}

implementation
uses POSDM, POSMain, LatTypes;


{$IFDEF CASH_FUEL_DISC}
function ApplyDiscount(const DiscNo : integer; const SearchLineType : string; const QualifyingMedia : currency) : currency;
{$ELSE}
function ApplyDiscount(DiscNo : integer) : currency;
{$ENDIF}
//20060614...
//var
//  Ret : currency;
//const
//  MAX_GRADE_NUMBER = 5;
var
  j : integer;
  RetVal : array [0..MAX_GRADE_NUMBER] of currency;
  iGradeNo : integer;
  GradeDiscAmount : currency;
  GradeDiscExtPrice : currency;
  TotalDiscExtPrice : currency;
//...20060614
  DiscAmount : Currency;
  Ndx : byte;
  TotalQualifyingMedia : currency;
//  {$IFDEF FUEL_PRICE_ROLLBACK}
//  CheckSaleData : pSalesData;
//  {$ENDIF}
  CurSaleData : pSalesData;
begin
  //20060614...
//  Ret := 0;
  TotalDiscExtPrice := 0.0;
  {$IFDEF CASH_FUEL_DISC}
  // If media that qualifies for the discount has been tendered.
  if (QualifyingMedia > 0.0) then
  begin
  {$ENDIF}
    for j := 0 to MAX_GRADE_NUMBER do
    begin
      RetVal[j] := 0.0;
    end;
    //...20060614
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      close;SQL.Clear;
      SQL.Add('Select * from Disc where RecType = ''F'' and DiscNo = :pDiscNo');
      parambyname('pDiscNo').AsInteger := DiscNo;
      open;
      if RecordCount > 0 then
        DiscAmount := fieldbyname('Amount').AsCurrency
      else
        DiscAmount := 0;
      close;
    end;
    if DiscAmount > 0 then
    begin
      if fmPos.CurSaleList.Count > 0 then
      begin
        TotalQualifyingMedia := QualifyingMedia;  // Will sum up media below (current tender not yet in sales list)
        {$IFDEF CASH_FUEL_DISC}
        for Ndx := 0 to fmPos.CurSaleList.Count - 1 do
        begin
          CurSaleData := fmPos.CurSaleList.Items[Ndx];
          if (CurSaleData^.LineType = 'MED') then
          begin
            // Sum up any previous qualifying media tendered
            if (((SearchLineType = 'DSG') and (Round(CurSaleData^.Number) = StrToInt(sGiftcardMediaNo)))
                                                    or
                ((SearchLineType = 'DS$') and (Round(CurSaleData^.Number) = CASH_MEDIA_NUMBER))) then
              TotalQualifyingMedia := TotalQualifyingMedia + CurSaleData^.ExtPrice;
          end
          else if (CurSaleData^.LineType = SearchLineType) then
          begin
            // Pre-remove total for any previously applied discounts (all qualified discounts will be
            // re-calculated below causing these to re-sum upward towards zero.
            j := Round(CurSaleData^.Number) - DiscNo;  // "Number" field is DiscNo plus grade.
            if (not (j in [Low(RetVal)..High(RetVal)])) then
              j := Low(RetVal);
            RetVal[j] := RetVal[j] + CurSaleData^.ExtPrice;  // A discount, so adding negative value.
          end;
        end;
        {$ENDIF}
        for Ndx := 0 to fmPos.CurSaleList.Count - 1 do
        begin
          CurSaleData := fmPos.CurSaleList.Items[Ndx];
          if CurSaleData^.LineType = 'FUL' then
          begin
            TotalQualifyingMedia := TotalQualifyingMedia - CurSaleData^.ExtPrice;
            if (TotalQualifyingMedia < 0.0) then
              break;  // Not enough qualifying media left for applying fuel discounts
  //          {$IFDEF FUEL_PRICE_ROLLBACK}
  //          // Check to see if discount already applied.
  //          for j := Ndx + 1 to CurSaleList.Count - 1 do
  //          begin
  //          end;
  //          {$ENDIF}
            //Ret := Ret + ((CurSaleData^.Qty - Frac(CurSaleData^.Qty)) * DiscAmount);
            //20060614...
  //          Ret := Ret + strtocurr(formatfloat('##0.00',(CurSaleData^.Qty * DiscAmount)));
            // Determine fuel grade from database based on the fuel sale ID in the sales list
            //   and accumulate discount by grade.
            with POSDataMod.IBTempQuery do
            begin
              try
                Close();
                SQL.Clear();
                SQL.Add('Select GradeNo from FuelTran f join PumpDef p');
                SQL.Add(' on f.PumpNo = p.Pumpno and f.HoseNo = f.HoseNo');
                SQL.Add(' where f.SaleID = :pSaleID and f.HoseNo = p.HoseNo');
                ParamByName('pSaleID').AsInteger := CurSaleData^.FuelSaleID;
                Open();
                if RecordCount > 0 then iGradeNo := FieldByName('GradeNo').AsInteger
                else                    iGradeNo := 0;
              except
                iGradeNo := 0;
              end;
              // Determine the discount that applies to the grade.
              GradeDiscAmount := DiscAmount;   // Default assumption (in case no discount for grade found below)
              if (iGradeNo > 0) then
              begin
                with POSDataMod.IBTempQuery do
                begin
                  try
                    Close();
                    SQL.Clear();
                    SQL.Add('Select * from Disc where RecType = ''F'' and DiscNo = :pDiscNo');
                    ParamByName('pDiscNo').AsInteger := DiscNo + iGradeNo;
                    Open();
                    if (RecordCount > 0) then
                      GradeDiscAmount := FieldByName('Amount').AsCurrency
                    else
                      iGradeNo := 0;  //GradeDiscAmount := DiscAmount;
                  except
                    iGradeNo := 0;  //GradeDiscAmount := DiscAmount;
                  end;
                end;  // with
  //            end
  //            else  // i.e., no grade number identified, so use default discount.
  //            begin
  //              GradeDiscAmount := DiscAmount;
              end;
              Close();
            end;  // with
            GradeDiscExtPrice := StrToCurr(formatfloat('##0.00',(CurSaleData^.Qty * GradeDiscAmount)));
            TotalDiscExtPrice := TotalDiscExtPrice + GradeDiscExtPrice;
            RetVal[iGradeNo] := RetVal[iGradeNo] + GradeDiscExtPrice;
            //...20060614
          end;  // if CurSaleData^.LineType = 'FUL'
        end;  /// for Ndx := 0 to CurSaleList.Count - 1
      end;  // if CurSaleList.Count > 0
    end;  // if DiscAmount > 0
    //20060614...
  //  if Ret > 0 then
    for j := 0 to MAX_GRADE_NUMBER do
    begin
      if RetVal[j] > 0 then
    //...20060614
      begin
        {$IFDEF CASH_FUEL_DISC}
        sLineType := SearchLineType;
        {$ELSE}
        sLineType := 'DSG';
        {$ENDIF}
        sSaleType := 'Sale';    {Sale, Void, Rtrn, VdVd, VdRt}
        nDiscNo := DiscNo + j;
        nDiscType := 'F';
        nQty   := 1;
        //20060614...
  //      nAmount := -Ret;
        nAmount := -RetVal[j];
        //...20060614
        fmPOS.AddGiftFuelDisc;
      end;
    end;  //20060614
  {$IFDEF CASH_FUEL_DISC}
  end;  // if (QualifyingMedia > 0.0)
  {$ENDIF}
  ApplyDiscount := TotalDiscExtPrice;
end;

{$IFDEF CASH_FUEL_DISC}
procedure DropGiftFuelDiscount(const SearchLineType : string);
{$ELSE}
procedure DropGiftFuelDiscount;
{$ENDIF}
var
  Ndx : byte;
  CurSaleData : pSalesData;
begin
  if fmPos.CurSaleList.Count > 0 then
  begin
    for Ndx := 0 to fmPos.CurSaleList.Count - 1 do
    begin
      CurSaleData := fmPos.CurSaleList.Items[Ndx];
      {$IFDEF CASH_FUEL_DISC}
      if CurSaleData^.LineType = SearchLineType then
      {$ELSE}
      if CurSaleData^.LineType = 'DSG' then
      {$ENDIF}
        fmPOS.VoidGiftFuelDisc;
    end;
  end;
end;

end.

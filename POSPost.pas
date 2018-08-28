{-----------------------------------------------------------------------------
 Unit Name: POSPost
 Author:    Gary Whetton
 Date:      4/13/2004 4:11:34 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSPost;

{$I ConditionalCompileSymbols.txt}

interface

uses
  LatTypes,
  Classes
  ;


procedure PostPrePayToDB(PumpNo, HoseNo, SaleID : integer; SaleVolume, SaleAmount, PrePayAmount : currency);

procedure PostSale(const PostSaleList : TNotList);
procedure PostNoSale(TerminalNo : smallint; ShiftNo : integer);
procedure PostCancel(const CurSaleList : TList; TransNo : integer; TerminalNo : smallint; ShiftNo : integer; Total : currency);
procedure PostSalesRptExec(TerminalNo : smallint; ShiftNo : integer);
procedure InitShiftTotals(TerminalNo, ShiftNo : integer);
procedure IncrementTillTimeout(OpenTime : TDateTime; TimeoutSecs : integer);

var
  nVoidCount : integer;
  nRtrnCount : integer;
  nVoidAmount : currency;
  nRtrnAmount : currency;
  bFuelItem, bMdseItem : boolean;

implementation

uses POSDM, ExceptLog, IBSQL, SysUtils, Math, DBInt, JclHashMapsCustom, CWAccess, POSMain;


procedure AllocateFuelAcrossMedia(const PostSaleList : TList); forward;

function DBUpdateMedia(const DayId : integer; const qSaleData : pSalesData) : boolean; forward;

procedure PostDiscount(const DayId : integer; const qSalesData : pSalesData); forward;
{$IFDEF PDI_PROMOS}
Procedure PostPDIPromo(PPCur : TIBSQLBuilder ; const DayId : integer; const qSalesData : pSalesData); forward;
{$ENDIF}
Procedure PostNormalDisc(PPCur : TIBSQLBuilder ; const DayId : integer; const qSalesData : pSalesData); forward;

procedure PostPrePayToXMD(SaleID, GradeDeptLink : Integer); forward;


{-----------------------------------------------------------------------------
  Name:      IncrementTillTimeout
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: OpenTime : TDateTime; TimeoutSecs : integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure IncrementTillTimeout(OpenTime : TDateTime; TimeoutSecs : integer);
var
CloseTime : TDateTime;
RepeatCount, x : smallint;
TimeIncr : double;
IncrCount : integer;
begin
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  CloseTime := Now;
  TimeIncr  := TimeOutSecs / 86400;
  OpenTime := OpenTime + TimeIncr;
  IncrCount := 0;
  for x := 1 to 1000 do
  begin
    if OpenTime >= CloseTime then
      break;
    OpenTime := OpenTime + TimeIncr;
    Inc(IncrCount);
  end;

  Dec(IncrCount); //allows for first TimeOut which is the allowed time for the drawer to be opened
  RepeatCount := 1;
  while True do
    begin
      try
        if not POSDataMod.IBPostTransaction.InTransaction then
          POSDataMod.IBPostTransaction.StartTransaction;
        // UPDATE Totals: Store and Shift
        with POSDataMod.IBPostSQL do
          begin
            Close;
            SQL.Clear;
            SQL.Add('UPDATE Totals SET ' +
             'TillTimeOutCount = TillTimeOutCount + :pIncrCount ' +
             'WHERE (TotalNo = 0) Or ((ShiftNo = :pShift) and (TerminalNo = :pTerminalNo))');
            ParamByName('pShift').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pIncrCount').AsInteger := IncrCount;
            ExecQuery;
          end;
        POSDataMod.IBPostTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Update TillTimeOutCount ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBPostTransaction.InTransaction then
              POSDataMod.IBPostTransaction.Rollback;
            sleep(100);
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end;
    end;  //end while true
end;


{-----------------------------------------------------------------------------
  Name:      PostPrePayToDB
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: PumpNo, HoseNo, SaleID : integer; SaleVolume, SaleAmount, PrePayAmount : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PostPrePayToDB(PumpNo, HoseNo, SaleID : integer; SaleVolume, SaleAmount, PrePayAmount : currency);
var
  GradeDeptLink: Integer;
  Repeatcount : smallint;
  HadToOpenDB : boolean;
  PPCur : TIBSQLBuilder;
  DayId : integer;
begin
  PPCur := POSDataMod.PosPostCur;

  HadToOpenDB := False;
  if SaleAmount > 0 then
  begin
    bPostingPrepaySale := True;
    if POSDataMod.IBDB.TestConnected = False then
      begin
        fmPOS.OpenTables(False);
        HadToOpenDB := True;
      end;
    RepeatCount := 1;
    while True do
    begin
      PPCur.StartTransaction;
      try
        UpdateZLog('PostPrePayToDB Starting');
        with PPCur['GetDayId'] do
        begin
          ExecQuery;
          DayId := FieldByName('DayId').AsInteger;
          Close;
        end;
        with PPCur['PPYUsedUpdate'] do
        begin
          ParamByName('pUsed').AsCurrency := SaleAmount;
          ParamByName('pShift').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          ExecQuery;
          Close;
        end;
        with PPCur['GetDeptForHose'] do
        begin
          ParamByName('pPumpNo').AsInteger := PumpNo;
          ParamByName('pHoseNo').AsInteger := HoseNo;
          ExecQuery;
          GradeDeptLink := 0;
          if RecordCount > 0 then  // No Match
          begin
            GradeDeptLink := FieldByName('DeptNo').AsInteger;
          end;
          Close;
        end;
        if GradeDeptLink > 0 then
        begin
          with PPCur['DepShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pDeptNo').AsInteger := GradeDeptLink;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pDlyCount').AsCurrency  := SaleVolume;
            ParamByName('pDlySales').AsCurrency  := SaleAmount;
            ParamByName('pAdjCount').AsCurrency  := 0;
            ParamByName('pAdjAmount').AsCurrency  := 0;
            ExecQuery;
            Close;
          end; {with}
          with PPCur['GradeUpdate'] do
          begin
            ParamByName('pVol').AsCurrency    := SaleVolume;
            ParamByName('pAmount').AsCurrency := SaleAmount;
            ParamByName('pDeptNo').AsInteger  := GradeDeptLink;
            ExecQuery;
            Close;
          end;

        end; {with TempQuery}
        PPCur.Commit();
        //XMD
        if bXMDActive then
          PostPrePayToXMD(SaleID, GradeDeptLink);
        //XMD
        if bLogging then UpdateZLog('PostPrePayToDB Complete');
        break;
      except
        on E : Exception do
        begin
          UpdateExceptLog( 'Rollback Post PrePay ' + IntToStr(RepeatCount) + ' ' + e.message);
          if PPCur.Transaction.InTransaction then
            PPCur.Rollback;
          sleep(100);
          Inc(RepeatCount);
          if RepeatCount > 100 then
          begin
            UpdateExceptLog('Rollback Posting PrePay ' + e.message);
            if bLogging then UpdateZLog('Post PrePay Failed');
            break;
          end;
        end;
      end; {if FI^.PumpSale1Amount > 0}
    end;  //end while true
  end;

  if SaleAmount = PrePayAmount then
  begin
    {if the amounts are equal then free the pumnp}
    fmPOS.SendFuelMessage(PumpNo, PMP_PAID, NOAMOUNT, SaleID, NOTRANSNO, NODESTPUMP);
  end;

  if HadToOpenDB then
  begin
    fmPOS.CloseTables;
  end;

  bPostingPrepaySale := False;


end; {procedure PostPrePay}

procedure AllocateFuelAcrossMedia(const PostSaleList : TList);
{
Allocate fuel amounts from a sale accross various media tendered.
The exact customer intent is not always known on split tenders; however, the
idea is to use a priority system to allocate the total fuel amounts.
}
var
  qSalesData : pSalesData;
  j : integer;
  TotalFuel : currency;
  MediaToAllocate : currency;
  PreviousFuelAmount : currency;
  GiftDiscountedFuelAmount : currency;
  SaleAmountToAllocate : currency;
  idxFirstMediaLine : integer;
  SignTotalFuel : currency;
  idxLastMediaLine : integer;
  TaxToAllocate : currency;
  TotalMedia : currency;
  TaxableMedia : currency;
  SignTaxableMedia : currency;
begin
  // Total up the fuel purchased (exclude any discounted amounts).
  // Also calculate a sub-total to represent any gift card discounted fuel amounts (excluding discount).
  TotalFuel := 0.0;
  TotalMedia := 0.0;
  idxLastMediaLine := -1;
  PreviousFuelAmount := 0.0;
  GiftDiscountedFuelAmount := 0.0;
  idxFirstMediaLine := 0;
  for j := 0 to (PostSaleList.Count - 1) do
  begin
    qSalesData := PostSaleList.Items[j];
    if (not qSalesData^.LineVoided) then
    begin
      if (((qSalesData^.LineType = 'FUL') or (qSalesData^.LineType = 'PPY') or (qSalesData^.LineType = 'PRF')) and
          (qSalesData^.SaleType = 'Sale')) then
      begin
        TotalFuel := TotalFuel + qSalesData^.ExtPrice;
        PreviousFuelAmount := qSalesData^.ExtPrice;
      end
      else if (((qSalesData^.LineType = 'DSG') or
                (qSalesData^.LineType = 'DS$')) and (qSalesData^.SaleType = 'Sale')) then
      begin
        TotalFuel := TotalFuel + qSalesData^.ExtPrice;
        if (qSalesData^.LineType = 'DSG') then  // Keep track of gift discounts (to be allocated first)
          GiftDiscountedFuelAmount := GiftDiscountedFuelAmount + PreviousFuelAmount + qSalesData^.ExtPrice;
      end
      else if ((qSalesData^.LineType = 'DPT') and (qSalesData^.SaleType = 'Sale')) then
      begin
        // Department sale:  Check for manual fuel purchase.
        with POSDataMod.IBTempQuery do
        begin
          try
            if (not Transaction.InTransaction) then
              Transaction.StartTransaction();
            Close();
            SQL.Clear();
            SQL.Add('select DeptNo from Dept D join Grp G on D.GrpNo = G.GrpNo');
            SQL.Add(' where D.DeptNo = :pDeptNo and G.Fuel = :pFuel');
            ParamByName('pDeptNo').AsCurrency := qSalesData^.Number;
            ParamByName('pFuel').AsInteger := 1;
            Open();
            if (not EOF) then
              TotalFuel := TotalFuel + qSalesData^.ExtPrice;
            Close();
            if (Transaction.InTransaction) then
              Transaction.Commit();
          except
            on E : Exception do
            begin
              if (Transaction.InTransaction) then
                Transaction.Rollback();
              UpdateExceptLog( 'AllocateFuelAcrossMedia - cannot query for fuel dept: ' + e.message);
            end;
          end;
        end;  // with
      end  // if department sale
      else if (qSalesData^.LineType = 'MED') then
      begin
        qSalesData^.SplitPrice := 0.0;
        qSalesData^.Taxable := 0.0;
        TotalMedia := TotalMedia + qSalesData^.ExtPrice;
        idxLastMediaLine := j;
        if (idxFirstMediaLine = 0) then
          idxFirstMediaLine := j;  // Remaining searches through sales list can start here
      end;
    end;  // if non-voided item
  end;  // for each item in PostSaleList

  // The sign used in some of the arithmetic below is reversed for pre-pay refunds.
  if (TotalFuel > 0.0) then
    SignTotalFuel := 1.0
  else
    SignTotalFuel := -1.0;
  MediaToAllocate := Abs(TotalFuel);

  // Allocate fuel amounts to cards that resulted in any fuel discounts
  if ((GiftDiscountedFuelAmount > 0.0) and (SignTotalFuel > 0.0)) then
  begin
    for j := idxFirstMediaLine to (PostSaleList.Count - 1) do
    begin
      qSalesData := PostSaleList.Items[j];
      if (not qSalesData^.LineVoided) then
      begin
        if ((qSalesData^.LineType = 'MED') and
            (qSalesData^.ExtPrice > 0.0) and
            (qSalesData^.SplitPrice < qSalesData^.ExtPrice) and
            (Round(qSalesData^.Number) = DEFAULT_GIFT_CARD_MEDIA_NUMBER)) then
        begin
          SaleAmountToAllocate := Min((qSalesData^.ExtPrice - qSalesData^.SplitPrice), GiftDiscountedFuelAmount);
          qSalesData^.SplitPrice := qSalesData^.SplitPrice + SaleAmountToAllocate;
          MediaToAllocate := MediaToAllocate - SaleAmountToAllocate;
          GiftDiscountedFuelAmount := GiftDiscountedFuelAmount - SaleAmountToAllocate;
          if (GiftDiscountedFuelAmount <= 0.0) then
            break;
        end;
      end;
    end;
  end;

  // Allocate (as much as possible) any remaining fuel amounts to any authorized credit/debit/gift cards.
  if (MediaToAllocate > 0.0) then
  begin
    for j := idxFirstMediaLine to (PostSaleList.Count - 1) do
    begin
      qSalesData := PostSaleList.Items[j];
      if (not qSalesData^.LineVoided) then
      begin
        if ((qSalesData^.LineType = 'MED') and
            ((SignTotalFuel * qSalesData^.ExtPrice) > 0.0) and
            (Abs(qSalesData^.SplitPrice) < Abs(qSalesData^.ExtPrice)) and
            (Round(qSalesData^.Number) in [CREDIT_MEDIA_NUMBER,
                                           DEBIT_MEDIA_NUMBER,
                                           DEFAULT_GIFT_CARD_MEDIA_NUMBER])) then
        begin
          SaleAmountToAllocate := Min(Abs(qSalesData^.ExtPrice - qSalesData^.SplitPrice), MediaToAllocate);
          qSalesData^.SplitPrice := qSalesData^.SplitPrice + (SignTotalFuel * SaleAmountToAllocate);
          MediaToAllocate := MediaToAllocate - SaleAmountToAllocate;
          if (MediaToAllocate <= 0.0) then
            break;
        end;
      end;
    end;

    // Allocate any remaining fuel amounts to non-card payment types (such as cash)
    if (MediaToAllocate > 0.0) then
    begin
      for j := idxFirstMediaLine to (PostSaleList.Count - 1) do
      begin
        qSalesData := PostSaleList.Items[j];
        if (not qSalesData^.LineVoided) then
        begin
          if ((qSalesData^.LineType = 'MED') and
              ((SignTotalFuel * qSalesData^.ExtPrice) > 0.0) and
              (Abs(qSalesData^.SplitPrice) < Abs(qSalesData^.ExtPrice))) then
          begin
            SaleAmountToAllocate := Min(Abs(qSalesData^.ExtPrice - qSalesData^.SplitPrice), MediaToAllocate);
            qSalesData^.SplitPrice := qSalesData^.SplitPrice + (SignTotalFuel * SaleAmountToAllocate);
            MediaToAllocate := MediaToAllocate - SaleAmountToAllocate;
            if (MediaToAllocate <= 0.0) then
              break;
          end;
        end;
      end;  // for each item in sales list
    end;  // if (MediaToAllocate > 0.0)
  end;   // if (MediaToAllocate > 0.0)

  // Now that fuel amounts have been allocated accross all media used in this sale,
  // distribute the tax amounts porportional to the non-fuel amounts allocated to each media.

  TaxToAllocate := Abs(pstSale.nTlTax);
  TaxableMedia := TotalMedia - TotalFuel - pstSale.nTlTax - pstSale.nChangeDue;
  if (TaxableMedia < 0) then
    SignTaxableMedia := -1
  else
    SignTaxableMedia := 1;
  if (TaxableMedia <> 0) then
  begin
    for j := idxFirstMediaLine to idxLastMediaLine - 1 do
    begin
      qSalesData := PostSaleList.Items[j];
      if (not qSalesData^.LineVoided) then
      begin
        if (qSalesData^.LineType = 'MED') then
        begin
          qSalesData^.Taxable := Round(((qSalesData^.ExtPrice - qSalesData^.SplitPrice) /
                                        TaxableMedia) * pstSale.nTlTax * 100.0) / 100.0;
          TaxToAllocate := TaxToAllocate - (SignTaxableMedia * qSalesData^.Taxable);
        end;
      end;
    end;
  end;
  if ((idxLastMediaLine >= 0) and (idxLastMediaLine < PostSaleList.Count)) then
  begin
    qSalesData := PostSaleList.Items[idxLastMediaLine];
    qSalesData^.Taxable := SignTaxableMedia * TaxToAllocate;  // Last media line gets remainder (to prevent roundoff error).
  end;
end;  //  procedure AllocateFuelAcrossMedia

{
procedure GetMinMaxTime(const PPCur : TIBSQLBuilder; var MinTime, MaxTime : TDateTime);
begin
  UpdateZLog('POSPost.GetMinMaxTime: get Max/Min Time');
  with PPCur['MaxTimeFind'] do
  begin
    ExecQuery;
    MaxTime := FieldByName('MaxTime').AsDateTime;
    Close;
  end;
  with PPCur['MinTimeFind'] do
  begin
    ParamByName('pTrxTime').AsDateTime := Time;
    ExecQuery;
    MinTime := FieldByName('MinTime').AsDateTime;
    Close;
  end;
  UpdateZLog('POSPost.GetMinMaxTime: get Max/Min Time done');
end;
}

{-----------------------------------------------------------------------------
  Name:      PostSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PostSale(const PostSaleList : TNotList);
var
  PLUIsValid : integer;
  nPostNdx: byte;
  Repeatcount : smallint;
  RecType : integer;
  ST : pSalesTax;
  t : integer;
  DayId : integer;
  pludept : integer;
  nFuelCount  : integer;
  nFuelAmount : currency;
  nMdseCount  : integer;
  nMdseAmount : currency;
  nFMCount    : integer;
  nFMAmount   : currency;
  nAdjCount   : Currency;
  nAdjAmount  : Currency;

  MaxTime: TDateTime;
  MinTime: TDateTime;

//bph...
//begin
  bReTendering : boolean;
  DelayCount : integer;
  bNeedInsert : boolean;            //20070216
  {$IFDEF PDI_PROMOS}
  LastPromo : integer;        //20070312
  QtySold : integer;        //20070313
  {$ENDIF}
  {$IFDEF FUEL_PRICE_ROLLBACK}
  cAmountOnPump : currency;
  cPriceOnPump : currency;
  iGradeOnPump : integer;
  DiscountSalesData : TSalesData;
  {$ENDIF}
  PPCur : TIBSQLBuilder;
begin {PostSale}
  PPCur := POSDataMod.PosPostCur;
  if not POSDataMod.IBDB.TestConnected then
    fmPOS.OpenTables(False);
  // Let the pin pad class know that the previous transaction is over.
  try
     if ((fmPOS.PPTrans <> nil)) then
       fmPOS.PPTrans.TransNo := 0;
  except
  end;
  AllocateFuelAcrossMedia(PostSaleList);
  bReTendering := False;  // Assume this is an initial tender for a sale.
//..bph
  if (PostSaleList.Count > 0) then
  for nPostNdx := 0 to (PostSaleList.Count - 1) do
  begin
    PostSaleData := PostSaleList.Items[nPostNdx];
    //bph...
//    if PostSaleData^.LineType = 'FUL' then
    // See if this is a re-tender of a previous sale.  If it is, then only update new
    // media amounts (other amounts are already in database).
    if (PostSaleData^.CCRequestType = RT_PURCHASE_REVERSE) then
      begin
        bReTendering := True;
      end
    else if PostSaleData^.LineType = 'FUL' then
    //...bph
    begin
      if (PostSaleData^.SaleType = 'Sale') and (PostSaleData^.LineVoided = False) then
      begin
        fmPOS.SendFuelMessage(PostSaleData^.PumpNo, PMP_PAID, NOAMOUNT, PostSaleData^.FuelSaleID, pstSale.nTransNo, NODESTPUMP );
      end;
    end
    else if PostSaleData^.LineType = 'PPY' then
    begin
      if (PostSaleData^.SaleType = 'Sale') and (PostSaleData^.LineVoided = False) then
      begin
        fmPOS.SendFuelMessage(PostSaleData^.PumpNo, PMP_POSPREPAY, PostSaleData^.ExtPrice, NOSALEID, pstSale.nTransNo, NODESTPUMP);
      end;
    end
    else if PostSaleData^.LineType = 'PRF' then
    begin
      if (PostSaleData^.SaleType = 'Sale') and (PostSaleData^.LineVoided = False) then
      begin
        fmPOS.SendFuelMessage(PostSaleData^.PumpNo, PMP_PAID, NOAMOUNT, PostSaleData^.FuelSaleID, pstSale.nTransNo, NODESTPUMP);
      end;
    end;
  end;
  RepeatCount := 1;
  while True do
  begin
    try
      PPCur.StartTransaction;
      with PPCur['GetDayId'] do
      begin
        ExecQuery;
        DayId := FieldByName('DayId').AsInteger;
        Close;
      end;
      nVoidCount := 0;
      nVoidAmount := 0;
      nRtrnCount := 0;
      nRtrnAmount := 0;
      {$IFDEF PDI_PROMOS}
      LastPromo := 0;   //20070312
      {$ENDIF}
      bFuelItem := False;
      bMdseItem := False;
      if (PostSaleList.Count > 0) then
      for nPostNdx := 0 to (PostSaleList.Count - 1) do
      begin
        PostSaleData := PostSaleList.Items[nPostNdx];
        UpdateZLog(Format('POSPost.PostSale: Posting line %d - %s %s',[nPostNdx + 1,PostSaleData^.LineType, PostSaleData^.SaleType]));
        if ((PostSaleData^.LineType = 'MED') and
            (PostSaleData^.CCRequestType <> RT_PURCHASE_REVERSE) and
            (Trim(PostSaleData^.SaleType) <> 'Void')) then
        begin  // MED
          if (not DBUpdateMedia(DayId, PostSaleData)) then abort;
        end    // MED
        else if (bReTendering) then
        begin  // Retendering
          // When re-tendering, skip db updates except for media.
        end
        else if PostSaleData^.LineType = 'DPT' then
        begin  // DPT
          bMdseItem := True;
          //execute procedure DepShiftMerge(:pdayid, :pdeptno, :pterminalno, :pshiftno, :pdlycount, :pdlysales, :padjcount, :padjamount)
          with PPCur['DepShiftMerge'] do
          begin
            ParamByName('pdayid').AsInteger := dayid;
            ParamByName('pDeptNo').AsInteger := Trunc(PostSaleData^.Number);
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pDlyCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pDlySales').AsCurrency := PostSaleData^.ExtPrice;
            ParamByName('padjcount').AsCurrency := 0;
            ParamByName('padjamount').AsCurrency := 0;
            ExecQuery;
            Close;
          end;
          // Update Void and Return Totals
          if PostSaleData^.SaleType = 'Void' then
          begin
            nVoidCount := nVoidCount + Trunc(PostSaleData^.Qty);
            nVoidAmount := nVoidAmount + (PostSaleData^.ExtPrice * -1) ;
          end
          else if PostSaleData^.SaleType = 'Rtrn' then
          begin
            nRtrnCount := nRtrnCount + Trunc(PostSaleData^.Qty);
            nRtrnAmount := nRtrnAmount + (PostSaleData^.ExtPrice * -1) ;
          end;
        end    // DPT
        else if PostSaleData^.LineType = 'FUL' then
        begin  // FUL
          bFuelItem := True;
          with PPCur['GradeUpdate'] do
          begin
            ParamByName('pVol').AsCurrency    := PostSaleData^.Qty;
            ParamByName('pAmount').AsCurrency := PostSaleData^.ExtPrice;
            ParamByName('pDeptNo').AsInteger  := Trunc(PostSaleData^.Number);
            ExecQuery;
            Close;
          end;
          with PPCur['DepShiftMerge'] do
          begin
            ParamByName('pdayid').AsInteger := dayid;
            ParamByName('pDeptNo').AsInteger := Trunc(PostSaleData^.Number);
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pDlyCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pDlySales').AsCurrency := PostSaleData^.ExtPrice;
            ParamByName('padjcount').AsCurrency := 0;
            ParamByName('padjamount').AsCurrency := 0;
            ExecQuery;
            Close;
          end;
          {$IFDEF FUEL_PRICE_ROLLBACK}
          if PostSaleData^.SaleType = 'Sale' then
          begin
            // If amount for fuel on sales list differs from that from the pump, then
            // a discount (*) may apply.
            // (*) Typically the "discount" is negative (indicating a surcharge included when the fuel is pumped
            //     at a discounted price, but paid for inside with a media that does not qualify for the discount.
            try
              with PPCur['PumpAmountFind'] do
              begin
                ParamByName('pSaleID').AsInteger := PostSaleData^.FuelSaleID;
                ExecQuery;
                if (not EOF) then
                begin
                  cAmountOnPump := FieldByName('Amount').AsCurrency;
                  cPriceOnPump := FieldByName('UnitPrice').AsCurrency;
                  iGradeOnPump := FieldByName('GradeNo').AsInteger;
                end
                else
                begin
                  cAmountOnPump := 0.0;
                  cPriceOnPump := 0.0;
                  iGradeOnPump := 0;
                end;
                Close();
              end;  //with
            except
              on E : Exception do
              begin
                UpdateExceptLog( 'PostSale - cannot access FuelTran - ' + e.message);
                cAmountOnPump := 0.0;
                cPriceOnPump := 0.0;
                iGradeOnPump := 0;
                // FIXME: May need a raise here
              end;
            end;

            // If a discount (or surcharge) is detected, then log it.
            if ((cAmountOnPump > 0.0) and (cAmountOnPump <> PostSaleData^.ExtPrice)) then
            begin
              DiscountSalesData.SeqNumber := PostSaleList.Count + 1;
              DiscountSalesData.LineType := 'DSC';
              DiscountSalesData.SaleType := 'Sale';
              DiscountSalesData.Number := CASH_EQUIV_FUEL_DISC_NO + iGradeOnPump;
              DiscountSalesData.Name := 'Payment Override';
              DiscountSalesData.Qty := PostSaleData^.Qty;
              DiscountSalesData.Price := PostSaleData^.Price - cPriceOnPump;
              DiscountSalesData.ExtPrice := PostSaleData^.ExtPrice - cAmountOnPump;
              DiscountSalesData.FuelSaleID := PostSaleData^.FuelSaleID;
              DiscountSalesData.PumpNo := PostSaleData^.PumpNo;
              DiscountSalesData.HoseNo := PostSaleData^.HoseNo;
              DiscountSalesData.TaxNo := PostSaleData^.TaxNo;
              DiscountSalesData.TaxRate := PostSaleData^.TaxRate;
              DiscountSalesData.Taxable := PostSaleData^.Taxable;
              DiscountSalesData.WEXCode := 0;
              DiscountSalesData.PHHCode := 0;
              DiscountSalesData.IAESCode := 0;
              DiscountSalesData.VoyagerCode := 0;
              DiscountSalesData.SavDiscable := 0;
              DiscountSalesData.SavDiscAmount := 0;
              DiscountSalesData.Discable := False;
              DiscountSalesData.LineVoided     := False;
              DiscountSalesData.CCAuthCode     := '';
              DiscountSalesData.CCApprovalCode := '';
              DiscountSalesData.CCDate         := '';
              DiscountSalesData.CCTime         := '';
              DiscountSalesData.CCCardNo       := '';
              DiscountSalesData.CCCardType     := '';
              DiscountSalesData.CCCardName     := '';
              DiscountSalesData.CCExpDate      := '';
              DiscountSalesData.CCBatchNo      := '';
              DiscountSalesData.CCSeqNo        := '';
              DiscountSalesData.CCEntryType    := '';
              DiscountSalesData.CCVehicleNo    := '';
              DiscountSalesData.CCOdometer     := '';
              DiscountSalesData.CCCPSData      := '';
              DiscountSalesData.CCRetrievalRef := '';
              DiscountSalesData.CCAuthNetId    := '';
              DiscountSalesData.CCTraceAuditNo := '';
              DiscountSalesData.GiftCardRestrictionCode := RC_NO_RESTRICTION;
              DiscountSalesData.CCPrintLine1  := '';
              DiscountSalesData.CCPrintLine2  := '';
              DiscountSalesData.CCPrintLine3  := '';
              DiscountSalesData.CCPrintLine4  := '';
              DiscountSalesData.CCBalance1    := 0;
              DiscountSalesData.CCBalance2    := 0;
              DiscountSalesData.CCBalance3    := 0;
              DiscountSalesData.CCBalance4    := 0;
              DiscountSalesData.CCBalance5    := 0;
              DiscountSalesData.CCBalance6    := 0;
              DiscountSalesData.CCRequestType := 0;
              DiscountSalesData.CCAuthorizer  := 0;
              DiscountSalesData^.ActivationState := asActivationDoesNotApply;
              DiscountSalesData^.ActivationTransNo := 0;
              DiscountSalesData^.ActivationTimeout := 0;
              DiscountSalesData^.LineID := GetLineID();
              DiscountSalesData^.ccPIN := '';
              PostDiscount(DayId, @DiscountSalesData);
            end;  // if ((cAmountOnPump > 0.0) and (cAmountOnPump <> PostSaleData^.ExtPrice))
          end  // if PostSaleData^.SaleType = 'Sale'
          else
          {$ENDIF}
          // Update Void and Return Totals
          if PostSaleData^.SaleType = 'Void' then
          begin
            nVoidCount := nVoidCount + Trunc(PostSaleData^.Qty);
            nVoidAmount := nVoidAmount + (PostSaleData^.ExtPrice * -1) ;
          end
          else if PostSaleData^.SaleType = 'Rtrn' then
          begin
            nRtrnCount := nRtrnCount + Trunc(PostSaleData^.Qty);
            nRtrnAmount := nRtrnAmount + (PostSaleData^.ExtPrice * -1) ;
          end;
        end    // FUL
        else if (PostSaleData^.LineType = 'DSC') or
                {$IFDEF CASH_FUEL_DISC}
                (PostSaleData^.LineType = 'DS$') or
                {$ENDIF}
                {$IFDEF ODOT_VMT}
                (PostSaleData^.LineType = 'DSV') or
                {$ENDIF}
                (PostSaleData^.LineType = 'DSG') then
        begin // Discount
          //FUEL_PRICE_ROLLBACK... (20070531 - NOTE:  Logic for this seciton moved to proc PostDiscount())
          PostDiscount(DayId, PostSaleData);
        end   // Discount
        else if PostSaleData^.LineType = 'MXM' then
        begin // MXM
          with PPCur['MixMatchShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pMMNo').AsInteger := Trunc(PostSaleData^.Number);
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pDlyCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pDlyAmount').AsCurrency := PostSaleData^.ExtPrice;
            ExecQuery;
            Close;
          end; {with }
        end   // MXM
        else if PostSaleData^.LineType = 'PLU' then
        begin // PLU
          bMdseItem := True;
          PLUDept := 0;
          nAdjAmount := 0;
          nAdjCount := 0;
          with PPCur['PLUSel'] do
          begin
            parambyname('pPLUNo').AsCurrency := Int(PostSaleData^.Number);
            ExecQuery;
            if RecordCount > 0 then
            begin
              PLUDept := FieldByName('DeptNo').AsInteger;
              nAdjAmount := PostSaleData^.Price - FieldByName('Price').AsCurrency;
              if nAdjAmount <> 0 then
                nAdjCount := PostSaleData^.Qty
              else
                nAdjCount := 0;
              with PPCur['PLUModSel'] do
              begin
                parambyname('pPLUNo').AsCurrency := Int(PostSaleData^.Number);
                ExecQuery;
                while not eof do
                begin
                  if PostSaleData^.Price = fieldbyname('PLUPrice').AsCurrency then
                  begin
                    nAdjAmount := 0;
                    nAdjCount := 0;
                    break;
                  end;
                  next;
                end;
                close; // PLUModSel
              end;
            end;
            Close; //PLUSel
          end;
            // Update PluShift Table
            // 'execute procedure plushiftmerge(:pdayid, :ppluno, :pplumodifier, :pterminalno, :pshiftno, :pprice, :pplumodifiergroup, :pdlycount, :pdlysales, :padjcount, :padjamount)'
          with PPCur['PLUShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pPluNo').AsCurrency  := PostSaleData^.Number;
            ParamByName('pPLUModifier').AsInteger := PostSaleData^.PLUModifier;
            ParamByName('pTerminalNo').AsInteger  := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pPrice').AsCurrency := PostSaleData^.Price;

            ParamByName('pplumodifiergroup').AsCurrency := PostSaleData^.PLUModifierGroup;

            ParamByName('pDlyCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pDlySales').AsCurrency := PostSaleData^.ExtPrice;
            parambyname('pAdjCount').AsCurrency := nAdjCount;
            parambyname('pAdjAmount').AsCurrency := nAdjAmount;
            ExecQuery;
            close;
          end;

            //Update Inventory
          with PPCur['PLUInvUpdate'] do
          begin
            parambyname('pCount').AsCurrency := PostSaleData^.Qty;
            parambyname('pPLUNo').AsCurrency := Int(PostSaleData^.Number);
            ExecQuery;
            Close;
          end;
            // Update DepShift Table
          with PPCur['DepShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            {$IFDEF PLU_MOD_DEPT}
            ParamByName('pDeptNo').AsInteger := PostSaleData^.DeptNo;
            {$ELSE}
            ParamByName('pDeptNo').AsCurrency   := PLUDept;
            {$ENDIF}
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pDlyCount').AsCurrency  := PostSaleData^.Qty;
            ParamByName('pDlySales').AsCurrency  := PostSaleData^.ExtPrice;
            ParamByName('pAdjCount').AsCurrency  := 0;
            ParamByName('pAdjAmount').AsCurrency  := 0;
            ExecQuery;
            Close;
          end; {with}
          // Update Void and Return Totals
          if PostSaleData^.SaleType = 'Void' then
          begin
            nVoidCount  := nVoidCount + Trunc(PostSaleData^.Qty);
            nVoidAmount := nVoidAmount + (PostSaleData^.ExtPrice * -1) ;
          end
          else if PostSaleData^.SaleType = 'Rtrn' then
          begin
            nRtrnCount  := nRtrnCount + Trunc(PostSaleData^.Qty);
            nRtrnAmount := nRtrnAmount + (PostSaleData^.ExtPrice * -1) ;
          end;
        end   // PLU
        else if PostSaleData^.LineType = 'BNK' then
        begin // BNK
          with PPCur['BankShiftMerge'] do
          begin
            // UPDATE BankShift Table
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pBankNo').AsInteger := Trunc(PostSaleData^.Number);
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pDlyCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pDlySales').AsCurrency := Abs(PostSaleData^.ExtPrice);
            ExecQuery;
            Close;
          end;
          with PPCur['BankFuncRecTypeFind'] do
          begin
            ParamByName('pBankNo').AsInteger := Trunc(PostSaleData^.Number);
            ExecQuery;
            RecType := 0;
            if RecordCount > 0 then
              RecType := FieldByName('RecType').AsInteger;
            Close;
          end;
          if RecType = 3 then  { 3 = cash drop}
            with PPCur['CashDropInsert'] do
            begin
              ParamByName('pDropTime').AsDateTime := Now + (nPostndx/10000);
              ParamByName('pDropShift').AsInteger := nShiftNo;
              ParamByName('pDropAmount').AsCurrency := Abs(PostSaleData^.ExtPrice);
              ParamByName('pDropTransNo').AsInteger := pstSale.nTransNo;
              ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
              ExecQuery;
              Close;
            end; {with}
        end   // BNK
        else if PostSaleData^.LineType = 'PPY' then
        begin // PPY
          bFuelItem := True;
          with PPCur['PPYTotalsUpdate'] do
          begin
            // UPDATE Totals Table (Store and Shift Record)
            ParamByName('pCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pAmount').AsCurrency := PostSaleData^.ExtPrice;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ExecQuery;
            Close;
          end; {with}
        end   // PPY
        else if PostSaleData^.LineType = 'PRF' then
        begin // PRF
          bFuelItem := True;
          with PPCur['PRFTotalsUpdate'] do
          begin
            // UPDATE Totals Table (Store and Shift Record)
            ParamByName('pCount').AsCurrency := PostSaleData^.Qty;
            ParamByName('pAmount').AsCurrency := PostSaleData^.ExtPrice;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ExecQuery;
            Close;
          end; {with}
        end;  // PRF
          UpdateZLog(Format('POSPost.PostSale: Done Posting line %d - %s %s',[nPostNdx + 1,PostSaleData^.LineType, PostSaleData^.SaleType]));
      end; {nPostNdx := 0 to (SalesList.Count - 1}
      //bph...
      if ((fmPOS.SaleState <> ssBankFuncTender) and (not bReTendering)) then
      //...bph
      begin
        UpdateZLog('POSPost.PostSale: posting sales taxes');
        for t := 1 to fmPOS.PostSalesTaxList.Count-1 do
        begin
          // 'execute procedure TaxShiftMerge(:pdayid, :ptaxno, :pterminalno, :pshiftno, :pdlycount, :pdlytaxablesales, :pdlytaxcharged, :pFSTaxExemptSales, :pFSTaxExemptAmount)'
          ST := fmPOS.PostSalesTaxList.Items[t];
          with PPCur['TaxShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pTaxNo').AsInteger := ST^.TaxNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pFSTaxExemptSales').AsCurrency := ST^.FSTaxExemptSales;
            ParamByName('pFSTaxExemptAmount').AsCurrency := ST^.FSTaxExemptAmount;
            if ST^.Taxable <> 0 then
            begin
              ParamByName('pDlyCount').AsInteger := 1;
              ParamByName('pdlyTaxableSales').AsCurrency := ST^.Taxable;
              ParamByName('pdlyTaxCharged').AsCurrency := ST^.TaxCharged;
            end
            else
            begin
              ParamByName('pDlyCount').AsInteger := 0;
              ParamByName('pdlyTaxableSales').AsCurrency := 0;
              ParamByName('pdlyTaxCharged').AsCurrency := 0;
            end;
            ExecQuery;
            Close;
          end; {with}
          UpdateZLog('POSPost.PostSale: posting sales taxes done');
        end; {for}

        nFuelCount  := 0;
        nFuelAmount := 0;
        nMdseCount  := 0;
        nMdseAmount := 0;
        nFMCount    := 0;
        nFMAmount   := 0;
        if (bFuelItem and bMdseItem) then
        begin
          nFMCount := 1;
          nFMAmount  := pstSale.nSubtotal;
        end
        else if bFuelItem then
        begin
          nFuelCount := 1;
          nFuelAmount := pstSale.nSubtotal;
        end
        else if bMdseItem then
        begin
          nMdseCount := 1;
          nMdseAmount := pstSale.nSubtotal;
        end;

        ST := fmPOS.PostSalesTaxList.Items[0];

        with PPCur['TotalsUpdate'] do
        begin
          ParamByName('pTotal').AsCurrency    := pstSale.nTotal;
          ParamByName('pSubTotal').AsCurrency := pstSale.nSubTotal;
          try
            ParamByName('pNoTax').AsCurrency := ST^.Taxable;
          except
            ParamByName('pNoTax').AsCurrency := 0;
          end;
          ParamByName('pFuelCount').AsInteger   := nFuelCount;
          ParamByName('pFuelAmount').AsCurrency := nFuelAmount;
          ParamByName('pMdseCount').AsInteger   := nMdseCount;
          ParamByName('pMdseAmount').AsCurrency := nMdseAmount;
          ParamByName('pFMCount').AsInteger   := nFMCount;
          ParamByName('pFMAmount').AsCurrency := nFMAmount;
          ParamByName('pVoidCount').AsInteger := Abs(nVoidCount);
          ParamByName('pVoidAmount').AsCurrency := Abs(nVoidAmount);
          ParamByName('pRtrnCount').AsInteger := Abs(nRtrnCount);
          ParamByName('pRtrnAmount').AsCurrency := Abs(nRtrnAmount);
          ParamByName('pShiftNo').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          UpdateZLog('POSPost.PostSale: pre-ExecQuery ');
          ExecQuery;
          Close;
          UpdateZLog('POSPost.PostSale: post-ExecQuery - updating totals table done');
        end; {with TempQuery}

        if pstSale.nChangeDue <> 0 then
        begin
          UpdateZLog('POSPost.PostSale: updating MedShift table with change');
          with PPCur['MedShiftMerge'] do
          begin
            ParamByName('pDayId').AsInteger := DayId;
            ParamByName('pMediaNo').AsInteger := 1;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pDlySales').AsCurrency := -pstSale.nChangeDue;
            ParamByName('pDlyFuel').AsCurrency := 0;
            ParamByName('pDlyTax').AsCurrency := 0;
            ParamByName('pDlyOutsideSales').AsCurrency := 0;
            ParamByName('pDlyOutsideFuel').AsCurrency := 0;
            ParamByName('pDlyOutsideCount').AsCurrency := 0;
            ExecQuery;
            Close;
          end;
          UpdateZLog('POSPost.PostSale: updating MedShift table with change done');
        end;

        UpdateZLog('POSPost.PostSale: update HourlyShift Table');
        with PPCur['HourlyShiftMerge'] do
        begin
          // Trxs after MaxTime should update last record
          ParamByName('pDayId').AsInteger := DayId;
          ParamByName('pTxnTime').AsDateTime := Now();
          ParamByName('pShiftNo').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          ParamByName('pDlyCount').AsCurrency   := 1;
          ParamByName('pDlySales').AsCurrency   := pstSale.nTotal;
          {$IFDEF PLU_MOD_DEPT}
          ParamByName('pFuelCount').AsInteger   := nFuelCount;
          ParamByName('pFuelAmount').AsCurrency := nFuelAmount;
          ParamByName('pMdseCount').AsInteger   := nMdseCount;
          ParamByName('pMdseAmount').AsCurrency := nMdseAmount;
          ParamByName('pFMCount').AsInteger   := nFMCount;
          ParamByName('pFMAmount').AsCurrency := nFMAmount;
          {$ELSE}
          ParamByName('pFuelCount').AsInteger   := 0;
          ParamByName('pFuelAmount').AsCurrency := 0;
          ParamByName('pMdseCount').AsInteger   := 0;
          ParamByName('pMdseAmount').AsCurrency := 0;
          ParamByName('pFMCount').AsInteger   := 0;
          ParamByName('pFMAmount').AsCurrency := 0;
          {$ENDIF}
          ParamByName('pNoSaleCount').AsInteger := 0;
          ParamByName('pVoidCount').AsInteger := Abs(nVoidCount);
          ParamByName('pVoidAmount').AsCurrency := Abs(nVoidAmount);
          ParamByName('pRtrnCount').AsInteger := Abs(nRtrnCount);
          ParamByName('pRtrnAmount').AsCurrency := Abs(nRtrnAmount);
          ParamByName('pCANCELCOUNT').AsInteger   := 0;
          ParamByName('pCANCELAMOUNT').AsCurrency := 0;
          ParamByName('pSALESRPTCOUNT').AsInteger := 0;
          ExecQuery;
          Close;
        end; {with TempQuery}
        UpdateZLog('POSPost.PostSale: update HourlyShift Table done');
      end;

      PPCur.Commit;
      if bLogging then UpdateZLog('PostSale Complete');
      break;
    except
      on E : Exception do
      begin
        UpdateExceptLog('Rollback Post Sale try %d - %s - %s', [RepeatCount, E.ClassName, E.message]);
        UpdateZLog('Rollback Post Sale try %d - %s - %s', [RepeatCount, E.ClassName, E.message]);
        if (repeatcount = 1) and (POS('deadlock', E.Message) = 0) then DumpTraceBack(E);
        if PPCur.Transaction.InTransaction then PPCur.Rollback;
        if (E.ClassName = 'ERangeError') and (POS('not in IBSqlStrHashMap', E.Message) > 0) then
        begin
          UpdateExceptLog('Breaking since this error is non-recoverable');
          UpdateZLog('Breaking since this error is non-recoverable');
          break;
        end;
        if (E.ClassName = 'EIBInterBaseError') and (POS('validation error for column', E.Message) > 0) then
        begin
          UpdateExceptLog('Breaking since this error is non-recoverable');
          UpdateZLog('Breaking since this error is non-recoverable');
          break;
        end;
        sleep(100);
        Inc(RepeatCount);
        if RepeatCount > 100 then
        begin
          UpdateExceptLog('PostSale Failed - Rollback Posting Sale ' + e.message);
          UpdateZLog('PostSale Failed - Rollback Posting Sale ' + e.message);
          break;
        end;
      end;
    end;//try..except
  end;
  // Let credit server know that the final auth amount is the same as the approved auth amount.
  for nPostNdx := 0 to (PostSaleList.Count - 1) do
  begin
    PostSaleData := PostSaleList.Items[nPostNdx];
    if (fmPOS.SalesItemQualifiesForAuthReduction(PostSaleData) and (not PostSaleData^.PriceOverridden)) then   // skip any already finalized (amount had been reduced)
    begin
      UpdateZLog(Format('POSPost.PostSale: Posting line %d - %s %s',[nPostNdx + 1,PostSaleData^.LineType, PostSaleData^.SaleType]));
      fmPOS.ReduceAuth(curSale.nTransNo, PostSaleData, PostSaleData^.ExtPrice);
    end;
  end;
end; {procedure PostSale}

{$IFDEF PDI_PROMOS}
procedure PostPDIPromo(PPCur : TIBSQLBuilder; const DayId: integer; const qSalesData : pSalesData);
var
  bNeedInsert : boolean;
begin
  with PPCur['PromoShiftFind'] do
  begin
    ParamByName('pShiftNo').AsInteger := nShiftNo;
    ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
    ParamByName('pPromoNo').AsInteger := Trunc(qSalesData^.Number);
    ExecQuery;
    bNeedInsert := (RecordCount = 0);
    Close();
  end;
  if bNeedInsert then
    with PPCur['PromoShiftInsert'] do
    begin
      ParamByName('pDlyCount').AsCurrency := 0.0;
      ParamByName('pDlyAmount').AsCurrency := 0.0;
      ParamByName('pTransCnt').AsInteger := 0;
      ParamByName('pQtySold').AsInteger := 0;
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pPromoNo').AsInteger := Trunc(qSalesData^.Number);
      ExecQuery;
      Close();
    end;
  with PPCur['PromoShiftUpdate'] do
  begin
    if LastPromo = Trunc(qSalesData^.Number) then
    begin
      ParamByName('pCount').AsCurrency := 0;
      ParamByName('pTransCnt').AsInteger := 0;
      ParamByName('pQtySold').AsInteger := 0;
    end
    else
    begin
      ParamByName('pCount').AsCurrency := qSalesData^.Qty;
      ParamByName('pTransCnt').AsInteger := 1;
      with PPCur['PromotionsFind'] do
      begin
        ParamByName('pPromoNo').AsInteger := Trunc(qSalesData^.Number);
        ExecQuery;
        QtySold := Trunc(qSalesData^.Qty) * FieldByName('Items').AsInteger;
        Close
      end;
      ParamByName('pQtySold').AsInteger := QtySold;
      LastPromo := Trunc(qSalesData^.Number);
    end;
    ParamByName('pAmount').AsCurrency := qSalesData^.ExtPrice;
    ParamByName('pShiftNo').AsInteger := nShiftNo;
    ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
    ParamByName('pPromoNo').AsInteger := Trunc(qSalesData^.Number);
    ExecQuery;
    Close();
  end;

end;
{$ENDIF}

procedure PostNormalDisc(PPCur : TIBSQLBuilder; const DayId : integer; const qSalesData : pSalesData);
begin
//execute procedure DiscShiftMerge(:pdayid, :pdiscno, :pterminalno, :pshiftno, :pdlycount, :pdlyamount)
  UpdateZLog('POSPost.PostNormalDisc: Posting discount %d for %g@%g',[Trunc(qSalesData^.Number), qSalesData^.Qty, qSalesData^.Price]);
  with PPCur['DiscShiftMerge'] do
  begin
    ParamByName('pdayid').AsInteger := DayId;
    ParamByName('pDiscNo').AsInteger := Trunc(qSalesData^.Number);
    ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
    ParamByName('pShiftNo').AsInteger := nShiftNo;
    ParamByName('pdlycount').AsCurrency := qSalesData^.Qty;
    ParamByName('pdlyamount').AsCurrency := qSalesData^.ExtPrice;
    ExecQuery;
    Close();
  end;
end;


//FUEL_PRICE_ROLLBACK... (code moved from procedure PostSale)
procedure PostDiscount(const DayId : integer; const qSalesData : pSalesData);
begin
  {$IFDEF PDI_PROMOS}
  if qSalesData^.SaleType = 'Info' then
    PostPDIPromo(POSDataMod.PosPostCur, DayId, qSalesData)
  else
  {$ENDIF}
    PostNormalDisc(POSDataMod.PosPostCur, DayId, qSalesData);
end;  // procedure PostDiscount
//...FUEL_PRICE_ROLLBACK

{-----------------------------------------------------------------------------
  Name:      DBUpdateMedia
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const qSaleData : pSalesData
  Result:    boolean
  Purpose:
-----------------------------------------------------------------------------}
//lk1...
function DBUpdateMedia(const DayId : integer; const qSaleData : pSalesData) : boolean;
var
  RetStr : boolean;
  cDLYSales : currency;
  PPCur : TIBSQLBuilder;
begin
  PPCur := POSDataMod.PosPostCur;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  try
    UpdateZLog('POSPost.DBUpdateMedia:  Enter');
    with PPCur['MedShiftMerge'] do
    begin
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pMediaNo').AsInteger := Trunc(qSaleData^.Number);
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pDlySales').AsCurrency := qSaleData^.ExtPrice;
      ParamByName('pDlyFuel').AsCurrency := qSaleData^.SplitPrice;
      ParamByName('pDlyTax').AsCurrency := qSaleData^.Taxable;
      ParamByName('pDlyOutsideSales').AsCurrency := 0;
      ParamByName('pDlyOutsideFuel').AsCurrency := 0;
      ParamByName('pDlyOutsideCount').AsCurrency := 0;
      ExecQuery;
      Close;
    end;
    UpdateZLog('POSPost.DBUpdateMedia:  MedShift Table Update Done');
    // Record sale and fuel amounts by card type tendered / shift / and terminal.
    cDLYSales := qSaleData^.ExtPrice;
    if (Round(qSaleData^.Number) = CASH_MEDIA_NUMBER) then
      cDLYSales := cDLYSales - pstSale.nChangeDue;
    with PPCur['MedCardTypeShiftMerge'] do
    begin
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pCardType').AsString := qSaleData^.CCCardType;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pDlySales').AsCurrency := cDLYSales;
      ParamByName('pDlyFuel').AsCurrency := qSaleData^.SplitPrice;
      ParamByName('pDlyTax').AsCurrency := qSaleData^.Taxable;
      ParamByName('pDlyOutsideSales').AsCurrency := 0;
      ParamByName('pDlyOutsideFuel').AsCurrency := 0;
      ParamByName('pDlyOutsideCount').AsCurrency := 0;
      ExecQuery;
      Close;
    end;
    UpdateZLog('POSPost.DBUpdateMedia:  MedCardTypeShift Table Modify Done');
    RetStr := True;
  except
    on E : Exception do
    begin
      RetStr := False;
      UpdateExceptLog( 'DBUpdateMedia - '+ e.message);
    end
    else
    begin
      RetStr := False;
    end;
  end;
  DBUpdateMedia := RetStr;
end;
//...lya


{-----------------------------------------------------------------------------
  Name:      PostNoSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PostNoSale(TerminalNo : smallint; ShiftNo : integer);
var
  PPCur : TIBSQLBuilder;
  DayId : integer;
begin
  PPCur := POSDataMod.PosPostCur;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);

  PPCur.StartTransaction;
  try
    with PPCur['GetDayId'] do
    begin
      ExecQuery;
      DayId := FieldByName('DayId').AsInteger;
      Close;
    end;
    with PPCur['HourlyShiftMerge'] do
    begin
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pTxnTime').AsDateTime := Now();
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pDlyCount').AsCurrency   := 0;
      ParamByName('pDlySales').AsCurrency   := 0;
      ParamByName('pFuelCount').AsInteger   := 0;
      ParamByName('pFuelAmount').AsCurrency := 0;
      ParamByName('pMdseCount').AsInteger   := 0;
      ParamByName('pMdseAmount').AsCurrency := 0;
      ParamByName('pFMCount').AsInteger   := 0;
      ParamByName('pFMAmount').AsCurrency := 0;
      ParamByName('pNoSaleCount').AsInteger := 1;
      ParamByName('pVoidCount').AsInteger := 0;
      ParamByName('pVoidAmount').AsCurrency := 0;
      ParamByName('pRtrnCount').AsInteger := 0;
      ParamByName('pRtrnAmount').AsCurrency := 0;
      ParamByName('pCANCELCOUNT').AsInteger   := 0;
      ParamByName('pCANCELAMOUNT').AsCurrency := 0;
      ParamByName('pSALESRPTCOUNT').AsInteger := 0;
      ExecQuery;
      Close;
    end;
    PPCur.Commit;
  except
    on E: Exception do
    begin
      PPCur.Rollback;
      UpdateExceptLog('POSPost.PostNoSale - Failed to execute UpdHourlyNoSale with %d, %d, %s - %s', [TerminalNo, ShiftNo, FormatDateTime('hh:nn', Now()), E.Message]); 
    end;
  end;
    
  if not POSDataMod.IBPostTransaction.InTransaction then
    POSDataMod.IBPostTransaction.StartTransaction;
  with POSDataMod.IBPostSQL do
  begin
    // UPDATE Totals Table (Store and Shift Record)
    try
      Close;
      SQL.Clear;
      SQL.Add('UPDATE Totals SET DlyNoSaleCount = DlyNoSaleCount + 1 ');
      SQL.Add('WHERE (TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo) ) ');
      ParamByName('pShiftNo').AsInteger := ShiftNo;
      ParamByName('pTerminalNo').AsInteger := TerminalNo;
      ExecQuery;
      if POSDataMod.IBPostTransaction.InTransaction then
        POSDataMod.IBPostTransaction.Commit;
      if bLogging then UpdateZLog('NoSaleUpdate Complete');
    except
      if POSDataMod.IBPostTransaction.InTransaction then
        POSDataMod.IBPostTransaction.Rollback;
      if bLogging then UpdateZLog('NoSaleUpdate Failed');
    end;

  end; {with TempQuery}

end; {procedure PostNoSale}


{-----------------------------------------------------------------------------
  Name:      PostCancel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PostCancel(const CurSaleList : TList; TransNo : integer; TerminalNo : smallint; ShiftNo : integer; Total : currency);
var
  nPostNdx: byte;
  AccessCode : string;
  CurSaleData : pSalesData;
  PLU : TDBPLURec;
  Dept : TDBDeptRec;
  PPCur : TIBSQLBuilder;
  DayId : integer;
begin
  PPCur := POSDataMod.PosPostCur;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);

  PPCur.StartTransaction;
  try
    with PPCur['GetDayId'] do
    begin
      ExecQuery;
      DayId := FieldByName('DayId').AsInteger;
      Close;
    end;
    with PPCur['HourlyShiftMerge'] do
    begin
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pTxnTime').AsDateTime := Now();
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pDlyCount').AsCurrency   := 0;
      ParamByName('pDlySales').AsCurrency   := 0;
      ParamByName('pFuelCount').AsInteger   := 0;
      ParamByName('pFuelAmount').AsCurrency := 0;
      ParamByName('pMdseCount').AsInteger   := 0;
      ParamByName('pMdseAmount').AsCurrency := 0;
      ParamByName('pFMCount').AsInteger   := 0;
      ParamByName('pFMAmount').AsCurrency := 0;
      ParamByName('pNoSaleCount').AsInteger := 0;
      ParamByName('pVoidCount').AsInteger := 0;
      ParamByName('pVoidAmount').AsCurrency := 0;
      ParamByName('pRtrnCount').AsInteger := 0;
      ParamByName('pRtrnAmount').AsCurrency := 0;
      ParamByName('pCANCELCOUNT').AsInteger   := 1;
      ParamByName('pCANCELAMOUNT').AsCurrency := Total;
      ParamByName('pSALESRPTCOUNT').AsInteger := 0;
      ExecQuery;
      Close;
    end;
    PPCur.Commit;
  except
    on E: Exception do
    begin
      PPCur.Rollback;
      UpdateExceptLog('POSPost.PostCancel - Failed to execute UpdHourlyCancel with %d, %g, %d, %d, %s - %s', [1, Total, TerminalNo, ShiftNo, FormatDateTime('hh:nn', Now()), E.Message]); 
    end;
  end;
  
  if not POSDataMod.IBPostTransaction.InTransaction then
    POSDataMod.IBPostTransaction.StartTransaction;
  with POSDataMod.IBPostSQL do
    begin
      // UPDATE Totals Table (Store and Shift Record)
      try
//20060707b        POSDataMod.IBPostTransaction.StartTransaction;
        Close;
        SQL.Clear;
        SQL.Add('UPDATE Totals SET ');
        SQL.Add('DlyCancelCount = DlyCancelCount + 1, ');
        SQL.Add('DlyCancelAmount = DlyCancelAmount + :pAmount ');
        SQL.Add('WHERE (TotalNo = 0) Or ((ShiftNo = :pShiftNo) and  (TerminalNo = :pTerminalNo) )');
        ParamByName('pAmount').AsCurrency := Total;
        ParamByName('pShiftNo').AsInteger := ShiftNo;
        ParamByName('pTerminalNo').AsInteger := TerminalNo;
        ExecQuery;
        POSDataMod.IBPostTransaction.Commit;
        if bLogging then UpdateZLog('CancelUpdate Complete');
      except
        POSDataMod.IBPostTransaction.Rollback;
        if bLogging then UpdateZLog('CancelUpdate Failed');
      end;
    end; {with TempQuery}

  for nPostNdx := 0 to (CurSaleList.Count - 1) do
  begin
    CurSaleData := fmPos.CurSaleList.Items[nPostNdx];
    if (CurSaleData^.LineType = 'FUL') or (CurSaleData^.LineType = 'PRF') or (CurSaleData^.LineType = 'PPY') then
    begin
      if (CurSaleData^.SaleType = 'Sale') and (CurSaleData^.PumpNo > 0) and (CurSaleData^.LineVoided = False) then
      begin
        fmPOS.SendFuelMessage(CurSaleData^.PumpNo, PMP_RELEASE, NOAMOUNT, CurSaleData^.FuelSaleID, TransNo, NODESTPUMP );
      end;
    end;
    if CurSaleData^.LineType = 'PLU' then
    begin
      AccessCode := CurSaleData^.CCCardName;
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBPLUQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
        ParamByName('pPLUNo').AsCurrency := CurSaleData^.Number;
        Open;
        GETPLU(POSDataMod.IBPLUQuery, @PLU);
        nLinkedPLUNo := PLU.LINKEDPLU;
        close;
        with POSDataMod.IBDeptQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Select * from Dept where DeptNo = :pDeptNo');
          ParamByName('pDeptNo').AsInteger := PLU.DeptNo;
          Open;
          GETDept(POSDataMod.IBDeptQuery, @Dept);
          close;
        end;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      //Test for carwash
      if not POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.StartTransaction;
      with POSDataMod.IBTempQry1 do
      begin
        close;SQL.Clear;
        SQL.Add('Select * from Grp where GrpNo = :pGrpNo');
        parambyname('pGrpNo').AsString := inttostr(Dept.GRPNO);
        open;
        if fieldbyname('Fuel').AsInteger = 3 then
        begin
          close;
          if AccessCode <> '' then fmCWAccessForm.VoidCarwashCode(AccessCode);
        end
        else
          close;
      end;
      if POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.Commit;
    end;
  end;
end; {procedure PostCancel}


{-----------------------------------------------------------------------------
  Name:      InitShiftTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TerminalNo, ShiftNo : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure InitShiftTotals(TerminalNo, ShiftNo : integer);
var
RepeatCount : integer;
begin
  RepeatCount := 0;
  while True do
  try
    assert(POSDataMod.IBRptSQL02Main.Transaction = POSDataMod.IBRptSQL01Main.Transaction, 'Transaction objects differ');
    with POSDataMod.IBRptSQL02Main do
    begin
      Assert(not open, 'IBRptSQL02Main not open');
      SQL.Clear;
      SQL.Add('EXECUTE PROCEDURE PROD_InitShiftTotals_NEW(:pCreditBatchID, ');
      SQL.Add(':pShiftNo, :pTotalNo, :pTerminalNo, :pDate)');
      parambyname('pCreditBatchID').AsString := inttostr(nCreditBatchID + 1);
      parambyname('pShiftNo').AsString := inttostr(ShiftNo);
      parambyname('pTotalNo').AsString := IntToStr((TerminalNo * 100) +  nShiftNo);
      parambyname('pTerminalNo').AsString := IntToStr(TerminalNo);
      parambyname('pDate').AsDatetime := Now();
      ExecQuery;
      Close;
    end;
    break;
  except
    on E : Exception do
    begin
      UpdateExceptLog( 'Rollback InitShift ' + IntToStr(RepeatCount) + ' ' + e.message);
      sleep(100);
      Inc(RepeatCount);
      if RepeatCount > 100 then
        break;
    end;
  end;
end; {procedure InitShiftTotals}

procedure PostPrePayToXMD(SaleID, GradeDeptLink : Integer);
var
  XMDAmount : Currency;
  XMDVolume : Integer;
  XMDTransNo : Integer;
  RepeatCount : Byte;
begin
  RepeatCount:= 1;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  while True do
  begin
    if not POSDataMod.IBXMDTrans.InTransaction then
      POSDataMod.IBXMDTrans.StartTransaction;
    try
      with POSDataMod.IBXMDQry1 do
      begin
        Close;SQL.Clear;
        SQL.Add('Select TransNo from FuelTran where SaleID = :pSaleID');
        parambyname('pSaleID').AsInteger := SaleID;
        Open;
        XMDTransNo := FieldByName('TransNo').AsInteger;
        Close;SQL.Clear;
        SQL.Add('Select * from XMDCouponActivity where TransactionNo = :pTransNo ');
        SQL.Add('and TransType = 2');
        parambyname('pTransNo').AsInteger := XMDTransNo;
        Open;
        if RecordCount > 0 then
        begin
          XMDVolume := round(FieldByName('TotalCount').AsInteger);
          XMDAmount := FieldByName('TotalDisc').AsCurrency;
        end
        else
        begin
          XMDVolume := 0;
          XMDAmount := 0;
        end;
        Close;
        if XMDVolume > 0 then
        begin
          Close;SQL.Clear;
          SQL.Add('Select * from Disc where DiscNo = :pDiscNo');
          parambyname('pDiscNo').AsInteger := GradeDeptLink;
          open;
          if RecordCount > 0 then
          begin
            close;
          end
          else
          begin
            Close;SQL.Clear;
            SQL.Add('Insert into Disc (DISCNO, NAME, REDUCETAX, AMOUNT, RECTYPE) ');
            SQL.Add('Values (:pDiscNo, (Select Name from Grade where deptno = :pDiscNo), 0, 0, :pRECTYPE)');
            ParamByName('pDiscNo').AsInteger := GradeDeptLink;
            //ParamByName('pName').AsString := TempName;
            ParamByName('pRecType').AsString := 'D';
            ExecSQL;
          end;
          Close;SQL.Clear;
          SQL.Add('Select * from DiscShift where DiscNo = :pDiscNo and ');
          SQL.Add('TerminalNo = :pTerminalNo and ShiftNo = :pShiftNo');
          ParamByName('pDiscNo').AsInteger := GradeDeptLink;
          ParamByName('pShiftNo').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          open;
          if RecordCount > 0 then
          begin
            close;
          end
          else
          begin
            Close;SQL.Clear;
            SQL.Add('Insert into DiscShift (DISCNO, SHIFTNO, DLYCOUNT, DLYAMOUNT, TERMINALNO) ');
            SQL.Add('Values (:pDISCNO, :pSHIFTNO, 0, 0, :pTERMINALNO)');
            parambyname('pDiscNo').AsInteger := GradeDeptLink;
            ParamByName('pShiftNo').AsInteger := nShiftNo;
            ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
            ExecSQL;
          end;
          Close;SQL.Clear;
          SQL.Add('Update DiscShift set DlyCount = DlyCount - :pXMDVolume, ');
          SQL.Add('DlyAmount = DlyAmount - :pXMDAmount where DiscNo = 998 and ');
          SQL.Add('TerminalNo = :pTerminalNo and ShiftNo = :pShiftNo');
          parambyname('pXMDVolume').AsInteger := XMDVolume;
          parambyname('pXMDAmount').AsCurrency := XMDAmount;
          ParamByName('pShiftNo').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          ExecSQL;
          Close;SQL.Clear;
          SQL.Add('Update DiscShift set DlyCount = DlyCount + :pXMDVolume, ');
          SQL.Add('DlyAmount = DlyAmount + :pXMDAmount where DiscNo = :pDiscNo and ');
          SQL.Add('TerminalNo = :pTerminalNo and ShiftNo = :pShiftNo');
          parambyname('pXMDVolume').AsInteger := XMDVolume;
          parambyname('pXMDAmount').AsCurrency := XMDAmount;
          parambyname('pDiscNo').AsInteger := GradeDeptLink;
          ParamByName('pShiftNo').AsInteger := nShiftNo;
          ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
          ExecSQL;
        end;
      end;
      if POSDataMod.IBXMDTrans.InTransaction then
        POSDataMod.IBXMDTrans.Commit;
      break;
    except
      on E : Exception do
      begin
        UpdateExceptLog( 'Rollback Post PrePayXMD ' + IntToStr(RepeatCount) + ' ' + e.message);
        if POSDataMod.IBXMDTrans.InTransaction then
          POSDataMod.IBXMDTrans.Rollback;
        sleep(100);
        Inc(RepeatCount);
        if RepeatCount > 100 then
        begin
          UpdateExceptLog('Rollback Posting PrePayXMD ' + e.message);
          if bLogging then UpdateZLog('Post PrePay Failed');
          break;
        end;
      end;
    end;
  end;
end;

procedure PostSalesRptExec(TerminalNo : smallint; ShiftNo : integer);
var
  PPCur : TIBSQLBuilder;
  DayId : Integer;
begin
  UpdateZLog('POSPost.PostSalesRptExec - Enter');
  PPCur := POSDataMod.PosPostCur;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);

  PPCur.StartTransaction;
  try
    with PPCur['GetDayId'] do
    begin
      ExecQuery;
      DayId := FieldByName('DayId').AsInteger;
      Close;
    end;
    with PPCur['HourlyShiftMerge'] do
    begin
      ParamByName('pDayId').AsInteger := DayId;
      ParamByName('pTxnTime').AsDateTime := Now();
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      ParamByName('pDlyCount').AsCurrency   := 0;
      ParamByName('pDlySales').AsCurrency   := 0;
      ParamByName('pFuelCount').AsInteger   := 0;
      ParamByName('pFuelAmount').AsCurrency := 0;
      ParamByName('pMdseCount').AsInteger   := 0;
      ParamByName('pMdseAmount').AsCurrency := 0;
      ParamByName('pFMCount').AsInteger   := 0;
      ParamByName('pFMAmount').AsCurrency := 0;
      ParamByName('pNoSaleCount').AsInteger := 0;
      ParamByName('pVoidCount').AsInteger := 0;
      ParamByName('pVoidAmount').AsCurrency := 0;
      ParamByName('pRtrnCount').AsInteger := 0;
      ParamByName('pRtrnAmount').AsCurrency := 0;
      ParamByName('pCANCELCOUNT').AsInteger   := 0;
      ParamByName('pCANCELAMOUNT').AsCurrency := 0;
      ParamByName('pSALESRPTCOUNT').AsInteger := 1;
      ExecQuery;
      Close;
    end;
    PPCur.Commit;
  except
    on E: Exception do
    begin
      PPCur.Rollback;
      UpdateExceptLog('POSPost.PostSalesRptExec - Failed to execute UpdHourlySalesRpt with %d, %d, %s - %s', [TerminalNo, ShiftNo, FormatDateTime('hh:nn', Now()), E.Message]); 
    end;
  end;
    
  UpdateZLog('POSPost.PostSalesRptExec - Leave');
end;

end.

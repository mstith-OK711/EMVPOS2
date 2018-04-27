{-----------------------------------------------------------------------------
 Unit Name: CardActivation
 Date:      7/23/2007

 Interface module to credit server for activations of non-tender card types
 (for example, a phone card, push PIN to receipt transaction).
-----------------------------------------------------------------------------}
unit CardActivation;

{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, AdPort, DB, POSPrt, POSMain, LatTypes;

function ProductActivationPending(qSaleList : pTList) : boolean;
function ConvertVCIForActivation(const pVCI : pValidCardInfo;
                                 const qActivationProductType : pActivationProductType) : boolean;
procedure ClearActivationProductData(const qActivationProductType : pActivationProductType);
function AddActivationMessageLine(const ActivationMessage : string) : pSalesData;
function AlterActivationMessageLine(const NewMessage : string;
                                    const AlterSaleList : pTList;
                                    const AlterLineID : integer;
                                    const bCurrentSale : boolean) : boolean;
procedure QueueBalanceInquiry(const qSalesData : pSalesData);
procedure QueueActivationRequest(const qSalesData : pSalesData);
function HandleActivationResponse(const CCActMsg : string) : pSalesData;
procedure CompleteActivationResponse();
function UpdateActivationResponse(const qSaleList : pTList;
                                  const ListTransNo : integer;
                                  const ListLineID : integer;
                                  const StatusMsg : string;
                                  const bCurrentSale : boolean) : pSalesData;
procedure IssueCardActivationPrompt(const PromptMsg : string);
procedure ClearCardActivationPrompt();
procedure PrintPINReceiptText(const qSaleList : pTList);

const
  {$I LatitudeConst.Inc}
  {$I CreditServerConst.inc}

var
  bCreditServerConnected : boolean;

  SavePOSErrorMsg_ShowYesNo           : boolean = False;
  SavePOSErrorMsg_lErrMsg_Caption     : string = '';
  SavePOSErrorMsg_lblContinue_Caption : string = '';
  SavePOSErrorMsg_Caption             : string = '';
  SavePOSErrorMsg_Tag                 : integer = 0;


implementation

uses strutils, POSDM, POSErr, POSMsg, POSMisc, ExceptLog;

function IsActivationUPC(const UPCValue : currency; var bNeedMSR : boolean; var bNeedPhoneNo : boolean) : boolean;
var
  RetValue : boolean;
begin
  RetValue := False;         // initial assumption
  with POSDataMod.IBTempQuery do
  begin
    try
      if (not Transaction.InTransaction) then
        Transaction.StartTransaction();
      Close();SQL.Clear();
      SQL.Add('SELECT ItemNeedsActivation, ItemNeedsSwipe from PLU WHERE (UPC = :pUPC) or (PLUNo = :pUPC)');
      ParamByName('pUPC').AsCurrency := UPCValue;
      Open();
      if (not EOF) then
      begin
        RetValue := (FieldByName('ItemNeedsActivation').AsInteger <> 0);
        bNeedMSR := (FieldByName('ItemNeedsSwipe').AsInteger = 1);
        bNeedPhoneNo := (FieldByName('ItemNeedsSwipe').AsInteger = 2);
      end;
      Close();
      if (Transaction.InTransaction) then
        Transaction.Commit();
    except
      on E : Exception do
      begin
        if (Transaction.InTransaction) then
          Transaction.Rollback();
        RetValue := False;
        bNeedMSR := False;
        bNeedPhoneNo := False;
        UpdateExceptLog( 'IsActivationUPC - cannot read PLU table: ' + e.message);
      end;
    end;
  end;  // with

  IsActivationUPC := RetValue;
end;  // function IsActivationUPC

function IsActivationType(const sd : pSalesData) : boolean;
{
Determine if a sales list entry represents an "activation" type product.
(It doesn't matter if the item has already been activated or not.)
}
var
  bNeedMSR : boolean;
  bNeedPhone : boolean;
begin
  if (sd <> nil) then
  begin
    if ((sd^.LineType = 'PLU') and
        (not sd^.LineVoided) and
        ((sd^.SaleType = 'Sale') or (sd^.SaleType = 'Rtrn') or (sd^.SaleType = 'Void')) ) then
      IsActivationType := IsActivationUPC(sd^.Number, bNeedMSR, bNeedPhone)
    else
      IsActivationType := False;
  end
  else
  begin
    IsActivationType := False;
  end;
end;  // function IsActivationType

function ProductActivationPending(qSaleList : pTList) : boolean;
var
  RetValue : boolean;
  qSalesData : pSalesData;
  j : integer;
begin
  RetValue := False;  // initial assumption (in case none found).
  if (qSaleList <> nil) then
  begin
    for j := 0 to qSaleList^.Count - 1 do
    begin
      qSalesData := qSaleList^.Items[j];
      if ((qSalesData^.ActivationState in [asWaitBalance, asActivationPending,            // waiting credit server
                                           asActivationFailed, asActivationSucceded]) and // waiting to process response
          (not qSalesData^.LineVoided)) then
      begin
        RetValue := True;
        break;
      end;
    end;
  end;
  ProductActivationPending := RetValue;
end;  // function ProductActivationPending

function ConvertVCIForActivation(const pVCI : pValidCardInfo;
                                 const qActivationProductType : pActivationProductType) : boolean;
{
Check to see if the supplied MSR data requires product activation and if so,
save information parsed by the credit server from the track data.
}
var
  cFaceValueDollars : currency;
  RetValue : boolean;
  pcode : string;
  i, l : integer;
  committrans : boolean;
begin
  cFaceValueDollars := 0.0;
  RetValue := False;
  if pVCI^.bActivationType then
  begin
    if (pVCI^.CardType = CT_GIFT) then
    begin
      ActivationProductData.ActivationCardType := CT_GIFT;
      RetValue := True;
    end
    else
    if (pVCI^.CardType = CT_PHONE) and (pVCI^.UPC < 0) then
    begin
      ActivationProductData.ActivationCardType := CT_PHONE;
      RetValue := True;
    end
    else
    begin
      if (pVCI^.CardType = CT_STORE_VALUE) and (pVCI^.UPC < 0) then
        pVCI^.UPC := - pVCI^.UPC;
      cFaceValueDollars := pVCI^.iFaceValueCents / 100.0;
      // Validate face value (if barcode has already been scanned).
      if ((ActivationProductData.ActivationAmount = 0.0) or (ActivationProductData.ActivationAmount = cFaceValueDollars)) then
        RetValue := True  // valid scan
      else
        pVCI.CardError :=  FormatFloat('$#,###.00 ;$#,###.00-', cFaceValueDollars) + ' amount on card does not match';
    end;
  end;
  if (RetValue) then
  begin
    // Determine if credit server is indicating a fuel-only gift card.
    // (Applies only when gift card to activate is scanned just prior to placing on sales list.)
    if (pVCI^.CardType = CT_GIFT) then
    begin
      if (pVCI^.bDebitBINMngt) then
        ActivationProductData.ActivationRestrictionCode := RC_ONLY_FUEL
      else if (fmPOS.bGiftRestrictions) then  // if system configured to prompt for restriction codes
        ActivationProductData.ActivationRestrictionCode := RC_UNKNOWN
      else
        ActivationProductData.ActivationRestrictionCode := RC_NO_RESTRICTION;
      {
      Note:  Traditional usage of "debit BIN mngt" does not apply to gift cards.
             DCOM interface variable bDebitMINMngt is being used as a special case
             to denote "fuel-only gift cards".  If DCOM interface is ever modified
             to include a separate argument, then following line is not necessary.
      }
      pVCI^.bDebitBINMngt := False;
    end;
    ActivationProductData.ActivationMSR := pVCI^.Track1Data + pVCI^.Track2Data;
    ActivationProductData.ActivationCardType := pVCI^.CardType;
    ActivationProductData.ActivationCardNo := pVCI^.CardNo;
    ActivationProductData.ActivationCardName := pVCI^.CardName;
    ActivationProductData.ActivationExpDate := pVCI^.ExpDate;
    if (cFaceValueDollars <> 0.0) then
      ActivationProductData.ActivationAmount := cFaceValueDollars;
    ActivationProductData.ActivationEntryType := ENTRY_TYPE_MSR;
    if (pVCI^.CardType = CT_PHONE) and (pVCI^.UPC < 0) then
    begin
      with POSDataMod.IBTempQuery do
      begin
        committrans := not Transaction.InTransaction;
        try
          if committrans then
            Transaction.StartTransaction;
          close();
          sql.Text := 'select upc from plu where itemno = :pSKU';
          ParamByName('pSKU').AsCurrency := -pVCI^.UPC;
          open();
          if not EOF then
            ActivationProductData.ActivationUPC := FieldByName('UPC').AsString;
          close();
          if committrans then
            Transaction.Commit;
        except
          on E : Exception do
          begin
            if committrans then
              Transaction.Rollback();
            UpdateExceptLog( 'CheckMSRforActivation - cannot select from PLU: %s while looking for "%g"', [e.message, -pVCI^.UPC]);
          end;
        end;
      end;
    end
    else
    if ((pVCI^.CardType = CT_PHONE) or (pVCI^.CardType = CT_STORE_VALUE)) and (pVCI^.UPC > 0) then
    begin
      ActivationProductData.ActivationUPC := CurrToStr(pVCI^.UPC);
    end
    else
    if (ActivationProductData.ActivationUPC = '') and (pVCI^.CardType = CT_PHONE) then
    begin
      pcode := ParseString(pVCI^.Track1Data, 2, '^');
      L := Length(pcode);
      I := 1;
      while (I <= L) and ((pcode[I] <= ' ') or (pcode[I] = '0')) do Inc(I);
      pcode := Copy(pcode, I, L - I + 1);
      with POSDataMod.IBTempQuery do
        begin
          try
            if (not Transaction.InTransaction) then
              Transaction.StartTransaction();
            Close();SQL.Clear();
            SQL.Add('select UPC from productcodemap where prodcode = :pProdCode');
            ParamByName('pProdCode').AsString := pcode;
            Open();
            if not EOF then
              ActivationProductData.ActivationUPC := CurrToStr(FieldByName('UPC').AsCurrency);
            Close();
            if (Transaction.InTransaction) then
              Transaction.Commit();
          except
            on E : Exception do
            begin
              if (Transaction.InTransaction) then
                Transaction.Rollback();
              UpdateExceptLog( 'CheckMSRforActivation - cannot select from ProductCodeMap: ' + e.message + ' while looking for "' + pcode + '"');
            end;
          end;
        end;  // with
    end
    else if (ActivationProductData.ActivationUPC = '') and (pVCI^.CardType = CT_STORE_VALUE) then
    begin
      pcode := ParseString(pVCI^.Track1Data, 2, '^');
      L := pos('$', pcode);
      if L = 12 then
      try
        ActivationProductData.ActivationUPC := UPCCheckDigit(copy(pcode, 1, 11));
      except
      end;
    end;
  end
  else if (pVCI^.CardError <> '') then
  begin
    fmPOS.POSError(pVCI^.CardError);
  end;
  ConvertVCIForActivation := RetValue;
end;  // function CheckMSRForActivation

procedure ClearActivationProductData(const qActivationProductType : pActivationProductType);
begin
  ZeroMemory(qActivationProductType, sizeof(TActivationProductType));
  qActivationProductType^.ActivationEntryType := ENTRY_TYPE_UNKNOWN;
  qActivationProductType^.ActivationRestrictionCode := RC_UNKNOWN;
end;  // procedure ClearActivationProductData

function AddActivationMessageLine(const ActivationMessage : string) : pSalesData;
{
Add a "status" entry to the sales list.  This new entry is for display
purposes only (for displaying information regarding the progress of a product activation).
This line appears on the line below the product that is being activated.
}
var
  MsgSaleData : pSalesData;
  j : integer;
begin
  New(MsgSaleData);
  ZeroMemory(MsgSaleData, sizeof(TSalesData));
  MsgSaleData^.SeqNumber := fmPos.CurSaleList.Count + 1;
  MsgSaleData^.LineType := SALE_DATA_LINE_TYPE_MESSAGE;
  MsgSaleData^.SaleType := 'None';
  MsgSaleData^.Number := 0.0;
  MsgSaleData^.Name := ActivationMessage;
  MsgSaleData^.Qty := 0.0;
  MsgSaleData^.Price := 0.0;
  MsgSaleData^.ExtPrice := 0.0;
  MsgSaleData^.SavDiscType := '';
  MsgSaleData^.SavDiscable := 0.0;
  MsgSaleData^.SavDiscAmount := 0.0;
  MsgSaleData^.FuelSaleID := 0;
  MsgSaleData^.PumpNo := 0;
  MsgSaleData^.HoseNo := 0;
  MsgSaleData^.TaxNo := 0;
  MsgSaleData^.TaxRate := 0.0;
  MsgSaleData^.Taxable := 0.0;
  MsgSaleData^.Discable := False;
  MsgSaleData^.FoodStampable := False;
  MsgSaleData^.FoodStampApplied := 0.0;
  MsgSaleData^.LineVoided := False;
  MsgSaleData^.AutoDisc := False;
  MsgSaleData^.PriceOverridden := False;
  MsgSaleData^.PLUModifier := 0;
  MsgSaleData^.PLUModifierGroup := 0.0;
  MsgSaleData^.DeptNo := 0;
  MsgSaleData^.VendorNo := 0;
  MsgSaleData^.ProdGrpNo := 0;
  MsgSaleData^.LinkedPLUNo := 0.0;
  MsgSaleData^.SplitQty := 0;
  MsgSaleData^.SplitPrice := 0.0;
  MsgSaleData^.QtyUsedForSplitOrMM := 0;
  MsgSaleData^.WexCode := 0;
  MsgSaleData^.PHHCode := 0;
  MsgSaleData^.IAESCode := 0;
  MsgSaleData^.VoyagerCode := 0;
  MsgSaleData^.CCAuthCode := '';
  MsgSaleData^.CCApprovalCode := '';
  MsgSaleData^.CCDate := '';
  MsgSaleData^.CCTime := '';
  MsgSaleData^.CCCardNo := '';
  MsgSaleData^.CCCardName := '';
  MsgSaleData^.CCCardType := '';
  MsgSaleData^.CCExpDate := '';
  MsgSaleData^.CCBatchNo := '';
  MsgSaleData^.CCSeqNo := '';
  MsgSaleData^.CCEntryType := '';
  MsgSaleData^.CCVehicleNo := '';
  MsgSaleData^.CCOdometer := '';
  MsgSaleData^.CCVehicleID := '';
  MsgSaleData^.CCRetrievalRef := '';
  MsgSaleData^.CCAuthNetId := '';
  MsgSaleData^.CCTraceAuditNo := '';
  MsgSaleData^.CCCPSData := '';
  for j := low(MsgSaleData^.CCPrintLine) to high(MsgSaleData^.CCPrintLine) do
    MsgSaleData^.CCPrintLine[j] := '';
  MsgSaleData^.CCBalance1 := UNKNOWN_BALANCE;
  MsgSaleData^.CCBalance2 := UNKNOWN_BALANCE;
  MsgSaleData^.CCBalance3 := UNKNOWN_BALANCE;
  MsgSaleData^.CCBalance4 := UNKNOWN_BALANCE;
  MsgSaleData^.CCBalance5 := UNKNOWN_BALANCE;
  MsgSaleData^.CCBalance6 := UNKNOWN_BALANCE;
  MsgSaleData^.CCRequestType := 0;
  MsgSaleData^.CCAuthid := 0;
  MsgSaleData^.GiftCardRestrictionCode := RC_UNSPECIFIED;
  MsgSaleData^.GiftCardStatus := CS_UNKNOWN;
  MsgSaleData^.GCMSRData := '';
  MsgSaleData^.ActivationState := asActivationDoesNotApply;
  MsgSaleData^.ActivationTransNo := 0;
  MsgSaleData^.ActivationTimeout := 0;
  MsgSaleData^.LineID := fmPOS.GetLineID();
  MsgSaleData^.ccPIN := '';
  MsgSaleData^.MODocNo := '';
  fmPos.CurSaleList.Capacity := fmPos.CurSaleList.Count;
  fmPOS.AddSalesListBeforeMedia(MsgSaleData);
  AddActivationMessageLine := MsgSaleData;
end;  // procedure AddActivationMessageLine

function AlterActivationMessageLine(const NewMessage : string;
                                    const AlterSaleList : pTList;
                                    const AlterLineID : integer;
                                    const bCurrentSale : boolean) : boolean;
{
Alter the message of a "status" entry on the sales list.  This entry is for display
purposes only (for displaying information regarding the progress of a product activation).
Also update the corresponding sales list entry on the screen (if bCurrentSale is true).
This line appears on the line below the product that is being activated.
}
var
  j : integer;
  qSalesData : pSalesData;
  ReturnValue : boolean;
begin
  ReturnValue := False;
  if (AlterSaleList <> nil) then
  begin
    for j := 0 to AlterSaleList^.Count - 1 do
    begin
      qSalesData := AlterSaleList^.Items[j];
      if ((qSalesData^.LineType = SALE_DATA_LINE_TYPE_MESSAGE) and
          ((qSalesData^.LineID = AlterLineID) or (AlterLineID <= 0))) then
      begin
        try
          qSalesData^.Name := NewMessage;
          qSalesData^.PriceOverridden := True;
          if (bCurrentSale) then
          begin
            PostMessage(fmPOS.Handle, WM_ACTIVATION_RESPONDED, 0, LongInt(0));
          end;
          ReturnValue := True;
        except
        end;
        // If message specific to a single item, then done; otherwise, continue searching for other applicable items.
        if (AlterLineID > 0) then
          break;
      end;
    end;
  end;  // if AlterSaleList not nil
  AlterActivationMessageLine := ReturnValue;
end;  // procedure AlterActivationMessageLine

procedure QueueBalanceInquiry(const qSalesData : pSalesData);
{
Queue a gift balance inquiry request (pointed to by qSalesData) to the credit server.
This request is sometimes issued before recharging a gift card to verify that the
balance will remain below the max allowed.
}
var
  CCMsg : string;
  GiftTrack1 : widestring;
  GiftTrack2 : widestring;
begin
  ParseMSR(qSalesData^.GCMSRData, GiftTrack1, GiftTrack2);
  CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_AUTHCARD)) +
           BuildTag(TAG_ENTRYTYPE, qSalesData^.CCEntryType) +
           BuildTag(TAG_AUTHAMOUNT, '0.0') +                 // Auth of zero on gift is "balance inquiry"
           BuildTag(TAG_CARDTYPE, qSalesData^.CCCardType) +
           BuildTag(TAG_TRANSNO,  Format('%6.6d',[qSalesData^.ActivationTransNo]) ) +
           BuildTag(TAG_USERDATACOUNT, IntToStr(qSalesData^.LineID)) +  // echoed back in response (to identify item in sales list)
           BuildTag(TAG_CARDNAME, qSalesData^.CCCardName) +
           BuildTag(TAG_CARDNO, qSalesData^.CCCardNo) +
           BuildTag(TAG_EXPDATE, qSalesData^.CCExpDate) +
           BuildTag(TAG_TRACK1DATA, GiftTrack1) +
           BuildTag(TAG_TRACK2DATA, GiftTrack2) +
           BuildTag(TAG_SERVICECODE, '000');
  fmPOS.SendCreditMessage(CCMsg);
  qSalesData^.ActivationTimeout := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
end;

procedure QueueActivationRequest(const qSalesData : pSalesData);
{
Queue a product activation request (pointed to by qSalesData) to the credit server.
}
var
  CCMsg : string;
  PhoneTrack1 : string;
  PhoneTrack2 : string;
  idxTrack1 : integer;
  idxTrack2 : integer;
  idxEndTrack : integer;
  sMsgType : string;
begin
  if (qSalesData^.SaleType = 'Rtrn') then
    sMsgType := IntToStr(CC_ACTIVATE_RETURN)
  else
    sMsgType := IntToStr(CC_ACTIVATE_GIFT);
  idxTrack1 := Pos('%', qSalesData^.GCMSRData);
  idxEndTrack := Pos('?', qSalesData^.GCMSRData);
  if ((idxTrack1 > 0) and (idxEndTrack > idxTrack1)) then
  begin
    PhoneTrack1 := Copy(qSalesData^.GCMSRData, idxTrack1, idxEndTrack - idxTrack1 + 1)
  end
  else
  begin
    PhoneTrack1 := '';
  end;
  idxTrack2 := Pos(';', qSalesData^.GCMSRData);
  if (idxTrack2 > 0) then
    PhoneTrack2 := Copy(qSalesData^.GCMSRData, idxTrack2, Length(qSalesData^.GCMSRData) - idxTrack2 + 1)
  else
    PhoneTrack2 := '';
  //
  CCMsg := BuildTag(TAG_MSGTYPE, sMsgType) +
           BuildTag(TAG_ENTRYTYPE, qSalesData^.CCEntryType) +
           BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', qSalesData^.ExtPrice))])) +
           BuildTag(TAG_CARDTYPE, qSalesData^.CCCardType) +
           BuildTag(TAG_TRANSNO,  Format('%6.6d',[qSalesData^.ActivationTransNo]) ) +
           BuildTag(TAG_USERDATACOUNT, IntToStr(qSalesData^.LineID)) +  // echoed back in response (to identify item in sales list)
           BuildTag(TAG_CARDNAME, qSalesData^.CCCardName) +
           BuildTag(TAG_CARDNO, qSalesData^.CCCardNo) +
           BuildTag(TAG_BILLING_PHONE, qSalesData^.CCPhoneNo) +
           BuildTag(TAG_EXPDATE, qSalesData^.CCExpDate) +
           BuildTag(TAG_RESTRICTION_CODE, IntToStr(qSalesData^.GiftCardRestrictionCode)) +
           BuildTag(TAG_TRACK1DATA, PhoneTrack1) +
           BuildTag(TAG_TRACK2DATA, PhoneTrack2) +
           BuildTag(TAG_SERVICECODE, '000');
  if qSalesData^.CCHost <> 0 then
    CCMsg := CCMsg + BuildTag(TAG_CCHOST, IntToStr(qSalesData^.CCHost));
  if qSalesData^.ItemNo <> 0 then
    CCMsg := CCMsg + BuildTag(TAG_USERDATA, Format('%d', [trunc(qSalesData^.ItemNo)]))  // UPC barcode
  else
    CCMsg := CCMsg + BuildTag(TAG_USERDATA, Format('%.12d', [trunc(qSalesData^.Number)]));  // UPC barcode
  fmPOS.SendCreditMessage(CCMsg);
  qSalesData^.ActivationState := asActivationPending;
  qSalesData^.ActivationTimeout := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
end;  // procedure QueueActivationRequest

function HandleActivationResponse(const CCActMsg : string) : pSalesData;
{
Handle response messages from the credit server that deal with prior product activation request.
Return True if sales amount is adjusted.
}
var
  ReturnValue : pSalesData;
  StatusMsg : string;
  sBalance : string;
  sTransNo : string;
  sRT : string;
  iTransNo : integer;
  cUserDataCount : string;
  iUserDataCount : integer;
  Action : integer;
  qSalesData : pSalesData;
  RespChargeAllowed : string;
  RespAuthID : string;
  RespAuthCode : string;
  OldAmount : currency;
  j : integer;
begin
  ReturnValue := nil;
  // Determine message type
  try
    Action :=  StrToInt(GetTagData(TAG_MSGTYPE, CCActMsg));
  except
    Action := 0;
  end;
  if (Action = 0) then
  begin
    UpdateExceptLog('---HandleActivationResponse - Invalid action:  ' + CCActMsg);
    HandleActivationResponse := ReturnValue;
    exit;
  end
  else if (Action = CC_AUTHMSG_ACT) then
  begin
    StatusMsg := GetTagData(TAG_STATUSSTRING, CCActMsg);
  end
  else
  begin
    StatusMsg := GetTagData(TAG_AUTHRESPMSG, CCActMsg);
  end;
  // Extract information from message that identifies the request that prompted this response:
  // TransNo is echoed back from the credit server (to match up response with prior request).
  // UserDataCount is echoed back from the credit server (it was the sequence number on the sales list).
  sTransNo :=  Trim(GetTagData(TAG_TRANSNO, CCActMsg));
  if (sTransNo <> '') then
  begin
    try
      iTransNo := StrToInt(sTransNo);
    except
      UpdateExceptLog('---HandleActivationRespose - Invalid TransNo:  ' + CCActMsg);
      iTransNo := 0;
    end;
  end
  else
  begin
    iTransNo := 0;
  end;

  // If for a specific request, then determine which item on sales list made the request
  if (iTransNo > 0) then
  begin
    cUserDataCount :=  Trim(GetTagData(TAG_USERDATACOUNT, CCActMsg));
    if (cUserDataCount <> '') then
    begin
      try
        iUserDataCount := StrToInt(cUserDataCount);
      except
        iUserDataCount := 0;
      end;
    end
    else
    begin
      iUserDataCount := 0;
    end;
    if (iUserDataCount <= 0) then
    begin
      UpdateExceptLog('---HandleActivationRespose - Invalid User Data Count:  ' + CCActMsg);
      HandleActivationResponse := ReturnValue;
      exit;  // Cannot identify message with sales list item.
    end;
  end
  else
  begin
    // Response is not message specific (i.e., it applies to all outstanding request).
    iUserDataCount := 0;
  end;

  qSalesData := UpdateActivationResponse(@(fmPos.CurSaleList), iTransNo, iUserDataCount, StatusMsg, True);
  // Also check items in any suspended sale (if not already located above).
  EnterCriticalSection(fmPOS.CSSuspendList);
  try
    if (bSuspendedSale and (SuspendList <> nil) and (qSalesData = nil){ and
        ((iTransNo = nCurTransNo) or (iTransNo = 0))}) then
    begin
      qSalesData := UpdateActivationResponse(@(SuspendList), iTransNo, iUserDataCount, StatusMsg, False);
    end;
  finally
    LeaveCriticalSection(fmPOS.CSSuspendList);
  end;
  // Process item
  if (qSalesData <> nil) then
  begin
    if (Action = CC_AUTHRESP_ACT) then
    begin
      // Determine if activation completed.
      qSalesData^.ActivationTimeout := 0;
      RespAuthID := Trim(GetTagData(TAG_AUTHID, CCActMsg));
      if (RespAuthID <> '') then
      begin
        try
          qSalesData^.CCAuthid := StrToInt(RespAuthID);
        except
        end;
      end;
      for j := low(qSalesData^.CCPrintLine) to high(qSalesData^.CCPrintLine) do
        qSalesData^.CCPrintLine[j] := GetTagData(IntToStr(nTAG_PRINT_LINE_1 - 1 + j), CCActMsg);
      qSalesData^.CCAuthCode := GetTagData(TAG_AUTHCODE, CCActMsg);
      RespChargeAllowed       := GetTagData(TAG_CHARGEALLOWED, CCActMsg);
      if (RespChargeAllowed = CA_NORMALAUTH) then
      begin
          qSalesData^.ActivationState := asActivationSucceded;
          if (qSalesData^.SaleType <> 'Void') then // Void PIN data comes from orig. trans. (not from credit server).
            qSalesData^.ccPIN := GetTagData(TAG_PINBLOCK, CCActMsg);
          // Extract new balance from message.
          sBalance := Trim(GetTagData(TAG_BALANCE, CCActMsg));
          if (sBalance <> '') then
          begin
            try
              qSalesData^.CCBalance1 := StrToCurr(sBalance);
            except
            end;
          end;
          // Extract old balance from message.
          sBalance := Trim(GetTagData(TAG_BALANCE_2, CCActMsg));
          if (sBalance <> '') then
          begin
            try
              qSalesData^.CCBalance2 := StrToCurr(sBalance);
            except
            end;
          end;
          sRT := Trim(GetTagData(TAG_VOUCHERTEXT, CCActMsg));
          qSalesData^.ReceiptText := '';
          if (sRT <> '') then
          try
            qSalesData^.ReceiptText := PChar(ansireplacestr(ansireplacestr(sRT, #1, #255), #2, '|'));
          except
            qSalesData^.ReceiptText := 'Exception Failure';
          end;
      end
      else
      begin
        qSalesData^.ActivationState := asActivationFailed;
      end;
      PostMessage(fmPOS.Handle, WM_ACTIVATION_RESPONDED, 0, LongInt(0));
    end
    else if (Action = CC_AUTHMSG_ACT) then
    begin
      // Reset the fail-safe timeout if status message received for this item.
      qSalesData^.ActivationTimeout := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
    end  // else if (Action = ...
    else if (Action = CC_BALANCERESP) then
    begin
      RespAuthCode := GetTagData(TAG_AUTHCODE, ccActMsg);
      if ((RespAuthCode = AC_APPROVAL) or (RespAuthCode = AC_ALREADY_ACTIVE)) then
      begin
        sBalance := Trim(GetTagData(TAG_BALANCE, ccActMsg));
        if (sBalance <> '') then
        begin
          try
            qSalesData^.CCBalance2 := StrToCurr(sBalance);
          except
          end;
        end;
        // Put card information on screen for status line.
        if (qSalesData^.CCBalance2 <> UNKNOWN_BALANCE) then
        begin
          StatusMsg := 'Balance:  $' + FormatFloat('###.00', qSalesData^.CCBalance2);
          if (UpdateActivationResponse(@(fmPos.CurSaleList), iTransNo, iUserDataCount, StatusMsg, True) = nil) then
          begin
            EnterCriticalSection(fmPOS.CSSuspendList);
            try
              if (bSuspendedSale and (SuspendList <> nil)) then
                UpdateActivationResponse(@(SuspendList), iTransNo, iUserDataCount, StatusMsg, False);
            finally
              LeaveCriticalSection(fmPOS.CSSuspendList);
            end;
          end;
        end;
        if (qSalesData^.CCBalance2 >= Setup.GIFTCARDFACEVALUEMAX) then
        begin
          qSalesData^.Price := 0.0;
          qSalesData^.ExtPrice := qSalesData^.Qty * qSalesData^.Price;
          qSalesData^.ActivationState := asActivationRejected;
          fmPos.PosError('Gift Card Already at MAX Balance: ' + FormatFloat('###.00', qSalesData^.CCBalance2));
          ReturnValue := qSalesData;
        end
        else if (qSalesData^.CCBalance2 + qSalesData^.Price > Setup.GIFTCARDFACEVALUEMAX) then
        begin
          OldAmount := qSalesData^.Price;
          qSalesData^.Price := Trunc(Setup.GIFTCARDFACEVALUEMAX - qSalesData^.CCBalance2);
          qSalesData^.ExtPrice := qSalesData^.Qty * qSalesData^.Price;
          fmPos.PosError('Gift Card Recharge Reduced From $' + FormatFloat('###.00', OldAmount) + ' To $' + FormatFloat('###.00', qSalesData^.Price));
          ReturnValue := qSalesData;
        end;
      end
      else if (RespAuthCode = AC_NOT_ACTIVATED) then
      begin
        StatusMsg := 'Card Inactive';
        if (UpdateActivationResponse(@(fmPos.CurSaleList), iTransNo, iUserDataCount, StatusMsg, True) = nil) then
        begin
          EnterCriticalSection(fmPOS.CSSuspendList);
          try
            if (bSuspendedSale and (SuspendList <> nil)) then
              UpdateActivationResponse(@(SuspendList), iTransNo, iUserDataCount, StatusMsg, False);
          finally
            LeaveCriticalSection(fmPOS.CSSuspendList);
          end;
        end;
      end;
      if (qSalesData^.ActivationState = asWaitBalance) then
      begin
        qSalesData^.ActivationTimeout := 0;
        qSalesData^.ActivationState := asActivationNeeded;  // now OK to tender media and activate card
      end;
    end;
  end;  // if (qSalesData <> nil)

  HandleActivationResponse := ReturnValue;
end;  // procedure HandleActivationResponse

procedure CompleteActivationResponse();
{
Complete activation response (for example, updating screen) and
(if final expected response) initiate tender complletion.
}
var
  qSalesData : pSalesData;
  SaveItemIndex : integer;
  j : integer;
  bStartedWithPendingActivations : boolean;
begin
  bStartedWithPendingActivations := ProductActivationPending(@(fmPos.CurSaleList));
  for j := 0 to fmPos.CurSaleList.Count - 1 do
  begin
    qSalesData := fmPos.CurSaleList.Items[j];
    if ((qSalesData^.LineType = SALE_DATA_LINE_TYPE_MESSAGE) and
         qSalesData^.PriceOverridden) then
    begin
      try
        SaveItemIndex := fmPOS.POSListBox.ItemIndex;
        fmPOS.POSListBox.ItemIndex := qSalesData^.SeqNumber - 1;
        fmPOS.POSListBox.DeleteSelected();
        fmPOS.POSListBox.ItemIndex := qSalesData^.SeqNumber - 1;
        fmPOS.POSListBox.Items.Insert(fmPOS.POSListBox.ItemIndex, 'D' + qSalesData^.Name);
        fmPOS.POSListBox.ItemIndex := SaveItemIndex;
        fmPOS.POSListBox.Refresh();
      finally
        qSalesData^.PriceOverridden := False;
      end;
    end;
    if (qSalesData^.ActivationState = asActivationSucceded) then
    begin
      qSalesData^.ActivationState := asActivationApproved;
    end
    else if (qSalesData^.ActivationState = asActivationFailed) then
    begin
      // Activation failed:  Notify clerk and auto-error correct from sales list.
      // (unless the sale is suspended -- in this case, handle when sale is resumeed).
      if (qSalesData^.CCAuthCode = AC_ALREADY_ACTIVE) then
        qSalesData^.ActivationState := asActivationRejected
      else
        qSalesData^.ActivationState := asActivationDeclined;
      SaveItemIndex := fmPOS.POSListBox.ItemIndex;
      fmPOS.POSListBox.ItemIndex := qSalesData^.SeqNumber - 1;
      fmPOS.ErrorCorrect();
      fmPOS.POSListBox.ItemIndex := SaveItemIndex;
    end;
  end;  // for each item in sales list
  // If this is the last activation request waiting a response, then resume processing of media
  // (The activations had been queued when the final media tender was approved, but the sale
  // had not been finalized at that time.)
  if (bStartedWithPendingActivations and (not ProductActivationPending(@(fmPos.CurSaleList))) and (fmPOS.SaleState = ssTender)) then
    fmPOS.BalanceOverTender();
end;  // procedure CompleteActivationResponse

function UpdateActivationResponse(const qSaleList : pTList;
                                  const ListTransNo : integer;
                                  const ListLineID : integer;
                                  const StatusMsg : string;
                                  const bCurrentSale : boolean) : pSalesData;
{
Locate the status message line(s) from the specified list (qSaleList) that apply
to a response and updtate the messages. The argument ListTransNo and ListLineID
identify the item(s) on the list that apply.
The argument bCurrentSale state determines if the sales list should also be modified.
}
var
  RetValue : pSalesData;
  qMessageSalesData : pSalesData;
  qSalesData : pSalesData;
  j : integer;
begin
  RetValue := nil;
  // Locate entry(s) in sales list for which this response applies.
  for j := 0 to qSaleList^.Count - 1 do
  begin
    qSalesData := qSaleList^.Items[j];
    if ((qSalesData^.ActivationState in [asWaitBalance, asActivationPending]) and
        ((qSalesData^.ActivationTransNo = ListTransNo ) or (ListTransNo <= 0 )) and
        ((qSalesData^.LineID = ListLineID) or (ListLineID <= 0))    ) then
    begin

      // Update message on sales list (should be on sales list line after the activation product).
      if (j + 1 < qSaleList^.Count) then
      begin
        qMessageSalesData := qSaleList^.Items[j + 1];
        if (qMessageSalesData <> nil) then
          AlterActivationMessageLine(StatusMsg, qSaleList, qMessageSalesData^.LineID, bCurrentSale);
      end;

      // If response specific to single item, then done; otherwise, contiune to locate other applicable items.
      if (ListLineID > 0) then
      begin
        RetValue := qSalesData;
        break;
      end;
    end;  // item matches response
  end;  // for each item in sales list
  UpdateActivationResponse := RetValue;
end;  // function UpdateActivationResponse

procedure IssueCardActivationPrompt(const PromptMsg : string);
{
Issue a prompt for card activation.  Generally, the prompt is for either a barcode scan or
a MSR swipe.
}
begin
  SavePOSErrorMsg_ShowYesNo           := fmPOSErrorMsg.ShowYesNo;
  SavePOSErrorMsg_lErrMsg_Caption     := fmPOSErrorMsg.lErrMsg.Caption;
  SavePOSErrorMsg_lblContinue_Caption := fmPOSErrorMsg.lblContinue.Caption;
  SavePOSErrorMsg_Caption             := fmPOSErrorMsg.Caption;
  SavePOSErrorMsg_Tag                 := fmPOSErrorMsg.Tag;

  fmPOSErrorMsg.Visible               := False;
  fmPOSErrorMsg.ShowYesNo             := False;
  fmPOSErrorMsg.lErrMsg.Caption       := PromptMsg;
  fmPOSErrorMsg.lblContinue.Caption   := 'Cancel';
  fmPOSErrorMsg.Caption               := 'Card Activation';
  fmPOSErrorMsg.Tag                   := POS_ERROR_MSG_TAG_CARD_ACTIVATION;
  fmPOSErrorMsg.Show();
end;  // procedure IssueCardActivationPrompt

procedure ClearCardActivationPrompt();
{
Clear a card activation prompt.  (Generally as a result of a barcode scan or MSR swipe.)
}
begin
  fmPOSErrorMsg.Visible             := False;
  fmPOSErrorMsg.ShowYesNo           := SavePOSErrorMsg_ShowYesNo;
  fmPOSErrorMsg.lErrMsg.Caption     := SavePOSErrorMsg_lErrMsg_Caption;
  fmPOSErrorMsg.lblContinue.Caption := SavePOSErrorMsg_lblContinue_Caption;
  fmPOSErrorMsg.Caption             := SavePOSErrorMsg_Caption;
  fmPOSErrorMsg.Tag                 := SavePOSErrorMsg_Tag;
end;  // procedure ClearCardActivationPrompt

procedure PrintPINReceiptText(const qSaleList : pTList);
{
Print text on receipt for any purchased PIN products:
}
var
  qSalesData : pSalesData;
  i, j : integer;
  s : string;
begin
  for i := 0 to qSaleList^.Count - 1 do
  begin
    qSalesData := qSaleList^.Items[i];
    if ((qSalesData^.ActivationState = asActivationApproved) and
        (not qSalesData^.LineVoided) and (qSalesData^.ExtPrice >= 0.0)) then
    begin
      POSPrt.PrintLine('');
      POSPrt.PrintLine('------------------------------');
      if (Trim(qSalesData^.CCCardNo) <> '') then
        if qSalesData^.CCCardType = CT_GIFT then
          PrintLine('Activation for: ' + cnRepl(qSalesData^.CCCardNo))
        else
          PrintLine('Activation for: ' + qSalesData^.CCCardNo);
      if (qSalesData^.CCBalance2 <> UNKNOWN_BALANCE) then
        PrintLine('Old Balance: ' + FormatFloat ( '#,###.00', qSalesData^.CCBalance2));
      if (qSalesData^.CCBalance1 <> UNKNOWN_BALANCE) then
        PrintLine('New Balance: ' + FormatFloat ( '#,###.00', qSalesData^.CCBalance1));
      // Print restriction code information (if applies):
      if qSalesData^.CCCardType = CT_GIFT then
        PrintGiftRestrictionCodeDescription(qSalesData^.GiftCardRestrictionCode);
      PrintLine('');
      for j := low(qSalesData^.CCPrintLine) to high(qSalesData^.CCPrintLine) do
        if qSalesData^.CCPrintLine[j] <> '' then
          PrintLine(qSalesData^.CCPrintLine[j]);
      if (Trim(qSalesData^.ccPIN) <> '') or (Trim(qSalesData^.CCPhoneNo) <> '') then
      begin
        if (Trim(qSalesData^.ccPIN) <> '') then
        begin
          PrintLine(qSalesData^.Name);
          PrintLine('PIN:  ' + qSalesData^.ccPIN);
        end;
        PrintLine('');
        with POSDataMod.IBTempQuery do
        begin
          try
            if (not Transaction.InTransaction) then
              Transaction.StartTransaction();
            Close();SQL.Clear();
            SQL.Add('select ReceiptText from ReceiptPINText where VendorNumber =');
            SQL.Add(' (select min(VendorNo) from PLU where ((PLUNo = :pPLUNo) or (UPC = :pPLUNo)))');
            SQL.Add(' order by LineNumber');
            ParamByName('pPLUNo').AsCurrency := qSalesData^.Number;
            Open();
            while (not EOF) do
            begin
              PrintLine(FieldByName('ReceiptText').AsString);
              Next();
            end;
            Close();
            if (Transaction.InTransaction) then
              Transaction.Commit();
          except
            on E : Exception do
            begin
              if (Transaction.InTransaction) then
                Transaction.Rollback();
              UpdateExceptLog( 'PrintPINReceiptText - cannot read ReceiptPINText table: ' + e.message);
            end;
          end;
        end;  // with
      end; // if push PIN to receipt type
      if (trim(qsalesdata^.receipttext) <> '') then
      begin
        s := trim(qsalesdata^.receipttext);
        while s <> '' do
        begin
          j := ansipos(#255, s);
          if j = 0 then
            j := length(s);
          PrintLine(ansileftstr(s, j-1));
          Delete(s, 1, j);
        end;
      end;
      PrintLine('');
    end;  // if item is activation product
    // IsActivationType
  end;
end;  //procedure PrintPINReceiptText


end.

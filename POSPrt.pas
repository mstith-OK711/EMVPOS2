{-----------------------------------------------------------------------------
 Unit Name: POSPrt
 Author:    Gary Whetton
 Date:      4/13/2004 11:52:30 AM
 Revisions: Build Number   Date      Author
            307            02/28/2005 Gary Whetton
            * Added 'input-synchronous' trap to CloseDrawer
-----------------------------------------------------------------------------}
unit POSPrt;
{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, AdPort, DB, POSMain, LatTypes;


procedure PrintLine(const pStr : string);

procedure PrintCardTotals(const q : pHostTotals);

//*************  Used in POSMain
procedure PrintVisaMCBalance(const qSalesData : pSalesData);
function PrintEBTBalance(const qSalesData : pSalesData) : boolean;
procedure PrintEBTDecline(const DeclineAmount : currency);
procedure PrintEMVDecline(const DeclineAmount : currency);
procedure PrintGiftRestrictionCodeDescription(const RestrictionCode : integer);
procedure PrintGiftCardBalance(const qGiftCardList : pTList; const Header1 : string; const Header2 : string);
//XMD
procedure PrintXMDData(ReceiptList : TList);
procedure PrintReceiptNoXMD(ReceiptList : TList);
//XMD
procedure PrintSeq(ReceiptList : TList = nil);
procedure PrintDebitReceiptFromReceiptList(ReceiptList : TList);
procedure PrintFuelOnlyReceiptFromReceiptList(ReceiptList : TList);
procedure PrintReceiptFromReceiptList(ReceiptList : TList);
function CheckReceiptListForSignatureRequired(ReceiptList : TList) : boolean;
procedure PrintFailedActivationFromReceiptList(ReceiptList : TList);
//************** End Used in POSMain

procedure PrintHeader;
procedure PrintFooter;
procedure PrintCancel;
procedure PrintSuspend;
procedure PrintCCMess(ReceiptData : pSalesData);
procedure FeedReceipt;
procedure OpenDrawer;
procedure CloseDrawer;

procedure CutReceipt;
procedure LoadPrinterSettings;
function ReturnASCIIString( S : String ) : String;

procedure PausePrint;
procedure ResumePrint;
procedure PrintReprint;
procedure PrintReversal();

//Mega Suspend
procedure PrintBill;
procedure PrintBillTL;
//Mega Suspend
{$IFDEF ODOT_VMT}
procedure PrintVMTData(const FuelSaleID : integer; const CreditAuthID : integer);
{$ENDIF}
{$IFDEF FF_PROMO}
procedure PrintFuelFirstCoupon(const CreditAuthID : integer;
                               const bPrintCoupon : boolean;
                               var CouponCount : integer);
{$ENDIF}

var
  CCUsed       : boolean;
  DebitUsed    : boolean;
  EBTFSUsed    : boolean;
  EBTCBUsed    : boolean;
  GiftUsed     : boolean;
  CCPtr        : pSalesData;
  DnBitMap     : array[0..1923] of char;
  {$IFDEF PDI_PROMOS}
  PromoDisc    : currency;
  {$ENDIF}


const
  bPrinterOK       : Boolean = True;
  CCSecond         : Boolean = False;
  bSignatureRequired : boolean = False;
  FirstError       : Boolean = True;
  CheckingPrinter  : Boolean = True;
  PrtStatus        : String = #29#114#49;//#27#118;
  PrtBold          : String = #27#33#32;
  PrtMode          : String = #27#33#64;
  PrtEOL           : String = #10;
  PrtCut           : String = #27#109;
  PrtFeed          : String = #27#100#8;
  PrtOpenDrawer    : String = #27#112#0#48#100#100;//#27#112#1#80#80;
  PrtFeed2         : String = #27#100#2;
  PrtBitMap        : String = #29#47#48;//#29#47#30;
  PrtDrawerStatus  : String = #29#114#50;//#27#117#30;
  PrtNCRBitMap     : String = #27'|1B';

//bp...
// Lines to print on receipt based on credit request type.
PRT_RT_CAT_AUTH         =  'Customer Activated Auth-Only';
PRT_RT_CAT_CAPTURE      =  'Customer Activated Capture';
PRT_RT_POS_AUTH         =  'POS Auth-Only';
PRT_RT_POS_CAPTURE      =  'POS Capture';
PRT_RT_POS_AUTH_CAPTURE =  'POS Purchase';
PRT_RT_RETURN           =  'Return';
PRT_RT_AUTH_VOID        =  'Auth-Only Void';
PRT_RT_PURCHASE_REVERSE =  'Purchase Reversal';
//...bp


implementation

uses POSDM, POSErr, POSMsg,
      CardActivation, StrUtils,
      JclHashMaps,
      ExceptLog, Reports, POSMisc, LatTaxes;

procedure PrintMdse(ReceiptData : pSalesData); forward;
procedure PrintPrePay(ReceiptData : pSalesData); forward;
procedure PrintPrePayRefund(ReceiptData : pSalesData); forward;
procedure PrintDisc(ReceiptData : pSalesData); forward;
procedure PrintFuel(ReceiptData : pSalesData); forward;
procedure PrintTl(ReceiptList : TList); forward;
procedure PrintFuelTl(TLAmount : currency); forward;
procedure PrintMedia(ReceiptData : pSalesData); forward;
procedure PrintChange; forward;

procedure AddLine(const PrintCmd : Integer; const PrintLine : WideString);
var
  TryCount : integer;
begin
  for TryCount := 1 to 5 do
  begin
    try
      fmPOS.DCOMPrinter.AddLine(PrintCmd, PrintLine);
      break;
    except
      on E: Exception do
        fmPOS.ReconnectPrinter('AddLine ', e.message, TryCount);
    end;
  end;
end;

procedure PrintLine(const PStr : string);
begin
  AddLine(PRT_NORMALTEXT, PStr + PrtEOL);
end;


{-----------------------------------------------------------------------------
  Name:      CheckTax
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
function CheckTax(ReceiptData : pSalesData) : string;
var
  pStr : string;
begin
  pStr := '';
  if (ItemTaxed(ReceiptData)) then
    pStr := pStr + 'T'
  else
    pStr := pStr + ' ';

  if ReceiptData^.Discable then
    pStr := pStr + 'D'
  else
    pStr := pStr + ' ';

  if bUseFoodStamps then
    if ReceiptData^.FoodStampable then
      pStr := pStr + 'F'
    else
      pStr := pStr + ' ';
  Result := pStr;
end;

{-----------------------------------------------------------------------------
  Name:      PrintReceiptFromReceiptList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintReceiptFromReceiptList(ReceiptList : TList);
var
  i : integer;
  {$IFNDEF MULTI_TAX}  //20061207d
  Med1 : integer;
  {$ENDIF}
  CarwashAccessCode : string;
  CarwashExpDate : string;
  MediaCardType : string;
  ReceiptData : pSalesData;
begin
  {$IFNDEF MULTI_TAX}  //20061207d
  Med1 := 1;
  {$ENDIF}
  {$IFDEF PDI_PROMOS}
  PromoDisc := 0.00;
  {$ENDIF}
  if ReceiptList.Count > 0 then
  begin
    for i := 0 to ReceiptList.Count-1 do
    Begin
      ReceiptData := ReceiptList.Items[i];
      if (Length(ReceiptData^.SaleType) <= 0) then
         ReceiptData^.SaleType := 'Sale';
      if (ReceiptData^.LineType = 'MED')
                                        {$IFDEF MULTI_TAX}
                                        or (ReceiptData^.LineType = 'TAX')
                                        {$ENDIF}
                                        then
      begin
        {$IFNDEF MULTI_TAX}  //20061207d
        Med1 := i;
        {$ENDIF}
        break;
      end
      else
      Begin
        if NOT bPrintVoids then
        begin
          if (ReceiptData^.LineVoided = True) or (ReceiptData^.SaleType = 'Void') then
            continue;
        end;
        if ReceiptData^.LineType = 'DPT' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'PLU' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'BNK' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'PPY' then     { Prepay }
          PrintPrepay(ReceiptData)
        else if ReceiptData^.LineType = 'PRF' then     { Prepay Refund }
          PrintPrePayRefund(ReceiptData)
        else if ReceiptData^.LineType = 'FUL' then
        begin
          {$IFDEF ODOT_VMT}  //20061023f
          if (i < ReceiptList.Count - 1) then
            ReceiptDataNextLine := ReceiptList.Items[i + 1]   //Used to check for fuel discounts on next line
          else
            ReceiptDataNextLine := nil;
          {$ENDIF}
          PrintFuel(ReceiptData);
        end
        else if ReceiptData^.LineType = 'DSC' then
          PrintDisc(ReceiptData)
        else if ReceiptData^.LineType = 'MXM' then
          PrintDisc(ReceiptData)
        //XMD
        else if (ReceiptData^.LineType = 'XMD') and (ReceiptData^.Number <> 0) then
          PrintDisc(ReceiptData)
        //XMD
        {$IFDEF CASH_FUEL_DISC}
        else if ReceiptData^.LineType = 'DS$' then
          PrintDisc(ReceiptData)
        {$ENDIF}
        //20061023f...  (Logic moved to PrintFuel())
//        {$IFDEF ODOT_VMT}
//        else if ReceiptData^.LineType = 'DSV' then
//          PrintDisc
//        {$ENDIF}
        //...20061023f
        //DSG
        else if ReceiptData^.LineType = 'DSG' then
          PrintDisc(ReceiptData);
        //DSG
      End;

       { We have to prevent a Buffer overflow with too many receiptlines... }

    End;

    PrintTl(ReceiptList);

    {$IFDEF MULTI_TAX}  //20061207d (change MULT_TAX to MULTI_TAX)
    for i:= 0 to ReceiptList.Count-1 do
    {$ELSE}
    for i:= Med1 to ReceiptList.Count-1 do
    {$ENDIF}
    begin
      ReceiptData := ReceiptList.Items[i];
      if ReceiptData^.LineType = 'MED' Then
      begin
        if ReceiptData^.PLUModifier in [CREDIT_MEDIA_TYPE, DEBIT_MEDIA_TYPE ] then
        begin
          CCUsed := true;
          GiftUsed := false;
          PrintMedia(ReceiptData);
          PrintVisaMCBalance(ReceiptData);  //20071029b
          PrintCCMess(ReceiptData);
        end
        else if ReceiptData^.PLUModifier in [ DEFAULT_GIFT_CARD_MEDIA_TYPE ] then
        begin
          GiftUsed := true;
          CCUsed := true;
          PrintMedia(ReceiptData);
          PrintCCMess(ReceiptData);
        end
        else
          PrintMedia(ReceiptData);
        MediaCardType := Trim(ReceiptData^.CCCardType);
        if ReceiptData^.PLUModifier in [FOOD_STAMP_MEDIA_TYPE, EBT_FS_MEDIA_TYPE ] then
        begin
          PrintEBTBalance(ReceiptData);
          PrintCCMess(ReceiptData);
        end;
      end;
    end;
    PrintChange;
    // Print access code for any carwash purchases
    for i := 0 to ReceiptList.Count-1 do
    begin
      ReceiptData := ReceiptList.Items[i];
      CarwashAccessCode := fmPOS.GetCarwashAccessCode(ReceiptData);
      if (CarwashAccessCode <> '') then
      begin
        PrintLine('Carwash Access Code: ' + PrtBold + CarwashAccessCode + Prtmode);
        CarwashExpDate := fmPOS.GetCarwashExpDate(ReceiptData);
        if (CarwashExpDate <> '') then
        begin
          PrintLine('Valid Through: ' + CarwashExpDate);
        end;
      end;
    end;

    //20070719a...
    if (bDebitUsed and (nCreditAuthType = CDTSRV_BUYPASS)) then
    begin
      if (CCSecond or PRINT_OLD_RECEIPT) then
        PrintLine(PrtBold + '** Customer Copy **' + PrtMode)
      else
        PrintLine(PrtBold + '** Merchant Copy **' + PrtMode);
    end;
    //...20070719a

    PrintSeq(ReceiptList);
    //XMD
    for i := 0 to ReceiptList.Count-1 do
    begin
      ReceiptData := ReceiptList.Items[i];
      if (ReceiptData^.LineType = 'XMD') and (ReceiptData^.Number = 0) then
      begin
        if (bCCUsed and CCSecond) or not bCCUsed then
          PrintXMDData(ReceiptList);
        break;
      end;
    end;
    //XMD
  end;
End;

function CheckReceiptListForSignatureRequired(ReceiptList : TList) : boolean;
{
Check receipt list to see if a credit tender requires a signature line.
}
var
  rd : psalesData;
  SignatureRequredDollarLimit : currency;
  j : integer;
  ReturnValue : boolean;
begin
  ReturnValue := False;  // initial assumption.
  try
    SignatureRequredDollarLimit := fmPOS.Config.Cur['CC_SIGNATURE_LIMIT'];
  except
    SignatureRequredDollarLimit := 0.0;
  end;
  if (SignatureRequredDollarLimit > 0.0) then
  begin
    for j := 0 to ReceiptList.Count - 1 do
    begin
      rd := ReceiptList.Items[j];
      if ((rd^.Number = CREDIT_MEDIA_NUMBER) and
          (rd^.LineType = 'MED') and
          (Abs(rd^.ExtPrice) >= SignatureRequredDollarLimit)) then
      begin
        ReturnValue := True;
        break;
      end;
    end;
  end;
  CheckReceiptListForSignatureRequired := ReturnValue;
end;  // function CheckReceiptListForSignatureRequired

procedure PrintCCLines(const qSalesData : pSalesData);
var
  j : integer;
begin
  for j := low(qSalesData^.CCPrintLine) to high(qSalesData^.CCPrintLine) do
    if (Trim(qSalesData^.CCPrintLine[j]) <> '') then
      PrintLine(qSalesData^.CCPrintLine[j]);
end;

procedure PrintFailedActivationFromReceiptList(ReceiptList : TList);
{
Print report (store copy) at end of receipt showing any activation products
that failed to activate.
}
var
  qReceiptData : pSalesData;
  j : integer;
  rReceiptData : pSalesData;
  k : integer;
begin
  PrintLine('Following Failed To Process:');
  PrintLine('');
  for j := 0 to (ReceiptList.Count - 1) do
  begin
    qReceiptData := ReceiptList.Items[j];
    if (qReceiptData^.NeedsActivation) then
    begin
      if ((qReceiptData^.SaleType = 'Void') and (qReceiptData^.ExtPrice < 0.0) and
          (not (qReceiptData^.ActivationState in [asActivationDoesNotApply, asActivationRejected]))) then
      begin
        PrintLine('');
        PrintLine('Product: ' + qReceiptData^.Name);
        if (qReceiptData^.CCAuthId > 0) then
          PrintLine('AuthID: ' + IntToStr(qReceiptData^.CCAuthId));
        PrintLine('LineID: ' + IntToStr(qReceiptData^.LineID));
        if (Trim(qReceiptData^.CCCardNo) <> '') then
          PrintLine('Card Number:' + qReceiptData^.CCCardNo);
        if (Trim(qReceiptData^.ccPIN) <> '') then
          PrintLine('Card PIN:' + qReceiptData^.ccPIN);
        // Search for sales line from original activation attempt:
        if (qReceiptData^.LineID > 0) then
        begin
          for k := j - 1 downto 0 do
          begin
            rReceiptData := ReceiptList.Items[k];
            if ((rReceiptData^.LineID = qReceiptData^.LineID) and
                (rReceiptData^.LineType <> SALE_DATA_LINE_TYPE_MESSAGE)) then
            begin
              PrintCCLines(rReceiptData);
              break;
            end;
          end;  // if (qReceiptData^.LineID > 0)
        end;  // for each item above this void
        PrintLine('*** AUTO VOID ***');
        PrintCCLines(qReceiptData);
      end;  // if declined reversal (VOID)
    end;  // if activation type
  end;  // for each item in receipt list.
  PrintLine('');
  PrintLine('Retain Card(s) and Attach This Receipt');
  PrintLine('');
end;  //  procedure PrintFailedActivationFromReceiptList

{-----------------------------------------------------------------------------
  Name:      PrintXMDData
  Author:    Gary Whetton
  Date:      05-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintXMDData(ReceiptList : TList);
var
  Ndx, Ndx1  : Byte;
  XMDCode : string;
  pStr : string;
  ProductArray : array[0..100,0..1] of string[20];
  HDRBLANKLINESABOVE,
  HDRBLANKLINESBELOW :Integer;
  HDR1,
  HDR2,
  HDR3 : string;
  HDR1BOLD,
  HDR2BOLD,
  HDR3BOLD,
  FTRBLANKLINESABOVE,
  FTRBLANKLINESBELOW : Integer;
  FTR1,
  FTR2,
  FTR3 : string;
  FTR1BOLD,
  FTR2BOLD,
  FTR3BOLD : Integer;
  DISCOUNTLINE,
  MAXVOLUMELINE,
  EXPIRELINE,
  CODELINE : string;
  LineCount : Integer;
  FoundItem : Boolean;
  TotalDiscount : Currency;
  ReceiptData : pSalesData;
begin
  TotalDiscount := 0;
  if not POSDataMod.IBXMDTrans.InTransaction then
    POSDataMod.IBXMDTrans.StartTransaction;
  with POSDataMod.IBXMDQry1 do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from XMDReceipt');
    Open;
    HDRBLANKLINESABOVE := FieldByName('HDRBLANKLINESABOVE').AsInteger;
    HDRBLANKLINESBELOW := FieldByName('HDRBLANKLINESBELOW').AsInteger;
    HDR1 := FieldByName('HDR1').AsString;
    HDR2 := FieldByName('HDR2').AsString;
    HDR3 := FieldByName('HDR3').AsString;
    HDR1BOLD := FieldByName('HDR1BOLD').AsInteger;
    HDR2BOLD := FieldByName('HDR2BOLD').AsInteger;
    HDR3BOLD := FieldByName('HDR3BOLD').AsInteger;
    FTRBLANKLINESABOVE := FieldByName('FTRBLANKLINESABOVE').AsInteger;
    FTRBLANKLINESBELOW := FieldByName('FTRBLANKLINESBELOW').AsInteger;
    FTR1 := FieldByName('FTR1').AsString;
    FTR2 := FieldByName('FTR2').AsString;
    FTR3 := FieldByName('FTR3').AsString;
    FTR1BOLD := FieldByName('FTR1BOLD').AsInteger;
    FTR2BOLD := FieldByName('FTR2BOLD').AsInteger;
    FTR3BOLD := FieldByName('FTR3BOLD').AsInteger;
    DISCOUNTLINE := FieldByName('DISCOUNTLINE').AsString;
    MAXVOLUMELINE := FieldByName('MAXVOLUMELINE').AsString;
    EXPIRELINE := FieldByName('EXPIRELINE').AsString;
    CODELINE := FieldByName('CODELINE').AsString;
    Close;
  end;
  if POSDataMod.IBXMDTrans.InTransaction then
    POSDataMod.IBXMDTrans.Commit;
  for Ndx  := 0 to 100 do
  begin
    ProductArray[Ndx,0] := '';
    ProductArray[Ndx,1] := '';
  end;
  for Ndx := 0 to ReceiptList.Count - 1 do
  begin
    ReceiptData := ReceiptList.Items[Ndx];
    if ReceiptData^.CCPrintLine[1] = 'XMD' then
    begin
      FoundItem := False;
      TotalDiscount := TotalDiscount + strtocurr(trim(Copy(ReceiptData^.CCPrintLine[2],1,20)));
      for ndx1 := 0 to 100 do
      begin
        if ProductArray[Ndx1,0] = ReceiptData^.Name then
        begin
          ProductArray[Ndx1,1] := CurrToStr(strtocurr(ProductArray[Ndx1,1]) + strtocurr(trim(Copy(ReceiptData^.CCPrintLine[2],1,20))));
          FoundItem := True;
          break;
        end;
      end;
      if not FoundItem then
      begin
        ProductArray[Ndx,0] := ReceiptData^.Name;
        ProductArray[Ndx,1] := trim(Copy(ReceiptData^.CCPrintLine[2],1,20));
      end;
    end;
  end;
  if HDRBLANKLINESABOVE > 0 then
  begin
    for LineCount := 1 to HDRBLANKLINESABOVE do
      PrintLine('');
  end;
  for Ndx := 0 to ReceiptList.Count-1 do
  begin
    ReceiptData := ReceiptList.Items[Ndx];
    XMDCode := fmPOS.GetXMDEarned(ReceiptData);
    if XMDCode <> '' Then
    begin
      if Length(HDR1) > 0 then
      begin
        if Boolean(HDR1Bold) then
          pStr := PrtBold
        else
          pStr := '';
        pStr := pStr + trimright(HDR1);
        if Boolean(HDR1Bold) then
          pStr := pStr + PrtMode;
        PrintLine(pStr);
      end;
      if Length(HDR2) > 0 then
      begin
        if Boolean(HDR2Bold) then
          pStr := PrtBold
        else
          pStr := '';
        if Boolean(HDR2Bold) then
          pStr := pStr+trimright(HDR2)+ PrtMode
        else
          pStr := HDR2;
        PrintLine(pStr);
      end;
      if Length(HDR3) > 0 then
      begin
        if Boolean(HDR3Bold) then
          pStr := PrtBold
        else
          pStr := '';
        if Boolean(HDR3Bold) then
          pStr := pStr+trimright(HDR3)+ PrtMode
        else
          pStr := HDR3;
        PrintLine(pStr);
      end;

      if HDRBLANKLINESBELOW > 0 then
      begin
        for LineCount := 1 to HDRBLANKLINESABOVE do
          PrintLine('');
      end;
      for Ndx1 := 0 to 100 do
      begin
        if ProductArray[Ndx1,0] <> '' then
        begin
          case bReceiptActive of
            DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-29s',[ProductArray[Ndx1,0]])  + '$' +
                     FormatFloat('0.00 ;0.00-', strtocurr(ProductArray[Ndx1,1])) +
                     '/Gallon');
            (*DRIVER_EPSON   :  pStr := Format('%-30s',[ProductArray[Ndx1,0]])  + '$' +
                     FormatFloat('0.00 ;0.00-', strtocurr(ProductArray[Ndx1,1]))+
                     '/Gallon';*)
          end;
        end;
      end;
      PrintLine('');
      if TotalDiscount > StrToFloat(Copy(XMDCode,10,3))/100 then
      begin
        PrintLine('Maximum Discount Met');
        PrintLine('');
      end;
      if Length(trim(DISCOUNTLINE)) > 0 then
        PrintLine(Format('%-29s',[DISCOUNTLINE]) + '$' + FormatFloat('0.00 ;0.00-',(StrToFloat(Copy(XMDCode,10,3))/100)) + '/Gallon')
      else
        PrintLine('Total Discount:               $' +
          FormatFloat('0.00 ;0.00-',(StrToFloat(Copy(XMDCode,10,3))/100)) + '/Gallon');

      if Length(trim(MAXVOLUMELINE)) > 0 then
        PrintLine(Format('%-29s',[MAXVOLUMELINE]) + IntToStr(XMDMaxVolume) + ' Gallons')
      else
        PrintLine('Maximum of ' + IntToStr(XMDMaxVolume) + ' Gallons');

      PrintLine('');

      if Length(trim(CODELINE)) > 0 then
        PrintLine(Format('%-30s',[CODELINE]) + trim(ReceiptData^.CCCardName))
      else
        PrintLine('Discount Code:                '+ trim(ReceiptData^.CCCardName));

      PrintLine('');

      if Length(trim(ExpireLine)) > 0 then
        PrintLine(Format('%-30s',[EXPIRELINE]) + ReceiptData^.CCPrintLine[1])
      else
        PrintLine('This Discount will Expire on:  ' + ReceiptData^.CCPrintLine[1]);

      PrintLine('');

      if FTRBLANKLINESABOVE > 0 then
        for LineCount := 1 to FTRBLANKLINESABOVE do
          PrintLine('');

      if Length(FTR1) > 0 then
        if Boolean(FTR1BOLD) then
          PrintLine(PrtBold +trimright(FTR1)+ PrtMode)
        else
          PrintLine(FTR1);

      if Length(FTR2) > 0 then
        if Boolean(FTR2BOLD) then
          PrintLine(PrtBold +trimright(FTR2)+ PrtMode)
        else
          PrintLine(FTR2);

      if Length(FTR3) > 0 then
        if Boolean(FTR3BOLD) then
          PrintLine(PrtBold +trimright(FTR3)+ PrtMode)
        else
          PrintLine(FTR3);

      if FTRBLANKLINESBELOW > 0 then
        for LineCount := 1 to FTRBLANKLINESBELOW do
          PrintLine('');

      try
        fmPos.DCOMPrinter.AddLine(PRT_BARCODE,trim(ReceiptData^.CCCardName));
      except
      end;
      PrintLine('');
    end;
  end;
  PrintSeq();
end;
//XMD


{-----------------------------------------------------------------------------
  Name:      PrintFuelOnlyReceiptFromReceiptList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintFuelOnlyReceiptFromReceiptList(ReceiptList : TList);
var
  i  : integer;
  FuelTL : currency;
  ReceiptData : pSalesData;
begin
  ResumePrint;  //Make sure the printer is back on after eod/eos
  FuelTl := 0;
  for i := 0 to ReceiptList.Count-1 do
    Begin
      ReceiptData := ReceiptList.Items[i];
      if ReceiptData^.LineType = 'MED' Then
        begin
          break;
        end
      else
        Begin

         if NOT bPrintVoids then
           begin
             if (ReceiptData^.LineVoided = True) or (ReceiptData^.SaleType = 'Void') then
               continue;
           end;
         if ReceiptData^.LineType = 'PPY' then     { Prepay }
           begin
             FuelTl := FuelTl + ReceiptData^.ExtPrice;
             PrintPrepay(ReceiptData);
           end
         else if ReceiptData^.LineType = 'PRF' then     { Prepay Refund }
           begin
             FuelTl := FuelTl + ReceiptData^.ExtPrice;
             PrintPrePayRefund(ReceiptData);
           end
         else if ReceiptData^.LineType = 'FUL' then
           begin
             FuelTl := FuelTl + ReceiptData^.ExtPrice;
             {$IFDEF ODOT_VMT}  //20061023f
             if (i < ReceiptList.Count - 1) then
               ReceiptDataNextLine := ReceiptList.Items[i + 1]   //Used to check for fuel discounts on next line
             else
               ReceiptDataNextLine := nil;
             {$ENDIF}
             PrintFuel(ReceiptData);
           end;
       End;

    End;

  PrintFuelTl(FuelTl);
  PrintSeq;
End;


{-----------------------------------------------------------------------------
  Name:      PrintDebitReceiptFromReceiptList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintDebitReceiptFromReceiptList(ReceiptList : TList);
var
  i, n, x, j : integer;
  pStr : shortstring;
  ReceiptData : pSalesData;
begin
  for i := 0 to ReceiptList.Count-1 do
    begin
      ReceiptData := ReceiptList.Items[i];
      if ReceiptData^.LineType = 'MED' then
        begin

          PrintLine(FormatDateTime('mmm dd, yyyy h:mm AM/PM', Now));

          //bpc...
          ReceiptData^.CCCardNo := Trim(ReceiptData^.CCCardNo);
          //...bpc
          pStr := ReceiptData^.CCCardNo;
          x := Length(ReceiptData^.CCCardNo);
          //bpc...
//          for n := 1 to (x-4) do
//             pStr[n] := 'X';
          if (bPANTruncationCustomerCopy) then
            begin
              for n := 1 to (x - nPANNonTruncatedCustomerCopy) do
                 pStr[n] := 'X';
            end;
          //...bpc
          PrintLine('Account# ' + pStr);

          if ReceiptData^.ExtPrice < 0 then
            PrintLine('ATM RETURN, PRIMARY')
          else if rcptSale.nChangeDue > 0 then
            PrintLine('ATM SALE WITH CASH BACK, PRIMARY')
          else
            PrintLine('ATM SALE, PRIMARY');

          PrintLine('Trace Audit# ' + ReceiptData^.CCTraceAuditNo);

          ReceiptData := ReceiptList.Items[ReceiptList.Count-1];
          case bReceiptActive of
            DRIVER_DIRECT, DRIVER_OPOS :
              PrintLine(Format('%20s%9s',['Amount',Float2Str(ReceiptData^.ExtPrice - rcptSale.nChangeDue,2)]));
            (*DRIVER_EPSON   :  pStr := Format('%14s',['Amount'])  +
                     Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice - rcptSale.nChangeDue))]);*)
          end;

          if rcptSale.nChangeDue <> 0 then
          begin
            case bReceiptActive of
              DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%20s%9s',['Cashback Amount',Float2Str(rcptSale.nChangeDue,2)]));
              (*DRIVER_EPSON   :  pStr := Format('%14s',['Cashback Amount'])  +
                       Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', rcptSale.nChangeDue))]);*)
            end;
          end;
          case bReceiptActive of
              DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%20s%9s',['Total Amount',Float2Str(ReceiptData^.ExtPrice,2)]));
              (*DRIVER_EPSON   :  pStr := Format('%14s',['Total Amount'])  +
                       Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice ))]);*)
          end;

          ReceiptData := ReceiptList.Items[i];

          PrintLine('Approval ' + ReceiptData^.CCApprovalCode);

          if ReceiptData^.CCAuthNetID = '41' then
            PrintLine('            TYME IS MONEY');

//          if (nCreditAuthType = CDTSRV_BUYPASS) then
          if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_LYNK]) then
          //lya...
              PrintLine('Merchant ID: ' + sTerminalID);
          for j := low(ReceiptData^.CCPrintLine) to high(ReceiptData^.CCPrintLine) do
            if (ReceiptData^.CCPrintLine[j] <> '') then
              PrintLine(ReceiptData^.CCPrintLine[j]);


          //if ((nCreditAuthType = CDTSRV_BUYPASS) and (ReceiptData^.CCAuthorizer <> CC_AUTHORIZER_UNKNOWN)) then
          //  begin
          //    pStr := 'Authorizer Code: ' + IntToStr(ReceiptData^.CCAuthorizer);
          //    PrintReceipt;
          //  end;

          if      (ReceiptData^.CCRequestType = RT_CAT_AUTH)         then PrintLine(PRT_RT_CAT_AUTH)
          else if (ReceiptData^.CCRequestType = RT_CAT_CAPTURE)      then PrintLine(PRT_RT_CAT_CAPTURE)
          else if (ReceiptData^.CCRequestType = RT_POS_AUTH)         then PrintLine(PRT_RT_POS_AUTH)
          else if (ReceiptData^.CCRequestType = RT_POS_CAPTURE)      then PrintLine(PRT_RT_POS_CAPTURE)
          else if (ReceiptData^.CCRequestType = RT_POS_AUTH_CAPTURE) then PrintLine(PRT_RT_POS_AUTH_CAPTURE)
          else if (ReceiptData^.CCRequestType = RT_RETURN)           then PrintLine(PRT_RT_RETURN)
          else if (ReceiptData^.CCRequestType = RT_AUTH_VOID)        then PrintLine(PRT_RT_AUTH_VOID)
          else if (ReceiptData^.CCRequestType = RT_PURCHASE_REVERSE) then PrintLine(PRT_RT_PURCHASE_REVERSE);
          //...bp
          break;
        end;
       { We have to prevent a Buffer overflow with too many receiptlines... }
    end;

  //20070719a...
  if (nCreditAuthType = CDTSRV_BUYPASS) then
  begin
    if (CCSecond or PRINT_OLD_RECEIPT) then
      PrintLine(PrtBold + '** Customer Copy **' + PrtMode)
    else
      PrintLine(PrtBold + '** Merchant Copy **' + PrtMode);
  end;
  //...20070719a
  PrintSeq(ReceiptList);

end;

{-----------------------------------------------------------------------------
  Name:      PrintMdse
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintMdse(ReceiptData : pSalesData);
{
1234567890123456789012345678901234567890
Sale where Qty = 1
xxxxxxxxxxxxxxxxxxxx         9,999.00-
Sale where Qty > 1
xxxxxxxxxxxxxxxxxxxx
99 @ 9,999.00-               9,999.00-
}
begin

  if ReceiptData^.SaleType = 'Void' then
    PrintLine('*** VOID ***')
  else if ReceiptData^.SaleType = 'Rtrn' then
    PrintLine(PrtBold + '*** RETURN ***' + PrtMode + PrtEol);   //Bold format

  if ReceiptData^.Qty > 1 then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s',[copy(ReceiptData^.Name,1,30)]));
      //DRIVER_EPSON   :  pStr := Format('%-14s',[ReceiptData^.Name]);
    end;

    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%2s @ %9s%26s%3s',[CurrToStr(ReceiptData^.Qty),
                                                                         Float2Str(ReceiptData^.Price, 2),
                                                                         Float2Str(ReceiptData^.ExtPrice, 2),
                                                                         CheckTax(ReceiptData)]) );
      (*DRIVER_EPSON   :  pStr := Format('%2s',[CurrToStr(ReceiptData^.Qty)])  + ' @ ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', ReceiptData^.Price))]) +
               Format('%17s',[(FormatFloat('#,###.00 ;#,###.00-', ReceiptData^.ExtPrice))]);*)
    end;
  end
  else
  begin
    if ReceiptData^.MODocNo <> '' then
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s',[copy(ReceiptData^.Name,1,30)]));
        //DRIVER_EPSON   :  pStr := Format('%-14s',[ReceiptData^.Name]);
      end;

      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%10s%4s%26s%3s',['******', rightstr(ReceiptData^.MODocNo, 4),
                                                                      Float2Str(ReceiptData^.ExtPrice,2),
                                                                      CheckTax(ReceiptData)]));
        (*DRIVER_EPSON   :  pStr := Format('%2s',[CurrToStr(ReceiptData^.Qty)])  + ' @ ' +
                 Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', ReceiptData^.Price))]) +
                 Format('%17s',[(FormatFloat('#,###.00 ;#,###.00-', ReceiptData^.ExtPrice))]);*)
        end;
    end
    else
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s%9s%3s',[copy(ReceiptData^.Name,1,30),
                                                                   Float2Str(ReceiptData^.ExtPrice,2),
                                                                   CheckTax(ReceiptData)]));
        (*DRIVER_EPSON   :  pStr := Format('%-20s',[ReceiptData^.Name])  + '  ' +
                 Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice))]);*)
      end;
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Name:      PrintPrePayRefund
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintPrePayRefund(ReceiptData : pSalesData);
{
1234567890123456789012345678901234567890
Sale where Qty = 1
xxxxxxxxxxxxxxxxxxxx         9,999.00-
Sale where Qty > 1
xxxxxxxxxxxxxxxxxxxx
99 @ 9,999.00-               9,999.00-
}

var
DataFound : boolean;
fName : string;
lPumpNo, lHoseNo : integer;
lUnitPrice, lVolume, lAmount, lPrepayAmount : currency;
begin
  lPumpNo := 0;
  lHoseNo := 0;
  lUnitPrice := 0;
  lVolume := 0;
  lAmount := 0;
  lPrepayAmount := 0;
  fName := 'Fuel';
  if not POSDataMod.IBPrintTransaction.InTransaction then
    POSDataMod.IBPrintTransaction.StartTransaction;
  with POSDataMod.IBPrintQuery do
  begin

      Close;
      SQL.Clear;
      SQL.Add('Select * from FuelTran where SaleID = ' + InttoStr( ReceiptData^.FuelSaleID ) );
      Open;
      Datafound := False;
      while NOT EOF do
        begin
          Datafound := True;
          lHoseNo              := FieldbyName('HoseNo').AsInteger;
          lPumpNo              := FieldbyName('PumpNo').AsInteger;
          lVolume              := FieldbyName('Volume').AsCurrency;
          lAmount              := FieldbyName('Amount').AsCurrency;
          lUnitPrice           := FieldbyName('UnitPrice').AsCurrency;
          lPrePayAmount        := FieldbyName('PrePayAmount').AsCurrency;
          break;
        end;
      Close;

      if DataFound then
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT D.Name FROM PumpDef P, Grade G, Dept D ' +
         'WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And ' +
         'P.GradeNo = G.GradeNo And G.DeptNo = D.DeptNo )');
        ParamByName('pPumpNo').AsInteger := lPumpNo;
        ParamByName('pHoseNo').AsInteger := lHoseNo;
        Open;
        if NOT EOF then
          fName := FieldByName('Name').AsString;
        Close;
      end;
    end;
  if POSDataMod.IBPrintTransaction.InTransaction then
    POSDataMod.IBPrintTransaction.Commit;
  if Datafound then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s%9s',['Fuel PrePay',Float2Str(lPrePayAmount * -1,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%-14s',['Fuel PrePay'])  + '  ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', (lPrePayAmount * -1)   ))]);*)
    end;

    PrintLine(fName);
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%10s @ %10s%17s',[Float2Str(lVolume,3),
                                                                        Float2Str(lUnitPrice,3),
                                                                        Float2Str(lAmount,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-', lVolume))])
               + ' @ ' +
               Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',lUnitPrice))]) +
               Format('%10s',[(FormatFloat('#,###.00 ;#,###.00-', lAmount))]);*)
    end;

  end
  else
    PrintMdse(ReceiptData);

end;

{-----------------------------------------------------------------------------
  Name:      PrintPrePay
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintPrePay(ReceiptData : pSalesData);
{
1234567890123456789012345678901234567890
Sale where Qty = 1
xxxxxxxxxxxxxxxxxxxx         9,999.00-
Sale where Qty > 1
xxxxxxxxxxxxxxxxxxxx
99 @ 9,999.00-               9,999.00-
}
var
DataFound : boolean;
fName : string;
lPumpNo, lHoseNo : integer;
lUnitPrice, lVolume, lAmount, lPrepayAmount : currency;

begin
  lPumpNo := 0;
  lHoseNo := 0;
  lUnitPrice := 0;
  lVolume := 0;
  lAmount := 0;
  lPrepayAmount := 0;
  Datafound := False;
  fName := 'Fuel';
  if PRINT_OLD_RECEIPT then
    begin
      {lets see if they already pumped so we can print the gallons}
      if not POSDataMod.IBPrintTransaction.InTransaction then
        POSDataMod.IBPrintTransaction.StartTransaction;
      with POSDataMod.IBPrintQuery do
        begin
          Close;
          SQL.Clear;
          SQL.Add('Select * from FuelTran where (TransNo = ' + InttoStr( rcptSale.nTransNo ) +
                                                 ') and (Completed = 1) ' );
          Open;
          if NOT EOF then
            begin
              if ReceiptData^.ExtPrice = FieldbyName('PrePayAmount').AsCurrency then
                begin
                  Datafound := True;
                  lHoseNo              := FieldbyName('HoseNo').AsInteger;
                  lPumpNo              := FieldbyName('PumpNo').AsInteger;
                  lVolume              := FieldbyName('Volume').AsCurrency;
                  lAmount              := FieldbyName('Amount').AsCurrency;
                  lUnitPrice           := FieldbyName('UnitPrice').AsCurrency;
                  lPrePayAmount        := FieldbyName('PrePayAmount').AsCurrency;
                end;
            end;
          Close;
          if DataFound then
            begin
              Close;
              SQL.Clear;
              SQL.Add('SELECT D.Name FROM PumpDef P, Grade G, Dept D ' +
               'WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And ' +
               'P.GradeNo = G.GradeNo And G.DeptNo = D.DeptNo )');
              ParamByName('pPumpNo').AsInteger := lPumpNo;
              ParamByName('pHoseNo').AsInteger := lHoseNo;
              Open;
              if NOT EOF then
                fName := FieldByName('Name').AsString;
              Close;
            end;
        end;

  if POSDataMod.IBPrintTransaction.InTransaction then
    POSDataMod.IBPrintTransaction.Commit;
  end;
  if Datafound then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s%9s',['Fuel PrePay',Float2Str(lPrePayAmount * -1,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%-14s',['Fuel PrePay'])  + '  ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', (lPrePayAmount * -1)   ))]);*)
    end;

    PrintLine(fName);
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%10s @ %10s%17s',[Float2Str(lVolume,3),
                                                                        Float2Str(lUnitPrice,3),
                                                                        Float2Str(lAmount,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-', lVolume))])
               + ' @ ' +
               Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',lUnitPrice))]) +
               Format('%10s',[(FormatFloat('#,###.00 ;#,###.00-', lAmount))]);*)
    end;

    rcptSale.nSubtotal := rcptSale.nSubtotal - ( lPrePayAmount - lAmount ) ;
    rcptSale.nTotal := rcptSale.nTotal - ( lPrePayAmount - lAmount ) ;
    rcptSale.nChangeDue := rcptSale.nChangeDue + ( lPrePayAmount - lAmount ) ;

  end
  else
  begin
    if ReceiptData^.Qty > 1 then
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-20s',[ReceiptData^.Name]));
        //DRIVER_EPSON   :  pStr := Format('%-14s',[ReceiptData^.Name]);
      end;
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%2s @ %9s%26s%3s',[CurrToStr(ReceiptData^.Qty),
                                                                           Float2Str(ReceiptData^.Price,2),
                                                                           Float2Str(ReceiptData^.ExtPrice,2),
                                                                           CheckTax(ReceiptData)]));
        (*DRIVER_EPSON   :  pStr := Format('%2s',[CurrToStr(ReceiptData^.Qty)])  + ' @ ' +
                 Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.Price))]) +
                 Format('%17s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice))]);*)
      end;
    end
    else
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s%9s%3s',[copy(ReceiptData^.Name,1,30),
                                                                      Float2Str(ReceiptData^.ExtPrice,2),
                                                                      CheckTax(ReceiptData)]));
        (*DRIVER_EPSON   :  pStr := Format('%-15s',[ReceiptData^.Name])  + '         ' +
                  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', ReceiptData^.ExtPrice))]);*)
      end;
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Name:      PrintFuel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintFuel(ReceiptData : pSalesData);
{
1234567890123456789012345678901234567890
Sale where Qty = 1
xxxxxxxxxxxxxxxxxxxx         9,999.00-
Sale where Qty > 1
xxxxxxxxxxxxxxxxxxxx
99 @ 9,999.00-               9,999.00-
}
{$IFDEF ODOT_VMT}  //20061023f
var
  ReceiptDataSave : pSalesData;
{$ENDIF}
begin

  PrintLine(ReceiptData^.Name);
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%10s @ %10s%15s%3s',[Float2Str(ReceiptData^.Qty,3),
                                                                         Float2Str(ReceiptData^.Price,3),
                                                                         Float2Str(ReceiptData^.ExtPrice,2),
                                                                         CheckTax(ReceiptData)]));
    (*DRIVER_EPSON   :  pStr := Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',ReceiptData^.Qty))])
             + ' @ ' +
             Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',ReceiptData^.Price))]) +
             Format('%10s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice))]);*)
  end;

  {$IFDEF FUEL_FIRST}  //20071023a...
  if ((ReceiptData^.CCAuthID > 0) and (Trim(ReceiptData^.CCCardType) = CT_FUEL_FIRST)) then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close();
      SQL.Clear();
      SQL.Add('Select CardNo, ApprovalCode from ccAuth where AuthID = :pAuthID');
      ParamByName('pAuthID').AsInteger := ReceiptData^.CCAuthID;
      Open();
      if (RecordCount > 0) then
        PrintLine('FF#:  ' + Trim(FieldByName('CardNo').AsString) + '  A#: ' + Trim(FieldByName('ApprovalCode').AsString));
    end; // with
    if POSdataMod.IBTransaction.InTransaction then
      POSdataMod.IBTransaction.Commit;
  end;  // if (ReceiptData^.CCAuthorizer > 0)
  {$ENDIF}             //...20071023a

  {$IFDEF ODOT_VMT}

  // Check for a state tax discount (VMT transaction) on the next line
  if (ReceiptDataNextLine <> nil) then
  begin
    if (ReceiptDataNextLine.LineType = 'DSV') then
    begin
      ReceiptDataSave := ReceiptData;
      ReceiptData := ReceiptDataNextLine;
      PrintDisc();
      ReceiptData := ReceiptDataSave;
    end;
  end;

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  PrintVMTData(ReceiptData^.FuelSaleID, 0);
  if POSdataMod.IBTransaction.InTransaction then
    POSdataMod.IBTransaction.Commit;
  {$ENDIF}

end;

{-----------------------------------------------------------------------------
  Name:      PrintDisc
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintDisc(ReceiptData : pSalesData);
{
1234567890123456789012345678901234567890
Sale where Qty = 1
xxxxxxxxxxxxxxxxxxxx         9,999.00-
Sale where Qty > 1
xxxxxxxxxxxxxxxxxxxx
99 @ 9,999.00-               9,999.00-
}
var
sDiscNum : string;

begin

  {$IFDEF PDI_PROMOS}
  if ((ReceiptData^.LineType = 'DSC') and (ReceiptData^.SaleType = 'Info')) then
  begin
    PromoDisc := PromoDisc + (ReceiptData^.ExtPrice * -1)
  end
  else
  {$ENDIF}
  begin
    sDiscNum := FormatFloat('0', ReceiptData^.Number);
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-31s%9s',[copy(ReceiptData^.Name,1,30),Float2Str(ReceiptData^.ExtPrice,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%-14s',[ReceiptData^.Name])  + '  ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice))]);*)
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Name:      PrintTL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintTL(ReceiptList : TList);
{
1234567890123456789012345678901234567890
                  Subtotal   9,999.99-
                       Tax   9,999.99-
                     Total   9,999.99-
               Your Change   9,999.99-
}
var
{$IFDEF MULTI_TAX}
  j : integer;
  ReceiptData : pSalesData;
{$ENDIF}
  taxname : string;
begin

  CCused := False;
  DebitUsed := False;
  //53o...
  EBTFSUsed := False;
  EBTCBUsed := False;
  //...53o
  GiftUsed := false;
  if bUseFoodStamps then
    if rcptSale.nFSSubtotal <> 0 then
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%31s%9s',['FS Subtotal',Float2Str(rcptSale.nFSSubtotal,2)]));
        (*DRIVER_EPSON   :  pStr := Format('%19s',['FS Subtotal'])  + '   ' +
                 Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nFSSubtotal))]);*)
      end;
    end;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%31s%9s',['Subtotal',Float2Str(rcptSale.nSubtotal,2)]));
    (*DRIVER_EPSON   :  pStr := Format('%19s',['Subtotal'])  + '   ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nSubtotal))]);*)
  end;

  if rcptSale.bSalesTaxXcpt then
    taxname := 'Tax Exempt'
  else
    taxname := 'Tax';
  if (rcptSale.nTlTax <> 0) or (rcptSale.bSalesTaxXcpt) then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :
    {$IFDEF MULTI_TAX}
        for j := 0 to ReceiptList.Count - 1 do
        begin
          ReceiptData := ReceiptList.Items[j];
          if ReceiptData^.LineType = 'TAX' then
            PrintLine(Format('%31s%9s',[copy(ReceiptData^.Name,1,30),Float2Str(ReceiptData^.ExtPrice,2)]));
        end;
    end;
    {$ELSE}
        PrintLine(Format('%31s%9s',[taxname,Float2Str(rcptSale.nTlTax,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%19s',['Tax'])  + '   ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nTlTax))]);*)
    end;
    {$ENDIF}
  end;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('                    ' + PrtBold + 'Total'+ PrtMode + ' ' +
             Format('%9s',[Float2Str(rcptSale.nTotal,2)]));
    (*DRIVER_EPSON   :  pStr := '          ' + PrtBold + 'Total'+ PrtMode + '  ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nTotal))]);*)
  end;

end;


{-----------------------------------------------------------------------------
  Name:      PrintFuelTL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TLAmount : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintFuelTL(TLAmount : currency);
{
1234567890123456789012345678901234567890
                  Subtotal   9,999.99-
                       Tax   9,999.99-
                     Total   9,999.99-
               Your Change   9,999.99-
}
begin

  CCused := False;
  DebitUsed := False;
  //53o...
  EBTFSUsed := False;
  EBTCBUsed := False;
  //...53o
  GiftUsed := false;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('                  ' + PrtBold + 'Total'+ PrtMode + '   ' +
             Format('%9s',[Float2Str(TLAmount,2)]));
    (*DRIVER_EPSON   :  pStr := '          ' + PrtBold + 'Total'+ PrtMode + '  ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',TLAmount))]);*)
  end;

end;

//20071029b...
procedure PrintVisaMCBalance(const qSalesData : pSalesData);
begin
  if (qSalesData^.CCBalance1 <> UNKNOWN_BALANCE) then
  begin
    PrintLine('*******CARD BALANCE*******');
    PrintLine(Float2Str(qSalesData^.CCBalance1,2) + ' (before purchase)');
    PrintLine('**************************');
  end;
end;  // procedure PrintVisaMCBalance
//...20071029b

{-----------------------------------------------------------------------------
  Name:      PrintEBTBalance
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const qSalesData : pSalesData
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//53o...
function PrintEBTBalance(const qSalesData : pSalesData) : Boolean;
var
  BalanceValue : currency;
  BalanceDesc : string;
  AccountDesc : string;
begin
  Result := False;
  if ((qSalesData^.CCBalance1 <> UNKNOWN_BALANCE) or           // Available balance for cash benefit
      (qSalesData^.CCBalance2 <> UNKNOWN_BALANCE) or           // Available balance for food stamp
      (qSalesData^.CCBalance3 <> UNKNOWN_BALANCE) or           // Ledger balance for cash benefit
      (qSalesData^.CCBalance4 <> UNKNOWN_BALANCE) or           // Ledger balance for food stamp
      (qSalesData^.CCBalance5 <> UNKNOWN_BALANCE) or           // Beginning ledger balance for cash benefit
      (qSalesData^.CCBalance6 <> UNKNOWN_BALANCE)   ) then     // Beginning ledger balance for food stamp
  begin
    Result := True;
    BalanceValue := UNKNOWN_BALANCE;
    BalanceDesc := '';
    PrintLine('***EBT BALANCE***');
    if ((qSalesData^.CCBalance1 <> UNKNOWN_BALANCE) or           // Available balance for cash benefit
        (qSalesData^.CCBalance3 <> UNKNOWN_BALANCE) or           // Ledger balance for cash benefit
        (qSalesData^.CCBalance5 <> UNKNOWN_BALANCE)   ) then     // Beginning ledger balance for cash benefit
    begin
      AccountDesc := 'EBT CB';                            // EBT Cash Benefit
      if (qSalesData^.CCBalance1 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance1;
        BalanceDesc := 'Avail.';                       // Available balance
      end
      else if (qSalesData^.CCBalance3 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance3;
        BalanceDesc := 'Ledger';                       // Ledger balance
      end
      else if (qSalesData^.CCBalance5 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance5;
        BalanceDesc := 'Begin';                        // Beginning ledger balance
      end;
      PrintLine(Format('%-6s: %9s (%6s)',[AccountDesc, Float2Str(BalanceValue,2), BalanceDesc]));
    end;
  if ((qSalesData^.CCBalance2 <> UNKNOWN_BALANCE) or           // Available balance for food stamp
      (qSalesData^.CCBalance4 <> UNKNOWN_BALANCE) or           // Ledger balance for food stamp
      (qSalesData^.CCBalance6 <> UNKNOWN_BALANCE)   ) then     // Beginning ledger balance for food stamp
    begin
      AccountDesc := 'EBT FS';                            // EBT Food Stamp
      if (qSalesData^.CCBalance2 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance2;
        BalanceDesc := 'Avail.';                       // Available balance
      end
      else if (qSalesData^.CCBalance4 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance4;
        BalanceDesc := 'Ledger';                       // Ledger balance
      end
      else if (qSalesData^.CCBalance6 <> UNKNOWN_BALANCE) then
      begin
        BalanceValue := qSalesData^.CCBalance6;
        BalanceDesc := 'Begin';                        // Beginning ledger balance
      end;
      PrintLine(Format('%-6s: %9s (%6s)',[AccountDesc, Float2Str(BalanceValue,2), BalanceDesc]));
    end;
    PrintLine('*****************');
  end;
end;

{-----------------------------------------------------------------------------
  Name:      PrintEBTDecline
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const DeclineAmount : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintEBTDecline(const DeclineAmount : currency);
var
  j : integer;
  LenCardNo : integer;
  qSalesData : pSalesdata;
  sAccountType : string;
  tStr : string;
begin
  if      (rCRD.sCCCardType = CT_EBT_FS) then sAccountType := 'FS '
  else if (rCRD.sCCCardType = CT_EBT_CB) then sAccountType := 'CB '
  else                                   sAccountType := '';
  if (sAccountType = '') then
    Exit;                            // Was actually an ATM debit decline, so do not print a "decline" receipt.
  rcptSale.nTransNo := qClient^.CreditTransNo;
  nrcptShiftNo := nShiftNo;
  PrintLine(PrtBold + '*** EBT Decline ***' + PrtMode);
  // Print account number (configuration option to mask all but last few digits)
  tStr := rCRD.sCCCardNo;
  LenCardNo := Length(rCRD.sCCCardNo);
  if (bPANTruncationCustomerCopy) then
  begin
    for j := 1 to (LenCardNo - nPANNonTruncatedCustomerCopy) do
       tStr[j] := 'X';
  end;
  PrintLine('Account# ' + tStr);
  PrintLine(sAccountType + Format('Purchase: %9s declined',[Float2Str(DeclineAmount,2)]));

  // If any balance information returned, then print it.
  if ((rCRD.nCCBalance1 <> UNKNOWN_BALANCE) or
      (rCRD.nCCBalance2 <> UNKNOWN_BALANCE) or
      (rCRD.nCCBalance3 <> UNKNOWN_BALANCE) or
      (rCRD.nCCBalance4 <> UNKNOWN_BALANCE) or
      (rCRD.nCCBalance5 <> UNKNOWN_BALANCE) or
      (rCRD.nCCBalance6 <> UNKNOWN_BALANCE)) then
  begin
    New(qSalesData);
    ZeroMemory(qSalesData, sizeof(TSalesData));
    qSalesData^.CCBalance1 := rCRD.nCCBalance1;
    qSalesData^.CCBalance2 := rCRD.nCCBalance2;
    qSalesData^.CCBalance3 := rCRD.nCCBalance3;
    qSalesData^.CCBalance4 := rCRD.nCCBalance4;
    qSalesData^.CCBalance5 := rCRD.nCCBalance5;
    qSalesData^.CCBalance6 := rCRD.nCCBalance6;
    PrintEBTBalance(qSalesData);
    Dispose(qSalesData);
  end;
  PrintLine('Merchant ID: ' + sTerminalID);
  for j := low(rCRD.sCCPrintLine) to high(rCRD.sCCPrintLine) do
    if (trim(rCRD.sCCPrintLine[j]) <> 'DECLINED') and (trim(rCRD.sCCPrintLine[j]) <> '') then
      PrintLine(rCRD.sCCPrintLine[j]);
  PrintLine('Auth Message: ' + rCRD.sCCAuthMsg);
  PrintSeq();
end;
//...53o


procedure PrintEMVDecline(const DeclineAmount : currency);
var
  j : integer;
  LenCardNo : integer;
  qSalesData : pSalesdata;
  sAccountType : string;
  tStr : string;
begin
  UpdateZLog('PrintEMVDeclined - enter');
  rcptSale.nTransNo := qClient^.CreditTransNo;
  nrcptShiftNo := nShiftNo;
  PrintLine(PrtBold + '*** Decline ***' + PrtMode);
  // Print account number (configuration option to mask all but last few digits)
  tStr := rCRD.sCCCardNo;
  LenCardNo := Length(rCRD.sCCCardNo);
  if (bPANTruncationCustomerCopy) then
  begin
    for j := 1 to (LenCardNo - nPANNonTruncatedCustomerCopy) do
       tStr[j] := 'X';
  end;
  PrintLine('Account# ' + tStr);
  PrintLine(sAccountType + Format('Purchase: %9s declined',[Float2Str(DeclineAmount,2)]));
  PrintLine('Merchant ID: ' + sTerminalID);
  for j := low(rCRD.sCCPrintLine) to high(rCRD.sCCPrintLine) do
    if (trim(rCRD.sCCPrintLine[j]) <> 'DECLINED') and (trim(rCRD.sCCPrintLine[j]) <> '') then
      PrintLine(rCRD.sCCPrintLine[j]);
  PrintLine('Auth Message: ' + rCRD.sCCAuthMsg);
  PrintSeq();
  UpdateZLog('PrintEMVDeclined - exit');
end;


{-----------------------------------------------------------------------------
  Name:      PrintMedia
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintMedia(ReceiptData : pSalesData);
var
  MedName : string;
begin

  MedName := ReceiptData^.Name;
  if ReceiptData^.Extprice < 0 then
    begin
      MedName := MedName + ' Refund';
    end;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%31s%9s',[copy(MedName,1,30),Float2Str(ReceiptData^.ExtPrice,2)]));
    (*DRIVER_EPSON   :  pStr := Format('%19s',[MedName])  + '   ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',ReceiptData^.ExtPrice))]);*)
  end;

  if (ReceiptData^.CCAuthCode <> '') and (copy(ReceiptData^.CCAuthCode,1,1) <> ' ') then
    begin
      CCUsed := True;
      CCPtr  := ReceiptData;
      if ReceiptData^.Number = StrToInt(sDebitMediaNo) then
        DebitUsed := True;
      //53o...
      if ReceiptData^.Number = StrToInt(sEBTFSMediaNo) then
        EBTFSUsed := True;
      if ReceiptData^.Number = StrToInt(sEBTCBMediaNo) then
        EBTCBUsed := True;
      //...53o
      if ReceiptData^.Number = StrToInt(sGiftCardMediaNo) then
        GiftUsed := True;

    end;

end;


{-----------------------------------------------------------------------------
  Name:      PrintChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintChange();
{
1234567890123456789012345678901234567890
                  Subtotal   9,999.99-
                       Tax   9,999.99-
                     Total   9,999.99-
               Your Change   9,999.99-
}
begin

  if rcptSale.nChangeDue <> 0 then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('      '+ PrtBold + 'Your Change'+ PrtMode + '   ' +
               Format('%9s',[Float2Str(rcptSale.nChangeDue,2)]));
      (*DRIVER_EPSON   :  pStr := PrtBold + '    Change'+ PrtMode + '  ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nChangeDue))]);*)
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      PrintSuspend
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintSuspend();
begin
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('        '+ PrtBold+'*Suspended*'+ PrtMode );
    //DRIVER_EPSON   :  pStr := '   '+ PrtBold+'*Suspended*'+ PrtMode ;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      PrintCancel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintCancel();
begin
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('        '+ PrtBold+'*Cancelled*'+ PrtMode);
    //DRIVER_EPSON   :  pStr := '  '+ PrtBold+'*Cancelled*'+ PrtMode ;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      PrintSeq
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintSeq(ReceiptList : TList);
begin
  {$IFDEF PDI_PROMOS}
  if (((CCUsed) and (CCSecond)) or (not(CCUsed) and not(CCSecond)) or PRINT_OLD_RECEIPT) and (PromoDisc > 0) and (Not PRINTING_REPORT) then
  begin
    PrintLine('');
    PrintLine('*** You saved ' + Float2Str(PromoDisc,2) + 'on this transaction!');
    PrintLine('');
  end;
  {$ENDIF}
  CCUsed := False;

  PrintFooter;

  CheckingPrinter := True;
  if Boolean(Setup.PrintUserName) then
    PrintLine(CurrentUser);
  //SaleType
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(' R# ' + Format('%1d',[fmPOS.ThisTerminalNo]) +
             ' S# ' + Format('%1d',[nrcptShiftNo]) + ' T# '
                    + Format('%6.6d',[rcptSale.nTransNo]) + ' '
                    + FormatDateTime('h:mm AM/PM',Time) + ' '
                    + FormatDateTime('mm/dd/yy',Date));
    (*DRIVER_EPSON   :  pStr := 'R#' + Format('%1d',[fmPOS.ThisTerminalNo]) +
             ' S#' + Format('%1d',[rcptSale.nShiftNo]) + ' T#'
                    + Format('%6.6d',[rcptSale.nTransNo]) + ' '
                    + FormatDateTime('h:mm AM/PM',Time)
                    + FormatDateTime('mm/dd/yy',Date);*)
  end;

  if ReceiptList <> nil then
    PrintPINReceiptText(@(ReceiptList));

  FeedReceipt;

  { flag so that we dont chop up the shift and day end reports }
  //Gift
  if (bGiftCardReceiptInfoFollows) then
    begin
    end
  else
  //Gift
  if PRINTING_REPORT then
    begin
      if LAST_REPORT then
        CutReceipt;
    end
  else
    CutReceipt;

  PrintHeader;

  if bReceiptActive = DRIVER_DIRECT then
    FeedReceipt;

end;


{-----------------------------------------------------------------------------
  Name:      PrintHeader
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintHeader();
var
  tStr : string;
  i : integer;
begin
  for i := 1 to 4 do
  begin
    if Setup.RcptHeader[i] > ' ' then
    begin
      if Boolean(Setup.RcptHBold[i]) then
        tStr := PrtBold
      else
        tStr := '';
      tStr := tStr + TrimRight(Setup.RcptHeader[i]);
      if Boolean(Setup.RcptHBold[i]) then
        tStr := tStr + PrtMode ;
      PrintLine(tStr);
    end;
  end;
  bPrinterOK := True;
end;

{-----------------------------------------------------------------------------
  Name:      PrintFooter
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintFooter();
var
  tStr : String;
  i : integer;
begin
  for i := 1 to 2 do
  begin
    if Setup.RcptFooter[i] > ' ' then
    begin
      if Boolean(Setup.RcptFBold[i]) then
        tstr := PrtBold
      else
        tstr := '';
      tstr := tstr + TrimRight(Setup.RcptFooter[i]);
      if Boolean(Setup.RcptFBold[i]) then
        tstr := tstr + PrtMode ;
      printLine(tStr);
    end;
  end;
end;

function GetSignature(const AuthId : integer) : WideString;
begin
  with POSDataMod.Cursors['SIG-GET'] do
  begin
    Transaction.StartTransaction();
    ParamByName('pAuthId').AsInteger := AuthId;
    ExecQuery;
    if Eof then
      Result := ''
    else
      Result := FieldByName('signaturedata').AsString;
    close();
    Transaction.commit();
  end;
end;

{-----------------------------------------------------------------------------
  Name:      PrintCCMess
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintCCMess(ReceiptData : pSalesData);
var
  tStr : array[0..30] of char;
  tmpStr : string;
  n : short;
  x : short;
  j : integer;
  r : TJclStrStrHashMap;
  s, t : string;
  //bpc...
  EndTruncate : short;
  //...bpc
  SigData : WideString;

  
  function GetPrintableCCMess(aValue : String) : String;
  var
     rSult : String;
  begin
     rSult := Copy(aValue,2,length(aValue) - 1);
     Result := rSult;
  end;
begin
  UpdateZLog('Inside PrintCCMess : local');
  PrintLine('');

  ccPtr^.CCCardNo := Trim(ccPtr^.CCCardNo);
  StrPCopy(tStr, ccPtr^.CCCardNo);
  if (PAN or
      (bPANTruncationStoreCopy    and (not CCSecond)) or
      (bPANTruncationCustomerCopy and      CCSecond )    ) then
    begin
      x := Length(trim(CCPtr^.CCCardNo));
      if (CCSecond) then EndTruncate := x - nPANNonTruncatedCustomerCopy - 1
                    else EndTruncate := x - nPANNonTruncatedStoreCopy - 1;
      for n := 0 to EndTruncate do
        tStr[n] := 'X';
    end;


  if CCSecond then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-2.2s',[CCPtr^.CCEntryType]) +
               Format('%-13s',[trim(CCPtr^.CCCardType)]) +
               Format('%-20s',[tStr]));
      (*DRIVER_EPSON   :  pStr := Format('%-2.2s',[CCPtr^.CCEntryType]) +
               Format('%-13s',[trim(CCPtr^.CCCardType)]) +
               Format('%-14s',[tStr]);*)
    end;
  end
  else
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%-2.2s',[CCPtr^.CCEntryType]) +
               Format('%-13s',[trim(CCPtr^.CCCardType)]) +
               Format('%-20s',[tStr])
               {$IFNDEF CISP_CODE}  //20070108b
               + Format('%5s',[CCPtr^.CCExpDate])
               {$ENDIF}
               );
      (*DRIVER_EPSON   :  pStr := Format('%-2.2s',[CCPtr^.CCEntryType]) +
               Format('%-13s',[trim(CCPtr^.CCCardType)]) +
               Format('%-14s',[tStr]) +
               Format('%5s',[CCPtr^.CCExpDate]) ;*)
    end;
  end;


  //53o...
//  if NOT CCSecond and NOT DebitUsed and NOT GiftUsed then
  SigData := GetSignature(CCPtr^.CCAuthId);
  if NOT CCSecond and NOT DebitUsed and NOT EBTFSUsed and NOT EBTCBUsed and NOT GiftUsed then
  //...53o
    begin
      for n := 1 to 4 do
        if Setup.CreditMess[n] > ' ' then
          PrintLine(TrimRight(Setup.CreditMess[n]));
      PrintLine('');
      PrintLine('');
      //Gift
      if (CCPtr^.CCCardType <> CT_GIFT) and (CCPtr^.CCCardType <> CT_EBT_FS) and (CCPtr^.CCCardType <> CT_EBT_CB) then
      begin
        if not DebitUsed then
        begin
          if SigData <> '' then
            AddLine(PRT_SIGING3BA, SigData)
          else
          begin
            PrintLine('Signature_______________________________');
            PrintLine(Format('AuthID: %d',[CCPtr^.CCAuthId]));
          end;
        end;
      end;
      //Build 18
    end;

  if (not bSignatureRequired and (SigData = '')) then
    PrintLine('No Signature Required');

  //PrintLine(CCPtr^.CCCardName);

  if CCSecond then
  begin
    if SigData <> '' then
      AddLine(PRT_SIGING3BA, SigData);
  end;

//  'Auth#00 bbsss In tttt    Approval nnnnnn'

  PrintLine(Format('AuthID %2s %8d In %6s Approval %s',
                   [CCPtr^.CCAuthCode, CCPtr^.CCAuthId, CCPtr^.CCTime, CCPtr^.CCApprovalCode]));
  

  if (CCPtr^.CCCPSData <> '') and (CCPtr^.CCCPSData <> 'None') then
    PrintLine('CPS ' + CCPtr^.CCCPSData);

  tmpStr := '';
  if length(CCPtr^.CCVehicleNo) > 0 then
    if (CCPtr^.CCCardType = CT_EBT_FS) then tmpStr := '  Voucher# ' + CCPtr^.CCVehicleNo;

  if length(CCPtr^.CCOdometer) > 0 then
    tmpStr := tmpStr + '  Odometer ' + CCPtr^.CCOdometer;

  if Length(tmpStr) > 0 then
    PrintLine(tmpStr);

  if length(CCPtr^.CCAuthorizer) > 0 then
    PrintLine('AuthorizerID: ' + CCPtr^.CCAuthorizer);

  if CCPtr^.CCTraceAuditNo <> '' then
    PrintLine('TA# ' + CCPtr^.CCTraceAuditNo + ' Net '  + CCPtr^.CCAuthNetID);

  if ((nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_LYNK]) or
      (ReceiptData^.CCCardType = CT_EBT_FS) or (ReceiptData^.CCCardType = CT_EBT_CB)) then
    PrintLine('Merchant ID: ' + sTerminalID);
  for j := low(ReceiptData^.CCPrintLine) to high(ReceiptData^.CCPrintLine) do
    if (ReceiptData^.CCPrintLine[j] <> '') then
      PrintLine(ReceiptData^.CCPrintLine[j]);
  if ReceiptData^.emvauthconf <> '' then
  begin
    r := ExtractINGTags(ReceiptData^.emvauthconf);
    try
      if r.ContainsKey(EMV_APN) then
      begin
        s := r.GetValue(EMV_APN);
        if s[1] = 'h' then
          t := unhexifystring(copy(s,2,length(s)-1))
        else
          t := copy(s,2,length(s)-1);
        PrintLine('APN: ' + t);
      end;
      if r.ContainsKey(TRANS_DATA_SOURCE ) then 
      begin
         PrintLine('Trans Data Souce : ' + GetPrintableCCMess(r.GetValue(TRANS_DATA_SOURCE )));
      end;

      if r.ContainsKey(PIN_ENTRY_VERIFIED ) then // might also have to look for TVR as well
      begin
         if (GetPrintableCCMess(r.GetValue(PIN_ENTRY_VERIFIED )) = '1') then
            PrintLine('PIN Verified');
      end;
      if r.ContainsKey(EMV_AL ) then PrintLine('AL : ' + GetPrintableCCMess(r.GetValue(EMV_AL )));
      if r.ContainsKey(EMV_AID) then PrintLine('AID: ' + GetPrintableCCMess(r.GetValue(EMV_AID)));
      if r.ContainsKey(EMV_TVR) then PrintLine('TVR: ' + GetPrintableCCMess(r.GetValue(EMV_TVR)));
      if r.ContainsKey(EMV_TSI) then PrintLine('TSI: ' + GetPrintableCCMess(r.GetValue(EMV_TSI)));
      if r.ContainsKey(EMV_TC ) then PrintLine('TC : ' + GetPrintableCCMess(r.GetValue(EMV_TC )));
      if r.ContainsKey(EMV_IAD) then PrintLine('IAD: ' + GetPrintableCCMess(r.GetValue(EMV_IAD)));
      if r.ContainsKey(EMV_ARC) then PrintLine('ARC: ' + GetPrintableCCMess(r.GetValue(EMV_ARC)));
      if r.ContainsKey(EMV_TRANSACTION_TYPE) then
      begin
         if (GetPrintableCCMess(r.GetValue(EMV_ARC)) = '00') then
         begin
            PrintLine('Transaction Type : Sale');          
         end
         else
         begin
            PrintLine('Transaction Type : Refund');          
         end; 
      end;
     
    finally
      r.Free;
    end;
  end;

  //if ((nCreditAuthType = CDTSRV_BUYPASS) and (ReceiptData^.CCAuthorizer <> CC_AUTHORIZER_UNKNOWN)) then
  //  begin
  //    pStr := 'Authorizer Code: ' + IntToStr(ReceiptData^.CCAuthorizer);
  //    PrintReceipt;
  //  end;

  //20060707c...
  if (nCreditAuthType = CDTSRV_BUYPASS) then
  begin
    try
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close();
      SQL.Clear();
      SQL.Add('Select FullName from ccCardTypes where CardType = :pCardType');
      ParamByName('pCardType').AsString := Trim(ReceiptData^.CCCardType);
      Open();
      if (RecordCount = 1) then
        PrintLine('Card Type: ' + FieldByName('FullName').AsString);
      Close();
    end;  // with POSDataMod.IBTempQuery
    if POSdataMod.IBTransaction.InTransaction then
      POSdataMod.IBTransaction.Commit;
    except
      if POSdataMod.IBTransaction.InTransaction then
        POSdataMod.IBTransaction.Rollback;
    end;
  end;
  //...20060707c

  if      (ReceiptData^.CCRequestType = RT_CAT_AUTH)         then PrintLine(PRT_RT_CAT_AUTH)
  else if (ReceiptData^.CCRequestType = RT_CAT_CAPTURE)      then PrintLine(PRT_RT_CAT_CAPTURE)
  else if (ReceiptData^.CCRequestType = RT_POS_AUTH)         then PrintLine(PRT_RT_POS_AUTH)
  else if (ReceiptData^.CCRequestType = RT_POS_CAPTURE)      then PrintLine(PRT_RT_POS_CAPTURE)
  else if (ReceiptData^.CCRequestType = RT_POS_AUTH_CAPTURE) then PrintLine(PRT_RT_POS_AUTH_CAPTURE)
  else if (ReceiptData^.CCRequestType = RT_RETURN)           then PrintLine(PRT_RT_RETURN)
  else if (ReceiptData^.CCRequestType = RT_AUTH_VOID)        then PrintLine(PRT_RT_AUTH_VOID)
  else if (ReceiptData^.CCRequestType = RT_PURCHASE_REVERSE) then PrintLine(PRT_RT_PURCHASE_REVERSE);

  if ((NOT CCSecond) and (NOT PRINT_OLD_RECEIPT)) then
    if (nCreditAuthType = CDTSRV_BUYPASS) then
      PrintLine(PrtBold + '** Merchant Copy **' + PrtMode)
    else
      PrintLine(PrtBold + '*** Store Copy ***' + PrtMode)
  else if (nCreditAuthType = CDTSRV_BUYPASS) then
    PrintLine(PrtBold + '** Customer Copy **' + PrtMode);

end;






{-----------------------------------------------------------------------------
  Name:      CutReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CutReceipt;
var
TryCount : integer;

begin

  if bCutReceipt then
    begin
      for TryCount := 1 to 5 do
        begin
          try
            case bReceiptActive of
            DRIVER_DIRECT :
              begin
                fmPOS.DCOMPrinter.AddLine(PRT_CUTRECEIPT, '' );
              end;
            DRIVER_OPOS :
              begin
                fmPOS.DCOMPrinter.AddLine(PRT_CUTRECEIPT, '' );
              end;
            end;
            break;
          except
            on E: Exception do
              begin
                fmPOS.ReconnectPrinter('Cut Receipt ', e.message, TryCount);
              end;
          end;
        end;
    end;


end;


{-----------------------------------------------------------------------------
  Name:      FeedReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure FeedReceipt();
var
TryCount : integer;
begin
  for TryCount := 1 to 5 do
    begin
      try
        case bReceiptActive of
        DRIVER_DIRECT :
          begin
            fmPOS.DCOMPrinter.AddLine(PRT_FEEDRECEIPT, '' );
          end;
        DRIVER_OPOS :
          begin
            fmPOS.DCOMPrinter.AddLine(PRT_FEEDRECEIPT, '' );
          end;
        end;
        break;
      except
        on E: Exception do
          begin
            fmPOS.ReconnectPrinter('Feed Receipt ', e.message, TryCount);
          end;
      end;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      PausePrint
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PausePrint();
var
TryCount : integer;
begin
  if bReceiptActive > 0 then  //20060531b
  begin
    for TryCount := 1 to 5 do
    begin
      try
        fmPOS.DCOMPrinter.AddLine(PRT_PAUSEPRINT, '' );
        fmPOS.PrintPaused := true;
        break;
      except
        on E: Exception do
          begin
            fmPOS.ReconnectPrinter('Pause Receipt ', e.message, TryCount);
          end;
      end;
    end;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      ResumePrint
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure ResumePrint();
var
TryCount : integer;
begin
  if bReceiptActive > 0 then  //20060531b
  begin
    for TryCount := 1 to 5 do
    begin
      try
        fmPOS.DCOMPrinter.AddLine(PRT_STARTPRINT, '' );
        fmPOS.PrintPaused := false;
        break;
      except
        on E: Exception do
        begin
          fmPOS.ReconnectPrinter('Start Receipt ', e.message, TryCount);
        end;
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      OpenDrawer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure OpenDrawer();
var
TryCount : integer;
begin

  if bReceiptActive > 0 then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        fmPOS.DCOMPrinter.OpenDrawer;
        break;
      except
        on E: Exception do
          begin
            fmPOS.ReconnectPrinter('Open Drawer ', e.message, TryCount);
          end;
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      CloseDrawer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CloseDrawer();
var
  i : integer;
begin
  if bReceiptActive > 0 then
  begin
    for i := 1 to 1000 do
    begin
      Application.ProcessMessages;
      try
        if fmPOS.DCOMPrinter.DrawerOpened then
        begin
          if fmPOSMsg.Visible = False then
            fmPOSMsg.ShowMsg('Please Close The Cash Drawer !', '');
          sleep(500);
        end
        else
          break;
      except
        on E: Exception do
        begin
          fmPOS.ReconnectPrinter('Close Drawer ', e.message, i);
          if fmPOSMsg.Visible = True then
            fmPOSMsg.Close;
          break;
        end;
      end;
    end;
  end;
  if fmPOSMsg.Visible = True then
    fmPOSMsg.Close;
end;


{-----------------------------------------------------------------------------
  Name:      PrintReprint
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure PrintReprint;
var
  OrigTimestamp : TDateTime;  //20070618a
Begin
  case bReceiptActive of
  DRIVER_DIRECT : PrintLine(PrtEOL + '    '+ PrtBold + '*** REPRINT ***' + PrtMode + PrtEOL);
  DRIVER_OPOS :   PrintLine(PrtEOL + '    '+ PrtBold + '*** REPRINT ***' + PrtMode + PrtEOL);
  (*DRIVER_EPSON :
      begin
        pStr := PrtEOL + ' ' + PrtBold + '*** REPRINT ***' + PrtEOL;
      end;*)
  end;

  //20070618a...
  OrigTimestamp := 0;
  try
    if not POSDataMod.IBTempTrans1.InTransaction then  //20070713b (change IBTransaction to IBTempTrans1)
      POSDataMod.IBTempTrans1.StartTransaction;
    with POSDataMod.IBTempQry1 do                     //20071023b (change IBTempQuery to IBTempQry1)
    begin
      Close();
      SQL.Clear();
      SQL.Add('SELECT MAX(TimeStmp) as OrigTimeStamp FROM POSLog Where LogNo = :pLogNo');
      ParamByName('pLogNo').AsInteger := rcptSale.nTransNo;
      Open();
      if (not EOF) then
        OrigTimestamp := FieldByName('OrigTimeStamp').AsDateTime;
      Close();
    end;
    if POSDataMod.IBTempTrans1.InTransaction then      //20070713b (change IBTransaction to IBTempTrans1)
      POSDataMod.IBTempTrans1.Commit;
  except
    OrigTimestamp := 0;
    if POSdataMod.IBTempTrans1.InTransaction then      //20071023b
      POSdataMod.IBTempTrans1.Rollback;                //20071023b
  end;
  if (OrigTimestamp > 0) then
    PrintLine('Original Transaction: ' + FormatDateTime('mmm dd, yyyy h:mm AM/PM', OrigTimestamp));


End;

{-----------------------------------------------------------------------------
  Name:      PrintReversal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
//bp...
procedure PrintReversal();
begin
  case bReceiptActive of
    1 : PrintLine(PrtEOL + '    '+ PrtBold + '*** REVERSAL ***' + PrtEOL);
    2 : PrintLine(PrtEOL + '    '+ PrtBold + '*** REVERSAL ***' + PrtMode + PrtEOL);
  end;
end;
//...bp

{-----------------------------------------------------------------------------
  Name:      ReturnASCIIString
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: S : String
  Result:    String
  Purpose:   
-----------------------------------------------------------------------------}
Function ReturnASCIIString( S : String ) : String;
Var
  MyRes : Array [0..20] of char;
  Buf   : String;
  i     : Integer;
  Pos   : Byte;

Begin

 Pos := 0;
 MyRes := '';
 Buf   := '';

 For i:= 2 to Length(S) do
  Begin
    If s[i] <> '#' Then
        Buf := Buf + s[i]
    Else
     Begin
       MyRes[Pos] := Chr(StrtoInt(Buf));
       Inc(Pos);
       Buf := '';
     End;
  End;
  MyRes[pos]:= Chr(StrtoInt(Buf));
  Result := strpas (Myres);

End;

{-----------------------------------------------------------------------------
  Name:      LoadPrinterSettings
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LoadPrinterSettings;

Var
  CharStr         : Array [0..20] of Char;
  ExePath         : Array[0..79] of Char;
  PStr            : PChar;
Begin

  PStr := CharStr;

  If not(Fileexists(ExtractFileDir(Application.ExeName) + '\POSPrint.ini')) Then
   Begin
     fmPOS.POSError('POSPrint.ini not found, using Defaults !');
     Exit;
   End;

  StrPCopy(ExePath, ExtractFileDir(Application.ExeName) + '\POSPrint.ini');

  GetPrivateProfileString('Settings','PrtBold', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtBold := ReturnASCIIString(StrPas (PStr));

  GetPrivateProfileString('Settings','PrtMode', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtMode := ReturnASCIIString(StrPas (PStr));

  GetPrivateProfileString('Settings','PrtEOL', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtEOL := ReturnASCIIString(StrPas (PStr));

  GetPrivateProfileString('Settings','PrtCut', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtCut := ReturnASCIIString(StrPas (PStr));

  GetPrivateProfileString('Settings','PrtFeed', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtFeed := ReturnASCIIString(StrPas (PStr));

  GetPrivateProfileString('Settings','PrtOpenDrawer', '' ,PStr, 20, ExePath);
  If (StrPas (PStr)) <> '' Then
    PrtOpenDrawer := ReturnASCIIString(StrPas (PStr));

End;

procedure PrintGiftRestrictionCodeDescription(const RestrictionCode : integer);
begin
  if (RestrictionCode in [Low(GIFT_CARD_RESTRICTION_DESC)..High(GIFT_CARD_RESTRICTION_DESC)]) then
    PrintLine(GIFT_CARD_RESTRICTION_DESC[RestrictionCode])
  else
    PrintLine('Gift Restriction:  ' + InttoStr(RestrictionCode));
end;

{-----------------------------------------------------------------------------
  Name:      PrintGiftCardBalance
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const qGiftCardList : pTList
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//20060626...
//procedure PrintGiftCardBalance(const qGiftCardList : pTList);
procedure PrintGiftCardBalance(const qGiftCardList : pTList; const Header1 : string; const Header2 : string);
//...20060626
const
  NUM_UNMASKED_DIGITS = 4;
var
  j : integer;
  j2 : integer;
  gd : pGiftCardData;
  DeltaBalance : currency;
  MaskedCardNo : array [ 0..SIZE_CARDNO - 1] of char;
  LastMaskedIndex : integer;
  LastDigitIndex : integer;
begin
  bGiftCardReceiptInfoFollows := False;
  if (qGiftCardList^.Count <= 0) then exit;                     // The list is empty.

//  PrintLine('**** Gift Card Information ****');
  if (Header1 <> '') then
    PrintLine(Header1);
  if (Header2 <> '') then
    PrintLine(Header2);
  if (nCreditAuthType = CDTSRV_BUYPASS) then
    PrintLine('Merchant ID: ' + sTerminalID);

  for j := 0 to qGiftCardList^.Count - 1 do
    begin
      gd := qGiftCardList^.Items[j];
      LastDigitIndex := StrLen(gd^.CardNo) - 1;
      if (LastDigitIndex > NUM_UNMASKED_DIGITS) then
      begin
        LastMaskedIndex := LastDigitIndex - NUM_UNMASKED_DIGITS;
        for j2 := 0                   to LastMaskedIndex do MaskedCardNo[j2] := '*';
        for j2 := LastMaskedIndex + 1 to LastDigitIndex  do MaskedCardNo[j2] := gd^.CardNo[j2];
        MaskedCardNo[LastDigitIndex + 1] := char(0);
        PrintLine(format('Card Number:  %*s', [SIZE_CARDNO, MaskedCardNo]));
      end
      else
        PrintLine('Card Number:  Not specified');

      if (gd^.CardStatus = CS_UNKNOWN) then
        PrintLine('Status of card is unknown.')
      else if (gd^.CardStatus = CS_INACTIVE) then
        PrintLine('Status of card is inactive.')
      else // i.e., information should be available on card balances.
      begin
        if (gd^.PriorValue <> UNKNOWN_BALANCE) then
          PrintLine(format('Beginning Balance:  $%6.2f', [gd^.PriorValue]))
        else if ((gd^.CardStatus = CS_JUST_ACTIVATED) or (gd^.CardStatus = CS_JUST_RECHARGED)) then
           PrintLine(      'Beginning Balance:  (New card)')
        else
           PrintLine(      'Beginning Balance:  UNKNOWN');

        DeltaBalance := gd^.FaceValue - gd^.PriorValue;
        if ((gd^.FaceValue <> UNKNOWN_BALANCE) and (gd^.PriorValue <> UNKNOWN_BALANCE)) then
        begin
          if (DeltaBalance < 0) then
            PrintLine(format('Total Sale       :  $%6.2f', [-DeltaBalance]))
          else if (DeltaBalance > 0) then
            PrintLine(format('Total Credit     :  $%6.2f', [ DeltaBalance]))
          else
            PrintLine('Balance Inquiry Only');

          if ((DeltaBalance <> 0) or (gd^.PriorValue = UNKNOWN_BALANCE)) then
            if (gd^.FaceValue <> UNKNOWN_BALANCE) then
              PrintLine(format('Ending Balance   :  $%6.2f', [gd^.FaceValue]))
            else
              PrintLine(       'Ending Balance   :  UNKNOWN');

          PrintGiftRestrictionCodeDescription(gd^.RestrictionCode);
        end;
      if (nCreditAuthType = CDTSRV_BUYPASS) then
        PrintLine('Approval: ' + gd^.HostApprovalCode);
    end;
  end;
  PrintSeq();
  // Clear out list.
  if qGiftCardList^.Count > 0 then
    for j := 0 to qGiftCardList^.Count - 1 do
      begin
        gd := qGiftCardList^.Items[j];
        dispose(gd);
        qGiftCardList^.Items[j] := nil;
      end;
  qGiftCardList^.Clear();
  qGiftCardList^.Capacity := qGiftCardList^.Count;

end;  // procedure PrintGiftCardBalance
//Gift
//bp...

{-----------------------------------------------------------------------------
  Name:      PrintCardTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const q : pHostTotals
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintCardTotals(const q : pHostTotals);
begin
  //53f...(change all calls to PrintReceipt() to LineOut(pStr)
  //20071004b...
//  pStr := '*** Host Totals Information ***';
  LineOut('Totals Timestamp:');
  LineOut(FormatDateTime('mmm dd, yyyy h:mm AM/PM', q^.CreateDate));
  //53d...
//  if (     fmPOS.CardTotalsDateCode = ''                             ) then pStr := 'Local settlement' // DATE_CODE_LOCAL
  if (     fmPOS.CardTotalsDateCode = DATE_CODE_LOCAL                ) then LineOut('Local settlement')
  //...53d
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_NON_SETTLE_NON_CLEAR ) then LineOut('Non-settlement - not reset')
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_SETTLE_CLEAR         ) then LineOut('Settlement - reset')
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_MOST_RECENT_DAY      ) then LineOut('Most recent date')
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_2ND_MOST_RECENT_DAY  ) then LineOut('2nd most recent date')
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_3RD_MOST_RECENT_DAY  ) then LineOut('3rd most recent date')
  else if (fmPOS.CardTotalsDateCode = DATE_CODE_NON_SETTLE_CLEAR     ) then LineOut('Non-settlement - reset')
  else                                                                      LineOut('Date code = ' + fmPOS.CardTotalsDateCode);
  LineOut('Grand Total' + Format('      %9s',[(Float2Str(q^.GrandTotal,2))]));
  LineOut('Fee Amount ' + Format('      %9s',[(Float2Str(q^.FeeAmount,2))]));
  LineOut('Net Amount ' + Format('      %9s',[(Float2Str(q^.NetAmount,2))]));

  if (nCreditAuthType = CDTSRV_BUYPASS) then
  begin

    LineOut('-----------------------------------------');
    LineOut('TYPE COUNT   AMOUNT');
    LineOut('-----------------------------------------');
    LineOut('CC    ' + Format('%4d  %9s',[q^.CCCount,  (Float2Str(q^.CCAmount ,2))]));
    LineOut('TE    ' + Format('%4d  %9s',[q^.TECount,  (Float2Str(q^.TEAmount ,2))]));
    LineOut('DS    ' + Format('%4d  %9s',[q^.DSCount,  (Float2Str(q^.DSAmount ,2))]));
    LineOut('AO    ' + Format('%4d  %9s',[q^.AOCount,  (Float2Str(q^.AOAmount ,2))]));
    LineOut('DB    ' + Format('%4d  %9s',[q^.DBCount,  (Float2Str(q^.DBAmount ,2))]));
    LineOut('FL    ' + Format('%4d  %9s',[q^.FLCount,  (Float2Str(q^.FLAmount ,2))]));
    LineOut('CS    ' + Format('%4d  %9s',[q^.CSCount,  (Float2Str(q^.CSAmount ,2))]));
    LineOut('PR    ' + Format('%4d  %9s',[q^.PRCount,  (Float2Str(q^.PRAmount ,2))]));
    LineOut('CK    ' + Format('%4d  %9s',[q^.CKCount,  (Float2Str(q^.CKAmount ,2))]));
    LineOut('EF    ' + Format('%4d  %9s',[q^.EFCount,  (Float2Str(q^.EFAmount ,2))]));
    LineOut('EC    ' + Format('%4d  %9s',[q^.ECCount,  (Float2Str(q^.ECAmount ,2))]));
    LineOut('SV1   ' + Format('%4d  %9s',[q^.SV1Count, (Float2Str(q^.SV1Amount,2))]));
    LineOut('SV2   ' + Format('%4d  %9s',[q^.SV2Count, (Float2Str(q^.SV2Amount,2))]));
    LineOut('SV3   ' + Format('%4d  %9s',[q^.SV3Count, (Float2Str(q^.SV3Amount,2))]));
    LineOut('SV4   ' + Format('%4d  %9s',[q^.SV4Count, (Float2Str(q^.SV4Amount,2))]));


  end  // if BUYPASS
  else if (nCreditAuthType = CDTSRV_FIFTH_THIRD) then
  begin

    LineOut('-----------------------------------------');
    LineOut('TYPE COUNT   AMOUNT    REFCNT REFUND AMT');
    LineOut('-----------------------------------------');
    LineOut(Format('CC    %4d  %9s  %4d  %9s',[q^.CCCount,  (Float2Str(q^.CCAmount,2 )),q^.CCRefCnt,  (Float2Str(q^.CCRefund,2 ))]));
    LineOut(Format('DS    %4d  %9s  %4d  %9s',[q^.DSCount,  (Float2Str(q^.DSAmount,2 )),q^.DSRefCnt,  (Float2Str(q^.DSRefund,2 ))]));
    LineOut(Format('VM    %4d  %9s  %4d  %9s',[q^.VMCount,  (Float2Str(q^.VMAmount,2 )),q^.VMRefCnt,  (Float2Str(q^.VMRefund,2 ))]));
    LineOut(Format('DB    %4d  %9s  %4d  %9s',[q^.DBCount,  (Float2Str(q^.DBAmount,2 )),q^.DBRefCnt,  (Float2Str(q^.DBRefund,2 ))]));
    LineOut(Format('PR    %4d  %9s  %4d  %9s',[q^.PRCount,  (Float2Str(q^.PRAmount,2 )),q^.PRRefCnt,  (Float2Str(q^.PRRefund,2 ))]));
    LineOut(Format('EF    %4d  %9s  %4d  %9s',[q^.EFCount,  (Float2Str(q^.EFAmount,2 )),q^.EFRefCnt,  (Float2Str(q^.EFRefund,2 ))]));
    LineOut(Format('EC    %4d  %9s  %4d  %9s',[q^.ECCount,  (Float2Str(q^.ECAmount,2 )),q^.ECRefCnt,  (Float2Str(q^.ECRefund,2 ))]));
    LineOut(Format('CS    %4d  %9s',[q^.CSCount,  (Float2Str(q^.CSAmount,2 ))]));
    LineOut(Format('CK    %4d  %9s',[q^.CKCount,  (Float2Str(q^.CKAmount,2 ))]));
    if (fmPOS.CardTotalsDateCode = DATE_CODE_LOCAL) then   // if local totals
      LineOut(Format('LOCAL %4d  %9s',[q^.OLCount,  (Float2Str(q^.OLAmount,2 ))]));
  end; // if Fifth Third

  {$IFNDEF HUCKS_REPORTS}  //20071107d...
  // Adjust where reports cut at request of Huck's Data Analysts
  PrintSeq();
  {$ENDIF}                //...20071107d
end;  // procedure PrintCardTotals                  *)
//...bp

procedure PrintReceiptNoXMD(ReceiptList : TList);
var
  i , Med1 : integer;
  CarwashAccessCode : string;
  CarwashExpDate : string;
  MediaCardType : string;
  ReceiptData : pSalesData;
begin
  Med1 := 1;
  for i := 0 to ReceiptList.Count-1 do
  Begin
    ReceiptData := ReceiptList.Items[i];
    if ReceiptData^.LineType = 'MED' Then
    begin
      Med1 := i;
      break;
    end
    else
    Begin
      if NOT bPrintVoids then
      begin
        if (ReceiptData^.LineVoided = True) or (ReceiptData^.SaleType = 'Void') then
          continue;
      end;
      if ReceiptData^.LineType = 'DPT' then
        PrintMdse(ReceiptData)
      else if ReceiptData^.LineType = 'PLU' then
        PrintMdse(ReceiptData)
      else if ReceiptData^.LineType = 'BNK' then
        PrintMdse(ReceiptData)
      else if ReceiptData^.LineType = 'PPY' then     { Prepay }
        PrintPrepay(ReceiptData)
      else if ReceiptData^.LineType = 'PRF' then     { Prepay Refund }
        PrintPrePayRefund(ReceiptData)
      else if ReceiptData^.LineType = 'FUL' then
      begin
        {$IFDEF ODOT_VMT}  //20061023f
        if (i < ReceiptList.Count - 1) then
          ReceiptDataNextLine := ReceiptList.Items[i + 1]   //Used to check for fuel discounts on next line
        else
          ReceiptDataNextLine := nil;
        {$ENDIF}
        PrintFuel(ReceiptData);
      end
      else if ReceiptData^.LineType = 'DSC' then
        PrintDisc(ReceiptData)
      else if ReceiptData^.LineType = 'MXM' then
        PrintDisc(ReceiptData)
      //XMD
      else if (ReceiptData^.LineType = 'XMD') and (ReceiptData^.Name = 'Fuel Discount') then
        PrintDisc(ReceiptData)
      //XMD
      {$IFDEF CASH_FUEL_DISC}
      else if ReceiptData^.LineType = 'DS$' then
         PrintDisc(ReceiptData)
      {$ENDIF}
      //20061023f...  (Logic moved to PrintFuel())
//      {$IFDEF ODOT_VMT}
//      else if ReceiptData^.LineType = 'DSV' then
//         PrintDisc
//      {$ENDIF}
      //...20061023f
      //DSG
      else if ReceiptData^.LineType = 'DSG' then
         PrintDisc(ReceiptData);
      //DSG
    End;

     { We have to prevent a Buffer overflow with too many receiptlines... }

  End;

  PrintTl(ReceiptList);

  for i:= Med1 to ReceiptList.Count-1 do
  begin
    ReceiptData := ReceiptList.Items[i];
    if ReceiptData^.LineType = 'MED' Then
    begin
      if ReceiptData^.Name = 'Credit Card' then
      begin
        CCUsed := true;
        GiftUsed := false;
        PrintMedia(ReceiptData);
        PrintVisaMCBalance(ReceiptData);  //20071029b
        PrintCCMess(ReceiptData);
      end
      else if ReceiptData^.Name = 'Gift Card' then
      begin
        GiftUsed := true;
        CCUsed := true;
        PrintMedia(ReceiptData);
        PrintCCMess(ReceiptData);
      end
      else
        PrintMedia(ReceiptData);
      MediaCardType := Trim(ReceiptData^.CCCardType);
      if ((MediaCardType = CT_EBT_FS) or (MediaCardType = CT_EBT_CB)) then
      begin
        PrintEBTBalance(ReceiptData);
        PrintCCMess(ReceiptData);
      end;
    end;
  end;
  PrintChange;
  // Print access code for any carwash purchases
  for i := 0 to ReceiptList.Count-1 do
  begin
    ReceiptData := ReceiptList.Items[i];
    CarwashAccessCode := fmPOS.GetCarwashAccessCode(ReceiptData);
    if (CarwashAccessCode <> '') then
      begin
        PrintLine('Carwash Access Code: ' + PrtBold + CarwashAccessCode + Prtmode);
        CarwashExpDate := fmPOS.GetCarwashExpDate(ReceiptData);
        if (CarwashExpDate <> '') then
          PrintLine('Valid Through: ' + CarwashExpDate);
      end;
  end;
  PrintSeq(ReceiptList);
End;

//Mega Suspend
procedure PrintBill;
var
  i : Byte;
  ReceiptData : pSalesData;
begin
  if fmPos.CurSaleList.Count > 0 then
  begin
    for i := 0 to fmPos.CurSaleList.Count-1 do
    Begin
      ReceiptData := fmPos.CurSaleList.Items[i];

      Begin
        if NOT bPrintVoids then
        begin
          if (ReceiptData^.LineVoided = True) or (ReceiptData^.SaleType = 'Void') then
            continue;
        end;
        if ReceiptData^.LineType = 'DPT' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'PLU' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'BNK' then
          PrintMdse(ReceiptData)
        else if ReceiptData^.LineType = 'PPY' then     { Prepay }
          PrintPrepay(ReceiptData)
        else if ReceiptData^.LineType = 'PRF' then     { Prepay Refund }
          PrintPrePayRefund(ReceiptData)
        else if ReceiptData^.LineType = 'FUL' then
        begin
          {$IFDEF ODOT_VMT}  //20061023f
          if (i < ReceiptList.Count - 1) then
            ReceiptDataNextLine := ReceiptList.Items[i + 1]   //Used to check for fuel discounts on next line
          else
            ReceiptDataNextLine := nil;
          {$ENDIF}
          PrintFuel(ReceiptData);
        end
        else if ReceiptData^.LineType = 'DSC' then
          PrintDisc(ReceiptData)
        else if ReceiptData^.LineType = 'MXM' then
          PrintDisc(ReceiptData)
        //XMD
        else if (ReceiptData^.LineType = 'XMD') and (ReceiptData^.Name = 'Fuel Discount') then
          PrintDisc(ReceiptData);
        //XMD
      End;

       { We have to prevent a Buffer overflow with too many receiptlines... }

    End;

    PrintBillTl;

    PrintSeq;
  end;
end;

procedure PrintBillTL();
{
1234567890123456789012345678901234567890
                  Subtotal   9,999.99-
                       Tax   9,999.99-
                     Total   9,999.99-
               Your Change   9,999.99-
}
{$IFDEF MULTI_TAX}
var
  j, j2 : integer;
  ST : pSalesTax;
  CurSaleData : pSalesData;
  ReceiptData : pSalesData;
{$ENDIF}
begin

  CCused := False;
  DebitUsed := False;
  //53o...
  EBTFSUsed := False;
  EBTCBUsed := False;
  //...53o
  GiftUsed := false;
  if bUseFoodStamps then
    if rcptSale.nFSSubtotal <> 0 then
    begin
      case bReceiptActive of
        DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%26s%3s%9s',['FS Subtotal','',Float2Str(rcptSale.nFSSubtotal,2)]));
        (*DRIVER_EPSON   :  pStr := Format('%19s',['FS Subtotal'])  + '   ' +
                 Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nFSSubtotal))]);*)
      end;
    end;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine(Format('%26s%3s%9s',['Subtotal','',Float2Str(rcptSale.nSubtotal,2)]));
    (*DRIVER_EPSON   :  pStr := Format('%19s',['Subtotal'])  + '   ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nSubtotal))]);*)
  end;

  if rcptSale.nTlTax <> 0 then
  begin
    case bReceiptActive of
      DRIVER_DIRECT, DRIVER_OPOS :
    {$IFDEF MULTI_TAX}
      begin                      //Add Tax Lines to Current Sales List for Bill Print
        for j := 1 to fmPOS.CurSalesTaxList.Count - 1 do
        begin
          ST := fmPOS.CurSalesTaxList.Items[j];
          if ST^.Taxable <> 0 then
          begin
            New(CurSaleData);
            ZeroMemory(CurSaleData, sizeof(TSalesData));
            CurSaleData^.SeqNumber   := fmPOS.CurSaleList.Count + 1;
            CurSaleData^.LineType    := 'TAX';    {DPT, PLU, MED}
            CurSaleData^.SaleType    := '';       {Sale, Void, Rtrn, VdVd, VdRt}
            CurSaleData^.Number      := 0;
            CurSaleData^.Name        := ST^.TaxName ;
            CurSaleData^.Qty         := 0;
            CurSaleData^.Price       := 0;
            CurSaleData^.ExtPrice    := ST^.TaxCharged;

            CurSaleData^.TaxNo   := 0;   // Init Tax Stuff
            CurSaleData^.TaxRate := 0;
            CurSaleData^.Taxable := 0;

            CurSaleData^.WEXCode := 0;
            CurSaleData^.PHHCode := 0;
            CurSaleData^.IAESCode := 0;
            CurSaleData^.VoyagerCode := 0;

            CurSaleData^.SavDiscable := 0;
            CurSaleData^.SavDiscAmount := 0;
            CurSaleData^.PumpNo := 0;
            CurSaleData^.HoseNo := 0;
            CurSaleData^.Discable := False;
            CurSaleData^.FUELSALEID := 0;
            CurSaleData^.LineVoided     := False;
            CurSaleData^.CCAuthCode     := '';
            CurSaleData^.CCApprovalCode := '';
            CurSaleData^.CCDate         := '';
            CurSaleData^.CCTime         := '';
            CurSaleData^.CCCardNo       := '';
            CurSaleData^.CCCardType     := '';
            CurSaleData^.CCCardName     := '';
            CurSaleData^.CCExpDate      := '';
            CurSaleData^.CCBatchNo      := '';
            CurSaleData^.CCSeqNo        := '';
            CurSaleData^.CCEntryType    := '';
            CurSaleData^.CCVehicleNo    := '';
            CurSaleData^.CCOdometer     := '';
            CurSaleData^.CCCPSData      := '';
            CurSaleData^.CCRetrievalRef := '';
            CurSaleData^.CCAuthNetId    := '';
            CurSaleData^.CCTraceAuditNo := '';
            CurSaleData^.GiftCardRestrictionCode := RC_NO_RESTRICTION;
            for j2 := low(CurSaleData^.CCPrintLine) to high(CurSaleData^.CCPrintLine) do
              CurSaleData^.CCPrintLine[j2]  := '';
            CurSaleData^.CCBalance1    := 0;
            CurSaleData^.CCBalance2    := 0;
            CurSaleData^.CCBalance3    := 0;
            CurSaleData^.CCBalance4    := 0;
            CurSaleData^.CCBalance5    := 0;
            CurSaleData^.CCBalance6    := 0;
            CurSaleData^.CCRequestType := 0;
            CurSaleData^.ActivationState := asActivationDoesNotApply;
            CurSaleData^.ActivationTransNo := 0;
            CurSaleData^.ActivationTimeout := 0;
            CurSaleData^.LineID := fmPos.GetLineID();
            CurSaleData^.ccPIN := '';
            fmPOS.CurSaleList.Capacity := fmPOS.CurSaleList.Count;
            fmPOS.CurSaleList.Add(CurSaleData);
          end;  // if ST^.Taxable <> 0
        end;  // for j := 1 to CurSalesTaxList.Count - 1
        for j := 1 to fmPOS.CurSaleList.Count - 1 do
        begin                             //Print Tax Lines
          ReceiptData := fmPOS.CurSaleList.Items[j];
          if ReceiptData^.LineType = 'TAX' then
            PrintLine(Format('%26s%3s%9s',[ReceiptData^.Name,'', Float2Str(ReceiptData^.ExtPrice,2)]));
        end;
        j := 1;
        while j < fmPOS.CurSaleList.Count do     //Remove Tax Lines from Current Sale List
        begin
          ReceiptData := fmPOS.CurSaleList.Items[j];
          if ReceiptData^.LineType = 'TAX' then
          begin
            fmPOS.CurSaleList.Delete(j);
            if j <= fmPOS.CurSaleList.Count-1 then
              for j2 := j to fmPOS.CurSaleList.Count - 1 do
              begin
                CurSaleData := fmPOS.CurSaleList.Items[j2];
                Dec(CurSaleData^.SeqNumber);
              end;
          end
          else
            Inc(j);
        end;  // while j < CurSaleList.Count
      end;  // DRIVER_DIRECT, DRIVER_OPOS
    end;  // case
    {$ELSE}
        PrintLine(Format('%26s%3s%9s',['Tax','', Float2Str(rcptSale.nTlTax,2)]));
      (*DRIVER_EPSON   :  pStr := Format('%19s',['Tax'])  + '   ' +
               Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nTlTax))]);*)
    end;  // case
    {$ENDIF}
  end;
  case bReceiptActive of
    DRIVER_DIRECT, DRIVER_OPOS :  PrintLine('        ' + PrtBold + 'Total Due'+ PrtMode + '   ' +
             Format('%9s',[Float2Str(rcptSale.nTotal,2)]));
    (*DRIVER_EPSON   :  pStr := '      ' + PrtBold + 'Total Due'+ PrtMode + '  ' +
             Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',rcptSale.nTotal))]);*)
  end;

end;
//Mega Suspend

{$IFDEF ODOT_VMT}
procedure PrintVMTData(const FuelSaleID : integer; const CreditAuthID : integer);
{
  Print any VMT sales data (located fuel transaction from FuelSaleID if provided;
  otherwise search based on CreditAuthID).

  Caller is responsible for the DB transaction.
}
const
  MAX_VMT_RECEIPT_LINES = 6;
  VMTLineDelimiter = '~';
var
//  VMTFee : currency;
  VMTReceiptData : string;
  VMTReceiptDataRemaining : string;
  idxStartLine : integer;
  idxEndLine : integer;
  lenVMTReceiptData : integer;
  lenRemaining : integer;
  lenThisLine : integer;
  j : integer;
begin
  if ((FuelSaleID > 0) or (CreditAuthID > 0)) then
  begin
    with POSDataMod.IBTempQuery do
    begin
      Close();
      SQL.Clear();
      if (FuelSaleID > 0) then
      begin
        SQL.Add('Select VMTReceiptData from FuelTran where SaleID = :pSaleID');
        ParamByName('pSaleID').AsInteger       := FuelSaleID;
      end
      else
      begin
        SQL.Add('Select VMTReceiptData from FuelTran where AuthID = :pAuthID');
        ParamByName('pAuthID').AsInteger       := CreditAuthID;
      end;
      Open();
      if (RecordCount > 0) then
      begin
        VMTReceiptData := FieldByName('VMTReceiptData').AsString;
        lenVMTReceiptData := Length(VMTReceiptData);
        idxStartLine := 1;
        for j := 1 to MAX_VMT_RECEIPT_LINES do
        begin
          if idxStartLine > lenVMTReceiptData then
            break;
          lenRemaining := lenVMTReceiptData - idxStartLine + 1;
          VMTReceiptDataRemaining := Copy(VMTReceiptData, idxStartLine, lenRemaining);
          idxEndLine := POS(VMTLineDelimiter ,VMTReceiptDataRemaining);
          if (idxEndLine > 0) then lenThisLine := idxEndLine - 1
          else                     lenThisLine := lenRemaining;
          PrintLine(Copy(VMTReceiptDataRemaining, 1, lenThisLine));
          Inc(idxStartLine, lenThisLine + 1);
        end;  // for
      end;  // if (RecordCount > 0)
    end; // with
  end;  // if (qSalesData^.FuelSaleID > 0)
end;  // procedure PrintVMTData
{$ENDIF}

{$IFDEF FF_PROMO}
procedure PrintFuelFirstCoupon(const CreditAuthID : integer;
                               const bPrintCoupon : boolean;
                               var CouponCount : integer);
{
  Print any Fuel First coupon data.
}
const
  MAX_FF_COUPON_RECEIPT_LINES = 20;
//20080128a  FFCouponLineDelimiter = '~';
var
  CouponUPC : string;  //20080207b
  CouponValue : currency;  //20080207b
  CouponReceiptData : string;
  CouponReceiptDataRemaining : string;
  idxStartLine : integer;
  idxEndLine : integer;
  lenCouponReceiptData : integer;
  lenRemaining : integer;
  lenThisLine : integer;
  CouponCode : string;
  j : integer;
begin
  CouponCode := '';   // initial assumption
  CouponCount := 0;  // initial assumption
  if (CreditAuthID > 0) then
  begin
    try
      if (not POSDataMod.IBTransaction.InTransaction) then
        POSDataMod.IBTransaction.StartTransaction();
      with POSDataMod.IBTempQuery do
      begin

        // First see if there is a promotion for this transaction (based on ff authorization).

        Close();
        SQL.Clear();
        //20080128a...
//        SQL.Add('Select CouponCode from XMDCouponActivity where TransactionNo = :pTransactionNo');
//        SQL.Add(' and TransType = :pTransType and Posted = 0');
//        ParamByName('pTransactionNo').AsInteger       := CreditAuthID;
//        ParamByName('pTransType').AsInteger           := COUPON_TYPE_FUEL_FIRST;
        SQL.Add('Select CouponCode from FFAwardActivity where CouponAuthID = :pCouponAuthID');
        SQL.Add(' and CouponTransType = :pCouponTransType and CouponPosted = 0');
        ParamByName('pCouponAuthID').AsInteger        := CreditAuthID;
        ParamByName('pCouponTransType').AsInteger     := COUPON_TYPE_FUEL_FIRST;
        //...20080128a
        Open();
        CouponCount := RecordCount;
        if (RecordCount > 0) then
        begin
          try
            CouponCode := FieldByName('CouponCode').AsString;
          except
            CouponCode := '';
            UpdateExceptLog('PrintFuelFirstCoupon - Cannot extract CouponCode for AuthID: ' + IntToStr(CreditAuthID));
          end;
        end;
        Close();

        // Call may only be to check for existence of promotion (without printing receipt).

        if (not bPrintCoupon) then
          exit;

        // If a promo code is located, then locate template for promotion
        // (the template record contains data to print on the receipt).

        if (CouponCode <> '') then
        begin

          SQL.Clear();
          //20080128a...
//          SQL.Add('Select PromoData from XMDCouponActivity where CouponCode = :pCouponCode');
//          SQL.Add(' and TransType = :pTransType');
//          ParamByName('pCouponCode').AsString            := CouponCode;
//          ParamByName('pTransType').AsInteger           := COUPON_TYPE_FF_TEMPLATE;
          SQL.Add('Select * from FFAwardDefinition where CouponCode = :pCouponCode'); //20080207b (Changed CouponReceiptData to *)
          SQL.Add(' and CouponType = :pCouponType and CouponActive = 1');
          ParamByName('pCouponCode').AsString            := CouponCode;
          ParamByName('pCouponType').AsInteger           := COUPON_TYPE_FF_TEMPLATE;
          //...20080128a
          Open();
          if (RecordCount > 0) then
          begin
            //20080207b...
            try
              CouponValue := FieldByName('CouponValue').AsCurrency;
            except
              UpdateExceptLog('PrintFuelFirstCoupon - Cannot extrace coupon value for AuthID: ' + IntToStr(CreditAuthID));
              CouponValue := 0.0;
            end;
            CouponUPC := Trim(FieldByName('CouponUPC').AsString);
            for j := 1 to 3 do
              PrintLine('');
            PrintLine(' ******* Fuel First Award *******');
            //...20080207b
            CouponReceiptData := FieldByName('CouponReceiptData').AsString;  //20080128a   PromoData changed to CouponReceiptData
            lenCouponReceiptData := Length(CouponReceiptData);
            idxStartLine := 1;
            for j := 1 to MAX_FF_COUPON_RECEIPT_LINES do
            begin
              if idxStartLine > lenCouponReceiptData then
                break;
              lenRemaining := lenCouponReceiptData - idxStartLine + 1;
              CouponReceiptDataRemaining := Copy(CouponReceiptData, idxStartLine, lenRemaining);
              idxEndLine := POS(FF_NEW_LINE_DELIMITER ,CouponReceiptDataRemaining);  //20080128a (first arg. was FFCouponLineDelimiter)
              if (idxEndLine > 0) then
                lenThisLine := idxEndLine - 1
              else
                lenThisLine := lenRemaining;
              PrintLine(Copy(CouponReceiptDataRemaining, 1, lenThisLine));
              Inc(idxStartLine, lenThisLine + 1);
            end;  // for
            //20080207b...
            if (CouponValue > 0.0) then
              PrintLine(Format(' Award Value:  %9s',[Float2Str(CouponValue,2)]));
            //...20080207b
            if (CouponUPC <> '') then
            begin
              for j := 1 to 7 do
                PrintLine('');
              try
                fmPos.DCOMPrinter.AddLine(PRT_BARCODE,CouponUPC);
              except
                UpdateExceptLog('PrintFuelFirstCoupon - Cannot print coupon barcode: "' + CouponUPC +
                                        '" - AuthID: ' + IntToStr(CreditAuthID));
              end;
              for j := 1 to 7 do
                PrintLine('');
            end;
            //20080207b...
            //  Printer must be reset to restore logo bitmap
            for j := 5 downto 0 do
            begin
              fmPOSMsg.ShowMsg('Wait for Printer: ' + IntToStr(j) + ' Sec.', '');
              sleep(1000);  // Allow time to print above
            end;
            fmPOSMsg.Close();
            fmPos.ReConnectPrinter('PrintFuelFirstCoupon', ' Award barcode printed', 1);
            //...20080207b
            PrintSeq();
          end;  // if (RecordCount > 0)

          // Mark coupon as being printed.

          Close();
          SQL.Clear();
          //20080128a...
//          SQL.Add('Update XMDCouponActivity set Posted = 1');
//          SQL.Add(' where TransactionNo = :pTransactionNo and TransType = :pTransType');
//          ParamByName('pTransactionNo').AsInteger       := CreditAuthID;
//          ParamByName('pTransType').AsInteger           := COUPON_TYPE_FUEL_FIRST;
          SQL.Add('Update FFAwardActivity set CouponPosted = 1');
          SQL.Add(' where CouponAuthID = :pCouponAuthID and CouponTransType = :pCouponTransType');
          ParamByName('pCouponAuthID').AsInteger       := CreditAuthID;
          ParamByName('pCouponTransType').AsInteger    := COUPON_TYPE_FUEL_FIRST;
          //...20080128a
          try
            ExecSQL;
          except
            UpdateExceptLog('PrintFuelFirstCoupon - Cannot Post coupon for AuthID: ' + IntToStr(CreditAuthID));
          end;

        end;  // if (CouponCode <> '')

      end; // with
      if (POSDataMod.IBTransaction.InTransaction) then
        POSDataMod.IBTransaction.Commit();
    except
      on E : Exception do
      begin
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Rollback;
        UpdateExceptLog('PrintFuelFirstCoupon - Rollback - ' + e.message);
      end;
    end;  // try / except
  end;  // if (CreditAuthID > 0)
end;  // procedure PrintFuelFirstCoupon
{$ENDIF}



end.


{-----------------------------------------------------------------------------
 Unit Name: Receipt
 Author:    Gary Whetton
 Date:      4/13/2004 4:20:17 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit Receipt;

interface

  {$I ConditionalCompileSymbols.txt}

Uses
  Windows, SysUtils, Dialogs, Classes, CardActivation {$IFDEF CISP_CODE}, Encrypt {$ENDIF};

type                                                                                                   //20070525b
  TReceiptSearchDirection = (mReceiptDirectionNone, mReceiptDirectionBack, mReceiptDirectionForward);  //20070525b

Procedure SaveSale(const PostSaleList : TList);
Procedure SaveSaleToText(const PostSaleList : TList);
//20070525b...
//Function  LoadReceipt(TransNo : Integer) : Boolean;
Function  LoadReceipt(var TransNo : Integer; const ReceiptDirection : TReceiptSearchDirection) : Boolean;
//...20070525b
procedure WriteDataLog(DataLogText : string);
{$IFDEF DAX_SUPPORT}
procedure SendSalesMsg(const PostSaleList : TList);
procedure SavePLUSales(const PostSaleList : TList);  //20071128c
{$ENDIF}

Var
  NRecFSSubtotal : Currency;
  NRecSubTotal : Currency;
  NRecTlTax    : Currency;
  NRecTotal    : Currency;
  bRecTaxXcpt  : boolean;
  nRecChangeDue: Currency;

implementation

Uses POSMain, POSDM, ExceptLog, JclHashMapsCustom,
  {$IFDEF DAX_SUPPORT}
  MSMQ_Tlb, StrUtils, Variants,
  {$ENDIF}
  POSMisc,
  LatTypes,
  POSErr;

{$IFDEF DAX_SUPPORT}
var
  TransactionDisp : MSMQTransactionDispenser;
{$ENDIF}


{-----------------------------------------------------------------------------
  Name:      LoadReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: TransNo : Integer
  Result:    Boolean
  Purpose:
-----------------------------------------------------------------------------}
//20070525b...
//Function LoadReceipt(TransNo : Integer) : Boolean;
function LoadReceipt(var TransNo : Integer; const ReceiptDirection : TReceiptSearchDirection) : Boolean;
//...20070525b
Var
  j      : Integer;
  MySale    : PSalesData;
  Datafound : Boolean;

begin
  if not POSDataMod.IBReceiptTransaction.InTransaction then
    POSDataMod.IBReceiptTransaction.StartTransaction;
  with POSDataMod.IBReceiptQuery do
    begin
      Close;
      SQL.Clear;
      //20070525b...
//      SQL.Add('Select * from Receipt where TransactionNo = ' + InttoStr(TransNo) + ' order by SeqNumber');
      SQL.Add('Select * from Receipt where TransactionNo =');
      if (ReceiptDirection = mReceiptDirectionBack) then
        SQL.Add(' (select max(TransactionNo) from Receipt where TransactionNo <= :pTransactionNo)')
      else if (ReceiptDirection = mReceiptDirectionForward) then
        SQL.Add(' (select min(TransactionNo) from Receipt where TransactionNo >= :pTransactionNo)')
      else  // assume mDirectionNone
        SQL.Add(' :pTransactionNo');
      SQL.Add(' order by SeqNumber');
      ParamByName('pTransactionNo').AsInteger := TransNo;
      //...20070525b
      Open;

     { We delete the old list }
      DisposeTListItems(fmPOS.CurSaleList);
      bRecTaxXcpt := False;
      fmPos.CurSaleList.Clear;
      Datafound := False;
      while not EOF do
        begin
          TransNo := FieldbyName('TransactionNo').AsInteger;  //20070525b
          Datafound := True;
          New(Mysale);
          ZeroMemory(Mysale, sizeof(TSalesData));
          MySale^.SeqNumber          := FieldbyName('SeqNumber').AsInteger;
          MySale^.LineType           := FieldbyName('LineType').AsString;
          MySale^.SaleType           := FieldbyName('SaleType').AsString;
          MySale^.Number             := FieldbyName('SaleNo').AsCurrency;
          MySale^.Name               := FieldbyName('SaleName').AsString;
          MySale^.Qty                := FieldbyName('Qty').AsCurrency;
          MySale^.Price              := FieldbyName('Price').AsCurrency;
          MySale^.ExtPrice           := FieldbyName('ExtPrice').AsCurrency;
          MySale^.SavDiscable        := FieldbyName('SavDiscable').AsCurrency;
          MySale^.SavDiscAmount      := FieldbyName('SavDiscAmount').AsCurrency;
          MySale^.PumpNo             := FieldbyName('PumpNo').AsInteger;
          MySale^.HoseNo             := FieldbyName('HoseNo').AsInteger;
          MySale^.FuelSaleID         := FieldbyName('FuelSaleID').AsInteger;
          MySale^.TaxNo              := FieldbyName('TaxNo').AsInteger;
          if MySale^.TaxNo < 0 then
          begin
            bRecTaxXcpt                := True;
            MySale^.TaxNo := abs(MySale^.TaxNo);
          end;
          MySale^.TaxRate            := FieldbyName('TaxRate').AsCurrency;
          MySale^.Taxable            := FieldbyName('Taxable').AsCurrency;
          MySale^.Discable           := Boolean(FieldbyName('Disc').AsInteger);
          MySale^.Linevoided         := Boolean(FieldbyName('Linevoided').AsInteger);
          NRecFSSubtotal             := FieldbyName('FSSubtotal').AsCurrency;
          NRecSubTotal               := FieldbyName('SubTotal').AsCurrency;
          NRecTlTax                  := FieldbyName('TlTotal').AsCurrency;
          NRecTotal                  := FieldbyName('Total').AsCurrency;
          NRecChangeDue              := FieldbyName('ChangeDue').AsCurrency;
          MySale^.WEXCode            := FieldbyName('WEXCode').AsInteger   ;
          MySale^.PHHCode            := FieldbyName('PHHCode').AsInteger   ;
          MySale^.IAESCode           := FieldbyName('IAESCode').AsInteger  ;
          MySale^.VoyagerCode        := FieldbyName('VoyagerCode').AsInteger;
          MySale^.CCAuthCode         := FieldbyName('CCAuthCode').AsString     ;
          MySale^.CCApprovalCode     := FieldbyName('CCApprovalCode').AsString ;
          MySale^.CCDate             := FieldbyName('CCDate').AsString         ;
          MySale^.CCTime             := FieldbyName('CCTime').AsString         ;
          {$IFDEF CISP_CODE}
          if (fmPOS.UseCISPEncryption(Setup.CreditAuthType)) then
          begin
            // Note:  Field for ccCardNo is to short to encrypt.  Once field is widened, it can be encrypted.
            {$IFDEF CISP_WIDE_FIELDS}                                      //20060924a
            MySale^.CCCardNo           := DecryptString(FieldbyName('CCCardNo').AsString);
            {$ELSE}
            MySale^.CCCardNo           := FieldbyName('CCCardNo').AsString;
            {$ENDIF}
            MySale^.CCCardName         := DecryptString(FieldbyName('CCCardName').AsString);
            MySale^.CCExpDate          := DecryptString(FieldbyName('CCExpDate').AsString);
          end
          else
          {$ENDIF}
          begin
            MySale^.CCCardNo           := FieldbyName('CCCardNo').AsString       ;
            MySale^.CCCardName         := FieldbyName('CCCardName').AsString     ;
            MySale^.CCExpDate          := FieldbyName('CCExpDate').AsString      ;
          end;
          MySale^.CCCardType         := FieldbyName('CCCardType').AsString     ;
          MySale^.CCBatchNo          := FieldbyName('CCBatchNo').AsString      ;
          MySale^.CCSeqNo            := FieldbyName('CCSeqNo').AsString        ;
          MySale^.CCEntryType        := FieldbyName('CCEntryType').AsString        ;
          MySale^.CCVehicleNo        := Trim(FieldbyName('CCVehicleNo').AsString);  //20060906c (added trim)
          MySale^.CCOdometer         := Trim(FieldbyName('CCOdometer').AsString);   //20060906c (added trim)
          //bp...
          for j := low(MySale^.CCPrintLine) to high(MySale^.CCPrintLine) do
            MySale^.CCPrintLine[j]   := FieldbyName('CCPrintLine' + IntToStr(j)).AsString        ;
          //lya...
          //53o...
//          MySale^.CCPrintLine4       := {FieldbyName('CCPrintLine4').AsString } ''      ; //(todo) - once added to DB
//          MySale^.CCBalance1         := {FieldbyName('CCBalance1').AsCurrency } 0.0      ; //(todo) - once added to DB
//          MySale^.CCBalance2         := {FieldbyName('CCBalance2').AsCurrency } 0.0      ; //(todo) - once added to DB
          MySale^.CCBalance1         := FieldbyName('CCBalance1').AsCurrency;
          MySale^.CCBalance2         := FieldbyName('CCBalance2').AsCurrency;
          MySale^.CCBalance3         := FieldbyName('CCBalance3').AsCurrency;
          MySale^.CCBalance4         := FieldbyName('CCBalance4').AsCurrency;
          MySale^.CCBalance5         := FieldbyName('CCBalance5').AsCurrency;
          MySale^.CCBalance6         := FieldbyName('CCBalance6').AsCurrency;
          //...53o
          //...lya
          //(todo - verify) - when field is added to DB
          try
            MySale^.CCRequestType      := FieldByName('CCRequestType').AsInteger      ;
          except
            MySale^.CCRequestType := RT_UNKNOWN;
          end;
          try
            MySale^.CCAuthId       := FieldByName('CCAuthID').AsInteger      ;
          except
            MySale^.CCAuthId       := -1;
          end;
          MySale^.CCAuthorizer := FieldByName('CCAuthorizer').AsString;
          //...bp
          MySale^.MODocNo            := FieldbyName('MODocNo').AsString;
          try
            MySale^.ActivationState := TActivationState(FieldByName('ActivationState').AsInteger);
          except
            MySale^.ActivationState := asActivationDoesNotApply;
          end;
          MySale^.ActivationTransNo := FieldByName('ActivationTransNo').AsInteger;
          MySale^.ActivationTimeout := FieldByName('ActivationTimeout').AsDateTime;
          MySale^.LineID := FieldByName('LineID').AsInteger;
          MySale^.ccPIN := FieldByName('CCPIN').AsString;
          MySale^.emvauthconf := FieldByName('EMVAuthConf').AsString;
          fmPos.CurSaleList.Add(MySale);
          Next;
        End;
      Close;
    End;
  Result := Datafound;
  if POSDataMod.IBReceiptTransaction.InTransaction then
    POSDataMod.IBReceiptTransaction.Commit;
End;

{-----------------------------------------------------------------------------
  Name:      SaveSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
Procedure SaveSale(const PostSaleList : TList);
Var
  i, j      : Integer;
  MySale    : PSalesData;
  {$IFDEF CISP_CODE}
  StringToEncrypt : string;
  {$ENDIF}
  rcur : TIBSQLBuilder;
begin
  rcur := POSDataMod.RecieptCur;
  if not rcur.Transaction.InTransaction then
    rcur.StartTransaction;
  with rcur['RCPT-Insert'] do
  begin
    { We save the Saleslist to the Receipt Table for later reuse }
    try
      for i := 0 to (PostSaleList.Count - 1) do
      begin
        MySale := PostSaleList.Items[i];
        {$IFDEF DEV_TEST}
        try
          if not assigned(fmEncryption) then
            fmEncryption := TfmEncryption.Create(fmPOS);
          StringToEncrypt := MySale^.Name;
          StringToEncrypt := EncryptString(StringToEncrypt);
          StringToEncrypt := DecryptString(StringToEncrypt);
        except
        end;
        {$ENDIF}

        ParamByName('pTransactionNo').AsInteger    := pstSale.nTransNo;
        ParamByName('pSeqNumber').AsInteger        := MySale^.SeqNumber;
        ParamByName('pLineType').AsString          := MySale^.LineType;
        ParamByName('pSaleType').AsString          := MySale^.SaleType;
        ParamByName('pSaleNo').AsCurrency             := MySale^.Number;
        ParamByName('pSaleName').AsString          := Copy(MySale^.Name, 1, 30);
        ParamByName('pQty').AsCurrency             := MySale^.Qty;
        ParamByName('pPrice').AsCurrency           := MySale^.Price;
        ParamByName('pExtPrice').AsCurrency        := MySale^.ExtPrice;
        ParamByName('pSavDiscable').AsCurrency     := MySale^.SavDiscable;
        ParamByName('pSavDiscAmount').AsCurrency   := MySale^.SavDiscAmount;
        ParamByName('pPumpNo').AsInteger           := MySale^.PumpNo;
        ParamByName('pHoseNo').AsInteger           := MySale^.HoseNo;
        ParamByName('pFuelSaleID').AsInteger       := MySale^.FuelSaleID;

        if pstSale.bSalesTaxXcpt then
          ParamByName('pTaxNo').AsInteger            := -MySale^.TaxNo        // negative means tax exempt
        else
          ParamByName('pTaxNo').AsInteger            := MySale^.TaxNo;
        ParamByName('pTaxRate').AsCurrency         := MySale^.TaxRate;
        ParamByName('pTaxable').AsCurrency         := MySale^.Taxable;
        ParamByName('pDisc').AsInteger             := Integer(MySale^.Discable);
        ParamByName('pLinevoided').AsInteger       := Integer(MySale^.LineVoided);

        ParamByName('pFSSubtotal').AsCurrency      := pstSale.nFSSubtotal;
        ParamByName('pSubTotal').AsCurrency        := pstSale.nSubTotal;
        ParamByName('pTlTotal').AsCurrency         := pstSale.nTlTax;
        ParamByName('pTotal').AsCurrency           := pstSale.nTotal;
        ParamByName('pChangeDue').AsCurrency       := pstSale.nChangeDue;

        ParamByName('pWEXCode').AsInteger          := MySale^.WEXCode;
        ParamByName('pPHHCode').AsInteger          := MySale^.PHHCode;
        ParamByName('pIAESCode').AsInteger         := MySale^.IAESCode;
        ParamByName('pVoyagerCode').AsInteger      := MySale^.VoyagerCode;

        ParamByName('pCCAuthCode').AsString        := MySale^.CCAuthCode;
        ParamByName('pCCApprovalCode').AsString    := MySale^.CCApprovalCode;
        ParamByName('pCCDate').AsString            := MySale^.CCDate;
        ParamByName('pCCTime').AsString            := MySale^.CCTime;
        {$IFDEF CISP_CODE}
        if (fmPOS.UseCISPEncryption(Setup.CreditAuthType)) then
        begin
          // Note:  Field for ccCardNo is to short to encrypt.  Once field is widened, it can be encrypted.
          {$IFDEF CISP_WIDE_FIELDS}                                      //20060924a
          StringToEncrypt := MySale^.CCCardNo;
          ParamByName('pCCCardNo').AsString          := EncryptString(Copy(StringToEncrypt, 1, MAX_DB_LEN_RECEIPT_CCCARD_NO));
          StringToEncrypt := MySale^.CCCardName;
          ParamByName('pCCCardName').AsString        := EncryptString(Copy(StringToEncrypt, 1, MAX_DB_LEN_RECEIPT_CC_CARD_NAME));
          StringToEncrypt := MySale^.CCExpDate;
          ParamByName('pCCExpDate').AsString         := EncryptString(Copy(StringToEncrypt, 1, MAX_DB_LEN_EXP_DATE));
          {$ELSE}
          ParamByName('pCCCardNo').AsString          := MySale^.CCCardNo;
          StringToEncrypt := MySale^.CCCardName;
          ParamByName('pCCCardName').AsString        := EncryptString(Copy(StringToEncrypt, 1, MAX_XX_LEN_RECEIPT_CC_CARD_NAME));
          StringToEncrypt := MySale^.CCExpDate;
          ParamByName('pCCExpDate').AsString         := EncryptString(Copy(StringToEncrypt, 1, MAX_XX_LEN_EXP_DATE));
          {$ENDIF}
        end
        else
          {$ENDIF}
        begin
          ParamByName('pCCCardNo').AsString          := MySale^.CCCardNo;
          ParamByName('pCCCardName').AsString        := MySale^.CCCardName;
          ParamByName('pCCExpDate').AsString         := MySale^.CCExpDate;
        end;
        ParamByName('pCCCardType').AsString        := MySale^.CCCardType;
        ParamByName('pCCBatchNo').AsString         := MySale^.CCBatchNo;
        ParamByName('pCCSeqNo').AsString           := MySale^.CCSeqNo;
        ParamByName('pCCEntryType').AsString       := MySale^.CCEntryType;
        ParamByName('pCCVehicleNo').AsString       := MySale^.CCVehicleNo;
        ParamByName('pCCOdometer').AsString        := MySale^.CCOdometer;

        for j := low(MySale^.CCPrintLine) to high(MySale^.CCPrintLine) do
          ParamByName('pCCPrintLine' + IntToStr(j)).AsString      := MySale^.CCPrintLine[j];

        ParamByName('pCCBalance1').AsCurrency      := MySale^.CCBalance1;
        ParamByName('pCCBalance2').AsCurrency      := MySale^.CCBalance2;
        ParamByName('pCCBalance3').AsCurrency      := MySale^.CCBalance3;
        ParamByName('pCCBalance4').AsCurrency      := MySale^.CCBalance4;
        ParamByName('pCCBalance5').AsCurrency      := MySale^.CCBalance5;
        ParamByName('pCCBalance6').AsCurrency      := MySale^.CCBalance6;

        ParamByName('pActivationState').AsInteger    := Integer(MySale^.ActivationState);
        ParamByName('pActivationTransNo').AsInteger  := MySale^.ActivationTransNo;
        ParamByName('pActivationTimeout').AsDateTime := MySale^.ActivationTimeout;
        ParamByName('pLineID').AsInteger             := MySale^.LineID;
        ParamByName('pCCPin').AsString               := MySale^.ccPIN;
        ParamByName('pCCRequestType').AsInteger    := MySale^.CCRequestType;
        ParamByName('pCCAuthorizer').AsString      := Copy(MySale^.CCAuthorizer, 1, 10);;
        ParamByName('pCCAuthID').AsInteger         := MySale^.CCAuthID;
        ParamByName('pMODocNo').AsString           := MySale^.MODocNo;

        ParamByName('pEMVAuthConf').AsString       := copy(MySale^.emvauthconf, 1, 2048);
        ExecQuery;
        Close;
      end;
      rcur.Commit;
      if bLogging then UpdateZLog('Receipt Insert Completed');
    except
      on E : Exception do
      begin
        UpdateExceptLog( 'Insert Receipt Table ' + e.message);
        if bLogging then UpdateZLog('Receipt Insert Failed');
        if rcur.Transaction.InTransaction then
          rcur.Rollback;
      end;
    end;
  end;
  {$IFDEF DAX_SUPPORT}
  if (bDAXDBConfigured) then  //20071128a
  begin
    UpdateZLog('Receipt.SaveSale - Sending info to DAX');
    if Setup.DAXSupport then
      SendSalesMsg(PostSaleList);
    UpdateZLog('Receipt.SaveSale - Saving Sales File');
    SavePLUSales(PostSaleList);      //20071128c
    UpdateZLog('Receipt.SaveSale - DAX support done');
  end;
  {$ENDIF}
end;

{-----------------------------------------------------------------------------
  Name:      SaveSaleToText
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure SaveSaleToText(const PostSaleList : TList);
Var
i           : Integer;
MySale      : PSalesData;
DataLogText : string;
Begin

  For i := 0 to (PostSaleList.Count - 1) do
  begin
     MySale := PostSaleList.Items[i];
     DataLogText := BuildTag( POSTAG_TRANSNO,    IntToStr(pstSale.nTransNo) )
                  + BuildTag( POSTAG_SEQNUMBER,  IntToStr(MySale^.SeqNumber) )
                  + BuildTag( POSTAG_LINETYPE,   MySale^.LineType )
                  + BuildTag( POSTAG_SALETYPE,   MySale^.SaleType )
                  + BuildTag( POSTAG_NUMBER,     FloatToStr(MySale^.Number) )
                  + BuildTag( POSTAG_NAME,       MySale^.Name )
                  + BuildTag( POSTAG_QTY,        FloatToStr(MySale^.Qty) )
                  + BuildTag( POSTAG_PRICE,      FloatToStr(MySale^.Price) )
                  + BuildTag( POSTAG_EXTPRICE,   FloatToStr(MySale^.ExtPrice) )
                  + BuildTag( POSTAG_FUELSALEID, IntToStr(MySale^.FuelSaleID) )
                  + BuildTag( POSTAG_PUMPNO,     IntToStr(MySale^.PumpNo) )
                  + BuildTag( POSTAG_HOSENO,     IntToStr(MySale^.HoseNo) )
                  + BuildTag( POSTAG_TAXNO,      IntToStr(MySale^.TaxNo) )
                  + BuildTag( POSTAG_TAXRATE,    FloatToStr(MySale^.TaxRate) )
                  + BuildTag( POSTAG_TAXABLE,    FloatToStr(MySale^.Taxable) )

                  + BuildTag( POSTAG_PLUMODIFIER,  FloatToStr(MySale^.PLUModifier) )
                  + BuildTag( POSTAG_PLUMODIFIERGROUP,  FloatToStr(MySale^.PLUModifierGroup) )

        //          + BuildTag( TAG_DISCABLE, IntToStr(MySale^.Discable) )
        //          + BuildTag( TAG_LINEVOIDED, IntToStr(MySale^.LineVoided) )
                  + BuildTag( POSTAG_CCAuthCode,     MySale^.CCAuthCode )
                  + BuildTag( POSTAG_CCApprovalCode, MySale^.CCApprovalCode )
                  + BuildTag( POSTAG_CCDate,         MySale^.CCDate )
                  + BuildTag( POSTAG_CCTime,         MySale^.CCTime )
                  {$IFDEF CISP_WIDE_FIELDS}                                      //20060924a
                  + BuildTag( POSTAG_CCCardNo,       EncryptString(Copy(MySale^.CCCardNo,   1, MAX_DB_LEN_RECEIPT_CCCARD_NO)) )
                  + BuildTag( POSTAG_CCCardName,     EncryptString(Copy(MySale^.CCCardName, 1, MAX_DB_LEN_RECEIPT_CC_CARD_NAME)) )
                  {$ELSE}
                  + BuildTag( POSTAG_CCCardNo,       MySale^.CCCardNo )
                  + BuildTag( POSTAG_CCCardName,     MySale^.CCCardName )
                  {$ENDIF}
                  + BuildTag( POSTAG_CCCardType,     MySale^.CCCardType )
                  + BuildTag( POSTAG_CCExpDate,      MySale^.CCExpDate )
                  + BuildTag( POSTAG_CCBatchNo,      MySale^.CCBatchNo )
                  + BuildTag( POSTAG_CCSeqNo,        MySale^.CCSeqNo )
                  + BuildTag( POSTAG_CCEntryType,    MySale^.CCEntryType )
                  + BuildTag( POSTAG_CCVehicleNo,    MySale^.CCVehicleNo )
                  + BuildTag( POSTAG_CCOdometer,     MySale^.CCOdometer )
                  + BuildTag( POSTAG_SHIFT,          inttostr(nShiftNo))
                  //bp...
                  + BuildTag( POSTAG_CCPrintLine1,   MySale^.CCPrintLine[1] )
                  + BuildTag( POSTAG_CCPrintLine2,   MySale^.CCPrintLine[2] )
                  + BuildTag( POSTAG_CCPrintLine3,   MySale^.CCPrintLine[3] )
                  //lya...
                  + BuildTag( POSTAG_CCPrintLine4,   MySale^.CCPrintLine[4] )
                  + BuildTag( POSTAG_CCBalance1,     CurrToStr(MySale^.CCBalance1) )
                  + BuildTag( POSTAG_CCBalance2,     CurrToStr(MySale^.CCBalance2) )
                  //...lya
                  //53o...
                  + BuildTag( POSTAG_CCBalance3,     CurrToStr(MySale^.CCBalance3) )
                  + BuildTag( POSTAG_CCBalance4,     CurrToStr(MySale^.CCBalance4) )
                  + BuildTag( POSTAG_CCBalance5,     CurrToStr(MySale^.CCBalance5) )
                  + BuildTag( POSTAG_CCBalance6,     CurrToStr(MySale^.CCBalance6) )
                  //...53o
                  + BuildTag( POSTAG_ACTIVATION_STATE,   IntToStr(Integer(MySale^.ActivationState)) )
                  + BuildTag( POSTAG_ACTIVATION_TRANSNO, IntToStr(MySale^.ActivationTransNo) )
                  + BuildTag( POSTAG_ACTIVATION_TIMEOUT, FormatDateTime('yyyy/mm/dd hh:nn:ss', MySale^.ActivationTimeout) )
                  + BuildTag( POSTAG_LINE_ID,            IntToStr(MySale^.LineID) )
                  + BuildTag( POSTAG_CC_PIN,             MySale^.ccPIN )
                  + BuildTag( POSTAG_CCRequestType,  IntToStr(MySale^.CCRequestType) )
                  + BuildTag( POSTAG_CCAuthID,       IntToStr(MySale^.CCAuthID) )
                  + BuildTag( POSTAG_CCAuthorizer,   MySale^.CCAuthorizer )
                  //...bp
                  + BuildTag( POSTAG_USER,            CurrentUserID);
     if (sDataLogName > '') then
     begin
       WriteDataLog(DataLogText);
     end;
  end;

  DataLogText := BuildTag( POSTAG_TRANSNO, IntToStr(pstSale.nTransNo) )
               + BuildTag( POSTAG_SEQNUMBER, '999')
               + BuildTag( POSTAG_SUBTOTAL , FloatToStr(pstSale.nSubTotal) )
               + BuildTag( POSTAG_TAX , FloatToStr(pstSale.nTlTax) )
               + BuildTag( POSTAG_TOTAL , FloatToStr(pstSale.nTotal) )
               + BuildTag( POSTAG_CHANGEDUE , FloatToStr(pstSale.nChangeDue) )
               + BuildTag( POSTAG_TIME , FormatDateTime('h:mm',Time) )
               + BuildTag( POSTAG_DATE , FormatDateTime('mm/dd/yy',Date) )
               + BuildTag( POSTAG_SHIFT , IntToStr(nShiftNo) )
               + BuildTag( POSTAG_USER , CurrentUserID );
  if (sDataLogName > '') then
  begin
    WriteDataLog(DataLogText);
  end;


End;


{-----------------------------------------------------------------------------
  Name:      WriteDataLog
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: DataLogText : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure WriteDataLog(DataLogText : string);
var
  TF : TextFile;
begin
  if (sDataLogName > '') then
  try
    {$I-}
    AssignFile(TF, sDataLogName);
    if FileExists(sDataLogName) then
    try
      Append(TF);
    except
      CloseFile(TF);
      try
        Append(TF);
      except
      end;
    end
    else
    try
      ReWrite(TF);
    except
      closefile(TF);
      try
        Rewrite(TF);
      except
      end
    end;
    WriteLn( TF, DataLogText);
    CloseFile(TF);
  {$I+}
  except
    fmPOSErrorMsg.lErrMsg.Caption := 'Error Writing to Backup File';
    fmPOSErrorMsg.lblContinue.Caption := 'Touch Here to Continue';
    fmPOSErrorMsg.Caption := 'Backup Error';
    fmPOSErrorMsg.Visible := True;
  end;
end;

{$IFDEF DAX_SUPPORT}
procedure SendSalesMsg(const PostSaleList : TList);
var
 LQueueInfo : MSMQQueueInfo;
 LMessageQueue : MSMQQueue;
 LMQMsg : MSMQMessage;
 LTransaction : OLEVariant;
 Transaction : OlEVariant;
 SD : PSalesData;
 PLULineCount : Integer;
 SalesIndex : Integer;
 SalesTime : TDateTime;
//20071211b FileID : String;
{$IFDEF DEV_TEST}
 FileID : String;  //20071211b
 f    : Textfile;
{$ENDIF}
 FileLine : String;
begin
  PLULineCount := 0;
  For SalesIndex := 0 to (PostSaleList.Count - 1) do
  begin
    SD := PostSaleList.Items[SalesIndex];
    if SD^.LineType = 'PLU' then
      inc(PLULineCount);
  end;
  if PLULineCount = 0 then
    exit;
  Try
    if TransactionDisp = nil then
    begin
      UpdateZLog('Receipt.SendSalesMsg: creating TransactionDisp');
      TransactionDisp := CoMSMQTransactionDispenser.Create;
    end;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: prepping Transaction'); {$ENDIF}
    Transaction := TransactionDisp.BeginTransaction;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: creating LQueueInfo'); {$ENDIF}
    LQueueInfo := CoMSMQQueueInfo.Create;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: setting FormatName'); {$ENDIF}
    LQueueInfo.FormatName := Setup.DAXFORMATNAME;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: prepping LMessageQueue'); {$ENDIF}
    LMessageQueue := LQueueInfo.Open(MQ_SEND_ACCESS,MQ_DENY_NONE);
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: creating LMQMsg'); {$ENDIF}
    LMQMsg := CoMSMQMessage.Create;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: done creating'); {$ENDIF}
    //20071128b...
//    LMQMsg.Label_ := 'Store: ' + SetupNumber + ' Reg: ' + InttoStr(fmPos.ThisTerminalNo) + ' Trans: ' + InttoStr(pstSale.TransNo);
//    FileID := 'ST' + SetupNumber + 'RG' + InttoStr(fmPos.ThisTerminalNo)+ FormatDateTime('yyyymmddhhnn',Now()) + 'TR' + InttoStr(pstSale.TransNo) ;
    LMQMsg.Label_ := 'Store: ' + RightStr('000' + Setup.Number, 3) + ' Reg: ' + InttoStr(fmPos.ThisTerminalNo) + ' Trans: ' + InttoStr(pstSale.nTransNo);
//20071211b    FileID := 'ST' + RightStr('000' + SetupNumber, 3) + 'RG' + InttoStr(fmPos.ThisTerminalNo)+ FormatDateTime('yyyymmddhhnn',Now()) + 'TR' + InttoStr(pstSale.TransNo) ;
    //...20071128b
{$IFDEF DEV_TEST}
    FileID := 'ST' + RightStr('000' + SetupNumber, 3) + 'RG' + InttoStr(fmPos.ThisTerminalNo)+ FormatDateTime('yyyymmddhhnn',Now()) + 'TR' + InttoStr(pstSale.nTransNo) ;  //20071211b
    Assign (f, FileID + '.txt');
    Rewrite (f);
{$ENDIF}
    //20071211b...
//    FileLine := 'H,' + FormatDateTime('yyyymmddhhnn',Now()) + ',1,' + InttoStr(PLULineCount) + ',' + FileId;
//    LMQMsg.Body := FileLine;
//{$IFDEF DEV_TEST}
//    Writeln(f, FileLine);
//{$ENDIF}
    //...20071211b
    LMQMsg.Body :=  '';  //20071212a
    SalesTime := Now();
    For SalesIndex := 0 to (PostSaleList.Count - 1) do
    begin
      SD := PostSaleList.Items[SalesIndex];
      if SD^.LineType = 'PLU' then
      begin
        //20071128a...
//        FileLine := SetupNumber + ','  + FormatDateTime('yyyy-mm-dd hh:nn:ss',SalesTime) + ',' + RightStr('00000000000000' + CurrtoStr(SD^.Number),14) + ',' + Currtostr(SD^.Qty) + ',RealSales,Sales,EA';
        FileLine := Setup.DAXStoreID + ','  + FormatDateTime('yyyy-mm-dd hh:nn:ss',SalesTime) + ',' + RightStr('00000000000000' + CurrtoStr(SD^.Number),14) + ',' + Currtostr(SD^.Qty) + ',RealSales,Sales,EA';
        //...20071128a
        if (LMQMsg.Body =  '') then                                             //20071212a
          LMQMsg.Body := FileLine                                               //20071212a
        else                                                                    //20071212a
          LMQMsg.Body := LMQMsg.Body + chr(13) + chr(10) + FileLine;            //20071213a (add line-feed after each CR)
{$IFDEF DEV_TEST}
        Writeln(f, FileLine);
{$ENDIF}
      end;
    end;
{$IFDEF DEV_TEST}
    Close(f);
{$ENDIF}
    LQueueInfo.Journal := MQ_JOURNAL_NONE;
    LTransaction := MQ_SINGLE_MESSAGE;
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: done prepping, sending'); {$ENDIF}
    LMQMsg.Send(LMessageQueue,LTransaction);
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: done sending'); {$ENDIF}
    Transaction.Commit(EmptyParam, EmptyParam,EmptyParam);
    {$IFDEF TIMING_DEBUG} UpdateZLog('Receipt.SendSalesMsg: done committing transaction'); {$ENDIF}
  except
    fmPOS.POSError('DAX Support not properly configured. Disabling for terminal.');
    Setup.DAXSupport := false;
    try
      Transaction.Abort(EmptyParam,EmptyParam);
    except
    end;
  end;
end;

//20071128c... (procedure moved from unit CloseDay)
procedure SavePLUSales;
const
  ASCII_TAB = 9;
var
 SD : PSalesData;
 PLULineCount : Integer;
 SalesIndex : Integer;
 SalesTime : TDateTime;
 f    : Textfile;
 FileLine : String;
 FileName : String;

begin
  PLULineCount := 0;
  For SalesIndex := 0 to (PostSaleList.Count - 1) do
  begin
    SD := PostSaleList.Items[SalesIndex];
    if SD^.LineType = 'PLU' then
      inc(PLULineCount);
  end;
  if PLULineCount = 0 then
    exit;
  Try
    FileName := 'History\POS_' + RightStr('000' + Setup.Number, 3) + '_' + FormatDateTime('YYYY-MM-DD',Now()) + '.txt';
    Assign (f, FileName);
    if FileExists(FileName) then
      Append(f)
    else
    begin
      Rewrite (f);
      FileLine := 'StoreCode';
      FileLine := FileLine + chr(ASCII_TAB) + 'DataDate';
      FileLine := FileLine + chr(ASCII_TAB) + 'UPCCode';
      FileLine := FileLine + chr(ASCII_TAB) + 'SKUCode';                        //20071211a
      FileLine := FileLine + chr(ASCII_TAB) + 'UseUPC';
      FileLine := FileLine + chr(ASCII_TAB) + 'TranQuantity';
      FileLine := FileLine + chr(ASCII_TAB) + 'TranPrice';                      //20071211a
      FileLine := FileLine + chr(ASCII_TAB) + 'DAXTranType';
      FileLine := FileLine + chr(ASCII_TAB) + 'POID';
      FileLine := FileLine + chr(ASCII_TAB) + 'PackSize';
      FileLine := FileLine + chr(ASCII_TAB) + 'UseStoreEDICode';                //20071211a
      FileLine := FileLine + chr(ASCII_TAB) + 'SourceStamp';
      FileLine := FileLine + chr(ASCII_TAB) + 'DaleteByScope';
      Writeln(f, FileLine);
    end;
    SalesTime := Now();
    For SalesIndex := 0 to (PostSaleList.Count - 1) do
    begin
      SD := PostSaleList.Items[SalesIndex];
      if SD^.LineType = 'PLU' then
      begin
        FileLine := Setup.DAXStoreID;                                            // StoreCode
        FileLine := FileLine + chr(ASCII_TAB) + FormatDateTime('YYYY-MM-DD',SalesTime);  // DataDate
        FileLine := FileLine + chr(ASCII_TAB) + RightStr('00000000000000' + CurrtoStr(SD^.Number), 14);  // UseUPC
        FileLine := FileLine + chr(ASCII_TAB) + '';                             // SKUCode //20071211a
        FileLine := FileLine + chr(ASCII_TAB) + '1';                            // UseUPC
        FileLine := FileLine + chr(ASCII_TAB) + Currtostr(SD^.Qty);             // TranQuantity
        FileLine := FileLine + chr(ASCII_TAB) + Currtostr(SD^.Price);           // TranPrice  //20071211a
        FileLine := FileLine + chr(ASCII_TAB) + 'RealSales';                    // DAXTranType
        FileLine := FileLine + chr(ASCII_TAB) + '-1';                           // POID
        FileLine := FileLine + chr(ASCII_TAB) + 'EA';                           // PackSize
        FileLine := FileLine + chr(ASCII_TAB) + '0';                            // UseStoreEDICode  //20071211a
        FileLine := FileLine + chr(ASCII_TAB) + '';                             // SourceStamp
        FileLine := FileLine + chr(ASCII_TAB) + '1';                            // DaleteByScope
        Writeln(f, FileLine);
      end;
    end;
    Close(f);
  except
  end;
end;
//...20071128c

initialization
  TransactionDisp := nil;

{  DO NOT DO THIS!  TransactionDisp is an Interfaced object so it will free itself.
   The following will double-free it and cause AV exceptions on shutdown
finalization
  if TransactionDisp <> nil then
    FreeAndNil(TransactionDisp);
}

{$ENDIF}  // DAX_SUPPORT

end.

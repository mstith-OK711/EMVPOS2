unit LatTypes;

interface

uses
  Classes,
  PumpxIcon;

const
  MaxPumps = 32;
  SIZE_MSR_DATA = 201;
  SIZE_CARDNO = 20;

  MULTITAX_PLU = -1;
  MULTITAX_DEPT = -2;

type
  TShowMsgProc = procedure(const sTopMsg, sBottomMsg: String; const sleeptime: integer) of object;

  pMsgRec = ^TMsgRec;
  TMsgRec = record
    Text : string;
  end;

  TSmallIntQuery = function() : smallint of object;
  TSmallIntNotify = procedure(const Value : smallint) of object;

  TPumpArray = array[1..MaxPumps] of TPumpxIcon;
  pPumpArray = ^TPumpArray;

  TCardSource = (csManual, csMSR, csPinPad, csSalesList, csThinAir);

  TValidCardInfo = record
    Orig           : WideString;
    Track1Data     : WideString;
    Track2Data     : WideString;
    CardNo         : WideString;
    ExpDate        : WideString;
    ServiceCode    : WideString;
    CardName       : WideString;
    VehicleNo      : WideString;
    CardError      : WideString;
    CardType       : WideString;
    CardTypeName   : WideString;
    EntryMethod    : WideString;
    iFaceValueCents : integer;
    bActivationType : WordBool;
    bGetDriverID   : WordBool;
    bGetOdometer   : WordBool;
    bGetRefNo      : WordBool;
    bGetVehicleNo  : WordBool;
    bGetID         : WordBool;
    bGetZIPCode    : WordBool;
    bAskDebit      : WordBool;
    bDebitBINMngt  : WordBool;
    bValid         : WordBool;
    bGetPIN        : WordBool;
    cardsource     : TCardSource;
    AuthID         : Integer;
    FinalAmount    : currency;
    UPC            : currency;
    PinBlock       : WideString;
    PinKSN         : WideString;
    PPCurrent      : Boolean;
    EncryptedTrackData : AnsiString;
    EMVAuth : AnsiString;
    mediarestrictioncode : integer;
  end;
  pValidCardInfo = ^TValidCardInfo;

  pGiftCardData = ^TGiftCardData;
  TGiftCardData = record
    FaceValue       : Currency;
    PriorValue      : Currency;
    RestrictionCode : integer;
    HostApprovalCode : string;  //20060622
    CardStatus      : integer;
    CardNo          : array [ 0..SIZE_CARDNO - 1] of char;
    MSRData         : array [ 0..SIZE_MSR_DATA-1] of char;
  end;

  TPPEntry = (ppeNone, ppePhoneNo = 250, ppeVehicleNo = 237, ppeDriverID = 236, ppeID = 242, ppeOdometer = 239, ppeZipCode=249);
  TPPEntryExitType = (ppeetEnter, ppeetCancel, ppeetDecline);

  TNotList = class(TList)
    private
      FName : string;
    procedure SetName(const Value: String);
  {$IFDEF MEMORY_DEBUG}
    protected
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  {$ENDIF}
    public
      property Name : String read FName write SetName;
  end;

  pCreditResponseData = ^TCreditResponseData;
  TCreditResponseData = record
    sMSGType            : string;
    sCCAllowed          : string;
    sCCAuthAmount       : string;
    sCCAuthCode         : string;
    sCCApprovalCode     : string;
    sCCDate             : string;
    sCCTime             : string;
    sCCCardNo           : string;
    sCCCardName         : string;
    sCCCardType         : string;
    sCCExpDate          : string;
    sCCBatchNo          : string;
    sCCSeqNo            : string;
    sCCEntryType        : string;
    sCCRefNo            : string;
    sCCReaderNo         : string;
    sCCOdometer         : string;
    sCCVehicleNo        : string;
    sCCRetrievalRef     : string;
    sCCAuthNetID        : string;
    sCCTraceAuditNo     : string;
    sCCAuthorizer       : string;
    sCCPrintLine        : array[1..4] of string;
    sCCAuthMsg          : string;
    sCCCPSData          : string;
    sCCPumpLimit        : string;
    sEMVresp            : string;
    sEMVauthCFM         : string;  //emv auth confirmation from pinpad
    iCCGiftRestriction  : integer;
    nCCBalance1         : currency;
    nCCBalance2         : currency;
    nCCBalance3         : currency;
    nCCBalance4         : currency;
    nCCBalance5         : currency;
    nCCBalance6         : currency;
    nCCRequestType      : integer;
    nCCAuthID           : integer;
    nChargeAmount       : currency;
    PaidItems           : TNotList;
    mediarestrictioncode: longword;
  end;

  pPaymentInfo = ^TPaymentInfo;
  TPaymentInfo = record
    AuthID : integer;
    LineID : integer;
    Amount : currency;
  end;

  TSaleState = (ssNoSale, ssSale, ssTender, ssBankFunc, ssBankFuncTender );

  // Define states for products (such as phone cards) that require activation when purchased.
  // Note:  Gift cards that can also be used as tender do not currently use this method (i.e., state does not apply).
  TActivationState = (asActivationDoesNotApply,  // Product is not activated (see note above).
                      asWaitBalance,             // Product requires balance check before activation can continue.
                      asActivationNeeded,        // Product requires activation, but activation has not been initiated.
                      asActivationPending,       // Activation has been sent to the credit server, but not response yet.
                      asActivationSucceded,      // Approved response received from credit server.
                      asActivationFailed,        // Non-approved response received from credit server.
                      asActivationDeclined,      // Attempted activation was declined.
                      asActivationRejected,      // Same as "declined", but de-activation not required.
                      asActivationApproved);     // Product has been activated.

  { Pointer to Sales line item record }
  pSalesData = ^TSalesData;
  { Sales line item record - Never place reference counted variables in here (ie. non-static strings) }
  TSalesData = record
    SeqNumber : ShortInt;
    LineType : string[3];
    SaleType : string[4];
    Number : Currency;
    Name : string[30];
    Qty : Currency;
    Price : Currency;
    ExtPrice : Currency;

    SavDiscType : string[1];
    SavDiscable : Currency;
    SavDiscAmount : Currency;

    FuelSaleID : integer;
    PumpNo : shortint;
    HoseNo : shortint;

    TaxNo: Integer;
    TaxRate: Currency;
    Taxable: Currency;
    Discable : Boolean;
    FoodStampable : Boolean;
    FoodStampApplied : Currency;

    LineVoided : Boolean;
    AutoDisc   : Boolean;
    //Build 18
    PriceOverridden : boolean;
    //Build 18

    PLUModifier : integer;
    PLUModifierGroup : currency;
    DeptNo : integer;
    VendorNo : integer;
    ProdGrpNo : integer;
    LinkedPLUNo : Double;
    SplitQty : integer;
    SplitPrice : currency;
    QtyUsedForSplitOrMM  : integer;

    ItemNo : Currency;

    WexCode : shortint;
    PHHCode : shortint;
    IAESCode : shortint;
    VoyagerCode : shortint;
    CCAuthCode : string[2];
    CCApprovalCode : string[6];
    CCDate : string[4];
    CCTime : string[6];
    CCCardNo : string[20];
    CCPhoneNo   : string[20];
    CCCardName  : string[40];  // IDT_INF (20 changed to 40)
    CCCardType  : string[20];
    CCExpDate   : string[10];
    CCBatchNo   : string[2];
    CCSeqNo     : string[3];
    CCEntryType : string[1];          {M or S}
    CCVehicleNo : string[10];
    CCOdometer  : string[10];
    CCVehicleID : string[10];
    CCRetrievalRef  : string[10];
    CCAuthNetId     : string[10];
    CCAuthorizer    : string[10];
    CCTraceAuditNo  : string[10];
    CCCPSData       : string[20];
    CCPrintLine     : array[1..4] of string[80];
    CCBalance1      : currency;
    CCBalance2      : currency;
    CCBalance3      : currency;
    CCBalance4      : currency;
    CCBalance5      : currency;
    CCBalance6      : currency;
    CCRequestType   : integer;
    CCAuthId        : integer;
    CCPartialTend   : boolean;
    CCHost          : integer;  // specifies if an activated product is to go to a specific host for activation

    //Gift
    GiftCardRestrictionCode : integer;
    GiftCardStatus          : integer;
    GCMSRData : array [0..SIZE_MSR_DATA-1] of char;
    //Gift

    {$IFDEF ODOT_VMT}
    VMTReceiptData : WideString;
    {$ENDIF}
    SeqLink : shortint;
    MODocNo : string[20];

    NeedsActivation : boolean;
    ActivationState : TActivationState;
    ActivationTransNo : integer;        // Normally, same as "current", but resumed sales are re-assigned a transaction #.
    ActivationTimeout : TDateTime;      // Time to wait for credit server on product activations
    LineID : integer;                   // To uniquely identify this sales list item.
    ccPIN : string[20];

    receipttext : ansistring;

    mediarestrictioncode : longword;

    emvauthconf : ansistring;

    // internal state variables below
    paidlist : TNotList;
  end;

  TSaleHeader = record
    nNonTaxable       : Currency;
    nFSSubtotal       : Currency;
    nFuelSubtotal     : Currency;
    FoodStampMediaAmount : currency;
    FuelMediaAmount      : currency;
    nSubtotal         : Currency;
    nTlTax            : Currency;
    //20040802...(need to include food stamp tax with amount to pass to credit for EBT)
    nFSTax            : Currency;
    //...20040802
    nTotal            : Currency;
    //Gift
    nMedia            : Currency;
    //Gift
    nChangeDue        : Currency;
    nTransNo          : Integer;
    nDiscountableTl   : Currency;
    nFSChange         : currency;
    nAmountDue        : Currency;
    bSalesTaxXcpt     : Boolean;
  end;


  pSalesTax = ^TSalesTax;
  TSalesTax = record
    TaxNo       : Integer;
    TaxName     : string[30];
    TaxType     : Integer;
    TaxRate     : Currency;
    Taxable     : Currency;
    TaxQty      : Currency;
    TaxCharged  : Currency;
    CalcAmount  : currency;
    FirstPenny  : currency;
    SalesTax    : boolean;
    //20040908...
    FSTaxExemptSales : currency;    // Food stamp sale amount exempted from sales tax
    FSTaxExemptAmount : currency;   // Food stamp sales tax exempted
    //...20040908
    Increment   : array[1..50] of currency;
    RepeatCount : array[1..50] of integer;
    CurCount    : array[1..50] of integer;
    StepType    : array[1..50] of integer;
  end;

  pTlist = ^TList;

  pSalesSummaryData = ^TSalesSummaryData;
  TSalesSummaryData = record
    Dept      : integer;
    FuelDept  : boolean;
    UnitPrice : currency;
    Qty       : currency;
    ExtAmount : currency;
  end;

  TCardMediaType = (ctGenericSmart, ctWIC, ctEMV, ctSwiped=98, ctInvalid=99);
  TTranType = (ttUnknown, ttPurchase);
  TCardStatus = (csInserted = ord('I'), csRemoved = ord('R'), csProblem = ord('P'), csSwiped = ord('S'));

  TMsgRecEvent = procedure(const msg : string) of object;
  TMsgRespRequest = procedure(const msg : string; const respdest : TMsgRecEvent) of object;

  TMsgRecCallMe = class(TObject)
    private
      p : TMsgRecEvent;
    public
      Constructor Create(const ap : TMsgRecEvent);
      procedure call(const param : string);
    end;

function CardSourceToText(const Value : TCardSource) : string;
procedure InitializeCRD(pCRD : pCreditResponseData);

implementation

uses
  Windows,
  ExceptLog;

const
  {$I CreditServerConst.inc}

function CardSourceToText(const Value : TCardSource) : string;
begin
  case Value of
   csManual : Result := 'Manual';
   csMSR    : Result := 'MSR';
   csPinPad : Result := 'PinPad';
   csSalesList : Result := 'SalesList';
   csThinAir : Result := 'Thin Air';
  else
    Result := 'Unknown';
  end;
end;

procedure InitializeCRD(pCRD : pCreditResponseData);
var
  i : integer;
begin
  ZeroMemory(pCRD, sizeof(TCreditResponseData));
  with pCRD^ do
  begin
    sCCAuthCode      := '';
    sCCApprovalCode  := '';
    sCCDate          := '';
    sCCTime          := '';
    sCCCardNo        := '';
    sCCCardName      := '';
    sCCCardType      := '';
    sCCExpDate       := '';
    sCCBatchNo       := '';
    sCCSeqNo         := '';
    sCCEntryType     := '';
    sCCVehicleNo     := '';
    sCCOdometer      := '';
    sCCRetrievalRef  := '';
    sCCAuthNetID     := '';
    sCCTraceAuditNo  := '';
    sCCAuthorizer    := '';
    for i := low(sCCPrintLine) to high(sCCPrintLine) do
      sCCPrintLine[i] := '';
    nCCBalance1       := UNKNOWN_BALANCE;
    nCCBalance2       := UNKNOWN_BALANCE;
    nCCBalance3       := UNKNOWN_BALANCE;
    nCCBalance4       := UNKNOWN_BALANCE;
    nCCBalance5       := UNKNOWN_BALANCE;
    nCCBalance6       := UNKNOWN_BALANCE;
    sCCAuthMsg        := '';
    nCCRequestType    := RT_UNKNOWN;
    nCCAuthID         := CC_AUTHID_UNKNOWN;
  end;
end;

{ TNotList }
{$IFDEF MEMORY_DEBUG}
procedure TNotList.Notify(Ptr: Pointer; Action: TListNotification);
var
  t : string;
begin
  inherited;
  case Action of
    lnAdded : t := 'Added';
    lnExtracted : t:= 'Extracted';
    lnDeleted : t:= 'Deleted';
  end;
  UpdateZLog('  %s.Notify - %s %p', [Self.Name, t, Ptr]);
  UpdateExceptLog('  %s.Notify - %s %p', [Self.Name, t, Ptr]);
end;
{$ENDIF}

procedure TNotList.SetName(const Value: String);
begin
  if FName = '' then
    FName := Value;
end;

{ TMsgRecCallMe }

procedure TMsgRecCallMe.call(const param: string);
begin
  p(param);
end;

constructor TMsgRecCallMe.Create(const ap: TMsgRecEvent);
begin
  inherited Create;
  p := ap;
end;

end.

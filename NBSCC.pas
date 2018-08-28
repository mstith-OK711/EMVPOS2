{-----------------------------------------------------------------------------
 Unit Name: NBSCC
 Author:    Gary Whetton
 Date:      7/25/2003 4:22:28 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit NBSCC;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, POSMain,
  Math, StdCtrls, DB, AdPort, ExtCtrls, POSBtn, ElastFrm, ComObj,
  POSCtrls, LatTypes;

const
  {$I ConditionalCompileSymbols.txt}
  {$I CreditServerConst.inc}
  {$I LatitudeConst.inc}
  //{$DEFINE DEBUG}
  WM_SETPIN  = WM_USER + 200;
  WM_CHECKENTRY = WM_USER + 209;

  PROCESS_KEY_PIN_ENTRY = 'Q';  // special indicator for PIN entry from PIN pad.    //20040922

  PIN_INPUTMASKED     = True;
  PIN_INPUTNOTMASKED  = False;

  NEXT_ALLOWED        = False;
  NEXT_NOTALLOWED     = False;

  {Button values for entering total date codes}
  KV_ENTER_DATE_CODE      = 'DC0';  // Use keypad to enter MMDDYY format.
  KV_NON_SETTLE_NON_CLEAR = 'DC1';
  KV_SETTLE_CLEAR         = 'DC2';
  KV_MOST_RECENT_DAY      = 'DC3';
  KV_2ND_MOST_RECENT_DAY  = 'DC4';
  KV_3RD_MOST_RECENT_DAY  = 'DC5';
  KV_NON_SETTLE_CLEAR     = 'DC9';

  DC0_BUTTON_NUMBER =  3;
  DC1_BUTTON_NUMBER =  1;
  DC2_BUTTON_NUMBER = 15;
  DC3_BUTTON_NUMBER =  4;
  DC4_BUTTON_NUMBER =  5;
  DC5_BUTTON_NUMBER =  6;
  DC9_BUTTON_NUMBER = 13;
  DCC_BUTTON_NUMBER = 11; // cancel
  //...bpe

  VOID_CREDIT_CLEAR_BUTTON_NUMBER = 5;
  VOID_CREDIT_AUTH_BUTTON_NUMBER  = 7;
//...bp

  //Build 23
  SIZE_KEY_BUFF          = 200;
  //Build 23
  // Number of concurrent sales transactions with credit server sessions.
  // (Example, normal, next customer, balance inquiry.)
  MAX_CCCLIENTS = 4;
  DEFAULT_CCINDEX = 0;
  //Gift

  DebugMode : boolean = false;
  {$IFDEF DEV_PIN_PAD}
  bNotifyPINPadPaymentType : boolean = True;
  {$ENDIF}
  
  FS_CHAR : char = char($1C);

  
type
  //Gift
  TKeyPadID = (mKeyPadUnknown, mKeyPadNone, mKeyPadClear, mKeyPadNumber, mKeyPadDebitCredit,
  //bpe...
//               mKeyPadYesNo, mKeyPadNextCustomerNo, mKeyPadNextCustomerYes);
               mKeyPadYesNo, mKeyPadNextCustomerNo, mKeyPadNextCustomerYes, mKeyPadVoidCredit, mKeyPadDateCode, mKeyPadEnterClear);
  //...bpe

type
  TfmNBSCCForm = class(TForm)
    lStatus: TPanel;
    ElasticForm1: TElasticForm;
    AuthTimeOutTimer: TTimer;
    lPinPadStatus: TPanel;
    leApprovalCode: TPOSLabeledEdit;
    leCardNo: TPOSLabeledEdit;
    leCardName: TPOSLabeledEdit;
    leExpDate: TPOSLabeledEdit;
    leCardTypeName: TPOSLabeledEdit;
    leRestrictionCode: TPOSLabeledEdit;
    leVehicleNo: TPOSLabeledEdit;
    leDriverID: TPOSLabeledEdit;
    leOdometer: TPOSLabeledEdit;
    leRefNo: TPOSLabeledEdit;
    leZipCode: TPOSLabeledEdit;
    leCardType: TPOSLabeledEdit;
    leID: TPOSLabeledEdit;
    //...53l
    //bp...
//    lDateCode: TLabel;
    //...bp
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure AuthTimeOutTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tpleEnter(Sender: TObject);
    procedure tpleExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    //Gift

    EntryType : string;
    FCurrentTransNo          : integer;
    GiftCardBalance          : currency;
    PriorGiftCardBalance     : currency;
    GiftCardRestrictionCode  : integer;
    GiftCardStatus           : integer;
    FSinAmount               : currency;  // Includes tobacco, acholol, lottery (plus associated tax)
    //bpd...
    FVoidTransNo             : integer;
    //...bpd
    FAuthorized              : integer;
    FChargeAmount            : currency;
    FTaxAmount               : currency;
    FAmountDue               : currency;
    FFuelAmount              : currency;
    FNonFuelAmount           : currency;
    FVCI                     : pValidCardInfo;
    FAuthSent                : boolean;
    FPreauth                 : boolean;
    FSalesList               : TNotList;
    FPayList                 : TNotList;

    procedure SetSinAmount(Value : currency);
    //bpd...
    procedure SetVoidTransNo(Value : integer);
    //...bpd
    procedure SetFuelAmount(Value : currency);
    procedure SetNonFuelAmount(Value : currency);
    procedure SetAuthorized(Value : integer);

    procedure SetChargeAmount(Value : currency);
    procedure SetTaxAmount(Value    : currency);
    procedure SetAmountDue(Value    : currency);

    procedure CheckEntries();
    procedure ProcessVCI();
    procedure SendCardAuth();
    procedure SendFinalizeAuth(authid : integer; finalamount : currency);
    //Gift
    function ValidDriverID        : boolean;
    function ValidID              : boolean;
    function ValidOdometer        : boolean;
    function ValidRefNo           : boolean;
    function ValidVehicleNo       : boolean;
    function ValidRestrictionCode : boolean;
    function ValidZIPCode         : boolean;
    procedure BuildTouchPad;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );

    procedure SetClearPad;
    procedure SetBlankPad;
    procedure SetNumberPad;

    function DecodeAuthResp(const msg : widestring) : pCreditResponseData;
    procedure ProcessAuthResp(const resp : pCreditResponseData);
    procedure ProcessEMVAuthResp(const resp : pCreditResponseData);
    
    procedure ProcessBalanceResp(const resp : pCreditResponseData);
    procedure SetCurrentTransNo(const Value: integer);
    procedure AlertCSToCancel(const TransNo : integer);
    procedure SetPreauth(const Value: boolean);
  public
    { Public declarations }
    SwipedCreditNeedsSignature : boolean;
    procedure InitialScreen();
    procedure PPCustomerDataReceived(Sender : TObject; const exittype : TPPEntryExitType; const entrytype : TPPEntry; const entry : string);
    function PPCardStatusChange(Sender : TObject; const CardMediaType : TCardMediaType; const CardVersion : integer;
                                const Trantype : TTranType; const CardStatus : TCardStatus) : boolean;
    procedure CCButtonClick(Sender: TObject);
    procedure ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string);
    procedure ResetLabels;
    procedure ScrubForm;
    procedure ProcessCreditMsg(const msg : widestring);
    function PPPromptChange(      Sender         : TObject;
                            const PinPadStatusID : string;
                            const PinPadPrompt   : string) : boolean;

    procedure CheckServiceCode;

    {$IFDEF FF_PROMO}
    function ValidFuelFirstCard() : boolean;
    {$ENDIF}

    function  GetSalePumpNo: integer;  // returns first pump no found in sale
    function  FormatSalesData (salelist : TNotList; const authid : integer; const mr : longword) : string;
    procedure ProcessEMVDecline(const resp : pCreditResponseData);
    procedure VCIReceived(const pVCI : pValidCardInfo);
    procedure ClearCardInfo();
    procedure PPAuthInfoReceived(      Sender        : TObject;
                                 const PinPadAmount  : currency;
                                 const PinPadMSRData : string;
                                 const PINBlock      : string;
                                 const PINSerialNo   : string);
    procedure OnlinePINTryExceeded();
    procedure ProcessEMVAuthCFM(const resp : pCreditResponseData);
    procedure ProcessEMVVoid(const msg : string);
    procedure SetOnlineT99Switch();
    procedure ShowMustUseEMV;
    property CurrentTransNo : integer  read FCurrentTransNo write SetCurrentTransNo;
    property SinAmount : currency read FSinAmount write SetSinAmount;
    //bpd...
    property VoidTransNo : integer read FVoidTransNo write SetVoidTransNo;
    //...bpd
    property FuelAmount : currency read FFuelAmount write SetFuelAmount;
    property NonFuelAmount : currency read FNonFuelAmount write SetNonFuelAmount;
    property Authorized : integer read FAuthorized write SetAuthorized;
    property ChargeAmount : currency read FChargeAmount write SetChargeAmount;
    property TaxAmount    : currency read FTaxAmount write SetTaxAmount;
    property AmountDue    : currency read FAmountDue write SetAmountDue;
    property Preauth : boolean read FPreauth write SetPreauth;
    property SalesList : TNotList read FSalesList write FSalesList;
  end;

var
  fmNBSCCForm: TfmNBSCCForm;

implementation

//53h...
//uses POSDM, POSLog, POSErr, Mainmenu, POSMisc, PinPad;
//DSG
//uses POSDM, POSLog, POSErr, Mainmenu, POSMisc, PinPad, POSUser, XMD;
uses POSDM, POSLog, POSErr, ExceptLog, POSMisc, PinPad, POSUser, GiftFuelDiscount, StrUtils, JCLDebug, MedRestrict, JCLStringLists,
     JclHashMaps, JclContainerIntf,
     PINPadTrans;
//DSG
//...53h

{$R *.DFM}

const
  RS_CHAR : char = char($1E);

var
  bGotDriverID, bGotOdometer, bGotVehicleNo, bGotID, bGotZipCode, bGotRefNo : Boolean;
  //Resp : TCredResponse;

  //Gift
  KeyPadID : TKeyPadID;
  //Gift

  bIgnoreSwipe : boolean;
  //bNoOrigSale  : boolean;

  CardTypeName  : widestring;
  ServiceCode   : string;
  CardError     : widestring;
  UserData      : string;
  UserDataCount : string;

  DebitCashBackAmount : currency;
  {$IFDEF DEV_PIN_PAD}
  bExpectCashBackAmount : boolean;
  {$ENDIF}

  //Build 23
  //KeyBuff: array[0..200] of Char;
  KeyBuff : array[0..SIZE_KEY_BUFF] of Char;
  //Build 23
  BuffPtr: short;

  bGetApproval, bGetDate : wordbool;
  bRetryDriverID : boolean;

  //53l...
//  bGetRestrictionCode, bGetVehicleNo : boolean;
  bGetRestrictionCode : WordBool;
  //...53l
  //dma... //dmb...
  bDebitBINMngt : WordBool;
  PINEntryAttempts : integer;
  //...dma

  (*DriverIDCount : short;
  DriverID1     : string;
  DriverID2     : string;
  DriverID3     : string;*)



  (*PinText      : string;
  SendBuff     : Array [0..128] of char;
  ComToken     : Integer;
  PINToken     : Integer;
  RcvPtr       : Integer;
  RcvBuffer    : Array [0..200] of Char;*)
  //Gift

  bSwipeErrFlag : boolean;

  Keytops      : array[1..15] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '', '0', '', 'C', 'B', 'E');
  POSButtonsNBSCC    : array[1..15] of TPOSTouchButton;


procedure TfmNBSCCForm.SendCardAuth();
var
  CCMsg : widestring;
  DiscNo : integer;
  DiscountedAmount : currency;
begin
  //ShowMessage('inside SendCardAuth function'); // madhu remove
  lStatus.Caption := 'Beginning Credit Auth';
  lStatus.refresh;

  // Pin pad may have altered the amount (e.g., when reduced to food stamp amount for EBT FS.
  if (fmPos.PPTrans <> nil) and (fmPOS.PPTrans.PinPadOnLine) and (fmPOS.PPTrans.Enabled) then
    ChargeAmount := fmPos.PPTrans.PINPadAmount;

  with POSDataMod.IBTempQuery do
  begin
    if not Transaction.InTransaction then
      Transaction.StartTransaction;
    close;SQL.Clear;
    SQL.Add('Select DiscNo from CCValidCards where CardType = :pCardType and StartISO <= :pISO and EndISO >= :pISO');
    parambyname('pCardType').AsString := FVCI^.CardType;
    parambyname('pISO').AsString := copy(FVCI^.CardNo,1,6);
    open;
    if fieldbyname('DiscNo').AsInteger > 0 then
      DiscNo := fieldbyname('DiscNo').AsInteger
    else
      DiscNo := 0;
    Close;
    Transaction.Commit;
  end;
{$IFDEF FUEL_PRICE_ROLLBACK}
  if ((DiscNo > 0) and (DiscNo <> CASH_EQUIV_FUEL_DISC_NO)) then
{$ELSE}
  if DiscNo > 0 then
{$ENDIF}
  begin
{$IFDEF CASH_FUEL_DISC}
    DiscountedAmount := ApplyDiscount(DiscNo, 'DSG', ChargeAmount);
{$ELSE}
    DiscountedAmount := ApplyDiscount(DiscNo);
{$ENDIF}
    ChargeAmount := ChargeAmount - DiscountedAmount;
    FuelAmount := FuelAmount - DiscountedAmount;
  end;

  //----------------------// madhu gv  27-10-2017   check   start ------------------

 {CCMsg := BuildTag(TAG_MSGTYPE, 'AUTHCARD') +
          BuildTag(TAG_ENTRYTYPE, 'S') +
           BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', 1.83))])) +
           BuildTag(TAG_FUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', -3.95 ))])) +
           BuildTag(TAG_NONFUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', 7.94 ))])) +
           BuildTag(TAG_TAXAMOUNT, Format('%10s',[( FormatFloat ( '###.00', 0.14 ))])) +
          { BuildTag(TAG_AUTHAMOUNT, Format('%10s',[1.83])) +
           BuildTag(TAG_FUELAMOUNT, Format('%10s',[-3.95])) +
           BuildTag(TAG_NONFUELAMOUNT, Format('%10s',[7.94])) +
           BuildTag(TAG_TAXAMOUNT, Format('%10s',[0.14])) +                   }
         {  BuildTag(TAG_TRANSNO,  Format('%6.6d',[006708]) ) +
           BuildTag(TAG_PUMPNO,'0') +
           BuildTag(TAG_SALESDATA, '008 1.09 3 3.27,000 1.58 1 1.58,088 0.14 1 0.14') +
           BuildTag(TAG_CARDNAME, 'CardholderName') +
           BuildTag(TAG_SERVICECODE, '001') +
           BuildTag(TAG_ENTRYMETHOD, '2')+
           BuildTag(TAG_CARDNO, '476173XXXXXX0119') +
           BuildTag(TAG_EXPDATE, '062026') +
           BuildTag(TAG_TRACK1DATA,'') +
           BuildTag(TAG_TRACK2DATA,';476173XXXXXX0119=EXPD?')+
           BuildTag(TAG_SERIALNUMBER,'123') +
           BuildTag(TAG_PINBLOCK, FVCI^.PinBlock) +
           BuildTag(TAG_CASHBACKAMOUNT, Format('%10s',[( FormatFloat ( '###.00',0.00))])) +
           BuildTag(TAG_CARDTYPE,'04')+
           BuildTag(TAG_EMVAUTH, 'ING\x1eT4F:07:hA0000000031010\x1c');
                                        // madhu gv  27-10-2017   check    end
           }
 //-------------------------------------------------------------// madhu gv  27-10-2017   check   start----------------
  CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_AUTHCARD)) +
           BuildTag(TAG_ENTRYTYPE, Self.EntryType) +
           BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', ChargeAmount + DebitCashBackAmount))])) +
           BuildTag(TAG_FUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', FuelAmount ))])) +
           BuildTag(TAG_NONFUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', NonFuelAmount ))])) +
           BuildTag(TAG_TAXAMOUNT, Format('%10s',[( FormatFloat ( '###.00', TaxAmount ))])) +
           BuildTag(TAG_TRANSNO,  Format('%6.6d',[CurrentTransNo]) ) +
           BuildTag(TAG_PUMPNO, IntToStr(GetSalePumpNo)) +
           BuildTag(TAG_SALESDATA, FormatSalesData(fmPos.CurSaleList, CC_AUTHID_UNKNOWN, FVCI^.mediarestrictioncode)) +
           BuildTag(TAG_CARDNAME, FVCI^.CardName) +
           BuildTag(TAG_SERVICECODE, FVCI^.ServiceCode) +
           BuildTag(TAG_ENTRYMETHOD, FVCI^.EntryMethod);
  if FVCI^.EncryptedTrackData <> '' then
    CCMSG := CCMSG + BuildTag(TAG_ENCRYPTEDTRACKDATA, FVCI^.EncryptedTrackData)
  else
    CCMSG := CCMSG + BuildTag(TAG_CARDNO, FVCI^.CardNo) +
                     BuildTag(TAG_EXPDATE, FVCI^.ExpDate) +
                     BuildTag(TAG_TRACK1DATA, FVCI^.Track1Data) +
                     BuildTag(TAG_TRACK2DATA, FVCI^.Track2Data);
  if FPreauth then
    CCMsg := CCMsg + BuildTag(TAG_FUTURE_CAPTURE, 'Yes');
  if leDriverID.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_DRIVERID, leDriverID.Text);
  if leID.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_ID, leID.Text);
  if leOdometer.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_ODOMETER, leOdometer.Text);
  if leVehicleNo.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_VEHICLENO, leVehicleNo.Text);
  if leRefNo.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_REFNO, leRefNo.Text);
  if leZipCode.Text <> '' then
    CCMsg := CCMsg + BuildTag(TAG_BILLING_ZIP, leZipCode.Text);
  if ((FVCI^.PinKSN <> '') and  (FVCI^.PinBlock <> '')) then
  begin
    CCMsg := CCMsg + BuildTag(TAG_SERIALNUMBER, FVCI^.PinKSN) +
                     BuildTag(TAG_PINBLOCK, FVCI^.PinBlock) +
                     BuildTag(TAG_CASHBACKAMOUNT, Format('%10s',[( FormatFloat ( '###.00', DebitCashBackAmount ))])) ;
    if not((FVCI^.CardType = CT_EBT_FS) or (FVCI^.CardType = CT_EBT_CB)) then
    begin
      FVCI^.CardType := CT_DEBIT;
      CCMsg := CCMsg + BuildTag(TAG_CARDTYPE, CT_DEBIT);
    end
    else
      CCMsg := CCMsg + BuildTag(TAG_CARDTYPE, FVCI^.CardType);
  end
  else
  begin
    CCMsg := CCMsg + BuildTag(TAG_CARDTYPE, FVCI^.CardType);
  end;
  if ((EntryType = 'M') and (FVCI^.CardType = CT_VOYAGER) and (leRestrictionCode.Text <> '')) then
    CCMsg := CCMsg + BuildTag(TAG_RESTRICTION_CODE, leRestrictionCode.Text)
  else if (FVCI^.CardType = CT_GIFT) then
    CCMsg := CCMsg + BuildTag(TAG_SIN_AMOUNT, CurrToStr(SinAmount)); //+
                     //BuildTag(TAG_RESTRICTION_CODE, IntToStr(GiftCardRestrictionCode)) +
                     //BuildTag(TAG_CASHOUT_OPTION, IntToStr(GiftCardCashOutOption));
  //Here is where I would need to set the <TSI>
  if FVCI^.EMVAuth <> '' then
    CCMsg := CCMsg + BuildTag(TAG_EMVAUTH, 'ING' + cRS + FVCI^.EMVAuth);
      // madhu gv  27-10-2017   check   end

  Self.lStatus.Visible := True;
  SetBlankPad;
  if not debugmode then
  begin
    AuthTimeOutTimer.Interval := 60000;
    AuthTimeOutTimer.Enabled := True;
  end;
  fmPOS.SendCreditMessage(CCMsg);
  FAuthSent := True;
end;

procedure TfmNBSCCForm.SendFinalizeAuth(authid : integer; finalamount : currency);
var
  CCMsg : widestring;
begin
  //ShowMessage('inside SendFinalizeAuth function'); // madhu remove
  lStatus.Caption := 'Beginning Finalize Auth';
  CCMsg := fmPOS.FormatFinalizeAuth(authid, finalamount, curSale.nTransNo, fmPOS.CurSaleList);
  Self.lStatus.Visible := True;
  if not debugmode then
  begin
    AuthTimeOutTimer.Interval := 60000;
    AuthTimeOutTimer.Enabled := True;
  end;
  fmPOS.SendCreditMessage(CCMsg);
end;

procedure TfmNBSCCForm.VCIReceived(const pVCI : pValidCardInfo);
begin
  //ShowMessage('TfmNBSCCForm.VCIReceived function'); // madhu remove
  if assigned(Self.FVCI) then
  begin
    if Self.FVCI.CardNo <> pvci.CardNo then
    begin
      ZeroMemory(Self.FVCI, sizeof(TValidCardInfo));
      dispose(Self.FVCI);
      new(Self.FVCI);
      FVCI^ := pVCI^;
    end;
  end
  else
  begin  // FVCI not assigned
    new(Self.FVCI);
    // copy reference counted strings over so we don't lose the ref counts when pVCI is disposed of later
    FVCI^ := pVCI^;
  end;
  Self.ProcessVCI();
end;

procedure TfmNBSCCForm.ClearCardInfo();
begin
  //showmessage('TfmNBSCCForm.ClearCardInfo();');  // madhu remove
  ScrubForm;
  if assigned (Self.FVCI) then
  begin
    ZeroMemory(Self.FVCI, sizeof(TValidCardInfo));
    dispose(Self.FVCI);
  end;
  if assigned (Self.FPayList) then
  begin
    Self.FPayList.Free;
    Self.FPayList := nil;
  end;
  Self.FVCI := nil;
  Self.FAuthSent := False;
  Self.leCardNo.PasswordChar := #0;
end;

procedure TfmNBSCCForm.PPAuthInfoReceived(      Sender        : TObject;
                                          const PinPadAmount  : currency;
                                          const PinPadMSRData : string;
                                          const PINBlock      : string;
                                          const PINSerialNo   : string);
begin
   fmPOS.EMV_Received_33_03 := True;
  //ShowMessage('TfmNBSCCForm.inside PPAuthInfoReceived function'); // madhu remove
  if (PINBlock <> '') and (PINSerialNo <> '') then
    if assigned(FVCI) then
    try
      Self.FVCI^.PinBlock := PINBlock;
      Self.FVCI^.PinKSN := PinSerialNo;
    except
      on E: Exception do
      begin
        DumpTraceBack(E,5);
      end;
    end;
  if (pos(FS, PinPadMSRData) > 0) then
    if assigned(FVCI) then
      try
        Self.FVCI^.EMVAuth := PinPadMSRData;
      except
        on E: Exception do
        begin
          UpdateZLog('TfmNBSCCForm.ProcessCredit - %s - %s', [E.ClassName, E.Message]);
          UpdateExceptLog('TfmNBSCCForm.ProcessCredit - %s - %s', [E.ClassName, E.Message]);
          DumpTraceBack(E,5);
        end;
      end;
      //ShowMessage('inside PPAuthInfoReceived function and call Self.SendCardAuth;'); // madhu remove
  Self.SendCardAuth;
end;

procedure TfmNBSCCForm.PPCustomerDataReceived(Sender : TObject; const exittype : TPPEntryExitType; const entrytype : TPPEntry; const entry : string);
var
  i : integer;
  f : boolean;
begin
 //ShowMessage('inside PPCustomerDataReceived function'); // madhu remove
  f := False;
  for i := 0 to pred(Self.ControlCount) do
    if (Controls[i].Tag = ord(entrytype)) then
      if Controls[i] is TPOSLabeledEdit then
      begin
        TPOSLabeledEdit(Controls[i]).Text := entry;
        f := True;
        break;
      end;
  if not f then
    UpdateExceptLog('TfmNBSCCForm.PPCustomerDataReceived - got entrytype %d and cannot find it on form', [ord(entrytype)])
  else
  begin
    case entrytype of
      ppeVehicleNo : bGotVehicleNo := True;
      ppeDriverID : bGotDriverID := True;
      ppeID : bGotId := True;
      ppeOdometer : bGotOdometer := True;
      ppeZipCode : bGotZipCode := True;
      else
      begin
        UpdateZLog('Got entrytype %d and do not know how to mark it', [ord(entrytype)]);
      end;
    end;
    Self.CheckEntries;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string);
  {$IFDEF DEV_PIN_PAD}
var
  bContinueProcessing : boolean;
  FSAmount : currency;
  PinTimeout : integer;
  DefaultPINPadMsgNo : integer;
  PromptToReIssue : integer;
  PINFKeySelect : integer;
  {$ENDIF}
  {$IFDEF FUEL_PRICE_ROLLBACK}
  cCheckCardType : string;
  {$ENDIF}
begin
  {$IFDEF FUEL_PRICE_ROLLBACK}
  // If selecting a payment type (for non-partial tenders), then verify that
  // card type qualifies for the any fuel prices on the sales list.
  if ((nAmount > 0.0) and (nAmount = nCurAmountDue) and
      ((sKeyType = 'CDT') or
       (sKeyType = 'DBT') or
       (sKeyType = 'ATM') or
       (sKeyType = 'EBF') or
       (sKeyType = 'EBC') or
       (sKeyType = 'EBV')   )) then
  begin
    case fmPOS.PinCreditSelect of
    PIN_CREDIT :
      begin
        cCheckCardType := CardType;
      end;
    PIN_DEBIT :
      begin
        cCheckCardType := CT_DEBIT;
      end;
    PIN_EBT_FS, PIN_EBT_VO :
      begin
        cCheckCardType := CT_EBT_FS;
      end;
    PIN_EBT_CB :
      begin
        cCheckCardType := CT_EBT_CB;
      end;
    else
      begin
        if (sKeyType = 'ATM') then
          cCheckCardType := CT_DEBIT
        else
          cCheckCardType := '';
      end;
    end;  // case
    //20070615a
//    if (fmPOS.AdjustFuelPriceForTender(nAmount, CREDIT_MEDIA_NUMBER, cCheckCardType)) then
//    begin
//      ChargeAmount := nCurAmountDue;  // amount due could have changed in above adjustment.
//    end
//    else
    if (not fmPOS.AdjustFuelPriceForTender(nAmount, CREDIT_MEDIA_NUMBER, cCheckCardType)) then
    //20070615a
    begin
      // Due to fuel price difference, clerk indicated desire not to continue with tender.
      close;
      exit;
    end;
  end;
  {$ENDIF}

  if sKeyType = 'CLR' then
  begin
    if Self.ActiveControl is TPOSLabeledEdit then
      with TPOSLabeledEdit(Self.ActiveControl) do
        if (Text = '') or not Editable then
          if Self.ActiveControl = Self.leCardNo then
            close
          else
            Self.SelectNext(Self.ActiveControl, False, True)
        else
          Text := '';
  end
  else if sKeyType = 'BSP' then
    PostMessage(Self.ActiveControl.Handle, WM_KEYDOWN, VK_BACK, 0)
  else if sKeyType = 'NUM' then
  begin
    if (Self.ActiveControl = Self.leCardNo) and (EntryType <> 'M') then
      EntryType := 'M';
    UpdateZLog('Posting keydown for number to %s', [Self.ActiveControl.Name]);
    PostMessage(Self.ActiveControl.Handle, WM_KEYDOWN, ord(sKeyVal[1]), 0);
  end
  else if sKeyType = 'ENT' then
  begin
    if Self.ActiveControl is TPOSLabeledEdit and (length(TPOSLabeledEdit(Self.ActiveControl).Text) > 0) then
    begin
      if Self.ActiveControl = Self.leExpDate then
        fmPOS.QueryValidCard(VC_RET_NBSCC_PROCESSKEY,'','', Self.leCardNo.Text, Self.leExpDate.Text, 'M')
      else
        Self.SelectNext(Self.ActiveControl, True, True);
    end;
  end
  else if sKeyType = 'PMP' then        {Pump Number}
    fmPOS.ProcessKeyPMP(sKeyVal, sPreset)
  else if sKeyType = 'PAT' then        {Pump Authorize}
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PAL' then        {Pump Authorize All}
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'EHL' then        { Emergency Halt }
    fmPOS.ProcessKeyEHL
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL
  else if sKeyType = 'OVR' then        { Override check authorization }
  begin
    fmNBSCCForm.Visible := False;
    bTempLogon := True;
    fmUser.ShowModal;
    bTempLogon := False;
    fmNBSCCForm.Visible := True;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.CheckServiceCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.CheckServiceCode;
var
nSCode : integer;
begin
  try
    nSCode := StrToInt(ServiceCode);
  except
    nSCode := 0;
  end;
  ServiceCode := Format('%3.3d',[nSCode]);
end;

{$IFDEF FF_PROMO}
function TfmNBSCCForm.ValidFuelFirstCard() : boolean;
var
  ReturnValue : boolean;
begin
  ReturnValue := (Trim(FVCI^.CardNo) = FuelFirstCardNoUsed);
  if (not ReturnValue) then
    fmPOS.POSError('Fuel First card does not match sales transaction.');
  ValidFuelFirstCard := ReturnValue;
end;
{$ENDIF}

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidRefNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmNBSCCForm.ValidRefNo : boolean;
var
RetCode : boolean;
begin
  CardError := ERR_REFNO;
  if length(leRefNo.Text) > 15 then
    RetCode := false
  else
    Retcode := true;
  ValidRefNo := RetCode;

end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidDriverID
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmNBSCCForm.ValidDriverID : boolean;
var
RetCode : boolean;
NoLen   : short;
begin

  NoLen := length(leDriverID.Text);
  RetCode := False;
  CardError := ERR_DRIVERID;
  if bGotDriverID then
  begin
    if NoLen = 0 then
      RetCode := True
    else
    begin
      if FVCI^.CardType = CT_FLEETONE then
        begin
          if NoLen = 4 then
            begin
              RetCode := True;
            end;
        end
      else if FVCI^.CardType = CT_WEX then
        begin
          if (NoLen = 4) or (NoLen = 6) then
          begin
            RetCode := True;
          end;
        end
      //bpf...
      else if FVCI^.CardType = CT_MC_FLEET then
        RetCode := True
      else if FVCI^.CardType = CT_VISA_FLEET then
        RetCode := True
      else if FVCI^.CardType = CT_VOYAGER then
        begin
          if (NoLen >= 1) and (NoLen <= 6) then
            begin
              RetCode := True;
            end;
        end;
    end;
  end;
  ValidDriverID := RetCode;

end;

function TfmNBSCCForm.ValidID : boolean;
var
  RetCode : boolean;
  NoLen   : short;
begin
  if bGotId then
  begin
    NoLen := length(leID.Text);
    if nolen = 0 then
      RetCode := True
    else
    begin
      RetCode := False;
      CardError := ERR_DRIVERID;
      if FVCI^.CardType = CT_FLEETONE then
        begin
          if NoLen = 4 then
            begin
              RetCode := True;
            end;
        end
      else if FVCI^.CardType = CT_WEX then
        begin
          if (NoLen = 4) or (NoLen = 6) then
          begin
            RetCode := True;
          end;
        end
      //bpf...
      else if FVCI^.CardType = CT_MC_FLEET then
        RetCode := True
      else if FVCI^.CardType = CT_VISA_FLEET then
        RetCode := True
      else if FVCI^.CardType = CT_VOYAGER then
        begin
          if (NoLen >= 1) and (NoLen <= 6) then
            begin
              RetCode := True;
            end;
        end
      else if FVCI^.CardType = CT_NPC then
        if (NoLen = 4) then RetCode := True;
    end;
  end
  else RetCode := False;
  ValidID := RetCode;

end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidOdometer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmNBSCCForm.ValidOdometer : boolean;
var
  Ret : boolean;
begin
  if bgotOdometer then
  begin
    CardError := ERR_ODOMETER;
    if length(leOdometer.Text) > 7 then
      Ret := false
    else
      Ret := true;
  end
  else
    Ret := False;
  ValidOdometer := Ret;

end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidVehicleNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmNBSCCForm.ValidVehicleNo : boolean;
const
  MIN_VEHCILE_NO_DIGITS = 1;  //20071114a (replace with checks below for (NoLen >= 1))
  MAX_VEHICLE_NO_DIGITS = 6;  //20071114a (replace with checks below for (NoLen <= 5))
var
RetCode : boolean;
NoLen   : short;
begin
  if bGotVehicleNo then
  begin
    NoLen := length(leVehicleNo.Text);
    if NoLen = 0 then
      RetCode := True
    else
    begin
      RetCode := False;
      CardError := ERR_VEHICLENO;
      //53h...
      //  if CardType = CT_WEX then
      if (fmPOS.PinCreditSelect = PIN_EBT_VO) then
      begin
        CardError := 'Invalid Voucher Number';
        RetCode := (NoLen > 0);
      end
      //...20041220
      else if FVCI^.CardType = CT_WEX then
      //...53h
        begin
          if (NoLen >= MIN_VEHCILE_NO_DIGITS) and (NoLen <= MAX_VEHICLE_NO_DIGITS) then
            begin
              RetCode := True;
            end;
      //bpf...
        end
      else if FVCI^.CardType = CT_MC_FLEET then
        begin
          if (NoLen >= MIN_VEHCILE_NO_DIGITS) and (NoLen <= MAX_VEHICLE_NO_DIGITS) then
            begin
              RetCode := True;
            end;
      //...bpf
      //53l...
        end
      else if FVCI^.CardType = CT_VISA_FLEET then
        begin
          if (NoLen >= MIN_VEHCILE_NO_DIGITS) and (NoLen <= MAX_VEHICLE_NO_DIGITS) then
            begin
              RetCode := True;
            end;
      //...53l
        end;
    end;
  end
  else
    RetCode := False;
  ValidVehicleNo := RetCode;

end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidRestrictionCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmNBSCCForm.ValidRestrictionCode : boolean;
begin
  ValidRestrictionCode := True;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ValidZIPCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
//53l...
function TfmNBSCCForm.ValidZIPCode : boolean;
var
  RetCode : boolean;
  NoLen   : short;
begin
  if bGotZipCode then
  begin
    NoLen := Length(leZipCode.Text);
    RetCode := ((NoLen = 5) or (NoLen = 9));
    CardError := ERR_ZIPCODE;
  end
  else
    RetCode := False;
  ValidZIPCode := RetCode;

end;
//...53l

procedure TfmNBSCCForm.ProcessCreditMsg(const msg : widestring);
var
  Action : integer;
  resp : pCreditResponseData;
begin
  //ShowMessage('inside ProcessCreditMsg function'); // madhu remove
  Action :=  StrToIntDef(GetTagData(TAG_MSGTYPE, Msg), 0);
  case Action of
   CC_FINALIZE_AUTH_RESP, CC_AUTHRESP, CC_COLLECTRESP :
     begin
       resp := DecodeAuthResp(msg);
       if resp.sEMVresp <> '' then
         ProcessEMVAuthResp(resp)
       else
         ProcessAuthResp(resp);
     end;
   CC_AUTHMSG : begin
                  lStatus.Caption := GetTagData(TAG_STATUSSTRING, Msg);
                  lStatus.refresh;
                  if not debugmode then
                  begin
                    AuthTimeOutTimer.Enabled  := False;
                    AuthTimeOutTimer.Interval := 60000;
                    AuthTimeOutTimer.Enabled  := False;
                  end;
                end;
   CC_BALANCERESP : begin
     resp := DecodeAuthResp(msg);
     ProcessBalanceResp(resp);
   end;
  else
    UpdateZLog('TfmNBSCCForm.ProcessCreditMsg - unhandled message');
  end;
end;

procedure TfmNBSCCForm.ProcessBalanceResp(const resp : pCreditResponseData);
var
  i : integer;
begin
  AuthTimeOutTimer.Enabled := False;
  if ((Resp.sCCAuthCode = AC_APPROVAL) or (Resp.sCCAuthCode = AC_ALREADY_ACTIVE)) then
  begin
    rCRD.sCCApprovalCode := Resp.sCCApprovalCode;

    if FVCI^.CardType = CT_GIFT then
    begin
      lStatus.Caption := Format('Balance:  $%.2f   Restriction = %d.', [Resp.nCCBalance1, Resp.iCCGiftRestriction]);

      PriorGiftCardBalance := Resp.nCCBalance1;

      i := Resp.iCCGiftRestriction;
      if ((i > 0) and
         (i <= NUM_GIFT_CARD_RESTRICTION_CODES)) then
        GiftCardRestrictionCode := i
      else if fmPOS.bGiftRestrictions then
        GiftCardRestrictionCode := RC_UNKNOWN
      else
        GiftCardRestrictionCode := RC_NO_RESTRICTION;
    end;
  end;
  Dispose(Resp);
end;

function TfmNBSCCForm.DecodeAuthResp(const msg : widestring) : pCreditResponseData;
var
  j : integer;
  Resp : pCreditResponseData;
begin
  new(Resp);
  InitializeCRD(resp);
  Resp.sMSGType         := GetTagData(TAG_MSGTYPE, Msg);
  Resp.sCCAllowed       := GetTagData(TAG_CHARGEALLOWED, Msg);
  Resp.sCCAuthCode      := GetTagData(TAG_AUTHCODE, Msg);
  Resp.sCCApprovalCode  := GetTagData(TAG_APPROVALCODE, Msg);
  Resp.sCCEntryType     := GetTagData(TAG_ENTRYMETHOD, Msg);
  Resp.sCCBatchNo       := GetTagData(TAG_BATCHNO, Msg);
  Resp.sCCSeqNo         := GetTagData(TAG_SEQNO, Msg);
  Resp.sCCPumpLimit     := GetTagData(TAG_PUMPDOLLARLIMIT, Msg);
  Resp.sCCRefNo         := GetTagData(TAG_REFERRALNO, Msg);
  Resp.sCCReaderNo      := GetTagData(TAG_READERNO, Msg);
  Resp.nCCAuthID        := StrToIntDef(GetTagData(TAG_AUTHID, Msg), CC_AUTHID_UNKNOWN);
  Resp.sCCCPSData       := GetTagData(TAG_CPSDATA, Msg);
  Resp.sCCAuthMsg       := GetTagData(TAG_AUTHRESPMSG, Msg);
  Resp.sCCTime          := GetTagData(TAG_AUTHTIME, Msg);
  Resp.sCCDate          := GetTagData(TAG_AUTHDATE, Msg);
  Resp.sCCRetrievalRef  := GetTagData(TAG_RETRIEVALREF, Msg);
  Resp.sCCAuthNetID     := GetTagData(TAG_AUTHNETID, Msg);
  Resp.sCCTraceAuditNo  := GetTagData(TAG_TRACEAUDITNO, Msg);
  Resp.sCCAuthAmount    := GetTagData(TAG_AUTHAMOUNT, Msg);
  Resp.sEMVresp         := GetTagData(TAG_EMVRESP, Msg);
  for j := low(Resp.sCCPrintLine) to high(Resp.sCCPrintLine) do
    Resp.sCCPrintLine[j] := GetTagData(IntToStr(nTAG_PRINT_LINE_1 - 1 + j), Msg);

  Resp.nCCBalance1      := StrToCurrDef(GetTagData(TAG_BALANCE, Msg), UNKNOWN_BALANCE);
  Resp.nCCBalance2      := StrToCurrDef(GetTagData(TAG_BALANCE_2, Msg), UNKNOWN_BALANCE);
  Resp.nCCBalance3      := StrToCurrDef(GetTagData(TAG_BALANCE_3, Msg), UNKNOWN_BALANCE);
  Resp.nCCBalance4      := StrToCurrDef(GetTagData(TAG_BALANCE_4, Msg), UNKNOWN_BALANCE);
  Resp.nCCBalance5      := StrToCurrDef(GetTagData(TAG_BALANCE_5, Msg), UNKNOWN_BALANCE);
  Resp.nCCBalance6      := StrToCurrDef(GetTagData(TAG_BALANCE_6, Msg), UNKNOWN_BALANCE);
  Resp.nCCRequestType   := StrToIntDef(GetTagData(TAG_REQUEST_TYPE, Msg), RT_UNKNOWN);
  Resp.sCCAuthorizer    := GetTagData(TAG_AUTHORIZER,   Msg);

  Result := Resp;
end;

procedure TfmNBSCCForm.ProcessAuthResp(const resp : pCreditResponseData);
var
  j : integer;
  iRespAuthID : integer;
  gd : pGiftCardData;
  s : string;
  r : TJclStrStrHashMap;
  skipclose : boolean;
  cvmperf, cvmcond, cvmres : byte;
begin
  AuthTimeOutTimer.Enabled := False;
  Self.FAuthSent := False;
  POSButtonsNBSCC[15].KeyType := '';
  POSButtonsNBSCC[15].KeyVal  := '';
  POSButtonsNBSCC[15].Caption := '';

  if (FVCI^.CardType = CT_GIFT) then
    GiftCardBalance := Resp.nCCBalance1
  else
    GiftCardBalance := UNKNOWN_BALANCE;

  lStatus.Caption := 'Auth Code ' + Resp.sCCAuthCode + ' ' + Resp.sCCApprovalCode;


  if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD, CDTSRV_NBS]) then
  begin
    if (Resp.sCCAllowed = CA_NORMALAUTH) then
    begin
      // approved
    end
    else if (Resp.sCCAllowed = CA_AUTH_REVERSE) then
    begin
      fmPOS.POSError(Resp.sCCPrintLine[1]);
    end
    else
    begin
      //53o...
      rCRD.sCCCardType     := FVCI^.CardType;
      rCRD.sCCCardNo       := FVCI^.CardNo;
      rCRD.sCCExpDate      := FVCI^.ExpDate;
      rCRD.sCCCardName     := FVCI^.CardName;
      for j := low(Resp.sCCPrintLine) to high(Resp.sCCPrintLine) do
        rCRD.sCCPrintLine[j] := Resp.sCCPrintLine[j];
      rCRD.sCCAuthMsg      := Resp.sCCAuthMsg;
      if (FVCI^.CardType = CT_GIFT) then
      begin
        ChargeAmount := 0;  // (todo - verify) Does this go here?
        s := GiftAuthCodeToStr(Resp.sCCAuthCode);
        if (Resp.sCCAuthCode = AC_NOT_ACTIVATED) then
          GiftCardStatus := CS_INACTIVE;
        fmPOS.POSError(s);
      end
      else
      begin
        fmPOS.POSError(Resp.sCCAuthMsg);
      end;
      // Card was declined.  Start a new transaction number to avoid duplicate transaction on a retry.
      j := curSale.nTransNo;
      fmPOS.AssignTransNo();
      // This needs reset so it does not ask below to capture signature
      SwipedCreditNeedsSignature := False;
      UpdateZLog('ProcessCredit - nCurTransNo updated from %d to %d', [j, curSale.nTransNo]);
      FCurrentTransNo := 0;
    end;
  end
  else if (Resp.sCCAuthCode = '00') then
  begin
  end
  else if (FVCI^.CardType = CT_GIFT) then
  begin
    ChargeAmount := 0;  // (todo - verify) Does this go here?
    s := GiftAuthCodeToStr(Resp.sCCAuthCode);
    if (Resp.sCCAuthCode = AC_NOT_ACTIVATED) then
      GiftCardStatus := CS_INACTIVE;
    fmPOS.POSError(s);
  end
  else
  //Gift
  if Resp.sCCAuthCode = '02' then
  begin
    if NOT bGetApproval then
    begin
      s := 'Call Center - ' + Resp.sCCRefNo;
      fmPOS.POSError(s);
      //bGetApproval := True;
      //lStatus.Caption := s;
      //PostMessage(fmNBSCCForm.Handle, WM_CHECKKEY, LongInt('Z'), 0);
      //exit;
    end;
  end
  else
  begin
    fmPOS.POSError(Resp.sCCAuthMsg);
    if fmNBSCCForm.Handle <> GetActiveWindow then
      SetActiveWindow (fmNBSCCForm.Handle) ;
  end;

  //DSG
  if Resp.sCCAuthCode <> '00' then
  begin
    with POSDataMod.IBTempQuery do
    begin
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      close;SQL.Clear;
      SQL.Add('Select DiscNo from CCValidCards where CardType = :pCardType and StartISO <= :pISO and EndISO >= :pISO');
      parambyname('pCardType').AsString := FVCI^.CardType;
      parambyname('pISO').AsString := copy(FVCI^.CardNo,1,6);
      open;
      {$IFDEF FUEL_PRICE_ROLLBACK}
      if ((FieldByName('DiscNo').AsInteger > 0) and (FieldByName('DiscNo').AsInteger <> CASH_EQUIV_FUEL_DISC_NO)) then
      {$ELSE}
      if fieldbyname('DiscNo').AsInteger > 0 then
      {$ENDIF}
        {$IFDEF CASH_FUEL_DISC}
        DropGiftFuelDiscount('DSG');
        {$ELSE}
        DropGiftFuelDiscount;
        {$ENDIF}
      Close;
      Transaction.Commit;
    end;
  end;
  rCRD.semvresp := resp.sEMVresp;
  rCRD.sEMVauthCFM := resp.sEMVauthCFM;

  
  // Determine if response was successful.
  // Note:  There are two types of credit reversals ("during" and "after").
  //        A "successful" response for a "during" credit reversal actually results
  //        in an unsuccessful media authorization.  On the "after" credit reversal,
  //        the original authorization was already processed, so another "successful"
  //        transaction is needed to cancel out the original authorization.
  //        An "after" credit reversal in indicated by GC_VOID_~.
  //        if (RespAllowed = '1') or (RespAllowed = '2') or (RespAllowed = '3')then
  if ((Resp.sCCAllowed = CA_NORMALAUTH     ) or
      (Resp.sCCAllowed = CA_NETWORKFALLBACK) or
      (Resp.sCCAllowed = CA_MODEMFALLBACK  ) or
      //bpd...
   //            ((RespAllowed = CA_AUTH_REVERSE) and (GiftCardUsage = GC_VOID_CREDIT))) then
      ((Resp.sCCAllowed = CA_AUTH_REVERSE))) then
      //...bpd
  begin
    rCRD.sCCAuthCode     := Resp.sCCAuthCode;
    rCRD.sCCApprovalCode := Resp.sCCApprovalCode;
    rCRD.sCCCardType     := FVCI^.CardType;
    rCRD.sCCCardNo       := FVCI^.CardNo;
    rCRD.sCCExpDate      := FVCI^.ExpDate;
    rCRD.sCCCardName     := FVCI^.CardName;
    rCRD.sCCBatchNo      := Resp.sCCBatchNo;
    rCRD.sCCSeqNo        := Resp.sCCSeqNo;
    rCRD.sCCEntryType    := EntryType;
    rCRD.sCCOdometer     := leOdometer.Text;
    rCRD.sCCVehicleNo    := leVehicleNo.Text;
    rCRD.sCCCPSData      := Resp.sCCCPSData;
    rCRD.sCCTime         := Resp.sCCTime;
    rCRD.sCCDate         := Resp.sCCDate;
    rCRD.sCCRetrievalRef := Resp.sCCRetrievalRef;
    rCRD.sCCAuthNetID    := Resp.sCCAuthNetID;
    rCRD.sCCTraceAuditNo := Resp.sCCTraceAuditNo;
    rCRD.sCCAuthorizer   := Resp.sCCAuthorizer;
    rCRD.nCCBalance1     := Resp.nCCBalance1;
    rCRD.nCCBalance2     := Resp.nCCBalance2;
    rCRD.nCCBalance3     := Resp.nCCBalance3;
    rCRD.nCCBalance4     := Resp.nCCBalance4;
    rCRD.nCCBalance5     := Resp.nCCBalance5;
    rCRD.nCCBalance6     := Resp.nCCBalance6;
    //bp...
    rCRD.sCCVehicleNo    := leVehicleNo.Text; //bpwex
    for j := low(Resp.sCCPrintLine) to high(Resp.sCCPrintLine) do
      rCRD.sCCPrintLine[j] := Resp.sCCPrintLine[j];
    rCRD.sCCAuthMsg      := Resp.sCCAuthMsg;
    //...53o
    rCRD.nCCRequestType := Resp.nCCRequestType;
    iRespAuthID := Resp.nCCAuthID;
    if (iRespAuthID = CC_AUTHID_UNKNOWN) then
    begin
      // AuthID is sometimes used as a unique field, so calculate another value.
      iRespAuthID := - ((Round(Frac(Now()) * 100000.0) mod 100000) * 10000);
      if (Resp.sCCBatchNo <> '') then
      begin
        iRespAuthID := iRespAuthID - (100 * StrToInt(Resp.sCCBatchNo));
      end;
      if (Resp.sCCSeqNo <> '') then
      begin
        iRespAuthID := iRespAuthID - StrToInt(Resp.sCCSeqNo);
      end;
    end;
    rCRD.nCCAuthID := iRespAuthID;
    rCRD.PaidItems := Self.FPayList;
    Self.FPayList := nil;  // hand off responsibility for this memory to rCRD processor.
    //53o...
     //          if (CardType = CT_DEBIT) and (DebitCashBackAmount > 0) then
    if ((FVCI^.CardType = CT_DEBIT) {or (FVCI^.CardType = CT_EBT_FS)} or (FVCI^.CardType = CT_EBT_CB)) and (DebitCashBackAmount > 0) then
    //...53o
    begin
      ChargeAmount := ChargeAmount + DebitCashBackAmount;
    end
    //Gift
    else if (FVCI^.CardType = CT_GIFT) then
    begin
      // Gift card authorizations could be reduced due balance depletion
      // or product restrictions.  The amount could also be increased for
      // cashing out an almost depleted card balance.
      if (Resp.sCCAuthAmount <> '') then
        ChargeAmount := StrToCurr(Resp.sCCAuthAmount);
      if (GiftCardBalance <> UNKNOWN_BALANCE) then
      begin
        if (GiftCardBalance > 0) then
          GiftCardStatus := CS_STILL_ACTIVE
        else GiftCardStatus := CS_DEPLETED;
      end;
      // Save information about gift card usage (to be printed on receipt)
      new(gd);
      gd^.FaceValue       := fmNBSCCForm.GiftCardBalance;
      gd^.PriorValue      := fmNBSCCForm.PriorGiftCardBalance;
      gd^.RestrictionCode := fmNBSCCForm.GiftCardRestrictionCode;
      gd^.CardStatus      := fmNBSCCForm.GiftCardStatus;
      gd^.HostApprovalCode := rCRD.sCCApprovalCode;  //20060622
      strPcopy(gd^.CardNo, copy(FVCI^.CardNo, 1, Min(Length(FVCI^.CardNo), SIZE_CARDNO-1)));
      qClient^.GiftCardUsedList.Capacity := qClient^.GiftCardUsedList.Count;
      qClient^.GiftCardUsedList.Add(gd);
    end
    else // if CardType = ...
    begin
      // Check for partial authorization (for example with Visa or MasterCard gift cards with depleted balances).
      if (Resp.sCCAuthAmount <> '') then
        ChargeAmount := StrToCurr(Resp.sCCAuthAmount);
    //...20071029a
    end;
    rCRD.nChargeAmount := ChargeAmount;
    rCRD.mediarestrictioncode := FVCI^.mediarestrictioncode;
    //Gift
    Authorized   := 1;
  end;
  // If pin pad configured, then notify it about the authorization response.
 // ShowMessage('before : if (fmPos.PPTrans <> nil) and fmPos.PPTrans.PinPadOnLine and fmPos.PPtrans.Enabled then'); // madhu remove
  if (fmPos.PPTrans <> nil) and fmPos.PPTrans.PinPadOnLine and fmPos.PPtrans.Enabled then
  begin
    if (not (FVCI^.cardsource in [csSalesList, csThinAir])) then
    begin
      fmPos.PPTrans.PINPadAuthResponse((Authorized = 1), rCRD.nCCAuthID, Resp.sCCApprovalCode, Resp.sCCAuthMsg);
    end;
  end;
  //dmb...
  //close;
  if ((Resp.sCCAllowed = CA_INVALID_PIN) and (PINEntryAttempts < Setup.MAXInsidePINAttempts) and
  (bPINPadActive > 0)) then
  begin
    {$IFDEF DEBUG}
    //UpdateExceptLog('ProcessCredit back to PIN prompt - FCardNo=' + fmPOS.MaskCardNumber(FCardNo));  // cdebugx
    {$ENDIF}  //DEBUG
    // Only problem seems to be a PIN entry and number tries not exceded.  Allow another attempt.
    Inc(PINEntryAttempts);
    {$IFDEF DEV_PIN_PAD}
    FSAmount := fmPOS.AdjustFoodStampChargeAmount(ChargeAmount, CardType);
    CreditPromptFlags := PINPAD_PROMPT_PIN;  // only reprompt for PIN
    {$ELSE}
    {$ENDIF}
  end
  else
  begin
    skipclose := False;
    if (resp.sEMVauthCFM <> '') then
    begin
      skipclose := True;
      if (resp.sEMVauthCFM <> '') then
         r:=ExtractIngTags(resp.sEMVauthCFM)
      else
         r:= ExtractIngTags(resp.sEMVresp);
      cvmperf := strToInt('$' + copy(r.GetValue(EMV_CVMRES), 2, 2));
      cvmcond := strToInt('$' + copy(r.GetValue(EMV_CVMRES), 4, 2));
      cvmres  := strToInt('$' + copy(r.GetValue(EMV_CVMRES), 6, 2));
      case cvmperf and $3f of
        CVM_SIG, CVM_PTPIN_ICC_SIG, CVM_ENPIN_ICC_SIG : begin
          if cvmres = CVMRES_UNK then // pin pad doesn't know if the signature worked, so wait on it from the pinpad
          begin
            //fmPos.PPTrans.SendSignatureRequest('Hey VJ, Sign for this transaction');
          end;
        end;
        $06..$1d : begin
          UpdateZLog('Reserved value %02x returned for CVM Method', [cvmperf and $3f]);
          close();
        end;
      else
        close();  // Remaining options are fail and PIN based checks
      end;
      r.Free;
    end;
    if (SwipedCreditNeedsSignature) then
    begin
       skipclose := True;
       fmPos.PPTrans.SendSignatureRequest('Please Sign');
    end;
    if not skipclose then
    begin
      // Close credit screen (unless waiting for a signature from pin pad).
      if (FVCI^.cardsource in [csSalesList, csThinAir]) then
      begin
        close();
      end
      else if ((fmPOs.PPTrans = nil) or (not fmPOS.PPTrans.PinPadOnLine) or (not fmPOS.PPTrans.Enabled) or (Authorized <> 1) or
          (FVCI^.PinBlock <> '') or (FVCI^.CardType = CT_GIFT)) then
      begin
        close();
      end
      else if (Abs(ChargeAmount) < fmPos.PPTrans.PinPadCreditSignatureLimit) or fmPos.PPTrans.SignatureCaptured then
      begin
        close();
      end;
    end;
  end;
  Dispose(Resp);
  //...dmb
end;

procedure TfmNBSCCForm.ProcessEMVAuthResp(const resp : pCreditResponseData);
begin
  //ShowMessage('inside :ProcessEMVAuthResp function'); // madhu remove
  // We have to duplicate the code in the ProcessAuthResp because 
  // if this apporoved and
  // Check OnlineT99Switch = True and set OnlinePINVerified
  if (resp.sCCAuthCode = '00') then
  begin
     if fmPOS.OnlineT99Switch = True then
     begin
        fmPOS.OnlinePINVerified := True;  
     end;
  end
  else if fmPOS.OnlineT99Switch = True then
     begin
        if (resp.sCCAuthMsg <> 'INVALID ID') then  //It was declined but not because of Invalid PIN
        begin
           fmPOS.OnlinePINVerified := True;  
        end;
     end;
  
  fmpos.PPTrans.SendEMVAuthResponse(resp);
end;

procedure TfmNBSCCForm.OnlinePINTryExceeded();
begin
   fmPOS.OnlineT99Switch := False;
   fmPOS.OnlinePINVerified := False;
   fmPOS.EMV_Received_33_03 := False;
   // need to close the form and 
   close();
end;

procedure TfmNBSCCForm.ProcessEMVAuthCFM(const resp: pCreditResponseData);
var
  k : String;
  r : TJclStrStrHashMap;
  respcode, msg : string;
  EMV_ERROR_CODE : String;
  DeclineSent : String;
  

  function GetCardType(pType : Integer) : String;
  var
     rrSult : String;
  begin
     rrSult := '';
     if (pType = 2) or (pType = 3) or (pType = 5) or (pType = 7) or (pType = 16) or (pType = 51) or (pType = 72) then
        rrSult := 'BC'
     else if (pType = 4) or (pType = 50) or (pType = 82) or (pType = 83) then
        rrSult := 'DC'
     else if (pType = 11) or (pType = 12) then
        rrSult := 'WI'
     else if (pType = 6) then
        rrSult := 'DM'
     else if (pType = 74) or (pType = 75) or (pType = 76) then
        rrSult := 'FM';
     Result := rrSult;
  end;
  
  procedure SendReversal_Void(pReason : String);
  var
     reqid : Integer;
     msg : String;
     msg54 : String;
     T2E : String;
     SCT : String;
  begin
       reqid := RandomRange(1, 9999);
       reqid := 10000 + reqid;
       reqid := 9999;
       //<999>84|<13>02|<10>2623|<411>ICC DECLINE
       //TAG_MSGTYPE = 999
       //TAG_CARDTYPE = 13
       //TAG_AUTHID = 10
       //TAG_EMV_REASON = 411
       //In that case, the Auth Ref and CPS Data fields would be empty and the card info would be the track 2 equivalent data obtained from the chip since 
       //they would have no ECAB info (you need an approval response to receive ECAB info).
       try SCT := GetCardType(StrToInt(FVCI^.CardType)); except SCT := ''; end;
       if (resp.sCCAuthCode = '00') then
       begin
          msg := BuildTag(TAG_MSGTYPE, IntToStr(CC_VOID)) +
                 BuildTag(TAG_CARDTYPE, FVCI^.CardType) +
                 BuildTag(TAG_AUTHID, IntToStr(resp.nCCAuthID)) +
                 BuildTag(TAG_EMV_REASON, pReason);
           fmPos.CCSendMsg(msg, self.ProcessEMVVoid);
       end
       else
       begin
          // If we have not processed the 33.03 then we will send just a generic Void/Reversal
          // ***** IF we have spun the bin
          // We must have Self.FVCI to perform this step
          Try
             
             if (fmPOS.EMV_Received_33_03 = False) and (assigned(Self.FVCI)) and (SCT <> '')then
             begin
                T2E := FVCI^.CardNo + '=' + Copy(FVCI^.ExpDate,3,2) + Copy(FVCI^.ExpDate,1,2);
                msg54 :=   'A' + FS_CHAR + copy(IntToStr(reqid),2,4) + FS_CHAR + '54' + FS_CHAR + SCT + FS_CHAR + '0' + FS_CHAR + '0' + FS_CHAR +  'S' + FS_CHAR + '2C' + FS_CHAR + T2E + FS_CHAR +
                         TrimRight(FormatFloat('###,###.00 ;###,###.00-',fmPOS.PPTrans.PinPadAmount)) + FS_CHAR + '' + FS_CHAR + '' + FS_CHAR;
                msg := BuildTag(TAG_MSGTYPE, IntToStr(CC_VOID54)) +
                       BuildTag(TAG_CARDTYPE, FVCI^.CardType) +
                       BuildTag(TAG_CCHOST, '3') +
                       BuildTag('VOID54DATA', msg54);
                fmPos.CCSendMsg(msg, self.ProcessEMVVoid);
             end;
          Except
             on E : Exception do
             begin
                UpdateZLog('Error extracting Track 2 Equivalent to send for Void 54 - ' + E.Message);
             end;         
          End;
       end;
  end;

  
begin

  // do we have the information ????


  
 // ShowMessage('inside  TfmNBSCCForm.ProcessEMV_AuthCFM function'); // madhu remove
  k := resp.sEMVauthCFM;
  if Copy(k,length(k) - 1,1) <> cFS then
      k := k + cFS;
  r:=ExtractIngTags(k);
  respcode := r.GetValue(ING_CNF_RESPCODE);
  EMV_ERROR_CODE := r.GetValue('D1010');
  EMV_ERROR_CODE := copy(EMV_ERROR_CODE,2,Length(EMV_ERROR_CODE) - 1);
  r.Destroy();
//  ShowMessage('inside  TfmNBSCCForm.ProcessEMV_AuthCFM function and respcode[2]:'+respcode[2]); // madhu remove

// CDIV  with E
//   WE NEED TO HANDLE A respcode[2] = 'D'  DECLINED differently
//   We also need to    CRPRE   = REMOVED
//                      
// when we implement quick chip we cannot handle this as is

  // must update SwipeCheckCount in case we have not received a 33.03 yet
  if (fmPOS.EMV_Received_33_03 = False) then
     fmPOS.PPTrans.SwipeCheckCount := fmPOS.PPTrans.SwipeCheckCount + 1;
  if (respcode[2] = 'E') then
  begin
     if (fmPOS.PPTrans.InvalidPIN_Entered = True) then
     begin
        fmPOS.PPTrans.SendOnline();
        fmPOS.OnlineT99Switch := False;
        fmPOS.OnlinePINVerified := False;
        fmPOS.EMV_Received_33_03 := False;
        if (fmPOS.PPTrans.SendEMV_FALLBACK() = False) then
        begin
           // do something in case of non fallback  ????   
        end;
        fmPOS.RedisplaySalesItemsToPinPad();
        fmPOS.ReComputeSaleTotal(false);
        fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
        fmPOS.SendSetAmount(fmPOS.PPTrans);
     end
     else if (EMV_ERROR_CODE = 'CNSUP') then
     begin
        fmPOS.POSError('Invalid Card!!!');
        fmPOS.PPTrans.SendOnline();
        fmPOS.OnlineT99Switch := False;
        fmPOS.OnlinePINVerified := False;
        fmPOS.EMV_Received_33_03 := False;
        if (fmPOS.PPTrans.SendEMV_FALLBACK() = False) then
        begin
           // do something in case of non fallback  ????   
        end;
        fmPOS.RedisplaySalesItemsToPinPad();
        fmPOS.ReComputeSaleTotal(false);
        fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
        fmPOS.SendSetAmount(fmPOS.PPTrans);
     end
     else if (EMV_ERROR_CODE = 'APBLK') then
     begin
        fmPOS.POSError('Invalid Card!!!');
        fmPOS.OnlineT99Switch := False;
        fmPOS.OnlinePINVerified := False;
        fmPOS.EMV_Received_33_03 := False;
        ProcessEMVDecline(resp);
     end
     else if (EMV_ERROR_CODE = 'CDIV') then
     begin
        // This is a card not supported so we need to reset
        // We should not have received any 33 messages prior to this so we need to display the error and have them try another card
        if (fmPOS.PPTrans.InvalidPIN_Entered = True) then
        begin
           //ProcessEMVDecline(resp);
           fmPOS.PPTrans.SendOnline();
           fmPOS.OnlineT99Switch := False;
           fmPOS.OnlinePINVerified := False;
           fmPOS.EMV_Received_33_03 := False;
           if (fmPOS.PPTrans.SendEMV_FALLBACK() = False) then
           begin
              // do something in case of non fallback  ????   
           end;
           fmPOS.RedisplaySalesItemsToPinPad();
           fmPOS.ReComputeSaleTotal(false);
           fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
           fmPOS.SendSetAmount(fmPOS.PPTrans);
        end
        else
        begin
          //ProcessEMVDecline(resp);
          fmPOS.POSError('Invalid Card!!!');
          fmPOS.PPTrans.SendOnline();
          fmPOS.OnlineT99Switch := False;
          fmPOS.OnlinePINVerified := False;
          fmPOS.EMV_Received_33_03 := False;
          if (fmPOS.PPTrans.SendEMV_FALLBACK() = False) then
          begin
             // do something in case of non fallback  ????   
          end;
          fmPOS.RedisplaySalesItemsToPinPad();
          fmPOS.ReComputeSaleTotal(false);
          fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
          fmPOS.SendSetAmount(fmPOS.PPTrans);
        end;
     end
     else if (EMV_ERROR_CODE = 'CRPRE') or (EMV_ERROR_CODE = 'CAN') then
     begin
        fmPOS.POSError('Transaction Prematurely Cancelled!!!');
        //if (resp.nCCAuthID > 0) then
        SendReversal_Void('REMOVED');
        fmPOS.PPTrans.SendOnline();
        fmPOS.OnlineT99Switch := False;
        fmPOS.OnlinePINVerified := False;
        fmPOS.EMV_Received_33_03 := False;
        if (fmPOS.PPTrans.SendEMV_FALLBACK() = False) then
        begin
           // do something in case of non fallback  ????   
        end;
        fmPOS.RedisplaySalesItemsToPinPad();
        fmPOS.ReComputeSaleTotal(false);
        fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
        fmPOS.SendSetAmount(fmPOS.PPTrans);
     end;
  end
  else if (respcode[2] = 'D') and (resp.sCCAuthMsg = 'CALL CENTER') then
  begin
     fmPOS.POSError('Call Issuer!!!');
     ProcessEMVDecline(resp);
     fmPOS.OnlineT99Switch := False;
     fmPOS.OnlinePINVerified := False;
     fmPOS.EMV_Received_33_03 := False;
  end
  else  if (respcode[2] = 'D') then
  begin
     SendReversal_Void('ICC DECLINE');
     // in all cases of a decline we will need to print a receipt
     // this is a basic receipt just like the PrintEBTDecline
     // It will move the current sale list to a receipt list
     // it will move the emv stuff as well
     // then it will print declined
     fmPOS.POSError('Declined!!!');
     fmPOS.OnlineT99Switch := False;
     fmPOS.OnlinePINVerified := False;
     fmPOS.EMV_Received_33_03 := False;
     ProcessEMVDecline(resp);
  end
  else
  if (respcode[2] = 'A') or (respcode[2] = 'C') or (resp.sCCAuthCode <> '00') then
  begin
    ProcessAuthResp(resp);
  end
  else
  begin
    //if (resp.nCCAuthID > 0) then
    SendReversal_Void('ICC DECLINE');
  end;
end;


procedure TfmNBSCCForm.ProcessEMVDecline(const resp : pCreditResponseData);
var
  j : integer;
  iRespAuthID : integer;
  gd : pGiftCardData;
  s : string;
  r : TJclStrStrHashMap;
  skipclose : boolean;
  cvmperf, cvmcond, cvmres : byte;
  IsVerifiedPIN : Boolean;

begin
  //ShowMessage('inside ProcessAuthResp function'); // madhu remove
  
  try
    AuthTimeOutTimer.Enabled := False;
    Self.FAuthSent := False;
    rCRD.semvresp := resp.sEMVresp;
    rCRD.sEMVauthCFM := resp.sEMVauthCFM;
    rCRD.sCCAuthCode     := Resp.sCCAuthCode;
    rCRD.sCCApprovalCode := Resp.sCCApprovalCode;
    rCRD.sCCCardType     := FVCI^.CardType;
    rCRD.sCCCardNo       := FVCI^.CardNo;
    rCRD.sCCExpDate      := FVCI^.ExpDate;
    rCRD.sCCCardName     := FVCI^.CardName;
    rCRD.sCCBatchNo      := Resp.sCCBatchNo;
    rCRD.sCCSeqNo        := Resp.sCCSeqNo;
    rCRD.sCCEntryType    := EntryType;
    rCRD.sCCOdometer     := leOdometer.Text;
    rCRD.sCCVehicleNo    := leVehicleNo.Text;
    rCRD.sCCCPSData      := Resp.sCCCPSData;
    rCRD.sCCTime         := Resp.sCCTime;
    rCRD.sCCDate         := Resp.sCCDate;
    rCRD.sCCRetrievalRef := Resp.sCCRetrievalRef;
    rCRD.sCCAuthNetID    := Resp.sCCAuthNetID;
    rCRD.sCCTraceAuditNo := Resp.sCCTraceAuditNo;
    rCRD.sCCAuthorizer   := Resp.sCCAuthorizer;
    rCRD.nCCBalance1     := Resp.nCCBalance1;
    rCRD.nCCBalance2     := Resp.nCCBalance2;
    rCRD.nCCBalance3     := Resp.nCCBalance3;
    rCRD.nCCBalance4     := Resp.nCCBalance4;
    rCRD.nCCBalance5     := Resp.nCCBalance5;
    rCRD.nCCBalance6     := Resp.nCCBalance6;
    rCRD.sCCVehicleNo    := leVehicleNo.Text;
    for j := low(Resp.sCCPrintLine) to high(Resp.sCCPrintLine) do 
      rCRD.sCCPrintLine[j] := Resp.sCCPrintLine[j];
    rCRD.sCCAuthMsg      := Resp.sCCAuthMsg;
    rCRD.nCCRequestType := Resp.nCCRequestType;
    rCRD.nCCAuthID := iRespAuthID;
    rCRD.PaidItems := Self.FPayList;
    rCRD.nChargeAmount := ChargeAmount;
    rCRD.mediarestrictioncode := FVCI^.mediarestrictioncode;
    // Now I should be able to print the receipt
    IsVerifiedPIN := False;
    if (resp.sEMVauthCFM <> '') then
    begin
       r := ExtractINGTags(resp.sEMVauthCFM);
  
       if r.ContainsKey(PIN_ENTRY_VERIFIED ) then
          IsVerifiedPIN := True;
    end;
    fmPOS.PrintEMVDeclinedReceipt(IsVerifiedPIN);
    try
    Dispose(Resp);
    except
       on E : Exception do
       begin
          UpdateZLog('ProcessEMVDecline Error Dispose(Resp)');
       end;
    end;
    //...dmb
  except
     on X : Exception do
     begin
        UpdateZLog('ProcessEMVDecline Error : ' + X.Message);
     end
  end;
  // need to close the form and 
     close();
end;

procedure TfmNBSCCForm.SetOnlineT99Switch();
begin
   fmPOS.OnlineT99Switch := True;
end;

procedure TfmNBSCCForm.ProcessEMVVoid(const msg : string);
begin
  // we will need to print the receipt
  // this is a requirement for passing certification
  close();
  fmPOS.POSError('ICC Declined');
end;

procedure TfmNBSCCForm.ShowMustUseEMV;
begin
  //ClearCardInfo();
  fmPOS.POSError('Chip/PIN card!!!  Please Insert instead of Swipe!!!!');
  //fmPOS.PPTrans.SendEMV_FALLBACK();
  fmPOS.ReComputeSaleTotal(false);
  fmPOS.RedisplaySalesItemsToPinPad();
  fmPOS.SendSetTransactionType(fmPOS.PPTrans);    
  fmPOS.SendSetAmount(fmPOS.PPTrans);
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.FormatSalesData
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    string
  Purpose:   
-----------------------------------------------------------------------------}
function TfmNBSCCForm.FormatSalesData(salelist : TNotList; const authid : integer; const mr : longword) : string;
var
  sSalesData : TStringList;
  CurSaleData : pSalesData;
  pNdx, ndx, i : integer;
  iPrice, iQty, iExtPrice : currency;
  tmpdpt : integer;
  //bpa...
  tmpAmount : currency;
  //...bpa
  r : pSalesSummaryData;
  cpflist, ssdlist : TList;
begin
  tmpdpt := 0;
  if authid = CC_AUTHID_UNKNOWN then
    cpflist := CanPayFor(mr, salelist)
  else
    cpflist := salelist;
  ssdlist := TList.Create;

  for Ndx := 0 to pred( cpflist.Count ) do
  begin
    CurSaleData := cpflist.Items[Ndx];
    if Authid = CC_AUTHID_UNKNOWN then
      tmpAmount := NeedsPayment( CurSaleData )
    else
      tmpAmount := PaidForWithAuthID( CurSaleData, AuthID );
    {$IFDEF DEBUG}
    updateZLog('  %2d %2d %30.30s  %.2g', [ ndx, CurSaleData.SeqNumber, CurSaleData.Name, tmpAmount ]);
    {$ENDIF}
    if tmpAmount <> 0 then
    begin
      iPrice := CurSaleData^.Price;
      iQty := CurSaleData^.Qty;
      iExtPrice := tmpAmount;
      if CurSaleData^.LineType = 'DPT' then
        tmpdpt := Trunc(CurSaleData^.Number)
      else if ( CurSaleData^.LineType = 'PLU' ) or ( CurSaleData^.LineType = 'DSC' ) then
        tmpdpt := CurSaleData^.DeptNo
      else if CurSaleData^.LineType = 'FUL' then
        tmpdpt := Trunc(CurSaleData^.Number)
      else if CurSaleData^.LineType = 'TAX' then
      begin
        tmpdpt := 88;
        iPrice := tmpAmount;
        iQty := 1;
      end
      else if (CurSaleData^.LineType = 'PPY') or (CurSaleData^.LineType = 'PRF') then
      begin
        FuelAmount := FuelAmount + tmpAmount;
        tmpdpt := 998;
      end
      else
        UpdateExceptLog('Failed to find a dept to assign line %d to', [ Ndx ] );

      i := -1;
      if ssdlist.Count > 0 then
        for pNdx := 0 to pred( ssdlist.Count ) do
          if ( pSalesSummaryData( ssdlist[pNdx] ).Dept = tmpdpt) then
          begin
            i := pNdx;
            break;
          end;
      if i = -1 then
      begin
        new(r);
        zeromemory(r, sizeof( TSalesSummaryData ) );
        r.Dept      := TmpDpt;
      end
      else
        r := pSalesSummaryData( ssdlist[i] );

      if CurSaleData^.LineType = 'FUL' then
      begin
        r.FuelDept := True;
        FuelAmount := FuelAmount + tmpAmount;
      end
      else
      begin
        if CurSaleData^.ExtPrice > 0 then
          NonFuelAmount := NonFuelAmount + tmpAmount
        else
          FuelAmount := FuelAmount + tmpAmount;
      end;
      r.UnitPrice := Abs(iPrice);
      r.Qty       := r.Qty + Abs( iQty );
      r.ExtAmount := r.ExtAmount + Abs( iExtPrice );
      if i = -1 then
        ssdlist.add( r );
    end;
  end;

  if ssdlist.Count > 0 then
    for pNdx := 0 to pred( ssdlist.count ) do
    begin
      r := pSalesSummaryData( ssdlist[pNdx] );
      if (r^.Dept > 0) and (r^.Qty > 0) then
        if NOT r^.FuelDept then
          if r^.UnitPrice <> POSRound((r^.ExtAmount / r^.Qty), 2) then
          begin
            r^.UnitPrice := POSRound((r^.ExtAmount / r^.Qty), 2);
            if POSRound((r^.UnitPrice * r^.Qty),2) <> r^.ExtAmount then
            begin
              r^.UnitPrice := r^.ExtAmount;
              r^.Qty := 1;
            end;
          end;
    end;

  sSalesData := TStringList.Create();
  if ssdlist.Count > 0 then
    for pNdx := 0 to pred( ssdlist.count ) do
    begin
      r := pSalesSummaryData( ssdlist[pNdx] );
      sSalesData.Add(format('%3.3d %.3g %.3g %.3g', [ r^.Dept, r^.UnitPrice, r^.Qty, r^.ExtAmount ]));
    end;

  FormatSalesData := JCLStringListStrings(sSalesData).Join(',');
  sSalesData.Destroy();

  DisposeTListItems( ssdlist );
  ssdlist.Free;

  if authid = CC_AUTHID_UNKNOWN then
    cpflist.free;

end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.GetSalePumpNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    integer
  Purpose:
-----------------------------------------------------------------------------}
function TfmNBSCCForm.GetSalePumpNo: integer;
var
  PumpNo : integer;
  ndx : integer;
  CurSaleData : pSalesData;
begin
  UpdateZLog('TfmNBSCCForm.GetSalePumpNo');

  PumpNo := 0;
  for Ndx := 0 to (fmPos.CurSaleList.Count - 1) do
    begin
      CurSaleData := fmPos.CurSaleList.Items[Ndx];
      //if (CurSaleData^.LineType = 'FUL') and (CurSaleData^.LineVoided = False) then
      if ((CurSaleData^.LineType = 'FUL') or (CurSaleData^.LineType = 'PPY') or (CurSaleData^.LineType = 'PRF')) and
                                                                                  (CurSaleData^.LineVoided = False) then
      
      begin
        PumpNo := CurSaleData^.PumpNo;
        break;
      end;
    end;

  GetSalePumpNo := PumpNo;

end;

procedure TfmNBSCCForm.ScrubForm;
var
  i : integer;
begin
  for i := 0 to pred(Self.ControlCount) do
    if Self.Controls[i] is TPOSLabeledEdit then
      with TPOSLabeledEdit(Self.Controls[i]) do
      begin
        Editable := False;
        Text := '';
        Visible := False;
      end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.ResetLabels
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.ResetLabels;
begin
  ScrubForm;
  if fmPOS.RefNo <> '' then
    leRefNo.Text := fmPOS.RefNo;
  if fmPOS.DriverID <> '' then
    leDriverID.Text := fmPOS.DriverID;
  if fmPOS.Odometer <> '' then
    leOdometer.Text := fmPOS.Odometer;
  if fmPOS.ZIPCode <> '' then
    leZipCode.Text := fmPOS.ZIPCode;

  leApprovalCode.editLabel.Caption  := 'Approval Code';
  leCardNo.EditLabel.Caption    := 'Card Number';
  leVehicleNo.EditLabel.Caption := 'Vehicle Number';

  lStatus.Caption := '';
  KeyBuff := '';
  BuffPtr := 0;

  if assigned(POSButtonsNBSCC[15]) then
  begin
    POSButtonsNBSCC[15].KeyType   := 'ENT';
    POSButtonsNBSCC[15].KeyVal := '';
    POSButtonsNBSCC[15].Caption := 'Enter';
  end;

  Self.leCardNo.Visible := True;
  Self.leCardNo.Editable := True;
  Self.leExpDate.Visible := True;
  Self.leExpDate.Editable := True;

  Self.ActiveControl := Self.leCardNo;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearCardInfo;
  if assigned(fmPOS.PPTrans) and (fmPOS.PPTrans.Enabled) and (fmPOS.PPTrans.PinPadOnLine) then
  begin
    fmPOS.PPTrans.SendOnline();
  end;
  EntryType := '';
  AuthTimeOutTimer.Enabled := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.BuildTouchPad;
var
nRowNo : short;
nColNo : short;
nBtnNo : short;
begin
 //ShowMessage('TfmNBSCCForm.BuildTouchPad - enter'); // madhu remove
  UpdateZLog('TfmNBSCCForm.BuildTouchPad - enter');
  nBtnNo := 1;
  for nRowNo := 1 to 5 do
    for nColNo := 1 to 3 do
    begin
      BuildKeyPad(nRowNo, nColNo, nBtnNo );
      Inc(nBtnNo);
    end;
  SetNumberPad;
  KeyPadID := mKeyPadUnknown;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.BuildkeyPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.BuildkeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin
  if screen.width = 800 then
    TopKeyPos := 48
  else
    TopKeyPos := 64;
  if POSButtonsNBSCC[BtnNdx] = nil then
  begin
    POSButtonsNBSCC[BtnNdx]         := TPOSTouchButton.Create(fmNBSCCForm);

    POSButtonsNBSCC[BtnNdx].Parent  := fmNBSCCForm;
    POSButtonsNBSCC[BtnNdx].Name    := 'CreditButton' + IntToStr(BtnNdx);
  end;

  if screen.width = 1024 then
  begin
    POSButtonsNBSCC[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 65);
    POSButtonsNBSCC[BtnNdx].Left     := ((ColNo - 1) * 65) + 500;
    POSButtonsNBSCC[BtnNdx].Height     := 60;
    POSButtonsNBSCC[BtnNdx].Width      := 60;
    POSButtonsNBSCC[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  end
  else
  begin
    POSButtonsNBSCC[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 50);
    POSButtonsNBSCC[BtnNdx].Left     := ((ColNo - 1) * 50) + 375;
    POSButtonsNBSCC[BtnNdx].Height     := 47;
    POSButtonsNBSCC[BtnNdx].Width      := 47;
    POSButtonsNBSCC[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
  end;
  POSButtonsNBSCC[BtnNdx].KeyRow     := RowNo;
  POSButtonsNBSCC[BtnNdx].KeyCol     := ColNo;
  POSButtonsNBSCC[BtnNdx].Visible    := True;
  POSButtonsNBSCC[BtnNdx].OnClick    := CCButtonClick;
  POSButtonsNBSCC[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtonsNBSCC[BtnNdx].FrameStyle := bfsNone;
  POSButtonsNBSCC[BtnNdx].WordWrap   := True;
  POSButtonsNBSCC[BtnNdx].Tag        := BtnNdx;
  POSButtonsNBSCC[BtnNdx].NumGlyphs  := 14;
  POSButtonsNBSCC[BtnNdx].Frame      := 8;
  POSButtonsNBSCC[BtnNdx].KeyPreset  := '';
  POSButtonsNBSCC[BtnNdx].MaskColor  := fmNBSCCForm.Color;

  POSButtonsNBSCC[BtnNdx].Font.Color :=  clBlack;
  POSButtonsNBSCC[BtnNdx].Frame := 11;

  (*case BtnNdx of
  (*15 :
      begin
        POSButtonsNBSCC[BtnNdx].KeyType   := 'ENT';
        POSButtonsNBSCC[BtnNdx].KeyVal := '';
        POSButtonsNBSCC[BtnNdx].Caption := 'Enter';
      end;
  14 :
      begin
        POSButtonsNBSCC[BtnNdx].KeyType   := 'BSP';
        POSButtonsNBSCC[BtnNdx].KeyVal := '';
        POSButtonsNBSCC[BtnNdx].Caption := 'Back Space';
      end;
  13 :
      begin
        POSButtonsNBSCC[BtnNdx].KeyType   := 'CLR';
        POSButtonsNBSCC[BtnNdx].KeyVal := '';
        POSButtonsNBSCC[BtnNdx].Caption := 'Clear';
      end;
  10, 12 :
      begin
        POSButtonsNBSCC[BtnNdx].KeyType   := '';
        POSButtonsNBSCC[BtnNdx].KeyVal := '';
        POSButtonsNBSCC[BtnNdx].Caption := '';
        POSButtonsNBSCC[BtnNdx].Visible  := False;
      end;
  else
    begin
      POSButtonsNBSCC[BtnNdx].KeyType := 'NUM - Number';
      POSButtonsNBSCC[BtnNdx].KeyVal  := KeyTops[BtnNdx];
      POSButtonsNBSCC[BtnNdx].Caption  := KeyTops[BtnNdx];
    end;
  end;*)
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetNumberPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetNumberPad;
var
BtnNdx : short;
begin
  for BtnNdx := 1 to 15 do
  begin
    case BtnNdx of
      15 :
          begin
            POSButtonsNBSCC[BtnNdx].Visible := True;
            POSButtonsNBSCC[BtnNdx].KeyType   := 'ENT';
            POSButtonsNBSCC[BtnNdx].KeyVal := '';
            POSButtonsNBSCC[BtnNdx].Caption := 'Enter';
          end;
      14 :
          begin
            POSButtonsNBSCC[BtnNdx].Visible := True;
            POSButtonsNBSCC[BtnNdx].KeyType   := 'BSP';
            POSButtonsNBSCC[BtnNdx].KeyVal := '';
            POSButtonsNBSCC[BtnNdx].Caption := 'Back Space';
          end;
      13 :
          begin
            POSButtonsNBSCC[BtnNdx].Visible := True;
            POSButtonsNBSCC[BtnNdx].KeyType   := 'CLR';
            POSButtonsNBSCC[BtnNdx].KeyVal := '';
            POSButtonsNBSCC[BtnNdx].Caption := 'Clear';
          end;
      10, 12 :
          begin
            POSButtonsNBSCC[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSButtonsNBSCC[BtnNdx].Visible  := True;
          POSButtonsNBSCC[BtnNdx].KeyType  := 'NUM - Number';
          POSButtonsNBSCC[BtnNdx].KeyVal   := KeyTops[BtnNdx];
          POSButtonsNBSCC[BtnNdx].Caption  := KeyTops[BtnNdx];
        end;
    end;
  end;
  KeyPadID := mKeyPadNumber;
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetClearPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetClearPad;
var
  BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
  try
    case BtnNdx of
    5 :
        begin
          POSButtonsNBSCC[BtnNdx].Visible := True;
          POSButtonsNBSCC[BtnNdx].KeyType   := 'CLR';
          POSButtonsNBSCC[BtnNdx].KeyVal := '';
          POSButtonsNBSCC[BtnNdx].Caption := 'Clear';
        end;
    10, 12 :
        begin
          POSButtonsNBSCC[BtnNdx].Visible  := False;
        end;
    else
      begin
        POSButtonsNBSCC[BtnNdx].Visible  := False;
      end;
    end;
  except
    on E: Exception do
      UpdateExceptLog('TfmNBSCCForm.SetClearPad BtnNdx %d - Exception %s - %s', [BtnNdx, E.ClassName, E.Message]);
  end;
  KeyPadID := mKeyPadClear;
end;

procedure TfmNBSCCForm.SetBlankPad;
var
  BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
  try
    POSButtonsNBSCC[BtnNdx].Visible  := False;
  except
    on E: Exception do
      UpdateExceptLog('TfmNBSCCForm.SetNoPad BtnNdx %d - Exception %s - %s', [BtnNdx, E.ClassName, E.Message]);
  end;
  KeyPadID := mKeyPadNone;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.CCButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.CCButtonClick(Sender: TObject);
var
  sKeyType, sKeyVal, sPreset : string;
begin

  if (Sender is TPOSTouchButton) then
    begin
      sKeyType := TPOSTouchButton(Sender).KeyType ;
      sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
      sPreset  := TPOSTouchButton(Sender).KeyPreset ;
      UpdateZLog('NBSCC.CCButtonClick - keytype %s', [sKeyType]);
      ProcessKey(leftstr(sKeyType,3), sKeyVal, sPreset);
    end;
  //20050126
  FormClick(self);
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.FormCreate(Sender: TObject);
begin
  Self.lPinPadStatus.Caption := '';
  Self.leCardTypeName.Editable := False;
  Self.FPayList := nil;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.AuthTimeOutTimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.AuthTimeOutTimerTimer(Sender: TObject);
begin
    //53g...
//    CreditAuthToken := 200;
    //CreditAuthToken := CA_HANDLE_TIMEOUT;
    //...53g
    PostMessage(fmNBSCCForm.Handle, WM_CREDITMSG, 0, 0);
  AuthTimeOutTimer.Enabled := False;
  UpdateExceptLog('Auth timed out');
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetSinAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetSinAmount(Value : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetSinAmount');
  FSinAmount := Value;
end;

procedure TfmNBSCCForm.SetVoidTransNo(Value : integer);
begin
  UpdateZLog('TfmNBSCCForm.SetVoidTransNo');
  FVoidTransNo := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetFuelAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetFuelAmount(Value : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetFuelAmount');
  FFuelAmount := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetNonFuelAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetNonFuelAmount(Value : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetNonFuelAmount');
  FNonFuelAmount := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetAuthorized
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetAuthorized(Value : integer);
begin
  UpdateZLog('TfmNBSCCForm.SetAuthorized');
  FAuthorized := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetChargeAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetChargeAmount(Value : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetChargeAmount');
  FChargeAmount := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetTaxAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetTaxAmount(Value    : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetTaxAmount');
  FTaxAmount := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.SetAmountDue
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.SetAmountDue(Value    : currency);
begin
  UpdateZLog('TfmNBSCCForm.SetAmountDue');
  FAmountDue := Value;
end;

procedure TfmNBSCCForm.CheckEntries();
var
  c : boolean;
  pending : boolean;
  mr : longword;
  ReceiptErrorMsg, detailmsg : pReceiptErrorMsg;
begin
  //ShowMessage('inside CheckEntries function'); // madhu remove
  {$IFDEF DEBUG}
  UpdateZLog('TfmNBSCCForm.CheckEntries - %p', [Self.FVCI]);
  UpdateZLog('TfmNBSCCForm.CheckEntries - Enter  GetZIPCode %s, GetDriverID %s, GetOdometer %s, GetRefNo %s, GetVehicleNo %s, GetID %s',
             [BoolToStr(FVCI^.bGetZIPCode, True),BoolToStr(FVCI^.bGetDriverID, True),BoolToStr(FVCI^.bGetOdometer, True),BoolToStr(FVCI^.bGetRefNo, True),BoolToStr(FVCI^.bGetVehicleNo, True),BoolToStr(FVCI^.bGetID, True)]
             );
  UpdateZLog('TfmNBSCCForm.CheckEntries - Enter  GotZIPCode %s, GotDriverID %s, GotOdometer %s, GotRefNo %s, GotVehicleNo %s, GotID %s',
             [BoolToStr(bGotZipCode, True), BoolToStr(bGotDriverID,True), BoolToStr(bGotOdometer, True), BoolToStr(bGotRefNo,True), BoolToStr(bGotVehicleNo,True), BoolToStr(bGotID,True)]);
  {$ENDIF}
  FPayList := CanPayFor(FVCI.mediarestrictioncode, FSalesList); // determine what this cardtype can pay for
  ChargeAmount := min(Self.ChargeAmount, SalesTotal(FPayList)); // reduce charge amount to smaller of entered amount or above calculation
  //ChargeAmount  :=  1;  // MADHU GV  27-10-2017   CHECK REMOVE
  if ChargeAmount = 0.0 then
  begin
    mr := FVCI.mediarestrictioncode;
    ModalResult := mrAbort;
    authorized := 0;
    New(ReceiptErrorMsg);
    ReceiptErrorMsg.Text := 'No amount qualifies due to media restrictions';
    New(DetailMsg);
    DetailMsg.Text := Format('Restrictions: %s', [RestrictionCodeToString(mr)]);
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
    PostMessage(fmPOS.Handle, WM_RECEIPTERRORMSG, LongInt(DetailMsg), LongInt(ReceiptErrorMsg));
    ClearCardInfo();
  end
  else
  begin
     //ShowMessage('inside CheckEntries function and else if ChargeAmount <> 0.0 then'); // madhu remove
    // FIXME : These should prompt through pinpad if available
    c := True;
    pending := False;
    if c and FVCI^.bGetZIPCode then
      c := Self.ValidZIPCode();
    if not c and FVCI^.bGetZIPCode then
    begin
      Self.ActiveControl := Self.leZipCode;
      pending := True;
      fmPOS.PPTrans.GetZip;
    end;

    if not pending then
    begin
      if c and FVCI^.bGetID then
      begin
        c := ValidID();
        {$IFDEF DEBUG}UpdateZLog('ValidID: %s', [BoolToStr(c,True)]);{$ENDIF}
      end;
      if not c and FVCI^.bGetID then
      begin
        Self.ActiveControl := Self.leID;
        pending := True;
        fmPOS.PPTrans.GetID;
      end;
    end;

    if not pending then
    begin
      if c and FVCI^.bGetDriverID then
      begin
        c := ValidDriverID();
        {$IFDEF DEBUG}UpdateZLog('ValidDriverID: %s', [BoolToStr(c,True)]);{$ENDIF}
      end;
      if not c and FVCI^.bGetDriverID then
      begin
        Self.ActiveControl := Self.leDriverID;
        pending := True;
        fmPOS.PPTrans.GetDriverID;
      end;
    end;

    if not pending then
    begin
      if c and FVCI^.bGetOdometer then
      begin
        c := Self.ValidOdometer();
        {$IFDEF DEBUG}UpdateZLog('ValidOdometer: %s', [BoolToStr(c,True)]);{$ENDIF}
      end;
      if not c and FVCI^.bGetOdometer then
      begin
        Self.ActiveControl := Self.leOdometer;
        pending := True;
        fmPOS.PPTrans.GetOdometer;
      end;
    end;

    if c and FVCI^.bGetRefNo then
      c := Self.ValidRefNo();
    if not c and FVCI^.bGetRefNo then
      Self.ActiveControl := Self.leRefNo;

    if not pending then
    begin
      if c and FVCI^.bGetVehicleNo then
      begin
        c := Self.ValidVehicleNo();
        {$IFDEF DEBUG}UpdateZLog('ValidVehicleNo: %s', [BoolToStr(c,True)]);{$ENDIF}
      end;
      if not c and FVCI^.bGetVehicleNo then
      begin
        Self.ActiveControl := Self.leVehicleNo;
        //Pending := True;
        fmPOS.PPTrans.GetVehicleNo;
      end;
    end;
    if c then
    begin
      if (fmPos.PPTrans <> nil) then
      begin
        fmPos.PPTrans.PINPadAmount := fmNBSCCForm.ChargeAmount
      end
      else
      begin
        SendCardAuth;
      end;
    end
    else
      UpdateZLog('TfmNBSCCForm.CheckEntries - waiting on %s', [Self.ActiveControl.Name]);
  end;
end;


procedure TfmNBSCCForm.ProcessVCI();
  procedure showcontrol(c : TControl);
  begin
    TPOSLabeledEdit(c).Visible := True;
    TPOSLabeledEdit(c).Enabled := True;
  end;
var
  i : integer;
  leavekeypad : boolean;
begin
  //FVCI^.ServiceCode
  //FVCI^.CardType
  //ShowMessage('inside TfmNBSCCForm.ProcessVCI - CardSource: function'); // madhu remove
  {$IFDEF DEBUG}
  UpdateZLog('TfmNBSCCForm.ProcessVCI - CardSource: %s', [CardSourceToText(FVCI^.cardsource)]);
  {$ENDIF}
  Self.ActiveControl := nil;
  leavekeypad := false;
  for i := 0 to pred(Self.ControlCount) do
    if Self.Controls[i] is TPOSLabeledEdit then
      TPOSLabeledEdit(Self.Controls[i]).Editable := False;
  Self.leCardNo.PasswordChar := '*';
  Self.leCardNo.Text := FVCI^.CardNo;   // madhu plz=check for value assign  24-11-2017m
  Self.leExpDate.Text := FVCI^.ExpDate;
  if (length(FVCI^.CardName) > 0) then
  begin
    Self.leCardName.Text := FVCI^.CardName;
    Self.leCardName.Enabled := True;
    Self.leCardName.Visible := True;
  end;
  Self.leCardNo.Editable := False;
  Self.leExpDate.Editable := False;
  // FIXME - These should be asked for at the PINPad if available
  if FVCI^.bGetDriverID then
    showcontrol(Self.leDriverID);
  if FVCI^.bGetOdometer then
    showcontrol(Self.leOdometer);
  if FVCI^.bGetRefNo then
    Self.leRefNo.Editable := True;
  if FVCI^.bGetVehicleNo then
    showcontrol(Self.leVehicleNo);
  if FVCI^.bGetID then
    showcontrol(Self.leID);
  if FVCI^.bGetZIPCode then
    showcontrol(Self.leZipCode);
  for i := 0 to pred(Self.ControlCount) do
    if Self.Controls[i] is TPOSLabeledEdit then
      leavekeypad := leavekeypad or TPOSLabeledEdit(Self.Controls[i]).Editable;
  if not leavekeypad and Self.Visible then
    Self.SetClearPad;


  
  //FVCI^.cardsource :=   csPINPad;  // MADHU GV  27-10-2017   CHECK
  if (FVCI^.cardsource in [csMSR, csPINPad]) then               // madhu g v 27-10-2017  check the card source
    Entrytype := 'S';
  if (FVCI^.cardsource in [csSalesList, csThinAir]) and (Self.Visible) then
  begin
    Entrytype := 'I';
    SendFinalizeAuth(FVCI^.AuthID, FVCI^.FinalAmount);
  end
  else
    if (FVCI^.cardsource in [csManual, csMSR]) and (not FVCI^.PPCurrent) then
    begin
      if assigned(fmPOS.PPTrans) and fmPOS.PPTrans.PinPadOnLine and fmPOS.PPTrans.Enabled then
      begin
        fmPOS.PPTrans.PinPadAccount := FVCI^.CardNo;
        if FVCI^.ExpDate = '' then
          FVCI^.ExpDate := '1249';
        fmPOS.PPTrans.PinPadExpDate := FVCI^.ExpDate;
        FVCI^.PPCurrent := True;
      end;
    end
    else if Self.Visible then       // madhu gv 27-10-2017  check remove
    begin
      Self.CheckEntries();
    end;
  SwipedCreditNeedsSignature := False;
    // Check For EMV Card Swiped to Set Signature Required if CardType = "05"
    
  //if (FVCI^.ServiceCode = '201') and (FVCI^.CardType = '05') and (Entrytype = 'S') then
  if (FVCI^.ServiceCode = '201') and (FVCI^.CardType = '05') and (fmPos.PPTrans.CheckSignatureEntry = 'S') then
  begin
     SwipedCreditNeedsSignature := True;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.FormShow(Sender: TObject);
begin
  ResetLabels;
  
end;


{-----------------------------------------------------------------------------
  Name:      TfmNBSCCForm.InitialScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TMessage
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmNBSCCForm.InitialScreen();
begin
  //ShowMessage('TfmNBSCCForm.InitialScreen - enter'); // madhu remove
  UpdateZLog('TfmNBSCCForm.InitialScreen - enter');
  AuthTimeOutTimer.Enabled := False;
  FAuthSent := False;
  BuildTouchPad;
  ResetLabels;
  SetNumberPad;

  //53o...
//  CardType      := '';
  // EBT "card types" are actually account types and must be selected at the POS (i.e.,
  // the credit server has no way to determine this information from the track data or
  // card number; therefore, only reset card type for non-EBT cards.
  CardTypeName    := '';
  EntryType     := '';
  ServiceCode   := '';
  CardError     := '';
  UserData      := '';
  UserDataCount := '';

  InitializeCRD(@rCRD);


  bGotRefNo             := False;
  bGotDriverID          := False;
  bGotOdometer          := False;
  bGotVehicleNo         := False;
  bGotZIPCode           := False;
  bGotID                := False;
  bGetApproval          := False;
  bGetDate              := False;
  bRetryDriverID        := False;
  bIgnoreSwipe          := True;
  //dma...  //dmb...
  bDebitBINMngt         := False;
  PINEntryAttempts      := 0;
  //...dma
  bGetRestrictionCode   := False;

  lStatus.Visible := False;
  lStatus.Caption := '';
  BuffPtr := 0;

  ServiceCode := '000';
  bSwipeErrFlag := False;

  DebitCashBackAmount := 0;
end;


procedure TfmNBSCCForm.FormClick(Sender: TObject);
begin
  if fmPOSErrorMsg.Visible then
    SetActiveWindow(fmPOSErrorMsg.Handle);
end;

procedure TfmNBSCCForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  blockaltf4 : boolean;
begin
  if (Self.ActiveControl = Self.leCardNo) and (Key >= 48) and (Key <= 57) then
    UpdateZLog('TfmNBSCCForm.FormKeyDown')
  else
    UpdateZLog('TfmNBSCCForm.FormKeyDown %d ', [Key]);
  if (Key = VK_F4) and (ssAlt in Shift) then
  begin
    try
      blockaltf4 := fmPOS.Config.Bool['CW_BLOCKALTF4'];
    except
      blockaltf4 := False;
    end;
    if blockaltf4 then
    begin
      UpdateZLog('%s: User pressed Alt-F4 - Blocked', [Self.Classname]);
      fmPOS.POSError('Call Support');
      Key := 0;
    end
    else
    begin
      UpdateZLog('%s: User pressed Alt-F4 - Not Blocked', [Self.Classname]);
      Self.ClearCardInfo;
      AlertCSToCancel(FCurrentTransNo);
      fmPOS.POSError('Have you called support?');
    end;
  end;
  if (Key = VK_F7) and (ssAlt in Shift) then
  begin
    UpdateZLog('%s: User pressed Alt-F7 - Closing', [Self.ClassName]);
    Self.ClearCardInfo;
    AlertCSToCancel(FCurrentTransNo);
    Close();
  end;
  if (Self.ActiveControl = Self.leCardNo) and (Key >= 48) and (Key <= 57) then
    Self.EntryType := 'M';
end;

procedure TfmNBSCCForm.tpleEnter(Sender: TObject);
begin
  if Sender is TPOSLabeledEdit then
    with TPOSLabeledEdit(Sender) do
      Color := clMoneyGreen;
end;

procedure TfmNBSCCForm.tpleExit(Sender: TObject);
begin
  if Sender is TPOSLabeledEdit then
    with TPOSLabeledEdit(Sender) do
      Color := clWhite;
end;

procedure TfmNBSCCForm.FormActivate(Sender: TObject);
begin
  Self.SetBounds((Screen.Width - Self.Width) div 2, Screen.Height - Self.Height, Self.Width, Self.Height);
  if assigned(Self.FVCI) then
  begin
    Self.ProcessVCI();
  end;
end;

procedure TfmNBSCCForm.SetCurrentTransNo(const Value: integer);
begin
  FCurrentTransNo := Value;
end;

procedure TfmNBSCCForm.AlertCSToCancel(const TransNo: integer);
var
  CCMsg : widestring;
begin
  CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_KILLAUTH)) +
           BuildTag(TAG_TRANSNO, Format('%6.6d',[TransNo]));
  fmPOS.SendCreditMessage(CCMsg);
end;

procedure TfmNBSCCForm.SetPreauth(const Value: boolean);
begin
  FPreauth := Value;
end;

function TfmNBSCCForm.PPPromptChange(Sender: TObject; const PinPadStatusID,
  PinPadPrompt: string): boolean;
begin
  Self.lPinPadStatus.Caption := ' Pin Pad: ' + Copy(PinPadPrompt, 1, 30);
  Result := True;
end;

function TfmNBSCCForm.PPCardStatusChange(Sender: TObject;
  const CardMediaType: TCardMediaType; const CardVersion: integer;
  const Trantype: TTranType; const CardStatus: TCardStatus): boolean;
begin
  UpdateZLog('%s - %d, %d, %d, %d', [ProcByLevel, ord(CardMediaType), CardVersion, ord(Trantype), ord(CardStatus)]);
  if Self.Visible then
    if (CardMediaType = ctEMV) and (CardStatus = csInserted) then
    begin
      TPINPadTrans(Sender).PINPadAmount := Self.ChargeAmount;
    end;
  Result := True;
end;

procedure TfmNBSCCForm.FormHide(Sender: TObject);
begin
   // do nothing
end;

end.


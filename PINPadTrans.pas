unit PINPadTrans;
{$I ConditionalCompileSymbols.txt}

{
This unit coordinates activities between the POS and the pin pad.
}

interface


uses
  Windows,
  Messages,
  ExtCtrls,
  Classes,
  SyncObjs,
  LatTypes,
  AdPort,
  LoadFileBuffer,
  POSMisc,
  JclHashMaps,
  SerialDev;

const
  {$I CREDITSERVERCONST.INC}
  WM_PIN_PAD_DEV_RESP     = WM_USER + 184;  // Message sent when response received from pin pad device.

  PINPAD_MSG_ID_LEN = 3;  // All msg IDs have same length.

  MAX_PIN_PAD_INPUTS = 2;

  PINPAD_DEFAULT_STATUS_INTERVAL : cardinal = 10000;
  PINPAD_TRANS_STATUS_INTERVAL : cardinal = 1000;

type
  TTriState = (tsUnknown, tsFalse, tsTrue);

  Tpayment = (pt_Debit = 1, pt_Credit, pt_EBTCash, pt_EBTFS, pt_Gift, pt_Loyalty, pt_GiftFuelOnly, pt_uu08,
              pt_uu09, pt_uu10, pt_uu11, pt_uu12, pt_uu13, pt_uu14, pt_uu15, pt_uu16);
  TTransactionType = (mTransTypeUndef, mTransTypeSale, mTransTypeVoid, mTransTypeReturn, mTransTypeVoidReturn);

  IOMsgType = (mIOTypeText, mIOTypeACK, mIOTypeNak, mIOTypeTimeout, mIOTypeError, mIOTypeBadLRC);

  TPPStartupState = (ppssOffline, ppssQueryUnitData, ppssQueryContactless, ppssQueryEncryption,
                     ppssQuerySigMS, ppssQueryEMVSup, ppssQueryEMVCVMMOD, ppssQueryFSIndex,
                     ppssQueryCards, ppssQueryDebit, ppssQuerySTB, ppssQuerySTBTD,
                     ppssQuerySTBCD, ppssQueryAds, ppssSendOnline, ppssSetDate, ppssSetTime,
                     ppssSetAllowedPayments, ppssOnline);

  TPPSupportedModels = (ppsmUnknown, ppsmI6780, ppsmISC250);

  pIOMessage = ^TIOMessage;
  TIOMessage = record
    IOText : string;
    IOType : IOMsgType;
  end;

  pPINPadInput = ^TPINPadInput;
  TPINPadInput = record
    bNeedsValue : boolean;
    InputValue : string;
    InputPromptID : integer;
  end;

  pPinPadDisplayMessage = ^TPinPadDisplayMessage;
  TPinPadDisplayMessage = record
   DisplayTransNo  : integer;
   DisplaySeqNo    : integer;
   DisplayExtPrice : currency;
   DisplayQty      : currency;
   DisplayItemDesc : string;
   DisplayTotalTax : currency;
   DisplayTotalDue : currency;
  end;

  pPPSaleLine = ^TPPSaleLine;
  TPPSaleLine = record
    SeqNo : integer;
    Qty : currency;
    Desc : string[30];
    ExtPrice : currency;
  end;


  TCardInfoReceivedEvent = procedure(      Sender        : TObject;
                                     const PINPadTrack1  : widestring;
                                     const PINPadTrack2  : widestring;
                                     const PINAccountNo  : widestring;
                                     const PINTrack      : widestring;
                                     const EncryptedTrackData: widestring;
                                     const EMVTags : widestring) of object;
  TAuthInfoReceivedEvent = procedure(      Sender        : TObject;
                                     const PinPadAmount  : currency;
                                     const PinPadMSRData : string;
                                     const PINBlock      : string;
                                     const PINSerialNo   : string) of object;
  TSignatureReceivedEvent = procedure(      Sender       : TObject;
                                      const AuthID : integer;
                                      const SigData : string) of object;
  TPinPadPromptChangeEvent = function(      Sender         : TObject;
                                      const PinPadStatusID : string;
                                      const PinPadPrompt   : string) : boolean of object;
  TEntryReceivedEvent  = procedure(      Sender   : TObject;
                                   const exittype : TPPEntryExitType;
                                   const entrytype: TPPEntry;
                                   const entry    : string) of object;
  TPinPadCardStatusEvent = function(      Sender         : TObject;
                                    const CardMediaType : TCardMediaType;
                                    const CardVersion : integer;
                                    const Trantype : TTranType;
                                    const CardStatus : TCardStatus) : boolean of object;

  TPINPadTransaction = class(TComponent)
  private
    { Private declarations }
    PPDev : TEFTDevice;
    FPinPadTransHandle : HWND;
    FWaitClose : boolean;  // used to give "offline" request time to complete before closing port.
    FOnOnlineChange : TNotifyEvent;
    FPinPadOnline : boolean;
    PinPadDisplayQueue : TThreadList;
    PinPadTimer : TTimer;
    LastStatusID : string[2];
    LastStatusPrompt : string;
    FTransNo : integer;
    bNewTransNo : boolean;
    bClearDisplayOnNextTransReset : boolean;
    FPaymentAllowed : Array[TPayment] of boolean;
    FPaymentQualifies : Array[TPayment] of boolean;
    FLastAllowedString : string;
    FbPinPadVoidTransaction : boolean;
    PinPadTransactionType : TTransactionType;
    FPinPadFSAmount : currency;
    FPinPadFuelAmount : currency;
    FPinPadAmount : currency;
    FPinPadAccount : string;
    FPinPadExpDate : string;
    FbBalanceInquiry : boolean;
    FPinPadTrack1 : string;
    FPinPadTrack2 : string;
    FEncryptedTrackData : string;
    FPinPadMSRData : string;
    FPINBlock : string;
    FPINSerialNo : string;
    FPinPadInputCount : integer;
    FPinPadInputs : array [0..MAX_PIN_PAD_INPUTS] of TPINPadInput;
    FLastInput : pPINPadInput;
    PinPadMsgType : string[PINPAD_MSG_ID_LEN];
    FRBAVersion : currency;
    FApplID : string[4];
    FParmID : string[4];
    FReqApplID : string[4];
    FReqParmID : string[4];
    FPOSTransNo : string[4];
    FTermSerialNo : string;
    FTermModel : TPPSupportedModels;
    FAuthSerialNo : string[8];
    FResponseCounter : string[4];
    FAccountNo : string;
    FDirPath : string;
    FFileName : string;
    FLastBlockTime : TDateTime;
    FPinPadPortNo : Integer;
    FPinPadBaudRate : integer;
    FPinPadDataBits : integer;
    FPinPadStopBits : integer;
    FPinPadParity : TParity;
    FPinPadCreditSignatureLimit : currency;
    NewPinPadCreditSignatureLimit : currency;
    bPinPadOpening : boolean;
    AuthorizedAuthID : integer;  // used as key field to store signature data
    SignatureData : string;
    SignatureDataIndex : integer;
    SignatureBlockIndex : integer;
    SignatureBlockHighest : integer;
    FSignatureCaptured : boolean;
    LoadFileBuffer : TLoadFileBuffer;
    LastTransNoDisplayed : integer;
    
    LastTotalTaxDisplayed : currency;
    LastTotalDueDisplayed : currency;
    FCardTypeField : smallint;
    FPinPaymentSelect : integer;
    FLogging : boolean;
    FShowMsg : TShowMsgProc;

    FAdCheckPeriod: integer;
    FLastAdCheck : TDateTime;
    FAdFileList : TStrings;
    FAdDirPath : string;
    FAdDisplayPeriod : Cardinal;
    FAdDisplayTime : TDateTime;
    FAdCurrent : smallint;
    FAdMax : smallint;
    FOnAdMaxChange : TSmallIntNotify;
    FAdsCurrent : TTriState;

    FbSwipePending : boolean;
    FOnSwipeChange : TNotifyEvent;
    FOnlineAttempt : TDateTime;

    FStartupState : TPPStartupState;

    FLastStatus : TDateTime;
    FLastStatusSent : TDateTime;
    FOnlineEvent : TEvent;

    FEnabled : boolean;

    FAdWaitPeriod : integer;     // Time to wait after transaction ends before displaying ads.
    DisplayAdDelta : Double;     // Same as FAdWaitPeriod except in units used by Now() function.
    DisplayAdStart : TDateTime;  // Future time to start displaying ads (zero implies no ads pending).

    RespWaitStart : TDateTime;
    RespWaitMsg : pOutboundMessage;
    LastAct : TDateTime;

    FReceiptLines : integer;
    FTimeoutCount : integer;
    FNAKCount : integer;
    FReg: integer;
    FStore: integer;
    FAdServerURL: string;
    FEntryPrompt: TPPEntry;
    FEnableContactless: boolean;
    FEncryptionEnabled : boolean;
    FTrack: string;
    FEMVEnabled: boolean;
    FOnCardStatusChange: TPinPadCardStatusEvent;
    FMSGBuffer : TJclStrStrHashMap;
    creditresponse : pCreditResponseData;
    FCCSendMsg : TMsgRespRequest;
    FSerialNoChange: TMsgRecEvent;
    function BoolToCharInt(Value : boolean) : char;
    procedure PPDevMsgReceived(Sender : TObject; Buffer : pChar; Count : integer);
    procedure PPDevAckReceived(Sender : TObject; msg : pOutboundMessage);
    procedure PPDevNakReceived(Sender : TObject; Count : integer);
    procedure PPDevTimeoutEvent(Sender : TObject; Count : integer);
    procedure PPDevBadLRCEvent(Sender : TObject);
    procedure PinPadTransMessageHandler(var Msg : TMessage);
    procedure PinPadTimerExpired(Sender : TObject);
    procedure QueuePINPadDisplayItem(const NewSeqNo : integer;
                                     const NewExtPrice : currency;
                                     const NewQty : currency;
                                     const NewItemDesc : string;
                                     const NewTotalTax : currency;
                                     const NewTotalDue : currency);
    procedure ProcessPINPadDisplayQueue();
    procedure ProcessPinPadOffline(const qIOMessage : pIOMessage);
    procedure ProcessPinPadOnline(const qIOMessage : pIOMessage);
    procedure SetDate(const expectresponse : boolean = False);
    procedure SetTime(const expectresponse : boolean = False);
    procedure ProcessPinPadSetPaymentType(const qIOMessage : pIOMessage);
    procedure ProcessPinPadUnitData(const qIOMessage : pIOMessage);
    procedure ProcessPinPadCardStatus(const qIOMessage : pIOMessage);
    procedure ProcessPinPadHardReset(const qIOMessage : pIOMessage);
    procedure ProcessPinPadStatusResponse(const qIOMessage : pIOMessage);
    procedure ProcessPinPadBINLookup(const qIOMessage : pIOMessage);
    function CheckIfSwipedIS_EMV(pCode : String) : Boolean;
    procedure ProcessPinPadSignatureReady(const qIOMessage : pIOMessage);
    procedure ProcessPinPadGetVariableRequest(const qIOMessage : pIOMessage);
    procedure ProcessPinPadPINReady(const qIOMessage : pIOMessage);
    procedure ProcessCardReadResponse(const qIOMessage : pIOMessage);
    procedure ProcessPinPadEMVMessage(const qIOMessage : pIOMessage);
    procedure ProcessPinPadAuthRequest(const qIOMessage : pIOMessage);
    procedure ProcessPinPadConfWrite(const qIOMessage : pIOMessage);
    procedure ProcessPinPadConfRead(const qIOMessage : pIOMessage);
    procedure ProcessPinPadFileWrite(const qIOMessage : pIOMessage);
    procedure ProcessPinPadSendAppl(const qIOMessage : pIOMessage);
    procedure ProcessPinPadSetVar(const qIOMessage : pIOMessage);
    procedure ProcessPinPadEntryReady(const qIOMessage : pIOMessage);
    procedure advancestartup();
    procedure handle_idn_cards(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_sig(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_emv(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_stb(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_ads(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_cless(const idngroup, idnindex : integer; const msg : string);
    procedure handle_idn_security(const idngroup, idnindex : integer; const msg : string);

    procedure SendMessageToDevice(const MsgToSend : string ; const expectresponse : boolean = True);
    procedure SetCardTypeField(const NewCardTypeField : smallint);
    procedure SetTransNo(const TransNo : integer);
    procedure CheckFileTransferStartStop();
    procedure SetPinPadCreditSignatureLimit(const SignatureLimit : currency);
    procedure SetLoadFileDir(const LFDir : string);
    procedure SetPinPadAmount(const cAmount : currency);
    procedure SetPinPadFSAmount(const cAmount : currency);
    procedure SetPinPadAccount(const sAccount : string);
    procedure SetPinPadExpDate(const sExpDate : string);
    procedure SetLoadFileName(const LFName : string);
    procedure SetPinPadOnline(const Value : boolean);
    function GetPinPadInputs(Index : Integer) : pPINPadInput;
    procedure SetPinPadInputs(Index : Integer; Value : pPINPadInput);
    function GetLoggingEnabled() : Boolean;
    procedure SetLoggingEnabled(const Value : Boolean);
    procedure SetbBalanceInquiry(const bBalanceInq : boolean);
    procedure SendFileWrite();
    procedure SendApplBlock();
    procedure SendReBoot();
    
    procedure SendOffline();
    procedure SendSetPaymentType(const conditional : boolean; const cardtype : char; const amount : currency);
    procedure SendSetAllowedPayments();
    procedure SendSetAllowedDebitCredit();
    procedure SendStatusRequest();
    procedure SendSetAccount();
    procedure SendSoftReset(const ResetType : char);
    procedure SendBINLookupResponse(const CardType : string;
                                    const bAskDebit : boolean;
                                    const bBINRange : boolean;
                                    const bValidated : boolean);
    
    procedure SendNumericEntryRequest(const displaychar : char; const prompt : string; const mindigits, maxdigits : integer; const formatspec : string = ''; const formspec : string = ''); overload;
    procedure SendNumericEntryRequest(const displaychar : char; const prompt, mindigits, maxdigits : integer; const formatspec : integer = -1; const formspec : string = ''); overload;
    procedure SendSetVariableRequest(const VarID : string;
                                     const VariableText : string;
                                     const bRequestResponse : boolean);
    procedure SendGetVariableRequest(const VarID : string);
    
    procedure SendAuthResponse(const bApproved : boolean;
                               const ApprovalCode : string;
                               const PINPadDisplayMsg : string);
    procedure SendConfWrite(const IDNGroup : integer;
                            const IDNIndex : integer;
                            const IDNData  : string);
    procedure SendConfRead(const IDNGroup : integer;
                           const IDNIndex : integer);
    procedure ProcessNewVariableData(const        VarID : string;
                                     const VariableData : string);
    procedure DBTransactionInsertSignatureData(const AuthID : integer;
                                               const SigData : string);
    property CardTypeField : smallint read FCardTypeField write SetCardTypeField;
    function getCardTypeChar: char;
    property CardTypeChar : char read getCardTypeChar;
    function GetReqApplId: string;
    function GetReqParmId: string;
    procedure SetReqApplId(const Value: string);
    procedure SetReqParmId(const Value: string);
    procedure SetSwipePending(const Value: boolean);
    procedure SetAdCheckPeriod(const Value: integer);
    procedure AdCheck();
    procedure SendAdFile();
    procedure DownloadComplete(const filename : string; const Aborted : boolean);
    procedure SetAdDisplayPeriod(const Value: Cardinal);
    procedure ShowAds();
    procedure PinPadStartup;
    procedure ManageStatusRequests;
    procedure SetAdMax(const Value: smallint);
    property AdMax : smallint read FAdMax write SetAdMax;
    procedure SetEnabled(const Value: boolean);
    procedure SetAdWaitPeriod(const Value: integer);
    procedure SetTermSerialNo(const Value: string);
    property TermSerialNo : string read FTermSerialNo write SetTermSerialNo;
    property TermModel : TPPSupportedModels read FTermModel;
    procedure SetAdsCurrent(const Value: TTriState);
    property AdsCurrent : TTriState read FAdsCurrent write SetAdsCurrent;
    procedure QueryUnitData;
    procedure QueryAdServer();
    procedure SetAdServerURL(const Value: string);
    procedure SetReg(const Value: integer);
    procedure SetStore(const Value: integer);
    procedure SetEntryPrompt(const Value: TPPEntry);
    property EntryPrompt : TPPEntry read FEntryPrompt write SetEntryPrompt;
    procedure SetEMVEnabled(const Value: boolean);
    procedure ProcessEMV_TrackTwoEquivalent(const msg: string);
    procedure ProcessEMV_Auth(const msg: string);
    procedure ProcessEMV_AuthRespFail(const msg: string);
    procedure ProcessEMV_AuthCFM(const msg: string);
    procedure ProcessEMV_CVMMod(const msg: string);
    procedure ProcessEMV_CVMMod_CCResp(const msg: string);
  protected
    { Protected declarations }
    FCardInfoReceived : TCardInfoReceivedEvent;
    FAuthInfoReceived : TAuthInfoReceivedEvent;
    FOnSigReceived    : TSignatureReceivedEvent;
    FOnPinPadPromptChange : TPinPadPromptChangeEvent;
    FOnPinPadAdQuery : TSmallIntQuery;
    FCustomerDataReceived : TEntryReceivedEvent;
    procedure CardInfoReceived(const PINPadTrack1  : widestring;
                               const PINPadTrack2  : widestring;
                               const PINAccountNo  : widestring;
                               const PINTrack      : widestring;
                               const EncryptedTrackData : widestring = '';
                               const EMVTags : widestring = '');
    procedure AuthInfoReceived(const PinPadAmount  : currency;
                               const PinPadMSRData : string;
                               const PINBlock      : string;
                               const PINSerialNo   : string);
    function PinPadPromptChange(const PinPadStatusID : string;
                                const PinPadPrompt   : string) : boolean;
    property OnCardInfoReceived : TCardInfoReceivedEvent read FCardInfoReceived write FCardInfoReceived;
    property OnAuthInfoReceived : TAuthInfoReceivedEvent read FAuthInfoReceived write FAuthInfoReceived;
    property OnSignatureReceived: TSignatureReceivedEvent read FOnSigReceived write FOnSigReceived;
    property OnPinPadPromptChange : TPinPadPromptChangeEvent read FOnPinPadPromptChange write FOnPinPadPromptChange;
    property OnPinPadAdQuery : TSmallIntQuery read FOnPinPadAdQuery write FOnPinPadAdQuery;
    property OnCustomerDataReceived : TEntryReceivedEvent read FCustomerDataReceived write FCustomerDataReceived;
    property OnCardStatusChange : TPinPadCardStatusEvent read FOnCardStatusChange write FOnCardStatusChange;
    property LoadFileName : string read FFileName write SetLoadFileName;
    property LastBlockTime : TDateTime read FLastBlockTime;
    property CCSendMsg : TMsgRespRequest read FCCSendMsg write FCCSendMsg;
    property OnSerialNoChange : TMsgRecEvent read FSerialNoChange write FSerialNoChange;
    procedure PinPadDownload(const filename : string);
    
    function PPStartupStateToString(const Value : TPPStartupState) : string;
  public
    { Public declarations }
    bCheckKeyPress,bcheckPayType,bEMVCheck: boolean; // madhu gv 18-12-2017  added to check GETKEYPRESS error for EMV tns.
    nCount: integer; // madhu gv  20-12-2017
    LastSeqNoDisplayed : integer;
    SwipeCheckCount : Integer;
    CheckSignatureEntry : String;
    InvalidPIN_Entered : boolean;
    InvalidPIN_EnteredCount : Integer;
    IsFallbackTransaction : boolean;
    IsContactlessEMV : boolean;
    constructor Create(AOwner : TComponent); override;
    destructor destroy(); override;
    procedure SendOnline();
    procedure PINPadOpen();
    procedure PINPadClose();
    procedure PINPadTransReset();
    procedure PINPadCancelAction();
    procedure PINPadReBoot();
    function SendEMV_FALLBACK() : Boolean;
    procedure SendSignatureRequest(const SignatureCapturePrompt : string);
    procedure EnablePT(PaymentType : TPayment ; const Enabled : boolean = True ; const Send : boolean = False);
    procedure PaymentTypes(enDebit, enCredit, enEBTCash, enEBTFS, enGift : boolean ; const Send : boolean = False);
    procedure PINPadNewSaleItem(const NewSeqNo : integer;
                                const NewExtPrice : currency;
                                const NewQty : currency;
                                const NewItemDesc : string;
                                const NewTotalTax : currency;
                                const NewTotalDue : currency);
    procedure PINPadAuthResponse(const bApproved : boolean;
                                 const AuthID    : integer;
                                 const ApprovalCode : string;
                                 const PINPadDisplayMsg : string);
    procedure ReIssueSignatureCapture(const TransAuthID : integer;
                                      const SignatureReCapturePrompt : string);
    procedure UpdatePinPadFiles();
    procedure DisplaySaleLine(const line : integer; const pPSL : pPPSaleLine);
    procedure DisplayTotalLine(const totaldue : currency; const totaltax : currency; const scroll : boolean = True);
    procedure HandleValidCardResp(const AcctNo, CardType : widestring; const bAskDebit, bBINRange, bValidated : wordbool);
    procedure SendHardReset(const bClearLineDisplay : boolean);
    procedure GetPhoneNo();
    procedure GetDriverID();
    procedure GetZip();
    procedure GetID();
    procedure GetOdometer();
    procedure GetVehicleNo();
    procedure StopOnDemand();
    procedure SendInitialSetAmount(sAmount : Currency);
    procedure SendSetAmount();
    procedure SendSetTransactionType();
    procedure SendReadCard();
    procedure SendCancelOnDemand();
    procedure SendEMVInitiate();
    procedure SendAdRequest(const adno : smallint = 0);
    procedure SendEMVAuthResponse(const Resp : pCreditResponseData);
    //procedure ProcessPinPadEMVMessage(sMsgs : string);   //-local Duplicate procedure name with no overload directive so this will not compile ****************************
    property PinPadOnLine : boolean read FPinPadOnline write SetPinPadOnline;
    property OnOnlineChange: TNotifyEvent read FOnOnlineChange write FOnOnlineChange;
    property TransNo : integer read FTransNo write SetTransNo;
    property PinPadFSAmount : currency read FPinPadFSAmount write SetPinPadFSAmount;
    property PinPadFuelAmount : currency read FPinPadFuelAmount write FPinPadFuelAmount;
    property PinPadAmount : currency read FPinPadAmount write SetPinPadAmount;
    property bPinPadVoidTransaction : boolean read FbPinPadVoidTransaction write FbPinPadVoidTransaction;
    property PinPadAccount : string read FPinPadAccount write SetPinPadAccount;
    property PinPadExpDate : string read FPinPadExpDate write SetPinPadExpDate;
    property LoadFileDir : string read FDirPath write SetLoadFileDir;
    property PINPadInputCount : integer read FPINPadInputCount;
    property PINPadInputs[Index: Integer] : pPINPadInput read GetPinPadInputs write SetPinPadInputs;
    property PinPadPortNo : Integer read FPinPadPortNo write FPinPadPortNo;
    property PinPadBaudRate : integer read FPinPadBaudRate write FPinPadBaudRate;
    property PinPadDataBits : integer read FPinPadDataBits write FPinPadDataBits;
    property PinPadStopBits : integer read FPinPadStopBits write FPinPadStopBits;
    property PinPadParity : TParity read FPinPadParity write FPinPadParity;
    property PinPadCreditSignatureLimit : currency read FPinPadCreditSignatureLimit write SetPinPadCreditSignatureLimit;
    property EMVEnabled : boolean read FEMVEnabled write SetEMVEnabled;
    property PinPaymentSelect : integer read FPinPaymentSelect;
    property LoggingEnabled : boolean read GetLoggingEnabled write SetLoggingEnabled;
    property ReqApplId : string read GetReqApplId write SetReqApplId;
    property ReqParmId : string read GetReqParmId write SetReqParmId;
    property ShowMsg : TShowMsgProc read FShowMsg write FShowMsg;
    property PinPadTrack1 : string read FPinPadTrack1 write FPinPadTrack1;
    property PinPadTrack2 : string read FPinPadTrack2 write FPinPadTrack2;
    property Track : string read FTrack;
    property OnSwipeChange : TNotifyEvent read FOnSwipeChange write FOnSwipeChange;
    property SwipePending : boolean read FbSwipePending write SetSwipePending;
    property AdCheckPeriod : integer read FAdCheckPeriod write SetAdCheckPeriod;
    property AdFileDir : string read FAdDirPath write FAdDirPath;
    property bBalanceInquiry : boolean read FbBalanceInquiry write SetbBalanceInquiry;
    property AdDisplayPeriod : Cardinal read FAdDisplayPeriod write SetAdDisplayPeriod;
    property OnAdMaxChange : TSmallIntNotify read FOnAdMaxChange write FOnAdMaxChange;
    property Enabled : boolean read FEnabled write SetEnabled;
    property AdWaitPeriod : integer read FAdWaitPeriod write SetAdWaitPeriod;
    property ReceiptLines : integer read FReceiptLines write FReceiptLines;
    property SignatureCaptured : boolean read FSignatureCaptured;
    property Store : integer read FStore write SetStore;
    property Reg : integer read FReg write SetReg;
    property AdServerURL : string read FAdServerURL write SetAdServerURL;
    procedure SendPINRequest(const acctno : string = '');
    property EnableContactless : boolean read FEnableContactless write FEnableContactless;
  end;
  TPINPadTrans = class(TPINPadTransaction)
  published

    property onCardInfoReceived;

    property onAuthInfoReceived;

    property OnSignatureReceived;

    property OnPinPadPromptChange;

    property OnPinPadAdQuery;

    property OnCustomerDataReceived;

    property OnCardStatusChange;

    property OnSerialNoChange;

    property CCSendMsg;
  end;

  TAdHTTPThread = class(TThread)
  private
    PP : TPINPadTransaction;
    URL: String;
    store, reg : integer;
    model, serial : string;
  public
    constructor Create(const APP : TPINPadTransaction; const AURL: String; const astore, areg: integer; const amodel: TPPSupportedModels; const aserial: string); reintroduce;
  end;

  TAdServerQueryThread = class(TAdHTTPThread)
  protected
    procedure Execute; override;
  end;

  TAdServerDoneThread = class(TAdHTTPThread)
  protected
    procedure Execute; override;
  end;


implementation

uses
  Forms,
  NBSCC,
  SysUtils,
  DateUtils,
  StrUtils,
  Math,
  ExceptLog,
  JCLDebug,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

const
  CARD_TYPE_FIELD_DEBIT    = ord(pt_Debit);
  CARD_TYPE_FIELD_CREDIT   = ord(pt_Credit);
  CARD_TYPE_FIELD_EBT_CB   = ord(pt_EBTCash);
  CARD_TYPE_FIELD_EBT_FS   = ord(pt_EBTFS);
  CARD_TYPE_FIELD_GIFT     = ord(pt_Gift);
  CARD_TYPE_FIELD_GIFT_FUEL_ONLY  = ord(pt_GiftFuelOnly);
  CARD_TYPE_FIELD_INVALID  = -1;
  CARD_TYPE_FIELD_UNKNOWN  = 0;

  // Message ID fields for messages sent to and received from Pin Pad
  PINPAD_MSG_ID_OFFLINE              = '00.';
  PINPAD_MSG_ID_ONLINE               = '01.';
  PINPAD_MSG_ID_PROGRAM_LOAD         = '02.';
  PINPAD_MSG_ID_SET_PAYMENT_TYPE     = '04.';
  PINPAD_MSG_ID_UNIT_DATA            = '07.';
  PINPAD_MSG_ID_SET_ALLOWED_PAYMENTS = '09.';
  PINPAD_MSG_ID_CARD_STATUS          = '09.';
  PINPAD_MSG_ID_HARD_RESET           = '10.';
  PINPAD_MSG_ID_STATUS_REQUEST       = '11.';
  PINPAD_MSG_ID_SET_ACCOUNT          = '12.';
  PINPAD_MSG_ID_SET_AMOUNT           = '13.';
  PINPAD_MSG_ID_SET_TRANSACTION_TYPE = '14.';
  PINPAD_MSG_ID_SOFT_RESET           = '15.';
  PINPAD_MSG_ID_CARD_INFORMATION     = '18.';
  PINPAD_MSG_ID_BIN_LOOKUP           = '19.';
  PINPAD_MSG_ID_SIGNATURE_READY      = '20.';
  PINPAD_MSG_ID_NUMERIC_INPUT_REQUEST= '21.';
  PINPAD_MSG_ID_APPLICATION_ID       = '22.';
  PINPAD_MSG_ID_CARD_READ_REQUEST    = '23.';
  PINPAD_MSG_ID_FORM_ENTRY_REQUEST   = '24.';
  PINPAD_MSG_ID_SET_VARIABLE_REQUEST = '28.';
  PINPAD_MSG_ID_GET_VARIABLE_REQUEST = '29.';
  PINPAD_MSG_ID_AD_REQUEST           = '30.';
  PINPAD_MSG_ID_PIN_REQUEST          = '31.';
  PINPAD_MSG_ID_EMV                  = '33.';
  PINPAD_MSG_ID_AUTH_REQUEST         = '50.';
  PINPAD_MSG_ID_PARM_LOAD            = '59.';
  PINPAD_MSG_ID_CONF_WRITE           = '60.';
  PINPAD_MSG_ID_CONF_READ            = '61.';
  PINPAD_MSG_ID_FILE_WRITE           = '62.';
  PINPAD_MSG_ID_FILE_FIND            = '63.';
  PINPAD_MSG_ID_REBOOT               = '97.';

  PINPAD_EMV_SUB_TRACKTWOEQUIV       = 2;
  PINPAD_EMV_SUB_AUTH                = 3;
  PINPAD_EMV_SUB_AUTHRESP            = 4;
  PINPAD_EMV_SUB_AUTHCONFIRM         = 5;
  PINPAD_EMV_SUB_CVMMOD              = 7;

  PINPAD_STATUS_ID_OFFLINE           = '00';
  PINPAD_STATUS_ID_SLIDE_CARD        = '01';
  PINPAD_STATUS_ID_TRANSACTION_TYPE  = '02';
  PINPAD_STATUS_ID_ENTER_PIN         = '03';
  PINPAD_STATUS_ID_AMOUNT            = '04';
  PINPAD_STATUS_ID_PROCESSING        = '05';
  PINPAD_STATUS_ID_APPROVED_DECLINED = '06';
  PINPAD_STATUS_ID_ERROR             = '07';
  PINPAD_STATUS_ID_LOADING_LR        = '08';
  PINPAD_STATUS_ID_LOADING           = '09';
  PINPAD_STATUS_ID_SIGNATURE_CAPTURE = '10';
  PINPAD_STATUS_ID_SIGNATURE_AVAIL   = '11';
  PINPAD_STATUS_ID_CARD_CAPTURE      = '12';
  PINPAD_STATUS_ID_CARD_DATA_AVAIL   = '13';
  PINPAD_STATUS_ID_SELECT_LANGUAGE   = '14';

  PINPAD_VAR_ID_SCROLL_DISPLAY        = '104';
  PINPAD_VAR_ID_BOTTOM_DISPLAY        = '120';
  PINPAD_VAR_ID_TIME                  = '201';
  PINPAD_VAR_ID_DATE                  = '202';
  PINPAD_VAR_ID_PAYMENT_TYPE          = '404';
  PINPAD_VAR_ID_PAYMENT_MSR_TRACK     = '405';
  PINPAD_VAR_ID_MSR_TRACK1            = '406';
  PINPAD_VAR_ID_MSR_TRACK2            = '407';
  PINPAD_VAR_ID_MSR_ENCRYPTEDBLOCK    = '411';
  PINPAD_VAR_ID_SIGNATURE_BLOCK       = '700';
  PINPAD_VAR_ID_SIGNATURE_BLOCK_COUNT = '712';
  PINPAD_VAR_ID_SIGNATURE_BLOCK_BYTES = '713';

  // Following are parameters for the PINPAD_MSG_ID_SOFT_RESET message type
  PINPAD_RESET_TYPE_HARD               = '0';  // see PINPAD_MSG_ID_HARD_RESET message type
  PINPAD_RESET_TYPE_CANCEL_SIGNATURE   = '1';
  PINPAD_RESET_TYPE_CANCEL_PIN         = '2';
  PINPAD_RESET_TYPE_AMOUNT             = '3';
  PINPAD_RESET_TYPE_SIGNATURE          = '4';
  PINPAD_RESET_TYPE_CONTINUE_ACTION    = '5';
  PINPAD_RESET_TYPE_STOP_ACTION        = '6';
  PINPAD_RESET_TYPE_PIN                = '7';
  PINPAD_RESET_TYPE_CLEAR_ITEM_DISPLAY = '8';

  PINPAD_IDN_GROUP_STB = 5;
  PINPAD_IDN_GROUP_SIG = 9;
  PINPAD_IDN_GROUP_ADS = 10;
  PINPAD_IDN_GROUP_CARDS = 11;
  PINPAD_IDN_GROUP_EMV = 19;
  PINPAD_IDN_GROUP_CLESS = 8;
  PINPAD_IDN_GROUP_SECURITY = 91;

  PINPAD_IDN_STB_ENABLED          = 2;
  PINPAD_IDN_STB_TRACKDATA        = 4;
  PINPAD_IDN_STB_CLEARDIGITS      = 8;
  PINPAD_IDN_SIG_SEND_MESSAGE     = 2;
  PINPAD_IDN_ADS_COUNT            = 2;
  PINPAD_IDN_CARDS_DEBIT          = 1;
  PINPAD_IDN_CARDS_CREDIT         = 2;
  PINPAD_IDN_CARDS_EBT_CASH       = 3;
  PINPAD_IDN_CARDS_EBT_FOODSTAMPS = 4;
  PINPAD_IDN_CARDS_GIFT           = 5;
  PINPAD_IDN_EMV_SUPPORT          = 1;
  PINPAD_IDN_EMV_CVMMOD           = 9;
  PINPAD_IDN_CLESS_ENABLED        = 1;
  PINPAD_IDN_SECURITY_ENCRYPTION  = 1;

  RESPONSE_STATUS_FAIL         = '1';
  RESPONSE_STATUS_SUCCESS      = '2';
  RESPONSE_STATUS_INVALID_ID   = '3';
  RESPONSE_STATUS_NOT_UPDATED  = '4';
  RESPONSE_STATUS_FORMAT_ERROR = '5';
  RESPONSE_STATUS_NOT_EXECUTED = '9';

  MAX_SIGNATURE_BYTES = 2048;
  MAX_DISPLAY_WIDTH = 39;
  
  FileWriteReservedField : string[8] = '000000';
  FS_CHAR : char = char($1C);
  GS_CHAR : char = char($1D);
  EXT_CHAR : char = char($03);
  

  PINPAD_DEFAULT_RECEIPT_LINES = 4;
  PINPAD_MAX_TIMEOUT = 3;
  PINPAD_MAX_NAK = 3;

type
  TFileUpdateRec = record
    ts : TDateTime;
    fn : string[20];
  end;
  pFileUpdateRec = ^TFileUpdateRec;

  TEMVPacketType = (ptFirstLast, ptFirstOfMore, ptMore, ptLast);

  TLogMaskIngTags = class(TLogMaskBase)
  private
    Fdir: TMsgDir;
    Fmstart: integer;
    Fmend: integer;
    Ftag: string;
  public
    constructor Create(const tag : string ; const dir : TMsgDir; const mstart, mend : integer);
    property tag : string read Ftag write Ftag;
    property dir : TMsgDir read Fdir write Fdir;
    property mstart : integer read Fmstart write Fmstart;
    property mend  : integer read Fmend write Fmend;
    procedure Mask(const buffer : pChar; const len : integer; const dir : TMsgDir); override;
  end;

constructor TPINPadTransaction.Create(AOwner : TComponent);
var
  i : TPayment;
begin
  Inherited Create(AOwner);
  FStartUpState := ppssOffline;
  FEncryptionEnabled := False;
  FTermModel := ppsmUnknown;
  PinPadOnline := False;
  try
    PinPadDisplayQueue := TThreadList.Create();
  except
    on e : exception do
      raise exception.Create('Cannot create list for PIN pad display messages - ' + e.Message);
  end;
  PinPadDisplayQueue.Duplicates := dupAccept;
  LastStatusID := PINPAD_STATUS_ID_OFFLINE;
  LastStatusPrompt := '';
  FTransNo := -1;
  bClearDisplayOnNextTransReset := True;  // Normally display cleared unless TransNo changes during sale (e.g. partial tender, declined card).
  FPinPaymentSelect := PIN_NO_TYPE;
  FPinPadTransHandle := AllocateHWND(PinPadTransMessageHandler);
  PPDev := nil;
  bPinPadOpening := False;
  SignatureData := '';
  SignatureDataIndex := 0;
  SignatureBlockIndex := 0;
  SignatureBlockHighest := 0;
  for i := Low(Self.FPaymentAllowed) to High(Self.FPaymentAllowed) do
    Self.FPaymentAllowed[i] := False;
  Self.FLastAllowedString := '';
  for i := Low(Self.FPaymentQualifies) to High(Self.FPaymentQualifies) do
    Self.FPaymentQualifies[i] := True;
  LoadFileBuffer := TLoadFileBuffer.Create();  // used for file transfers to pin pad device
  FDirPath := '';
  FFileName := '';
  FPinPadCreditSignatureLimit := 0.0;
  FWaitClose := False;
  NewPinPadCreditSignatureLimit := -1.0;
  FAdWaitPeriod := 0 {seconds};
  DisplayAdStart := 0.0;
  ReqApplID := '0000';
  ReqParmID := '0000';
  FApplID := '0000';
  FParmID := '0000';

  PinPadTimer := TTimer.Create(AOwner);
  PinPadTimer.Enabled := False;
  PinPadTimer.Interval := 100;
  PinPadTimer.OnTimer := PinPadTimerExpired;

  FOnSwipeChange := nil;
  FbSwipePending := False;
  FOnlineAttempt := 0;
  FLastAdCheck := 0;
  FAdDirPath := '';
  FAdsCurrent := tsUnknown;
  FbBalanceInquiry := False;

  FAdDisplayPeriod := 0;
  FAdCurrent := 0;
  FAdMax := 0;

  LastAct := Now();

  FOnlineEvent := TEvent.Create(nil, True, False, 'PinPadOnline');
  FReceiptLines := PINPAD_DEFAULT_RECEIPT_LINES;

  FTimeoutCount := 0;
  FNAKCount := 0;

  FTermSerialNo := '';
  FEMVEnabled := False;

  Self.FMSGBuffer := TJclStrStrHashMap(15);

   bCheckKeyPress := False;    // madhu gv 19-12-2017  start
   bcheckPayType := False;      // madhu gv 19-12-2017   end
   bEMVCheck := false;// madhu gv 19-12-2017
   nCount := 0;// madhu gv 20-12-2017
end;

destructor TPINPadTransaction.Destroy();
var
  j : integer;
  QueueList : TList;
  q : pPinPadDisplayMessage;
begin
  try
    QueueList := PinPadDisplayQueue.LockList();
    for j := 0 to QueueList.Count - 1 do
    begin
      try
        q := QueueList.Items[j];
        q^.DisplayItemDesc := '';
        Dispose(q);
        QueueList.Items[j] := nil;
      except
        on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem disposing QueueList[%d] - %s - %s', [j, E.ClassName, E.Message]);
      end;
    end;
    QueueList.Pack();
  finally
    PinPadDisplayQueue.UnlockList();
  end;
  try
    PinPadDisplayQueue.Destroy();
  except
    on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem destroying PinPadDisplayQueue - %s - %s',[E.ClassName, E.Message]);
  end;
  try
    if (PinPadTimer <> nil) then
    begin
      PinPadTimer.Enabled := False;
    end;
  except
    on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem disabling PinPadTimer - %s - %s',[E.ClassName, E.Message]);
  end;
  try
    LoadFileBuffer.Destroy;
  except
    on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem destroying LoadFileBuffer - %s - %s',[E.ClassName, E.Message]);
  end;
  //PPDev.LogEvent('TPINPadTransaction.Destroy: About to destroy PPDev');
  try
    if PPDev <> nil then
      PPDev.Destroy;
  except
    on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem destroying PPDev - %s - %s',[E.ClassName, E.Message]);
  end;
  try
    Inherited Destroy();
  except
    on E: Exception do UpdateExceptLog('TPinPadTransaction.Destroy: problem destroying parent - %s - %s',[E.ClassName, E.Message]);
  end;
  try
    FMSGBuffer.Free;
  except
    on E: Exception do UpdateExceptLog('%s: problem destroying parent - %s - %s',[ProcByLevel, E.ClassName, E.Message]);
  end;
  FreeAndNil(FOnlineEvent);
end;

procedure TPINPadTransaction.SendMessageToDevice(const MsgToSend : string ; const expectresponse : boolean = True);
begin
  // If device not open, then open it:
  if (not (PPDev.Connected or bPinPadOpening)) then
  begin
    PPDev.LogEvent('SendMessageToDevice: Pinpad not open or opening "%s" is causing us to try to open', [MsgToSend]);
    PinPadOpen();
  end;
  // Send the message:
  try
    Self.LastAct := Now();
    PPDev.Send(MsgToSend, expectresponse);
  except
    on e : exception do
    begin
      PinPadOnLine := False;
      UpdateExceptLog('PINPadSend failed - ' + e.Message);
    end;
  end;
  
end;

procedure TPINPadTransaction.PinPadTransMessageHandler(var Msg : TMessage);
{
Handle all responses (including timeouts) from pin pad device:
}
var
  qIOMessage : pIOMessage;
  obmsg : pOutboundMessage;
  sKeyPress: string;  // madhu gv  19-12-2017 added
begin
  if (Msg.Msg = WM_PIN_PAD_DEV_RESP) then
  begin
    qIOMessage := pIOMessage(Msg.LParam);
    if (qIOMessage <> nil) then
    begin
      if (qIOMessage^.IOType = mIOTypeText) then
      begin
        {$IFDEF PP_DEBUG}
        PPDev.LogEvent('MessageHandler - Received "%s"', [qIOMessage^.IOText]);
        {$ENDIF}
        UpdateZLog(':local - MessageHandler - Received "%s"', [qIOMessage^.IOText]);
        // Ordinary response (process based on message type).
        PinPadMsgType := Copy(qIOMessage^.IOText, 1, PINPAD_MSG_ID_LEN);

        sKeyPress := Copy(qIOMessage^.IOText, 1,5);

        bcheckPayType := false; // madhu gv 18-12-2017  added


        // Michael Stith Removed this because the flow of the messages needs to change
        // per RBA_21_7_2 standards

        // The reason 7-eleven was stuck on RBA 3 was because Latitude was coded for the flow of messages at that time
        // With the new RBA's, the flow is reversed and the POS needs to initiate the transaction
        
        {if (qIOMessage^.IOText ='11.20Get Keypress')or (sKeyPress = '11.20') then // madhu gv  16-12-2017    start
        begin
          UpdateZLog('or (smadhu = 11.20) then ;-tarang :');
          if (nCount = 1) then
          begin
            UpdateZLog('PINPAD_MSG_ID_SET_TRANSACTION_TYPE -tarang :');
            PinPadMsgType := PINPAD_MSG_ID_SET_TRANSACTION_TYPE;
            qIOMessage^.IOText := PINPAD_MSG_ID_SET_TRANSACTION_TYPE;
            SendSetTransactionType();
            bEMVCheck := true;
            bCheckKeyPress := False;
            nCount := nCount + 1;
          end else
          if (nCount = 2) then
          begin
             UpdateZLog('SendSetPaymentType-set amount -tarang :');
            PinPadMsgType := PINPAD_MSG_ID_SET_AMOUNT;
            qIOMessage^.IOText :=  PINPAD_MSG_ID_SET_AMOUNT;
           // SendSetPaymentType(False, 'B', Self.PinPadAmount);  // set amount
            SendSetAmount();
            nCount := nCount + 1;
          end else
          if (nCount = 3) then
          begin
            UpdateZLog('PINPAD_MSG_ID_STATUS_REQUEST -tarang :');
            PinPadMsgType := PINPAD_MSG_ID_STATUS_REQUEST;
            qIOMessage^.IOText :=  PINPAD_MSG_ID_STATUS_REQUEST;
            nCount := nCount + 1;
          end else
          if (nCount = 4) then
          begin
             UpdateZLog('SendSetPaymentType -tarang :');
            PinPadMsgType := PINPAD_MSG_ID_SET_PAYMENT_TYPE;
            qIOMessage^.IOText :=  PINPAD_MSG_ID_SET_PAYMENT_TYPE;
            SendSetPaymentType(False, 'B', Self.PinPadAmount);
            nCount := nCount + 1;
          end else
           if (nCount = 5) then
          begin
             UpdateZLog('if(bEMVCheck)-5 then -tarang :');
             qIOMessage^.IOText := PINPAD_MSG_ID_EMV;
             PinPadMsgType := PINPAD_MSG_ID_EMV;
             nCount := nCount + 1;
          end else
          if (nCount = 6) then
          begin
            UpdateZLog('if(bEMVCheck)-6 then -tarang :');
            qIOMessage^.IOText := PINPAD_MSG_ID_EMV;
            PinPadMsgType := PINPAD_MSG_ID_EMV;
            nCount := nCount + 1;
          end;
          if (nCount = 7) then
          begin
            UpdateZLog('if(bEMVCheck)-7 then -tarang :');
            qIOMessage^.IOText := PINPAD_MSG_ID_EMV;
            PinPadMsgType := PINPAD_MSG_ID_EMV;
            nCount := nCount + 1;
          end;
        end;}

        
       { bcheckPayType := false;0 // madhu gv 18-12-2017  added
        if (qIOMessage^.IOText ='11.20Get Keypress')or (sKeyPress = '11.20') then // madhu gv  16-12-2017    start
        begin
          UpdateZLog('or (smadhu = 11.20) then ;-tarang :');
          if (bCheckKeyPress)and not(bEMVCheck) then
          begin
            //PinPadMsgType := PINPAD_MSG_ID_SET_PAYMENT_TYPE;
            SendSetTransactionType();
            SendSetPaymentType(False, 'B', Self.PinPadAmount);
            bEMVCheck := true;
            bCheckKeyPress := False;
          end else
          if(bEMVCheck)then
          begin
            UpdateZLog('if(bEMVCheck)then -tarang :');
            qIOMessage^.IOText := PINPAD_MSG_ID_EMV;
            PinPadMsgType := PINPAD_MSG_ID_EMV;
          end;

        end;      }                                            // madhu gv  16-12-2017

        //---------------------------madhu g v  19-12-2017--------------start

      { sKeyPress := Copy(qIOMessage^.IOText, 1,5);

       if (qIOMessage^.IOText ='11.20Get Keypress')or (sKeyPress = '11.20') then // madhu gv  16-12-2017    start
       begin
         UpdateZLog('Before: SetPinPadAmount(Self.PinPadAmount); -tarang :');
         if (bCheckKeyPress)and not(bcheckPayType) then
         begin
           UpdateZLog('if (bCheckKeyPress)and not(bcheckPayType) then -tarang :');
           bCheckKeyPress := False;
           bcheckPayType := true;
           SetPinPadAmount(Self.PinPadAmount);
           //SendSetPaymentType(False, 'B', Self.PinPadAmount);
         end
         else
         if (bcheckPayType) and not(bEMVCheck)then
         begin
           UpdateZLog(' if (bcheckPayType)then -tarang :');
           bcheckPayType := False;
           bEMVCheck := true;
           PinPadMsgType := PINPAD_MSG_ID_SET_PAYMENT_TYPE;
         end else
         if(bEMVCheck)then
         begin
            UpdateZLog('if(bEMVCheck)then -tarang :');
           PinPadMsgType := PINPAD_MSG_ID_EMV;
         end;
       end;           }
     //--------------------------------madhu gv 19-12-2017------------------end

        if RespWaitMsg <> nil then
          if PinPadMsgType = Copy(RespWaitMsg^.MsgText, 1, PINPAD_MSG_ID_LEN) then
          begin
            {$IFDEF PP_DEBUG}PPDev.LogEvent('Dequeuing %s',[RespWaitMsg^.MsgText]);{$ENDIF}
            PPDev.DeQueueOutboundMsg(RespWaitMsg);
            PPDev.SendNextOutboundMsg;
          end
          else
            PPDev.LogEvent('While waiting for response, expected %s, got %s instead', [Copy(RespWaitMsg^.MsgText, 1, PINPAD_MSG_ID_LEN), PinPadMsgType]);

        if (PinPadMsgType = PINPAD_MSG_ID_OFFLINE) then
        begin
          ProcessPinPadOffline(qIOMessage);              // device going off-line
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_ONLINE) then
        begin
          ProcessPinPadOnline(qIOMessage);               // response to on-line request
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_SET_PAYMENT_TYPE)  then
        begin
          ProcessPinPadSetPaymentType(qIOMessage);       // response to setting payment type / amount
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_UNIT_DATA) then
        begin
          ProcessPinPadUnitData(qIOMessage);             // response to unit data request
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_CARD_STATUS) then
        begin
          ProcessPinPadCardStatus(qIOMessage);
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_HARD_RESET) then
        begin
          ProcessPinPadHardReset(qIOMessage);            // response to hard reset
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_STATUS_REQUEST) then
        begin
            ProcessPinPadStatusResponse(qIOMessage);       // response to status request
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_BIN_LOOKUP) then
        begin
          CheckSignatureEntry := 'S';
          ProcessPinPadBINLookup(qIOMessage);            // device requesting info on card swiped
        end
        else if (PinPadMsgType = PINPAD_MSG_ID_CARD_READ_REQUEST) then
          ProcessCardReadResponse(qIOMessage)           // tells us what type of transaction (MSR or EMV)
        else if (PinPadMsgType = PINPAD_MSG_ID_SIGNATURE_READY) then
          ProcessPinPadSignatureReady(qIOMessage)       // device notifying that customer accepted signature
        else if (PinPadMsgType = PINPAD_MSG_ID_NUMERIC_INPUT_REQUEST) then
          ProcessPinPadEntryReady(qIOMessage)       // device notifying that customer did data entry
        else if (PinPadMsgType = PINPAD_MSG_ID_GET_VARIABLE_REQUEST) then
          ProcessPinPadGetVariableRequest(qIOMessage)   // response to get variable request
        else if (PinPadMsgType = PINPAD_MSG_ID_PIN_REQUEST) then
          ProcessPinPadPINReady(qIOMessage)
        else if (PinPadMsgType = PINPAD_MSG_ID_EMV) then
          ProcessPinPadEMVMessage(qIOMessage)
        else if (PinPadMsgType = PINPAD_MSG_ID_AUTH_REQUEST) then
          ProcessPinPadAuthRequest(qIOMessage)          // device requesting card authorization
        else if (PinPadMsgType = PINPAD_MSG_ID_CONF_WRITE) then
          ProcessPinPadConfWrite(qIOMessage)            // response to a configuration write request
        else if (PinPadMsgType = PINPAD_MSG_ID_CONF_READ) then
          ProcessPinPadConfRead(qIOMessage)            // response to a configuration read request
        else if (PinPadMsgType = PINPAD_MSG_ID_FILE_WRITE) then
          ProcessPinPadFileWrite(qIOMessage)            // response to file write block request
        else if (PinPadMsgType = PINPAD_MSG_ID_PROGRAM_LOAD) then
          UpdateExceptLog('PINPadTransMessageHandler: Received unhandled message type %s', [PinPadMsgType])
        else if (PinPadMsgType = PINPAD_MSG_ID_PROGRAM_LOAD) then
          ProcessPinPadSendAppl(qIOMessage)
        else if (PinPadMsgType = PINPAD_MSG_ID_SET_VARIABLE_REQUEST) then
          ProcessPinPadSetVar(qIOMessage)
        else
          UpdateExceptLog('PINPadTransMessageHandler: Received unhandled message type %s', [PinPadMsgType]);
      end
      // Processing of remaining message types mostly handled in TEFTDev class, but notified
      // here in case additional processing needed.
      else if (qIOMessage^.IOType = mIOTypeAck) then
      begin
        FTimeoutCount := 0;
        FNAKCount := 0;
        Self.LastAct := Now();
        obmsg := pOutboundMessage(Msg.WParam);
        if obmsg <> nil then
        begin
          RespWaitStart := Now();
          RespWaitMsg := obmsg;
        end
        else
        begin
          RespWaitStart := 0;
          RespWaitMsg := nil;
          PPDev.SendNextOutboundMsg;
        end;
      end
      else if (qIOMessage^.IOType = mIOTypeNak) then
      begin
        inc(FNAKCount);
        if FNAKCount >= PINPAD_MAX_NAK then
        begin
          PPDev.LogEvent('NAK limit exceeded, attempting to restart');
          Self.PinPadOnline := False;
          PPDev.FlushOutQueue;
        end
        else
          PPDev.SendNextOutboundMsg;
      end
      else if (qIOMessage^.IOType = mIOTypeTimeout) then
      begin
        inc(FTimeoutCount);
        if FTimeoutCount >= PINPAD_MAX_TIMEOUT then
        begin
          PPDev.LogEvent('Timeout limit exceeded, attempting to restart');
          Self.PinPadOnLine := False;
          PPDev.FlushOutQueue;
        end
        else
          PPDev.SendNextOutboundMsg;
      end
      else if (qIOMessage^.IOType = mIOTypeError) then
      begin
        //
      end;
    end;
    // If POS had requested a close then close the device now (had been waiting on the
    // response from the "offline" request).
    if (FWaitClose) then
    begin
      try
        if PPDev <> nil then
          PPDev.Connected := False;
        PinPadOnline := False;
        FWaitClose := False;
      except
        on e : exception do
        begin
          PinPadOnLine := False;
          UpdateExceptLog('TPINPadTransaction.PinPadTransMessageHandler: PINPad disconnect failed - %s - %s ', [E.ClassName, E.Message]);
        end;
      end;
    end;
    // Remove message just processed:
    try
      qIOMessage^.IOText := '';
      Dispose(qIOMessage);
    except
      on e : exception do UpdateExceptLog('TPINPadTransaction.PinPadTransMessageHandler: Cannot dispose qIOMessage - %s - %s', [E.ClassName, E.Message]);
    end;
  end;
end;  //procedure PinPadTransMessageHandler

procedure TPINPadTransaction.PinPadTimerExpired(Sender : TObject);
begin
  try
    {$IFDEF PP_DEBUG} PPDev.LogEvent('PinPadTimerExpired'); {$ENDIF}
    if (PPDev.QueueCount <> 0) and TimerExpired(Self.LastAct, 3) then
      PPDev.SendNextOutboundMsg;
    if Self.FWaitClose then
      exit;
    Self.ManageStatusRequests;
    if PinPadOnline then
    begin
      if (DisplayAdStart = 0.0) then  // if no ads display pending from end of previous transaction
      begin
        if (Self.FTransNo = 0) and (Self.FAdDisplayPeriod <> 0) then // self managing ads
          ShowAds();
      end
      else  // i.e., still waiting to display ads after end of previous transaction
      begin
        if (DisplayAdStart < Now()) then
        begin
          DisplayAdStart := 0.0;
          ShowAds();
        end;
      end;
      if (FAdCheckPeriod <> 0) and TimerExpired(FLastAdCheck, FAdCheckPeriod * 60) then
        AdCheck;
      if (Self.FAdFileList <> nil) then
        if TimerExpired(FLastBlockTime, 10) then
          if (LoadFileBuffer.FilePath = '') then
            SendAdFile
          else
          begin
            PPDev.LogEvent('Aborting send as last block of %s is %d seconds old', [LoadFileBuffer.FilePath, SecondsBetween(Now, FLastBlockTime)] );
            LoadFileBuffer.FilePath := '';
          end;
    end;
  except
    on E: Exception do
    begin
      UpdateExceptLog('PinPadTimerExpired - Exception "%s"', [E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;
end;

procedure TPINPadTransaction.QueuePINPadDisplayItem(const NewSeqNo : integer;
                                                    const NewExtPrice : currency;
                                                    const NewQty : currency;
                                                    const NewItemDesc : string;
                                                    const NewTotalTax : currency;
                                                    const NewTotalDue : currency);
var
  q : pPinPadDisplayMessage;
begin
  UpdateZLog('PIN Pad Display Queued: ' + NewItemDesc + '  Total=' + CurrToStr(NewTotalDue));
  New(q);
  q^.DisplayTransNo  := FTransNo;
  q^.DisplaySeqNo    := NewSeqNo;
  q^.DisplayExtPrice := NewExtPrice;
  q^.DisplayQty      := NewQty;
  q^.DisplayItemDesc := NewItemDesc;
  q^.DisplayTotalTax := NewTotalTax;
  q^.DisplayTotalDue := NewTotalDue;
  PinPadDisplayQueue.Add(q);
end;

procedure TPINPadTransaction.ProcessPINPadDisplayQueue();
{
Process pin pad display queue.  New lines to display are sometimes queued (such as when the
transaction is being reset) when the pin pad would not be able to handle them.  This procedure
makes the delayed call to display those lines on the pin pad display.
}
var
  j : integer;
  QueueList : TList;
  q : pPinPadDisplayMessage;
begin
  UpdateZLog('PIN Pad Display: Process queue');
  try
    QueueList := PinPadDisplayQueue.LockList();
    for j := 0 to QueueList.Count - 1 do
    begin
      try
        q := QueueList.Items[j];
        if (q^.DisplayTransNo = FTransNo) then
        begin
          PINPadNewSaleItem(q^.DisplaySeqNo, q^.DisplayExtPrice, q^.DisplayQty,
                            q^.DisplayItemDesc, q^.DisplayTotalTax, q^.DisplayTotalDue);
        end;
        q^.DisplayItemDesc := '';
        Dispose(q);
        QueueList.Items[j] := nil;
      except
        on e : exception do
          UpdateExceptLog('ProcessPINPadDisplayQueue failed - ' + e.Message);
      end;
    end;
    QueueList.Pack();
  finally
    PinPadDisplayQueue.UnlockList();
  end;
end;

procedure TPINPadTransaction.ProcessPinPadOffline(const qIOMessage : pIOMessage);
begin
  PPDev.Connected := False;
  PinPadOnline := False;
  FStartupState := ppssOffline;
  if not Self.FWaitClose then
  begin
    Inc(FStartupState);
    PinPadStartup;
  end;
end;

procedure TPINPadTransaction.ProcessPinPadOnline(const qIOMessage : pIOMessage);
begin
  if (Length(qIOMessage^.IOText) >= 11) then
  begin
    FApplID := Copy(qIOMessage^.IOText, 4, 4);
    FParmID := Copy(qIOMessage^.IOText, 8, 4);
  end;
  if Self.FStartupState = ppssSendOnline then
  begin
    inc(Self.FStartupState);
    Self.PinPadStartup;
  end;
end;  // procedure ProcessPinPadOnline

procedure TPINPadTransaction.SetDate(const expectresponse : boolean = False);
begin
  SendSetVariableRequest(PINPAD_VAR_ID_DATE, FormatDateTime('mmddyy', Now()), expectresponse);
end;

procedure TPINPadTransaction.SetTime(const expectresponse : boolean = False);
begin
  SendSetVariableRequest(PINPAD_VAR_ID_TIME, FormatDateTime('hhnnss', Now()), expectresponse);
end;

procedure TPINPadTransaction.ProcessPinPadSetPaymentType(const qIOMessage : pIOMessage);
var
  l : integer;
  status : char;
  cardtype : char;
  amount : currency;
begin
  l := Length(qIOMessage^.IOText);
  if (l >= 5) then
  begin
    status := qIOMessage^.IOText[4];
    cardtype := qIOMessage^.IOText[5];
    amount := StrToCurr(copy(qIOMessage^.IOText, 6, l - 5));
    if (status = '1') then  // '0'=Success '1'=Failed '2'='Changed'
      UpdateExceptLog('ProcessPinPadSetPaymentType - Failed.  Msg="' + qIOMessage^.IOText + '"');
    if (cardtype <> Self.CardTypeChar) then
      UpdateExceptLog('ProcessPinPadSetPaymentType - Unexpected card type (' + Self.CardTypeChar + ').  Msg="' + qIOMessage^.IOText + '"');
    {  WTF INGENICO!?!?!?
    if (amount = 0) and (cardtype = 'A') then
      SendSetPaymentType(False, 'B', Self.PinPadAmount);
    }
    //SendSetAmount();  This is a duplicate at this point
  end
  else
  begin
    UpdateExceptLog('ProcessPinPadSetPaymentType - Response too short.  Msg="' + qIOMessage^.IOText + '"');
  end;
end;  // procedure ProcessPinPadSetPaymentType

procedure TPINPadTransaction.ProcessPinPadCardStatus(const qIOMessage : pIOMessage);
var
  cardtype, version, trantype, status : string;
  ct : TCardMediaType;
  ver : integer;
  tt : TTranType;
  cs : TCardStatus;
begin
  cardtype := midstr(qIOMessage^.IOText, 4, 2);
  ct := TCardMediaType(strtoint(cardtype));
  version  := midstr(qIOMessage^.IOText, 6, 2);
  ver := strtoint(version);
  trantype := midstr(qIOMessage^.IOText, 8, 2);
  tt := TTranType(strtoint(trantype));
  status   := midstr(qIOMessage^.IOText, 10, 1);
  cs := TCardStatus(ord(status[1]));
  if Assigned(Self.FOnCardStatusChange) then
    Self.FOnCardStatusChange(Self, ct, ver, tt, cs);
  CheckSignatureEntry := status;
  if status = 'I' then
    swipepending := True
  else if status = 'R' then
    swipepending := False;
end;

procedure TPINPadTransaction.ProcessPinPadHardReset(const qIOMessage : pIOMessage);
begin
  FPinPadFSAmount := 0.0;
  FPinPadFuelAmount := 0.0;
  FPinPadAmount := 0.0;
  FPinPadAccount := '';
  FPinPadExpDate := '';
  SendHardReset(False);
  AuthInfoReceived(FPinPadAmount, '', '', '');  // Cancel credit request with pos
end;  // procedure ProcessPinPadHardReset

procedure TPINPadTransaction.ProcessPinPadStatusResponse(const qIOMessage : pIOMessage);
const
  IDX_STATUS_ID = 4;
  IDX_PROMPT    = 6;
var
  LenMessage : integer;
  CurrentStatusID : string[2];
  CurrentPrompt : string;
begin
  Self.FLastStatus := Now();
  LenMessage := Length(qIOMessage^.IOText);

                                                // madhu gv  16-12-2017    end    }
  if (LenMessage > IDX_STATUS_ID) then
  begin
    // Check to see if status has changed since the last status check:
    CurrentStatusID := Copy(qIOMessage^.IOText, IDX_STATUS_ID, 2);
    if (LenMessage >= IDX_PROMPT) then
      CurrentPrompt := Copy(qIOMessage^.IOText, IDX_PROMPT, LenMessage - IDX_PROMPT)
    else
      CurrentPrompt := '';
    if ((LastStatusID <> CurrentStatusID) or (LastStatusPrompt <> CurrentPrompt)) then
    begin
      UpdateZLog('Pin Pad status: ' + LastStatusID + ' -->  ' + CurrentStatusID + ' : ' + CurrentPrompt);
      if (PinPadPromptChange(CurrentStatusID, CurrentPrompt)) then  // Notify POS of prompt change
        LastStatusPrompt := CurrentPrompt
      else
        UpdateZLog('Pin Pad status: Not changed.');
    end;
    LastStatusID := CurrentStatusID;
    // If payment type still unknown and pin pad prompting as progressed far enough, then request payment type.
    if ((LastStatusID = PINPAD_STATUS_ID_ENTER_PIN) or (LastStatusID = PINPAD_STATUS_ID_AMOUNT)) then
    begin
      if (CardTypeField = CARD_TYPE_FIELD_UNKNOWN) then
        SendGetVariableRequest(PINPAD_VAR_ID_PAYMENT_TYPE);
    end;
    // Do not attempt to reset transaction if pin pad still prompting for signature
    if ((LastStatusID <> PINPAD_STATUS_ID_SIGNATURE_CAPTURE) and
        (LastStatusID <> PINPAD_STATUS_ID_SIGNATURE_AVAIL)) then
    begin
      if (bNewTransNo) then
      begin
        bNewTransNo := False;
        // Status response follows a change in TransNo
        // Either end the previous transaction, or start a new one.
        if (FTransNo = 0) then
          DisplayAdStart := Now() + DisplayAdDelta
        else
        begin
          SendHardReset(bClearDisplayOnNextTransReset);
          ProcessPINPadDisplayQueue();
        end;
      end;
    end;
  end;
end;

function TPINPadTransaction.CheckIfSwipedIS_EMV(pCode : String) : Boolean;
var
   wrkString : String;
   IsThere : Integer;
begin
   // we will use FPinPadTrack1 for this
   // if Service Code starts with 2 then it is EMV
   // Will need to see if we already checked because there might be a problem with the chip so proceed with swipe
   if SwipeCheckCount >= 3 then
   begin
      result := False;
   end
   else if (length(pCode) > 0) then
   begin
      if (Copy(pCode,1,1) = '2') or (Copy(pCode,1,1) = '6') then result := True else result := False;   
   end
   else
   begin
      // now check tghe service code
      wrkString := FPinPadTrack1;
      // now look for the ^
      IsThere := POS('^',wrkString);
      wrkString := Copy(wrkString,IsThere + 1,Length(wrkString));
      IsThere := POS('^',wrkString);
      if (IsThere > 0) then
      begin
         wrkString := Copy(wrkString,IsThere + 1,Length(wrkString));
         if (Copy(wrkString,5,1) <> '1') then
         begin
            result := True;
         end
         else
         begin
            result := False;
         end;
      end
      else
      begin
         result := False;
      end;
   end;
end;

procedure TPINPadTransaction.ProcessPinPadBINLookup(const qIOMessage : pIOMessage);
{
The pin pad device has sent a message indication that a card was swiped:
}
var
  TempStr, EMVTempStr : string;
  idxStart, idxEnd : integer;
  derived : char;
  contactless : boolean;
  t1s, t2s : boolean;
  tracksincluded : boolean;
  MustUseEMV : Boolean;
  PassServiceCode : String;
begin
  tracksincluded := False;
  if (Length(qIOMessage^.IOText) > 12) then
  begin
    FPinPadTrack1 := '';
    FPinPadTrack2 := '';
    FTrack := '';
    derived := Copy(qIOMessage^.IOText, 4, 1)[1];
    contactless := (derived = 'h') or (derived = 'd');
    case lowercase(derived)[1] of
     'h' : Ftrack := '1';
     'd' : Ftrack := '2';
     't' : Ftrack := '0';
    end;
    if contactless then
    begin
      Ftrack := Ftrack + 'R';  // RFID flag
    end;
    IsContactlessEMV := contactless;
    if IsFallbackTransaction = True then
       Ftrack := Ftrack + 'F';
    // Extract the response counter from the message (this value will be
    // used in the eventual response (but first, track data is requested from the device).
    t1s := (Copy(qIOMessage^.IOText, 5, 1) = '1');
    t2s := (Copy(qIOMessage^.IOText, 6, 1) = '1') or (derived = 'T');
    FResponseCounter := Copy(qIOMessage^.IOText, 8, 4);
    // Extract the card account number from the message
    TempStr := Copy(qIOMessage^.IOText, 12, Length(qIOMessage^.IOText) - 12 + 1);
    PassServiceCode := '';
    if Copy(qIOMessage^.IOText,1,3) = '19.' then
    begin
      PassServiceCode := Copy(TempStr,Length(TempStr) - 2,3);
      TempStr := Copy(TempStr,1,Length(TempStr) - 4);
    end;
    if Copy(qIOMessage^.IOText,1,3) = '23.' then
    begin
       TempStr := Copy(qIOMessage^.IOText, 7, Length(qIOMessage^.IOText) - 7 + 1);
       EMVTempStr := TempStr;
       idxEnd := Pos(FS_CHAR, TempStr);
       t1s := true;
       t2s := false;
       tracksincluded := True;
       if (IdxEnd > 0) then
       begin
         FPinPadTrack1 := '%' + Copy(TempStr, 1, idxend - 1) + '?';        
         idxStart := idxend;
         EMVTempStr := Copy(TempStr,idxend + 1, length(TempStr));
         idxEnd := Pos(FS_CHAR, EMVTempStr);
         FPinPadTrack2 := ';' + Copy(EMVTempStr, 1, idxEnd - 1) + '?';
         FAccountNo := Copy(TempStr, 1, Pos('^',TempStr) - 1);
       end
       else
          FAccountNo := TempStr;
       Ftrack := '2';
       if (Length(FPinPadTrack2) <= 2) then
          Ftrack := '1';
       if IsFallbackTransaction = True then
          Ftrack := Ftrack + 'F';
          
    end
    else
    begin
      idxEnd := Pos(FS_CHAR, TempStr);
      if (IdxEnd > 0) then
      begin
        tracksincluded := True;
        FAccountNo := Copy(TempStr, 1, IdxEnd - 1);
        idxStart := idxEnd + 1;
        idxend := PosEx(FS_CHAR, TempStr, idxStart);
        if t1s then
          FPinPadTrack1 := '%' + Copy(TempStr, idxStart, idxend - idxstart) + '?';
        idxStart := idxEnd + 1;
        if t2s then
        begin
          FPinPadTrack2 := ';' + Copy(TempStr, idxStart, Length(qIOMessage^.IOText)-idxstart) + '?';
        end;
      end
      else
        FAccountNo := TempStr;
    end;
  end;
  // Queue a request to get track data
  // (Once track 1 response received, track 2 will be requested -
  //  then POS can be called for the card validation and then BIN lookup response can be sent.)
  // if track data already set

  // I will need to do some additional coding if this is a 23.x response because the [FS] is now a ^ in the Track Data
  //IsContactlessEMV
  if IsContactlessEMV then
  begin
   if (length(PassServiceCode) > 0) then
   begin
      if (Copy(PassServiceCode,1,1) = '2') or (Copy(PassServiceCode,1,1) = '6') then 
         IsContactlessEMV := True 
      else 
         IsContactlessEMV := False;   
   end;
  end;
  if tracksincluded then
  begin
    if FEncryptionEnabled then
      SendGetVariableRequest(PINPAD_VAR_ID_MSR_ENCRYPTEDBLOCK)
    else
    begin
      if contactless then
      begin
         // contactless could either be EMV or MSR so I cannot use the check
         MustUseEMV := False;
      end
      else
      begin
         MustUseEMV := CheckIfSwipedIS_EMV(PassServiceCode);
      end;
      if MustUseEMV then
      begin
         // make them insert the chip card
         // clear the card info
         // send a soft reset to the device
         //SendHardReset(False);
         FResponseCounter := '';
         SendOnline();
         // now alert the cashier to make them insert the card
         fmNBSCCform.ShowMustUseEMV;         
      end
      else
         CardInfoReceived(FPinPadTrack1, FPinPadTrack2, FAccountNo, FTrack);
    end;
  end
  else
    SendGetVariableRequest(PINPAD_VAR_ID_MSR_TRACK1);
  SwipePending := True;
  if MustUseEMV then
     SwipePending := False;
end;

procedure TPINPadTransaction.ProcessPinPadSignatureReady(const qIOMessage : pIOMessage);
begin
  // The customer at the pin pad device has accepted a signature:
  // Start the first of a series of requests to get data regarding the signature.
  SignatureData := '';
  SignatureDataIndex := 0;
  SignatureBlockIndex := 0;
  SignatureBlockHighest := 0;
  SendGetVariableRequest(PINPAD_VAR_ID_SIGNATURE_BLOCK_BYTES);
end;

procedure TPINPadTransaction.ProcessPinPadPINReady(const qIOMessage : pIOMessage);
var
  StatusCode : string[1];
  pinblock : string;
  ksn : string;
begin
  // The pin pad device has responded to a previous "get PIN" request.
  // Extract the PIN data from the message.
  StatusCode := Copy(qIOMessage^.IOText, 4, 1);
  if StatusCode = '0' then
  begin
    pinblock := copy(qIOMessage^.IOText, 5, 16);
    ksn := copy(qIOMessage^.IOText, 21, 20);
    self.AuthInfoReceived(0.01, '', pinblock, ksn);
  end
  else
    self.AuthInfoReceived(0.0, '', '', '');
end;

procedure TPINPadTransaction.ProcessPinPadGetVariableRequest(const qIOMessage : pIOMessage);
const
  STATUS_CODE_SUCCESS             = '2';
  STATUS_CODE_ERROR               = '3';
  STATUS_CODE_INSUFFICIENT_MEMORY = '4';
  STATUS_CODE_INVALID_ID          = '5';
  STATUS_CODE_NO_DATA             = '6';
var
  StatusCode : string[1];
  VariableID : string;
  VariableData : string;
begin
  // The pin pad device has responded to a previous "get variable" request.
  // Extract the variable ID and data from the message.
  if (Length(qIOMessage^.IOText) >= 11) then
  begin
    StatusCode := Copy(qIOMessage^.IOText, 4, 1);
    VariableID := Copy(qIOMessage^.IOText, 9, 3);  // leave off first 3 zeros
    if (StatusCode = STATUS_CODE_SUCCESS) then
      VariableData := Copy(qIOMessage^.IOText, 12, Length(qIOMessage^.IOText))
    else
      VariableData := '';
    if ((StatusCode = STATUS_CODE_SUCCESS) or (StatusCode = STATUS_CODE_NO_DATA)) then
      ProcessNewVariableData(VariableID, VariableData);
  end;
end;

procedure TPINPadTransaction.ProcessPinPadAuthRequest(const qIOMessage : pIOMessage);
{
The customer has provided enough information at the pin pad device to request a card authorization:
}
var
  TempStr : string;
  sAmount : string;
  PINInfo : string;
  idxEnd : integer;
begin
  if (Length(qIOMessage^.IOText) > 62) then
  begin
    // Extract the Terminal serial number and POS trans #.
    // These values eventually will be sent back with the response to the device
    // (after POS receives the credit server response).
    // Also extract the amount and MSR data from the message.
    // (More complete MSR data had already been sent from the PIN pad.)
    FAuthSerialNo := Copy(qIOMessage^.IOText, 47, 8);
    FPOSTransNo := Copy(qIOMessage^.IOText, 56, 4);
    sAmount := '';
    TempStr := Copy(qIOMessage^.IOText, 62, Length(qIOMessage^.IOText));
    idxEnd := Pos(FS_CHAR, TempStr);
    if (IdxEnd > 0) then
    begin
      FPinPadMSRData :=  Copy(TempStr, 1, IdxEnd - 1);
      TempStr := Copy(TempStr, idxEnd + 1, Length(TempStr));
      idxEnd := Pos(FS_CHAR, TempStr);
      if (IdxEnd > 0) then
      begin
        PINInfo := Copy(TempStr, 1, IdxEnd - 1);
        TempStr := Copy(TempStr, idxEnd + 1, Length(TempStr));
        idxEnd := Pos(FS_CHAR, TempStr);
        if (IdxEnd > 0) then
          SAmount := Copy(TempStr, 1, idxEnd - 1);
      end
      else
      begin
        PINInfo := '';
      end;
    end
    else
    begin
      FAccountNo := TempStr;
    end;
    if (sAmount <> '') then
    begin
      try
        if (PinPadTransactionType in [mTransTypeVoid, mTransTypeReturn]) then
          FPinPadAmount := -StrToInt(sAmount) / 100.0
        else
          FPinPadAmount := StrToInt(sAmount) / 100.0;
      except
        FPinPadAmount := 0.0;
        UpdateExceptLog('ProcessPinPadAuthRequest: Cannot convert amount "' + sAmount
                        + '" - Message="' + qIOMessage^.IOText + '"');
      end;
    end
    else
    begin
      FPinPadAmount := 0.0;
    end;
    FPINBlock := Copy(PINInfo, 8, 16);
    FPINSerialNo := Copy(PINInfo, 24, 20);
    // Verify track information device passed in authorization message.
    // It should match one of the two tracks previously requested
    // (back when the device had validated -- i.e., BIN lookup -- the swipe).
    // Format the track data to a standard form used by POS.
    //20091012b...
//    if ((FPinPadMSRData = FPinPadTrack1) or (FPinPadMSRData = FPinPadTrack2)) then
    if ((FPinPadMSRData = FPinPadTrack1) or
        ((Length(FPinPadMSRData) > 0) and (FPinPadMSRData = Copy(FPinPadTrack2, 1, Length(FPinPadMSRData))))) then
    //...20091012b
    begin
      if (FPinPadTrack1 <> '') then
        FPinPadMSRData := FPinPadTrack1;
      if (FPinPadTrack2 <> '') then
        FPinPadMSRData := FPinPadMSRData + FPinPadTrack2;
    end
    else
    begin
      FPinPadMSRData := FPinPadMSRData;
    end;
    // Notify POS that authorization request received:
    if (CardTypeField = CARD_TYPE_FIELD_UNKNOWN) then
      SendGetVariableRequest(PINPAD_VAR_ID_PAYMENT_TYPE)  // AuthInfoReceived will be called when response handled
    else
      AuthInfoReceived(FPinPadAmount, FPinPadMSRData, FPINBlock, FPINSerialNo);
  end;
  SwipePending := False;
end;  // procedure ProcessPinPadAuthRequest

procedure TPINPadTransaction.ProcessPinPadConfWrite(const qIOMessage : pIOMessage);
{
The device is responding after a configuration value was written:
}
begin
  if (Length(qIOMessage^.IOText) > 3) then
  begin
    if ((NewPinPadCreditSignatureLimit >= 0.0) and (qIOMessage^.IOText[4] = RESPONSE_STATUS_SUCCESS)) then
      FPinPadCreditSignatureLimit := NewPinPadCreditSignatureLimit;
  end;
  //SendOnLine();
end;  // procedure ProcessPinPadConfWrite

procedure TPINPadTransaction.advancestartup();
begin
  if Self.FStartupState <> ppssOnline then
  begin
    inc(Self.FStartupState);
    pinpadstartup;
  end;
end;

procedure TPINPadTransaction.handle_idn_cards(const idngroup, idnindex : integer; const msg : string);
const
  LEN_SIGNATURE_LIMIT_FIELD = 6;
var
  TempStr, TempStr2 : string;
  siglimitfield : integer;
  SignatureLimit : integer;
  OldSignatureLimit : integer;
  sSignatureLimit : string;
  RequestedSignatureLimit : currency;
begin
  tempstr := msg;
  case idnindex of
    PINPAD_IDN_CARDS_CREDIT : begin
          begin
            case self.TermModel of
              ppsmISC250 : siglimitfield := 28;
              else
                siglimitfield := 27;
            end;
            if ((Length(TempStr) = 42) or (Length(TempStr) = 53) or (Length(TempStr) = 55)) then
              begin
              // Rest of message text is data for credit cards.
              // Determine if the signature limit portion of this message matches that specified by POS
              try
                SignatureLimit := Round(FPinPadCreditSignatureLimit * 100.0);
              except
                SignatureLimit := -1;
              end;
              RequestedSignatureLimit := FPinPadCreditSignatureLimit;
              // Extract signature limit from message:
              try
                TempStr2 := Copy(TempStr, siglimitfield, LEN_SIGNATURE_LIMIT_FIELD);
                UpdateZLog('Extracted signature limit "%s"', [TempStr2]);
                OldSignatureLimit := StrToInt(TempStr2);
                FPinPadCreditSignatureLimit := OldSignatureLimit / 100.0;
              except
                OldSignatureLimit := -1;
                FPinPadCreditSignatureLimit := -1;
              end;
              UpdateZLog('Pin Pad reports signature limit of %.2g', [FPinPadCreditSignatureLimit]);
              // If POS requested signature limit doesn't match what the pin pad just reported, then
              // prepare to send a message to change the signature limit on the pin pad.
              if ((SignatureLimit <> OldSignatureLimit) and
                  (SignatureLimit >= 0) and (OldSignatureLimit >= 0)) then
              begin
                sSignatureLimit := Format('%*s', [LEN_SIGNATURE_LIMIT_FIELD, IntToStr(SignatureLimit)]);
                Move(sSignatureLimit[1], TempStr[siglimitfield], LEN_SIGNATURE_LIMIT_FIELD);
                NewPinPadCreditSignatureLimit := RequestedSignatureLimit;
                SendConfWrite(IDNGroup, IDNIndex, TempStr);
              end;
              AdvanceStartup;
            end
            else
            begin
              UpdateZLog('Pin Pad responded with data of length %d for %d.%d', [length(tempstr),IDNGroup, IDNIndex]);
              UpdateExceptLog('Pin Pad responded with data of length %d for %d.%d', [length(tempstr),IDNGroup, IDNIndex]);
            end;
          end;
      end;
    PINPAD_IDN_CARDS_DEBIT :
          begin
            TempStr2 := msg;
            UpdateZLog('Debit cashback amount: %s', [Copy(msg, 14, 5)]);
            TempStr[14] := ' ';  // cashback amount = 0
            TempStr[15] := ' ';
            TempStr[16] := ' ';
            TempStr[17] := ' ';
            TempStr[18] := '0';

            TempStr[22] := '1';  // amount index

            TempStr[11] := '1';  // Debit PIN Prompt #17
            TempStr[12] := '7';

            if tempstr <> tempstr2 then
              SendConfWrite(IDNGroup, IDNIndex, TempStr);
            AdvanceStartup;
          end;
    PINPAD_IDN_CARDS_EBT_FOODSTAMPS :
          begin
            TempStr2 := Copy(msg, 22, 1);
            UpdateZLog('Foodstamp amount index: %s', [TempStr2]);
            if TempStr2 <> '2' then
            begin
              TempStr[22] := '2';
              SendConfWrite(IDNGroup, IDNIndex, TempStr);
            end;
            AdvanceStartup;
          end;

    else
      UpdateExceptLog('unhandled 61 response for %d.%d', [idngroup, idnindex]);
    end;
end;

procedure TPINPadTransaction.handle_idn_sig(const idngroup, idnindex : integer; const msg : string);
begin
  case idnindex of
    PINPAD_IDN_SIG_SEND_MESSAGE : begin
      UpdateZLog('Signature ready message enabled flag: %s', [msg]);
      if msg = '0' then
        SendConfWrite(IDNGroup, IDNIndex, '1');
      AdvanceStartup;
    end
  end;
end;

procedure TPINPadTransaction.handle_idn_emv(const idngroup, idnindex : integer; const msg : string);
begin
  case idnindex of
    PINPAD_IDN_EMV_SUPPORT :
          begin
            UpdateZLog('EMV Support Flag: %s', [msg]);
            if msg <> BoolToCharInt(self.FEMVEnabled) then
              SendConfWrite(IDNGroup, IDNIndex, BoolToCharInt(self.FEMVEnabled));
            AdvanceStartup;
          end;
    PINPAD_IDN_EMV_CVMMOD :
        begin
          //UpdateZLog('EMV CVM MOD Flag: %s', [msg]);
          //if msg <> '1' then
          // do not allow CVM modifications from POS
          SendConfWrite(IDNGroup, IDNIndex, '0');
          AdvanceStartup;
        end;
  end;
end;

procedure TPINPadTransaction.handle_idn_stb(const idngroup, idnindex : integer; const msg : string);
begin
  case IDNIndex of
    PINPAD_IDN_STB_ENABLED :
          begin
            UpdateZLog('SpinTheBin enabled flag: %s', [msg]);
            if msg = '0' then
              SendConfWrite(IDNGroup, IDNIndex, '1');
            AdvanceStartup;
          end;
    PINPAD_IDN_STB_TRACKDATA :
          begin
            UpdateZLog('SpinTheBin trackdata enabled flag: %s', [msg]);
            if msg = '0' then
              SendConfWrite(IDNGroup, IDNIndex, '1');
            AdvanceStartup;
          end;
    PINPAD_IDN_STB_CLEARDIGITS :
          begin
            UpdateZLog('SpinTheBin Clear digits : %s', [msg]);
            if msg <> '7' then
              SendConfWrite(IDNGroup, IDNIndex, '7');
            AdvanceStartup;
          end;
  end;
  // append the service code to the end of the 19.x message
  SendConfWrite(5, 10, '1');
  //When there have been no PIN entries entered
  //DevMsg := '60.6' + GS_CHAR + '13' + GS_CHAR + '1';
  SendConfWrite(6, 13, '1');
  // Credit Card Signature Capture
  //"60.1121 0 4  0   0     0 1 1 1 1      0 131 0 1 0 D 1 1 C8E 0"
  SendConfWrite(11, 2, '1 0 4  0   0     0 1 1 1 1      0 131 0 1 0 D 1 1 C8E 0');
  //60.5[GS]10[GS]0  Do not append Service Code to 19 Message
  //This will need to change when we implement EMV version
  SendConfWrite(5, 10, '1');
end;

procedure TPINPadTransaction.handle_idn_ads(const idngroup, idnindex : integer; const msg : string);
begin
  case IDNIndex of
    PINPAD_IDN_ADS_COUNT :
          begin
            try
              Self.AdMax := StrToInt(msg);
            except
              Self.AdMax := 0;
            end;
            AdvanceStartup;
          end;
  end;
end;

procedure TPINPadTransaction.handle_idn_cless(const idngroup, idnindex : integer; const msg : string);
var
  i : integer;
begin
  case IDNIndex of
    PINPAD_IDN_CLESS_ENABLED :
          begin
            UpdateZLog('Contactless enabled flag: %s', [msg]);
            i := StrToInt(msg);
            if i <> integer(Self.FEnableContactless) then
              SendConfWrite(IDNGroup, IDNIndex, IntToStr(integer(Self.FEnableContactless)));
            AdvanceStartup;
          end;
  end;
end;

procedure TPINPadTransaction.handle_idn_security(const idngroup, idnindex : integer; const msg : string);
var
  i : integer;
begin
  case IDNIndex of
    PINPAD_IDN_SECURITY_ENCRYPTION :
          begin
            UpdateZLog('Encryption set to style %s', [msg]);
            i := StrToInt(msg);
            if i <> 0 then
              self.FEncryptionEnabled := True;
            AdvanceStartup;
          end;
  end;
end;

procedure TPINPadTransaction.ProcessPinPadConfRead(const qIOMessage : pIOMessage);
{
The device is responding with a configuration value:
}
var
  status : char;
  LenString : integer;
  TempStr : string;
  sIDNGroup : string;
  sIDNIndex : string;
  sIDNData : string;
  IDNGroup : integer;
  IDNIndex : integer;
  idxGS : integer;
begin
  sIDNData := '';
  LenString := Length(qIOMessage^.IOText);
  idxGS := 0;
  idngroup := 0;
  idnindex := 0;
  if (LenString > 3) then
  begin
    status := qIOMessage^.IOText[4];
    if (status in [RESPONSE_STATUS_SUCCESS, RESPONSE_STATUS_INVALID_ID]) then
    begin
      idxGS := Pos(char($1D), qIOMessage^.IOText);
      if ((idxGS > 5)and (idxGS < LenString)) then
      begin
        // IDN group:
        sIDNGroup := Copy(qIOMessage^.IOText, 5, idxGS - 5);
        try
          IDNGroup := StrToInt(sIDNGroup);
        except
          IDNGroup := 0;
          IDNIndex := 0;
          UpdateExceptLog('ProcessPinPadConfRead: Cannot convert IDNGroup "' + sIDNGroup
                          + '" - Message="' + qIOMessage^.IOText + '"');
        end;
        TempStr := Copy(qIOMessage^.IOText, idxGS + 1, LenString - idxGS);
        // IDN index:
        LenString := Length(tempStr);
        idxGS := Pos(char($1D), TempStr);
        if ((idxGS > 1)and (idxGS <= LenString)) then
        begin
          sIDNIndex := Copy(TempStr, 1, idxGS - 1);
          try
            IDNIndex := StrToInt(sIDNIndex);
          except
            IDNIndex := 0;
            UpdateExceptLog('ProcessPinPadConfRead: Cannot convert IDNIndex "' + sIDNIndex
                            + '" - Message="' + qIOMessage^.IOText + '"');
          end;
        end;
      end;
    end;
    if (idngroup > 0) and (idnindex > 0) then
    begin
      if (status = RESPONSE_STATUS_SUCCESS) then
      begin
        // Extract  subfields (delimited by the GS ASCII character).
        TempStr := Copy(TempStr, idxGS + 1, LenString - idxGS);
        // Check to see if this is the parameter for credit card data:
        case IDNGroup of
          PINPAD_IDN_GROUP_CARDS : handle_idn_cards(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_SIG   : handle_idn_sig(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_EMV   : handle_idn_emv(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_STB   : handle_idn_stb(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_ADS   : handle_idn_ads(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_CLESS : handle_idn_cless(idngroup, idnindex, tempstr);
          PINPAD_IDN_GROUP_SECURITY : handle_idn_security(idngroup, idnindex, tempstr);
        end;
      end
      else if (status = RESPONSE_STATUS_INVALID_ID) then
      begin
        if (IDNGroup = PINPAD_IDN_GROUP_EMV) then
          AdvanceStartup;
      end;
    end
  end;
end;  // procedure ProcessPinPadConfRead

procedure TPINPadTransaction.ProcessPinPadFileWrite(const qIOMessage : pIOMessage);
{
The device is responding to a block of file data sent to it:
}
var
  idx : integer;
  status : char;
  filelength : string;
  filename : string;
begin
  idx := Pos('.', qIOMessage.IOText);
  status := qIOMessage.IOText[idx + 1];
  filelength := copy(qIOMessage.IOText, idx+2, 12);

  if status = '0' then
  begin
    if filelength <> '' then // file transfer complete
    begin
      filename := LoadFileBuffer.FilePath; // used as a temp var here
      LoadFileBuffer.FilePath := '';  // Signal to caller that transfer is complete
      DownloadComplete(ExtractFileName(filename), False);
    end
    else
      SendFileWrite();  // send next block
  end
  else
  begin
    PPDev.LogEvent(Format('Problem writing file %s - status %s, aborting', [ LoadFileBuffer.FilePath, status ]));
    LoadFileBuffer.FilePath := '';
  end;

end;  // procedure ProcessPinPadFileWrite

procedure TPINPadTransaction.PPDevMsgReceived(Sender : TObject; Buffer : pChar; Count : integer);
{
The pin pad device has received a complete message or an error:
}
var
  j : integer;
  q : pChar;
  qIOMessage : pIOMessage;
begin
  bPinPadOpening := False;
  New(qIOMessage);
  // Determine message type:
  if ((Count > 0) and (Count < MAX_SERIAL_BUFFER_LENGTH) and (Buffer <> nil)) then
  begin
    // Valid data actually received from device (as opposed to some sort of error such as timeout).
    SetLength(qIOMessage^.IOText, Count);
    q := Buffer;
    for j := 1 to Count do
    begin
      qIOMessage^.IOText[j] := Char(q^);
      Inc(q);
    end;
    qIOMessage^.IOType := mIOTypeText;
    TEFTDevice(Sender).Ack;
  end
  else if (Count >= MAX_SERIAL_BUFFER_LENGTH) then
  begin
    qIOMessage^.IOType := mIOTypeError;
    qIOMessage^.IOText := '*** buffer overflow ***';
    TEFTDevice(Sender).Nak;
  end
  else
  begin
    qIOMessage^.IOText := '*** invalid buffer ***';
  end;
  // Queue message handler
  PostMessage(FPinPadTransHandle, WM_PIN_PAD_DEV_RESP, 0, LongInt(qIOMessage));
end;  // procedure PPDevMsgReceived

procedure TPINPadTransaction.PPDevAckReceived(Sender: TObject ; msg : pOutboundMessage);
var
  qIOMessage : pIOMessage;
begin
  bPinPadOpening := False;
  New(qIOMessage);
  qIOMessage^.IOType := mIOTypeACK;
  qIOMessage^.IOText := ACK_CHAR;
  // Queue message handler
  PostMessage(FPinPadTransHandle, WM_PIN_PAD_DEV_RESP, LongInt(msg), LongInt(qIOMessage));
end;

procedure TPINPadTransaction.PPDevNakReceived(Sender: TObject; Count: integer);
var
  qIOMessage : pIOMessage;
begin
  bPinPadOpening := False;
  New(qIOMessage);
  qIOMessage^.IOType := mIOTypeNAK;
  qIOMessage^.IOText := NAK_CHAR;
  // Queue message handler
  PostMessage(FPinPadTransHandle, WM_PIN_PAD_DEV_RESP, 0, LongInt(qIOMessage));
end;

procedure TPINPadTransaction.PPDevTimeoutEvent(Sender: TObject; Count: integer);
var
  qIOMessage : pIOMessage;
begin
  bPinPadOpening := False;
  New(qIOMessage);
  qIOMessage^.IOType := mIOTypeTimeout;
  qIOMessage^.IOText := '';
  // Queue message handler
  PostMessage(FPinPadTransHandle, WM_PIN_PAD_DEV_RESP, 0, LongInt(qIOMessage));
end;


function TPINPadTransaction.SendEMV_FALLBACK() : Boolean;
var
  DevMsg : string;
  rSult : Boolean;
begin
  // must always send this so the PINPAD is reset to a normal state
  DevMsg := PINPAD_MSG_ID_ONLINE + FReqApplID + FReqParmID;
  SendMessageToDevice(DevMsg);
  rSult := False;
  if SwipeCheckCount >= 3 then
  begin
    IsFallbackTransaction := True;
     // send fallback
     SendMessageToDevice('28.900004201',False);
     rSult := True;
  end;
  Result := rSult;
end;

procedure TPINPadTransaction.PPDevBadLRCEvent(Sender: TObject);
var
  qIOMessage : pIOMessage;
begin
  bPinPadOpening := False;
  New(qIOMessage);
  qIOMessage^.IOType := mIOTypeBadLRC;
  TEFTDevice(Sender).Nak;
  // Queue message handler
  PostMessage(FPinPadTransHandle, WM_PIN_PAD_DEV_RESP, 0, LongInt(qIOMessage));
end;

procedure TPINPadTransaction.PINPadOpen();
begin
  FLastAllowedString := '';
  Self.FOnlineAttempt := Now();
  Self.PinPadTimer.Enabled := True;
  Self.FLastAdCheck := 0;
  Self.FLastStatus := 0;
  // If first time, create the pin pad device instance:
  if (PPDev = nil) then
  begin
    PPDev := TEFTDevice.Create(Self, FPinPadPortNo, FPinPadBaudRate, FPinPadDataBits, FPinPadStopBits, FPinPadParity, tlsIBM);
    PPDev.AutoSendNext := False;
    PPDev.LogPrefix := 'PinPad';
    PPDev.OnMsgReceived := PPDevMsgReceived;
    PPDev.OnVerbAck := Self.PPDevAckReceived;
    PPDev.OnNak := Self.PPDevNakReceived;
    PPDev.OnTimeout := Self.PPDevTimeoutEvent;
    PPDev.OnBadLRC := Self.PPDevBadLRCEvent;
    // Mask track 1 and track 2 variables.
    PPDev.AddLogMask('29.20000406', tmdIn, 12, -3, 2);
    PPDev.AddLogMask('29.20000407', tmdIn, 12, -3, 2);
    // Mask Authorization Request
    PPDev.AddLogMask('50.', tmdIn, 60, -3, 2);
    // Mask Account number setting
    PPDev.AddLogMask('12.', tmdOut, 4, -3, 2);
    // Mask BIN Lookup and response
    PPDev.AddLogMask('19.', tmdOut, 9, -3, 2);
    PPDev.AddLogMask('19.', tmdIn, 12, -3, 2);
    PPDev.AddLogMask('31.', tmdOut, 14, -7, 2);
    PPDev.AddLogMask(TLogMaskIngTags.Create('T57', tmdIn, 6, -2 )); // mask track 2 equivalent tag
    PPDev.AddLogMask(TLogMaskIngTags.Create('T5A', tmdIn, 6, -4 )); // mask pan tag
    PPDev.AddLogMask(TLogMaskIngTags.Create('TF524', tmdIn, 1, 0)); // mask expdate
    PPDev.AddLogMask(TLogMaskIngTags.Create('T5F20', tmdIn, 4, -2 )); // mask name
    PPDev.AddLogMask(TLogMaskIngTags.Create('T9F0B', tmdIn, 4, -2 )); // mask extended name
    PPDev.LoggingEnabled := Self.FLogging;
    PPDev.LogEvent('TPINPadTransaction.PINPadOpen - just initialized PPDev');
  end;
  // Open the port (if not already open) and send a request to determine setting for signature limit:
  PPDev.LogEvent('TPINPadTransaction.PINPadOpen - Starting');
  PPDev.LogEvent('PinPad.Enabled property set to %s', [BoolToStr(Enabled,True)]);  
  PPDev.Connected := True;
  bPinPadOpening := True;
  Self.FStartupState := ppssOffline;
  Inc(Self.FStartupState);
  PinPadStartup();
end;

procedure TPINPadTransaction.PINPadClose();
begin
  try
    LoadFileBuffer.FilePath := '';
    PPDev.LogEvent('TPINPadTransaction.PINPadClose - Starting');
    PPDev.FlushOutQueue;
    SendOffline();
    FWaitClose := True;  // When response (or timeout) received, port will be closed:
  except
    on e : exception do
      UpdateExceptLog('PIN Pad Close failed - ' + e.Message);
  end;
end;

procedure TPINPadTransaction.PINPadCancelAction();
begin
  PinPadTransReset();
  SendHardReset(False);
end;

procedure TPINPadTransaction.PINPadTransReset();
var
  i : TPayment;
begin
  FTransNo := 0;
  bNewTransNo := False;
  FPinPadAccount := '';
  FPinPadExpDate := '';
  FbPinPadVoidTransaction := False;
  PinPadTransactionType := mTransTypeUndef;
  FPinPadFSAmount := 0.0;
  FPinPadFuelAmount := 0.0;
  FPinPadAmount := 0.0;
  FbBalanceInquiry := False;
  FPinPadTrack1 := '';
  FPinPadTrack2 := '';
  FTrack := '';
  FPinPadMSRData := '';
  FEncryptedTrackData := '';
  FPINBlock := '';
  FPINSerialNo := '';
  FPinPadInputCount := 0;
  FResponseCounter := '';
  FAccountNo := '';
  if (bClearDisplayOnNextTransReset) then
  begin
    LastTransNoDisplayed := -1;
    LastSeqNoDisplayed := -1;
    LastTotalTaxDisplayed := 0.0;
    LastTotalDueDisplayed := 0.0;
  end;
  for i := Low(Self.FPaymentQualifies) to High(Self.FPaymentQualifies) do
    Self.FPaymentQualifies[i] := True;
  if Self.PinPadOnLine then
    Self.SendSetAllowedPayments;
  SwipePending := False;
  if assigned(self.creditresponse) then
    dispose(self.creditresponse);
  self.creditresponse := nil;
  //SendAdRequest(1);
end;

procedure TPINPadTransaction.PINPadReBoot();
begin
  SendReBoot();
  FWaitClose := True;
  PinPadOnLine := False;
  PinPadTransReset();
end;

procedure TPINPadTransaction.DisplaySaleLine(const line : integer; const pPSL : pPPSaleLine);
var
  QtyText : string;
  DisplayText : string;
  LineID : string;
begin
  if not Enabled then exit;
  if ((pPSL.Qty = 1.0) or (Frac(pPSL.Qty) <> 0.0)) then
    QtyText := '    '
  else
    QtyText := Format('%4s', [CurrToStr(pPSL.Qty) + '@']);
  LineID := Format('11%d', [line + 1]);
  DisplayText := LeftStr(format('%7s %4s - %s', [FormatFloat('###.00 ;###.00-', pPSL.ExtPrice), QtyText, pPSL.Desc] ), MAX_DISPLAY_WIDTH);
  SendSetVariableRequest(LineID, DisplayText, True);
  UpdateZLog('PIN Pad Display: %s', [DisplayText]);  
end;

procedure TPINPadTransaction.DisplayTotalLine(const totaldue : currency; const totaltax : currency; const scroll : boolean = True);
var
  LineID : string;
  DisplayText : string;
begin
  if scroll then
    LineID := PINPAD_VAR_ID_SCROLL_DISPLAY
  else          
    LineID := Format('11%d', [Self.ReceiptLines + 1]);
  // Display (or re-display) sales total information:
  DisplayText := LeftStr(format('%7s      - Total   ($%s - Tax)', [FormatFloat('###.00 ;###.00-', TotalDue), FormatFloat('##.00 ;##.00-', TotalTax)]), MAX_DISPLAY_WIDTH);
  SendSetVariableRequest(LineID, DisplayText, True);
  UpdateZLog('PIN Pad display Total (scrolled : %s): %s', [BoolToStr(scroll, True), DisplayText]);

end;


procedure TPINPadTransaction.PINPadNewSaleItem(const NewSeqNo : integer;
                                               const NewExtPrice : currency;
                                               const NewQty : currency;
                                               const NewItemDesc : string;
                                               const NewTotalTax : currency;
                                               const NewTotalDue : currency);
{
Called by POS to indicate changes to sales information to display on pin pad.
}
var
  pPSL : pPPSaleLine;
begin
  if not Enabled then
  begin
    exit;
  end;
  // If transaction just started, then device may not yet be ready for display information, so queue it:
  if (bNewTransNo) then
  begin
    QueuePINPadDisplayItem(NewSeqNo, NewExtPrice, NewQty, NewItemDesc, NewTotalTax, NewTotalDue);
  end
  // Check to see if there is any new data to display:
  // (POS sometimes goes through logic that recalls this method without changes).
  else if ((LastSeqNoDisplayed <> NewSeqNo) or
          (LastTransNoDisplayed <> FTransNo) or
           (LastTotalDueDisplayed <> NewTotalDue) or (LastTotalTaxDisplayed <> NewTotalTax)) then
  begin
    LastTotalTaxDisplayed := NewTotalTax;
    LastTotalDueDisplayed := NewTotalDue;
    // Clear the line item display for the first item.
    if (NewSeqNo = 1) then
      SendSoftReset(PINPAD_RESET_TYPE_CLEAR_ITEM_DISPLAY);
    // If new sales item to display (not just a total change), then scroll up:
    if ((LastTransNoDisplayed <> FTransNo) or (LastSeqNoDisplayed <> NewSeqNo) or (NewSeqNo = 1)) then
    begin
      LastTransNoDisplayed := FTransNo;
      LastSeqNoDisplayed := NewSeqNo;
      new(pPSL);
      pPSL.SeqNo := NewSeqNo;
      pPSL.Qty := NewQty;
      pPSL.Desc := NewItemDesc;
      pPSL.ExtPrice := NewExtPrice;
      DisplaySaleLine(Self.ReceiptLines, pPSL);
      dispose(pPSL);
    end;
    DisplayTotalLine(NewTotalDue, NewTotalTax, True);
  end;
end;

procedure TPINPadTransaction.PINPadAuthResponse(const bApproved : boolean;
                                                const AuthID    : integer;
                                                const ApprovalCode : string;
                                                const PINPadDisplayMsg : string);
begin
  if bApproved then
    AuthorizedAuthID := AuthID;
  SendAuthResponse(bApproved, ApprovalCode, PINPadDisplayMsg);
end;

procedure TPINPadTransaction.ReIssueSignatureCapture(const TransAuthID : integer;
                                                     const SignatureReCapturePrompt : string);
begin
  AuthorizedAuthID := TransAuthID;
  SendSignatureRequest(SignatureReCapturePrompt);
end;

procedure TPINPadTransaction.SetCardTypeField(const NewCardTypeField : smallint);
begin
  FCardTypeField := NewCardTypeField;
  if      (FCardTypeField = CARD_TYPE_FIELD_DEBIT)  then FPinPaymentSelect := PIN_DEBIT
  else if (FCardTypeField = CARD_TYPE_FIELD_CREDIT) then FPinPaymentSelect := PIN_CREDIT
  else if (FCardTypeField = CARD_TYPE_FIELD_EBT_CB) then FPinPaymentSelect := PIN_EBT_CB
  else if (FCardTypeField = CARD_TYPE_FIELD_EBT_FS) then FPinPaymentSelect := PIN_EBT_FS
  else if (FCardTypeField = CARD_TYPE_FIELD_GIFT)   then FPinPaymentSelect := PIN_CREDIT;
end;

procedure TPINPadTransaction.SetTransNo(const TransNo : integer);
begin
  if not enabled then
  begin
    FTransNo := 0;
    ShowAds();
    exit;
  end;
  if (FTransNo <> TransNo) then
  begin
    // Display should be cleared when starting or ending a sales transaction, but not when
    // switching transaction numbers due to a partial tender or card decline.
    bClearDisplayOnNextTransReset := ((FTransNo = 0) or (TransNo = 0));
    PINPadTransReset();
    // Save the new transaction number, but delay any action until next status response.
    FTransNo := TransNo;
    bNewTransNo := True;
    FSignatureCaptured := False; //reset captured flag
    // If display did not clear, then associate the new transaction # with the displayed items.
    if (not bClearDisplayOnNextTransReset) then
      LastTransNoDisplayed := FTransNo;
    if ((FTransNo = 0) or (bClearDisplayOnNextTransReset)) then
    begin
      FPinPaymentSelect := PIN_NO_TYPE;
      DisplayAdStart := Now() + DisplayAdDelta;
      Self.FLastStatusSent := 0;
      ManageStatusRequests;
    end;
    if (FTransNo <> 0) then // If start of new transaction,
      DisplayAdStart := 0;  //   then cancel start of ads queued after previous transaction.
  end;
end;

procedure TPINPadTransaction.SetPinPadFSAmount(const cAmount : currency);
begin
  if not Enabled then
    exit;
  FPinPadFSAmount := cAmount;
end;


procedure TPINPadTransaction.SetPinPadAmount(const cAmount : currency);
var
  NewTransactionType : TTransactionType;
begin
  if not Enabled then
    exit;
  // Determine transaction type (based on sign of amount)
  if (FbPinPadVoidTransaction) then
  begin
    if (cAmount < 0.0) then
      NewTransactionType := mTransTypeVoidReturn
    else
      NewTransactionType := mTransTypeVoid;
  end
  else
  begin
    if (cAmount < 0.0) then
      NewTransactionType := mTransTypeReturn
    else
      NewTransactionType := mTransTypeSale;
  end;
  // If transaction type has changed, then notify device.
  if (PINPadTransactionType <> NewTransactionType) then
  begin
    PINPadTransactionType := NewTransactionType;
    //SendSetTransactionType();
  end;
  if (FPINPadAmount <> cAmount) then
  begin
    // New "charge amount" must be given to pin pad device.  The device uses the amount
    // for amount verification prompting and certain customer interaction is delayed until
    // an amount is received (i.e., customer had been prompted to "wait" for clerk).
    FPINPadAmount := cAmount;
    //SendSetAmount();
    //SendSetPaymentType(True, 'B', cAmount); //Self.PinPadAmount);
  end;
end;

procedure TPINPadTransaction.SetPinPadAccount(const sAccount : string);
begin
  // Pin pad device needs the account number to encrypt a PIN (only needed from POS if card requiring
  // PIN is not swiped at PIN pad).
  if (FPinPadAccount <> sAccount) then
  begin
    FPinPadAccount := sAccount;
    if ((FPinPadAccount <> '') and (FPinPadExpDate <> '')) then
      SendSetAccount();
  end;
end;

procedure TPINPadTransaction.SetPinPadExpDate(const sExpDate : string);
begin
  // Basically same function as SetPinPadAccount (both acct. # and exp. date are part of account information).
  if (FPinPadExpDate <> sExpDate) then
  begin
    FPinPadExpDate := sExpDate;
    if ((FPinPadAccount <> '') and (FPinPadExpDate <> '')) then
      SendSetAccount();
  end;
end;

procedure TPINPadTransaction.CheckFileTransferStartStop();
{
Called when load file path is changed:
If set, initiate a file transfer; if cleared, then abort file transfer (if in progress).
}
begin
  if ((FDirPath <> '') and (FFileName <> '')) then
  begin
    LoadFileBuffer.FilePath := FDirPath + FFileName;
    SendFileWrite();                // initiate file transfer (processing of response will send next block)
  end
  else
  begin
    LoadFileBuffer.FilePath := '';  // will abort the transfer (if still in progress)
  end;
end;

procedure TPINPadTransaction.SetPinPadCreditSignatureLimit(const SignatureLimit : currency);
begin
  if (PinPadOnline) or (Self.FStartupState > ppssQueryCards) then
    raise exception.CreateFmt('Cannot set signature limit while pin pad is online (%s,%s).', [BoolToStr(PinPadOnline, True), PPStartupStateToString(Self.FStartupState)])
  else
    FPinPadCreditSignatureLimit := SignatureLimit;
end;

procedure TPINPadTransaction.SetLoadFileDir(const LFDir : string);
{
Basically same function as SetLoadFileName (both dir and file name need to be set)
}
begin
  FDirPath := LFDir;
  try
    if not DirectoryExists(FDirPath) then
      MkDir(FDirPath);
  except
    on E: Exception do
      UpdateExceptLog('Problem creating directory %s - (%s) %s', [FDirPath, E.ClassName, E.Message]);
  end;
  FAdDirPath := LFDir + 'ads\';
  try
    if not DirectoryExists(FAdDirPath) then
      MkDir(FAdDirPath);
  except
    on E: Exception do
      UpdateExceptLog('Problem creating ad directory %s - (%s) %s', [FDirPath, E.ClassName, E.Message]);
  end;
  
  CheckFileTransferStartStop();
end;

procedure TPINPadTransaction.SetLoadFileName(const LFName : string);
{
Basically same function as SetLoadFileDir (both dir and file name need to be set)
}
begin
  FFileName := LFName;
  CheckFileTransferStartStop();
end;

function TPINPadTransaction.GetPinPadInputs(Index : Integer) : pPINPadInput;
begin
  Result := @(FPinPadInputs[Index]);
  FLastInput := Result;
end;

procedure TPINPadTransaction.SetPinPadInputs(Index : Integer; Value : pPINPadInput);
begin
  FPinPadInputs[Index] := Value^;
end;

procedure TPINPadTransaction.SetbBalanceInquiry(const bBalanceInq : boolean);
begin
  if not Enabled then
    exit;
  if FbBalanceInquiry xor bBalanceInq then
  begin
    if bBalanceInq then
    begin
      SendSetAmount();
      Self.TransNo := TRANSNO_BALANCE_INQUIRY;
    end
    else
    begin
      SendHardReset(True);
      Self.TransNo := 0;
    end;
    FbBalanceInquiry := bBalanceInq;
  end;
end;

procedure TPINPadTransaction.SendOnline();
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_ONLINE + FReqApplID + FReqParmID;
  SendMessageToDevice(DevMsg);
  //We will send the action to make the Green Button work like Cancel
  
end;

procedure TPINPadTransaction.SendOffline();
var
  DevMsg : string;
begin
  try
    DevMsg := PINPAD_MSG_ID_OFFLINE + '0000';
    SendMessageToDevice(DevMsg);
  except
    on e : exception do
      UpdateExceptLog('Send offline message to Pad failed - ' + e.Message);
  end;
end;

function TPINPadTransaction.BoolToCharInt(Value : boolean) : char;
begin
  if Value then
    Result := '1'
  else
    Result := '0';
end;

procedure TPINPadTransaction.SendSetPaymentType(const conditional : boolean; const cardtype : char; const amount : currency);
var
  DevMsg : string;
begin
  
  DevMsg := PINPAD_MSG_ID_SET_PAYMENT_TYPE +
            BoolToCharInt(conditional) +                                 // '0' for unconditional; '1' for conditional
            CardType +
            Format('%.3d', [Round(Amount * 100.0)]);
  if (Round(Amount * 100.0) <> 0.00) then
     SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.SendSetAllowedDebitCredit();
begin
  Self.FLastAllowedString := '1100000000000000';
  SendMessageToDevice(PINPAD_MSG_ID_SET_ALLOWED_PAYMENTS + Self.FLastAllowedString, False);
end;

procedure TPINPadTransaction.SendSetAllowedPayments();
{
Let the pin pad know what the valid payment types are for the last card swiped.
This call is only needed if the BIN lookup process (which results in a
credit server ValidCard() call) could not determine the payment type (for example,
a card number begining in '4' could be VISA credit or debit).
}
var
  DevMsg : string;
  EnablePaymentArray : string;
  i : TPayment;
begin
  EnablePaymentArray := '';
  for i := Low(Self.FPaymentAllowed) to High(Self.FPaymentAllowed) do
    EnablePaymentArray := EnablePaymentArray + BoolToCharInt(Self.FPaymentAllowed[i] and Self.FPaymentQualifies[i]);
  DevMsg := PINPAD_MSG_ID_SET_ALLOWED_PAYMENTS + EnablePaymentArray;
  if FLastAllowedString <> EnablePaymentArray then
    SendMessageToDevice(DevMsg, False);
  Self.FLastAllowedString := EnablePaymentArray;
  if Self.FStartupState = ppssSetAllowedPayments then
  begin
    Inc(Self.FStartupState);
    Self.PinPadStartup;
  end;
end;

procedure TPINPadTransaction.SendHardReset(const bClearLineDisplay : boolean);
var
  DevMsg : string;
begin
  if (bClearLineDisplay) then
    DevMsg := PINPAD_MSG_ID_HARD_RESET + '1'
  else
    DevMsg := PINPAD_MSG_ID_HARD_RESET + '0';
  SendMessageToDevice(DevMsg, False);
  Self.SwipePending := False;
end;

procedure TPINPadTransaction.SendStatusRequest();
var
  DevMsg : string;
begin
  Self.FLastStatusSent := Now();
  DevMsg := PINPAD_MSG_ID_STATUS_REQUEST;
  SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.SendSetAccount();
var
  DevMsg : string;
  ExpDateField : string[4];
begin
  if (Length(FPinPadExpDate) = 4) then
    ExpDateField := Copy(FPinPadExpDate, 3, 2) + Copy(FPinPadExpDate, 1, 2)
  else
    ExpDateField := '4912';
  DevMsg := PINPAD_MSG_ID_SET_ACCOUNT + FPinPadAccount + '=' + ExpDateField;
  SendMessageToDevice(DevMsg, False);
end;


procedure TPINPadTransaction.SendInitialSetAmount(sAmount : Currency);
var
  DevMsg : string;
  DevAmount : String;
begin
  if (CardTypeField = CARD_TYPE_FIELD_EBT_FS) then
  begin
    PinPadNewSaleItem(LastSeqNoDisplayed, 0.0, 0.0, '', 0.0, sAmount);
  end;
  FPinPadAmount := sAmount;
  // pad with 6 zeros
  DevAmount := IntToStr(Round(sAmount * 100.0));
  DevMsg := PINPAD_MSG_ID_SET_AMOUNT + DevAmount;
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendSetAmount();
var
  DevMsg : string;
begin
  if (CardTypeField = CARD_TYPE_FIELD_EBT_FS) then
  begin
    PinPadNewSaleItem(LastSeqNoDisplayed, 0.0, 0.0, '', 0.0, FPinPadAmount);
  end;
  DevMsg := PINPAD_MSG_ID_SET_AMOUNT + Format('%.*d',[0,Round(FPinPadAmount * 100.0)]);
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendSetTransactionType();
const
  TRANS_TYPE_SALE        = '01';
  TRANS_TYPE_VOID        = '02';
  TRANS_TYPE_RETURN      = '03';
  TRANS_TYPE_VOID_RETURN = '04';
var
  DevMsg : string;
  TransactionTypeField : string[2];
begin
  case PinPadTransactionType of
    mTransTypeUndef      : begin
      PPDev.LogEvent('SendSetTransactionType - TransType == undef - forcing to sale');
      TransactionTypeField := TRANS_TYPE_SALE;
    end;
    mTransTypeVoid       : TransactionTypeField := TRANS_TYPE_VOID;
    mTransTypeReturn     : TransactionTypeField := TRANS_TYPE_RETURN;
    mTransTypeVoidReturn : TransactionTypeField := TRANS_TYPE_VOID_RETURN;
  else
                           TransactionTypeField := TRANS_TYPE_SALE;
  end;

  DevMsg := PINPAD_MSG_ID_SET_TRANSACTION_TYPE + TransactionTypeField;
  SendMessageToDevice(DevMsg, False);
end;


procedure TPINPadTransaction.SendReadCard();
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_CARD_READ_REQUEST
            + 'We always charge Josh Johnsons card here at 7-Eleven'
            + FS_CHAR  + FS_CHAR + '1' + FS_CHAR + 'MS';
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendSoftReset(const ResetType : char);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_SOFT_RESET + ResetType;
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendBINLookupResponse(const CardType : string;
                                                   const bAskDebit : boolean;
                                                   const bBINRange : boolean;
                                                   const bValidated : boolean);
var
  DevMsg : string;
  j : TPayment;
begin
  // Let pin pad device know about the card type
  // If type is "invalid", device will re-prompt a swipe;
  // if "unknown", it will prompt for payment type (e.g., "credit", "debit"...)
  if (not bValidated) then
  begin
    CardTypeField := CARD_TYPE_FIELD_INVALID;
    // Done with track data if card not valid
    FPinPadTrack1 := '';
    FPinPadTrack2 := '';
    FTrack := '';
    SwipePending := False;
  end
  else if ((CardType = CT_EBT_CB) or (CardType = CT_EBT_FS)) then
  begin
    // EBT card type.  If both cash back and food stamps supported, then prompt for which one.
    if ((Self.FPaymentAllowed[pt_EBTCash]) and (Self.FPaymentAllowed[pt_EBTFS]) and (FPinPadFSAmount <> 0.0)) then
    begin
      CardTypeField := CARD_TYPE_FIELD_UNKNOWN;
      for j := Low(Self.FPaymentQualifies) to High(Self.FPaymentQualifies) do
        Self.FPaymentQualifies[j] := (j in [pt_EBTCash, pt_EBTFS]);  // (todo) - pt_debit may also need to be choice if debit allowed
    end
    else  if (Self.FPaymentAllowed[pt_EBTCash] and
             ((CardType = CT_EBT_CB) or ((FPinPadFSAmount = 0.0)))) then  // force to CB if no FS amounts
      CardTypeField := CARD_TYPE_FIELD_EBT_CB
    else  if ((CardType = CT_EBT_FS) and Self.FPaymentAllowed[pt_EBTFS] and (FPinPadFSAmount <> 0.0)) then
      CardTypeField := CARD_TYPE_FIELD_EBT_FS
    else
      CardTypeField := CARD_TYPE_FIELD_INVALID;
  end
  else if (bAskDebit) or (CardType = CT_DEBIT) then
  begin
    CardTypeField := CARD_TYPE_FIELD_DEBIT;
    SendSetAllowedDebitCredit()
  end
  else if (bBINRange and (CardType = CT_GIFT)) then
    CardTypeField := CARD_TYPE_FIELD_GIFT_FUEL_ONLY
  else  if (CardType = CT_GIFT) then
    CardTypeField := CARD_TYPE_FIELD_GIFT
  else
    CardTypeField := CARD_TYPE_FIELD_CREDIT;
  if (CardTypeField = CARD_TYPE_FIELD_UNKNOWN) and bValidated then
    SendSetAllowedPayments();
  if not bValidated then
  begin
    if Self.FRBAVersion < 4.0 then
      SendHardReset(False);
  end
  else
  begin
    if (FResponseCounter <> '') and (IsContactlessEMV <> True) then
    begin
      DevMsg := PINPAD_MSG_ID_BIN_LOOKUP + Self.CardTypeChar + FResponseCounter + FAccountNo;
      SendMessageToDevice(DevMsg, False);
    end
    else
    begin
      SendSetPaymentType(True, Self.CardTypeChar, FPinPadAmount);
      SendInitialSetAmount(FPinPadAmount);
    end;
  end;
  if (FbBalanceInquiry) then
    SendSetPaymentType(False, Self.CardTypeChar, 0);  // Used to set amount to zero on pinpad
end;

procedure TPINPadTransaction.SendSignatureRequest(const SignatureCapturePrompt : string);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_SIGNATURE_READY + SignatureCapturePrompt;
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendNumericEntryRequest(const displaychar : char; const prompt : string; const mindigits, maxdigits : integer; const formatspec : string ; const formspec : string);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_NUMERIC_INPUT_REQUEST + displaychar;
  if (mindigits < 1) or (mindigits > 20) then
    DevMsg := DevMsg + '00'
  else
    DevMsg := DevMsg + Format('%02d', [mindigits]);
  if (maxdigits < 1) or (maxdigits > 20) then
    DevMsg := DevMsg + '20'
  else
    DevMsg := DevMsg + Format('%02d', [maxdigits]);
  DevMsg := DevMsg + prompt;
  if (formatspec <> '') then
    DevMsg := DevMsg + FS_CHAR + formatspec;
  if (formspec <> '') then
    DevMsg := DevMsg + FS_CHAR + formspec;
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendNumericEntryRequest(const displaychar : char; const prompt, mindigits, maxdigits : integer; const formatspec : integer; const formspec : string);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_NUMERIC_INPUT_REQUEST + displaychar + format('%2.2d%2.2d%d', [mindigits, maxdigits, prompt]);
  if formatspec <> -1 then
    DevMsg := DevMsg + FS_CHAR + format('%d', [formatspec]);
  if formspec <> '' then
    DevMsg := DevMsg + FS_CHAR + formspec;
  SendMessageToDevice(DevMsg, False);
end;


procedure TPINPadTransaction.SendSetVariableRequest(const VarID : string;
                                                    const VariableText : string;
                                                    const bRequestResponse : boolean);
var
  RespType : string[1];
  DevMsg : string;
begin
  if (bRequestResponse) then
    RespType := '1'
  else
    RespType := '9';
  DevMsg := PINPAD_MSG_ID_SET_VARIABLE_REQUEST + RespType + '1000' + VarID + VariableText;
  SendMessageToDevice(DevMsg, bRequestResponse);
end;

procedure TPINPadTransaction.SendGetVariableRequest(const VarID : string);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_GET_VARIABLE_REQUEST + '00000' + VarID;
  SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.SendAdRequest(const adno : smallint = 0);
var
  DevMsg : string;
begin
  if PinPadOnline and (Self.EntryPrompt = ppeNone) then
  begin
    Self.FAdDisplayTime := Now();
    DevMsg := PINPAD_MSG_ID_AD_REQUEST + IntToStr(adno);
    SendMessageToDevice(DevMsg, False);
  end;
end;

procedure TPINPadTransaction.SendPINRequest(const acctno : string = '');
var
  DevMsg : string;
begin
  if PinPadOnline then
  begin
    devmsg := PINPAD_MSG_ID_PIN_REQUEST + 'D*1';
    if acctno <> '' then
      devmsg := devmsg + FS_CHAR + acctno;
    SendMessageToDevice(DevMsg, False);
  end
  else
    UpdateZLog('Pin pad offline');
end;


procedure TPINPadTransaction.SendEMVAuthResponse(const Resp : pCreditResponseData);
begin
  self.creditresponse := resp;
  InvalidPIN_Entered := False;
  if resp.sEMVresp <> '' then
  begin
    if (Uppercase(resp.sCCAuthMsg) = 'INVALID ID NBR') then
    begin
       InvalidPIN_EnteredCount := InvalidPIN_EnteredCount + 1;
       // Online PIN Decline
       {if (InvalidPIN_EnteredCount >= 3) then
       begin
          SendMessageToDevice(PINPAD_MSG_ID_EMV + '04.' + '0000' + FS_CHAR + 'D1011:0002:a05' + FS_CHAR);
          fmNBSCCForm.OnlinePINTryExceeded();
       end
       else
       begin
          InvalidPIN_Entered := True;
          SendMessageToDevice(PINPAD_MSG_ID_EMV + '04.' + '0000' + FS_CHAR + 'D1011:0002:a55' + FS_CHAR);       
       end;}
       SendMessageToDevice(PINPAD_MSG_ID_EMV + '04.' + '0000' + FS_CHAR + 'D1011:0002:a05' + FS_CHAR);
       fmNBSCCForm.OnlinePINTryExceeded();
    end
    else
    begin
       SendMessageToDevice(PINPAD_MSG_ID_EMV + '04.' + '0000' + FS_CHAR + ansirightstr(resp.sEMVresp, length(resp.sEMVresp) - 4));
    end;
  end;
end;

procedure TPINPadTransaction.SendAuthResponse(const bApproved : boolean;
                                              const ApprovalCode : string;
                                              const PINPadDisplayMsg : string);
{
POS calls this method when it receives a credit response from the credit server:
}
var
  DevMsg : string;
  RespCode : string[2];
  promptidx : integer;
begin
  if (bApproved) then
  begin
    RespCode := 'A?';
    promptidx := 21;
  end
  else
  begin
    RespCode := 'N?';
    promptidx := 22;
  end;
  DevMsg := PINPAD_MSG_ID_AUTH_REQUEST + 
            Format('%8.8s0%4.4s%2.2s%6.6s%6.6s',
                   [FAuthSerialNo, FPOSTransNo,
                   RespCode, ApprovalCode,
                   FormatDateTime('yymmdd', Now())]);
  case Self.TermModel of
    ppsmISC250 : DevMsg := DevMsg + Format('%d', [promptidx]);
  else
    DevMsg := DevMsg + Format('%.32s', [PINPadDisplayMsg]);
  end;
  DevMsg := DevMsg + FS_CHAR;
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendConfWrite(const IDNGroup : integer;
                                           const IDNIndex : integer;
                                           const IDNData  : string);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_CONF_WRITE +
            Format('%4.4d', [IDNGroup]) + char($1D) +
            Format('%4.4d', [IDNIndex]) + char($1D) + IDNData;
  SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.SendConfRead(const IDNGroup : integer;
                                          const IDNIndex : integer);
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_CONF_READ + Format('%4.4d', [IDNGroup]) + char($1D) + Format('%4.4d', [IDNIndex]);
  SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.SendFileWrite();
{
Send the next block of a file to the pin pad.
}
const
  MAX_CHARS_TO_SEND = 200;
var
  BytesRequested : integer;
  BytesReturned : integer;
  EncodedFileCharacters : string[MAX_CHARS_TO_SEND];
  RecordType : string[1];
  FileNameField, ext : string;
  EncodingField, VerifyFlagField, HiSpeedField : string[1];
  SendMessage : string;
  bInitialGet : boolean;
  bEOF : boolean;
  bAbortSend : boolean;
begin
  bAbortSend := False;
  FLastBlockTime := Now();
  if (LoadFileBuffer.FilePath <> '') then
  begin
    //PPDev.LogEvent(Format('SendFileWrite - Start - TotalCharsEncoded: %d',[LoadFileBuffer.TotalCharsEncoded]));
    BytesRequested := MAX_CHARS_TO_SEND;
    HiSpeedField := '0';
    ext := ExtractFileExt(LoadFileBuffer.FilePath);
    if lowercase(rightstr(ext, 2)) = 'gz' then
      VerifyFlagField := '0'
    else
      VerifyFlagField := '1';
    bInitialGet := (LoadFileBuffer.TotalCharsEncoded = 0);
    if (bInitialGet) then
    begin
      FileNameField := ExtractFileName(LoadFileBuffer.FilePath) + FS_CHAR;
      Dec(BytesRequested, Length(FileNameField));
    end
    else
    begin
      FileNameField := '';
    end;
    SetLength(EncodedFileCharacters, BytesRequested);
    LoadFileBuffer.GetEncodedFileBlock(@(EncodedFileCharacters[1]), BytesRequested, BytesReturned, bEOF);
    SetLength(EncodedFileCharacters, BytesReturned);
    //PPDev.LogEvent(Format('SendFileWrite - Sending %d bytes - TotalCharsEncoded: %d',[BytesReturned, LoadFileBuffer.TotalCharsEncoded]));
    if (bInitialGet) then
    begin
      if (bEof) then
        RecordType := '0'   // Entire file fits in one block
      else
        RecordType := '1';  // First block of multi-block sequence.
    end
    else if (bEOF) then
      RecordType := '3'   // Last block of multi-block sequence.
    else
      RecordType := '2';   // Middle blocks of multi-block sequence.
    if (LoadFileBuffer.EncodingType = mEncodingType7Bit) then
      EncodingField := '7'
    else
      EncodingField := '8';
  end
  else
  begin
    bAbortSend := True;
  end;
  if (bAbortSend) then
  begin
    RecordType := '4';     // Abort previously initiated file transfer.
    FileNameField := '';
    //PPDev.LogEvent(Format('SendFileWrite - Aborted Send - TotalCharsEncoded: %d',[LoadFileBuffer.TotalCharsEncoded]));
  end;
  SendMessage := PINPAD_MSG_ID_FILE_WRITE + RecordType + EncodingField + FileWriteReservedField + VerifyFlagField + HiSpeedField +
                         FileNameField + EncodedFileCharacters;
  SendMessageToDevice(SendMessage);
end;  // procedure SendFileWrite

procedure TPINPadTransaction.SendReBoot();
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_REBOOT;
  SendMessageToDevice(DevMsg);
end;

procedure TPINPadTransaction.ProcessNewVariableData(const VarID        : string;
                                                    const VariableData : string);
{
Process variable data from pin pad
(Variable ID specific part of processing response to the get variable data request).
}
var
  VarIntValue : integer;
  LenVariableData : integer;
  VarIDSignatureBlockRequest : string;
  iAuthID : integer;
begin
  // Some variable IDs must have data
  if (VariableData <> '') then
  begin
    // Check for ID
    if (Copy(VarID, 1, 2) = Copy(PINPAD_VAR_ID_SIGNATURE_BLOCK, 1, 2)) then
    begin
      // New signature block (last digit of VarID represents the block #)
      LenVariableData := Length(VariableData);
      if ((SignatureDataIndex > 0) and
         ((SignatureDataIndex + LenVariableData - 1) <= Length(SignatureData))) then
      begin
        Move(VariableData[1], SignatureData[SignatureDataIndex], LenVariableData);
        Inc(SignatureDataIndex, LenVariableData);
        Inc(SignatureBlockIndex);
        if (SignatureBlockIndex < SignatureBlockHighest) then
        begin
          // Additional block(s) of signature data remain to be captured.
          VarIDSignatureBlockRequest := VarID;
          VarIDSignatureBlockRequest[3] := char(1 + byte(VarID[3]));  // next block
          SendGetVariableRequest(VarIDSignatureBlockRequest);
        end
        else
        begin
          // All blocks of signature data have been captured:
          // Record the signature data
          iAuthID := AuthorizedAuthID;
          AuthorizedAuthID := 0;
          DBTransactionInsertSignatureData(iAuthID, SignatureData);
          if (bNewTransNo) then
          begin
            bNewTransNo := False;
            if (FTransNo = 0) then
              DisplayAdStart := Now() + DisplayAdDelta
            else
              SendHardReset(bClearDisplayOnNextTransReset);
          end;
        end;
      end;
    end
    else if (VarID = PINPAD_VAR_ID_SIGNATURE_BLOCK_COUNT) then
    begin
      // Number of signature data blocks has been returned.
      // Save this value and request the first block.
      try
        VarIntValue := StrToInt(VariableData);
      except
        VarIntValue := 0;
        UpdateExceptLog('ProcessNewVariableData: Cannot convert signature block count "' + VariableData);
      end;
      if (VarIntValue > 0) then
      begin
        SignatureBlockHighest := VarIntValue;
        SendGetVariableRequest(PINPAD_VAR_ID_SIGNATURE_BLOCK);
      end;
    end
    else if (VarID = PINPAD_VAR_ID_SIGNATURE_BLOCK_BYTES) then
    begin
      // Number of bytes for signature data has been returned.
      // Reserve enough space for the signature data and request the number of blocks.
      try
        VarIntValue := StrToInt(VariableData);
      except
        VarIntValue := 0;
        UpdateExceptLog('ProcessNewVariableData: Cannot convert signature number of bytes "' + VariableData);
      end;
      if (VarIntValue > 0) then
      begin
        SetLength(SignatureData, VarIntValue);
        SignatureDataIndex := 1;
        FPinPadTrack1 := '';
        SendGetVariableRequest(PINPAD_VAR_ID_SIGNATURE_BLOCK_COUNT);
      end;
    end;
  end;
  // Check for ID (may be no data in response)
  if (VarID = PINPAD_VAR_ID_MSR_TRACK1) then
  begin
    // Track 1 data has been returned.  Request track 2 data.
    if (VariableData <> '') then
      FPinPadTrack1 := '%' + VariableData + '?';
    FPinPadTrack2 := '';
    SendGetVariableRequest(PINPAD_VAR_ID_MSR_TRACK2);
  end
  else if (VarID = PINPAD_VAR_ID_MSR_TRACK2) then
  begin
    // All track data for previous card swipe has been received:
    // Ask POS to validate the card and send known card type information to pin pad.
    if (VariableData <> '') then
      FPinPadTrack2 := ';' + VariableData + '?';
    // A series of messages resulted after device had previously requested a BIN lookup.
    // The response above terminates this series.
    if FEncryptionEnabled then
      SendGetVariableRequest(PINPAD_VAR_ID_MSR_ENCRYPTEDBLOCK)
    else
      CardInfoReceived(FPinPadTrack1, FPinPadTrack2, FAccountNo, FTrack);
  end
  else if (VarID = PINPAD_VAR_ID_MSR_ENCRYPTEDBLOCK) then
  begin
    if (VariableData <> '') then
      FEncryptedTrackData := VariableData;
    CardInfoReceived(FPinPadTrack1, FPinPadTrack2, FAccountNo, FTrack, FEncryptedTrackData);
  end
  else if (VarID = PINPAD_VAR_ID_PAYMENT_TYPE) then
  begin
    if (Length(VariableData) > 0) then
    begin
      CardTypeField := Byte(VariableData[1]) - $40; // 'A' to 1, 'B' to 2, etc.
    end;
    // If PIN not yet received for PIN type transaction, then must wait for device to request Auth
    if (not((FPINBlock = '') and
            ((CardTypeField in [CARD_TYPE_FIELD_DEBIT,
                                CARD_TYPE_FIELD_EBT_FS,
                                CARD_TYPE_FIELD_EBT_CB]))) and
                                (FPinPadMSRData <> '')   // i.e., if pin pad has requested an authorization
                                                       ) then
    begin
      // Delayed response to PIN pad auth request (had to wait for payment type selected at pin pad).
      AuthInfoReceived(FPinPadAmount, FPinPadMSRData, FPINBlock, FPINSerialNo);
    end;
  end;
end;

procedure TPINPadTransaction.DBTransactionInsertSignatureData(const AuthID : integer;
                                               const SigData : string);
{
Save signature data in database.
}
begin
  FSignatureCaptured := True;
  if Assigned(FOnSigReceived) then
    FOnSigReceived(Self, AuthId, SigData);
end;

procedure TPINPadTransaction.CardInfoReceived(const PINPadTrack1  : widestring;
                                              const PINPadTrack2  : widestring;
                                              const PINAccountNo  : widestring;
                                              const PINTrack      : widestring;
                                              const EncryptedTrackData : widestring;
                                              const EMVTags : widestring);
begin
  //CardInfoReceived('','','','','',msg);
  if Assigned(FCardInfoReceived) then
    FCardInfoReceived(Self, PINPadTrack1, PINPadTrack2, PINAccountNo, PINTrack, EncryptedTrackData, EMVTags);
end;

procedure TPINPadTransaction.AuthInfoReceived(const PinPadAmount  : currency;
                                              const PinPadMSRData : string;
                                              const PINBlock      : string;
                                              const PINSerialNo   : string);
begin
  if Assigned(FAuthInfoReceived) then
  begin
    FAuthInfoReceived(Self, PinPadAmount, PinPadMSRData, PINBlock, PINSerialNo);
  end;
end;

function TPINPadTransaction.PinPadPromptChange(const PinPadStatusID : string;
                                               const PinPadPrompt   : string) : boolean;
var
  RetValue : boolean;
begin
  if Assigned(FOnPinPadPromptChange) then
    RetValue := FOnPinPadPromptChange(Self, PinPadStatusID, PinPadPrompt)
  else
    RetValue := True;
  PinPadPromptChange := RetValue;
end;

procedure TPINPadTransaction.EnablePT(PaymentType: TPayment;
  const Enabled: boolean; const Send : boolean);
begin
  Self.FPaymentAllowed[PaymentType] := Enabled;
  if Send then
    Self.SendSetAllowedPayments();
end;

procedure TPINPadTransaction.PaymentTypes(enDebit, enCredit, enEBTCash,
  enEBTFS, enGift: boolean; const Send : boolean);
begin
  Self.FPaymentAllowed[pt_Debit] := enDebit;
  Self.FPaymentAllowed[pt_Credit] := enCredit;
  Self.FPaymentAllowed[pt_EBTCash] := enEBTCash;
  Self.FPaymentAllowed[pt_EBTFS] := enEBTFS;
  Self.FPaymentAllowed[pt_Gift] := enGift;
  Self.FPaymentAllowed[pt_GiftFuelOnly] := enGift;
  if Send then
    Self.SendSetAllowedPayments();
end;

procedure TPINPadTransaction.SetPinPadOnline(const Value: boolean);
begin
  if Value <> FPinPadOnline then
  begin
    try
      PPDev.LogEvent('PinPadOnline set to ' + BoolToStr(Value, True));
    except
      UpdateExceptLog('PinPadOnline set to ' + BoolToStr(Value, True));
    end;
    FPinPadOnline := Value;
    if FPinPadOnline then
      Self.FOnlineEvent.SetEvent
    else
    begin
      Self.FStartupState := ppssOffline;
      Self.FOnlineEvent.ResetEvent;
    end;
    if assigned(Self.FOnOnlineChange) then
    try
      Self.FOnOnlineChange(Self);
    except
      on E: Exception do UpdateExceptLog('TPINPadTransaction.SetPinPadOnline: in OnOnlineChange routine - %s - %s', [E.ClassName, E.Message]);
    end;
  end;

end;

function TPINPadTransaction.GetLoggingEnabled: Boolean;
begin
  if assigned(Self.PPDev) then
    Result := Self.PPDev.LoggingEnabled
  else
    Result := Self.FLogging;
end;

procedure TPINPadTransaction.SetLoggingEnabled(const Value: Boolean);
begin
  if assigned(Self.PPDev) then
    Self.PPDev.LoggingEnabled := Value;
  Self.FLogging := Value;
end;

function TPINPadTransaction.getCardTypeChar: char;
begin
  if Self.FCardTypeField = CARD_TYPE_FIELD_INVALID then
    Result := '0'
  else if Self.FCardTypeField = CARD_TYPE_FIELD_GIFT_FUEL_ONLY then
    Result := char(64 + CARD_TYPE_FIELD_GIFT)
  else if Self.FCardTypeField = CARD_TYPE_FIELD_UNKNOWN then
    Result := '9'
  else
    Result := char(64 + Self.FCardTypeField);
end;

function TPINPadTransaction.GetReqApplId: string;
begin
  Result := Self.FReqApplID;
end;

function TPINPadTransaction.GetReqParmId: string;
begin
  Result := Self.FReqParmID;
end;

procedure TPINPadTransaction.SetReqApplId(const Value: string);
var
  tstr : string;
begin
  tstr := format('%4.4d', [StrToInt(Value)]);
  if (Value = '0000') or (tstr = Value) then
    Self.FReqApplID := Value
  else
    raise EConvertError.CreateFmt('"%s" is an invalid decimal number to set ReqApplID to - "%s"', [Value, tstr]);
end;

procedure TPINPadTransaction.SetReqParmId(const Value: string);
var
  tstr : string;
begin
  tstr := format('%4.4d', [StrToInt(Value)]);
  if (Value = '0000') or (tstr = Value) then
    Self.FReqParmID := Value
  else
    raise EConvertError.CreateFmt('"%s" is an invalid decimal number to set ReqParmID to - "%s"', [Value, tstr]);
end;

procedure TPINPadTransaction.SendApplBlock();
{
Send the next block of the application file to the pin pad.
}
const
  MAX_CHARS_TO_SEND = 233;
var
  BytesRequested : integer;
  BytesReturned : integer;
  FileCharacters : string[MAX_CHARS_TO_SEND];
  SendMessage : string;
  bEOF : boolean;
begin
  FLastBlockTime := Now();
  if (LoadFileBuffer.FilePath <> '') then
  begin
    BytesRequested := MAX_CHARS_TO_SEND;
    SetLength(FileCharacters, BytesRequested);
    LoadFileBuffer.GetEncodedFileBlock(@(FileCharacters[1]), BytesRequested, BytesReturned, bEOF);
    SetLength(FileCharacters, BytesReturned);
  end;
  SendMessage := PINPAD_MSG_ID_PROGRAM_LOAD + Self.TermSerialNo + copy(FileCharacters, 0, BytesReturned);
  SendMessageToDevice(SendMessage);
  if (bEOF) then
    LoadFileBuffer.FilePath := '';  // Signal to caller that transfer is complete
end;  // procedure SendApplBlock

procedure TPINPadTransaction.ProcessPinPadSendAppl(const qIOMessage : pIOMessage);
{
The device is responding to a block of file data sent to it:
}
begin
  if (LoadFileBuffer.FilePath = '') then
  begin
    Self.TermSerialNo := Copy(qIOMessage^.IOText, 4, 8);
    LoadFileBuffer.EncodingType := mEncodingTypeNone;
    LoadFileBuffer.FilePath := FDirPath + Self.FReqApplID + '.appl';
  end;
  if (LoadFileBuffer.FilePath <> '') then  // setting the path above opens the file if necessary, if it doesn't exist, we won't send
    SendApplBlock()   // Send next block
end;  // procedure ProcessPinPadFileWrite

procedure TPINPadTransaction.ProcessPinPadSetVar(const qIOMessage: pIOMessage);
var
  idx : integer;
  status : char;
  varid : integer;
  varstring : string;
begin
  idx := Pos('.', qIOMessage.IOText);
  status := qIOMessage.IOText[idx + 1];
  varstring := copy(qIOMessage.IOText, idx+3, 6);
  try
    varid := StrToInt(varstring);
    varstring := '';
  except
    on e: Exception do
    begin
      UpdateExceptLog('TPINPadTransaction.ProcessPinPadSetVar: Problem parsing variable id from "%s"', [varstring]);
      varid := -1;
    end;
  end;
  if status <> '2' then
    PPDev.LogEvent('TPINPadTransaction.ProcessPinPadSetVar: not successful - %s - %d %s', [status, varid, varstring])
  else
  begin
    if (Self.FStartupState = ppssSetDate) and (varid = StrToInt(PINPAD_VAR_ID_DATE)) then
    begin
      Inc(Self.FStartupState);
      Self.PinPadStartup;
    end
    else if (Self.FStartupState = ppssSetTime) and (varid = StrToInt(PINPAD_VAR_ID_TIME)) then
    begin
      Inc(Self.FStartupState);
      Self.PinPadStartup;
    end;
  end;
end;


procedure TPinPadTransaction.PinPadDownload(const filename : string);
var
  res : longbool;
begin
  if assigned(ShowMsg) then
    ShowMsg('', 'Downloading to PIN pad: ' + filename, 3);
  LoadFileName := filename;  // initiates download
                             // Wait for pin pad class to clear the file name (indicating that it is done).
  while ((LoadFileName <> '') and (Now() < (5.0/86400.0 + LastBlockTime))) do
  begin
    Application.ProcessMessages();
    Sleep(20);
  end;
  if (LoadFileName = '') then
  begin
    try
      res := DeleteFile(LoadFileDir + filename);
      if not res then
        RaiseLastOSError;
    except
      on e : Exception do
      begin
        UpdateExceptLog('Delete of file (' + filename + ') sent to pin pad failed (download OK):  ' + e.Message);
      end;
    end;
  end
  else
  begin
    UpdateExceptLog('PIN pad file download timed out:  ' + filename);
    LoadFileName := '';
  end;
end;



procedure TPINPadTransaction.UpdatePinPadFiles();
{
Download any files that have been staged in the download directory to the PIN pad device.
}
var
  FileAttrs : integer;
  sr : TSearchRec;
  DownloadFile : string;
  extension : string;
  bRebootNeeded : boolean;
begin
  bRebootNeeded := False;
  DownloadFile := '';
  // If pin pad configured:
  try
    LoadFileName := '';
    FileAttrs := faAnyFile and (not faDirectory);
    // If any files waiting to download
    if (FindFirst(LoadFileDir + '*.*', FileAttrs, sr) = 0) then
    begin
      repeat  // for each file in directory
        DownloadFile := sr.Name;
        extension := lowercase(ExtractFileExt(DownloadFile));
        if (extension = '.appl') or (DownloadFile = 'SysPara.cfg') then
          continue;  //skip .appl and SysPara.cfg files
        if (extension = '.dat') or (extension = '.pgz') then
          bRebootNeeded := True;
        //if ((extension = '.plt') or (extension = '.bmp')) and (LeftStr(sr.Name,2) = 'ad') then
        //  continue; // skip ad files - adcheck deals with those 
        PinPadDownload(DownloadFile);
      until (FindNext(sr) <> 0);  // next file
      FindClose(sr);
      if FileExists(LoadFileDir + 'SysPara.cfg') then
      begin
        PinPadDownload('SysPara.cfg');
        bRebootNeeded := True;
      end;
      if assigned(ShowMsg) then
        ShowMsg('', 'Downloads to PIN pad complete:', 3 );
    end;  // if files exists in directory
  except
    on e : Exception do
    begin
      UpdateExceptLog('Download of file (' + DownloadFile + ') to pin pad failed:  ' + e.Message);
    end;
  end;
  // If files were downloaded, then reboot the pin pad
  if (bRebootNeeded) then
  begin
    PINPadReBoot();
    // should queue up an attempt to online device
  end;
end;  // procedure UpdatePinPadFiles


procedure TPINPadTransaction.SetSwipePending(const Value: boolean);
begin
  if FbSwipePending <> Value then
  begin
    FbSwipePending := Value;
    if assigned(FOnSwipeChange) then
      FOnSwipeChange(Self);
  end;
end;

procedure TPINPadTransaction.SetAdCheckPeriod(const Value: integer);
begin
  FAdCheckPeriod := Value;
end;

procedure TPINPadTransaction.AdCheck;
var
  adinfo : textfile;
  readstring : string;
  FileNameList : TStrings;
  FileAttrs : integer;
  sr : TSearchRec;
  AdTimeList : TList;
  adinforec : pFileUpdateRec;
  fs : TFormatSettings;
  i, j : integer;
  function FURSort(a, b : pointer) : Integer;
  begin
    Result := CompareText(pFileUpdateRec(a).fn, pFileUpdateRec(b).fn);
  end;
  function fileinFUR(FURlist : TList; basename : string) : integer;
  var
    i : integer;
  begin
    Result := -1;
    for i := 0 to FURList.Count - 1 do
      if pFileUpdateRec(FURList.Items[i]).fn = basename then
      begin
        Result := i;
        break;
      end;
  end;
  function fbasename(const fn : string) : string;
  begin
    Result := RightStr(fn,length(fn) - length(ExtractFileExt(fn)));
  end;
begin
  if Self.FAdFileList <> nil then
    exit;
  PPDev.LogEvent('AdCheck starting');
  Self.FLastAdCheck := Now();
  FileNameList := nil;
  AdTimeList := nil;
  GetISOFormatSettings(fs);
  try
    if SysUtils.FileExists(AdFileDir + 'adinfo.txt') then
    begin
      AdTimeList := TList.Create();
      assignfile(adinfo, AdFileDir + 'adinfo.txt');
      try
        reset(adinfo);
        while not eof(adinfo) do
        begin
          readln(adinfo,readstring);
          new(adinforec);
          // split string into fields of TFileUpdateRec
          try
            adinforec.fn := ParseString(readstring, 1, #09);
            adinforec.ts := StrToDateTime(ParseString(readstring, 2, #09),fs);
          except
            on E: Exception do
              begin
                dispose(adinforec);
                adinforec := nil;
                UpdateExceptLog('Problem parsing adinfo line "%s" (%s), ingoring', [readstring, E.ClassName]);
              end;
          end;
          // stash record into AdTimeList
          if adinforec <> nil then
            AdTimeList.Add(adinforec);
        end;
      finally
        if AdTimeList.Count = 0 then
        begin
          AdTimeList.Destroy();
          AdTimeList := nil;
        end
        else
          AdTimeList.Sort(@FURSort);
      end;
    end;

    FileNameList := TStringList.Create;
    FileAttrs := faAnyFile and (not faDirectory);
    if (FindFirst(AdFileDir + 'ad??.bmp', FileAttrs, sr) = 0) then
    begin
      PPDev.LogEvent('Found files matching ad??.bmp in "' + AdFileDir + '"');
      repeat  // for each file in directory
        if FileExists(AdFileDir + ChangeFileExt(sr.Name, '.plt')) then
        begin
          PPDev.LogEvent('Adding "' + sr.Name + '"');
          FileNameList.Add(sr.Name);
          FileNameList.Add(ChangeFileExt(sr.Name, '.plt'));
        end;
      until (FindNext(sr) <> 0);  // next file
      FindClose(sr);
    end;

    if FileNameList.Count > 0 then
    begin
      FAdFileList := TStringList.Create;
      if (AdTimeList <> nil) then
      begin
        // search AdTimeList for matching .bmp files for each file in FileNameList
        for i := 0 to FileNameList.Count - 1 do
        begin
          // if not found on AdTimeList, put in FAdFileList
          j := fileinFUR(AdTimeList, fbasename(FileNameList.Strings[i]));
          if  j = -1 then
            FAdFileList.Append(FileNameList[i])
          // if found and we're past the ad time in the file
          else if (Now() >= pFileUpdateRec(AdTimeList[j]).ts) then
            FAdFileList.Append(FileNameList[i]);  // add it to the todo list
        end;
        DisposeTListItems(AdTimeList);
        AdTimeList.Destroy;
      end
      else
        FAdFileList.Assign(FileNameList);
    end;
    if FAdFileList <> nil then
      PPDev.LogEvent(Format('AdCheck done - %d files found',[FAdFileList.Count]))
    else
    begin
      PPDev.LogEvent('AdCheck done');
      if Self.AdsCurrent = tsUnknown then
        QueryAdServer();
    end;

  finally
    FileNameList.Free;
  end;
end;

procedure TPINPadTransaction.SendAdFile;
begin
  if (Self.PinPadOnLine) and (Self.FAdFileList <> nil) and (Self.FAdFileList.Count > 0) then
  begin
    if fileexists(FadDirPath + Self.FAdFileList.Strings[0]) then
    begin
      LoadFileBuffer.FilePath := FAdDirPath + Self.FAdFileList.Strings[0];
      SendFileWrite();
    end
    else
    begin
      PPDev.LogEvent('File %s disappeared from Ad Dir, skipping', [Self.FAdFileList.Strings[0]]);
      Self.FAdFileList.Delete(0);
      Self.SendAdFile;
    end;
  end;
end;

procedure TPINPadTransaction.DownloadComplete(const filename: string;
  const Aborted: boolean);
var
  res : longbool;
begin
  PPDev.LogEvent(Format('DownloadComplete %s Aborted: %s',[filename,BoolToStr(Aborted,True)]));
  if (Self.FAdFileList <> nil) and (Self.FAdFileList.Strings[0] = filename) then
  begin
    if not Aborted then
    try
      res := DeleteFile(FAdDirPath + filename);
      if not res then
        RaiseLastOSError;
    except
      on E: Exception do UpdateExceptLog('Cannot delete file %s%s - %s - %s', [FAdDirPath, filename, E.ClassName, E.Message]);
    end;
    Self.FAdFileList.Delete(0);
    if Self.FAdFileList.Count > 0 then
      SendAdFile()
    else
    begin
      try
        Self.FAdFileList.Destroy;
        Self.FAdFileList := nil;
      except
        on E: Exception do UpdateExceptLog('Cannot destroy AdFileList - %s - %s', [E.ClassName, E.Message]);
      end;
      try
        TAdServerDoneThread.Create(Self, Self.AdServerURL, Self.Store, Self.Reg, Self.TermModel, Self.TermSerialNo);
      except
        on E: Exception do UpdateExceptLog('Cannot create TAdServerDoneThread thread - %s - %s', [E.ClassName, E.Message]);
      end;
    end;
  end
  else
  begin
    if not Aborted then
    try
      res := DeleteFile(Self.LoadFileDir + filename);
      if not res then
        RaiseLastOSError;
    except
      on E: Exception do UpdateExceptLog('Cannot delete file %s%s - %s - %s', [Self.LoadFileDir, filename, E.ClassName, E.Message]);
    end;
  end;
end;


procedure TPINPadTransaction.SetAdDisplayPeriod(const Value: Cardinal);
begin
  FAdDisplayPeriod := Value;
  if Self.PinPadOnLine then
    ShowAds;  
end;

procedure TPINPadTransaction.ShowAds;
begin
  try
    if Self.AdsCurrent <> tsTrue then
      exit;
    if Self.FAdDisplayPeriod <> 0 then
    begin
    if TimerExpiredMs(Self.FAdDisplayTime, Self.FAdDisplayPeriod) then
      begin
        if assigned(Self.FOnPinPadAdQuery) then
        SendAdRequest(Self.FOnPinPadAdQuery)
        else
        begin
          if Self.AdMax = 0 then
            SendAdRequest(0)
          else
          begin
            Self.FAdCurrent := (Self.FAdCurrent mod Self.AdMax) + 1;
            SendAdRequest(Self.FAdCurrent);
          end;
        end;
      end;
    end
    else
      SendAdRequest();
  except
    on E: Exception do
    begin
      UpdateExceptLog('Caught %s in TPINPadTransaction.ShowAds - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E, 10);
      Self.FAdDisplayPeriod := 0;
    end;
  end;
end;

function TPINPadTransaction.PPStartupStateToString(const Value : TPPStartupState) : string;
begin
  case Value of
    ppssOffline : Result := 'Offline';
    ppssQueryCards : Result := 'Query Cards';
    ppssQueryDebit : Result := 'Query Debit';
    ppssQuerySigMS : Result := 'Query Signature Ready Message';
    ppssQueryEMVSup : Result := 'Query EMV Support';
    ppssQueryFSIndex : Result := 'Query Food Stamp Amount Index';
    ppssQuerySTB : Result := 'Query STB';
    ppssQuerySTBTD : Result := 'Query STB Track Data';
    ppssQuerySTBCD : Result := 'Query STB Clear Digits';
    ppssQueryAds : Result := 'Query Ads';
    ppssSendOnline : Result := 'Send Online';
    ppssSetDate : Result := 'Set Date';
    ppssSetTime : Result := 'Set Time';
    ppssQueryUnitData : Result := 'Query Unit Data';
    ppssSetAllowedPayments : Result := 'Set Allowed Payments';
    ppssQueryContactless : Result := 'Query Contactless enabled';
    ppssQueryEncryption : Result := 'Query Encryption';
    ppssOnline : Result := 'Online';
  else
    Result := 'Unknown';
  end;
end;


procedure TPINPadTransaction.PinPadStartup;
begin
//  TPPStartupState = (ppssOffline, ppssQueryCards, ppssQueryAds, ppssSendOnline, ppssSetTime, ppssSetAllowedPayments, ppssOnline);
  PPDev.LogEvent('PinPadStartup - State: ' + PPStartupStateToString(Self.FStartupState));
  case FStartupState of
    ppssOffline : begin
                    DisplayAdStart := 0.0;
                    SendOffline();
                    inc(FStartupState);
                    PinPadStartup;
                  end;
    ppssQueryCards : SendConfRead(PINPAD_IDN_GROUP_CARDS, PINPAD_IDN_CARDS_CREDIT);
    ppssQueryDebit : SendConfRead(PINPAD_IDN_GROUP_CARDS, PINPAD_IDN_CARDS_DEBIT);
    ppssQuerySigMS : SendConfRead(PINPAD_IDN_GROUP_SIG, PINPAD_IDN_SIG_SEND_MESSAGE);
    ppssQueryEMVSup : SendConfRead(PINPAD_IDN_GROUP_EMV, PINPAD_IDN_EMV_SUPPORT);
    ppssQueryEMVCVMMOD : SendConfRead(PINPAD_IDN_GROUP_EMV, PINPAD_IDN_EMV_CVMMOD);
    ppssQueryFSIndex : SendConfRead(PINPAD_IDN_GROUP_CARDS, PINPAD_IDN_CARDS_EBT_FOODSTAMPS);
    ppssQuerySTB : SendConfRead(PINPAD_IDN_GROUP_STB, PINPAD_IDN_STB_ENABLED);
    ppssQuerySTBTD : SendConfRead(PINPAD_IDN_GROUP_STB, PINPAD_IDN_STB_TRACKDATA);
    ppssQuerySTBCD : SendConfRead(PINPAD_IDN_GROUP_STB, PINPAD_IDN_STB_CLEARDIGITS);
    ppssQueryAds :   SendConfRead(PINPAD_IDN_GROUP_ADS, PINPAD_IDN_ADS_COUNT);
    ppssSendOnline : Self.SendOnline;
    ppssSetDate : Self.SetDate(True);
    ppssSetTime : Self.SetTime(True);
    ppssQueryUnitData : Self.QueryUnitData();
    ppssQueryContactless : SendConfRead(PINPAD_IDN_GROUP_CLESS, PINPAD_IDN_CLESS_ENABLED);
    ppssQueryEncryption : SendConfRead(PINPAD_IDN_GROUP_SECURITY, PINPAD_IDN_SECURITY_ENCRYPTION);
    ppssSetAllowedPayments : SendSetAllowedPayments();
    ppssOnline : begin
                   Self.PinPadOnLine := True;
                   ShowAds;
                   ManageStatusRequests;
                   // We now need to show 1 ad
                   //SendAdRequest(1);
                 end;
  end;
end;

procedure TPINPadTransaction.ManageStatusRequests;
var
  interval : cardinal;
begin
  if Self.PinPadOnLine then
  begin
      if FTransNo <> 0 then
        interval := PINPAD_TRANS_STATUS_INTERVAL
      else
        interval := PINPAD_DEFAULT_STATUS_INTERVAL;
      if TimerExpiredms(Self.FLastStatus, interval) and 
         TimerExpiredms(Self.FLastStatusSent, interval) and
         (PPDev.QueueCount < 2) then
         SendStatusRequest;
  end
  else if TimerExpired(Self.FOnlineAttempt, 15) then
    PinPadOpen;

    {
  if Self.FTransNo <> 0 then
    PinPadStatusTimer.Interval := PINPAD_TRANS_STATUS_INTERVAL
  else
    if Self.FAdDisplayPeriod <> 0 then
      PinPadStatusTimer.Interval := Self.FAdDisplayPeriod
    else
      PinPadStatusTimer.Interval := PINPAD_DEFAULT_STATUS_INTERVAL;
   }

end;

procedure TPINPadTransaction.SetAdMax(const Value: smallint);
begin
  FAdMax := Value;
  if assigned(FOnAdMaxChange) then
  try
    FOnAdMaxChange(Value);
  except
    on E: Exception do
      UpdateExceptLog('TPINPadTransaction.FOnAdMaxChange(%d) threw %s - %s', [Value, E.ClassName, E.Message]);
  end;
end;

procedure TPINPadTransaction.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
  if assigned(PPDev) then
    PPDev.LogEvent('PinPad.Enabled property set to %s', [BoolToStr(Value,True)]);
end;

procedure TPINPadTransaction.SetAdWaitPeriod(const Value: integer);
begin
  FAdWaitPeriod := Value;
  DisplayAdDelta := FAdWaitPeriod {sec} / 86400.0 {sec/day};
end;

procedure TPINPadTransaction.QueryUnitData;
var
  DevMsg : string;
begin
  if PinPadOnline or (Self.FStartupState = ppssQueryUnitData) then
  begin
    DevMsg := PINPAD_MSG_ID_UNIT_DATA;
    SendMessageToDevice(DevMsg);
  end;
end;


procedure TPINPadTransaction.ProcessPinPadUnitData(const qIOMessage: pIOMessage);
var
  mns : string;
  rbav : string;
begin
  Self.TermSerialNo := ParseString(qIOMessage^.IOText, 3, FS_CHAR);
  mns := ParseString(qIOMessage^.IOText, 2, FS_CHAR);
  rbav := ParseString(qIOMessage^.IOText, 9, FS_CHAR);
  UpdateZLog('fmPOS.rbav = ' + rbav);
  if (rbav = '200C') then
  begin
     self.FRBAVersion := 20.00;
  end
  else
  begin
     self.FRBAVersion := StrToCurr(ParseString(qIOMessage^.IOText, 9, FS_CHAR))/100;
  end;
  if pos('6780', mns) > 0 then
    Self.FTermModel := ppsmI6780
  else if pos('SC250', mns) > 0 then
    Self.FTermModel := ppsmISC250;
  if Self.TermModel = ppsmUnknown then
    PPDev.LogEvent('Cannot determine if pin pad is supported model');
  if (Self.FStartupState = ppssQueryUnitData) then
  begin
    Inc(Self.FStartupState);
    Self.PinPadStartup;
  end;
end;

procedure TPINPadTransaction.SetTermSerialNo(const Value: string);
begin
  if Value <> FTermSerialNo then
  begin
    FTermSerialNo := Value;
    AdsCurrent := tsUnknown;
    if assigned(self.FSerialNoChange) then
      FSerialNoChange(value);
  end;
end;

procedure TPINPadTransaction.SetAdsCurrent(const Value: TTriState);
begin
  if Value <> FAdsCurrent then
  begin
    if Value = tsUnknown then
      QueryAdServer();
    FAdsCurrent := Value;
  end;
end;

procedure TPINPadTransaction.QueryAdServer;
begin
  PPDev.LogEvent('Querying Ad Server');
  if length(Self.AdServerURL) > 0 then
    TAdServerQueryThread.Create(Self, Self.AdServerURL, Self.Store, Self.Reg, Self.TermModel, Self.TermSerialNo)
  else
    Self.AdsCurrent := tsTrue;
end;

procedure TPINPadTransaction.SetAdServerURL(const Value: string);
begin
  FAdServerURL := Value;
end;

procedure TPINPadTransaction.SetReg(const Value: integer);
begin
  FReg := Value;
end;

procedure TPINPadTransaction.SetStore(const Value: integer);
begin
  FStore := Value;
end;

constructor TAdHTTPThread.Create(const APP : TPINPadTransaction; const AURL: String; const astore, areg: integer; const amodel: TPPSupportedModels; const aserial: string);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  PP := APP;
  URL := AURL;
  store := astore;
  reg := areg;
  case amodel of
    ppsmI6780 : model := 'I6780';
    ppsmISC250 : model := 'ISC250';
  else
    model := 'UNKNOWN';
  end;
  serial := aserial;
end;

{ TAdServerQueryThread }

procedure TAdServerQueryThread.Execute;
var
  HTTP: TIdHTTP;
  s : String;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    try
      s := HTTP.Get(Format('%s?method=query&ver=1&store=%d&reg=%d&model=%s&serial=%s', [URL, store, reg, model, serial]));
      if StrToIntDef(s, 0) = 1 then
        PP.AdsCurrent := tsTrue;
    except
      on E: Exception do
        PP.PPDev.LogEvent('TAdServerQueryThread.Execute - Exception %s - %s', [E.ClassName, E.Message]);
    end;
  finally
    HTTP.Free;
  end;
end;

{ TAdServerDoneThread }

procedure TAdServerDoneThread.Execute;
var
  HTTP: TIdHTTP;
begin
  HTTP := TIdHTTP.Create(nil);
  try
    try
      HTTP.Get(Format('%s?method=update&ver=1&store=%d&reg=%d&model=%s&serial=%s', [URL, store, reg, model, serial]));
    except
      on E: Exception do
        PP.PPDev.LogEvent('TAdServerDoneThread.Execute - Exception %s - %s', [E.ClassName, E.Message]);
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TPINPadTransaction.HandleValidCardResp(const AcctNo, CardType: widestring; const bAskDebit, bBINRange, bValidated: wordbool);
begin
  FPinPadAccount := AcctNo;
  SendBINLookupResponse(CardType, bAskDebit, bBINRange, bValidated);
end;

procedure TPINPadTransaction.GetPhoneNo;
begin
  Self.EntryPrompt := ppePhoneNo;
  if Self.TermModel = ppsmISC250 then
    Self.SendNumericEntryRequest('0', 250, 10, 10, 7, 'INPUT.K3Z')
  else
    Self.SendNumericEntryRequest('0', 'Enter 10 digit phone number', 10, 10, '%m10%M10%h(%o  %s %h) %o   %h-%o    ');
end;

procedure TPINPadTransaction.GetZip;
begin
  Self.EntryPrompt := ppeZipCode;
  UpdateZLog('Requesting Zip entry at pinpad (%d)', [ord(EntryPrompt)]);
  Self.SendNumericEntryRequest('0', 249, 5, 5, 11, 'INPUT.K3Z');
end;

procedure TPINPadTransaction.GetID;
begin
  Self.EntryPrompt := ppeID;
  UpdateZLog('Requesting ID entry at pinpad (%d)', [ord(EntryPrompt)]);
  Self.SendNumericEntryRequest('*', 242, 0, 7, 11, 'INPUT.K3Z');
end;

procedure TPINPadTransaction.GetOdometer;
begin
  Self.EntryPrompt := ppeOdometer;
  UpdateZLog('Requesting Odometer entry at pinpad (%d)', [ord(EntryPrompt)]);
  Self.SendNumericEntryRequest('0', 239, 0, 7, 2, 'INPUT.K3Z');
end;

procedure TPINPadTransaction.GetVehicleNo;
begin
  Self.EntryPrompt := ppeVehicleNo;
  UpdateZLog('Requesting VehicleNo entry at pinpad (%d)', [ord(EntryPrompt)]);
  Self.SendNumericEntryRequest('*', 237, 0, 7, 11, 'INPUT.K3Z');
end;

procedure TPINPadTransaction.GetDriverID;
begin
  Self.EntryPrompt := ppeDriverID;
  UpdateZLog('Requesting DriverID entry at pinpad (%d)', [ord(EntryPrompt)]);
  Self.SendNumericEntryRequest('*', 236, 0, 7, 11, 'INPUT.K3Z');
end;

procedure TPINPadTransaction.ProcessPinPadEntryReady(const qIOMessage : pIOMessage);
var
  event : TEntryReceivedEvent;
  eet : TPPEntryExitType;
  responselen : integer;
  response : string;
  ep : TPPEntry;
begin
  event := nil;
  if Self.EntryPrompt <> ppeNone then
    event := Self.FCustomerDataReceived;
  if assigned(event) then
  begin
    ep := EntryPrompt;
    EntryPrompt := ppeNone;
    case (qIOMessage^.IOText[4]) of
      '0' : eet := ppeetEnter;
      '1' : eet := ppeetCancel;
      '9' : eet := ppeetDecline;
    else eet := ppeetDecline;
    end;
    responselen := length(qIOMessage^.IOText) - 4;
    if (responselen > 0) then
      response := copy(qIOMessage.IOText, 5, responselen);
    event(self, eet, ep, response);
  end;
end;

procedure TPINPadTransaction.StopOnDemand;
begin
  UpdateZLog('TPINPadTransaction.StopOnDemand');
  Self.SendSoftReset(PINPAD_RESET_TYPE_STOP_ACTION);
  Self.EntryPrompt := ppeNone;
end;

procedure TPINPadTransaction.SetEntryPrompt(const Value: TPPEntry);
begin
  FEntryPrompt := Value;
end;

procedure TPINPadTransaction.SetEMVEnabled(const Value: boolean);
begin
  FEMVEnabled := Value;
end;

procedure TPINPadTransaction.ProcessCardReadResponse(const qIOMessage : pIOMessage);
var
   msgnos : string;
   msgsts : string;
   ctype : string;
begin
   // this will either initiate and emv transaction or msr swipe
   //23.0M = MSR
   //23.0S = EMV
   UpdateZLog('ENTER: ProcessCardReadResponse with ' + qIOMessage^.IOText);
  try
    msgnos := Copy(qIOMessage^.IOText, 4, 2);
    msgsts := Copy(msgnos,1,1);
    ctype := Copy(msgnos,2,1);
    //11.18
    //33.00
    if (msgsts <> '0') then
    begin
       raise Exception.Create('Invalid Card Read');
       SendReadCard();
    end;
    if (ctype = 'S') then
       SendEMVInitiate()
    else if (ctype = 'M') then
    begin
       //SendReadCard();
       // This is a swipe and we should have everything that we need for the initial process
       UpdateZLog('Inside ProcessCardReadResponse and the type = ''M'' next step is ProcessPinPadBINLookup :local');
       // this is the same as a 19. response and we should just send it to be processed and everything should flow
       ProcessPinPadBINLookup(qIOMessage);
    end
    else
       SendReadCard();
    
  except
      UpdateZLog('Invalid Card Read Message :local');
      SendReadCard();
  end;
end;

procedure TPINPadTransaction.SendCancelOnDemand();
var
  DevMsg : string;
begin
  DevMsg := '15.6';
  SendMessageToDevice(DevMsg, False);
end;

procedure TPINPadTransaction.SendEMVInitiate();
var
  DevMsg : string;
begin
  DevMsg := PINPAD_MSG_ID_EMV + '00.0000'
            + FS_CHAR  + 'B'
            + FS_CHAR  + FS_CHAR + FS_CHAR + FS_CHAR;
  SendMessageToDevice(DevMsg, False);
end;


procedure TPINPadTransaction.ProcessPinPadEMVMessage(const qIOMessage: pIOMessage);
var
  msgnos : string;
  status, pktnum, check_msgnos : integer;
  pkttype : TEMVPacketType;
  extract, msg : string;
  vs : String;
  pb : String;
  ksn : String;
begin
  try
    msgnos := Copy(qIOMessage^.IOText, 4, 2);
    if (msgnos = '18') then msgnos := '';  // a 33.18 is equivalent to a 33. where we do not process this message
    //if (msgnos = '07') then nCount := nCount - 1;
    check_msgnos := StrToInt(msgnos);
    try
       status := strtoint(Copy(qIOMessage^.IOText, 7, 2));
    except
       status := 0;
    end;
    pktnum := strtoint(Copy(qIOMessage^.IOText, 9, 1));
    pkttype := TEMVPacketType(strtoint(Copy(qIOMessage^.IOText, 10, 1)));
    extract := Copy(qIOMessage^.IOText, 12, length(qIOMessage^.IOText) - 11);
    FPINBLOCK := '';
    FPINSerialNo := '';
    if status = 0 then
    begin
      if pkttype = ptFirstLast then
        msg := extract
      else if pkttype = ptFirstOfMore then
        self.FMSGBuffer.PutValue(msgnos, extract)
      else if pkttype = ptMore then
        self.FMSGBuffer.PutValue(msgnos, self.FMSGBuffer.GetValue(msgnos) + extract)
      else if pkttype = ptLast then
        msg := self.FMSGBuffer.GetValue(msgnos) + extract;
      if msg <> '' then
      case strtoint(msgnos) of
        PINPAD_EMV_SUB_TRACKTWOEQUIV : ProcessEMV_TrackTwoEquivalent(msg);   //02
        PINPAD_EMV_SUB_AUTH : begin
                                 SwipeCheckCount := SwipeCheckCount + 1;  // need to do this so that we know they tried an EMV
                                 if (POS('T99:24:',extract) > 0) then
                                 begin
                                     fmNBSCCForm.SetOnlineT99Switch();
                                     vs := Copy(extract,POS('T99:24:',extract),50);
                                     pb := Copy(vs,9,16);
                                     ksn := Copy(vs,25,20);
                                     FPINBLOCK := pb;
                                     FPINSerialNo := ksn;
                                 end;
                                 ProcessEMV_Auth(msg);                          //03
                              end;
        PINPAD_EMV_SUB_AUTHRESP : ProcessEMV_AuthRespFail(msg);              //04
        PINPAD_EMV_SUB_AUTHCONFIRM : ProcessEMV_AuthCFM(msg);                //05
        PINPAD_EMV_SUB_CVMMOD : ProcessEMV_CVMMod(msg);                      //07
      end;
    end
    else
      UpdateZLog('%s: EMV Msg status %d unhandled', [ProcByLevel, status]);
  except
      UpdateZLog('Invalid EMV Message :local');
  end;
end;

procedure TPINPadTransaction.ProcessEMV_TrackTwoEquivalent(const msg: string);
begin
  PPDev.LogEvent('%s: enter',[ProcBylevel]);
  CardInfoReceived('','','','','',msg);
end;

procedure TPINPadTransaction.ProcessEMV_Auth(const msg: string);
begin
  if (fmNBSCCForm.Visible <> true) then 
  begin
     fmNBSCCForm.Visible := true;
  end;
  AuthInfoReceived(FPinPadAmount, msg, FPINBLOCK, FPINSerialNo);
end;

procedure TPINPadTransaction.ProcessEMV_AuthRespFail(const msg: string);
begin
  PPDev.LogEvent('Failed to send auth - %s', [msg]);
end;

procedure TPINPadTransaction.ProcessEMV_AuthCFM(
  const msg: string);
var
  p : pCreditResponseData;
begin
  // JUST RETURN FOR NOW MDS : LOCAL XXXXX
  //EXIT;
  if (fmNBSCCForm.Visible <> true) then fmNBSCCForm.Visible := true;
  try
  if Assigned(self.creditresponse) then
  begin
     // do nothing
  end
  else
  begin
     New(creditresponse);
  end;
  creditresponse.sEMVauthCFM := msg;
  PPDev.LogEvent('%s: ',[ProcBylevel]);
  p := self.creditresponse;
  self.creditresponse := nil;
  p.sEMVauthCFM := msg;
  fmNBSCCform.ProcessEMVAuthCFM(p);
  except
  end;
  try
    if Assigned(p) then
       Dispose(p);
  except
  end;
end;

procedure TPINPadTransaction.ProcessEMV_CVMMod_CCResp(const msg: string);
var
  tcresp : string;
  DevMsg : String;
begin
  tcresp := GetTagData(TAG_EMVTCINFO, msg);
  DevMsg := PINPAD_MSG_ID_EMV + '07.0000' + FS_CHAR + 'T9F33:03:hE0F0C8';
  //SendMessageToDevice(PINPAD_MSG_ID_EMV + format('%2.2d.0000', [PINPAD_EMV_SUB_CVMMOD]) + FS_CHAR + ansirightstr(tcresp, length(tcresp) - 4), False);
  SendMessageToDevice(DevMsg,False);
end;

procedure TPINPadTransaction.ProcessEMV_CVMMod(const msg: string);
begin
  Self.CCSendMsg(BuildTag(TAG_MSGTYPE, IntToStr(CC_CVM_QUERY))+BuildTag(TAG_EMVTCINFO, 'ING' + cRS + msg), Self.ProcessEMV_CVMMod_CCResp);
end;

{ TLogMaskIngTags }

constructor TLogMaskIngTags.Create(const tag: string; const dir: TMsgDir;
  const mstart, mend: integer);
begin
  inherited Create;
  Self.FTag := tag;
  Self.Fdir := dir;
  Self.Fmstart := mstart;
  Self.Fmend := mend;
end;

procedure TLogMaskIngTags.Mask(const buffer: pChar; const len: integer;
  const dir: TMsgDir);
var
  i, s, e, o : integer;
  mask : boolean;
begin
  s := self.mstart;
  e := self.mend;
  if (self.dir = dir) then
  begin
    o := Pos(self.tag + ':', buffer);
    mask := (o > 0);
    if mask then
    begin
      s := o + length(self.tag) + s + 4; // tags followed by two colons, two digits and a type spec
      e := posex(cFS, buffer, o) - 2 + e; // find end of tag
      for i := s to e do
        if i < len then
          case buffer[i] of
           #48 .. #57 : buffer[i] := '*';
           #65 .. #90 : buffer[i] := '*';
           #97 ..#122 : buffer[i] := '*';
          end;
    end;
  end;
end;

end.

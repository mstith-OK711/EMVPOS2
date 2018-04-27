unit ADSCC;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, POSMain,
  StdCtrls, DB, AdPort, ExtCtrls, POSBtn, ElastFrm, POSMisc;

const

WM_SETPIN      = WM_USER + 200;
WM_INITSCREEN  = WM_USER + 201;

PIN_INPUTMASKED     = True;
PIN_INPUTNOTMASKED  = False;

{BSI Card Type Values}
CT_PROPRIETARY      = '01';
CT_MASTERCARD       = '02';
CT_VISA             = '03';
CT_DEBIT            = '04';
CT_AMEX             = '05';
CT_DISCOVER         = '07';
CT_WEX              = '11';
CT_WEXPROP          = '12';
CT_PHH              = '13';
CT_DINERS           = '16';
CT_IAES             = '19';
CT_GSA              = '26';
CT_VOYAGER          = '28';

ERR_INVALIDACCOUNT     = 'Invalid Account#';
ERR_INVALIDDATE        = 'Invalid Exp. Date';
ERR_CARDEXPIRED        = 'Card Expired';
ERR_CARDNOTACCEPTED    = 'Card Not Valid At This Location';
ERR_RESTRICTIONCODE    = 'Invalid Voyager Restriction Code';
ERR_VEHICLENO          = 'Invalid Vehicle Number';
ERR_DRIVERID           = 'Invalid Driver ID';
ERR_ODOMETER           = 'Invalid Odometer';
ERR_NOCREDITS          = 'No Credits on IAES';
ERR_NOISO              = 'No ISO on Manual Wex and Clark Fleet';

  STX = #02;
  ETX = #03;
  FS  = #28;
  SUB = #26;
  ACK = #6;
  EOT = #4;
  NACK= #21;

  CM_WAITFORACK       = 10;
  CM_WAITFORRESPONSE  = 20;

type

  TfmADSCCForm = class(TForm)
    lCardNo: TLabel;
    lCardName: TLabel;
    lExpDate: TLabel;
    lCardType: TLabel;
    eCardType: TLabel;
    lRestrictionCode: TLabel;
    lVehicle: TLabel;
    lDriver: TLabel;
    eDriverID: TLabel;
    lOdometer: TLabel;
    lBatchNo: TLabel;
    lSeqNo: TLabel;
    lDate: TLabel;
    eBatchNo: TLabel;
    eSeqNo: TLabel;
    eDate: TLabel;
    lApproval: TLabel;
    eApproval: TPanel;
    lStatus: TPanel;
    eCardNo: TPanel;
    eCardName: TPanel;
    eExpDate: TPanel;
    eRestrictionCode: TPanel;
    eVehicleNo: TPanel;
    eVisibleDriverID: TPanel;
    eOdometer: TPanel;
    ElasticForm1: TElasticForm;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    Authorized : boolean;
    MSRData : string;
    EntryBuff: array[0..200] of Char;
    ChargeAmount : currency;
    bNoSwipe : boolean;
    CreditAuthToken : short;

    procedure CCButtonClick(Sender: TObject);
    procedure ProcessKey ;
    procedure ResetLabels;
    procedure ProcessCredit(var Msg: TWMStatus); message WM_CREDITMSG;
    procedure InitScreen(var Msg: TMessage); message WM_INITSCREEN;

    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure PreProcessKey(var Msg: TMessage); message WM_PREPROCESSKEY;

    procedure DeformatTrack1Data;
    procedure DeformatTrack2Data;
    procedure CheckServiceCode;

    procedure SetPrevField;
    procedure SetActiveField;

    function ValidCardData : boolean;
    function ValidChecksum : boolean;
    function ValidSpecChecksum(StartPos, EndPos, CheckPos: short) : boolean;
    function ValidDate : boolean;
    function ValidRestrictionCode : boolean;
    function ValidVehicleNo : boolean;
    function ValidDriverID : boolean;
    function ValidOdometer : boolean;

    procedure CheckUserData;
    procedure CalcProdTypes;
    procedure BuildWEXUserData;
    procedure BuildWEXCredit;
    procedure BuildPHHUserData;
    procedure BuildIAESUserData;
    procedure BuildVoyagerUserData;
    procedure BuildVoyagerCredit;

    procedure CheckCardNoSpaces;
    procedure ProcessPinPadString(InputString : string);

    procedure BuildTouchPad;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );
    function  GetSalePumpNo: integer;  // returns first pump no found in sale

  end;

pWEXSingleFuelProd = ^TWEXSingleFuelProd;
TWEXSingleFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
end;

pWEXSingleNonFuelProd = ^TWEXSingleNonFuelProd;
TWEXSingleNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
end;


pWEXFuelAndNonFuelProd = ^TWEXFuelAndNonFuelProd;
TWEXFuelAndNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
end;

pWEXTwoNonFuelProd = ^TWEXTwoNonFuelProd;
TWEXTwoNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
end;


pWEXFuelAndTwoNonFuelProd = ^TWEXFuelAndTwoNonFuelProd;
TWEXFuelAndTwoNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
  ProdCode3         : array[0..1] of char;
  ProdCode3Amount   : array[0..5] of char;
end;

pWEXThreeNonFuelProd = ^TWEXThreeNonFuelProd;
TWEXThreeNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OdometerNumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
  ProdCode3         : array[0..1] of char;
  ProdCode3Amount   : array[0..5] of char;
end;

pWEXCredit = ^TWEXCredit;
TWEXCredit = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OrigBatchNo       : array[0..1] of char;
  OrigBatchSeqNo    : array[0..2] of char;
  OrigDate          : array[0..3] of char;
end;

pPHHAuth = ^TPHHAuth;
TPHHAuth = record
  Odometer        : array[0..5] of char;
  VehicleNo       : array[0..9] of char;
  FuelMeasure     : char;
  FuelType        : array[0..1] of char;
  FuelServiceType : array[0..1] of char;
  FuelQuantity    : array[0..4] of char;
  FuelDollars     : array[0..6] of char;
  OilQuantity     : array[0..1] of char;
  OilDollars      : array[0..4] of char;
  OtherCode1      : array[0..1] of char;
  OtherDollars1   : array[0..5] of char;
  OtherCode2      : array[0..1] of char;
  OtherDollars2   : array[0..5] of char;
  OtherCode3      : array[0..1] of char;
  OtherDollars3   : array[0..5] of char;
  Tax             : array[0..4] of char;
  Filler          : array[0..10] of char;
end;

pIAESAuth = ^TIAESAuth;
TIAESAuth = record
  PINNumber       : array[0..3] of char;
  Odometer        : array[0..6] of char;
  VehicleNo       : array[0..4] of char;
  FuelCode        : array[0..1] of char;
  FuelUnits       : char;
  FuelQuantity    : array[0..5] of char;
  FuelPrice       : array[0..4] of char;
  FuelAmount      : array[0..5] of char;
  OilCode         : array[0..1] of char;
  OilUnits        : char;
  OilQuantity     : array[0..4] of char;
  OilPrice        : array[0..4] of char;
  OilAmount       : array[0..4] of char;
  ProdCode1       : array[0..1] of char;
  ProdAmount1     : array[0..4] of char;
  ProdCode2       : array[0..1] of char;
  ProdAmount2     : array[0..4] of char;
  Filler1         : array[0..3] of char;
  VFDriverNo      : array[0..4] of char;
  VFCVVNo         : array[0..2] of char;
end;


pVoyagerAuth = ^TVoyagerAuth;
TVoyagerAuth = record
  Odometer        : array[0..6] of char;
  DriverID        : array[0..5] of char;
  ServiceType     : char;
  FuelProd1Type   : array[0..1] of char;
  FuelProd1Gals   : array[0..4] of char;
  FuelProd1Amt    : array[0..4] of char;
  FuelProd2Type   : array[0..1] of char;
  FuelProd2Gals   : array[0..4] of char;
  FuelProd2Amt    : array[0..4] of char;
  Prod1Type       : array[0..1] of char;
  Prod1Qty        : array[0..1] of char;
  Prod1Amt        : array[0..4] of char;
  Prod2Type       : array[0..1] of char;
  Prod2Qty        : array[0..1] of char;
  Prod2Amt        : array[0..4] of char;
  Prod3Type       : array[0..1] of char;
  Prod3Qty        : array[0..1] of char;
  Prod3Amt        : array[0..4] of char;
  Prod4Type       : array[0..1] of char;
  Prod4Qty        : array[0..1] of char;
  Prod4Amt        : array[0..4] of char;
  Tax             : array[0..5] of char;
end;



pVoyagerCredit = ^TVoyagerCredit;
TVoyagerCredit = record
  OrigInvoiceNo   : array[0..5] of char;
  ServiceType     : char;
  FuelProd1Type   : array[0..1] of char;
  FuelProd1Gals   : array[0..4] of char;
  FuelProd1Amt    : array[0..4] of char;
  FuelProd2Type   : array[0..1] of char;
  FuelProd2Gals   : array[0..4] of char;
  FuelProd2Amt    : array[0..4] of char;
  Prod1Type       : array[0..1] of char;
  Prod1Qty        : array[0..1] of char;
  Prod1Amt        : array[0..4] of char;
  Prod2Type       : array[0..1] of char;
  Prod2Qty        : array[0..1] of char;
  Prod2Amt        : array[0..4] of char;
  Prod3Type       : array[0..1] of char;
  Prod3Qty        : array[0..1] of char;
  Prod3Amt        : array[0..4] of char;
  Prod4Type       : array[0..1] of char;
  Prod4Qty        : array[0..1] of char;
  Prod4Amt        : array[0..4] of char;
  Tax             : array[0..5] of char;
end;


var
  fmADSCCForm: TfmADSCCForm;

  WEXSingleFuelProd        : pWEXSingleFuelProd;
  WEXSingleNonFuelProd     : pWEXSingleNonFuelProd;
  WEXFuelAndNonFuelProd    : pWEXFuelAndNonFuelProd;
  WEXTwoNonFuelProd        : pWEXTwoNonFuelProd;
  WEXFuelAndTwoNonFuelProd : pWEXFuelAndTwoNonFuelProd;
  WEXThreeNonFuelProd      : pWEXThreeNonFuelProd;
  WEXCredit                : pWEXCredit;

  PHHAuth        : pPHHAuth;
  IAESAuth       : pIAESAuth;
  VoyagerAuth    : pVoyagerAuth;
  VoyagerCredit  : pVoyagerCredit;

  SearchOption: TLocateOptions;


bIgnoreSwipe : boolean;
bNoOrigSale : boolean;

CardNo   : string;
ExpDate  : string;
CardType : string;
CardTypeNo : string;
CardName : string;
EntryType : string;
ServiceCode : string;
CardError : string;
UserData   : string;
UserDataCount : string;

  DebitSerialNumber   : string;
  DebitPINBlock       : string;
  DebitCashBackAmount : currency;

FieldToken : short;

  KeyBuff: array[0..200] of Char;
  BuffPtr: short;

fOne : boolean;

FirstTwoChars : string;
TypeNo : integer;
CardLen : short;

PrevField : short;

bFuelOnly, bGetVehicleNo, bGetDriverID, bGetOdometer, bGetRestrictionCode : boolean;
bGetApproval, bGetBatchNo, bGetInvoiceNo, bGetSeqNo, bGetDate : boolean;
bRetryDriverID : boolean;

DriverIDCount : short;
DriverID1     : string;
DriverID2     : string;
DriverID3     : string;



RespAllowed      : string;
RespAuthCode     : string;
RespDate         : string;
RespTime         : string;
RespApprovalCode : string;
RespAuthorizer   : string;
RespEntryMethod  : string;
RespBatchNo      : string;
RespSeqNo        : string;
RespPumpLimit    : string;
RespReferralNo   : string;
RespReaderNo     : string;
RespAuthID       : string;

PinText      : string;
SendBuff     : Array [0..128] of char;
ComToken     : Integer;
PINToken     : Integer;
RcvPtr       : Integer;
RcvBuffer    : Array [0..200] of Char;

FuelType     : array[0..4] of integer;
FuelQty      : array[0..4] of Currency;
FuelPrice    : array[0..4] of Currency;
FuelAmount   : Currency;
NonFuelAmount : currency;
TaxAmount : currency;


OilType      : integer;
OilQty       : Currency;
OilPrice     : Currency;
OilAmount    : Currency;

ProdType     : array[1..4] of integer;
ProdQty      : array[1..4] of Currency;
ProdAmount   : array[1..4] of Currency;

TlProdCount  : short;
TlTax        : currency;

OriginalInvoiceNo : string;
OrigBatchNo       : string;
OrigBatchSeqNo    : string;
OrigDate          : string;

bSwipeErrFlag : boolean;
nSwipeCount : short;


CCMsg      : string;
TempCCMsg  : string;

Keytops      : array[1..15] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '', '0', '', 'C', 'B', 'E');
POSButtons    : array[1..15] of TPOSTouchButton;

implementation

uses POSDM, POSLog, POSErr, PinPad;

var
 sKeyType  : string[3];
 sKeyVal   : string[5];
 sPreset   : string[10];

 Track1Data : string;
 Track2Data : string;

{$R *.DFM}

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CCButtonClick                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Sender                                                       |
|                                                                            |
| CALLED BY:    BuildKeyPad                                                  |
|                                                                            |
| CALLS:        ProcessKey                                                   |
|                                                                            |
| GLOBALS:      sKeyType, sKeyVal, sPreset                                   |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CCButtonClick                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Sender                                                       |
|                                                                            |
| CALLED BY:    BuildKeyPad                                                  |
|                                                                            |
| CALLS:        ProcessKey                                                   |
|                                                                            |
| GLOBALS:      sKeyType, sKeyVal, sPreset                                   |
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
procedure TfmADSCCForm.CCButtonClick(Sender: TObject);
begin

  if (Sender is TPOSTouchButton) then
    begin
      sKeyType := TPOSTouchButton(Sender).KeyType ;
      sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
      sPreset  := TPOSTouchButton(Sender).KeyPreset ;
      ProcessKey;
    end;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessPinPadString                             |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   InputString                                                  |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        ProcessKey                                                   |
|                                                                            |
| GLOBALS:      eDriverID, eOdometer, eVehicleNo, eVisibleDriverID,          |
|               FieldToken, sKeyType                                         |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessPinPadString                             |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   InputString                                                  |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        ProcessKey                                                   |
|                                                                            |
| GLOBALS:      eDriverID, eOdometer, eVehicleNo, eVisibleDriverID,          |
|               FieldToken, sKeyType                                         |
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
procedure TfmADSCCForm.ProcessPinPadString(InputString : string);
begin

  sKeyType := 'ENT';

  case FieldToken of
  4 :
    begin
      eVehicleNo.Caption := InputString;
    end;
  5 :
    begin
      eDriverID.Caption  := InputString;
      eVisibleDriverID.Caption   := StringOfChar('*',Length(eDriverID.Caption));
    end;
  6 :
    begin
      eOdometer.Caption  := InputString;
    end;
  end;
  ProcessKey;

end;









{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.PreProcessKey                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        CheckServiceCode, DeformatTrack1Data, DeformatTrack2Data,    |
|               ProcessKey                                                   |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, bNoSwipe, CardName, CardNo, eCardName, eCardNo,|
|               eCardType, eExpDate, EntryBuff, EntryType, ExpDate,          |
|               FieldToken, lCardName, lCardType, MSRData, sKeyType          |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.PreProcessKey                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        CheckServiceCode, DeformatTrack1Data, DeformatTrack2Data,    |
|               ProcessKey                                                   |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, bNoSwipe, CardName, CardNo, eCardName, eCardNo,|
|               eCardType, eExpDate, EntryBuff, EntryType, ExpDate,          |
|               FieldToken, lCardName, lCardType, MSRData, sKeyType          |
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
procedure TfmADSCCForm.PreProcessKey(var Msg:TMessage);
begin

  if (EntryBuff[0] = '%') and (bIgnoreSwipe = False) and (bNoSwipe = False) then     {Magstripe indicator Track 1}
    begin
      MSRData := EntryBuff;
      DeformatTrack1Data;
      CheckServiceCode;
      lCardName.Visible := True;
      eCardName.Enabled := True;
      lCardType.Visible := True;
      eCardType.Enabled := True;
      eCardNo.Caption := CardNo;
      eCardName.Caption := CardName;
      eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);
      EntryType := 'S';
      sKeyType := 'ENT';
      FieldToken := 90;
      ProcessKey;
      exit;
    end
  else if (EntryBuff[0] = ';') and (bIgnoreSwipe = False) and (bNoSwipe = False) then             {Magstripe indicator Track 2}
    begin
      MSRData := EntryBuff;
      DeformatTrack2Data;
      CheckServiceCode;
      lCardName.Visible := True;
      eCardName.Enabled := True;
      lCardType.Visible := True;
      eCardType.Enabled := True;
      eCardNo.Caption := CardNo;
      eCardName.Caption := CardName;
      eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);
      EntryType := 'S';
      sKeyType := 'ENT';
      FieldToken := 90;
      ProcessKey;
      exit;
    end;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckKey                                        |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        CheckServiceCode, DeformatTrack1Data, DeformatTrack2Data,    |
|               ProcessKey                                                   |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, bNoSwipe, bRetryDriverID, BuffPtr, CardName,   |
|               CardNo, eCardName, eCardNo, eCardType, eExpDate, EntryBuff,  |
|               EntryType, Error_SkipKey, ExpDate, FieldToken, KBDef,        |
|               KeyBuff, KeyCode, KeyType, KeyVal, lCardName, lCardType,     |
|               MSRData, Preset, sKeyType, sKeyVal, sPreset                  |
|                                                                            |
| LOCALS:       FirstOne, LastOne, sKeyChar                                  |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckKey                                        |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        CheckServiceCode, DeformatTrack1Data, DeformatTrack2Data,    |
|               ProcessKey                                                   |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, bNoSwipe, bRetryDriverID, BuffPtr, CardName,   |
|               CardNo, eCardName, eCardNo, eCardType, eExpDate, EntryBuff,  |
|               EntryType, Error_SkipKey, ExpDate, FieldToken, KBDef,        |
|               KeyBuff, KeyCode, KeyType, KeyVal, lCardName, lCardType,     |
|               MSRData, Preset, sKeyType, sKeyVal, sPreset                  |
|                                                                            |
| LOCALS:       FirstOne, LastOne, sKeyChar                                  |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.CheckKey(var Msg:TWMPOSKey);
var
 sKeyChar  : string[2];
 FirstOne,LastOne : PChar;

begin
  KeyBuff[BuffPtr] := Msg.KeyCode;

  If Error_SkipKey Then
   Begin
     Error_SkipKey := False;
     KeyBuff := '';
     BuffPtr := 0;
     Exit;
   End;

  if (KeyBuff[0] = '%') and (bIgnoreSwipe = False) and (bNoSwipe = False) then             {Magstripe indicator Track 1}
    begin
      FirstOne := StrScan(KeyBuff,'?');
      if FirstOne > nil then
        begin
          LastOne := StrRScan(KeyBuff,'?');
          if LastOne > FirstOne then
            begin
              StrCopy(EntryBuff,KeyBuff);
              KeyBuff := '';
              BuffPtr := 0;
              MSRData := EntryBuff;
              DeformatTrack1Data;
              CheckServiceCode;
              lCardName.Visible := True;
              eCardName.Enabled := True;
              lCardType.Visible := True;
              eCardType.Enabled := True;
              eCardNo.Caption := CardNo;
              eCardName.Caption := CardName;
              eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);
              EntryType := 'S';
              sKeyType := 'ENT';
              FieldToken := 90;
              ProcessKey;
              exit;
            end;
        end;
    end
  else if (KeyBuff[0] = ';') and (bIgnoreSwipe = False) and (bNoSwipe = False) then             {Magstripe indicator Track 2}
    begin
      FirstOne := StrScan(KeyBuff,'?');
      if FirstOne > nil then
        begin
          StrCopy(EntryBuff,KeyBuff);
          KeyBuff := '';
          BuffPtr := 0;
          MSRData := EntryBuff;
          DeformatTrack2Data;
          CheckServiceCode;
          lCardName.Visible := True;
          eCardName.Enabled := True;
          lCardType.Visible := True;
          eCardType.Enabled := True;
          eCardNo.Caption := CardNo;
          eCardName.Caption := CardName;
          eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);
          EntryType := 'S';
          sKeyType := 'ENT';
          FieldToken := 90;
          ProcessKey;
          exit;
        end;
    end
  else if KeyBuff[0] = 'Z' then      {special to get approval code or retry driver id}
    begin
      KeyBuff := '';
      BuffPtr := 0;
      sKeyType := 'ENT';
      if bRetryDriverID then
        FieldToken := 93
      else
        FieldToken := 90;
      ProcessKey;
      exit;
    end
  else if BuffPtr = 1 then
    begin
      sKeyChar := UpperCase(Copy(KeyBuff,1,2));
      if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
        begin
          sKeyType := KBDef[sKeyChar[1], sKeyChar[2]].KeyType;
          sKeyVal  := KBDef[sKeyChar[1], sKeyChar[2]].KeyVal;
          sPreset  := KBDef[sKeyChar[1], sKeyChar[2]].Preset;

          ProcessKey();
        end
      else
        Begin
          Error_SkipKey := True;
        End;
      KeyBuff := '';
      BuffPtr := 0;
      exit;
    end;

 if KeyBuff[BuffPtr] <> #13 then
   Inc(BuffPtr,1);

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessKey                                      |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CCButtonClick, CheckKey, PreProcessKey, ProcessPinPadString  |
|                                                                            |
| CALLS:        POSError, ProcessKeyEHL, ProcessKeyPAL, ProcessKeyPAT,       |
|               ProcessKeyPHL, ProcessKeyPMP, ResetLabels, SetActiveField,   |
|               SetPrevField, ValidCardData, ValidDriverID, ValidOdometer,   |
|               ValidRestrictionCode, ValidVehicleNo                         |
|                                                                            |
| GLOBALS:      bGetApproval, bGetBatchNo, bGetDate, bGetDriverID,           |
|               bGetInvoiceNo, bGetOdometer, bGetRestrictionCode, bGetSeqNo, |
|               bGetVehicleNo, bNoOrigSale, bRetryDriverID, bWEXNotAllowed,  |
|               CardError, CardNo, CardType, CardTypeNo, ChargeAmount,       |
|               CreditAuthToken, CT_WEX, CT_WEXPROP, DriverID1, DriverID2,   |
|               DriverIDCount, eApproval, eBatchNo, eCardNo, eCardType,      |
|               eDate, eDriverID, eExpDate, EntryType, eOdometer,            |
|               eRestrictionCode, eSeqNo, eVehicleNo, eVisibleDriverID,      |
|               ExpDate, FieldToken, fmADSCCForm, fmPOS, lApproval, lBatchNo,|
|               lDate, lDriver, lOdometer, lRestrictionCode, lSeqNo,         |
|               lVehicle, MSRData, PINToken, PrevField, sKeyType, sKeyVal,   |
|               sPreset, WM_CREDITMSG, WM_SETPIN                             |
|                                                                            |
| LOCALS:       eLen, eMM, eNo                                               |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessKey                                      |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CCButtonClick, CheckKey, PreProcessKey, ProcessPinPadString  |
|                                                                            |
| CALLS:        POSError, ProcessKeyEHL, ProcessKeyPAL, ProcessKeyPAT,       |
|               ProcessKeyPHL, ProcessKeyPMP, ResetLabels, SetActiveField,   |
|               SetPrevField, ValidCardData, ValidDriverID, ValidOdometer,   |
|               ValidRestrictionCode, ValidVehicleNo                         |
|                                                                            |
| GLOBALS:      bGetApproval, bGetBatchNo, bGetDate, bGetDriverID,           |
|               bGetInvoiceNo, bGetOdometer, bGetRestrictionCode, bGetSeqNo, |
|               bGetVehicleNo, bNoOrigSale, bRetryDriverID, bWEXNotAllowed,  |
|               CardError, CardNo, CardType, CardTypeNo, ChargeAmount,       |
|               CreditAuthToken, CT_WEX, CT_WEXPROP, DriverID1, DriverID2,   |
|               DriverIDCount, eApproval, eBatchNo, eCardNo, eCardType,      |
|               eDate, eDriverID, eExpDate, EntryType, eOdometer,            |
|               eRestrictionCode, eSeqNo, eVehicleNo, eVisibleDriverID,      |
|               ExpDate, FieldToken, fmADSCCForm, fmPOS, lApproval, lBatchNo,|
|               lDate, lDriver, lOdometer, lRestrictionCode, lSeqNo,         |
|               lVehicle, MSRData, PINToken, PrevField, sKeyType, sKeyVal,   |
|               sPreset, WM_CREDITMSG, WM_SETPIN                             |
|                                                                            |
| LOCALS:       eLen, eMM, eNo                                               |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.ProcessKey;
var
//cwe...
//eLen, eNo, eMM, eYY : short;
eLen, eNo, eMM : short;
//...cwe
begin

  while True do
    begin

      if sKeyType = 'CLR' then
        begin
          case FieldToken of
          1 : { Card Number }
            begin
              if eCardNo.Caption = '' then
                begin
                  eCardNo.Color := clBtnFace;
                  close;
                end
              else
                begin
                  eCardNo.Caption := '';
                end;
            end;
          2 : { ExpDate }
            begin
              if eExpDate.Caption = '' then
                begin
                  PrevField := 1;
                  SetPrevField;
                end
              else
                begin
                  eExpDate.Caption := '';
                end;
            end;
          3 : { Restriction Code}
            begin
              if eRestrictionCode.Caption = '' then
                begin
                  if (PrevField = FieldToken) or (PrevField >= 90) then
                    close
                  else
                    SetPrevField;
                end
              else
                begin
                  eRestrictionCode.Caption := '';
                end;
            end;
          4 : { Vehicle No }
            begin
              if eVehicleNo.Caption = '' then
                begin
                  if (PrevField = FieldToken) or (PrevField >= 90) then
                    close
                  else
                    SetPrevField;
                end
              else
                begin
                  eVehicleNo.Caption := '';
                end;
            end;
          5 : { DriverID }
            begin
              if eDriverID.Caption = '' then
                begin
                  if bRetryDriverID then
                    close
                  else
                    begin
                      if (PrevField = FieldToken) or (PrevField >= 90) then
                        close
                      else
                        SetPrevField;
                    end;
                end
              else
                begin
                  eDriverID.Caption := '';
                  eVisibleDriverID.Caption := '';
                end;
            end;
          6 : { Odometer }
            begin
              if eOdometer.Caption = '' then
                begin
                  if (PrevField = FieldToken) or (PrevField >= 90) then
                    close
                  else
                    SetPrevField;
                end
              else
                begin
                  eOdometer.Caption := '';
                end;
            end;

          10 : { Original Batch No  or Original Sequence No}
            begin
              if eBatchNo.Caption = '' then
                begin
                  if (PrevField = FieldToken) or (PrevField >= 90) then
                    close
                  else
                    SetPrevField;
                end
              else
                begin
                  eBatchNo.Caption := '';
                end;
            end;

          11 : { Original Seq No }
            begin
              if eSeqNo.Caption = '' then
                begin
                  SetPrevField;
                end
              else
                begin
                  eSeqNo.Caption := '';
                end;
            end;
          12 : { Original Date }
            begin
              if eDate.Caption = '' then
                begin
                  SetPrevField;
                end
              else
                begin
                  eDate.Caption := '';
                end;
            end;
          20 : { Approval Code }
            begin
              if eApproval.Caption = '' then
                begin
                  close
                end
              else
                begin
                  eApproval.Caption := '';
                end;
            end;
          end;
        end
      else if sKeyType = 'BSP' then
        begin
          case FieldToken of
          1 : { Card Number }
            begin
              if length(eCardNo.Caption) > 0 then
                eCardNo.Caption := copy(eCardNo.Caption, 1, (length(eCardNo.Caption) - 1));
            end;
          2 : { ExpDate }
            begin
              if length(eExpDate.Caption) > 0 then
                eExpDate.Caption := copy(eExpDate.Caption, 1, (length(eExpDate.Caption) - 1));
            end;
          3 : { Restriction Code}
            begin
              if length(eRestrictionCode.Caption) > 0 then
                eRestrictionCode.Caption := copy(eRestrictionCode.Caption, 1, (length(eRestrictionCode.Caption) - 1));
            end;
          4 : { Vehicle No }
            begin
              if length(eVehicleNo.Caption) > 0 then
                eVehicleNo.Caption := copy(eVehicleNo.Caption, 1, (length(eVehicleNo.Caption) - 1));
            end;
          5 : { DriverID }
            begin
              if length(eDriverID.Caption) > 0 then
                eDriverID.Caption := copy(eDriverID.Caption, 1, (length(eDriverID.Caption) - 1));
            end;
          6 : { Odometer }
            begin
              if length(eOdometer.Caption) > 0 then
                eOdometer.Caption := copy(eOdometer.Caption, 1, (length(eOdometer.Caption) - 1));
            end;
          10 : { Original Batch No  or Original Sequence No}
            begin
              if length(eBatchNo.Caption) > 0 then
                eBatchNo.Caption := copy(eBatchNo.Caption, 1, (length(eBatchNo.Caption) - 1));
            end;
          11 : { Original Seq No }
            begin
              if length(eSeqNo.Caption) > 0 then
                eSeqNo.Caption := copy(eSeqNo.Caption, 1, (length(eSeqNo.Caption) - 1));
            end;
          12 : { Original Date }
            begin
              if length(eDate.Caption) > 0 then
                eDate.Caption := copy(eDate.Caption, 1, (length(eDate.Caption) - 1));
            end;
          20 : { Approval Code }
            begin
              if length(eApproval.Caption) > 0 then
                eApproval.Caption := copy(eApproval.Caption, 1, (length(eApproval.Caption) - 1));
            end;
          end;
        end
      else if sKeyType = 'NUM' then
        begin
          case FieldToken of
          1 :
            begin
              eCardNo.Caption := eCardNo.Caption + sKeyVal;
            end;
          2 :
            begin
              eExpDate.Caption := eExpDate.Caption + sKeyVal;
            end;
          3 :
            begin
              eRestrictionCode.Caption := eRestrictionCode.Caption + sKeyVal;
            end;
          4 :
            begin
              eVehicleNo.Caption := eVehicleNo.Caption + sKeyVal;
            end;
          5 :
            begin
              eDriverID.Caption  := eDriverID.Caption + sKeyVal;
              eVisibleDriverID.Caption   := StringOfChar('*',Length(eDriverID.Caption));
            end;
          6 :
            begin
              eOdometer.Caption  := eOdometer.Caption + sKeyVal;
            end;
          10 :
            begin
              eBatchNo.Caption  := eBatchNo.Caption + sKeyVal;
            end;
          11 :
            begin
              eSeqNo.Caption  := eSeqNo.Caption + sKeyVal;
            end;
          12 :
            begin
              eDate.Caption  := eDate.Caption + sKeyVal;
            end;
          20 :
            begin
              eApproval.Caption  := eApproval.Caption + sKeyVal;
            end;
          end;
        end
      else if sKeyType = 'ENT' then
        begin
          PrevField := FieldToken;
          case FieldToken of
          1 :   { Card No }
            begin
              if length(eCardNo.Caption) > 0 then
                begin
                  FieldToken := 2;
                  SetActiveField;
                end;
            end;
          2 :  { ExpDate }
            begin
              if length(eExpDate.Caption) > 0 then
                begin
                  eExpDate.Color := clBtnFace;
                  CardNo  := eCardNo.Caption;
                  ExpDate := eExpDate.Caption;
                  EntryType := 'M';
                  MSRData := '';
                  FieldToken := 90;
                  continue;
                end;
            end;

          3 : {bGetRestrictionCode  - only used for manual voyager entry}
            begin

              if ValidRestrictionCode then
                begin

                  if bGetVehicleNo then
                    lVehicle.Visible := True;
                  if bGetDriverID then
                    lDriver.Visible := True;
                  if bGetOdometer then
                    lOdometer.Visible := True;


                  if bGetVehicleNo then
                    FieldToken := 4
                  else if bGetDriverID then
                    FieldToken := 5
                  else if bGetOdometer then
                    FieldToken := 6
                  else
                    begin
                      FieldToken := 99;
                      continue;
                    end;
                  SetActiveField;
                end
              else
                fmPOS.POSError(CardError);

            end;
          4 : {VehicleNo}
            begin
              if ValidVehicleNo then
                begin
                  if bGetDriverID then
                    FieldToken := 5
                  else if bGetOdometer then
                    FieldToken := 6
                  else
                    begin
                      FieldToken := 95;
                      continue;
                    end;
                end
              else
                begin
                  fmPOS.POSError(CardError);
                  eVehicleNo.Caption := '';
                end;
              SetActiveField;


            end;
          5 : {Driver ID}
            begin
              if ValidDriverID then
                begin
                  if bRetryDriverID then
                    begin
                       if DriverIDCount = 2 then
                         begin
                            if eDriverID.Caption = DriverID1 then
                              begin
                                Inc(DriverIDCount);
                                DriverID2 := eDriverID.Caption;
                                fmPOS.POSError('Invalid PIN - Retry');
                                eDriverID.Caption := '';
                                eVisibleDriverID.Caption := '';
                                SetActiveField;
                              end
                            else
                              begin
                                FieldToken := 99;
                                continue;
                              end;
                         end
                       else
                         begin
                            if (eDriverID.Caption = DriverID1) or (eDriverID.Caption = DriverID2) then
                              begin
                                fmPOS.POSError('Invalid PIN - Declined');
                                bRetryDriverID := False;
                                bWEXNotAllowed := True;
                                close;
                              end
                            else
                              begin
                                FieldToken := 99;
                                continue;
                              end;
                          end;
                    end
                  else
                    begin
                      if bGetOdometer then
                        FieldToken := 6
                      else
                        begin
                          FieldToken := 95;
                          continue;
                        end;
                    end;
                end
              else
                begin
                  fmPOS.POSError(CardError);
                  eDriverID.Caption := '';
                  eVisibleDriverID.Caption := '';
                end;
              SetActiveField;

            end;
          6 : {Odometer}
            begin
              if ValidOdometer then
                begin
                  FieldToken := 95;
                  SetActiveField;
                  continue;
                end
              else
                begin
                  fmPOS.POSError(CardError);
                  eOdometer.Caption := '';
                  SetActiveField;
                end;
            end;


          10 : { Batch No or Invoice No }
            begin
              eLen := Length(eBatchNo.Caption);
              if bGetInvoiceNo then
                begin
                  if ((eLen >= 1) and (eLen <= 6)) then
                    begin
                      FieldToken := 99;
                      continue;
                    end
                  else
                    begin
                      fmPOS.POSError('Enter 1 to 6 Digits');
                    end;
                end
              else  {getting batch no}
                begin
                  if ((eLen >= 1) and (eLen <= 2)) then
                    begin
                      try
                        eNo := StrToInt(eBatchNo.Caption);
                      except
                        eNo := 0
                      end;
                      if ((eNo >= 1) and (eNo <= 99)) then
                        begin
                          if bGetSeqNo then
                            FieldToken := 11
                          else if bGetDate then
                            FieldToken := 12
                          else
                            begin
                              FieldToken := 99;
                              continue;
                            end;
                        end
                      else
                        begin
                          fmPOS.POSError('Batch Number Must Be 1 to 99');
                        end;
                    end
                  else
                    begin
                      fmPOS.POSError('Enter 1 to 2 Digits');
                    end;
                end;
              SetActiveField;
            end;
          11 : {Sequence No}
            begin
              eLen := Length(eSeqNo.Caption);
              if ((eLen >= 1) and (eLen <= 2)) then
                begin
                  try
                    eNo := StrToInt(eBatchNo.Caption);
                  except
                    eNo := 0
                  end;
                  if ((eNo >= 1) and (eNo <= 99)) then
                    begin
                      if bGetDate then
                        FieldToken := 12
                      else
                        begin
                          FieldToken := 99;
                          continue;
                        end;
                    end
                  else
                    begin
                      fmPOS.POSError('Batch Number Must Be 1 to 99');
                    end;
                end
              else
                begin
                  fmPOS.POSError('Enter 1 to 2 Digits');
                end;
              SetActiveField;
            end;


          12 : {Original date}
            begin
              eLen := Length(eDate.Caption);
              if (eLen = 4) then
                begin
                  try
                    eMM := StrToInt(Copy(eDate.Caption,1,2));
//cwe                    eYY := StrToInt(Copy(eDate.Caption,3,2));
                  except
                    eMM := 0;
//cwe                    eYY := 0;
                  end;
                  if ((eMM >= 1) and (eMM <= 12)) then
                    begin
                      FieldToken := 99;
                      continue;
                    end
                  else
                    begin
                      fmPOS.POSError('Invalid Date');
                    end;
                end
              else
                begin
                  fmPOS.POSError('Date Must Be 4 Digits');
                end;
              SetActiveField;
            end;

          20 : {Approval Code}

            begin
              eLen := Length(eApproval.Caption);
              if (eLen = 6) then
                begin
                  FieldToken := 99;
                  continue;
                end
              else
                begin
                  fmPOS.POSError('Code Must Be 6 Digits');
                end;
              SetActiveField;
            end;


          90 :
            begin
              if NOT ValidCardData then
                begin
                  fmPOS.POSError(CardError);
                  ResetLabels;
                  if bNoOrigSale then
                    Close;
                end
              else
                begin
                  eCardType.Caption := CardType;
                  eCardType.Enabled := True;

                  if bWEXNotAllowed and ((CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP)) then
                    begin
                      fmPOS.POSError('WEX Declined For This Transaction');
                      FieldToken := 0;
                      Close;
                      break;
                    end;

                  if bGetRestrictionCode or (eRestrictionCode.Caption <> '') then
                    lRestrictionCode.Visible := True;

                  if bGetVehicleNo then
                    lVehicle.Visible := True;
                  if bGetDriverID then
                    lDriver.Visible := True;
                  if bGetOdometer then
                    lOdometer.Visible := True;
                  if bGetApproval then
                    lApproval.Visible := True;

                  if bGetInvoiceNo then
                    begin
                      lBatchNo.Caption := 'Original Invoice No';
                      lBatchNo.Visible := True;
                    end;
                  if bGetBatchNo then
                    begin
                      lBatchNo.Caption := 'Original Batch No';
                      lBatchNo.Visible := True;
                    end;
                  if bGetSeqNo then
                    lSeqNo.Visible := True;
                  if bGetDate then
                    lDate.Visible := True;


                  if bGetApproval then
                    FieldToken := 20
                  else if bGetRestrictionCode then
                    begin
                      PrevField  := 2;
                      FieldToken := 3
                    end
                  else if bGetVehicleNo then
                    FieldToken := 4
                  else if bGetDriverID then
                    FieldToken := 5
                  else if bGetOdometer then
                    FieldToken := 6
                  else if bGetInvoiceNo then
                    FieldToken := 10
                  else if bGetBatchNo then
                    FieldToken := 10
                  else if bGetSeqNo then
                    FieldToken := 11
                  else if bGetDate then
                    FieldToken := 12
                  else
                    begin
                      FieldToken := 99;
                      SetActiveField;
                      continue;
                    end;
                  SetActiveField;
                end;
            end;

          93 :
            begin
              lDriver.Visible := True;
              FieldToken := 5;
              SetActiveField;
             end;

          95 :
            begin
              if bGetInvoiceNo then
                FieldToken := 10
              else if bGetBatchNo then
                FieldToken := 10
              else if bGetSeqNo then
                FieldToken := 11
              else if bGetDate then
                FieldToken := 12
              else
                begin
                  FieldToken := 99;
                  continue;
                end;
              SetActiveField;
            end;

          99 :
            begin
              FieldToken := 0;
              PINToken := 100;
              PostMessage(fmADSCCForm.Handle, WM_SETPIN, 0, 0);
              if bGetApproval then
                CreditAuthToken := 30  {build data collect}
              else if (ChargeAmount < 0) and NOT ((CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP)) then
                CreditAuthToken := 30  {build data collect}
              else
                CreditAuthToken := 1;  {build authorization}
              PostMessage(fmADSCCForm.Handle, WM_CREDITMSG, 0, 0);
            end;

          end;
        end

      else if sKeyType = 'PMP' then   {Pump Number}
        begin
          fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
        end
      else if sKeyType = 'PAT' then        {Pump Authorize}
        fmPOS.ProcessKeyPAT
      else if sKeyType = 'PAL' then        {Pump Authorize All}
        fmPOS.ProcessKeyPAL
      else if sKeyType = 'EHL' then        { Emergency Halt }
        fmPOS.ProcessKeyEHL
      else if sKeyType = 'PHL' then        { Pump Halt }
        fmPOS.ProcessKeyPHL;
      break
    end;
end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.SetPrevField                                    |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        SetActiveField                                               |
|                                                                            |
| GLOBALS:      FieldToken, PrevField                                        |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.SetPrevField                                    |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        SetActiveField                                               |
|                                                                            |
| GLOBALS:      FieldToken, PrevField                                        |
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
procedure TfmADSCCForm.SetPrevField;
begin
  FieldToken := PrevField;
  SetActiveField;
end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.SetActiveField                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey, ResetLabels, SetPrevField                        |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, eApproval, eBatchNo, eCardNo, eDate, eDriverID,|
|               eExpDate, eOdometer, eRestrictionCode, eSeqNo, eVehicleNo,   |
|               eVisibleDriverID, FieldToken, fmPOS, PinPad1,                |
|               PINPADPROMPT_DRIVERID, PINPADPROMPT_ODOMETER,                |
|               PINPADPROMPT_VEHICLEID                                       |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.SetActiveField                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey, ResetLabels, SetPrevField                        |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      bIgnoreSwipe, eApproval, eBatchNo, eCardNo, eDate, eDriverID,|
|               eExpDate, eOdometer, eRestrictionCode, eSeqNo, eVehicleNo,   |
|               eVisibleDriverID, FieldToken                                 |
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
procedure TfmADSCCForm.SetActiveField;
begin

  eCardNo.Color            := clNavy;
  eExpDate.Color           := clNavy;
  eRestrictionCode.Color   := clNavy;
  eDriverID.Color          := clNavy;
  eVisibleDriverID.Color   := clNavy;
  eVehicleNo.Color         := clNavy;
  eOdometer.Color          := clNavy;
  eBatchNo.Color           := clNavy;
  eSeqNo.Color             := clNavy;
  eDate.Color              := clNavy;
  eApproval.Color          := clNavy;

  eCardNo.Font.Color            := clYellow;
  eExpDate.Font.Color           := clYellow;
  eRestrictionCode.Font.Color   := clYellow;
  eDriverID.Font.Color          := clYellow;
  eVisibleDriverID.Font.Color   := clYellow;
  eVehicleNo.Font.Color         := clYellow;
  eOdometer.Font.Color          := clYellow;
  eBatchNo.Font.Color           := clYellow;
  eSeqNo.Font.Color             := clYellow;
  eDate.Font.Color              := clYellow;
  eApproval.Font.Color          := clYellow;


  eCardNo.BevelInner          := bvNone;
  eExpDate.BevelInner         := bvNone;
  eRestrictionCode.BevelInner := bvNone;
  eVisibleDriverID.BevelInner := bvNone;
  eVehicleNo.BevelInner       := bvNone;
  eOdometer.BevelInner        := bvNone;
  eApproval.BevelInner        := bvNone;

  eCardNo.BevelOuter          := bvNone;
  eExpDate.BevelOuter         := bvNone;
  eRestrictionCode.BevelOuter := bvNone;
  eVisibleDriverID.BevelOuter := bvNone;
  eVehicleNo.BevelOuter       := bvNone;
  eOdometer.BevelOuter        := bvNone;
  eApproval.BevelOuter        := bvNone;



  if FieldToken = 1 then
    bIgnoreSwipe := False
  else
    bIgnoreSwipe := True;

  case FieldToken of
  1 :
     begin
       eCardNo.Color       := clWhite;
       eCardNo.Font.Color  := clBlack;

       eCardNo.BevelInner  := bvLowered;
       eCardNo.BevelOuter  := bvRaised;
     end;
  2 :
     begin
       eExpDate.Color   := clWhite;
       eExpDate.Font.Color   := clBlack;
       eExpDate.BevelInner  := bvLowered;
       eExpDate.BevelOuter  := bvRaised;
     end;

  3 :
     begin
       eRestrictionCode.Color   := clWhite;
       eRestrictionCode.Font.Color   := clBlack;
       eRestrictionCode.BevelInner  := bvLowered;
       eRestrictionCode.BevelOuter  := bvRaised;
     end;
  4 :
     begin
       eVehicleNo.Color       := clWhite;
       eVehicleNo.Font.Color  := clBlack;
       eVehicleNo.BevelInner  := bvLowered;
       eVehicleNo.BevelOuter  := bvRaised;

       (*fmPOS.PinPad1.Prompt    := PINPADPROMPT_VEHICLEID;
       fmPOS.PinPad1.MaskInput := False;
       fmPOS.PinPad1.EntryMode := emNumber;

    // fmPOS.PINPadPort.GetString('VEHICLE ID', PIN_INPUTNOTMASKED);*)

     end;
  5 :
     begin
       eVisibleDriverID.Color       := clWhite;
       eVisibleDriverID.Font.Color  := clBlack;
       eVisibleDriverID.BevelInner  := bvLowered;
       eVisibleDriverID.BevelOuter  := bvRaised;

       (*fmPOS.PinPad1.Prompt     := PINPADPROMPT_DRIVERID;
       fmPOS.PinPad1.MaskInput  := True;
       fmPOS.PinPad1.EntryMode  := emNumber;
    // fmPOS.PINPadPort.GetString('DRIVER ID', PIN_INPUTMASKED);*)

     end;
  6 :
     begin
       eOdometer.Color       := clWhite;
       eOdometer.Font.Color  := clBlack;
       eOdometer.BevelInner  := bvLowered;
       eOdometer.BevelOuter  := bvRaised;

       (*fmPOS.PinPad1.Prompt     := PINPADPROMPT_ODOMETER;
       fmPOS.PinPad1.MaskInput  := False;
       fmPOS.PinPad1.EntryMode  := emNumber;

  //     fmPOS.PINPadPort.GetString('ODOMETER', PIN_INPUTNOTMASKED);*)
     end;

  10 :
     begin
       eBatchNo.Color  := clWhite;
     end;
  11 :
     begin
       eSeqNo.Color  := clWhite;
     end;
  12 :
     begin
       eDate.Color  := clWhite;
     end;

  20 :
     begin
       eApproval.Color  := clWhite;
       eApproval.Font.Color := clBlack  ;
       eApproval.BevelInner  := bvLowered;
       eApproval.BevelOuter  := bvRaised;
     end;

  end;
end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.FormShow                                        |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Sender                                                       |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      fmADSCCForm, WM_INITSCREEN                                   |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.FormShow                                        |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Sender                                                       |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      fmADSCCForm, WM_INITSCREEN                                   |
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
procedure TfmADSCCForm.FormShow(Sender: TObject);
begin

  PostMessage(fmADSCCForm.Handle, WM_INITSCREEN,0 ,0);

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.InitScreen                                      |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        BuildTouchPad, CheckServiceCode, DeformatTrack1Data,         |
|               DeformatTrack2Data, POSError, ResetLabels                    |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetApproval, bGetBatchNo, bGetDate, bGetDriverID,|
|               bGetInvoiceNo, bGetOdometer, bGetRestrictionCode, bGetSeqNo, |
|               bGetVehicleNo, bIgnoreSwipe, bNoOrigSale, bNoSwipe,          |
|               bRetryDriverID, bSwipeErrFlag, BuffPtr, CardError, CardName, |
|               CardNo, CardType, CardTypeNo, DriverID1, DriverID2,          |
|               DriverID3, DriverIDCount, eCardName, eCardNo, eCardType,     |
|               eExpDate, EntryType, ExpDate, FieldToken, fmADSCCForm, fmPOS,|
|               fOne, IAESAuth, lCardName, lCardType, lStatus, MSRData,      |
|               nSwipeCount, PHHAuth, POSButtons, POSScreenSize,             |
|               sCCApprovalCode, sCCAuthCode, sCCBatchNo, sCCCardName,       |
|               sCCCardNo, sCCCardType, sCCDate, sCCEntryType, sCCExpDate,   |
|               sCCOdometer, sCCSeqNo, sCCTime, sCCVehicleNo, ServiceCode,   |
|               sKeyType, Track1Data, Track2Data, UserData, UserDataCount,   |
|               VoyagerAuth, VoyagerCredit, WEXCredit, WEXFuelAndNonFuelProd,|
|               WEXFuelAndTwoNonFuelProd, WEXSingleFuelProd,                 |
|               WEXSingleNonFuelProd, WEXThreeNonFuelProd, WEXTwoNonFuelProd,|
|               WM_CHECKKEY                                                  |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.InitScreen                                      |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        BuildTouchPad, CheckServiceCode, DeformatTrack1Data,         |
|               DeformatTrack2Data, POSError, ResetLabels                    |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetApproval, bGetBatchNo, bGetDate, bGetDriverID,|
|               bGetInvoiceNo, bGetOdometer, bGetRestrictionCode, bGetSeqNo, |
|               bGetVehicleNo, bIgnoreSwipe, bNoOrigSale, bNoSwipe,          |
|               bRetryDriverID, bSwipeErrFlag, BuffPtr, CardError, CardName, |
|               CardNo, CardType, CardTypeNo, DriverID1, DriverID2,          |
|               DriverID3, DriverIDCount, eCardName, eCardNo, eCardType,     |
|               eExpDate, EntryType, ExpDate, FieldToken, fmADSCCForm, fmPOS,|
|               fOne, IAESAuth, lCardName, lCardType, lStatus, MSRData,      |
|               nSwipeCount, PHHAuth, POSButtons, POSScreenSize,             |
|               sCCApprovalCode, sCCAuthCode, sCCBatchNo, sCCCardName,       |
|               sCCCardNo, sCCCardType, sCCDate, sCCEntryType, sCCExpDate,   |
|               sCCOdometer, sCCSeqNo, sCCTime, sCCVehicleNo, ServiceCode,   |
|               sKeyType, Track1Data, Track2Data, UserData, UserDataCount,   |
|               VoyagerAuth, VoyagerCredit, WEXCredit, WEXFuelAndNonFuelProd,|
|               WEXFuelAndTwoNonFuelProd, WEXSingleFuelProd,                 |
|               WEXSingleNonFuelProd, WEXThreeNonFuelProd, WEXTwoNonFuelProd,|
|               WM_CHECKKEY                                                  |
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
procedure TfmADSCCForm.InitScreen(var Msg:TMessage);
begin


  case fmPOS.POSScreenSize of
  1 :
    begin
      fmADSCCForm.Left := 169;
      fmADSCCForm.Top  := 291;
    end;
  2 :
    begin
      fmADSCCForm.Left := 123;
      fmADSCCForm.Top  := 243;
    end;
  end;

  if POSButtons[1] = nil then
    BuildTouchPad;



  fOne := False;
  ResetLabels;

  New(WEXSingleFuelProd);
  New(WEXSingleNonFuelProd);
  New(WEXFuelAndNonFuelProd);
  New(WEXTwoNonFuelProd);
  New(WEXFuelAndTwoNonFuelProd);
  New(WEXThreeNonFuelProd);
  New(WEXCredit);
  New(PHHAuth);
  New(IAESAuth);
  New(VoyagerAuth);
  New(VoyagerCredit);

  CardNo        := '';
  ExpDate       := '';
  CardType      := '';
  CardTypeNo    := '';
  CardName      := '';
  EntryType     := '';
  ServiceCode   := '';
  CardError     := '';
  Track1Data    := '';
  Track2Data    := '';
  UserData      := '';
  UserDataCount := '';

  sCCAuthCode     := '';
  sCCApprovalCode := '';
  sCCDate         := '';
  sCCTime         := '';
  sCCCardNo       := '';
  sCCCardName     := '';
  sCCCardType     := '';
  sCCExpDate      := '';
  sCCBatchNo      := '';
  sCCSeqNo        := '';
  sCCEntryType    := '';
  sCCVehicleNo    := '';
  sCCOdometer     := '';

  bFuelOnly             := False;
  bGetVehicleNo         := False;
  bGetDriverID          := False;
  bGetOdometer          := False;
  bGetRestrictionCode   := False;
  bGetApproval          := False;
  bGetBatchNo           := False;
  bGetInvoiceNo         := False;
  bGetSeqNo             := False;
  bGetDate              := False;
  bRetryDriverID        := False;
  bIgnoreSwipe          := True;
  bNoOrigSale           := False;

  DriverID1 := '';
  DriverID2 := '';
  DriverID3 := '';
  DriverIDCount := 1;

  lStatus.Visible := False;
  lStatus.Caption := '';
  BuffPtr := 0;

  ServiceCode := '000';
  bSwipeErrFlag := False;

  if copy(MSRData,1,1) = '%' then             {Magstripe indicator Track 1}
    begin
      DeformatTrack1Data;
      CheckServiceCode;
      if NOT bSwipeErrFlag then
        begin
          lCardName.Visible := True;
          eCardName.Enabled := True;
          lCardType.Visible := True;
          eCardType.Enabled := True;
          eCardNo.Caption := CardNo;
          eCardName.Caption := CardName;
          eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);

          EntryType := 'S';
          sKeyType := 'ENT';
          PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt('Z'), 0);

       {
          FieldToken := 90;
          ProcessKey;
       }
          exit;
        end;
    end
  else if copy(MSRData,1,1) = ';' then             {Magstripe indicator Track 2}
    begin
      DeformatTrack2Data;
      CheckServiceCode;
      if NOT bSwipeErrFlag then
        begin
          lCardName.Visible := True;
          eCardName.Enabled := True;
          lCardType.Visible := True;
          eCardType.Enabled := True;
          eCardNo.Caption := CardNo;
          eCardName.Caption := CardName;
          eExpDate.Caption := Copy(ExpDate,1,2) + '/' + Copy(ExpDate,3,2);
          EntryType := 'S';
          sKeyType := 'ENT';

          PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt('Z'), 0);

      {    FieldToken := 90;
          ProcessKey;
        }
          exit;
        end;
    end
  else
    begin
      bIgnoreSwipe := False;
      FieldToken := 1;
    end;

  if bSwipeErrFlag then
    begin
      if nSwipeCount > 3 then
        begin
          bNoSwipe := True;
          fmPOS.POSError('Bad Card Read - Please Enter Manually' );
        end
      else
        fmPOS.POSError('Bad Read - Please Swipe Again');
    end;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.DeformatTrack1Data                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        CheckCardNoSpaces                                            |
|                                                                            |
| GLOBALS:      bSwipeErrFlag, CardName, CardNo, ExpDate, MSRData,           |
|               nSwipeCount, ServiceCode, Track1Data, Track2Data             |
|                                                                            |
| LOCALS:       CharPosition, FirstPOS, ptr, r1                              |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.DeformatTrack1Data                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        CheckCardNoSpaces                                            |
|                                                                            |
| GLOBALS:      bSwipeErrFlag, CardName, CardNo, ExpDate, MSRData,           |
|               nSwipeCount, ServiceCode, Track1Data, Track2Data             |
|                                                                            |
| LOCALS:       CharPosition, FirstPOS, ptr, r1                              |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.DeformatTrack1Data;
var
FirstPOS, CharPosition, r1, ptr : short;
begin

//%B5419841234567890^MASTERCARD2^9912101123456789?
//;5419841234567890=9912101123456789?

// do this only if its an msr

  Track1Data := '';
  Track2Data := '';

  r1 := Length(MSRData);
  CharPosition := Pos(';',MSRData);
  if CharPosition > 0 then
    begin
      Track1Data := Copy(MSRData, 1, CharPosition-1);
      Track2Data := Copy(MSRData, CharPosition , r1-CharPosition+1 );

      if Copy(MSRData,2,1) = 'B' then
        begin
          CharPosition := Pos('^',MSRData);
          if CharPosition > 0 then
            begin
              CardNo := Copy(MSRData,3,CharPosition-3);
              for ptr := (CharPosition + 1) to r1 do
                begin
                  if MSRData[ptr] = '^' then
                    break;
                end;
              CardName := Copy(MSRData,CharPosition+1,ptr-CharPosition-1);
              ExpDate := Copy(MSRData,ptr+3,2) + Copy(MSRData,ptr+1,2);
              ServiceCode := Copy(MSRData, ptr+5, 3);
            end;
        end
      else   {try to use track 2}
        begin
          Track1Data := '';
          FirstPOS := Pos(';',MSRData);
          CharPosition := Pos('=',MSRData);
          if CharPosition > 0 then
            begin
              CardNo  := Copy(MSRData, (FirstPOS + 1), CharPosition-(FirstPOS + 1));
              if Copy(CardNo,1,6) = '707910' then
                ExpDate := Copy(MSRData, CharPosition+1, 2) + Copy(MSRData, CharPosition+3, 2) {date is backwards on iaes}
              else
                ExpDate := Copy(MSRData, CharPosition+3, 2) + Copy(MSRData, CharPosition+1, 2);


              ServiceCode := Copy(MSRData, CharPosition+5, 3);


            end;
        end;
    end
  else {maybe its only track 1}
    begin
      CharPosition := Pos('?',MSRData);
      if CharPosition > 0 then
        begin
          Track1Data := Copy(MSRData, 1, CharPosition);
          Track2Data := '';
          if Copy(MSRData,2,1) = 'B' then
            begin
              CharPosition := Pos('^',MSRData);
              if CharPosition > 0 then
                begin
                  CardNo := Copy(MSRData,3,CharPosition-3);
                  for ptr := (CharPosition + 1) to r1 do
                    begin
                      if MSRData[ptr] = '^' then
                        break;
                    end;
                  CardName := Copy(MSRData,CharPosition+1,ptr-CharPosition-1);
                  ExpDate := Copy(MSRData,ptr+3,2) + Copy(MSRData,ptr+1,2);
                  ServiceCode := Copy(MSRData, ptr+5, 3);
                end;
            end
          else
            begin
              bSwipeErrFlag := True;
              Inc(nSwipeCount);
            end
        end
      else
        begin
          bSwipeErrFlag := True;
          Inc(nSwipeCount);
        end;

    end;

  if Length(CardNo) < 5 then
    bSwipeErrFlag := True;

  if NOT bSwipeErrFlag then
    CheckCardNoSpaces;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.DeformatTrack2Data                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        CheckCardNoSpaces                                            |
|                                                                            |
| GLOBALS:      bSwipeErrFlag, CardNo, ExpDate, MSRData, nSwipeCount,        |
|               ServiceCode, Track1Data, Track2Data                          |
|                                                                            |
| LOCALS:       CharPosition                                                 |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.DeformatTrack2Data                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        CheckCardNoSpaces                                            |
|                                                                            |
| GLOBALS:      bSwipeErrFlag, CardNo, ExpDate, MSRData, nSwipeCount,        |
|               ServiceCode, Track1Data, Track2Data                          |
|                                                                            |
| LOCALS:       CharPosition                                                 |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.DeformatTrack2Data;
var
CharPosition  : short;
begin

//;5419841234567890=9912101123456789?

// do this only if its an msr

  Track1Data := '';
  Track2Data := MSRData;
  CharPosition := Pos('=',MSRData);
  if CharPosition > 0 then
    begin
      CardNo      := Copy(MSRData, 2, CharPosition-2);
      ExpDate     := Copy(MSRData, CharPosition+3, 2) + Copy(MSRData, CharPosition+1, 2);
      ServiceCode := Copy(MSRData, CharPosition+5, 3);
    end
  else
    begin
      bSwipeErrFlag := True;
      Inc(nSwipeCount);
    end;

  if Length(CardNo) < 5 then
    bSwipeErrFlag := True;

  if NOT bSwipeErrFlag then
    CheckCardNoSpaces;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckCardNoSpaces                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    DeformatTrack1Data, DeformatTrack2Data                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardNo                                                       |
|                                                                            |
| LOCALS:       CardLen, CopyCardNo, ndx                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckCardNoSpaces                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    DeformatTrack1Data, DeformatTrack2Data                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardNo                                                       |
|                                                                            |
| LOCALS:       CardLen, CopyCardNo, ndx                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.CheckCardNoSpaces;
var
ndx, CardLen : short;
CopyCardNo : string[40];
begin
  CopyCardNo := '';
  CardLen := Length(CardNo);
  for ndx := 1 to CardLen do
    if not(CardNo[ndx] = ' ') then
      begin
        CopyCardNo := CopyCardNo + CardNo[ndx];
      end;
  CardNo := '';
  CardNo := CopyCardNo;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckServiceCode                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      ServiceCode                                                  |
|                                                                            |
| LOCALS:       nSCode                                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckServiceCode                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckKey, InitScreen, PreProcessKey                          |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      ServiceCode                                                  |
|                                                                            |
| LOCALS:       nSCode                                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.CheckServiceCode;
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


{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidCardData                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        ValidChecksum, ValidDate, ValidRestrictionCode,              |
|               ValidSpecChecksum                                            |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetDriverID, bGetOdometer, bGetRestrictionCode,  |
|               bGetVehicleNo, bNoOrigSale, CardError, CardLen, CardNo,      |
|               CardType, CardTypeNo, ChargeAmount, CT_AMEX, CT_DINERS,      |
|               CT_DISCOVER, CT_IAES, CT_MASTERCARD, CT_PHH, CT_PROPRIETARY, |
|               CT_VISA, CT_VOYAGER, CT_WEX, CT_WEXPROP, eBatchNo, eCardNo,  |
|               eDate, EntryType, eRestrictionCode, ERR_CARDNOTACCEPTED,     |
|               ERR_INVALIDACCOUNT, ERR_NOCREDITS, ERR_NOISO, eSeqNo,        |
|               eVehicleNo, FirstTwoChars, IBTempQuery, lVehicle, POSDataMod,|
|               ServiceCode, Track2Data, TypeNo                              |
|                                                                            |
| LOCALS:       PANNo, rcode, TmpInt                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidCardData                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        ValidChecksum, ValidDate, ValidRestrictionCode,              |
|               ValidSpecChecksum                                            |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetDriverID, bGetOdometer, bGetRestrictionCode,  |
|               bGetVehicleNo, bNoOrigSale, CardError, CardLen, CardNo,      |
|               CardType, CardTypeNo, ChargeAmount, CT_AMEX, CT_DINERS,      |
|               CT_DISCOVER, CT_IAES, CT_MASTERCARD, CT_PHH, CT_PROPRIETARY, |
|               CT_VISA, CT_VOYAGER, CT_WEX, CT_WEXPROP, eBatchNo, eCardNo,  |
|               eDate, EntryType, eRestrictionCode, ERR_CARDNOTACCEPTED,     |
|               ERR_INVALIDACCOUNT, ERR_NOCREDITS, ERR_NOISO, eSeqNo,        |
|               eVehicleNo, FirstTwoChars, IBTempQuery, lVehicle, POSDataMod,|
|               ServiceCode, Track2Data, TypeNo                              |
|                                                                            |
| LOCALS:       PANNo, rcode, TmpInt                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidCardData : boolean;
var
rcode : boolean;
TmpInt : integer;
PANNo : currency;

begin

  TmpInt := 0;
  rcode := False;
  CardNo  := eCardNo.Caption;
  CardLen := Length(CardNo);
  CardType := '';
  CardTypeNo := '';
  CardError := ERR_INVALIDACCOUNT;
  bGetVehicleNo := False;
  bGetDriverID := False;
  bGetOdometer := False;
  bFuelOnly := False;
  FirstTwoChars := copy(CardNo,1,2);

  while True do
    begin

        try
          TypeNo := StrToInt(Copy(CardNo,1,6));
        except
          CardError := ERR_INVALIDACCOUNT;
          break;
        end;

        case TypeNo of
        471531 :   {Visa Fleet}
          begin
            if NOT (CardLen = 16) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidChecksum then
              begin
                break;
              end;
            if NOT ValidDate then
              break;

            try
              TmpInt := StrToInt(Copy(CardNo,7,1));
            except
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
            case TmpInt of
            2 : bGetVehicleNo := True;
            3, 4 :
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            end;

            bGetOdometer := True;
            bGetDriverID := True;

            CardType := 'Visa Fleet';
            CardTypeNo := CT_IAES;
            rCode := True;
            break;
          end;

        601100..601109, 601120..601149, 601190..601199 :
          begin
            if NOT (CardLen = 16) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidChecksum then
              begin
                break;
              end;
            if NOT ValidDate then
              break;
            CardType := 'DISCOVER';
            CardTypeNo := CT_DISCOVER;
            rCode := True;
            break;
          end;

        690046 :
          begin
            if NOT (CardLen = 19) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidSpecChecksum(13,18,19) then
              begin
                break;
              end;
            if NOT ValidDate then
              break;

            if EntryType <> 'S' then
              begin
                CardError := ERR_NOISO;
                break;
              end;

            if (Copy(CardNo,7,2) = '02') or (Copy(CardNo,7,2) = '04') then
              begin
                CardType := 'WEX';
                CardTypeNo := CT_WEX;
              end
            else if Copy(CardNo,7,2) = '25' then
              begin
                CardType := 'WEX - CLARK';
                CardTypeNo := CT_WEXPROP;
              end
            else
              begin
                CardError := ERR_CARDNOTACCEPTED;
                break;
              end;
    //       bGetVehicleNo  := True;

            eVehicleNo.Caption := Copy (Track2Data, 29,5);
            lVehicle.Visible := True;

            if (Copy(CardNo,11,2) <> '01') and (CardTypeNo = CT_WEXPROP) then
              begin
                bGetDriverID := True;
                bGetOdometer  := True;
              end
            else if (CardTypeNo = CT_WEX) then
              begin
                bGetDriverID := True;
                bGetOdometer  := True;
              end;

            if ChargeAmount < 0 then
              begin
                with POSDataMod.IBTempQuery do
                  begin
                    Close;
                    SQL.Clear;

                    SQL.Add('SELECT * FROM CCBatch');
                    SQL.Add('Where AcctNumber = ' + CardNo);
                    SQL.Add('Order By BatchID, SeqNo');
                    Open;
                    If BOF and EOF then { empty ? }
                      begin
                        CardError := 'Credit Not Allowed - No Original Sale';
                        bNoOrigSale := True;
                        close;
                        break;
                      end
                    else
                      begin
                        Last;
                        eBatchNo.Caption := FieldByName('BatchNo').AsString;
                        eSeqNo.Caption   := FieldByName('SeqNo').AsString;
                        eDate.Caption  := FieldByName('TermDate').AsString;

                        eBatchNo.Visible := False;
                        eSeqNo.Visible := False;
                        eDate.Visible := False;

                      end;
                    Close;
                  End;

            //    bGetBatchNo := True;
            //    bGetSeqNo   := True;
            //    bGetDate    := True;
              end;

            rCode := True;
            break;
          end;

        707654 :
          begin
            if NOT (CardLen = 16) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidChecksum then
              begin
                break;
              end;
            if NOT ValidDate then
              break;
            CardType := 'Clark';
            CardTypeNo := CT_PROPRIETARY;
            rCode := True;
            break;
          end;

        707910 :
          begin
            if NOT (CardLen = 19) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            try
              {//cwe   TmpInt := }StrToInt(Copy(CardNo,7,2));
            except
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;

            try
              TmpInt := StrToInt(Copy(CardNo,9,6));
              if NOT ((TmpInt >= 0) and (TmpInt <= 999999)) then
                begin
                  CardError := ERR_INVALIDACCOUNT;
                  break;
                end;
            except
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;

            if NOT ValidDate then
              break;

            if ChargeAmount < 0 then
              begin
                CardError := ERR_NOCREDITS;
                break;
              end;


            try
              TmpInt := StrToInt(Copy(CardNo,7,1));
            except
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
            case TmpInt of
            2 : bGetVehicleNo := True;
            3, 4 :
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            end;

            bGetOdometer := True;
            bGetDriverID := True;

            CardType := 'IAES';
            CardTypeNo := CT_IAES;
            rCode := True;
            break;

          end;


        708885, 708886, 708887, 708888, 708889 :
          begin
            if NOT (CardLen = 19) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidChecksum then
              begin
                break;
              end;
            if NOT ValidSpecChecksum(5,12,13) then
              begin
                break;
              end;
            if NOT ValidDate then
               break;

            if EntryType = 'S' then
              begin
                eRestrictionCode.Caption := Copy(ServiceCode,1,2);
                if NOT ValidRestrictionCode then
                  begin
                    CardError := ERR_INVALIDACCOUNT;
                    break;
                  end;
              end
            else
              bGetRestrictionCode := True;

            if ChargeAmount < 0 then
              begin
                with POSDataMod.IBTempQuery do
                  begin
                    Close;
                    SQL.Clear;

                    SQL.Add('SELECT * FROM CCBatch');
                    SQL.Add('Where AcctNumber = ' + CardNo);
                    Open;
                    If BOF and EOF then { empty ? }
                      begin
                        CardError := 'Credit Not Allowed - No Original Sale';
                        bNoOrigSale := True;
                        close;
                        break;
                      end
                    else
                      begin
                        Last;
                        eBatchNo.Caption := FieldByName('TransNo').AsString;

                        eBatchNo.Visible := False;
                        eSeqNo.Visible := False;
                        eDate.Visible := False;

                      end;
                    Close;
                  End;

              end;

            CardNo := Copy(CardNo,5,15);
            CardLen := 15;
            CardType := 'VOYAGER';
            CardTypeNo := CT_VOYAGER;

    //        if ChargeAmount < 0 then
    //          begin
    //            bGetInvoiceNo := True;
    //          end;



            rCode := True;
            break;
          end;

        744003, 760300..760399 :
          begin

            {add code to check sub account ranges}
            if NOT (CardLen = 19) then
              begin
                CardError := ERR_INVALIDACCOUNT;
                break;
              end;
            if NOT ValidSpecChecksum(5,13,14) then
              begin
                break;
              end;
            if NOT ValidSpecChecksum(5,17,18) then
              begin
                break;
              end;
            if NOT ValidDate then
               break;

            if TypeNo <> 744003 then  {then its a domestic PHH}
              begin
                try
                  PANNo := StrToCurr(Copy(CardNo,5,14));
                except
                  PANNo := 0;
                end;
                if NOT (((PANNo >= 500230010000.0) and (PANNo <= 500269999999.0)) or
                   ((PANNo >= 500270110000.0) and (PANNo <= 500279999999.0)) or
                   ((PANNo >= 500285110000.0) and (PANNo <= 500299999999.0)) or
                   ((PANNo >= 550000040000.0) and (PANNo <= 550299959999.0))) then
                  begin
                    CardError := ERR_INVALIDACCOUNT;
                    break;
                  end;
                CardNo := Copy(CardNo,5,14);
                CardLen := 14;
              end;

            bGetVehicleNo := True;
            bGetOdometer := True;
            CardType := 'PHH';
            CardTypeNo := CT_PHH;
            rCode := True;
            break;
          end;

        end;


      if (FirstTwoChars = '51') or (FirstTwoChars = '52') or (FirstTwoChars = '53') or
         (FirstTwoChars = '54') or (FirstTwoChars = '55') then
        begin
          if CardLen <> 16 then
            begin
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
          if NOT ValidChecksum then
            begin
              break;
            end;
          if NOT ValidDate then
            break;
          CardType := 'MasterCard';
          CardTypeNo := CT_MASTERCARD;
          rCode := True;
          break;
        end

      else if CardNo[1] = '4' then
        begin
          if NOT ((CardLen = 13) or (CardLen = 16)) then
            begin
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
          if NOT ValidChecksum then
            begin
              break;
            end;
          if NOT ValidDate then
            break;
          CardType := 'VISA';
          CardTypeNo := CT_VISA;
          rCode := True;
          break;

        end
      else if (FirstTwoChars = '34') or (FirstTwoChars = '37') then
        begin
          if NOT (CardLen = 15) then
            begin
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
          if NOT ValidChecksum then
            begin
              break;
            end;
          if NOT ValidDate then
            break;
          CardType := 'AMEX';
          CardTypeNo := CT_AMEX;
          rCode := True;
          break;
        end

      else if (FirstTwoChars = '30') or (FirstTwoChars = '36')
                                     or (FirstTwoChars = '38') then
        begin
          if NOT (CardLen = 14) then
            begin
              CardError := ERR_INVALIDACCOUNT;
              break;
            end;
          if NOT ValidChecksum then
            begin
              break;
            end;
          if NOT ValidDate then
            break;
          CardType := 'DINERS';
          CardTypeNo := CT_DINERS;
          rCode := True;
          break;
        end;


      {we only get her if its not any other card type }
      {if so, and this is a manual entry, see if its wex or voyager with out the iso number}

      if EntryType = 'M' then
        begin
          if (CardLen = 13) then     {maybe its a wex}
            begin
              if (Copy(CardNo,1,2) = '02') or (Copy(CardNo,1,2) = '04') then
                begin
                  CardType := 'WEX';
                  CardTypeNo := CT_WEX;
                end
              else if Copy(CardNo,1,2) = '25' then
                begin
                  CardType := 'WEX - CLARK';
                  CardTypeNo := CT_WEXPROP;
                end
              else
                begin
                  CardError := ERR_CARDNOTACCEPTED;
                  break;
                end;
              if NOT ((Copy(CardNo,5,2) <> '00') or (Copy(CardNo,5,2) <> '01')) then
                begin
                  CardError := ERR_CARDNOTACCEPTED;
                  break;
                end;
              if NOT ValidSpecChecksum(7,12,13) then
                begin
                  break;
                end;
              if NOT ValidDate then
                break;
              bGetVehicleNo  := True;
              if Copy(CardNo,5,2) <> '01' then
                begin
                  bGetDriverID := True;
                  bGetOdometer  := True;
                end;
              CardNo := '690046' + CardNo;
              CardLen := CardLen + 6;
              rCode := True;
              break;
            end
          else if (CardLen = 15) then     {maybe its a voyager}
            begin
              if ((Copy(CardNo,1,2) <> '85') or (Copy(CardNo,1,2) <> '86')
                                             or (Copy(CardNo,1,2) <> '87')
                                             or (Copy(CardNo,1,2) <> '88')
                                             or (Copy(CardNo,1,2) <> '89')) then
                begin
                 CardNo := '7088' + CardNo;
                 CardLen := CardLen + 4;
                  if NOT ValidChecksum then
                    begin
                     break;
                    end;
                  CardLen := 15;
                  CardNo := Copy(CardNo,5,15);

                  if NOT ValidSpecChecksum(1,8,9) then
                    begin
                      break;
                    end;
                  if NOT ValidDate then
                    break;
                  bGetRestrictionCode := True;
                  CardType := 'VOYAGER';
                  CardTypeNo := CT_VOYAGER;
                  rCode := True;
                  break;
                end
            end
          else if (CardLen = 14) then     {maybe its a phh}
            begin
              {add code to check sub account ranges}
              if NOT ValidSpecChecksum(1,9,10) then
                begin
                  break;
                end;
              if NOT ValidSpecChecksum(1,13,14) then
                begin
                  break;
                end;
              if NOT ValidDate then
                 break;
              try
                PANNo := StrToCurr(Copy(CardNo,1,14));
              except
                PANNo := 0;
              end;
              if NOT (((PANNo >= 500230010000.0) and (PANNo <= 500269999999.0)) or
                     ((PANNo >= 500270110000.0) and (PANNo <= 500279999999.0)) or
                     ((PANNo >= 500285110000.0) and (PANNo <= 500299999999.0)) or
                     ((PANNo >= 550000040000.0) and (PANNo <= 550299959999.0))) then
                begin
                  CardError := ERR_INVALIDACCOUNT;
                  break;
                end;
              CardNo := Copy(CardNo,1,14);
              CardLen := 15;
              bGetVehicleNo := True;
              bGetOdometer := True;
              CardType := 'PHH';
              CardTypeNo := CT_PHH;
              rCode := True;
              break;
            end;
        end;
      break;
    end;

   ValidCardData := rCode;

end;



{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidChecksum                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardLen, CardNo, ERR_INVALIDACCOUNT               |
|                                                                            |
| LOCALS:       chkdgt, DigitLen, digitstr, rem, seed, startpos, sum, x      |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidChecksum                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardLen, CardNo, ERR_INVALIDACCOUNT               |
|                                                                            |
| LOCALS:       chkdgt, DigitLen, digitstr, rem, seed, startpos, sum, x      |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidChecksum : boolean;
var

digitstr : string;
DigitLen : short;
chkdgt, rem, startpos, x, sum, seed : short;
begin

  StartPos := CardLen - 1 ;
  Seed := 2 ;
  DigitStr := '';
  for x := StartPos downto 1 do

    begin
      DigitStr := DigitStr + IntToStr ( StrToInt(Copy(CardNo,x,1)) * Seed ) ;
      if Seed = 2 then
        Seed := 1
      else
        Seed := 2;
    end;

  DigitLen := Length(DigitStr);
  Sum := 0;
  for x := 1 to DigitLen do
    begin
      Sum := Sum + StrToInt(Copy(DigitStr,x,1));
    end;

  try
    rem := sum mod 10;
  except
    rem := 0;
  end;
  chkdgt := 0;
  if rem > 0 then
    ChkDgt := 10 - rem;

  if ChkDgt = StrToInt(Copy(CardNo,CardLen,1)) then
    ValidChecksum := True
  else
    begin
      CardError := ERR_INVALIDACCOUNT;
      ValidChecksum := False;
    end;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidSpecChecksum                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   CheckPos, EndPos, StartPos                                   |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardNo, ERR_INVALIDACCOUNT                        |
|                                                                            |
| LOCALS:       chkdgt, DigitLen, digitstr, rem, seed, sum, x                |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidSpecChecksum                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   CheckPos, EndPos, StartPos                                   |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardNo, ERR_INVALIDACCOUNT                        |
|                                                                            |
| LOCALS:       chkdgt, DigitLen, digitstr, rem, seed, sum, x                |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidSpecChecksum(StartPos, EndPos, CheckPos  : short ) : boolean;
var
digitstr : string;
DigitLen : short;
chkdgt, rem, x, sum, seed : short;
begin

  Seed := 2 ;
  DigitStr := '';
  for x := EndPos downto StartPos do
    begin
      DigitStr := DigitStr + IntToStr ( StrToInt(Copy(CardNo,x,1)) * Seed ) ;
      if Seed = 2 then
        Seed := 1
      else
        Seed := 2;
    end;

  DigitLen := Length(DigitStr);
  Sum := 0;
  for x := 1 to DigitLen do
    begin
      Sum := Sum + StrToInt(Copy(DigitStr,x,1));
    end;

  try
    rem := sum mod 10;
  except
    rem := 0;
  end;
  chkdgt := 0;
  if rem > 0 then
    ChkDgt := 10 - rem;

  if ChkDgt = StrToInt(Copy(CardNo,CheckPos,1)) then
    ValidSpecChecksum := True
  else
    begin
      CardError := ERR_INVALIDACCOUNT;
      ValidSpecChecksum := False;
    end;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidDate                                       |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, ERR_CARDEXPIRED, ERR_INVALIDDATE, ExpDate         |
|                                                                            |
| LOCALS:       CardExpDate, CardMonth, CardYear, CurDay, CurMonth, CurYear, |
|               RetCode                                                      |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidDate                                       |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ValidCardData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, ERR_CARDEXPIRED, ERR_INVALIDDATE, ExpDate         |
|                                                                            |
| LOCALS:       CardExpDate, CardMonth, CardYear, CurDay, CurMonth, CurYear, |
|               RetCode                                                      |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidDate : boolean;
var
RetCode : boolean;
CardMonth, CardYear : word;
CurMonth, CurDay, CurYear : word;
CardExpDate : TDateTime;

begin
  CardExpDate := now;
  RetCode := False;
  DecodeDate(Date, CurYear, CurMonth, CurDay);

  while True do
    begin
      if length(ExpDate) <> 4 then
        begin
          CardError := ERR_INVALIDDATE;
          break;
        end;

      try
        CardMonth := StrToInt(Copy(ExpDate,1,2));
        CardYear  := StrToInt(Copy(ExpDate,3,2));
      except
        CardMonth := 0;
        CardYear  := 0;
      end;

      if (CardMonth < 1) or (CardMonth > 12) then
        begin
          CardError := ERR_INVALIDDATE;
          break;
        end;

      if CardYear > 90 then
        CardYear := CardYear + 1900
      else
        CardYear := CardYear + 2000;

      try
        if CardMonth = 12 then
          CardExpDate := (EncodeDate(CardYear + 1, 1, 1) - 1)
        else
          CardExpDate := (EncodeDate(CardYear, CardMonth + 1, 1) - 1);
      except
        CardError := ERR_INVALIDDATE;
        break;
      end;
      if Date > CardExpDate then
        begin
          CardError := ERR_CARDEXPIRED;
          break;
        end;

      RetCode := True;
      break;
    end;

  ValidDate := RetCode;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidRestrictionCode                            |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey, ValidCardData                                    |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetDriverID, bGetOdometer, CardError,            |
|               eRestrictionCode, ERR_RESTRICTIONCODE                        |
|                                                                            |
| LOCALS:       RetCode, TmpInt                                              |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidRestrictionCode                            |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey, ValidCardData                                    |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      bFuelOnly, bGetDriverID, bGetOdometer, CardError,            |
|               eRestrictionCode, ERR_RESTRICTIONCODE                        |
|                                                                            |
| LOCALS:       RetCode, TmpInt                                              |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidRestrictionCode : boolean;
var
RetCode : boolean;
TmpInt : short;
begin

  RetCode := False;
  CardError := ERR_RESTRICTIONCODE;

  while True do
    begin
      if length(eRestrictionCode.Caption) <> 2 then
        break;
      try
        TmpInt := StrToInt(Copy(eRestrictionCode.Caption,1,1));
        case TmpInt of
        0: ;
        1: bGetDriverID := True;
        2: bGetOdometer := True;
        3:
          begin
            bGetDriverID := True;
            bGetOdometer := True;
          end;
        else
          begin
            break;
          end;
        end;
        TmpInt := StrToInt(Copy(eRestrictionCode.Caption,2,1));
        case TmpInt of
        0: ;
        1: bFuelOnly := True;
        else
          begin
            break;
          end;
        end;
      except
        break;
      end;

      RetCode := True;
      break;
    end;

  ValidRestrictionCode := RetCode;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidVehicleNo                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, ERR_VEHICLENO, eVehicleNo                        |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidVehicleNo                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, ERR_VEHICLENO, eVehicleNo                        |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidVehicleNo : boolean;
var
RetCode  : boolean;
NoLen    : short;
NoVal : real;
begin
  RetCode := False;
  CardError := ERR_VEHICLENO;
  NoLen := length(eVehicleNo.Caption);
  try
    NoVal := StrToFloat(eVehicleNo.Caption);
  except
    NoVal := 0;
  end;

  while True do
    begin
      if NoLen < 1 then
        break;
      if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP) then
        begin
          if NoLen > 5 then
            break;
        end
      else if CardTypeNo = CT_PHH then
        begin
          if NoLen > 10 then
            break;
        end
      else if CardTypeNo = CT_IAES then
        begin
          if NoLen > 5 then
            break;
          if NoVal < 1 then
            break;
        end
      else if CardTypeNo = CT_VOYAGER then
        begin
        end;
      RetCode := True;
      break;
    end;

  ValidVehicleNo := RetCode;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidDriverID                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, eDriverID, ERR_DRIVERID                          |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidDriverID                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, eDriverID, ERR_DRIVERID                          |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidDriverID : boolean;
var
RetCode : boolean;
NoLen   : short;
NoVal : longint;
begin
  RetCode := False;
  CardError := ERR_DRIVERID;
  NoLen := length(eDriverID.Caption);
  try
    NoVal := StrToInt(eDriverID.Caption);
  except
    NoVal := 0;
  end;
  while True do
    begin
      if NoLen < 1 then
        break;
      if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP) then
        begin
          if not ((NoLen = 4) or (NoLen = 6)) then
            break;
        end
      else if CardTypeNo = CT_PHH then
        begin
        end
      else if CardTypeNo = CT_IAES then
        begin
          if NoLen <> 4 then
            break;
        end
      else if CardTypeNo = CT_VOYAGER then
        begin
          if NoLen > 6 then
            break;
          if NoVal < 1 then
            break;
        end;
      RetCode := True;
      break;
    end;

  ValidDriverID := RetCode;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidOdometer                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, eOdometer, ERR_ODOMETER                          |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.ValidOdometer                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessKey                                                   |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardError, CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX,  |
|               CT_WEXPROP, eOdometer, ERR_ODOMETER                          |
|                                                                            |
| LOCALS:       NoLen, NoVal, RetCode                                        |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.ValidOdometer : boolean;
var
RetCode : boolean;
NoLen   : short;
NoVal : longint;
begin
  RetCode := False;
  CardError := ERR_Odometer;
  NoLen := length(eOdometer.Caption);
  try
    NoVal := StrToInt(eOdometer.Caption);
  except
    NoVal := 0;
  end;
  while True do
    begin
      if NoLen < 1 then
        break;
      if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP) then
        begin
          if NoLen > 6 then
            break;
        end
      else if CardTypeNo = CT_PHH then
        begin
          if NoLen > 6 then
            break;
        end
      else if CardTypeNo = CT_IAES then
        begin
          if NoLen > 7 then
            break;
          if NoVal < 1 then
            break;
        end
      else if CardTypeNo = CT_VOYAGER then
        begin
          if NoLen > 7 then
            break;
        end;
      RetCode := True;
      break;
    end;

  ValidOdometer := RetCode;

end;



{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessCredit                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        BuildTag, CheckUserData, GetSalePumpNo, POSError,            |
|               SendCreditMessage                                            |
|                                                                            |
| GLOBALS:      Authorized, bGetApproval, bRetryDriverID, bWEXNotAllowed,    |
|               CardName, CardNo, CardType, CardTypeNo, CCMsg, ChargeAmount, |
|               CreditAuthToken, CT_AMEX, CT_DEBIT, CT_WEX, CT_WEXPROP,      |
|               DebitCashBackAmount, DebitPINBlock, DebitSerialNumber,       |
|               DriverIDCount, eDriverID, EntryType, eOdometer, eVehicleNo,  |
|               eVisibleDriverID, ExpDate, fmADSCCForm, fmPOS, FuelAmount,   |
|               lStatus, nCurTransNo, NonFuelAmount, RespAllowed,            |
|               RespApprovalCode, RespAuthCode, RespAuthID, RespAuthorizer,  |
|               RespBatchNo, RespDate, RespEntryMethod, RespPumpLimit,       |
|               RespReaderNo, RespReferralNo, RespSeqNo, RespTime,           |
|               sCCApprovalCode, sCCAuthCode, sCCBatchNo, sCCCardName,       |
|               sCCCardNo, sCCCardType, sCCDate, sCCEntryType, sCCExpDate,   |
|               sCCOdometer, sCCSeqNo, sCCTime, sCCVehicleNo, ServiceCode,   |
|               SetupCREDITAUTHTYPE, Status, TaxAmount, Text, Track1Data,    |
|               Track2Data, UserData, UserDataCount, WM_CHECKKEY,            |
|               WM_CREDITMSG                                                 |
|                                                                            |
| LOCALS:       action, r1, s                                                |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ProcessCredit                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Msg                                                          |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        BuildTag, CheckUserData, GetSalePumpNo, POSError,            |
|               SendCreditMessage                                            |
|                                                                            |
| GLOBALS:      Authorized, bGetApproval, bRetryDriverID, bWEXNotAllowed,    |
|               CardName, CardNo, CardType, CardTypeNo, CCMsg, ChargeAmount, |
|               CreditAuthToken, CT_AMEX, CT_DEBIT, CT_WEX, CT_WEXPROP,      |
|               DebitCashBackAmount, DebitPINBlock, DebitSerialNumber,       |
|               DriverIDCount, eDriverID, EntryType, eOdometer, eVehicleNo,  |
|               eVisibleDriverID, ExpDate, fmADSCCForm, fmPOS, FuelAmount,   |
|               lStatus, nCurTransNo, NonFuelAmount, RespAllowed,            |
|               RespApprovalCode, RespAuthCode, RespAuthID, RespAuthorizer,  |
|               RespBatchNo, RespDate, RespEntryMethod, RespPumpLimit,       |
|               RespReaderNo, RespReferralNo, RespSeqNo, RespTime,           |
|               sCCApprovalCode, sCCAuthCode, sCCBatchNo, sCCCardName,       |
|               sCCCardNo, sCCCardType, sCCDate, sCCEntryType, sCCExpDate,   |
|               sCCOdometer, sCCSeqNo, sCCTime, sCCVehicleNo, ServiceCode,   |
|               SetupCREDITAUTHTYPE, Status, TaxAmount, Text, Track1Data,    |
|               Track2Data, UserData, UserDataCount, WM_CHECKKEY,            |
|               WM_CREDITMSG                                                 |
|                                                                            |
| LOCALS:       action, r1, s                                                |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.ProcessCredit(var Msg:TWMStatus);
var
action : short;
s : String;
begin
  case CreditAuthToken of
  1 :
    begin

    {

      Action            0      2  99
      EntryType         2      1   X  S or M
      AuthAmount        3     10  99999.99-
      CardType         13      2
      ServiceCode      15      3
      CardNo           18     40
      AuthExpDate      58      4  XXXX
      Track1Data       62     80   Card No or MSR data
      Track2Data      142     80   Card No or MSR data
      TransNo         222      6
      UserDataCount   228      3
      UserData        231     90
      ReaderNo        321      2
      CardName        323     40

    }

    RespAllowed      := '';
    RespAuthCode     := '';
    RespDate         := '';
    RespTime         := '';
    RespApprovalCode := '';
    RespAuthorizer   := '';
    RespEntryMethod  := '';
    RespBatchNo      := '';
    RespSeqNo        := '';
    RespPumpLimit    := '';
    RespReferralNo   := '';
    RespReaderNo     := '';
    RespAuthID       := '';

    CheckUserData;
    bRetryDriverID := False;

    CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_AUTHCARD)) +
               BuildTag(TAG_ENTRYTYPE, EntryType) +
               BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', ChargeAmount + DebitCashBackAmount))])) +
               BuildTag(TAG_FUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', FuelAmount ))])) +
               BuildTag(TAG_NONFUELAMOUNT, Format('%10s',[( FormatFloat ( '###.00', NonFuelAmount ))])) +
               BuildTag(TAG_TAXAMOUNT, Format('%10s',[( FormatFloat ( '###.00', TaxAmount ))])) +
               BuildTag(TAG_CARDTYPE, CardTypeNo) +
               BuildTag(TAG_CARDNO, CardNo) +
               BuildTag(TAG_EXPDATE, ExpDate) +
               BuildTag(TAG_TRACK1DATA, Track1Data) +
               BuildTag(TAG_TRACK2DATA, Track2Data) +
               BuildTag(TAG_TRANSNO,  Format('%6.6d',[nCurTransNo]) ) +
               BuildTag(TAG_PUMPNO, IntToStr(GetSalePumpNo)) +
               BuildTag(TAG_USERDATACOUNT, UserDataCount) +
               BuildTag(TAG_USERDATA, UserData) +
               BuildTag(TAG_CARDNAME, CardName) +
               BuildTag(TAG_DRIVERID, eDriverID.Caption) +
               BuildTag(TAG_ODOMETER, eOdometer.Caption) +
               BuildTag(TAG_VEHICLENO, eVehicleNo.Caption) +
               //BuildTag(TAG_REFNO, eRefNo.Caption) +
               BuildTag(TAG_SERVICECODE, ServiceCode);
      if CardType = CT_DEBIT then
        begin

          CCMsg := CCMsg + BuildTag(TAG_SERIALNUMBER, DebitSerialNumber) +
                           BuildTag(TAG_PINBLOCK, DebitPINBlock) +
                           BuildTag(TAG_CASHBACKAMOUNT, Format('%10s',[( FormatFloat ( '###.00', DebitCashBackAmount ))])) ;

        end
      //Gift
      else if (CardType = CT_GIFT) then
        begin
      //    CCMsg := CCMsg + BuildTag(TAG_SIN_AMOUNT, CurrToStr(SinAmount)) +
        //                   BuildTag(TAG_CASHOUT_OPTION, IntToStr(GiftCardCashOutOption));
        end;
      //Gift

      {
      if (EntryType = 'M') and (CardTypeNo = CT_VOYAGER) then
        begin
          EntryType := 'S';
          Track2Data := ';7088' + CardNo + '=' + Copy(ExpDate,3,2) + Copy(ExpDate,1,2) + eRestrictionCode.Caption + '00000000000?';
        end;


      CCMsg := '';
      if CreditAuthToken = 1 then
        StrPCopy(TempCCMsg, Format('%2.2d',[CC_AUTHCARD]))
      else
        StrPCopy(TempCCMsg, Format('%2.2d',[CC_AUTHQ]));
      move(TempCCMsg, CCMsg[0], 2);

      StrPCopy(TempCCMsg, EntryType);
      move(TempCCMsg, CCMsg[2], 1)  ;

      StrPCopy(TempCCMsg, Format('%10s',[( FormatFloat ( '###.00', ChargeAmount ))]));
      move(TempCCMsg, CCMsg[3],10);

      StrPCopy(TempCCMsg, CardTypeNo);
      move(TempCCMsg, CCMsg[13], 2)  ;

      StrPCopy(TempCCMsg, ServiceCode);
      move(TempCCMsg, CCMsg[15], 3)  ;

      if CardTypeNo = CT_VOYAGER then
        StrPCopy(TempCCMsg, '7088' + CardNo)
      else
        StrPCopy(TempCCMsg, CardNo);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(40 - r1)))));
      move(TempCCMsg, CCMsg[18], 40)  ;

      StrPCopy(TempCCMsg, ExpDate);
      move(TempCCmsg, CCMsg[58], 4);

      StrPCopy(TempCCMsg, Track1Data);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(80 - r1)))));
      move(TempCCMsg, CCMsg[62], 80)  ;

      StrPCopy(TempCCMsg, Track2Data);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(80 - r1)))));
      move(TempCCMsg, CCMsg[142], 80)  ;

      StrPCopy(TempCCMsg, Format('%6.6d',[nCurTransNo]));
      move(TempCCMsg, CCMsg[222], 6);

      StrPCopy(TempCCMsg, UserDataCount);
      move(TempCCmsg, CCMsg[228], 3);

      try
        r1 := StrToInt(UserDataCount);
      except
        r1 := 0;
      end;
      move(UserData, TempCCMsg, r1);

      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(90 - r1)))));
      move(TempCCMsg, CCMsg[231], 90)  ;

      StrPCopy(TempCCMsg, Format('%2.2d',[ 0 ])); {Empty - Used for Reader No from CAT Server
      move(TempCCMsg, CCMsg[321], 2);

      StrPCopy(TempCCMsg, CardName);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(40 - r1)))));
      move(TempCCMsg, CCMsg[323], 40)  ;}

      lStatus.Visible := True;
      CreditAuthToken := 100;
      if Setup.CreditAuthType = 1 then
        PostMessage(fmADSCCForm.Handle, WM_CREDITMSG, 0, 0)
      else
        fmPOS.SendCreditMessage(CCMsg) ;


    end;

  30 :
    begin

    {

      Action              1     2  99
      EntryType           3     1   X  S or M
      AuthAmount          4    10  99999.99-
      CardType           14     2
      CardNo             16    40
      AuthExpDate        56     4  XXXX
      AuthCode           60     2
      ApprovalCode       62     6
      Authorizer         68     1
      TermDate           69     4
      TermTime           73     6
      EntryMethod        79     1
      CardType           80     2
      TransNo            82     6
      UserDataCount      88     3
      UserData           91    90
      CATAmount         181     6
      CATVolume         187     7
      CATUnitPrice      194     7
      CATGrade          201     1
      CATReaderNo       202     2
      AuthID            204     6
      CardName          210    40
    }

      CheckUserData;

      CCMsg := '';
      CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_DATACOLLECT)) +
               BuildTag(TAG_ENTRYTYPE, EntryType) +
               BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', ChargeAmount ))])) +
               BuildTag(TAG_CARDTYPE, CardTypeNo) +
               BuildTag(TAG_CARDNO, CardNo) +
               BuildTag(TAG_EXPDATE, ExpDate) +
               BuildTag(TAG_TRACK1DATA, Track1Data) +
               BuildTag(TAG_TRACK2DATA, Track2Data) +
               BuildTag(TAG_AUTHCODE, RespAuthCode) +
               BuildTag(TAG_APPROVALCODE, RespApprovalCode) +
               BuildTag(TAG_ENTRYTYPE, EntryType) +
               BuildTag(TAG_TRANSNO, Format('%6.6d',[nCurTransNo])) +
               BuildTag(TAG_PUMPNO, IntToStr(GetSalePumpNo) ) +
               BuildTag(TAG_USERDATACOUNT, UserDataCount)  +
               BuildTag(TAG_USERDATA, UserData) +
               //BuildTag(TAG_AUTHID, sAuthID) +
               BuildTag(TAG_CARDNAME, CardName) +
               BuildTag(TAG_DRIVERID, eDriverID.Caption) +
               BuildTag(TAG_ODOMETER, eOdometer.Caption) +
               BuildTag(TAG_VEHICLENO, eVehicleNo.Caption) +
               //BuildTag(TAG_REFNO, eRefNo.Caption) +
               BuildTag(TAG_SERVICECODE, ServiceCode) ;

      {StrPCopy(TempCCMsg, Format('%2.2d',[CC_DATACOLLECT]));
      move(TempCCMsg, CCMsg[0], 2);

      StrPCopy(TempCCMsg, EntryType);
      move(TempCCMsg, CCMsg[2], 1)  ;

      StrPCopy(TempCCMsg, Format('%10s',[( FormatFloat ( '###.00', ChargeAmount ))]));
      move(TempCCMsg, CCMsg[3],10);

      StrPCopy(TempCCMsg, CardTypeNo);
      move(TempCCMsg, CCMsg[13], 2)  ;

      if CardTypeNo = CT_VOYAGER then
        StrPCopy(TempCCMsg, '7088' + CardNo)
      else
        StrPCopy(TempCCMsg, CardNo);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(40 - r1)))));
      move(TempCCMsg, CCMsg[15], 40)  ;

      StrPCopy(TempCCMsg, ExpDate);
      move(TempCCmsg, CCMsg[55], 4);

      if ChargeAmount < 0 then
        StrPCopy(TempCCMsg, '08')
      else
        StrPCopy(TempCCMsg, RespAuthCode);
      move(TempCCmsg, CCMsg[59], 2);

      if Length(eApproval.Caption) > 0  then
        RespApprovalCode := eApproval.Caption
      else
        begin
          RespApprovalCode := '      ';
        end;
      StrPCopy(TempCCMsg, RespApprovalCode);
      move(TempCCmsg, CCMsg[61], 6);

      if Length(RespAuthorizer) = 1 then
        StrPCopy(TempCCMsg, RespAuthorizer)
      else
        StrPCopy(TempCCMsg, 'T');
      move(TempCCmsg, CCMsg[67], 1);

      if Length(RespDate) <> 4 then
        begin
          RespDate := FormatDateTime('mmdd',Date);
        end;
      StrPCopy(TempCCMsg, RespDate);
      move(TempCCmsg, CCMsg[68], 4);

      if Length(RespTime) <> 6 then
        RespTime := FormatDateTime('hhmmss',Time);

      StrPCopy(TempCCMsg, RespTime);
      move(TempCCmsg, CCMsg[72], 6);

      if Length(RespEntryMethod) <> 1 then
        begin
          if EntryType = 'M' then
            RespEntryMethod := '1'
          else
            RespEntryMethod := '0';
        end;
      StrPCopy(TempCCMsg, RespEntryMethod);
      move(TempCCmsg, CCMsg[78], 1);

      StrPCopy(TempCCMsg, CardTypeNo);
      move(TempCCmsg, CCMsg[79], 2);

      StrPCopy(TempCCMsg, Format('%6.6d',[nCurTransNo]));
      move(TempCCMsg, CCMsg[81], 6);


      StrPCopy(TempCCMsg, UserDataCount);
      move(TempCCmsg, CCMsg[87], 3);

      try
        r1 := StrToInt(UserDataCount);
      except
        r1 := 0;
      end;
      move(UserData, TempCCMsg, r1);

      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(90 - r1)))));
      move(TempCCMsg, CCMsg[90], 90)  ;

      StrPCopy(TempCCMsg, Format('%6.6d',[ 0 ])); {Empty - Used for Amount from CAT Server
      move(TempCCMsg, CCMsg[180], 6);
      StrPCopy(TempCCMsg, Format('%7.7d',[ 0 ])); {Empty - Used for Volume from CAT Server
      move(TempCCMsg, CCMsg[186], 7);
      StrPCopy(TempCCMsg, Format('%7.7d',[ 0 ])); {Empty - Used for Unit Price from CAT Server
      move(TempCCMsg, CCMsg[193], 7);
      StrPCopy(TempCCMsg, Format('%1.1d',[ 0 ])); {Empty - Used for Grade from CAT Server
      move(TempCCMsg, CCMsg[200], 1);
      StrPCopy(TempCCMsg, Format('%2.2d',[ 0 ])); {Empty - Used for Reader No from CAT Server
      move(TempCCMsg, CCMsg[201], 2);

      try
        StrPCopy(TempCCMsg, Format('%6.6d',[ StrToInt(RespAuthID) ])); {Auth ID
      except
        TempCCMsg := '000000';
      end;
      move(TempCCMsg, CCMsg[203], 6);

      StrPCopy(TempCCMsg, CardName);
      r1 := StrLen(TempCCMsg);
      StrPCopy(TempCCMsg,(TempCCMsg + (StringOfChar(' ',(40 - r1)))));
      move(TempCCMsg, CCMsg[209], 40)  ;}

      lStatus.Visible := True;

      CreditAuthToken := 100;
      if Setup.CreditAuthType = 1 then
        PostMessage(fmADSCCForm.Handle, WM_CREDITMSG, 0, 0)
      else
        fmPOS.SendCreditMessage(CCMsg);

    end;

  100 :
    begin
      if Setup.CreditAuthType = 1 then
        begin
          CCMsg := '0410001010930001234560001001050           00123456';
        end
      else
        begin
          CCMsg := Msg.Status.Text;
          Dispose(Msg.Status);
        end;
      try
        Action :=  StrToInt(GetTagData(TAG_MSGTYPE, CCMsg));
        //Action :=  StrToInt(Copy(CCMsg,1,2));
      except
        Action := 0;
      end;
      if Action = CC_AUTHMSG then
        begin
          lStatus.Caption := GetTagData(TAG_STATUSSTRING, CCMsg);
          //lStatus.Caption := Copy(CCMsg,3,50);
          lStatus.refresh;

        end
      else if Action = CC_AUTHRESP then
        begin

// handle auth codes
// if authed need auth#, etc


{  Response Message Format

      Action            0      2  99
      Allowed           2      1
      AuthCode          3      2
      Date              5      4
      Time              9      6
      ApprovalCode     15      6
      Authorizer       21      1
      EntryMethod      22      1
      BatchNo          23      2
      SeqNo            25      3
      PumpLimit        28      3
      ReferralNo       31      11
      ReaderNo         42      2
      AuthID           44      6

}


         lStatus.Caption := 'Auth Code ' + Copy(CCMsg,3,10);

         RespAllowed       := Copy(CCMsg,  3, 1);
         RespAuthCode      := Copy(CCMsg,  4, 2);

         RespDate          := Copy(CCMsg,  6, 4);
         RespTime          := Copy(CCMsg, 10, 6);
         RespApprovalCode  := Copy(CCMsg, 16, 6);
         RespAuthorizer    := Copy(CCMsg, 22, 1);
         RespEntryMethod   := Copy(CCMsg, 23, 1);
         RespBatchNo       := Copy(CCMsg, 24, 2);
         RespSeqNo         := Copy(CCMsg, 26, 3);
         RespPumpLimit     := Copy(CCMsg, 29, 3);
         RespReferralNo    := Copy(CCMsg, 32, 11);
         RespReaderNo      := Copy(CCMsg, 43, 2);
         RespAuthID        := Copy(CCMsg, 45, 6);

         if (RespAuthCode = '00') or (RespAuthCode = '  ')then
           begin
          //   fmPOS.POSError('Approved Auth ' + RespAuthCode + ' Date ' + RespDate
          //                                            + ' Time ' + RespTime
          //                                            + ' Code ' + RespApprovalCode );
           end
         else if RespAuthCode = '01' then
           begin
             if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP)  then
               fmPOS.POSError('Card DECLINED - Bad Vehicle #')
             else
               fmPOS.POSError('Card DECLINED - Pick Up Card');
           end
         else if RespAuthCode = '02' then
           begin
             if DriverIDCount = 3 then
               begin
                 fmPOS.POSError('Declined - Invalid PIN');
                 eDriverID.Caption := '';
                 eVisibleDriverID.Caption := '';
                 bRetryDriverID := False;
                 bWEXNotAllowed := True;
               end
             else
               begin
                 Inc(DriverIDCount);
                 fmPOS.POSError('Invalid PIN - Retry');
                 bRetryDriverID := True;
                 eDriverID.Caption := '';
                 eVisibleDriverID.Caption := '';
                 PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt('Z'), 0);
                 exit;
               end;
           end
         else if RespAuthCode = '03' then
           begin
             fmPOS.POSError('Card DECLINED - Call Credit Center');
           end
         else if RespAuthCode = '04' then
           begin
             fmPOS.POSError('Card APPROVED - Call Credit Center');
           end
         else if RespAuthCode = '05' then
           begin
             fmPOS.POSError('Card APPROVED - Switched Card');
           end
         else if RespAuthCode = '06' then
           begin
             fmPOS.POSError('Card DECLINED');
           end
         else if RespAuthCode = '07' then
           begin
             fmPOS.POSError('Invalid PIN - No Retry');
           end
         else if RespAuthCode = '08' then
           begin
           //  fmPOS.POSError('Credit Adjustment');
           end
         else if RespAuthCode = '10' then
           begin
             fmPOS.POSError('Card DECLINED');
           end
         else if RespAuthCode = '16' then
           begin
             fmPOS.POSError('Card DECLINED');
           end
         else if RespAuthCode = '17' then
           begin
             fmPOS.POSError('Terminal Disabled');
           end
         else if RespAuthCode = '20' then
           begin
             fmPOS.POSError('Card DECLINED - Pick Up Card');
           end
         else if RespAuthCode = '30' then
           begin
             if NOT bGetApproval then
               begin
                 s := 'Call Center - ' + RespReferralNo;
                 if CardTypeNo = CT_AMEX then
                   s := s +  '- Queue# ' + RespApprovalCode;
                 fmPOS.POSError(s);
                 bGetApproval := True;
                 lStatus.Caption := s;
                 PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt('Z'), 0);
                 exit;
               end;

           end
         else if (RespAuthCode = '40') or (RespAuthCode = '80') or (RespAuthCode = '90') then
           begin
             if (RespAllowed = '0') or (RespAllowed = '4') then
               fmPOS.POSError('Declined - Over Fallback Limit')
             else
               begin
                 if (RespAuthCode = '40')  then
                   RespAuthCode := '48';
                 if (RespAuthCode = '80')  then
                   RespAuthCode := '88';
                 if (RespAuthCode = '90')  then
                   RespAuthCode := '98';

               end;


            //   fmPOS.POSError('Approved Auth ' + RespAuthCode + ' Date ' + RespDate

            //                                            + ' Time ' + RespTime
            //                                            + ' Code ' + RespApprovalCode );
           end
         else if (RespAuthCode = '37') or (RespAuthCode = '57') then
           begin
             if (RespAllowed = '0') or (RespAllowed = '4') then
               fmPOS.POSError('Declined - Over Fallback Limit');


            //   fmPOS.POSError('Approved Auth ' + RespAuthCode + ' Date ' + RespDate

            //                                            + ' Time ' + RespTime
            //                                            + ' Code ' + RespApprovalCode );
           end
         else if RespAuthCode = '50' then
           begin
             fmPOS.POSError('Invalid Account or Card Type');
           end
         else if RespAuthCode = '55' then
           begin
             fmPOS.POSError('Invalid PIN Encryption Key');
           end
         else if RespAuthCode = '60' then
           begin
             fmPOS.POSError('Card Expired');
           end
         else if RespAuthCode = '70' then
           begin
             fmPOS.POSError('Card DECLINED - Invalid Data');
           end
         else if RespAuthCode = '79' then
           begin
             fmPOS.POSError('Card DECLINED - Invalid Data');
           end
         else if RespAuthCode = '81' then
           begin
             fmPOS.POSError('Card DECLINED - Debit Network Error');
           end
         else if RespAuthCode = '83' then
           begin
             fmPOS.POSError('Card DECLINED - Inquiry Balance Not Available');
           end
         else if RespAuthCode = '84' then
           begin
             fmPOS.POSError('Card DECLINED - Unexpected Response From Interchange');
           end
         else if RespAuthCode = '85' then
           begin
             fmPOS.POSError('Card DECLINED - Duplicate Authorization Request');
           end
         else if RespAuthCode = '86' then
           begin
             fmPOS.POSError('Card DECLINED - Velocity Entry Not Found');
           end
         else if RespAuthCode = '87' then
           begin
             fmPOS.POSError('Card DECLINED - Account Suspended');
           end
         else if RespAuthCode = '89' then
           begin
             fmPOS.POSError('Card DECLINED - Exceed Usage Unit');
           end
         else if RespAuthCode = '91' then
           begin
             fmPOS.POSError('Card DECLINED - Exceed Floor Limit');
           end
         else
           begin
             if NOT ((RespAllowed = '1') or (RespAllowed = '2') or (RespAllowed = '3')) then
               fmPOS.POSError('Card DECLINED - Invalid Network Response');
           end;


          if (RespAllowed = '1') or (RespAllowed = '2') or (RespAllowed = '3')then
            begin
              sCCAuthCode := RespAuthCode;
              sCCApprovalCode := RespApprovalCode;
              sCCDate := RespDate;
              sCCTime      := RespTime;
              sCCCardType  := CardType;
              sCCCardNo    := CardNo;
              sCCExpDate   := ExpDate;
              sCCCardName  := CardName;
              sCCBatchNo   := RespBatchNo;
              sCCSeqNo     := RespSeqNo;
              sCCEntryType := EntryType;
              sCCVehicleNo := eVehicleNo.Caption;
              sCCOdometer  := eOdometer.Caption;
              Authorized := True;
            end;
          close;
        end;

    end;

  end;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckUserData                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessCredit                                                |
|                                                                            |
| CALLS:        BuildIAESUserData, BuildPHHUserData, BuildVoyagerCredit,     |
|               BuildVoyagerUserData, BuildWEXCredit, BuildWEXUserData,      |
|               CalcProdTypes                                                |
|                                                                            |
| GLOBALS:      CardTypeNo, ChargeAmount, CT_IAES, CT_PHH, CT_VOYAGER,       |
|               CT_WEX, CT_WEXPROP, DriverID1, DriverID2, DriverID3,         |
|               DriverIDCount, eDriverID, UserData, UserDataCount            |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CheckUserData                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessCredit                                                |
|                                                                            |
| CALLS:        BuildIAESUserData, BuildPHHUserData, BuildVoyagerCredit,     |
|               BuildVoyagerUserData, BuildWEXCredit, BuildWEXUserData,      |
|               CalcProdTypes                                                |
|                                                                            |
| GLOBALS:      CardTypeNo, ChargeAmount, CT_IAES, CT_PHH, CT_VOYAGER,       |
|               CT_WEX, CT_WEXPROP, DriverID1, DriverID2, DriverID3,         |
|               DriverIDCount, eDriverID, UserData, UserDataCount            |
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
procedure TfmADSCCForm.CheckUserData;
begin

  case DriverIDCount of
  1 : DriverID1  :=  eDriverID.Caption;
  2 : DriverID2  :=  eDriverID.Caption;
  3 : DriverID3  :=  eDriverID.Caption;
  end;

  UserDataCount := '000';
  UserData := '';

  if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP) then
    begin
      CalcProdTypes;
      if ChargeAmount > 0 then
        BuildWEXUserData
      else
        BuildWEXCredit;

    end
  else if CardTypeNo = CT_PHH then
    begin
      CalcProdTypes;
      BuildPHHUserData;
    end
  else if CardTypeNo = CT_IAES then
    begin
      CalcProdTypes;
      BuildIAESUserData;
    end
  else if CardTypeNo = CT_VOYAGER then
    begin
      CalcProdTypes;
      if ChargeAmount > 0 then
        BuildVoyagerUserData
      else
        BuildVoyagerCredit;
    end;

end;



{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CalcProdTypes                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX, CT_WEXPROP, |
|               CurSaleData, CurSaleList, ExtPrice, FuelPrice, FuelQty,      |
|               FuelType, IAESCode, LineType, nCurTlTax, OilAmount, OilPrice,|
|               OilQty, OilType, PHHCode, Price, ProdAmount, ProdQty,        |
|               ProdType, Qty, TlProdCount, TlTax, VoyagerCode, WexCode      |
|                                                                            |
| LOCALS:       CurProd, Ndx, SalesNdx                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.CalcProdTypes                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardTypeNo, CT_IAES, CT_PHH, CT_VOYAGER, CT_WEX, CT_WEXPROP, |
|               CurSaleData, CurSaleList, ExtPrice, FuelPrice, FuelQty,      |
|               FuelType, IAESCode, LineType, nCurTlTax, OilAmount, OilPrice,|
|               OilQty, OilType, PHHCode, Price, ProdAmount, ProdQty,        |
|               ProdType, Qty, TlProdCount, TlTax, VoyagerCode, WexCode      |
|                                                                            |
| LOCALS:       CurProd, Ndx, SalesNdx                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.CalcProdTypes;
var
  SalesNdx, Ndx : short;
  CurProd : integer;
  CurSaleData : pSalesData;
begin
  CurProd := 0;

  for ndx := 1 to 2 do
    begin
      FuelType[ndx]    := 0;
      FuelQty[ndx]     := 0;
      FuelPrice[ndx]   := 0;
      //FuelAmount[ndx]  := 0;
    end;

  OilType     := 0;
  OilQty      := 0;
  OilPrice    := 0;
  OilAmount   := 0;

  for ndx := 1 to 4 do
    begin
      ProdType[ndx]    := 0;
      ProdQty[ndx]     := 0;
      ProdAmount[ndx]  := 0;
    end;


  for SalesNdx := 0 to (fmPos.CurSaleList.Count - 1) do
    begin
      CurSaleData := fmPos.CurSaleList.Items[SalesNdx];
      if (CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP) then
        begin
          CurProd := CurSaleData^.WEXCode
        end
      else if CardTypeNo = CT_PHH then
        begin
          CurProd := CurSaleData^.PHHCode
        end
      else if CardTypeNo = CT_IAES then
        begin
          CurProd := CurSaleData^.IAESCode
        end
      else if CardTypeNo = CT_VOYAGER then
        begin
          CurProd := CurSaleData^.VoyagerCode
        end;

      if CurProd > 0 then
        begin
          if ((CurSaleData^.LineType = 'DPT') or (CurSaleData^.LineType = 'PLU')) then
            begin


             if (CardTypeNo = CT_PHH) then
               begin
                if CurProd = 30 then
                  begin
                    if (OilType = 0)  or (OilType = CurProd) then
                      begin
                        OilType     := CurProd;
                        OilQty      := OilQty + Abs(CurSaleData^.Qty);
                        OilPrice    := Abs(CurSaleData^.Price);
                        OilAmount   := OilAmount + Abs(CurSaleData^.ExtPrice);
                        continue;
                      end;
                  end;
                end
             else if (CardTypeNo = CT_IAES) then
               begin
                if CurProd = 14 then
                  begin
                    if (OilType = 0)  or (OilType = CurProd) then
                      begin
                        OilType     := CurProd;
                        OilQty      := OilQty + Abs(CurSaleData^.Qty);
                        OilPrice    := Abs(CurSaleData^.Price);
                        OilAmount   := OilAmount + Abs(CurSaleData^.ExtPrice);
                        continue;
                      end;
                  end;
                end;


              for ndx := 1 to 4 do
                begin

                  if (ProdType[ndx] = CurProd) or (ProdType[ndx] = 0) then
                    begin
                      ProdType[ndx]   := CurProd;
                      ProdQty[ndx]    := ProdQty[ndx] + Abs(CurSaleData^.Qty);
                      ProdAmount[ndx] := ProdAmount[ndx] + Abs(CurSaleData^.ExtPrice);
                      break;
                    end;
                end;
            end
          else if (CurSaleData^.LineType = 'FUL') or (CurSaleData^.LineType = 'PPY') or (CurSaleData^.LineType = 'PRF') then
            begin
              for ndx := 1 to 2 do
                begin
                  if (FuelType[ndx] = CurProd) or (FuelType[ndx] = 0) then
                    begin
                      FuelType[ndx]   := CurProd;
                      FuelQty[ndx]    := FuelQty[ndx] + Abs(CurSaleData^.Qty);
                      FuelPrice[ndx]  := Abs(CurSaleData^.Price);
                      //FuelAmount[ndx] := FuelAmount[ndx] + Abs(CurSaleData^.ExtPrice);
                      break;
                    end;
                end;
            end;

        end;

    end;


  if ((CardTypeNo = CT_WEX) or (CardTypeNo = CT_WEXPROP)) and (nCurTlTax <> 0)then
    begin
      if ProdType[3] > 0 then
        begin
          ProdAmount[3] := ProdAmount[3] + Abs(nCurTlTax);
        end
      else if ProdType[2] > 0 then
        begin
          ProdType[3] := 56;
          ProdAmount[3] := Abs(nCurTlTax);
        end
      else if ProdType[1] > 0 then
        begin
          ProdType[2] := 56;
          ProdAmount[2] := Abs(nCurTlTax);
        end
      else
        begin
          ProdType[1] := 56;
          ProdAmount[1] := Abs(nCurTlTax);
        end;
    end;

  TlProdCount := 0;
  if FuelType[1] > 0 then
   Inc(TlProdCount);
  if FuelType[2] > 0 then
   Inc(TlProdCount);
  if OilType > 0     then
   Inc(TlProdCount);
  if ProdType[1] > 0 then
   Inc(TlProdCount);
  if ProdType[2] > 0 then
   Inc(TlProdCount);
  if ProdType[3] > 0 then
   Inc(TlProdCount);
  if ProdType[4] > 0 then
   Inc(TlProdCount);

  TlTax := Abs(nCurTlTax);

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildWEXUserData                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eDriverID, eOdometer, eVehicleNo, FuelPrice,       |
|               FuelType, OdometerNumber, PricePerGal, ProdAmount, ProdCode1,|
|               ProdCode1Amount, ProdCode2, ProdCode2Amount, ProdCode3,      |
|               ProdCode3Amount, ProdType, TlProdCount, UserData,            |
|               UserDataCount, VehicleNumber, WEXFuelAndNonFuelProd,         |
|               WEXFuelAndTwoNonFuelProd, WEXSingleFuelProd,                 |
|               WEXSingleNonFuelProd, WEXThreeNonFuelProd, WEXTwoNonFuelProd |
|                                                                            |
| LOCALS:       NoLen, pStr, sDriver, sOdometer, sVehicle                    |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildWEXUserData                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eDriverID, eOdometer, eVehicleNo, FuelPrice,       |
|               FuelType, OdometerNumber, PricePerGal, ProdAmount, ProdCode1,|
|               ProdCode1Amount, ProdCode2, ProdCode2Amount, ProdCode3,      |
|               ProdCode3Amount, ProdType, TlProdCount, UserData,            |
|               UserDataCount, VehicleNumber, WEXFuelAndNonFuelProd,         |
|               WEXFuelAndTwoNonFuelProd, WEXSingleFuelProd,                 |
|               WEXSingleNonFuelProd, WEXThreeNonFuelProd, WEXTwoNonFuelProd |
|                                                                            |
| LOCALS:       NoLen, pStr, sDriver, sOdometer, sVehicle                    |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildWEXUserData;
var
pStr : array[0..50] of char;
sDriver : array[0..50] of char;
sVehicle : array[0..50] of char;
sOdometer : array[0..50] of char;
NoLen : short;
begin

  {

pWEXSingleFuelProd = ^TWEXSingleFuelProd;
TWEXSingleFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
end;

pWEXSingleNonFuelProd = ^TWEXSingleNonFuelProd;
TWEXSingleNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
end;


pWEXFuelAndNonFuelProd = ^TWEXFuelAndNonFuelProd;
TWEXFuelAndNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
end;

pWEXTwoNonFuelProd = ^TWEXTwoNonFuelProd;
TWEXTwoNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
end;


pWEXFuelAndTwoNonFuelProd = ^TWEXFuelAndTwoNonFuelProd;
TWEXFuelAndTwoNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  PricePerGal       : array[0..3] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
  ProdCode3         : array[0..1] of char;
  ProdCode3Amount   : array[0..5] of char;
end;

pWEXThreeNonFuelProd = ^TWEXThreeNonFuelProd;
TWEXThreeNonFuelProd = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  Odometerumber     : array[0..5] of char;
  ProdCode1         : array[0..1] of char;
  ProdCode1Amount   : array[0..5] of char;
  ProdCode2         : array[0..1] of char;
  ProdCode2Amount   : array[0..5] of char;
  ProdCode3         : array[0..1] of char;
  ProdCode3Amount   : array[0..5] of char;
end;



   }

  UserDataCount := '000';
  UserData := '';
  try
    StrPCopy(sVehicle, format('%5.5d', [StrToInt(eVehicleNo.Caption)]))       ;
  except
    sVehicle := '0000000000000';
  end;


  NoLen := length(eDriverID.Caption);
  if NoLen = 0 then
    begin
      sDriver := '0000         ';
    end
  else
    begin
      try
        StrPCopy(sDriver, format('%-6.6s', [eDriverID.Caption]))       ;
      except
        sDriver := '0000         ';
      end;
    end;

  try
    StrPCopy(sOdometer, format('%6.6d', [StrToInt(eOdometer.Caption)]))       ;
  except
    sOdometer := '0000000000000';
  end;

  if TlProdCount = 1 then
    begin
      if FuelType[1] = 0 then  {one non fuel}
        begin
          UserDataCount := '025';
          move (sVehicle , WEXSingleNonFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXSingleNonFuelProd^.DriverID      , 6);
          move (sOdometer, WEXSingleNonFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXSingleNonFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXSingleNonFuelProd^.ProdCode1Amount, 6);
          move(WEXSingleNonFuelProd^, UserData, sizeof(WEXSingleNonFuelProd^)) ;
        end
      else   {one fuel}
        begin
          UserDataCount := '023';
          move (sVehicle , WEXSingleFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXSingleFuelProd^.DriverID      , 6);
          move (sOdometer, WEXSingleFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXSingleFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%4.4d', [ Round(FuelPrice[1] * 1000) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXSingleFuelProd^.PricePerGal, 4);
          move(WEXSingleFuelProd^, UserData, sizeof(WEXSingleFuelProd^)) ;
        end;
    end
  else if TlProdCount = 2 then
    begin
      if FuelType[1] = 0 then  {Two non fuel}
        begin
          UserDataCount := '033';
          move (sVehicle , WEXTwoNonFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXTwoNonFuelProd^.DriverID      , 6);
          move (sOdometer, WEXTwoNonFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXTwoNonFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXTwoNonFuelProd^.ProdCode1Amount, 6);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXTwoNonFuelProd^.ProdCode2, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[2] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXTwoNonFuelProd^.ProdCode2Amount, 6);
          move(WEXTwoNonFuelProd^, UserData, sizeof(WEXTwoNonFuelProd^)) ;
        end
      else   {one fuel and one non fuel}
        begin
          UserDataCount := '031';
          move (sVehicle , WEXFuelAndNonFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXFuelAndNonFuelProd^.DriverID      , 6);
          move (sOdometer, WEXFuelAndNonFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndNonFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%4.4d', [ Round(FuelPrice[1] * 1000) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndNonFuelProd^.PricePerGal, 4);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndNonFuelProd^.ProdCode2, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndNonFuelProd^.ProdCode2Amount, 6);
          move(WEXFuelAndNonFuelProd^, UserData, sizeof(WEXFuelAndNonFuelProd^)) ;
        end;
    end
  else
    begin
      if FuelType[1] = 0 then  {Three non fuel}
        begin
          UserDataCount := '041';
          move (sVehicle , WEXThreeNonFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXThreeNonFuelProd^.DriverID      , 6);
          move (sOdometer, WEXThreeNonFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode1Amount, 6);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode2, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[2] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode2Amount, 6);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[3]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode3, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[3] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXThreeNonFuelProd^.ProdCode3Amount, 6);
          move(WEXThreeNonFuelProd^, UserData, sizeof(WEXThreeNonFuelProd^)) ;
        end
      else   {one fuel and one non fuel}
        begin
          UserDataCount := '039';
          move (sVehicle , WEXFuelAndTwoNonFuelProd^.VehicleNumber , 5);
          move (sDriver  , WEXFuelAndTwoNonFuelProd^.DriverID      , 6);
          move (sOdometer, WEXFuelAndTwoNonFuelProd^.OdometerNumber, 6);
          try
            StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.ProdCode1, 2);
          try
            StrPCopy(pStr, format('%4.4d', [ Round(FuelPrice[1] * 1000) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.PricePerGal, 4);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.ProdCode2, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.ProdCode2Amount, 6);

          try
            StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.ProdCode3, 2);
          try
            StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[2] * 100) ]))       ;
          except
            pStr := '0000000000000';
          end;
          move (pStr, WEXFuelAndTwoNonFuelProd^.ProdCode3Amount, 6);
          move(WEXFuelAndTwoNonFuelProd^, UserData, sizeof(WEXFuelAndTwoNonFuelProd^)) ;
        end;
    end;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildWEXCredit                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eBatchNo, eDate, eDriverID, eSeqNo, eVehicleNo,    |
|               OrigBatchNo, OrigBatchSeqNo, OrigDate, UserData,             |
|               UserDataCount, VehicleNumber, WEXCredit                      |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildWEXCredit                                  |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eBatchNo, eDate, eDriverID, eSeqNo, eVehicleNo,    |
|               OrigBatchNo, OrigBatchSeqNo, OrigDate, UserData,             |
|               UserDataCount, VehicleNumber, WEXCredit                      |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildWEXCredit;
var
pStr : array[0..50] of char;
begin
{
pWEXCredit = ^TWEXCredit;
TWEXCredit = record
  VehicleNumber     : array[0..4] of char;
  DriverID          : array[0..5] of char;
  OrigBatchNo       : array[0..1] of char;
  OrigBatchSeqNo    : array[0..2] of char;
  OrigDate          : array[0..3] of char;
end;
}



  UserDataCount := '020';
  UserData := '';

  try
    StrPCopy(pStr, format('%5.5d', [StrToInt(eVehicleNo.Caption)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr , WEXCredit^.VehicleNumber , 5);

  try
    StrPCopy(pStr, format('%-6.6s', [eDriverID.Caption]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr , WEXCredit^.DriverID , 6);

  try
    StrPCopy(pStr, format('%2.2d', [StrToInt(eBatchNo.Caption)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr , WEXCredit^.OrigBatchNo , 2);

  try
    StrPCopy(pStr, format('%3.3d', [StrToInt(eSeqNo.Caption)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr , WEXCredit^.OrigBatchSeqNo , 3);

  try
    StrPCopy(pStr, format('%4.4d', [StrToInt(eDate.Caption)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr , WEXCredit^.OrigDate , 4);

  move(WEXCredit^, UserData, sizeof(WEXCredit^)) ;


end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildPHHUserData                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      eOdometer, eVehicleNo, Filler, FuelAmount, FuelDollars,      |
|               FuelMeasure, FuelQty, FuelQuantity, FuelServiceType,         |
|               FuelType, Odometer, OilAmount, OilDollars, OilQty,           |
|               OilQuantity, OtherCode1, OtherCode2, OtherCode3,             |
|               OtherDollars1, OtherDollars2, OtherDollars3, PHHAuth,        |
|               ProdAmount, ProdType, Tax, TlTax, UserData, UserDataCount,   |
|               VehicleNo                                                    |
|                                                                            |
| LOCALS:       pStr, r1                                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildPHHUserData                                |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      eOdometer, eVehicleNo, Filler, FuelAmount, FuelDollars,      |
|               FuelMeasure, FuelQty, FuelQuantity, FuelServiceType,         |
|               FuelType, Odometer, OilAmount, OilDollars, OilQty,           |
|               OilQuantity, OtherCode1, OtherCode2, OtherCode3,             |
|               OtherDollars1, OtherDollars2, OtherDollars3, PHHAuth,        |
|               ProdAmount, ProdType, Tax, TlTax, UserData, UserDataCount,   |
|               VehicleNo                                                    |
|                                                                            |
| LOCALS:       pStr, r1                                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildPHHUserData;
var
r1 : short;
pStr : array[0..50] of char;
begin

   {
TPHHAuth = record
  Odometer        : array[0..5] of char;
  VehicleNo       : array[0..9] of char;
  FuelMeasure     : char;
  FuelType        : array[0..1] of char;
  FuelServiceType : array[0..1] of char;
  FuelQuantity    : array[0..4] of char;
  FuelDollars     : array[0..6] of char;
  OilQuantity     : array[0..1] of char;
  OilDollars      : array[0..4] of char;
  OtherCode1      : array[0..1] of char;
  OtherDollars1   : array[0..5] of char;
  OtherCode2      : array[0..1] of char;
  OtherDollars2   : array[0..5] of char;
  OtherCode3      : array[0..1] of char;
  OtherDollars3   : array[0..5] of char;
  Tax             : array[0..4] of char;
  Filler          : array[0..10] of char;
end;

}


  UserDataCount := '080';
  UserData := '';

  try
    StrPCopy(pStr, format('%6.6d', [StrToInt(eOdometer.Caption)]))       ;
  except
    pStr := '000000';
  end;
  move (pStr, PHHAuth^.Odometer, 6);

  StrPCopy(PHHAuth^.VehicleNo, eVehicleNo.Caption);
  r1 := Length( eVehicleNo.Caption );
  StrPCopy(PHHAuth^.VehicleNo,(PHHAuth^.VehicleNo + (StringOfChar(' ',(10- r1)))));

  PHHAuth^.FuelMeasure  := 'G';   {Gallons}

  try
    StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.FuelType, 2);

  PHHAuth^.FuelServiceType  := '01'    {Self Service};

   try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelQty[1] * 10) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.FuelQuantity, 5);

  try
    //StrPCopy(pStr, format('%7.7d', [ Round(FuelAmount[1] * 100) ]))       ;
    StrPCopy(pStr, format('%7.7d', [ Round(FuelAmount * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.FuelDollars, 7);


  try
    StrPCopy(pStr, format('%2.2d', [Round(OilQty)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OilQuantity, 2);

  try
    StrPCopy(pStr, format('%5.5d', [Round(OilAmount * 100  )]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OilDollars, 5);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherCode1, 2);
  if PHHAuth^.OtherCode1 = '00' then
    PHHAuth^.OtherCode1 := '  ';

  try
    StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[1] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherDollars1, 6);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherCode2, 2);
  if PHHAuth^.OtherCode2 = '00' then
    PHHAuth^.OtherCode2 := '  ';

  try
    StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherDollars2, 6);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[3]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherCode3, 2);
  if PHHAuth^.OtherCode3 = '00' then
    PHHAuth^.OtherCode3 := '  ';

  try
    StrPCopy(pStr, format('%6.6d', [ Round(ProdAmount[3] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.OtherDollars3, 6);


  try
    StrPCopy(pStr, format('%5.5d', [ Round(TlTax * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, PHHAuth^.Tax, 5);

  PHHAuth^.Filler          := '           ' ;
  move(PHHAuth^, UserData, sizeof(PHHAuth^)) ;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildIAESUserData                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardNo, eDriverID, eOdometer, eVehicleNo, Filler1,           |
|               FuelAmount, FuelCode, FuelPrice, FuelQty, FuelQuantity,      |
|               FuelType, FuelUnits, IAESAuth, Odometer, OilAmount, OilCode, |
|               OilPrice, OilQty, OilQuantity, OilType, OilUnits, PINNumber, |
|               ProdAmount, ProdAmount1, ProdAmount2, ProdCode1, ProdCode2,  |
|               ProdType, Track2Data, UserData, UserDataCount, VehicleNo,    |
|               VFCVVNo, VFDriverNo                                          |
|                                                                            |
| LOCALS:       CharPosition, pStr, tNum                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildIAESUserData                               |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CardNo, eDriverID, eOdometer, eVehicleNo, Filler1,           |
|               FuelAmount, FuelCode, FuelPrice, FuelQty, FuelQuantity,      |
|               FuelType, FuelUnits, IAESAuth, Odometer, OilAmount, OilCode, |
|               OilPrice, OilQty, OilQuantity, OilType, OilUnits, PINNumber, |
|               ProdAmount, ProdAmount1, ProdAmount2, ProdCode1, ProdCode2,  |
|               ProdType, Track2Data, UserData, UserDataCount, VehicleNo,    |
|               VFCVVNo, VFDriverNo                                          |
|                                                                            |
| LOCALS:       CharPosition, pStr, tNum                                     |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildIAESUserData;
var
pStr : array[0..50] of char;
CharPosition : short;
tNum : integer;
begin
 {
TIAESAuth = record
  PINNumber       : array[0..3] of char;
  Odometer        : array[0..6] of char;
  VehicleNo       : array[0..4] of char;
  FuelCode        : array[0..1] of char;
  FuelUnits       : char;
  FuelQuantity    : array[0..5] of char;
  FuelPrice       : array[0..4] of char;
  FuelAmount      : array[0..5] of char;
  OilCode         : array[0..1] of char;
  OilUnits        : char;
  OilQuantity     : array[0..4] of char;
  OilPrice        : array[0..4] of char;
  OilAmount       : array[0..4] of char;
  ProdCode1       : array[0..1] of char;
  ProdAmount1     : array[0..5] of char;
  ProdCode2       : array[0..1] of char;
  ProdAmount2     : array[0..5] of char;
  Filler1         : array[0..3] of char;
  VFDriverNo      : array[0..4] of char;
  VFCVVNo         : array[0..2] of char;
end;
  }



  UserDataCount := '080';
  UserData := '';

  try
    StrPCopy(pStr, format('%4.4d', [StrToInt(eDriverID.Caption)]))       ;
  except
    pStr := '0000';
  end;
  move (pStr, IAESAuth^.PINNumber, 4);

  try
    StrPCopy(pStr, format('%7.7d', [StrToInt(eOdometer.Caption)]))       ;
  except
    pStr := '0000000';
  end;
  move (pStr, IAESAuth^.Odometer, 7);


  try
    tNum := StrToInt(eVehicleNo.Caption);
  except
    tNum := 0;
  end;

  try
    StrPCopy(pStr, format('%5.5d', [tNum]))       ;
  except
    pStr := '00000';
  end;
  move (pStr, IAESAuth^.VehicleNo, 5);


  try
    StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.FuelCode, 2);

  IAESAuth^.FuelUnits        := 'G'    {Gallons}   ;

  try
    StrPCopy(pStr, format('%6.6d', [ Round((FuelQty[1] * 1000)) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.FuelQuantity, 6);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelPrice[1] * 1000) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.FuelPrice, 5);


  try
    //StrPCopy(pStr, format('%6.6d', [ Round(FuelAmount[1] * 100) ]))       ;
    StrPCopy(pStr, format('%6.6d', [ Round(FuelAmount * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.FuelAmount, 6);


  try
    StrPCopy(pStr, format('%2.2d', [OilType]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.OilCode, 2);

  If (OilType = 0) Then
    IAESAuth^.OilUnits        := ' '        // Changed from 'Q', B.Bartlome, 10-28-97
  Else
    IAESAuth^.OilUnits        := 'Q';

  try
    StrPCopy(pStr, format('%5.5d', [Round(OilQty * 100)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.OilQuantity, 5);


  try
    StrPCopy(pStr, format('%5.5d', [Round(OilPrice * 100)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.OilPrice, 5);


  try
    StrPCopy(pStr, format('%5.5d', [Round(OilAmount * 100)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.OilAmount, 5);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.ProdCode1, 2);

  try
    StrPCopy(pStr, format('%5.5d', [Round(ProdAmount[1] * 100)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.ProdAmount1, 5);

  try
    StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.ProdCode2, 2);

  try
    StrPCopy(pStr, format('%5.5d', [Round(ProdAmount[2] * 100)]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, IAESAuth^.ProdAmount2, 5);


  IAESAuth^.Filler1         := '0000'   ;
  IAESAuth^.VFDriverNo      := '00000'  ;
  IAESAuth^.VFCVVNo         := '000'    ;

  if Copy(CardNo,1,6) = '471531' then  {VisaFleet}
    begin
     CharPosition := Pos('=',Track2Data);
     if CharPosition > 0 then
       begin
         try
          StrPCopy(pStr, Copy(Track2Data, CharPosition+8, 3))       ;
         except
           pStr := '0000000000000';
         end;
         move (pStr, IAESAuth^.VFCVVNo, 3);

         try
          StrPCopy(pStr, Copy(Track2Data, CharPosition+16, 5))       ;
         except
           pStr := '0000000000000';
         end;
         move (pStr, IAESAuth^.VFDriverNo, 5);

       end;

    end;

  move(IAESAuth^, UserData, sizeof(IAESAuth^)) ;

end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildVoyagerUserData                            |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eDriverID, eOdometer, FuelAmount, FuelProd1Amt,    |
|               FuelProd1Gals, FuelProd1Type, FuelProd2Amt, FuelProd2Gals,   |
|               FuelProd2Type, FuelQty, FuelType, Odometer, Prod1Amt,        |
|               Prod1Qty, Prod1Type, Prod2Amt, Prod2Qty, Prod2Type, Prod3Amt,|
|               Prod3Qty, Prod3Type, Prod4Amt, Prod4Qty, Prod4Type,          |
|               ProdAmount, ProdQty, ProdType, ServiceType, Tax, TlTax,      |
|               UserData, UserDataCount, VoyagerAuth                         |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildVoyagerUserData                            |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      DriverID, eDriverID, eOdometer, FuelAmount, FuelProd1Amt,    |
|               FuelProd1Gals, FuelProd1Type, FuelProd2Amt, FuelProd2Gals,   |
|               FuelProd2Type, FuelQty, FuelType, Odometer, Prod1Amt,        |
|               Prod1Qty, Prod1Type, Prod2Amt, Prod2Qty, Prod2Type, Prod3Amt,|
|               Prod3Qty, Prod3Type, Prod4Amt, Prod4Qty, Prod4Type,          |
|               ProdAmount, ProdQty, ProdType, ServiceType, Tax, TlTax,      |
|               UserData, UserDataCount, VoyagerAuth                         |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildVoyagerUserData;
var
pStr : array[0..50] of char;
begin
{
  Odometer        : array[0..6] of char;
  DriverID        : array[0..5] of char;
  ServiceType     : char;
  FuelProd1Type   : array[0..1] of char;
  FuelProd1Gals   : array[0..4] of char;
  FuelProd1Amt    : array[0..4] of char;
  FuelProd2Type   : array[0..1] of char;
  FuelProd2Gals   : array[0..4] of char;
  FuelProd2Amt    : array[0..4] of char;
  Prod1Type       : array[0..1] of char;
  Prod1Qty        : array[0..1] of char;
  Prod1Amt        : array[0..4] of char;
  Prod2Type       : array[0..1] of char;
  Prod2Qty        : array[0..1] of char;
  Prod2Amt        : array[0..4] of char;
  Prod3Type       : array[0..1] of char;
  Prod3Qty        : array[0..1] of char;
  Prod3Amt        : array[0..4] of char;
  Prod4Type       : array[0..1] of char;
  Prod4Qty        : array[0..1] of char;
  Prod4Amt        : array[0..4] of char;
  Tax             : array[0..5] of char;
  garbage         : array[0..9] of char;
}

  UserDataCount := '080';
  UserData := '';

  try
    StrPCopy(pStr, format('%7.7d', [StrToInt(eOdometer.Caption)]))       ;
  except
    pStr := '0000000';
  end;
  move (pStr, VoyagerAuth^.Odometer, 7);

  try
    StrPCopy(pStr, format('%6.6d', [StrToInt(eDriverID.Caption)]))       ;
  except
    pStr := '000000';
  end;
  move (pStr, VoyagerAuth^.DriverID, 6 );


  VoyagerAuth^.ServiceType  := '0';   {Self Service}

  try
    StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd1Type, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelQty[1] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd1Gals, 5);

  try
    //StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount[1] * 100) ]))       ;
    StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd1Amt, 5);

  try
    StrPCopy(pStr, format('%2.2d', [FuelType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd2Type, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelQty[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd2Gals, 5);

  try
    //StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.FuelProd2Amt, 5);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod1Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[1]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod1Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[1] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod1Amt, 5);
//-------------------

  try
    StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod2Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[2]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod2Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod2Amt, 5);
//-------------------
  try
    StrPCopy(pStr, format('%2.2d', [ProdType[3]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod3Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[3]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod3Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[3] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod3Amt, 5);
//-------------------
  try
    StrPCopy(pStr, format('%2.2d', [ProdType[4]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod4Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[4]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod4Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[4] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Prod4Amt, 5);
//-------------------

  try
    StrPCopy(pStr, format('%6.6d', [ Round(TlTax * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerAuth^.Tax, 6);

  move(VoyagerAuth^, UserData, sizeof(VoyagerAuth^)) ;


end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildVoyagerCredit                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      eBatchNo, FuelAmount, FuelProd1Amt, FuelProd1Gals,           |
|               FuelProd1Type, FuelProd2Amt, FuelProd2Gals, FuelProd2Type,   |
|               FuelQty, FuelType, OrigInvoiceNo, Prod1Amt, Prod1Qty,        |
|               Prod1Type, Prod2Amt, Prod2Qty, Prod2Type, Prod3Amt, Prod3Qty,|
|               Prod3Type, Prod4Amt, Prod4Qty, Prod4Type, ProdAmount,        |
|               ProdQty, ProdType, ServiceType, Tax, TlTax, UserData,        |
|               UserDataCount, VoyagerCredit                                 |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildVoyagerCredit                              |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    CheckUserData                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      eBatchNo, FuelAmount, FuelProd1Amt, FuelProd1Gals,           |
|               FuelProd1Type, FuelProd2Amt, FuelProd2Gals, FuelProd2Type,   |
|               FuelQty, FuelType, OrigInvoiceNo, Prod1Amt, Prod1Qty,        |
|               Prod1Type, Prod2Amt, Prod2Qty, Prod2Type, Prod3Amt, Prod3Qty,|
|               Prod3Type, Prod4Amt, Prod4Qty, Prod4Type, ProdAmount,        |
|               ProdQty, ProdType, ServiceType, Tax, TlTax, UserData,        |
|               UserDataCount, VoyagerCredit                                 |
|                                                                            |
| LOCALS:       pStr                                                         |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildVoyagerCredit;
var
pStr : array[0..50] of char;
begin
{
TVoyagerCredit = record
  OrigInvoiceNo   : array[0..5] of char;
  ServiceType     : char;
  FuelProd1Type   : array[0..1] of char;
  FuelProd1Gals   : array[0..4] of char;
  FuelProd1Amt    : array[0..4] of char;
  FuelProd2Type   : array[0..1] of char;
  FuelProd2Gals   : array[0..4] of char;
  FuelProd2Amt    : array[0..4] of char;
  Prod1Type       : array[0..1] of char;
  Prod1Qty        : array[0..1] of char;
  Prod1Amt        : array[0..4] of char;
  Prod2Type       : array[0..1] of char;
  Prod2Qty        : array[0..1] of char;
  Prod2Amt        : array[0..4] of char;
  Prod3Type       : array[0..1] of char;
  Prod3Qty        : array[0..1] of char;
  Prod3Amt        : array[0..4] of char;
  Prod4Type       : array[0..1] of char;
  Prod4Qty        : array[0..1] of char;
  Prod4Amt        : array[0..4] of char;
  Tax             : array[0..5] of char;
end;

   }

  UserDataCount := '073';
  UserData := '';

  try
    StrPCopy(pStr, format('%6.6d', [StrToInt(eBatchNo.Caption)]))       ;
  except
    pStr := '000000';
  end;
  move (pStr, VoyagerCredit^.OrigInvoiceNo, 6 );



  VoyagerCredit^.ServiceType  := '0';   {Self Service}

  try
    StrPCopy(pStr, format('%2.2d', [FuelType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd1Type, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelQty[1] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd1Gals, 5);

  try
    //StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount[1] * 100) ]))       ;
    StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd1Amt, 5);

  try
    StrPCopy(pStr, format('%2.2d', [FuelType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd2Type, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(FuelQty[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd2Gals, 5);

  try
    //StrPCopy(pStr, format('%5.5d', [ Round(FuelAmount[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.FuelProd2Amt, 5);


  try
    StrPCopy(pStr, format('%2.2d', [ProdType[1]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod1Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[1]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod1Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[1] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod1Amt, 5);
//-------------------

  try
    StrPCopy(pStr, format('%2.2d', [ProdType[2]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod2Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[2]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod2Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[2] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod2Amt, 5);
//-------------------
  try
    StrPCopy(pStr, format('%2.2d', [ProdType[3]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod3Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[3]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod3Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[3] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod3Amt, 5);
//-------------------
  try
    StrPCopy(pStr, format('%2.2d', [ProdType[4]]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod4Type, 2);

  try
    StrPCopy(pStr, format('%2.2d', [ Round(ProdQty[4]) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod4Qty, 2);

  try
    StrPCopy(pStr, format('%5.5d', [ Round(ProdAmount[4] * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Prod4Amt, 5);
//-------------------

  try
    StrPCopy(pStr, format('%6.6d', [ Round(TlTax * 100) ]))       ;
  except
    pStr := '0000000000000';
  end;
  move (pStr, VoyagerCredit^.Tax, 6);

  move(VoyagerCredit^, UserData, sizeof(VoyagerCredit^)) ;


end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ResetLabels                                     |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    InitScreen, ProcessKey                                       |
|                                                                            |
| CALLS:        SetActiveField                                               |
|                                                                            |
| GLOBALS:      BuffPtr, eApproval, eBatchNo, eCardName, eCardNo, eCardType, |
|               eDate, eDriverID, eExpDate, EntryType, eOdometer,            |
|               eRestrictionCode, eSeqNo, eVehicleNo, eVisibleDriverID,      |
|               FieldToken, KeyBuff, lApproval, lBatchNo, lCardName,         |
|               lCardType, lDate, lDriver, lOdometer, lRestrictionCode,      |
|               lSeqNo, lStatus, lVehicle                                    |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.ResetLabels                                     |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    InitScreen, ProcessKey                                       |
|                                                                            |
| CALLS:        SetActiveField                                               |
|                                                                            |
| GLOBALS:      BuffPtr, eApproval, eBatchNo, eCardName, eCardNo, eCardType, |
|               eDate, eDriverID, eExpDate, EntryType, eOdometer,            |
|               eRestrictionCode, eSeqNo, eVehicleNo, eVisibleDriverID,      |
|               FieldToken, KeyBuff, lApproval, lBatchNo, lCardName,         |
|               lCardType, lDate, lDriver, lOdometer, lRestrictionCode,      |
|               lSeqNo, lStatus, lVehicle                                    |
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
procedure TfmADSCCForm.ResetLabels;
begin

  lCardName.Visible := False;
  eCardName.Enabled := False;
  lCardType.Visible := False;
  eCardType.Enabled := False;

  eCardNo.Caption := '';
  eCardName.Caption := '';
  eExpDate.Caption := '';
  eCardType.Caption := '';
  eRestrictionCode.Caption := '';
  eVehicleNo.Caption := '';
  eDriverID.Caption := '';
  eVisibleDriverID.Caption := '';
  eOdometer.Caption := '';

  lRestrictionCode.Visible := False;
  lDriver.Visible := False;
  lOdometer.Visible := False;
  lVehicle.Visible := False;

  eBatchNo.Caption := '';
  eSeqNo.Caption := '';
  eDate.Caption := '';
  eApproval.Caption := '';

  eBatchNo.Visible := True;
  eSeqNo.Visible := True;
  eDate.Visible := True;

  lBatchNo.Visible := False;
  lSeqNo.Visible := False;
  lDate.Visible := False;
  lApproval.Visible := False;

  EntryType := 'M';
  FieldToken := 1;
  SetActiveField;
  lStatus.Caption := '';
  KeyBuff := '';
  BuffPtr := 0;

end;


{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.FormClose                                       |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Action, Sender                                               |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      bPINPadActive, fmPOS, IAESAuth, MSRData, PHHAuth, PinPad1,   |
|               VoyagerAuth, VoyagerCredit, WEXCredit, WEXFuelAndNonFuelProd,|
|               WEXFuelAndTwoNonFuelProd, WEXSingleFuelProd,                 |
|               WEXSingleNonFuelProd, WEXThreeNonFuelProd, WEXTwoNonFuelProd |
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
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.FormClose                                       |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   Action, Sender                                               |
|                                                                            |
| CALLED BY:    (none)                                                       |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      IAESAuth, MSRData, PHHAuth, VoyagerAuth, VoyagerCredit,      |
|               WEXCredit, WEXFuelAndNonFuelProd, WEXFuelAndTwoNonFuelProd,  |
|               WEXSingleFuelProd, WEXSingleNonFuelProd, WEXThreeNonFuelProd,|
|               WEXTwoNonFuelProd                                            |
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
procedure TfmADSCCForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MSRData := '';
  (*if bPINPadActive > 0 then
    fmPOS.PINPad1.EntryMode := emIdle;*)
  Dispose(WEXSingleFuelProd);
  Dispose(WEXSingleNonFuelProd);
  Dispose(WEXFuelAndNonFuelProd);
  Dispose(WEXTwoNonFuelProd);
  Dispose(WEXFuelAndTwoNonFuelProd);
  Dispose(WEXThreeNonFuelProd);
  Dispose(WEXCredit);
  Dispose(PHHAuth);
  Dispose(IAESAuth);
  Dispose(VoyagerAuth);
  Dispose(VoyagerCredit);
end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildTouchPad                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    InitScreen                                                   |
|                                                                            |
| CALLS:        BuildKeyPad                                                  |
|                                                                            |
| GLOBALS:      (none)                                                       |
|                                                                            |
| LOCALS:       nBtnNo, nColNo, nRowNo                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildTouchPad                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    InitScreen                                                   |
|                                                                            |
| CALLS:        BuildKeyPad                                                  |
|                                                                            |
| GLOBALS:      (none)                                                       |
|                                                                            |
| LOCALS:       nBtnNo, nColNo, nRowNo                                       |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildTouchPad;
var
nRowNo : short;
nColNo : short;
nBtnNo : short;

begin

  nBtnNo := 1;
  for nRowNo := 1 to 5 do
    for nColNo := 1 to 3 do
      begin
        if (nRowNo = 4) and ((nColNo = 1) or (nColNo = 3)) then
        else
          BuildKeyPad(nRowNo, nColNo, nBtnNo );
        Inc(nBtnNo);
      end;

end;



{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildKeyPad                                     |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   BtnNdx, ColNo, RowNo                                         |
|                                                                            |
| CALLED BY:    BuildTouchPad                                                |
|                                                                            |
| CALLS:        CCButtonClick                                                |
|                                                                            |
| GLOBALS:      fmADSCCForm, Keytops, POSButtons                             |
|                                                                            |
| LOCALS:       TopKeyPos                                                    |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
{
+----------------------------------------------------------------------------+
|                                                                            |
| PROCEDURE:    TfmADSCCForm.BuildKeyPad                                     |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   BtnNdx, ColNo, RowNo                                         |
|                                                                            |
| CALLED BY:    BuildTouchPad                                                |
|                                                                            |
| CALLS:        CCButtonClick                                                |
|                                                                            |
| GLOBALS:      fmADSCCForm, Keytops, POSButtons                             |
|                                                                            |
| LOCALS:       TopKeyPos                                                    |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
procedure TfmADSCCForm.BuildkeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin

  if screen.width = 800 then
    TopKeyPos := 48
  else
    TopKeyPos := 64;

  POSButtons[BtnNdx]         := TPOSTouchButton.Create(fmADSCCForm);

  POSButtons[BtnNdx].Parent  := fmADSCCForm;
  POSButtons[BtnNdx].Name    := 'PumpButton' + IntToStr(BtnNdx);

  if screen.width = 1024 then
    begin
      POSButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 65);
      POSButtons[BtnNdx].Left     := ((ColNo - 1) * 65) + 500;
      POSButtons[BtnNdx].Height     := 60;
      POSButtons[BtnNdx].Width      := 60;
      POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
    end
  else
    begin
      POSButtons[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 50);
      POSButtons[BtnNdx].Left     := ((ColNo - 1) * 50) + 375;
      POSButtons[BtnNdx].Height     := 47;
      POSButtons[BtnNdx].Width      := 47;
      POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
    end;
  POSButtons[BtnNdx].KeyRow     := RowNo;
  POSButtons[BtnNdx].KeyCol     := ColNo;
  POSButtons[BtnNdx].Visible    := True;
  POSButtons[BtnNdx].OnClick    := CCButtonClick;
  POSButtons[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[BtnNdx].FrameStyle := bfsNone;
  POSButtons[BtnNdx].WordWrap   := True;
  POSButtons[BtnNdx].Tag        := BtnNdx;
  POSButtons[BtnNdx].NumGlyphs  := 14;
  POSButtons[BtnNdx].Frame      := 8;
  POSButtons[BtnNdx].KeyPreset  := '';

  POSButtons[BtnNdx].Font.Color :=  clBlack;
  POSButtons[BtnNdx].Frame := 11;

  case BtnNdx of
  15 :
      begin
        POSButtons[BtnNdx].KeyType   := 'ENT';
        POSButtons[BtnNdx].KeyVal := '';
        POSButtons[BtnNdx].Caption := 'Enter';
      end;
  14 :
      begin
        POSButtons[BtnNdx].KeyType   := 'BSP';
        POSButtons[BtnNdx].KeyVal := '';
        POSButtons[BtnNdx].Caption := 'Back Space';
      end;
  13 :
      begin
        POSButtons[BtnNdx].KeyType   := 'CLR';
        POSButtons[BtnNdx].KeyVal := '';
        POSButtons[BtnNdx].Caption := 'Clear';
      end;
  else
    begin
      POSButtons[BtnNdx].KeyType := 'NUM - Number';
      POSButtons[BtnNdx].KeyVal  := KeyTops[BtnNdx];
      POSButtons[BtnNdx].Caption  := KeyTops[BtnNdx];
    end;
  end;
end;

{
+----------------------------------------------------------------------------+
|                                                                            |
| FUNCTION:     TfmADSCCForm.GetSalePumpNo                                   |
|                                                                            |
| DESCRIPTION:                                                               |
|                                                                            |
| PARAMETERS:   (none)                                                       |
|                                                                            |
| CALLED BY:    ProcessCredit                                                |
|                                                                            |
| CALLS:        (none)                                                       |
|                                                                            |
| GLOBALS:      CurSaleData, CurSaleList, LineType, LineVoided               |
|                                                                            |
| LOCALS:       ndx, PumpNo                                                  |
|                                                                            |
| REVISION HISTORY:                                                          |
|                                                                            |
| Version   Date       Programmer     Modification                           |
| -------   --------   ------------   -------------------------------------- |
|                                                                            |
+----------------------------------------------------------------------------+
}
function TfmADSCCForm.GetSalePumpNo: integer;
var
  PumpNo : integer;
  ndx : integer;
  CurSaleData : pSalesData;
begin

  PumpNo := 0;
  for Ndx := 0 to (fmPos.CurSaleList.Count - 1) do
    begin
      CurSaleData := fmPos.CurSaleList.Items[Ndx];
      if (CurSaleData^.LineType = 'FUL') and (CurSaleData^.LineVoided = False) then
        begin
          PumpNo := CurSaleData^.PumpNo;
          break;
        end;
    end;

  GetSalePumpNo := PumpNo;

end;


end.

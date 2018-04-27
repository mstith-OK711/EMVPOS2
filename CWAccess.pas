{-----------------------------------------------------------------------------
 Unit Name: CWAccess
 Author:    Gary Whetton
 Date:      4/13/2004 3:15:13 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit CWAccess;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, POSMain,
  Math, StdCtrls, DB, AdPort, ExtCtrls, POSBtn, ElastFrm, ComObj;

const

  LEN_KEY_TYPE   =  3;
  LEN_KEY_VALUE  =  5;
  LEN_KEY_PRESET = 10;

  WM_INITSCREEN  = WM_USER + 201;

  FT_ACCESS_CODE         = 1;
  FT_EXPDATE             = 2;
  FT_STARTAUTH           = 11;

  DC0_BUTTON_NUMBER =  3;
  DC1_BUTTON_NUMBER =  1;
  DC2_BUTTON_NUMBER = 15;
  DC3_BUTTON_NUMBER =  4;
  DC4_BUTTON_NUMBER =  5;
  DC5_BUTTON_NUMBER =  6;
  DC9_BUTTON_NUMBER = 13;
  DCC_BUTTON_NUMBER = 11; // cancel

  // Number of concurrent sales transactions with credit server sessions.
  // (Example, normal, next customer, balance inquiry.)
  MAX_CWClientS = 4;
  DEFAULT_CCINDEX = 0;

  DebugMode : boolean = false;


type
  TKeyPadID = (mKeyPadUnknown, mKeyPadClear, mKeyPadNumber, mKeyPadDebitCredit, mKeyPadCWSelect,
               mKeyPadYesNo, mKeyPadNextCustomerNo, mKeyPadNextCustomerYes, mKeyPadVoidCredit, mKeyPadDateCode);

  TCWClientData = record
    // Saved property values:
    TransNo                 : integer;
    LastUsedTime            : TTime;
    CWAccessType            : integer;
    Authorized              : integer;
    CWPLUNo                 : integer;
    CWAccessCode            : string;
    CWDaysToExpire          : integer;
    CarwashInterfaceState   : short;
    // Other saved values:
    KeyPadID                : TKeyPadID;
    bPressedYes             : boolean;
    FieldToken              : short;
    BuffPtr                 : short;
    PrevField               : short;
    sKeyType                : string[LEN_KEY_TYPE];
    sKeyVal                 : string[LEN_KEY_VALUE];
    sPreset                 : string[LEN_KEY_PRESET];
    RespAllowed             : string;
    RespAuthCode            : string;
    RespAuthMsg             : string;
    RespPrintLine1          : string;
  end;

  TfmCWAccessForm = class(TForm)
    lAccessCode: TLabel;
    lExpDate: TLabel;
    lStatus: TPanel;
    eAccessCode: TPanel;
    eExpDate: TPanel;
    ElasticForm1: TElasticForm;
    CWTimeOutTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure InitializeCWClientData(CWIndex : integer);
    procedure CWTimeOutTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    CWClientIndex            : integer;
    CWClientData             : array [0..MAX_CWClientS-1] of TCWClientData;

    FCurrentTransNo          : integer;
    FCWAccessType            : integer;
    FAuthorized              : integer;
    FCWPLUNo                 : integer;
    FCWAccessCode            : string;
    FCWDaysToExpire          : integer;
    FCarwashInterfaceState   : short;

    procedure GetCWClientVar();
    procedure PutCWClientVar();
    function GetCWClientIndex() : integer;
    procedure SetAuthorized(Value : integer);
    procedure SetCWPLUNo(Value : integer);
    procedure SetCWAccessCode(Value : string);
    procedure SetCWDaysToExpire(Value : integer);
    procedure SetCarwashInterfaceState(Value : short);

  public
    { Public declarations }
    EntryBuff: array[0..200] of Char;
    Initialize : Boolean;

    procedure CWButtonClick(Sender: TObject);
    procedure ProcessKey ;
    procedure ResetLabels;
    procedure ProcessCarwash(var Msg: TWMStatus); message WM_CARWASH_MSG;
    procedure InitScreen(var Msg: TMessage); message WM_INITSCREEN;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure PreProcessKey(var Msg: TMessage); message WM_PREPROCESSKEY;

    procedure SetPrevField;
    procedure SetActiveField;

    procedure BuildTouchPad;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );
    function  GetSalePumpNo(): integer;  // returns first pump no found in sale
    procedure SetClearPad();
    procedure SetNumberPad();
    procedure SetYesNoPad();
    procedure SetCWSelectPad();
    procedure SetCWClientData(const NewTransNo : integer; const NewCWAccessType : integer);

    procedure VoidCarwashCode(const AuthCode : string);
    property CurrentTransNo : integer  read FCurrentTransNo{cebugccc write SetCurrentTransNo};
    property CWAccessType : integer  read FCWAccessType{cdebugccc write SetCWAccessType};
    property Authorized : integer read FAuthorized write SetAuthorized;
    property CWPLUNo : integer read FCWPLUNo write SetCWPLUNo;
    property CWAccessCode : string read FCWAccessCode write SetCWAccessCode;
    property CWDaysToExpire : integer read FCWDaysToExpire write SetCWDaysToExpire;
    property CarwashInterfaceState : short read FCarwashInterfaceState write SetCarwashInterfaceState;
    procedure InitializeScreen;
  end;

var
  fmCWAccessForm: TfmCWAccessForm;

  KeyPadID : TKeyPadID;

  bPressedYes   : boolean;

  FieldToken : short;

  KeyBuff: array[0..200] of Char;
  BuffPtr: short;

  PrevField : short;


  RespAllowed      : string;
  RespAuthCode     : string;
  RespAuthMsg      : string;

  RespPrintLine1     : string;

  RespRequestStatus : string;
  RespAccessCode : string;
  RespValue : string;

  RequestStatus : Integer;

  bVoidDuring : boolean;

  Keytops      : array[1..15] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '', '0', '', 'C', 'B', 'E');
  POSButtons    : array[1..15] of TPOSTouchButton;

implementation

uses POSDM, POSLog, POSErr, Mainmenu, POSMisc, LatTypes;

{$R *.DFM}
var
  sKeyType  : string[LEN_KEY_TYPE];
  sKeyVal   : string[LEN_KEY_VALUE];
  sPreset   : string[LEN_KEY_PRESET];

{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.PreProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.PreProcessKey(var Msg:TMessage);
begin
  GetCWClientVar();
  ProcessKey();
  PutCWClientVar();
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.CheckKey(var Msg:TWMPOSKey);
var
 sKeyChar  : string[2];
begin
  GetCWClientVar();
  KeyBuff[BuffPtr] := Msg.KeyCode;
  if Error_SkipKey then
  Begin
    Error_SkipKey := False;
    KeyBuff := '';
    BuffPtr := 0;
    PutCWClientVar();
    Exit;
  End;
  if BuffPtr = 1 then
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
      Error_SkipKey := True;
    KeyBuff := '';
    BuffPtr := 0;
    PutCWClientVar();
    exit;
  end;
  if KeyBuff[BuffPtr] <> #13 then
    Inc(BuffPtr,1);
  PutCWClientVar();
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.InitScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.InitScreen(var Msg:TMessage);
begin
  GetCWClientVar();
  CWTimeOutTimer.Enabled := False;
  case fmPOS.POSScreenSize of
  1 :
    begin
      fmCWAccessForm.Left := 169;
      fmCWAccessForm.Top  := 291;
    end;
  2 :
    begin
      fmCWAccessForm.Left := 123;
      fmCWAccessForm.Top  := 243;
    end;
  end;

  if POSButtons[1] = nil then
    BuildTouchPad;

  ResetLabels;
  SetCWSelectPad();

  bVoidDuring := False;


  lStatus.Visible := False;
  lStatus.Caption := '';
  BuffPtr := 0;
  // If carwash product (PLU) has already been selected, then request access code from carwash server;
  // otherwise, request product from clerk.
  if (CarwashInterfaceState = CI_BUILD_CODE_REQUEST) then
    begin
      FieldToken := 0;
      PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, 0);
    end
  else
    begin
      FieldToken := FT_ACCESS_CODE;
    end;
  SetActiveField;
  PutCWClientVar();
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.ProcessKey;
begin
  while True do
  begin
    if sKeyType = 'CLR' then
    begin
      case FieldToken of
          FT_STARTAUTH,
          FT_ACCESS_CODE : { Carwash access code. }
            begin
              if eAccessCode.Caption = '' then
              begin
                eAccessCode.Color := clBtnFace;
                close;
              end
              else
                eAccessCode.Caption := '';
            end;

          FT_EXPDATE : { ExpDate }
            begin
              if eExpDate.Caption = '' then
              begin
                PrevField := FT_ACCESS_CODE;
                SetPrevField;
              end
              else
                eExpDate.Caption := '';
            end;
      end;
    end
    else if (sKeyType = 'YEA') then
    begin
      sKeyType := 'ENT';
      FieldToken := FT_STARTAUTH;
      SetActiveField();
      continue;
    end
    else if (sKeyType = 'MAY') then  // cdebug - Temp. code to test cashout option ...
    begin
      sKeyType := 'ENT';
      FieldToken := FT_STARTAUTH;
      SetActiveField();
      continue;
    end
    else if (sKeyType = 'NAY') then
    begin
      sKeyType := 'ENT';
      FieldToken := FT_STARTAUTH;
      SetActiveField();
      Continue;
    end
    else if sKeyType = 'BSP' then
    begin
      case FieldToken of
        FT_ACCESS_CODE : { Access code }
          begin
            if length(eAccessCode.Caption) > 0 then
              eAccessCode.Caption := copy(eAccessCode.Caption, 1, (length(eAccessCode.Caption) - 1));
          end;
        FT_EXPDATE : { ExpDate }
          begin
            if length(eExpDate.Caption) > 0 then
              eExpDate.Caption := copy(eExpDate.Caption, 1, (length(eExpDate.Caption) - 1));
          end;
      end;
    end
    else if sKeyType = 'NUM' then
    begin
      case FieldToken of
      FT_ACCESS_CODE :
        begin
          eAccessCode.Caption := eAccessCode.Caption + sKeyVal;
        end;
      FT_EXPDATE :
        begin
          eExpDate.Caption := eExpDate.Caption + sKeyVal;
        end;
      end;
    end
    else if sKeyType = 'PLU' then
    begin
      PrevField := FieldToken;
      case FieldToken of
        FT_ACCESS_CODE,
        FT_STARTAUTH :
          begin
            FieldToken := 0;
            SetActiveField;
            try
              CWPLUNo := StrToInt(sKeyVal);
            except
              CWPLUNo := 0;
            end;
            CarwashInterfaceState := CI_BUILD_CODE_REQUEST;
            PutCWClientVar();
            PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, 0);
          end;
      end;
    end
    else if sKeyType = 'SET' then
    begin
      PrevField := FieldToken;
      case FieldToken of
        FT_ACCESS_CODE,
        FT_STARTAUTH :
          begin
            FieldToken := 0;
            SetActiveField;
            CarwashInterfaceState := CI_BUILD_PRICE_STORE;
            PutCWClientVar();
            PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, 0);
          end;
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
    else if sKeyType = 'NXT' then        { Next Customer }
    begin
      Authorized   := 2;
      Close;
    end;
    break;
  end;
end;  // procedure Processkey()


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetPrevField
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetPrevField;
begin
  FieldToken := PrevField;
  SetActiveField;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetActiveField
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetActiveField;
begin
  eAccessCode.Color                 := clBackGround;
  eExpDate.Color                := clBackGround;
  eAccessCode.Font.Color            := clYellow;
  eAccessCode.BevelInner            := bvNone;
  eExpDate.BevelInner           := bvNone;
  eAccessCode.BevelOuter            := bvNone;
  eExpDate.BevelOuter           := bvNone;
  lStatus.Visible := False;
  case FieldToken of
  FT_ACCESS_CODE :
     begin
       eAccessCode.Color           := clWhite;
       eAccessCode.Font.Color      := clBlack;

       eAccessCode.BevelInner      := bvLowered;
       eAccessCode.BevelOuter      := bvRaised;

       if (CWAccessType = GC_NONE) then
         lStatus.Caption         := 'Select Carwash Option'
       else
         lStatus.Caption         := 'Enter Access Code';

       lStatus.Visible         := True;

     end;
  FT_EXPDATE :
     begin
       lStatus.Caption := 'Enter Expiration Date';
       lStatus.Visible := True;

       eExpDate.Color   := clWhite;
       eExpDate.Font.Color   := clBlack;
       eExpDate.BevelInner  := bvLowered;
       eExpDate.BevelOuter  := bvRaised;
     end;
  end;
  lStatus.Refresh;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.ProcessCarwash
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TWMStatus
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.ProcessCarwash(var Msg:TWMStatus);
var
  action : short;
  CWMsg : string;
  CheckCWMsg : string;
  TagTransNoStr : string;
  TempTransNo : integer;
  jcc : integer;
  bChangeContext : boolean;
  SaveTransNo : integer;
  SaveCWAccessType : integer;
begin
  GetCWClientVar();
  // If a transaction number is in the message, then reset the context of the credit interface back
  // to what it was at the time the request was sent.
  bChangeContext := False;  // Assumption for now.
  // Following initial values not used unless reset below, but keeps compiler happy.
  SaveTransNo := 0;
  SaveCWAccessType := GC_NONE;
  try
    if (Msg.Status <> nil) then
    begin
      CheckCWMsg := Msg.Status.Text;
      TagTransNoStr := GetTagData(CWTAG_TRANSNO, CheckCWMsg);
    end
    else
    begin
      TagTransNoStr := '';
    end;
    if (TagTransNoStr <> '') then
    begin
      TempTransNo :=  StrToInt(TagTransNoStr);
      for jcc := 0 to NUM_CREDIT_CLIENTS - 1 do
      begin
        if (TempTransNo = CarwashClient[jcc].CarwashTransNo) then
        begin
          SaveTransNo := CurrentTransNo;
          SaveCWAccessType := CWAccessType;
          bChangeContext := True;
          fmCWAccessForm.SetCWClientData(TempTransNo, CarwashClient[jcc].CWAccessType);
          break;
        end;
      end;
    end;
  except
  end;

  case CarwashInterfaceState of
  CI_BUILD_CODE_REQUEST :
    begin
      lStatus.Caption := 'Beginning Carwash Code Request';
      lStatus.refresh;

      SetClearPad();

      RespAllowed      := '';
      RespAuthCode     := '';
      RespAuthMsg      := '';
      RespPrintLine1   := '';
      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_CODE_REQUEST)) +
               BuildTag(IntToStr(nCWTAG_PLU_OPTION),  IntToStr(CWPLUNo) ) +
               BuildTag(CWTAG_TRANSNO,  Format('%6.6d',[CurrentTransNo]) );
      lStatus.Visible := True;
      CarwashInterfaceState := CI_HANDLE_RESPONSE;

      if (not debugmode) then
      begin
        CWTimeOutTimer.Interval := CI_FAILSAFE_TIMEOUT;
        CWTimeOutTimer.Enabled := True;
      end;
      fmPOS.SendCarwashMessage(CWMsg);
    end;

  CI_BUILD_PRICE_LOAD :
    begin

      lStatus.Caption := 'Beginning Carwash Price Load Request';
      lStatus.refresh;

      RespAllowed      := '';
      RespAuthCode     := '';
      RespAuthMsg      := '';
      RespPrintLine1   := '';

      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PRICE_LOAD_REQUEST)) +
               BuildTag(CWTAG_TRANSNO,  Format('%6.6d',[CurrentTransNo]) );
      lStatus.Visible := True;
      CarwashInterfaceState := CI_HANDLE_RESPONSE;

      if (not debugmode) then
      begin
        CWTimeOutTimer.Interval := CI_FAILSAFE_TIMEOUT;
        CWTimeOutTimer.Enabled := True;
      end;
      fmPOS.SendCarwashMessage(CWMsg);
    end;

  CI_BUILD_PRICE_STORE :
    begin

      lStatus.Caption := 'Setting Carwash Prices';
      lStatus.refresh;

      RespAllowed      := '';
      RespAuthCode     := '';
      RespAuthMsg      := '';
      RespPrintLine1   := '';

      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PRICE_STORE_REQUEST)) +
               BuildTag(CWTAG_TRANSNO,  Format('%6.6d',[CurrentTransNo]) );
      lStatus.Visible := True;
      CarwashInterfaceState := CI_HANDLE_RESPONSE;

      if (not debugmode) then
      begin
        CWTimeOutTimer.Interval := CI_FAILSAFE_TIMEOUT;
        CWTimeOutTimer.Enabled := True;
      end;
      fmPOS.SendCarwashMessage(CWMsg);
    end;

  CI_HANDLE_RESPONSE :
    begin
      CWMsg := Msg.Status.Text;
      Dispose(Msg.Status);
      try
        Action :=  StrToInt(GetTagData(TAG_MSGTYPE, CWMsg));
      except
        Action := 0;
      end;

      if Action = CW_MSG_RESPONSE then
      begin
        CWTimeOutTimer.Enabled := False;
        lStatus.Caption := GetTagData(TAG_STATUSSTRING, CWMsg);
        lStatus.refresh;
        if (not debugmode) then
          begin
            CWTimeOutTimer.Enabled := True;
          end;

      end
      else if (Action = CW_CODE_RESPONSE) then
      begin
        CarwashInterfaceState := CI_IDLE;
        CWTimeOutTimer.Enabled := False;
        RespPrintLine1    := GetTagData(CWTAG_MESSAGE,        CWMsg);
        RespRequestStatus := GetTagData(CWTAG_REQUEST_STATUS, CWMsg);
        try
          RequestStatus := StrToInt(RespRequestStatus);
        except
          RequestStatus := CW_STATUS_DENIED;
        end;
        Authorized := RequestStatus;
        if (RequestStatus = CW_STATUS_ACCEPTED) then
        begin
          RespAccessCode := GetTagData(CWTAG_ACCESS_CODE, CWMsg);
          CWAccessCode := RespAccessCode;
          try
            CWDaysToExpire := StrToInt(GetTagData(CWTAG_DAYS_TO_EXPIRE, CWMsg));
          except
            CWDaysToExpire := -1;
          end;
          RespValue      := GetTagData(CWTAG_VALUE,       CWMsg);
          lStatus.Caption := 'Code:  ' + RespAccessCode + ' - Value:  $' + RespValue;
          lStatus.refresh;
        end
        else   // denied
        begin
          fmCWAccessForm.FormStyle := fsNormal;
          fmPOS.POSError(RespPrintLine1);
          fmCWAccessForm.FormStyle := fsStayOnTop;
        end;
        close;
      end
      else if (Action = CW_PRICE_LOAD_RESPONSE) then
      begin
        CarwashInterfaceState := CI_IDLE;
        CWTimeOutTimer.Enabled := False;
        RespPrintLine1    := GetTagData(CWTAG_MESSAGE,        CWMsg);
        RespRequestStatus := GetTagData(CWTAG_REQUEST_STATUS, CWMsg);
        try
          RequestStatus := StrToInt(RespRequestStatus);
        except
          RequestStatus := CW_STATUS_DENIED;
        end;
        Authorized := RequestStatus;
        if (RequestStatus = CW_STATUS_ACCEPTED) then
          begin
            lStatus.Caption := 'New prices loaded';
            lStatus.refresh;
          end
        else   // denied
          begin
            fmCWAccessForm.FormStyle := fsNormal;
            fmPOS.POSError(RespPrintLine1);
            fmCWAccessForm.FormStyle := fsStayOnTop;
          end;
      end
      else if (Action = CW_PRICE_STORE_RESPONSE) then
      begin
        CarwashInterfaceState := CI_IDLE;
        CWTimeOutTimer.Enabled := False;
        RespPrintLine1    := GetTagData(CWTAG_MESSAGE,        CWMsg);
        RespRequestStatus := GetTagData(CWTAG_REQUEST_STATUS, CWMsg);
        try
          RequestStatus := StrToInt(RespRequestStatus);
        except
          RequestStatus := CW_STATUS_DENIED;
        end;
        Authorized := RequestStatus;
        if (RequestStatus = CW_STATUS_ACCEPTED) then
          begin
            lStatus.Caption := 'New Prices Set on Device';
            lStatus.refresh;
          end
        else   // denied
          begin
            fmCWAccessForm.FormStyle := fsNormal;
            fmPOS.POSError(RespPrintLine1);
            fmCWAccessForm.FormStyle := fsStayOnTop;
          end;
        FieldToken := FT_ACCESS_CODE;
      end
    end;

  CI_HANDLE_TIMEOUT :
    begin

      CarwashInterfaceState := CI_IDLE;

      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_CANCEL_REQUEST));
      fmPOS.SendCarwashMessage(CWMsg);

      lStatus.Caption := 'Timeout waiting on carwash device';
      fmCWAccessForm.FormStyle := fsNormal;
      fmPOS.POSError('Timeout waiting on carwash device');
      fmCWAccessForm.FormStyle := fsStayOnTop;
      close;

    end;

  end;
  // If this procedure changed context (processed different transaction number), then restore context.
  if (bChangeContext) then
  begin
    fmCWAccessForm.SetCWClientData(SaveTransNo, SaveCWAccessType);
  end;
  PutCWClientVar();

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.GetSalePumpNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    integer
  Purpose:   
-----------------------------------------------------------------------------}
function TfmCWAccessForm.GetSalePumpNo(): integer;
var
  PumpNo : integer;
  ndx : integer;
  CurSaleData : pSalesData;
begin
  PumpNo := 0;
  for Ndx := 0 to (fmPos.CurSaleList.Count - 1) do
  begin
    CurSaleData := fmPos.CurSaleList.Items[Ndx];
    if ((CurSaleData^.LineType = 'FUL') or (CurSaleData^.LineType = 'PPY') or (CurSaleData^.LineType = 'PRF')) and
                                                                                (CurSaleData^.LineVoided = False) then
    begin
      PumpNo := CurSaleData^.PumpNo;
      break;
    end;
  end;
  GetSalePumpNo := PumpNo;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.ResetLabels
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.ResetLabels;
begin
  eAccessCode.Caption := '';
  eExpDate.Caption := '';
  lStatus.Caption := '';
  KeyBuff := '';
  BuffPtr := 0;
  POSButtons[15].KeyType   := 'ENT';
  POSButtons[15].KeyVal := '';
  POSButtons[15].Caption := 'Enter';
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CWTimeOutTimer.Enabled := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.BuildTouchPad;
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


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.BuildkeyPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.BuildkeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin

  if screen.width = 800 then
    TopKeyPos := 50
  else
    TopKeyPos := 64;
  if POSButtons[BtnNdx] = nil then
  begin
    POSButtons[BtnNdx]         := TPOSTouchButton.Create(Self);
    POSButtons[BtnNdx].Parent  := Self;
    POSButtons[BtnNdx].Name    := 'CarwashButton' + IntToStr(BtnNdx);
  end;
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
    POSButtons[BtnNdx].Left     := ((ColNo - 1) * 50) + 500;
    POSButtons[BtnNdx].Height     := 47;
    POSButtons[BtnNdx].Width      := 47;
    POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
  end;
  POSButtons[BtnNdx].KeyRow     := RowNo;
  POSButtons[BtnNdx].KeyCol     := ColNo;
  POSButtons[BtnNdx].Visible    := True;
  POSButtons[BtnNdx].OnClick    := CWButtonClick;
  POSButtons[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[BtnNdx].FrameStyle := bfsNone;
  POSButtons[BtnNdx].WordWrap   := True;
  POSButtons[BtnNdx].Tag        := BtnNdx;
  POSButtons[BtnNdx].NumGlyphs  := 14;
  POSButtons[BtnNdx].Frame      := 8;
  POSButtons[BtnNdx].KeyPreset  := '';
  POSButtons[BtnNdx].MaskColor  := fmCWAccessForm.Color;

  POSButtons[BtnNdx].Font.Color :=  clBlack;
  POSButtons[BtnNdx].Frame := 11;

  case BtnNdx of
  15 :
      begin
        if Setup.CarwashInterfaceType = CWSRV_UNITEC then
        begin
          POSButtons[BtnNdx].KeyType   := 'ENT';
          POSButtons[BtnNdx].KeyVal := '';
          POSButtons[BtnNdx].Caption := 'Enter';
        end;
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


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetNumberPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetNumberPad();
var
BtnNdx : short;
begin
  for BtnNdx := 1 to 15 do
    begin
      case BtnNdx of
      15 :
          begin
            if Setup.CarwashInterfaceType = CWSRV_UNITEC then
            begin
              POSButtons[BtnNdx].Visible := True;
              POSButtons[BtnNdx].KeyType   := 'ENT';
              POSButtons[BtnNdx].KeyVal := '';
              POSButtons[BtnNdx].Caption := 'Enter';
            end;
          end;
      14 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'BSP';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'Back Space';
          end;
      13 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'CLR';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'Clear';
          end;
      10, 12 :
          begin
          end;
      else
        begin
          POSButtons[BtnNdx].Visible  := True;
          POSButtons[BtnNdx].KeyType  := 'NUM - Number';
          POSButtons[BtnNdx].KeyVal   := KeyTops[BtnNdx];
          POSButtons[BtnNdx].Caption  := KeyTops[BtnNdx];
        end;
      end;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetYesNoPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetYesNoPad();
var
BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
    begin
      case BtnNdx of
      1 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'YEA';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'Yes';
          end;
      3 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'NAY';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'No';
          end;
      10, 12 :
          begin
          end;
      15 :
          begin
            if Setup.CarwashInterfaceType <> CWSRV_UNITEC then
              POSButtons[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSButtons[BtnNdx].Visible  := False;
        end;
      end;
    end;

  KeyPadID := mKeyPadYesNo;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCWSelectPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCWSelectPad();
const
  START_BUTTON_NUMBER = 1;
var
  BtnNdx : short;
  NextBtn : short;
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close();
    SQL.Clear();
    SQL.Add('SELECT P.PLUNo PLUNo, CW.PLUNo, P.Name Name, D.DeptNo DeptNo, G.GrpNo GrpNo from PLU P, Dept D, Grp G, CWFeatures CW');
    //20070213a...
//    SQL.Add(' WHERE P.DeptNo=D.DeptNo and D.GrpNo=G.GrpNo and P.PLUNo = CW.PLUNo and G.Fuel= :pFuel order by P.Name' );
    SQL.Add(' WHERE P.DeptNo=D.DeptNo and D.GrpNo=G.GrpNo and P.PLUNo = CW.PLUNo and G.Fuel= :pFuel' );
    SQL.Add(' and (P.DelFlag = 0 or P.DelFlag is null) order by P.Name' );
    //...20070213a
    parambyname('pFuel').AsString := CARWASH_GROUP_TYPE;
    Open();

    NextBtn := START_BUTTON_NUMBER;
    while ((not EOF) and (NextBtn <= MAX_CARWASH_POS_SELECTIONS)) do
    begin
      POSButtons[NextBtn].Visible := True;
      POSButtons[NextBtn].KeyType   := 'PLU';
      POSButtons[NextBtn].KeyVal := IntToStr(FieldByName('PLUNo').AsInteger);
      POSButtons[NextBtn].Caption := Copy(FieldByName('Name').AsString, 1, MAX_CARWASH_CAPTION_LEN);
      Inc(NextBtn);
      Next();
    end;

    close();
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if (NextBtn = START_BUTTON_NUMBER) then
      fmPOS.POSError('No PLUs defined for carwash dept #:  ');


  for BtnNdx := NextBtn to 15 do
    begin
      case BtnNdx of
      10, 12 :
          begin
          end;
      13 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'CLR';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'Clear';
          end;
      15 :
          begin
            if Setup.CarwashInterfaceType = CWSRV_UNITEC then
            begin
              POSButtons[BtnNdx].Visible := True;
              POSButtons[BtnNdx].KeyType   := 'SET';
              POSButtons[BtnNdx].KeyVal := '';
              POSButtons[BtnNdx].Caption := 'Set Prices';
            end
            else
              POSButtons[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSButtons[BtnNdx].Visible  := False;
        end;
      end;
    end;

  KeyPadID := mKeyPadCWSelect;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetClearPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetClearPad();
var
BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
    begin
      case BtnNdx of
      5 :
          begin
            POSButtons[BtnNdx].Visible := True;
            POSButtons[BtnNdx].KeyType   := 'CLR';
            POSButtons[BtnNdx].KeyVal := '';
            POSButtons[BtnNdx].Caption := 'Clear';
          end;
      10, 12 :
          begin
          end;
      else
        begin
          POSButtons[BtnNdx].Visible  := False;
        end;
      end;
    end;
  KeyPadID := mKeyPadClear;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.CWButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.CWButtonClick(Sender: TObject);
begin

  if (Sender is TPOSTouchButton) then
    begin
      sKeyType := TPOSTouchButton(Sender).KeyType ;
      sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
      sPreset  := TPOSTouchButton(Sender).KeyPreset ;
      ProcessKey;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.InitializeCWClientData
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CWIndex : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.InitializeCWClientData(CWIndex : integer);
const
  INVALID_TRANSNO = -1;
begin
  if ((CWIndex <= 0) and (CWIndex < MAX_CWCLIENTS)) then
  begin
    CWClientData[CWIndex].TransNo                 := INVALID_TRANSNO;
    CWClientData[CWIndex].LastUsedTime            := Now();
    CWClientData[CWIndex].CWAccessType            := 0;
    CWClientData[CWIndex].Authorized              := 0;
    CWClientData[CWIndex].CWPLUNo                 := 0;
    CWClientData[CWIndex].CWAccessCode            := '';
    CWClientData[CWIndex].CWDaysToExpire          := 0;
    CWClientData[CWIndex].CarwashInterfaceState   := 0;
    CWClientData[CWIndex].KeyPadID                := mKeyPadUnknown;
    CWClientData[CWIndex].bPressedYes             := False;
    CWClientData[CWIndex].FieldToken              := 0;
    CWClientData[CWIndex].BuffPtr                 := 0;
    CWClientData[CWIndex].PrevField               := 0;
    CWClientData[CWIndex].sKeyType                := '';
    CWClientData[CWIndex].sKeyVal                 := '';
    CWClientData[CWIndex].sPreset                 := '';
    CWClientData[CWIndex].RespAllowed             := '';
    CWClientData[CWIndex].RespAuthCode            := '';
    CWClientData[CWIndex].RespAuthMsg             := '';
    CWClientData[CWIndex].RespPrintLine1          := '';
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.FormCreate(Sender: TObject);
const
  INVALID_TRANSNO = -1;
var
  j : integer;
begin
  for j := 0 to MAX_CWClientS - 1 do
  begin
    InitializeCWClientData(j);
  end;
  CWClientIndex := DEFAULT_CCINDEX;
  if screen.width > 800 then
  begin
    fmCWAccessForm.ElasticForm1.DesignScreenWidth := 1024;
    fmCWAccessForm.ElasticForm1.DesignScreenHeight:= 786;
    fmCWAccessForm.Left := 169;
    fmCWAccessForm.Top  := 291;
  end
  else
  begin
    fmCWAccessForm.ElasticForm1.DesignScreenWidth := 800;
    fmCWAccessForm.ElasticForm1.DesignScreenHeight:= 600;
    fmCWAccessForm.Left := 123;
    fmCWAccessForm.Top  := 243;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.CWTimeOutTimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.CWTimeOutTimerTimer(Sender: TObject);
begin
  CarwashInterfaceState := CI_HANDLE_TIMEOUT;
  PutCWClientVar();
  PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, 0);
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.GetCWClientVar
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.GetCWClientVar();
var
  q : ^TCWClientData;
begin
  q := @(CWClientData[GetCWClientIndex()]);
  if (KeyPadID <> q^.KeyPadID) then
    begin
      KeyPadID            := q^.KeyPadID;
      case KeyPadID of
        mKeyPadClear           : SetClearPad();
        mKeyPadNumber          : SetNumberPad();
        mKeyPadCWSelect        : SetCWSelectPad();
        mKeyPadYesNo           : SetYesNoPad();
      end;
    end;
  bPressedYes         := q^.bPressedYes;
  BuffPtr             := q^.BuffPtr;
  PrevField           := q^.PrevField;
  sKeyType            := q^.sKeyType;
  sKeyVal             := q^.sKeyVal;
  sPreset             := q^.sPreset;
  RespAllowed         := q^.RespAllowed;
  RespAuthCode        := q^.RespAuthCode;
  RespAuthMsg         := q^.RespAuthMsg;
  RespPrintLine1      := q^.RespPrintLine1;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.PutCWClientVar
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.PutCWClientVar();
var
  q : ^TCWClientData;
begin
  q := @(CWClientData[GetCWClientIndex()]);
  q^.KeyPadID            := KeyPadID;
  q^.bPressedYes         := bPressedYes;
  q^.FieldToken          := FieldToken;
  q^.BuffPtr             := BuffPtr;
  q^.PrevField           := PrevField;
  q^.sKeyType            := sKeyType;
  q^.sKeyVal             := sKeyVal;
  q^.sPreset             := sPreset;
  q^.RespAllowed         := RespAllowed;
  q^.RespAuthCode        := RespAuthCode;
  q^.RespAuthMsg         := RespAuthMsg;
  q^.RespPrintLine1      := RespPrintLine1;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.GetCWClientIndex
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    integer
  Purpose:   
-----------------------------------------------------------------------------}
function TfmCWAccessForm.GetCWClientIndex() : integer;
// Determine the index into the credit card client data (CWClientData[]) to use.
var
  LeastRecentIndex : integer;
  LeastRecentTime : TTime;
  j : integer;
  Found : boolean;
begin
  // Search for the current transaction number represented in the credit card client data.
  // If not found, then use the index of the least recently used data.
  LeastRecentIndex := 0;
  LeastRecentTime := CWClientData[LeastRecentIndex].LastUsedTime;
  Found := False;
  for j := 0 to MAX_CWClientS - 1 do
    begin
      if ((CWClientData[j].TransNo       = FCurrentTransNo) and
          (CWClientData[j].CWAccessType = FCWAccessType )    ) then
        begin
          Found := True;
          break;
        end
      else if (CWClientData[j].LastUsedTime < LeastRecentTime) then
        begin
          LeastRecentIndex := j;
          LeastRecentTime := CWClientData[LeastRecentIndex].LastUsedTime;
        end;
    end;
  if (Found) then
    begin
      GetCWClientIndex := j;
    end
  else
    begin
      InitializeCWClientData(LeastRecentIndex);
      //CWClientData[LeastRecentIndex].KeyPadID := mKeyPadUnknown;
      GetCWClientIndex := LeastRecentIndex;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetAuthorized
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetAuthorized(Value : integer);
begin
  FAuthorized := Value;
  CWClientData[CWClientIndex].Authorized := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCWPLUNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCWPLUNo(Value : integer);
begin
  FCWPLUNo := Value;
  CWClientData[CWClientIndex].CWPLUNo := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCWAccessCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCWAccessCode(Value : string);
begin
  FCWAccessCode := Value;
  CWClientData[CWClientIndex].CWAccessCode := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCWDaysToExpire
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCWDaysToExpire(Value : integer);
begin
  FCWDaysToExpire := Value;
  CWClientData[CWClientIndex].CWDaysToExpire := Value;
end;
//...cwf


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCarwashInterfaceState
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCarwashInterfaceState(Value : short);
begin
  FCarwashInterfaceState := Value;
  CWClientData[CWClientIndex].CarwashInterfaceState := Value;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.SetCWClientData
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const NewTransNo : integer; const NewCWAccessType : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.SetCWClientData(const NewTransNo : integer; const NewCWAccessType : integer);
begin
  if ((NewTransNo <> FCurrentTransNo) or (NewCWAccessType <> FCWAccessType)) then
    begin
      FCurrentTransNo := NewTransNo;
      FCWAccessType  := NewCWAccessType;
      CWClientIndex := GetCWClientIndex();
      CWClientData[CWClientIndex].TransNo       := FCurrentTransNo;
      CWClientData[CWClientIndex].CWAccessType := FCWAccessType;
      CWClientData[CWClientIndex].LastUsedTime := Now();
      FAuthorized := CWClientData[CWClientIndex].Authorized;
      FCWPLUNo := CWClientData[CWClientIndex].CWPLUNo;
      FCWAccessCode := CWClientData[CWClientIndex].CWAccessCode;
      FCWDaysToExpire := CWClientData[CWClientIndex].CWDaysToExpire;
      FCarwashInterfaceState := CWClientData[CWClientIndex].CarwashInterfaceState;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.VoidCarwashCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const AuthCode : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.VoidCarwashCode(const AuthCode : string);
var
  CWMsg : string;
begin
  CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_VOID_CODE_REQUEST)) +
           BuildTag(CWTAG_ACCESS_CODE, AuthCode);
  fmPOS.SendCarwashMessage(CWMsg);
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.FormShow(Sender: TObject);
begin
  if Initialize then InitializeScreen;
  Initialize := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCWAccessForm.InitializeScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCWAccessForm.InitializeScreen;
begin
  GetCWClientVar();
  CWTimeOutTimer.Enabled := False;
  case fmPOS.POSScreenSize of
  1 :
    begin
      fmCWAccessForm.Left := 169;
      fmCWAccessForm.Top  := 291;
    end;
  2 :
    begin
      fmCWAccessForm.Left := 123;
      fmCWAccessForm.Top  := 243;
    end;
  end;

  BuildTouchPad;
  ResetLabels;
  SetCWSelectPad();

  bVoidDuring := False;


  lStatus.Visible := False;
  lStatus.Caption := '';
  BuffPtr := 0;
  // If carwash product (PLU) has already been selected, then request access code from carwash server;
  // otherwise, request product from clerk.
  if (CarwashInterfaceState = CI_BUILD_CODE_REQUEST) then
    begin
      FieldToken := 0;
      PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, 0);
    end
  else
    begin
      FieldToken := FT_ACCESS_CODE;
    end;
  SetActiveField;
  PutCWClientVar();
end;


end.

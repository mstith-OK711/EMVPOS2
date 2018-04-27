unit GiftForm;

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
type
  TGiftFormMode = (gfmInquiry, gfmActivation);

  TfmGiftForm = class(TForm)
    lStatus: TPanel;
    ElasticForm1: TElasticForm;
    AuthTimeOutTimer: TTimer;
    lPinPadStatus: TPanel;
    leCardNo: TPOSLabeledEdit;
    leRestrictionCode: TPOSLabeledEdit;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure AuthTimeOutTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tpleEnter(Sender: TObject);
    procedure tpleExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FMode : TGiftFormMode;
    gd : pGiftCardData;

    EntryType : string;
    FVCI                     : pValidCardInfo;
    POSButtonsGift    : array[1..15] of TPOSTouchButton;

    procedure InitialScreen();
    procedure ProcessVCI();
    procedure SendBalanceInquiry();

    procedure BuildTouchPad;
    procedure BuildKeyPad(RowNo, ColNo, BtnNdx : short );

    procedure SetClearPad;
    procedure SetNumberPad;
    procedure SetYesNoPad();
{$IFDEF DISABLEDPADS}
    procedure SetEnterClearPad;
{$ENDIF}

    procedure ProcessBalanceResp(const msg : widestring);
    procedure PrintBalance();
  public
    { Public declarations }
    Initialize : Boolean;

    procedure CCButtonClick(Sender: TObject);
    procedure ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string);
    procedure ResetLabels;
    procedure ScrubForm;
    procedure PPAuthInfoReceived(      Sender        : TObject;
                                 const PinPadAmount  : currency;
                                 const PinPadMSRData : string;
                                 const PINBlock      : string;
                                 const PINSerialNo   : string);
    procedure ProcessCreditMsg(const msg : widestring);

    procedure VCIReceived(const pVCI : pValidCardInfo);
    procedure ClearCardInfo();
    property Mode : TGiftFormMode read FMode write FMode;
  end;

var
  fmGiftForm: TfmGiftForm;

implementation

uses POSDM, POSLog, POSErr, ExceptLog, POSMisc, PinPad, POSUser, GiftFuelDiscount, StrUtils, POSPrt;

{$R *.DFM}

var
  debugmode : boolean = false;

  Keytops      : array[1..15] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', '', '0', '', 'C', 'B', 'E');

procedure TfmGiftForm.SendBalanceInquiry();
var
  CCMsg : widestring;
  GiftRestrictionCode : integer;
begin
  if (FVCI^.bDebitBINMngt and (FVCI^.CardType = CT_GIFT)) then
    GiftRestrictionCode := RC_ONLY_FUEL
  else if (fmPOS.bGiftRestrictions) then
    GiftRestrictionCode := RC_UNKNOWN  // will be determined by credit host
  else
    GiftRestrictionCode := RC_NO_RESTRICTION;
  CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_AUTHCARD)) +
           BuildTag(TAG_ENTRYTYPE, Self.EntryType) +
           BuildTag(TAG_AUTHAMOUNT, '0.00') +
           BuildTag(TAG_CARDTYPE, FVCI^.CardType) +
           BuildTag(TAG_CARDNO, FVCI^.CardNo) +
           BuildTag(TAG_EXPDATE, FVCI^.ExpDate) +
           BuildTag(TAG_TRACK1DATA, FVCI^.Track1Data) +
           BuildTag(TAG_TRACK2DATA, FVCI^.Track2Data) +
           BuildTag(TAG_RESTRICTION_CODE, IntToStr(GiftRestrictionCode)) +
           BuildTag(TAG_TRANSNO,  '70707');
  if FVCI^.bGetPIN then
    CCMsg := CCMsg + BuildTag(TAG_SERIALNUMBER, FVCI^.PinKSN) + BuildTag(TAG_PINBLOCK, FVCI^.PinBlock);
  Self.lStatus.Visible := True;
  if not debugmode then
  begin
    AuthTimeOutTimer.Interval := 60000;
    AuthTimeOutTimer.Enabled := True;
  end;
  fmPOS.SendCreditMessage(CCMsg);
end;

procedure TfmGiftForm.VCIReceived(const pVCI : pValidCardInfo);
begin
  if not assigned(Self.FVCI) then
  begin
    new(Self.FVCI);
    UpdateZLog('TfmGiftForm.VCIReceived');
    // copy reference counted strings over so we don't lose the ref counts when pVCI is disposed of later
    FVCI^ := pVCI^;
    Self.ProcessVCI();
  end
  else
    UpdateZLog('TfmGiftForm.VCIReceived - FIXME: How should we handle cardswipes while we''ve already got one in memory?');
end;

procedure TfmGiftForm.ClearCardInfo();
begin
  UpdateZLog('TfmGiftForm.ClearCardInfo');
  ScrubForm;
  if assigned (Self.FVCI) then
    dispose(Self.FVCI);
  Self.FVCI := nil;
  if assigned(Self.gd) then
    dispose(Self.gd);
  Self.gd := nil;
end;

  
{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmGiftForm.ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string);
begin
  if sKeyType = 'CLR' then
  begin
    if Self.ActiveControl is TPOSLabeledEdit then
    begin
      with TPOSLabeledEdit(Self.ActiveControl) do
        if Text = '' then
          if Self.ActiveControl = Self.leCardNo then
            close
          else
            Self.SelectNext(Self.ActiveControl, False, True)
        else
          Text := '';
    end
    else
      Close();
  end
  else if sKeyType = 'NAY' then
    close()
  else if sKeyType = 'YEA' then
    PrintBalance()
  else if sKeyType = 'BSP' then
    PostMessage(Self.ActiveControl.Handle, WM_KEYDOWN, VK_BACK, 0)
  else if sKeyType = 'NUM' then
  begin
    if (Self.ActiveControl = Self.leCardNo) and (EntryType <> 'M') then
      EntryType := 'M';
    PostMessage(Self.ActiveControl.Handle, WM_KEYDOWN, ord(sKeyVal[1]), 0);
  end
  else if sKeyType = 'ENT' then
  begin
    if Self.ActiveControl is TPOSLabeledEdit and (length(TPOSLabeledEdit(Self.ActiveControl).Text) > 0) then
      fmPOS.QueryValidCard(VC_RET_GIFT_PROCESSKEY,'','', Self.leCardNo.Text, '1249', 'M')
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
    fmPOS.ProcessKeyPHL;
end;


procedure TfmGiftForm.ProcessCreditMsg(const msg : widestring);
var
  Action : integer;
begin
  UpdateZLog('TfmGiftForm.ProcessCreditMsg: %s', [DeformatCreditMsg(Msg)]);
  Action :=  StrToIntDef(GetTagData(TAG_MSGTYPE, Msg), 0);
  case Action of
   CC_AUTHRESP : begin end;  // ignore this
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
   CC_BALANCERESP : ProcessBalanceResp(msg);
  else
    UpdateZLog('TfmGiftForm.ProcessCreditMsg - unhandled message');
  end;
end;

procedure TfmGiftForm.ScrubForm;
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
  Name:      TfmGiftForm.ResetLabels
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.ResetLabels;
begin
  ScrubForm;

  lStatus.Caption := '';

  if assigned(POSButtonsGift[15]) then
  begin
    POSButtonsGift[15].KeyType   := 'ENT';
    POSButtonsGift[15].KeyVal := '';
    POSButtonsGift[15].Caption := 'Enter';
  end;

  Self.leCardNo.Visible := True;
  Self.leCardNo.Editable := True;

  Self.ActiveControl := Self.leCardNo;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AuthTimeOutTimer.Enabled := False;
  ClearCardInfo;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.BuildTouchPad;
var
nRowNo : short;
nColNo : short;
nBtnNo : short;

begin
  UpdateZLog('TfmGiftForm.BuildTouchPad - enter');
  nBtnNo := 1;
  for nRowNo := 1 to 5 do
    for nColNo := 1 to 3 do
    begin
      BuildKeyPad(nRowNo, nColNo, nBtnNo );
      Inc(nBtnNo);
    end;
  SetNumberPad;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.BuildkeyPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.BuildkeyPad(RowNo, ColNo, BtnNdx : short );
var
TopKeyPos : short;

begin
  if screen.width = 800 then
    TopKeyPos := 48
  else
    TopKeyPos := 64;
  if POSButtonsGift[BtnNdx] = nil then
  begin
    POSButtonsGift[BtnNdx]         := TPOSTouchButton.Create(fmGiftForm);

    POSButtonsGift[BtnNdx].Parent  := fmGiftForm;
    POSButtonsGift[BtnNdx].Name    := 'GiftButton' + IntToStr(BtnNdx);
  end;

  if (screen.Width = 1024) then
  begin
    POSButtonsGift[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 65);
    POSButtonsGift[BtnNdx].Left     := ((ColNo - 1) * 65) + 500;
    POSButtonsGift[BtnNdx].Height     := 60;
    POSButtonsGift[BtnNdx].Width      := 60;
    POSButtonsGift[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  end
  else
  begin
    POSButtonsGift[BtnNdx].Top     := TopKeyPos + ((RowNo - 1) * 50);
    POSButtonsGift[BtnNdx].Left     := ((ColNo - 1) * 50) + 375;
    POSButtonsGift[BtnNdx].Height     := 47;
    POSButtonsGift[BtnNdx].Width      := 47;
    POSButtonsGift[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
  end;
  POSButtonsGift[BtnNdx].KeyRow     := RowNo;
  POSButtonsGift[BtnNdx].KeyCol     := ColNo;
  POSButtonsGift[BtnNdx].Visible    := True;
  POSButtonsGift[BtnNdx].OnClick    := CCButtonClick;
  POSButtonsGift[BtnNdx].KeyCode    := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtonsGift[BtnNdx].FrameStyle := bfsNone;
  POSButtonsGift[BtnNdx].WordWrap   := True;
  POSButtonsGift[BtnNdx].Tag        := BtnNdx;
  POSButtonsGift[BtnNdx].NumGlyphs  := 14;
  POSButtonsGift[BtnNdx].Frame      := 8;
  POSButtonsGift[BtnNdx].KeyPreset  := '';
  POSButtonsGift[BtnNdx].MaskColor  := fmGiftForm.Color;

  POSButtonsGift[BtnNdx].Font.Color :=  clBlack;
  POSButtonsGift[BtnNdx].Frame := 11;

  (*case BtnNdx of
  (*15 :
      begin
        POSButtonsGift[BtnNdx].KeyType   := 'ENT';
        POSButtonsGift[BtnNdx].KeyVal := '';
        POSButtonsGift[BtnNdx].Caption := 'Enter';
      end;
  14 :
      begin
        POSButtonsGift[BtnNdx].KeyType   := 'BSP';
        POSButtonsGift[BtnNdx].KeyVal := '';
        POSButtonsGift[BtnNdx].Caption := 'Back Space';
      end;
  13 :
      begin
        POSButtonsGift[BtnNdx].KeyType   := 'CLR';
        POSButtonsGift[BtnNdx].KeyVal := '';
        POSButtonsGift[BtnNdx].Caption := 'Clear';
      end;
  10, 12 :
      begin
        POSButtonsGift[BtnNdx].KeyType   := '';
        POSButtonsGift[BtnNdx].KeyVal := '';
        POSButtonsGift[BtnNdx].Caption := '';
        POSButtonsGift[BtnNdx].Visible  := False;
      end;
  else
    begin
      POSButtonsGift[BtnNdx].KeyType := 'NUM - Number';
      POSButtonsGift[BtnNdx].KeyVal  := KeyTops[BtnNdx];
      POSButtonsGift[BtnNdx].Caption  := KeyTops[BtnNdx];
    end;
  end;*)
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.SetNumberPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.SetNumberPad;
var
BtnNdx : short;
begin
  for BtnNdx := 1 to 15 do
  begin
    case BtnNdx of
      15 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'ENT';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Enter';
          end;
      14 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'BSP';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Back Space';
          end;
      13 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'CLR';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Clear';
          end;
      10, 12 :
          begin
            POSButtonsGift[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSButtonsGift[BtnNdx].Visible  := True;
          POSButtonsGift[BtnNdx].KeyType  := 'NUM - Number';
          POSButtonsGift[BtnNdx].KeyVal   := KeyTops[BtnNdx];
          POSButtonsGift[BtnNdx].Caption  := KeyTops[BtnNdx];
        end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.SetYesNoPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.SetYesNoPad();
var
BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
    begin
      case BtnNdx of
      1 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'YEA';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Yes';
          end;
      3 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'NAY';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'No';
          end;
      10, 12 :
          begin
            POSButtonsGift[BtnNdx].Visible  := False;
          end;
      else
        begin
          POSButtonsGift[BtnNdx].Visible  := False;
        end;
      end;
    end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.SetClearPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.SetClearPad;
var
  BtnNdx : short;
begin

  for BtnNdx := 1 to 15 do
  try
    case BtnNdx of
    5 :
        begin
          POSButtonsGift[BtnNdx].Visible := True;
          POSButtonsGift[BtnNdx].KeyType   := 'CLR';
          POSButtonsGift[BtnNdx].KeyVal := '';
          POSButtonsGift[BtnNdx].Caption := 'Clear';
        end;
    10, 12 :
        begin
          POSButtonsGift[BtnNdx].Visible  := False;
        end;
    else
      begin
        POSButtonsGift[BtnNdx].Visible  := False;
      end;
    end;
  except
    on E: Exception do
      UpdateExceptLog('TfmGiftForm.SetClearPad BtnNdx %d - Exception %s - %s', [BtnNdx, E.ClassName, E.Message]);
  end;
end;

{$IFDEF DISABLEDPADS}
procedure TfmGiftForm.SetEnterClearPad;
var
BtnNdx : short;
begin
  for BtnNdx := 1 to 15 do
  begin
    case BtnNdx of
      15 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'ENT';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Enter';
          end;
      13 :
          begin
            POSButtonsGift[BtnNdx].Visible := True;
            POSButtonsGift[BtnNdx].KeyType   := 'CLR';
            POSButtonsGift[BtnNdx].KeyVal := '';
            POSButtonsGift[BtnNdx].Caption := 'Clear';
          end;
      else
          begin
            POSButtonsGift[BtnNdx].Visible  := False;
          end;
    end;
  end;
end;
{$ENDIF}

{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.CCButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmGiftForm.CCButtonClick(Sender: TObject);
var
  sKeyType, sKeyVal, sPreset : string;
begin

  if (Sender is TPOSTouchButton) then
    begin
      sKeyType := TPOSTouchButton(Sender).KeyType ;
      sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
      sPreset  := TPOSTouchButton(Sender).KeyPreset ;
      UpdateZLog('GiftForm.CCButtonClick - keytype %s', [sKeyType]);
      ProcessKey(leftstr(sKeyType,3), sKeyVal, sPreset);
    end;
  //20050126
  FormClick(self);
end;

{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.FormCreate(Sender: TObject);
begin
  Self.Initialize := True;
  Self.lPinPadStatus.Caption := '';
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.AuthTimeOutTimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.AuthTimeOutTimerTimer(Sender: TObject);
begin
    //53g...
//    CreditAuthToken := 200;
    //CreditAuthToken := CA_HANDLE_TIMEOUT;
    //...53g
    PostMessage(fmGiftForm.Handle, WM_CREDITMSG, 0, 0);
  AuthTimeOutTimer.Enabled := False;
  UpdateExceptLog('Auth timed out');
end;

procedure TfmGiftForm.ProcessVCI();
var
  i : integer;
begin
  UpdateZLog('TfmGiftForm.ProcessVCI - CardSource: %s', [CardSourceToText(FVCI^.cardsource)]);
  Self.ActiveControl := nil;
  for i := 0 to pred(Self.ControlCount) do
    if Self.Controls[i] is TPOSLabeledEdit then
      TPOSLabeledEdit(Self.Controls[i]).Editable := False;
  Self.leCardNo.Text := FVCI^.CardNo;
  Self.leCardNo.Editable := False;
  Self.SetClearPad;
  if FVCI^.bGetPIN then
  begin
    if assigned(fmPOS.PPTrans) and fmPOS.PPTrans.PinPadOnLine and fmPOS.PPTrans.Enabled then
    begin
      UpdateZLog('TfmGiftForm.ProcessVCI - Sending information to PINPad');
      fmPOS.PPTrans.SendPINRequest(FVCI^.CardNo);
    end;
  end
  else
    Self.SendBalanceInquiry;
end;

{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.FormShow(Sender: TObject);
begin
  if Initialize then InitialScreen();
  Initialize := False;
  ResetLabels;
  SetNumberPad;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftForm.InitialScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftForm.InitialScreen();
begin
  UpdateZLog('TfmGiftForm.InitialScreen - enter');
  AuthTimeOutTimer.Enabled := False;
  BuildTouchPad;
  ResetLabels;
  SetNumberPad;

  lStatus.Visible := False;
  lStatus.Caption := '';

end;

procedure TfmGiftForm.FormClick(Sender: TObject);
begin
  if fmPOSErrorMsg.Visible then
    SetActiveWindow(fmPOSErrorMsg.Handle);
end;

procedure TfmGiftForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  blockaltf4 : boolean;
begin
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
      fmPOS.POSError('Have you called support?');
    end;
  end;
  if (Key = VK_F7) and (ssAlt in Shift) then
  begin
    UpdateZLog('%s: User pressed Alt-F7 - Closing', [Self.ClassName]);
    Self.ClearCardInfo;
    Close();
  end;
  if (Self.ActiveControl = Self.leCardNo) and (Key >= 48) and (Key <= 57) then
    Self.EntryType := 'M';
end;

procedure TfmGiftForm.tpleEnter(Sender: TObject);
begin
  if Sender is TPOSLabeledEdit then
    with TPOSLabeledEdit(Sender) do
      Color := clMoneyGreen;
end;

procedure TfmGiftForm.tpleExit(Sender: TObject);
begin
  if Sender is TPOSLabeledEdit then
    with TPOSLabeledEdit(Sender) do
      Color := clWhite;
end;

procedure TfmGiftForm.FormActivate(Sender: TObject);
begin
  Self.SetBounds((Screen.Width - Self.Width) div 2, Screen.Height - Self.Height, Self.Width, Self.Height);
end;

procedure TfmGiftForm.ProcessBalanceResp(const msg: widestring);
var
  RespAuthCode, RespBalance, RespRestrictionCode : string;
  qSalesData : pSalesData;
begin
  AuthTimeOutTimer.Enabled := False;
  RespAuthCode := GetTagData(TAG_AUTHCODE, Msg);
  if RespAuthCode = AC_APPROVAL then
  begin
    UpdateZLog('ProcessBalanceResp CardType = "%s"', [FVCI^.CardType]);
    if (FVCI^.CardType = CT_EBT_FS) or (FVCI^.CardType = CT_EBT_FS) then
    begin
      new(qSalesData);
      ZeroMemory(qSalesData, sizeof(TSalesData));
      qSalesData^.CCBalance1 := -2;
      qSalesData^.CCBalance2 := -2;
      qSalesData^.CCBalance3 := UNKNOWN_BALANCE;
      qSalesData^.CCBalance4 := UNKNOWN_BALANCE;
      qSalesData^.CCBalance5 := UNKNOWN_BALANCE;
      qSalesData^.CCBalance6 := UNKNOWN_BALANCE;
      try
        //qSalesData^.CCBalance1      := GetTagData(TAG_BALANCE, Msg, True);
        qSalesData^.CCBalance1      := StrToCurrDef(GetTagData(TAG_BALANCE, Msg), UNKNOWN_BALANCE);
      except;
      end;
      try
        qSalesData^.CCBalance2      := StrToCurrDef(GetTagData(TAG_BALANCE_2, Msg), UNKNOWN_BALANCE);
      except;
      end;
      try
        qSalesData^.CCBalance3      := StrToCurr(GetTagData(TAG_BALANCE_3, Msg, True));
      except;
      end;
      try
        qSalesData^.CCBalance4      := StrToCurr(GetTagData(TAG_BALANCE_4, Msg, True));
      except;
      end;
      try
        qSalesData^.CCBalance5      := StrToCurr(GetTagData(TAG_BALANCE_5, Msg, True));
      except;
      end;
      try
        qSalesData^.CCBalance6      := StrToCurr(GetTagData(TAG_BALANCE_6, Msg, True));
      except;
      end;
      if PrintEBTBalance(qSalesData) then
        PrintSeq();
      Dispose(qSalesData);
      Close();
    end
    else
    begin
      RespBalance := GetTagData(TAG_BALANCE, Msg);
      RespRestrictionCode := GetTagData(TAG_RESTRICTION_CODE, Msg);
      lStatus.Caption := Format('Balance:  $%s   Restriction = %s.  Print?', [RespBalance, RespRestrictionCode]);
      new(Self.gd);
      gd^.FaceValue := StrToCurrDef(RespBalance, 0);
      gd^.PriorValue := gd^.FaceValue;
      gd^.RestrictionCode := StrToIntDef(RespRestrictionCode, 0);
      gd^.CardStatus := CS_STILL_ACTIVE;
      strPcopy(gd^.CardNo, copy(FVCI^.Cardno, 1,  Min(Length(FVCI^.Cardno), SIZE_CARDNO-1)));
      SetYesNoPad();
    end;
  end
  else
  begin
    Self.FormStyle := fsNormal;
    fmPOS.POSError(GiftAuthCodeToStr(RespAuthCode));
    Self.FormStyle := fsStayOnTop;
    Close;
  end;
end;

procedure TfmGiftForm.PrintBalance;
var
  GiftCardList : TList;
begin
  GiftCardList := TList.Create();
  GiftCardList.Add(Self.gd);
  PrintGiftCardBalance(@GiftCardList, '', '');
  // print disposes of gd
  Self.gd := nil;
  GiftCardList.Destroy;
  close();
end;

procedure TfmGiftForm.PPAuthInfoReceived(      Sender        : TObject;
                                         const PinPadAmount  : currency;
                                         const PinPadMSRData : string;
                                         const PINBlock      : string;
                                         const PINSerialNo   : string);
begin
  UpdateZLog('TfmGiftForm.PPAuthInfoReceived  %g', [PinPadAmount]);
  if (PinPadAmount <> 0) then
  begin
    if assigned(FVCI) then
    try
      Self.FVCI^.PinBlock := PINBlock;
      Self.FVCI^.PinKSN := PinSerialNo;
    except
      on E: Exception do
      begin
        UpdateZLog('TfmGiftForm.ProcessCredit - %s - %s', [E.ClassName, E.Message]);
        UpdateExceptLog('TfmGiftForm.ProcessCredit - %s - %s', [E.ClassName, E.Message]);
        DumpTraceBack(E,5);
      end;
    end;
    Self.SendBalanceInquiry;
  end
  else
  begin
    fmPOS.POSError('Customer Rejected Request');
    self.Close();
  end;
end;


end.


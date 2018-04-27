program Latitude;


uses
  {$IFNDEF USEMEMCHK}
  FastMM4Messages in '..\lib\FastMM\FastMM4Messages.pas',
  FastMM4 in '..\lib\FastMM\FastMM4.pas',
  {$ENDIF}
  {$IFDEF USEMEMCHK}
  MemCheck in '..\lib\MemCheck.pas',
  {$ENDIF}
  AESEx in 'AESEx.pas',
  CCRecpt in 'Ccrecpt.pas' {fmCardReceipt},
  Classes,
  Clock in 'Clock.pas' {fmClockInOut},
  CloseDay in 'Closeday.pas',
  CWAccess in 'CWAccess.pas' {fmCWAccessForm},
  Dialogs,
  EnterAge in 'EnterAge.pas' {fmEnterAge},
  FactorEx in 'FactorEx.pas',
  FactorImport in 'FactorImport.pas',
  Forms,
  FuelPric in 'FuelPric.pas' {fmChangeFuelPrice},
  FuelRcpt in 'FuelRcpt.pas' {fmFuelReceipt},
  FuelSel in 'FuelSel.pas' {fmFuelSelect},
  GetAge in 'GetAge.pas' {fmValidAge},
  Mainmenu in 'Mainmenu.pas' {POSMenu},
  MedRestrict in 'MedRestrict.pas',
  Messages,
  NACSEx in 'NACSEx.pas',
  NBSCC in 'NBSCC.pas' {fmNBSCCForm},
  OldRecpt in 'OldRecpt.pas' {fmOldReceipt},
  PDIEx in 'PDIEx.pas',
  PDIImport in 'PDIImport.pas',
  PluRpt in 'Plurpt.pas' {fmPLUSalesReport},
  PLUSearch in 'PLUSearch.pas' {frmPLULookup},
  PopMsg in 'PopMsg.pas' {fmPopUpMsg},
  POSDM in 'POSDM.pas' {POSDataMod: TDataModule},
  POSErr in 'POSErr.pas' {fmPOSErrorMsg},
  POSLog in 'POSLog.pas',
  ReceiptSrvrEvents in '..\POSTools\ReceiptSrvrEvents.pas',
  POSMain in 'POSMain.pas' {fmPOS},
  POSMsg in 'POSMsg.pas' {fmPOSMsg},
  POSPole in 'POSPole.pas',
  POSPost in 'POSPost.pas',
  POSPrt in 'POSPrt.pas',
  PosUser in 'PosUser.pas' {fmUser},
  PriceCheck in 'PriceCheck.pas' {fmPriceCheck},
  PriceOverride in 'PriceOverride.pas' {fmPriceOverride},
  PriceSgn in 'PriceSgn.pas',
  PumpInfo in 'PumpInfo.pas' {fmPumpInfo},
  PumpOnOf in 'PumpOnOf.pas' {fmPumpOnOff},
  Receipt in 'Receipt.pas',
  Reports in 'Reports.pas',
  SelTermShift in 'SelTermShift.pas' {fmSelectTermShift},
  StartingTill in 'StartingTill.pas' {fmStartingTill},
  SysMgrImport in 'SysMgrImport.pas',
  SysUtils,
  TermNo in 'TermNo.pas' {fmSetTerminal},
  ViewRpt in 'ViewRpt.pas' {fmViewReport},
  Windows,
  Sounds in 'Sounds.pas',
  Kiosk in 'Kiosk.pas' {KioskFrame: TFrame},
  KioskForm in 'KioskForm.pas' {fmKiosk},
  SelectSuspend in 'SelectSuspend.pas' {fmSuspend},
  GiftFuelDiscount in 'GiftFuelDiscount.pas',
  Inventory in 'Inventory.pas' {fmInventoryInOut},
  SnowBirdEx in 'SnowBirdEx.pas',
  Encrypt in 'Encrypt.pas',
  PumpxIcon in 'PumpxIcon.pas',
  MOStat in 'MOStat.pas' {fmMO},
  MOLoad in 'MOLoad.pas' {fmMOLoad},
  MOInq in 'MOInq.pas' {fmMOInq},
  MODocNo in 'MODocNo.pas' {MODocEntry},
  CardActivation in 'CardActivation.pas',
  PosThreads in 'PosThreads.pas',
  Scanner in 'Scanner.pas',
  ExceptLog in '..\lib\ExceptLog.pas',
  PINPadTrans in 'PINPadTrans.pas',
  LoadFileBuffer in 'LoadFileBuffer.pas',
  IngSig in '..\lib\IngSig.pas',
  SigVerify in 'SigVerify.pas' {frmSigVerify},
  LatTypes in 'LatTypes.pas',
  PinPadStatus in 'PinPadStatus.pas',
  AdManage in 'AdManage.pas' {AdManageMod: TDataModule},
  IBEvents in '..\lib\IB\IBEvents.pas',
  NotifyReg in '..\lib\NotifyReg.pas',
  MSR in 'MSR.pas',
  PumpLockSup in '..\lib\PumpLockSup.pas',
  PumpLockMgr in 'PumpLockMgr.pas',
  LatTaxes in 'LatTaxes.pas',
  GiftForm in 'GiftForm.pas' {fmGiftForm},
  PTVerify in 'PTVerify.pas' {frmPTVerify},
  PPEntryPrompt in 'PPEntryPrompt.pas' {fmPPEntryPrompt},
  RptUtils in '..\lib\RptUtils.pas',
  TagTCPClient in '..\lib\TagTCPClient.pas',
  LatConst in 'LatConst.pas',
  hScales in 'hScales.pas',
  ScaleWeight in 'ScaleWeight.pas' {ScaleWeightFrm};

{fmInventorySelect}

{$R *.RES}


{$R LatitudeVer.RES}

const
  WM_STARTPOS = WM_USER + 200;


var
  singlemutex      : THandle;

procedure CreateForm(InstanceClass: TComponentClass; var Reference);
begin
  {$IFDEF DEBUG}
  UpdateExceptLog('Creating form %s', [InstanceClass.ClassName]);
  {$ENDIF}
  Application.CreateForm(InstanceClass, Reference);
end;

begin
  {$IFDEF USEMEMCHK}
  MemChk;
  {$ENDIF}
  singlemutex := CreateMutex(nil, True, 'com.ok7-eleven.delphi.store.Latitude');
  if (singlemutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin // the mutex is already locked, so we can't grab it.  dip out quietly
    UpdateExceptLog('Latitude is already running.  Refusing to do so again.');
  end
  else
  begin

    SetErrorMode(SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX);

    Application.Initialize;
    Application.Title := 'Latitude';

    CreateForm(TPOSDataMod, POSDataMod);
    CreateForm(TPOSMenu, POSMenu);
    CreateForm(TfmPOSMsg, fmPOSMsg);
    CreateForm(TfmEnterAge, fmEnterAge);
    CreateForm(TfrmPLULookup, frmPLULookup);
    CreateForm(TfmSetTerminal, fmSetTerminal);
    CreateForm(TfmViewReport, fmViewReport);
    CreateForm(TfmPOSErrorMsg, fmPOSErrorMsg);
    CreateForm(TfmPopUpMsg, fmPopUpMsg);
    CreateForm(TfmStartingTill, fmStartingTill);
    CreateForm(TfmSelectTermShift, fmSelectTermShift);
    CreateForm(TfmPumpInfo, fmPumpInfo);
    CreateForm(TfmUser, fmUser);
    CreateForm(TfmNBSCCForm, fmNBSCCForm);
    CreateForm(TfmPriceOverride, fmPriceOverride);
    CreateForm(TfmPriceCheck, fmPriceCheck);
    CreateForm(TfmCWAccessForm, fmCWAccessForm);
    CreateForm(TfmKiosk, fmKiosk);
    CreateForm(TfmSuspend, fmSuspend);
    CreateForm(TfmInventoryInOut, fmInventoryInOut);
    CreateForm(TfmMO, fmMO);
    CreateForm(TfmMOLoad, fmMOLoad);
    CreateForm(TfmMOInq, fmMOInq);
    CreateForm(TfrmSigVerify, frmSigVerify);
    CreateForm(TAdManageMod, AdManageMod);
    CreateForm(TfmGiftForm, fmGiftForm);
    CreateForm(TfrmPTVerify, frmPTVerify);
    CreateForm(TfmPPEntryPrompt, fmPPEntryPrompt);
    CreateForm(TMoDocEntry, MoDocEntry);
    CreateForm(TScaleWeightFrm, ScaleWeightFrm);
    fmPOSMsg.ShowMsg('Loading POS...', '');


    POSMenu.Show;
    fmPOSMsg.ShowMsg('Loading POS...', '');

    CreateForm(TfmValidAge, fmValidAge);
    CreateForm(TfmPOS, fmPOS);
    CreateForm(TfmFuelSelect, fmFuelSelect);
    CreateForm(TfmPLUSalesReport, fmPLUSalesReport);
    CreateForm(TfmOldReceipt, fmOldReceipt);
    CreateForm(TfmFuelReceipt, fmFuelReceipt);
    CreateForm(TfmPumpOnOff, fmPumpOnOff);
    CreateForm(TfmChangeFuelPrice, fmChangeFuelPrice);
    CreateForm(TfmCardReceipt, fmCardReceipt);
    fmPOSMsg.ShowMsg('Starting POS...', '');
    fmPOSMsg.Close;

    {$IFDEF DEBUG}UpdateExceptLog('Starting POS');{$ENDIF}
    PostMessage(POSMenu.Handle,WM_STARTPOS,0,0);

    Application.Run;

    if (singlemutex <> 0) then
      closehandle(singlemutex);
  end;
end.

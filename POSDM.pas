{-----------------------------------------------------------------------------
 Unit Name: POSDM
 Author:    Gary Whetton
 Date:      4/13/2004 4:04:35 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSDM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, DBTables, IBCustomDataSet, IBQuery, IBDatabase, IBSQL,
  RxMemDS, ADODB, JclHashMapsCustom, IBEvents, NotifyReg, IBStoredProc;

{.$DEFINE ASYNCEVENTNOT}

{$IFDEF ASYNCEVENTNOT}
const
  WM_IBNOTIFYMSG = WM_USER + 995;
{$ENDIF}

type
  TPOSDataMod = class(TDataModule)
    CCBatchSource: TDataSource;
    FuelTranSource: TDataSource;
    UserSource: TDataSource;
    PLUSource: TDataSource;
    AESImportQry: TQuery;
    AESData: TDatabase;
    IBDb: TIBDatabase;
    IBTransaction: TIBTransaction;
    IBPDITransaction: TIBTransaction;
    IBFuelPriceChangeQuery: TIBQuery;
    IBTaxTableQuery: TIBQuery;
    IBFuelTranQuery: TIBQuery;
    IBCCBatchQuery: TIBQuery;
    IBUserQuery: TIBQuery;
    IBActionQuery: TIBQuery;
    IBReportQuery: TIBQuery;
    IBReportQuery2: TIBQuery;
    IBPDIQuery: TIBQuery;
    IBTempQry1: TIBQuery;
    IBTempQuery: TIBQuery;
    IBTempQuery2: TIBQuery;
    IBEODQuery: TIBQuery;
    IBShiftQuery: TIBQuery;
    IBRestrictionQuery: TIBQuery;
    IBGradeQuery: TIBQuery;
    IBPrintQuery: TIBQuery;
    IBReceiptQuery: TIBQuery;
    IBModifierQuery: TIBQuery;
    IBPLUQuery: TIBQuery;
    IBPLUModQuery: TIBQuery;
    IBDeptQuery: TIBQuery;
    IBBankFuncQuery: TIBQuery;
    IBDiscQuery: TIBQuery;
    IBTotalsQuery: TIBQuery;
    IBNFPLUQuery: TIBQuery;
    IBPumpDefQuery: TIBQuery;
    IBMediaQuery: TIBQuery;
    IBKybdQuery: TIBQuery;
    IBMenuQuery: TIBQuery;
    IBShiftTransaction: TIBTransaction;
    IBDefaultTransaction: TIBTransaction;
    IBSetupTransaction: TIBTransaction;
    IBSetupQuery: TIBQuery;
    IBMixMatchQuery: TIBQuery;
    IBMixMatchTransaction: TIBTransaction;
    IBUserTransaction: TIBTransaction;
    IBLogSQL: TIBSQL;
    IBLogTransaction: TIBTransaction;
    IBPostTransaction: TIBTransaction;
    IBPostSQL: TIBSQL;
    IBFuelPriceChangeTransaction: TIBTransaction;
    IBFuelPriceUpdateSQL: TIBSQL;
    IBFuelPriceUpdateTransaction: TIBTransaction;
    IBReceiptTransaction: TIBTransaction;
    PLUMemTable: TRxMemoryData;
    IBEODTransaction: TIBTransaction;
    IBMenuTransaction: TIBTransaction;
    IBKybdTransaction: TIBTransaction;
    IBTempTrans2: TIBTransaction;
    IBTempTrans1: TIBTransaction;
    IBReportTransaction: TIBTransaction;
    IBBatchReportQuery: TIBQuery;
    IBBatchReportTransaction: TIBTransaction;
    IBReportTransaction2: TIBTransaction;
    IBPrintTransaction: TIBTransaction;
    IBExportQuery: TIBQuery;
    IBExportTransaction: TIBTransaction;
    IBTransactionMenuUpdate: TIBTransaction;
    IBQueryMenuUpdate: TIBQuery;
    IBXMDQry1: TIBQuery;
    IBXMDTrans: TIBTransaction;
    IBXMDQry2: TIBQuery;
    IBSecTrans: TIBTransaction;
    IBSecQry1: TIBQuery;
    IBKioskTrans: TIBTransaction;
    IBQryKiosk: TIBQuery;
    KioskConn: TADOConnection;
    KioskQry: TADOStoredProc;
    IBSuspendTrans: TIBTransaction;
    IBSuspendQry: TIBQuery;
    KioskOrderQry: TADOQuery;
    KioskCompleteQry: TADOStoredProc;
    IBSetPortQry: TIBQuery;
    IBSetPortTrans: TIBTransaction;
    IBInvTrans: TIBTransaction;
    IBInvQry: TIBQuery;
    IBInventoryTrans: TIBTransaction;
    IBQryInventory: TIBQuery;
    IBQryInventory2: TIBQuery;
    ThreadTrans: TIBTransaction;
    IBThreadConfigTrans: TIBTransaction;
    IBEvents: TIBEvents;
    IBAdTrans: TIBTransaction;
    DoEvent: TIBStoredProc;
    EventTran: TIBTransaction;
    IBSpTransNo: TIBStoredProc;
    IBRptTrans: TIBTransaction;
    IBRptSQL01Main: TIBSQL;
    IBRptSQL01Sub1: TIBSQL;
    IBRptSQL02Main: TIBSQL;
    IBRptSQL02Sub1: TIBSQL;
    IBRptSQL01Sub2: TIBSQL;
    IBRptSQL03Main: TIBSQL;
    IBRptSQL03Sub1: TIBSQL;
    IBRptSQL03Sub2: TIBSQL;
    IBRptSQL03Sub3: TIBSQL;
    IBRptSub1: TIBQuery;
    IBRptSub2: TIBQuery;
    IBRptSub3: TIBQuery;
//    ADOStoredProc1: TADOStoredProc;
    procedure DataModuleCreate(Sender: TObject);
    procedure TransactionIdleTimer(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure IBEventErrorHandler(Sender: TObject; ErrorCode: Integer);
    procedure IBEventHandler(Sender: TObject; EventName: String;
      EventCount: Integer; var CancelAlerts: Boolean);
    procedure IBDbBeforeDisconnect(Sender: TObject);
    procedure IBDbAfterConnect(Sender: TObject);
    {procedure IBSQLMonitor1SQL(EventText: String; EventTime: TDateTime);}
{$IFDEF ASYNCEVENTNOT}
  protected
    FHandle : HWnd;
    function GetHandle : HWnd;
    procedure WndProc(var Message : TMessage);
{$ENDIF}
  private
    { Private declarations }
    FThCursors : TIBSqlBuilder;
    FCursors : TIBSqlBuilder;
    FPosPostCursors : TIBSqlBuilder;
    FReceiptCursors: TIBSqlBuilder;
    FIBEventNot : TNotificationRegistry;
    FDBEventNot : TNotificationRegistry;
    procedure DBNotify(const Name : string);
{$IFDEF ASYNCEVENTNOT}
    procedure IBNotifyMsg(var Msg: TMessage); Message WM_IBNOTIFYMSG;
{$ENDIF}
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Init();
    function CursorBuild(): TIBSqlBuilder;
    property ThCursors : TIBSqlBuilder read FThCursors;
    property Cursors : TIBSqlBuilder read FCursors;
    property PosPostCur : TIBSqlBuilder read FPosPostCursors;
    property RecieptCur : TIBSqlBuilder read FReceiptCursors;
    procedure RegIBEventNotification(const Name : ansistring; const Event : TNotifyEvent);
    procedure IBNotify(const Name : string);

    procedure RegDBEventNotification(const Name : ansistring; const Event : TNotifyEvent);
    procedure PostEvent(const Name : string);
{$IFDEF ASYNCEVENTNOT}
    property Handle : HWnd read GetHandle;
{$ENDIF}
    function GetDayId(Tran : TIBTransaction) : integer;
  end;

var
  POSDataMod: TPOSDataMod;


implementation

{$R *.DFM}

uses ExceptLog, POSMisc, EClasses, LatTypes;

function TPOSDataMod.CursorBuild(): TIBSqlBuilder;
var
  indtran : TIBTransaction;
begin
  indtran := TIBTransaction.Create(Self.IBDb);
  indtran.AddDatabase(Self.IBDb);
  Self.IBDb.AddTransaction(indtran);
  Result := TIBSqlBuilder.Create(Self.IBDb, indtran);
  if (buildflags and VS_FF_DEBUG) <> 0 then
  begin
    indtran.IdleTimer := 600;
    indtran.OnIdleTimer := TransactionIdleTimer;
  end;

end;


procedure TPOSDataMod.DataModuleCreate(Sender: TObject);
begin
{$IFDEF ASYNCEVENTNOT}
  FHandle := AllocateHWnd(WndProc);
{$ENDIF}
  IBTransaction.AllowAutoStart := False;
  IBShiftTransaction.AllowAutoStart := False;
  IBDefaultTransaction.AllowAutoStart := False;
  IBSetupTransaction.AllowAutoStart := False;
  IBMixMatchTransaction.AllowAutoStart := False;
  IBUserTransaction.AllowAutoStart := False;
  IBLogTransaction.AllowAutoStart := False;
  IBPostTransaction.AllowAutoStart := False;
  IBFuelPriceChangeTransaction.AllowAutoStart := False;
  IBFuelPriceUpdateTransaction.AllowAutoStart := False;
  IBReceiptTransaction.AllowAutoStart := False;
  IBEODTransaction.AllowAutoStart := False;
  IBMenuTransaction.AllowAutoStart := False;
  IBKybdTransaction.AllowAutoStart := False;
  IBTempTrans2.AllowAutoStart := False;
  IBTempTrans1.AllowAutoStart := False;
  IBReportTransaction.AllowAutoStart := False;
  IBBatchReportTransaction.AllowAutoStart := False;
  IBReportTransaction2.AllowAutoStart := False;
  IBPrintTransaction.AllowAutoStart := False;
  IBExportTransaction.AllowAutoStart := False;
  IBTransactionMenuUpdate.AllowAutoStart := False;
  IBXMDTrans.AllowAutoStart := False;
  IBSecTrans.AllowAutoStart := False;
  IBKioskTrans.AllowAutoStart := False;
  IBSuspendTrans.AllowAutoStart := False;

end;

procedure TPOSDataMod.Init;
var
  i : integer;
begin
  FThCursors := TIBSqlBuilder.Create(Self.IBDB, Self.ThreadTrans);
  try
    FThCursors.StartTransaction;
    FThCursors.AddCursor('FPC-PostSel', 'Select TS, ProductName, CashPrice, CreditPrice, TotalVolume, TotalValue, FuelPriceChangeLog.RDB$DB_KEY from FuelPriceChangeLog where posted = 0 order by posted, TS');
    FThCursors.AddCursor('FPC-PostU', 'Update FuelPriceChangeLog set posted = 1 where FuelPriceChangeLog.RDB$DB_KEY = :pKey');
    FThCursors.Commit;
  except
    on E: Exception do
    begin
      FThCursors.Rollback;
      raise;
    end;
  end;
  FCursors := Self.CursorBuild();
  try
    FCursors.Transaction.Name := 'FCursors_Transaction';
    FCursors.StartTransaction;
    FCursors.AddCursor('MOM-Insert', 'Insert into MOMoves (act, rangeb, rangee, ts, tsms, posted) values (:pAct, :pRangeB, :pRangeE, :pTS, :pTSms, 0)');
    FCursors.AddCursor('MO-Insert', 'Insert into MoneyOrder (SerialNo, DocValue, PurchTS, TransNo) values (:pSerialNo, :pDocValue, :pPurchTS, :pTransNo)');
    FCursors.AddCursor('MO-UpdLP', 'Update Config set pvalue = :pSerialNo where pname=''MO_LASTPRINTED'' and ptype = ''CUR''');
    FCursors.AddCursor('SIG-GET', 'Select signaturedata from pinpadsignature where authid=:pAuthId');
    FCursors.Commit;
  except
    on E: Exception do
    begin
      FCursors.Rollback;
      raise;
    end;
  end;
  FReceiptCursors := TIBSqlBuilder.Create(Self.IBDB, Self.IBReceiptTransaction);
  try
    FReceiptCursors.StartTransaction;
    FReceiptCursors.AddCursor('RCPT-Insert', 'Insert into Receipt (TransactionNo, SeqNumber, LineType, SaleType,' +
                                             'SaleNo, SaleName, Qty, Price, ExtPrice, SavDiscable, SavDiscAmount,' +
                                             'PumpNo, HoseNo, Disc, FSSubtotal, Subtotal, TlTotal, Total, ChangeDue, LineVoided, ' +
                                             'TaxNo, TaxRate, Taxable, WEXCode, PHHCode, IAESCode, VoyagerCode, ' +
                                             'CCAuthCode, CCApprovalCode, CCDate, CCTime, CCCardNo, CCCardType, ' +
                                             'CCCardName, CCExpDate, CCBatchNo, CCSeqNo, CCEntryType, CCvehicleNo, ' +
                                             'CCOdometer, CCPrintLine1, CCPrintLine2, CCPrintLine3, CCPrintLine4, ' +
                                             'CCBalance1, CCBalance2, CCBalance3, CCBalance4, CCBalance5, CCBalance6, ' +
                                             'ActivationState, ActivationTransNo, ActivationTimeout, LineID, CCPin, ' +
                                             'CCRequestType, CCAuthID, CCAuthorizer, FuelSaleID, MODocNo, EMVAuthConf) Values ' +
                                             '(:pTransactionNo, :pSeqNumber, :pLineType, :pSaleType, ' +
                                             ':pSaleNo, :pSaleName, :pQty, :pPrice, :pExtPrice, :pSavDiscable, :pSavDiscAmount,' +
                                             ':pPumpNo, :pHoseNo, :pDisc, :pFSSubtotal,:pSubtotal, :pTlTotal, :pTotal, :pChangeDue, :pLineVoided, ' +
                                             ':pTaxNo, :pTaxRate, :pTaxable, :pWEXCode, :pPHHCode, :pIAESCode, :pVoyagerCode, ' +
                                             ':pCCAuthCode, :pCCApprovalCode, :pCCDate, :pCCTime, :pCCCardNo, :pCCCardType, ' +
                                             ':pCCCardName, :pCCExpDate, :pCCBatchNo, :pCCSeqNo, :pCCEntryType, :pCCvehicleNo, ' +
                                             ':pCCOdometer, :pCCPrintLine1, :pCCPrintLine2, :pCCPrintLine3, :pCCPrintLine4, ' +
                                             ':pCCBalance1, :pCCBalance2, :pCCBalance3,  :pCCBalance4, :pCCBalance5,   :pCCBalance6, ' +
                                             ':pActivationState, :pActivationTransNo, :pActivationTimeout, :pLineID, :pCCPin, ' +
                                             ':pCCRequestType, :pCCAuthID, :pCCAuthorizer, :pFuelSaleID, :pMODocNo, :pEMVAuthConf)');
    FReceiptCursors.Commit;
  except
    on E: Exception do
    begin
      FCursors.Rollback;
      raise;
    end;
  end;
  FPosPostCursors := Self.CursorBuild();
  try
    with FPosPostCursors do
    begin
      Transaction.Name := 'FPosPostCursors_Transaction';
      StartTransaction;
      AddCursor('GetDayId', 'Execute procedure GetDayId');
      // Line item postings
      // DBUpdateMedia
      AddCursor('MedShiftMerge', 'execute procedure MedShiftMerge(:pDayId, :pMediaNo, :pTerminalNo, :pShiftNo, :pDlyCount, :pDlySales, :pDlyOutsideSales, :pDlyFuel, :pDlyOutsideFuel, :pDlyOutsideCount, :pDlyTax)');
      AddCursor('MedCardTypeShiftMerge', 'execute procedure MedCardTypeShiftMerge(:pDayId, :pCardType, :pTerminalNo, :pShiftNo, :pDlyCount, :pDlySales, :pDlyOutsideSales, :pDlyFuel, :pDlyOutsideFuel, :pDlyOutsideCount, :pDlyTax)');
      // PostDiscount
      {$IFDEF PDI_PROMOS}
      AddCursor('PromoShiftFind', 'Select * from PromoShift where DayId = :pDayId and PromoNo = :pPromoNo And ShiftNo = :pShiftNo And TerminalNo = :pTerminalNo');
      AddCursor('PromotionsFind', 'SELECT Sum(MatchQTY) Items FROM PROMOTIONS WHERE PromoNo = :pPromoNo ');
      {$ENDIF}
      AddCursor('DiscShiftMerge', 'execute procedure DiscShiftMerge(:pdayid, :pdiscno, :pterminalno, :pshiftno, :pdlycount, :pdlyamount)');

      // PostSale
      AddCursor('DepShiftMerge', 'execute procedure DepShiftMerge(:pdayid, :pdeptno, :pterminalno, :pshiftno, :pdlycount, :pdlysales, :padjcount, :padjamount)');
      AddCursor('GradeUpdate', 'UPDATE Grade SET TLVol = TLVol + :pVol, TLAmount = TLAmount + :pAmount WHERE (DeptNo = :pDeptNo)');
      AddCursor('PumpAmountFind', 'select f.Amount as Amount, f.UnitPrice as UnitPrice, p.GradeNo as GradeNo from FuelTran f join PumpDef p on f.PumpNo = p.PumpNo and f.HoseNo = p.HoseNo where f.SaleID = :pSaleID');
      AddCursor('MixMatchShiftMerge', 'execute procedure mixmatchshiftmerge(:pdayid, :pmmno, :pterminalno, :pshiftno, :pdlycount, :pdlyamount)');
      AddCursor('PLUSel', 'Select PLUNo, Price, DeptNo from PLU where PLUNo = :pPLUNo');
      AddCursor('PLUModSel', 'Select PLUNo, PLUPrice from PLUMod where PLUNo = :pPLUNo');
      AddCursor('PLUShiftMerge', 'execute procedure plushiftmerge(:pdayid, :ppluno, :pplumodifier, :pterminalno, :pshiftno, :pprice, :pplumodifiergroup, :pdlycount, :pdlysales, :padjcount, :padjamount)');
      AddCursor('PLUInvUpdate', 'Update PLU SET OnHand = OnHand - :pCount where PLUNo = :pPLUNo');
      AddCursor('BankShiftMerge', 'execute procedure BankShiftMerge (:pdayid, :pbankno, :pterminalno, :pshiftno, :pdlycount, :pdlysales)');
      AddCursor('BankFuncRecTypeFind', 'Select RecType From BankFunc Where BankNo = :pBankNo');
      AddCursor('CashDropInsert', 'INSERT INTO CashDrop( DropTime, DropShift, DropAmount, DropTransNo, TerminalNo) Values (:pDropTime, :pDropShift, :pDropAmount, :pDropTransNo, :pTerminalNo)');
      AddCursor('PPYTotalsUpdate', 'UPDATE Totals SET DlyPrePayCount = DlyPrePayCount + :pCount, DlyPrePayRcvd = DlyPrePayRcvd + :pAmount WHERE ((TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo) ) )');
      AddCursor('PPYUsedUpdate', 'UPDATE Totals SET DlyPrePayCountUsed = DlyPrePayCountUsed + 1, DlyPrePayUsed = DlyPrePayUsed + :pUsed WHERE (TotalNo = 0) Or ((ShiftNo = :pShift) and (TerminalNo = :pTerminalNo))');
      AddCursor('PRFTotalsUpdate', 'UPDATE Totals SET DlyPrePayRfndCount = DlyPrePayRfndCount + :pCount, DlyPrePayRfnd = DlyPrePayRfnd + :pAmount WHERE ((TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)))');
      AddCursor('GetDeptForHose', 'SELECT G.DeptNo FROM PumpDef P, Grade G WHERE ((P.PumpNo = :pPumpNo And P.HoseNo = :pHoseNo) And P.GradeNo = G.GradeNo)');
      // Total postings
      AddCursor('TaxShiftMerge', 'execute procedure TaxShiftMerge(:pdayid, :ptaxno, :pterminalno, :pshiftno, :pdlycount, :pdlytaxablesales, :pdlytaxcharged, :pFSTaxExemptSales, :pFSTaxExemptAmount)');
      AddCursor('TotalsUpdate', 'UPDATE Totals SET CurGT = CurGT + :pTotal, DlyTransCount = DlyTransCount + 1, DlyDS = DlyDS + :pTotal, DlyND = DlyND + :pSubTotal, DlyNoTax = DlyNoTax + :pNoTax, FuelCount  = FuelCount + :pFuelCount,' +
                                       'FuelAmount = FuelAmount + :pFuelAmount, MdseCount  = MdseCount + :pMdseCount, MdseAmount = MdseAmount + :pMdseAmount, FMCount  = FMCount + :pFMCount, FMAmount = FMAmount + :pFMAmount,' +
                                       'DlyVoidCount = DlyVoidCount + :pVoidCount, DlyVoidAmount = DlyVoidAmount + :pVoidAmount, DlyRtrnCount = DlyRtrnCount + :pRtrnCount, DlyRtrnAmount = DlyRtrnAmount + :pRtrnAmount ' +
                                       'WHERE ((TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo) )  )');
      AddCursor('MedShiftDSUpdate', 'UPDATE MedShift SET DlySales = (DlySales - :pChangeDue) WHERE ((MediaNo = 1) And (ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)    )');
      AddCursor('HourlyShiftMerge', 'execute procedure hourlyshiftmerge(:pDAYID, :pTxnTime, :pTERMINALNO, :pSHIFTNO, :pDLYCOUNT, :pDLYSALES, :pFUELCOUNT, :pFUELAMOUNT, :pMDSECOUNT, :pMDSEAMOUNT, :pFMCOUNT, :pFMAMOUNT,' +
                                    ':pNOSALECOUNT, :pVOIDCOUNT, :pVOIDAMOUNT, :pRTRNCOUNT, :pRTRNAMOUNT, :pCANCELCOUNT, :pCANCELAMOUNT, :pSALESRPTCOUNT)');
      Commit;
    end;
  except
    on E: Exception do
    begin
      FPosPostCursors.Rollback;
      raise;
    end;
  end;
  if (buildflags and VS_FF_DEBUG) <> 0 then
  begin
    UpdateExceptLog(' Debug build - Setting transaction idle timers');
    for i := 0 to Self.IBDB.TransactionCount -1 do
    begin
      Self.IBDB.Transactions[i].IdleTimer := 6000;
      Self.IBDB.Transactions[i].OnIdleTimer := TransactionIdleTimer;
      UpdateExceptLog(Format('  Transaction %s updated',[Self.IBDb.Transactions[i].Name]));
    end;
  end;
end;

procedure TPOSDataMod.TransactionIdleTimer(Sender: TObject);
begin
  if Sender is TIBTransaction then
  with TIBTransaction(Sender) do
  begin
    UpdateExceptLog(Format('Transaction %s idle for %d seconds - default action already taken', [Name,IdleTimer]));
  end
  else UpdateExceptLog(Format('%s being sent to TransactionIdleTimer', [Sender.ClassName]));
end;

procedure TPOSDataMod.DataModuleDestroy(Sender: TObject);
begin
  try
    FCursors.Free;
  except
  end;
  try
    FThCursors.Free;
  except
  end;
  try
    FPosPostCursors.Free;
  except
  end;
{$IFDEF ASYNCEVENTNOT}
  DeallocateHWND(FHandle);
{$ENDIF}
end;

procedure TPOSDataMod.IBEventErrorHandler(Sender: TObject;
  ErrorCode: Integer);
begin
  UpdateExceptLog('TPOSDataMod.IBEvents encountered an error: %s - %d', [Sender.ClassName, ErrorCode]);
end;

procedure TPOSDataMod.IBEventHandler(Sender: TObject; EventName: String; EventCount: Integer; var CancelAlerts: Boolean);
{$IFDEF ASYNCEVENTNOT}
var
  msg : pMsgRec;
{$ENDIF}
begin
  try
    CancelAlerts := False;
    UpdateZLog('TPOSDataMod.EventHandler: got event %s from %s.  Count: %d', [EventName, Sender.ClassName, EventCount]);
{$IFDEF ASYNCEVENTNOT}
    new(msg);
    msg^.Text := EventName;
    PostMessage(POSDataMod.Handle,WM_IBNOTIFYMSG,0,longint(msg));
{$ELSE}
    Self.FIBEventNot.Notify(EventName);
{$ENDIF}
  except
    on E: EKeyError do
    begin
      UpdateExceptLog('Cannot find %s in event handler', [EventName]);
    end;
  end;
end;

procedure TPOSDataMod.IBNotify(const Name: string);
begin
  Self.FIBEventNot.Notify(Name);
end;

procedure TPOSDataMod.RegIBEventNotification(const Name: ansistring; const Event: TNotifyEvent);
begin
  UpdateZLog('Registering event %s', [Name]);
  Self.FIBEventNot.RegisterNotification(Name, Event);
  {Self.IBSQLMonitor1SQL('*** about to add event to IBEvents ***', Now());}
  Self.IBEvents.Events.Add(Name);
  {Self.IBSQLMonitor1SQL('*** done adding event to IBEvents ***', Now());}
  if Self.IBEvents.Registered then
    Self.IBEvents.UnRegisterEvents;
  Self.IBEvents.RegisterEvents;
end;

procedure TPOSDataMod.DBNotify(const Name: string);
begin
  try
    Self.FDBEventNot.Notify(Name);
  except
    on E: Exception do
    begin
      UpdateExceptLog('TPOSDataMod.DBNotify: exception %s caught while trying to notify "%s" - Message: %s', [E.ClassName, Name, E.Message]);
      DumpTraceBack(E, 5);
    end;
  end;

end;

procedure TPOSDataMod.RegDBEventNotification(const Name: ansistring;
  const Event: TNotifyEvent);
begin
  Self.FDBEventNot.RegisterNotification(Name, Event);
end;


constructor TPOSDataMod.Create;
begin
  inherited;
  Self.FIBEventNot := TNotificationRegistry.Create();
  Self.FDBEventNot := TNotificationRegistry.Create();
end;

destructor TPOSDataMod.Destroy;
begin
  inherited;
  FreeAndNil(Self.FIBEventNot);
  FreeAndNil(Self.FDBEventNot);
end;

{
procedure TPOSDataMod.IBSQLMonitor1SQL(EventText: String;
  EventTime: TDateTime);
var
  TF     : TextFile;
begin
  try
    AssignFile(TF, 'sqlmon.log');
    if FileExists('sqlmon.log') then
      Append(TF)
    else
      ReWrite(TF);
    WriteLn(TF, FormatDateTime('yyyy-mm-dd hh:mm:ss ', EventTime) + EventText);
    CloseFile(TF);
  except
  end;

end;
}

procedure TPOSDataMod.IBDbBeforeDisconnect(Sender: TObject);
begin
  UpdateZLog('TPOSDataMod.IBDbBeforeDisconnect - Sender class - %s', [Sender.ClassName]);
  DBNotify('BeforeDisconnect');
  Self.IBEvents.UnRegisterEvents;
end;

procedure TPOSDataMod.IBDbAfterConnect(Sender: TObject);
begin
  UpdateZLog('TPOSDataMod.IBDbAfterConnect - Sender class - %s', [Sender.ClassName]);
  DBNotify('AfterConnect');
  Self.IBEvents.RegisterEvents;
end;



procedure TPOSDataMod.PostEvent(const Name: string);
begin
  UpdateZLog('Posting DB Event %s', [Name]);
  Self.EventTran.StartTransaction;
  Self.DoEvent.ParamByName('EVENTNAME').AsString := Name;
  Self.DoEvent.ExecProc;
  Self.EventTran.Commit;
end;

{$IFDEF ASYNCEVENTNOT}
procedure TPOSDataMod.IBNotifyMsg(var Msg: TMessage);
var
  s : string;
begin
  if Msg.LParam <> 0 then
  begin
    s := pMsgRec(Msg.LParam).Text;
    Dispose(pMsgRec(Msg.LParam));
    Self.IBNotify(s);
  end;
end;

// -WndProc to be used by the window handle
procedure TPOSDataMod.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
    UpdateZLog('TPOSDataMod.WndProc %d %d %d', [Message.Msg, Message.WParam, Message.LParam]);
    if Message.Msg = WM_QUERYENDSESSION then
      Message.Result := 1;
  except
    Application.HandleException(Self);
  end;
end;

// -Creates window handle for class
function TPOSDataMod.GetHandle : HWnd;
begin
  Result := FHandle;
end;

{$ENDIF}

function TPOSDataMod.GetDayId(Tran: TIBTransaction): integer;
var
  ibsp : TIBStoredProc;
begin
  ibsp := TIBStoredProc.Create(Self);
  ibsp.Database := Self.IBDb;
  ibsp.Transaction := Tran;
  ibsp.StoredProcName := 'GETDAYID';
  ibsp.ExecProc;
  Result := ibsp.ParamByName('DAYID').AsInteger;
  ibsp.Destroy;
end;

end.


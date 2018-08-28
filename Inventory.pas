unit Inventory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OoMisc, AdPort, StdCtrls, ElastFrm, Buttons, ExtCtrls, POSBtn,
  //inv2...
  Math,
  //...inv2
  ComCtrls, Grids;

const
{$I ConditionalCompileSymbols.txt}
{$I ExportTags.inc}

  STX = #2;
  ETX = #3;
  IdleScreen    = 1;
  MoveScreen    = 2;
  AdjustScreen  = 3;
  InitialScreen = 4;
  ReceiveScreen = 5;
  AddScreen     = 6;
  bScannerAvail : boolean = false;
  //inv2...
  bInventoryFunctionsAllowed : boolean = True;
  iBreakdownItemCount : integer = 0;
  BreakdownLink : double = 0.0;
  BreakdownItemCount : integer = 0;
  MAXBreakdownPackagesOnHand : integer = 0;
  COLUMN_NUMBER_UPCTEXT : integer = 0;
  COLUMN_NUMBER_SCANNED : integer = 2;
  MAX_INVOICE_WIDTH : integer = 20;
  //...inv2
  MAX_DEPT_NO_WIDTH : integer = 30;
  LEN_DEPTNO_FIELD : integer = 3;

type
  TfmInventoryInOut = class(TForm)
    LblFromPLU: TLabel;
    ElasticForm1: TElasticForm;
    fldPLU1: TEdit;
    btnClose: TBitBtn;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    LblCurrentCount: TLabel;
    fldCurrentCount: TEdit;
    LblNewCount: TLabel;
    fldNewCount: TEdit;
    Memo1: TMemo;
    btnMove: TBitBtn;
    LblToPLU: TLabel;
    LblToCount: TLabel;
    fldToCount: TEdit;
    fldPLU2: TEdit;
    btnAdjust: TBitBtn;
    btnReceive: TBitBtn;
    lblBreakdownDesc: TLabel;
    dbGridOnHand: TStringGrid;
    btnScannerExport: TBitBtn;
    btnScannerImport: TBitBtn;
    lblOnHandDifference: TLabel;
    btnPrintPriorInvoice: TButton;
    lblPLU1Name: TLabel;
    fldInvoiceID: TComboBox;
    fldDeptToPrint: TComboBox;
    btnPrintDeptInventory: TButton;
    btnAddPending: TButton;
    procedure ScannerPortTriggerAvail(CP: TObject; Count: Word);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnMoveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnReceiveClick(Sender: TObject);
    procedure btnAdjustClick(Sender: TObject);
    procedure fldNewCountChange(Sender: TObject);
    procedure dbGridOnHandSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure btnScannerExportClick(Sender: TObject);
    procedure btnScannerImportClick(Sender: TObject);
    procedure btnPrintPriorInvoiceClick(Sender: TObject);
    procedure fldPLU1Click(Sender: TObject);
    procedure fldCurrentCountClick(Sender: TObject);
    procedure fldNewCountClick(Sender: TObject);
    procedure fldPLU1KeyPress(Sender: TObject; var Key: Char);
    procedure dbGridOnHandKeyPress(Sender: TObject; var Key: Char);
    procedure dbGridOnHandKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbGridOnHandExit(Sender: TObject);
    procedure btnPrintDeptInventoryClick(Sender: TObject);
    procedure btnAddPendingClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ScannerPort: TApdComPort;
    { Private declarations }
    procedure ProcessScan1;
    //inv2...
//    procedure ProcessScan2;
    //...inv2
    procedure SetScreen(ScreenToUse : byte);
    procedure POSButtonClick(Sender: TObject);
    procedure ProcessKey;
    function CheckUPC : boolean;
    //inv2...
    procedure SetUpGridOnHand();
    procedure AddPendingImportedInventory(const UPCTextToAdd : string; const ScanCountToAdd : integer);
    //inv4...
//    procedure AdjustImportedInventory();
    procedure AdjustImportedInventory(const ScanType : integer);
    //...inv4
    procedure UpdateScanCounts();
    procedure ImportScannedInventory(const InvFileName : string; const InvScanType : integer);
    procedure BuildInvoiceField();
    //...inv2
    procedure BuildDeptField();
  public
    { Public declarations }
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
    procedure ProcessScan(PLUNo : string);
  end;

  pUPCScanRecord = ^TUPCScanRecord;
  //inv2...
  TUPCScanRecord = record
    UPCText : string;
    bScanned : boolean;
    ScanCount : integer;
  end;
  //...inv2


var
  fmInventoryInOut: TfmInventoryInOut;
  BuffPtr     : byte;
  KeyBuff     : array[0..14] of char;
  MoveData,
  ReceiveData,
  AddData,
  //inv5...
  UpdateData,
  //...inv5
  AdjustData  : boolean;
  Keytops  : array[1..14] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT', 'NXT', 'BAK');
  POSButtons2    : array[1..14] of TPOSTouchButton;

  //inv2...
//  UPCList : TList;
  InitialUPCScannedList : TList;
  //...inv2

implementation

uses PosDm,
  //inv3...
  Reports,
  //...inv3
  POSMain, 
  POSMisc,
  ExceptLog;

{$R *.dfm}
var
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

procedure TfmInventoryInOut.ScannerPortTriggerAvail(CP: TObject; Count: Word);
var
  i           : word;
  c           : char;
begin
  for i := 1 to count do
  begin
    c :=  ScannerPort.GetChar;
    if c = STX then
    begin
      KeyBuff := '';
      BuffPtr := 0;
    end;
    if (c = ETX)  then
    begin
      if not fldPLU1.Enabled then
        Memo1.Lines.Add('You must select Receive, Adjust or Move prior to scanning!')
      else
      if fldPLU1.Focused then
      begin
        fldPLU1.text := Copy(KeyBuff,2,(BuffPtr - 1));
        ProcessScan1;
      //inv2...
//      end
//      else if fldPLU2.Focused then
//      begin
//        fldPLU2.text := Copy(KeyBuff,2,(BuffPtr - 1));
//        ProcessScan2;
      //...inv2
      end;
      KeyBuff := '';
      BuffPtr := 0;
    end
    else
    begin
      KeyBuff[BuffPtr] := c;
      Inc(BuffPtr);
    end;
  end;
end;  // procedure ScannerPortTriggerAvail

procedure TfmInventoryInOut.FormCreate(Sender: TObject);
var
  nPort, nBaud, nData, nStop: short;
  nParity       : TParity;
//  hw : HWND;
begin
  scannerport := TApdComPort.Create(Self);
  scannerport.OnTriggerAvail := Self.ScannerPortTriggerAvail;
  MoveData := false;
  //inv2...
//  SetScreen(InitialScreen);
  //...inv2
  memo1.Clear();
//  hw:=FindWindow('TfmPOS', Nil);
  //inv2...
//  if (hw = 0) then
//  bInventoryFunctionsAllowed := (hw = 0);
  bInventoryFunctionsAllowed := True;
  SetScreen(InitialScreen);
  if (not bInventoryFunctionsAllowed) then
  //...inv2
  begin
    if not POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.StartTransaction;
    with POSDataMod.IBQryInventory do
    begin
      Close();
      SQL.Clear();
      //inv2...
//      SQL.Add('Select * from TermPorts where TerminalNo = :pTerminalNo and DeviceNo = 28');
      SQL.Add('Select * from TermPorts where TerminalNo = :pTerminalNo and DeviceType = 3 and Driver = 1 order by DeviceNo');
      //...inv2
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      Open;
      if RecordCount > 0 then
      begin
        nPort := FieldByName('PortNo').AsInteger;
        nBaud := FieldByName('BaudRate').AsInteger;
        nData := FieldByName('DataBits').AsInteger;
        nStop := FieldByName('StopBits').AsInteger;
        if FieldByName('Parity').AsInteger = 0 then
          nParity := pNone
        else if FieldByName('Parity').AsInteger = 1 then
          nParity := pEven
        else
          nParity := pOdd;
        ScannerPort.ComNumber := nPort;
        ScannerPort.Baud := nBaud;
        ScannerPort.Databits := nData;
        ScannerPort.StopBits := nStop;
        ScannerPort.Parity := nParity;
        ScannerPort.Open := True;
        bScannerAvail := true;
      end
      else
        bScannerAvail := false;
      Close;
    end;
    if POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.Commit;
    BuffPtr := 0;
    KeyBuff := '';
  end;
  //inv2...
  btnSave.Enabled := False;
  btnCancel.Enabled := bInventoryFunctionsAllowed;
  btnMove.Enabled := bInventoryFunctionsAllowed;
  btnReceive.Enabled := bInventoryFunctionsAllowed;
  btnAdjust.Enabled := bInventoryFunctionsAllowed;
  btnAddPending.Enabled := bInventoryFunctionsAllowed;

//inv5  DBGridOnHand.Enabled := False;
  InitialUPCScannedList := TList.Create();
  InitialUPCScannedList.Clear();
//  SetupGridOnHand();
//  BuildInvoiceField();
  //...inv2

end;  // procedure FormCreate

procedure TfmInventoryInOut.btnCloseClick(Sender: TObject);
begin
  MoveData := false;
  if bScannerAvail then
    ScannerPort.Open := false;
  Close;
end;

procedure TfmInventoryInOut.btnCancelClick(Sender: TObject);
var
  Strng : string;
begin
  if ReceiveData then
    Strng := 'Receive inventory cancelled'
  else if AddData then
    Strng := 'Add pending received cancelled'
  //inv5...
  else if UpdateData then
    strng := 'Inventory update cancelled'
  //...inv5
  else if AdjustData then
    strng := 'Inventory adjustment cancelled'
  else if MoveData then
    strng := 'Move inventory cancelled'
  else
    strng := 'Inventory changes cancelled';
  Memo1.Clear();
  Memo1.Lines.Add(strng);
  MoveData := false;
  AdjustData := false;
  ReceiveData := false;
  AddData := false;
  //inv5...
  UpdateData := false;
  //...inv5
  SetScreen(IdleScreen);
  BuffPtr := 0;
  KeyBuff := '';
//inv5  DBGridOnHand.Enabled := False;
  SetupGridOnHand();
end;

procedure TfmInventoryInOut.btnSaveClick(Sender: TObject);
var
  CurrentOk : double;
  RecordsReturned : cardinal;
  //inv2...
//  CurrentOnHand : cardinal;
  ItemAdjustment : integer;
  InvoiceID : string;
  //...inv2
  ScanCountToAdd : integer;
  UPCTextToAdd : string;
begin
  ScanCountToAdd := 0;
  //inv2...
  InvoiceID := '';
  // Validate fields entered on the form.
  if (ReceiveData) then
  begin
    if (Trim(fldPLU1.Text) = '') then
    begin
      btnSave.Enabled := False;
      showmessage('Invoice must be non blank');
      fldPLU1.SetFocus();
      exit;
    end;
    UpdateScanCounts();
  end
  else
  begin
  //...inv2
    try
      strtofloat(fldPLU1.Text);
    except
      showmessage('PLU/UPC must be numeric');
      exit;
    end;
  //inv2...
//  if ReceiveData or AdjustData then
  end;
  if (AdjustData) then
  //...inv2
  try
    strtofloat(fldNewCount.Text);
  except
    showmessage('New Count must be numeric');
    exit;
  end
  else if (AddData) then
  //...inv2
  try
    StrToCurr(fldPLU1.Text);
    ScanCountToAdd := StrToInt(fldNewCount.Text);
  except
    showmessage('UPC and additional count must be numeric');
    exit;
  end
  else if MoveData then
  begin
    try
      strtofloat(fldPLU2.Text);
    except
      showmessage('Both PLU/UPC fields must be numeric');
      exit;
    end;
    //inv2...
//    if grpBreakDown.ItemIndex < 0 then
//    begin
//      showmessage('Breakdown must be selected');
//      exit;
//    end;
    //...inv2
  end;
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  if not POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory do
  begin
    //inv2...
//    if MoveData and (fldPLU1.text <> '') and (fldPLU2.text <> '') and (grpBreakDown.ItemIndex > -1) then
    if MoveData and (fldPLU1.text <> '') and (fldPLU2.text <> '') then
    //...inv2
    begin
      MoveData := false;
      Close();
      SQL.Clear();
      SQL.Add('Update PLU set OnHand = OnHand - :pCountMoved where PLUNo = :pPLUNo or UPC = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
      ParamByName('pCountMoved').AsInteger := strtoint(fldCurrentCount.Text);
      ExecSQL;
      Close();
      SQL.Clear();
      //inv2...
//      SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
      SQL.Add('Select * from PLU where PLUNo = :pPLUNo or UPC = :pPLUNo');
      //...inv2
      ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU2.Text);
      open;
      if recordcount > 0 then
      begin
        if (fieldbyname('OnHand').AsCurrency >= 0) or (fieldbyname('OnHand').AsCurrency < 0) then
          CurrentOk := fieldbyname('OnHand').AsCurrency
        else
          CurrentOk := 0;
      end
      else
        CurrentOK := 0;
      Close();
      SQL.Clear();
      SQL.Add('Update PLU set OnHand = :pOnHand where PLUNo = :pPLUNo or UPC = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU2.Text);
      //inv2...
//      case grpBreakdown.ItemIndex of
//        0 : parambyname('pOnHand').AsCurrency := CurrentOK + (4 * strtoint(fldCurrentCount.Text));
//        1 : parambyname('pOnHand').AsCurrency := CurrentOK + (6 * strtoint(fldCurrentCount.Text));
//        2 : parambyname('pOnHand').AsCurrency := CurrentOK + (10 * strtoint(fldCurrentCount.Text));
//        3 : parambyname('pOnHand').AsCurrency := CurrentOK + (12 * strtoint(fldCurrentCount.Text));
//        4 : parambyname('pOnHand').AsCurrency := CurrentOK + (18 * strtoint(fldCurrentCount.Text));
//        5 : parambyname('pOnHand').AsCurrency := CurrentOK + (24 * strtoint(fldCurrentCount.Text));
//        6 : parambyname('pOnHand').AsCurrency := CurrentOK + (30 * strtoint(fldCurrentCount.Text));
//        7 : parambyname('pOnHand').AsCurrency := CurrentOK + (48 * strtoint(fldCurrentCount.Text));
//      end;
      ItemAdjustment := BreakdownItemCount * StrToInt(fldCurrentCount.Text);
      ParamByName('pOnHand').AsCurrency := CurrentOK + ItemAdjustment;
      //...inv2
      try
        ExecSQL;
        Close();
        SQL.Clear();
        SQL.Add('Select * from InvAudit');
        open;
        RecordsReturned := RecordCount;
        Close();
        SQL.Clear();
        SQL.Add('Insert into InvAudit (SEQNO, USERNO, CHANGEDATE, PLUNO, ADJUSTMENT, BREAKDOWN, RECEIVE) ');
        if RecordsReturned > 0 then
          SQL.Add('Values ((Select Max(SeqNo) + 1 from InvAudit), :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 1, 0)')
        else
          SQL.Add('Values (1, :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 1, 0)');
        ParamByName('pUserNo').AsString := CurrentUserID;
        ParamByName('pChangeDate').AsDateTime := now;
        ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
        ParamByName('pAdjustment').AsInteger := -1 * StrToInt(fldCurrentCount.Text);
        ExecSQL;
        Close();
        SQL.Clear();
        SQL.Add('Insert into InvAudit (SEQNO, USERNO, CHANGEDATE, PLUNO, ADJUSTMENT, BREAKDOWN, RECEIVE) ');
        SQL.Add('Values ((Select Max(SeqNo) + 1 from InvAudit), :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 1, 0)');
        ParamByName('pUserNo').AsString := CurrentUserID;
        ParamByName('pChangeDate').AsDateTime := now;
        ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU2.Text);
        //inv2...
//        case grpBreakdown.ItemIndex of
//          0 : parambyname('pAdjustment').AsInteger := 4;
//          1 : parambyname('pAdjustment').AsInteger := 6;
//          2 : parambyname('pAdjustment').AsInteger := 10;
//          3 : parambyname('pAdjustment').AsInteger := 12;
//          4 : parambyname('pAdjustment').AsInteger := 18;
//          5 : parambyname('pAdjustment').AsInteger := 24;
//          6 : parambyname('pAdjustment').AsInteger := 30;
//          7 : parambyname('pAdjustment').AsInteger := 48;
//        end;
        ParamByName('pAdjustment').AsInteger := ItemAdjustment;
        //...inv2
        ExecSQL;
        BuildInvoiceField();
      except
        on E: Exception do
          showmessage('Error ' + e.Message);
      end;
    end
    else if (fldPLU1.text <> '') and (fldCurrentCount.text <> '') and (fldNewCount.Text <> '')
      and (fldCurrentCount.text <> fldNewCount.Text) and AdjustData then
    begin
      AdjustData := false;
      Close();
      SQL.Clear();
      SQL.Add('Update PLU set OnHand = :pOnHand where PLUNo = :pPLUNo or UPC = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
      ParamByName('pOnHand').AsCurrency := strtofloat(fldNewCount.Text);
      try
        ExecSQL;
        Close();
        SQL.Clear();
        SQL.Add('Select * from InvAudit');
        open;
        RecordsReturned := RecordCount;
        Close();
        SQL.Clear();
        SQL.Add('Insert into InvAudit (SEQNO, USERNO, CHANGEDATE, PLUNO, ADJUSTMENT, BREAKDOWN, RECEIVE) ');
        if RecordsReturned > 0 then
          SQL.Add('Values ((Select Max(SeqNo) + 1 from InvAudit), :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 0, 0)')
        else
          SQL.Add('Values (1, :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 0, 0)');
        ParamByName('pUserNo').AsString := CurrentUserID;
        ParamByName('pChangeDate').AsDateTime := now;
        ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
        ParamByName('pAdjustment').AsInteger := strtoint(fldNewCount.Text) - strtoint(fldCurrentCount.Text);
        ExecSQL;
        BuildInvoiceField();
      except
        on E: Exception do
          showmessage('Error ' + e.Message);
      end;
    end
    //inv2...
//    else if (fldPLU1.text <> '') and (fldCurrentCount.text <> '') and (fldNewCount.Text <> '') and
//      ReceiveData then
//    begin
//      ReceiveData := false;
//      Close();
//      SQL.Clear();
//      SQL.Add('Select * from PLU where PLUNo = :pPLU or UPC = :pPLU');
//      ParamByName('pPLU').AsCurrency := strtofloat(fldPLU1.Text);
//      open;
//      if recordcount > 0 then
//      begin
//        if fieldbyname('OnHand').AsCurrency > 0 then
//          CurrentOnHand := fieldbyname('OnHand').AsInteger
//        else
//          CurrentOnHand := 0;
//        Close();
//        SQL.Clear();
//        SQL.Add('Update PLU set OnHand = :pOnHand + :pCount where PLUNo = :pPLU or UPC = :pPLU');
//        ParamByName('pOnHand').AsInteger := CurrentOnHand;
//        ParamByName('pCount').AsInteger := strtoint(fldNewCount.text);
//        ParamByName('pPLU').AsCurrency := strtofloat(fldPLU1.Text);
//        try
//          ExecSQL;
//          Memo1.Clear();
//          Memo1.Lines.Add('Item updated');
//          Close();
//          SQL.Clear();
//          SQL.Add('Select * from InvAudit');
//          open;
//          RecordsReturned := RecordCount;
//          Close();
//          SQL.Clear();
//          SQL.Add('Insert into InvAudit (SEQNO, USERNO, CHANGEDATE, PLUNO, ADJUSTMENT, BREAKDOWN, RECEIVE) ');
//          if RecordsReturned > 0 then
//            SQL.Add('Values ((Select Max(SeqNo) + 1 from InvAudit), :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 0, 1)')
//          else
//            SQL.Add('Values (1, :pUSERNO, :pCHANGEDATE, :pPLUNO, :pADJUSTMENT, 0, 1)');
//          ParamByName('pUserNo').AsString := CurrentUserID;
//          ParamByName('pChangeDate').AsDateTime := now;
//          ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
//          ParamByName('pAdjustment').AsInteger := strtoint(fldNewCount.text);
//          ExecSQL;
//        except
//          on E: Exception do
//            showmessage('Error ' + e.Message);
//        end;
//      end;
//    end;
    else if (fldPLU1.text <> '') and (fldNewCount.Text <> '') and AddData then
    begin
      AddData := false;
      // If a PLU # were entered (assume PLU #s have fewer digits), then convert to PLU value to UPC value.
      UPCTextToAdd := fldPLU1.text;  // Initial assumption
      if (Length(fldPLU1.Text) < 8) then
      begin
        POSDataMod.IBQryInventory.Close();
        POSDataMod.IBQryInventory.SQL.Clear();
        POSDataMod.IBQryInventory.SQL.Add('select UPC from PLU where PLUNo = :pPLUNo');
        POSDataMod.IBQryInventory.ParamByName('pPLUNo').AsCurrency := StrToCurr(fldPLU1.text);
        POSDataMod.IBQryInventory.Open();
        try
          if (POSDataMod.IBQryInventory.RecordCount > 0) then
            UPCTextToAdd := FormatFloat('000000000000', FieldByName('UPC').AsCurrency);
        except
          UpdateExceptLog('Inventory save - cannot convert PLU to UPC: "' + fldPLU1.text + '"');
          UPCTextToAdd := fldPLU1.text;
        end;
        POSDataMod.IBQryInventory.Close();
      end;  // if PLU entered
      AddPendingImportedInventory(UPCTextToAdd, ScanCountToAdd);
    end
    else if (ReceiveData) then
    begin
      ReceiveData := false;
      //inv4...
//      AdjustImportedInventory();
      AdjustImportedInventory(INV_SCAN_TYPE_RECEIVE);
      //...inv4
      InvoiceID := Trim(UpperCase(fldPLU1.Text));
    end;
    //..inv2
  end;
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;
  if POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.Commit;
  //inv2...
  SetUpGridOnHand();
  if (InvoiceID <> '') then
    PrintInventoryReport(InvoiceID);
  //...inv2
  Memo1.Clear();
  Memo1.Lines.Add('Inventory changes saved');
  SetScreen(IdleScreen);
  BuffPtr := 0;
  KeyBuff := '';
end;  // procedure btnSaveClick

procedure TfmInventoryInOut.ProcessScan1;
//inv2...
//begin
var
  sBreakdownLink : string;
  xPLUNo : currency;
  SmallUnit : string;
  LargeUnit : string;
begin
  SmallUnit := '';
  LargeUnit := '';
  try
    xPLUNo := strtofloat(fldPLU1.Text);
  except
    ShowMessage('PLU/UPC must be numeric');
    fldPLU1.SetFocus();
    exit;
  end;
//...inv2
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  if not POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory do
  begin
    Close();
    SQL.Clear();
//    SQL.Add('Select * from PLU where PLUNo = :pPLUNo or UPC = :pPLUNo');
    SQL.Add('Select * from PLU P left outer join InvUnits I on P.UnitID = I.UnitID');
    SQL.Add(' where PLUNo = :pPLUNo or UPC = :pPLUNo');

    //inv2...
//    ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU1.Text);
    ParamByName('pPLUNo').AsCurrency := xPLUNo;
    //...inv2
    open;
    if recordcount > 0 then
    begin
      LargeUnit := FieldByName('UnitName').AsString;
      if fieldbyname('OnHand').AsCurrency > 0 then
        fldCurrentCount.text := fieldbyname('OnHand').AsString
      else
        fldCurrentCount.text := '0';
      //inv2...
      try
        BreakDownLink := FieldByName('BreakdownLink').AsCurrency;
        BreakDownItemCount := FieldByName('BreakdownItemCount').AsInteger;
      except
        BreakDownLink := 0.0;
        BreakDownItemCount := 0;
      end;
      //...inv2
//      if fldPLU2.Visible then
//      begin
//        fldPLU2.SetFocus;
//        Memo1.Lines.Add('Scan To Item');
//      end
//      else
//      begin
//        fldNewCount.SetFocus;
//        if ReceiveData then
//          Memo1.Lines.Add('Enter received count')
//        else if AdjustData then
//          Memo1.Lines.Add('Enter new count');
//      end;
      if MoveData then
      begin
        fldPLU2.Text := '';
        fldToCount.Text := '';
        if (BreakDownLink <= 0.0) then
        begin
          Memo1.Lines.Add('ERROR: No breakdown link defined for PLU');
          fldPLU1.SetFocus;
        end
        else if (BreakDownItemCount <= 1) then
        begin
          Memo1.Lines.Add('ERROR: PLU does not break down into smaller items.');
          fldPLU1.SetFocus;
        end
        else // Valid breakdown case
        begin
          sBreakDownLink := FloatToStr(BreakDownLink);
          //fldPLU2.Text := sBreakDownLink;
          // Determine on hand inventory for linked item.
          POSDataMod.IBQryInventory2.Close();
          POSDataMod.IBQryInventory2.SQL.Clear();
//          POSDataMod.IBQryInventory2.SQL.Add('Select * from PLU where PLUNo = :pPLUNo or UPC = :pPLUNo');
          POSDataMod.IBQryInventory2.SQL.Add('Select * from PLU P left outer join InvUnits I on P.UnitID = I.UnitID');
          POSDataMod.IBQryInventory2.SQL.Add(' where PLUNo = :pPLUNo or UPC = :pPLUNo');
          POSDataMod.IBQryInventory2.ParamByName('pPLUNo').AsCurrency := BreakDownLink;
          POSDataMod.IBQryInventory2.Open();
          if (POSDataMod.IBQryInventory2.RecordCount > 0) then
          begin
            SmallUnit := POSDataMod.IBQryInventory2.FieldByName('UnitName').AsString;
            if (Length(Trim(fldPLU1.Text)) > 6) then fldPLU2.Text := POSDataMod.IBQryInventory2.FieldByName('UPC').AsString
                                                else fldPLU2.Text := POSDataMod.IBQryInventory2.FieldByName('PLUNo').AsString;
            fldToCount.Text := POSDataMod.IBQryInventory2.FieldByName('OnHand').AsString;
            MAXBreakdownPackagesOnHand := FieldByName('OnHand').AsInteger;
            if ((SmallUnit <> '') and (LargeUnit <> '')) then
              lblBreakdownDesc.Caption := '(MAX ' + trim(IntToStr(MAXBreakdownPackagesOnHand))+
                                          ') @ ' + trim(IntToStr(BreakDownItemCount)) + ' ' + SmallUnit + ' per ' + LargeUnit
            else if (LargeUnit <> '') then
              lblBreakdownDesc.Caption := '(MAX ' + trim(IntToStr(MAXBreakdownPackagesOnHand))+
                                          ') @ ' + trim(IntToStr(BreakDownItemCount)) + ' per ' + LargeUnit
            else
              lblBreakdownDesc.Caption := '(MAX ' + trim(IntToStr(MAXBreakdownPackagesOnHand))+
                                          ') @ ' + trim(IntToStr(BreakDownItemCount)) + ' per Package'
                                          ;
            lblBreakdownDesc.Visible := true;
            if (MAXBreakdownPackagesOnHand > 0) then
            begin
              Memo1.Lines.Add('Set count to move for breakdown.');
              fldCurrentCount.Text := '';
              fldCurrentCount.Enabled := true;
              fldCurrentCount.SetFocus;
            end
            else
            begin
              Memo1.Lines.Add('No cartons in inventory to breakdown.');
              fldPLU1.SetFocus;
            end;
          end
          else
          begin
            Memo1.Lines.Add('ERROR: Invalid breakdown link defined for PLU: ' + sBreakDownLink);
            fldPLU1.SetFocus;
          end;
          POSDataMod.IBQryInventory2.Close();
        end;
      end
      else if ReceiveData then
      begin
        Memo1.Lines.Add('Enter received count');
        fldNewCount.SetFocus;
      end
      else if AddData then
      begin
        Memo1.Lines.Add('Enter number of items recieved');
        fldNewCount.SetFocus;
      end
      else if AdjustData then
      begin
        Memo1.Lines.Add('Enter new count');
        fldNewCount.SetFocus;
      end;
    end
    //...inv2
    else
    begin
      Memo1.Lines.Add('PLU/UPC not found');
      fldPLU1.text := '';
      //inv2...
      lblPLU1Name.Caption := '';
      //...inv2
    end;
    close;
  end;
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;
  if POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.Commit;
end;  // procedure ProcessScan1

//inv2...
//procedure TfmInventoryInOut.ProcessScan2;
//begin
//  if not POSDataMod.IBDefaultTrans.InTransaction then
//    POSDataMod.IBDefaultTrans.StartTransaction;
//  with POSDataMod.IBQryTemp do
//  begin
//    Close;SQL.Clear;
//    SQL.Add('Select * from PLU where PLUNo = :pPLUNo or UPC = :pPLUNo');
//    ParamByName('pPLUNo').AsCurrency := strtofloat(fldPLU2.Text);
//    open;
//    if RecordCount > 0 then
//    begin
//      if fieldbyname('OnHand').AsCurrency > 0 then
//        fldToCount.text := fieldbyname('OnHand').AsString
//      else
//        fldToCount.text := '0';
//      fldCurrentCount.Enabled := true;
//      fldCurrentCount.Text := '';
//      fldCurrentCount.SetFocus;
//      Memo1.Lines.Add('Enter From Count and Select breakdown');
//      btnSave.Enabled := true;
//      btnCancel.Enabled := true;
//    end
//    else
//    begin
//      Memo1.Lines.Add('PLU/UPC not found');
//      fldPLU2.text := '';
//    end;
//    close;
//  end;
//  if POSDataMod.IBDefaultTrans.InTransaction then
//    POSDataMod.IBDefaultTrans.Commit;
//end;
//...inv2


procedure TfmInventoryInOut.btnMoveClick(Sender: TObject);
begin
  MoveData := true;
  ReceiveData := false;
  AddData := false;
  //inv5...
  UpdateData := false;
  //...inv5
  AdjustData := false;
  btnCancel.Enabled := true;
  SetScreen(MoveScreen);
  memo1.Clear();
  //inv2...
//  if fldPLU1.Text <> '' then
//  begin
//    Memo1.Lines.Add('Scan to item');
//    fldPLU2.SetFocus;
//  end
//  else
//  begin
//    Memo1.Lines.Add('Scan from item');
//    fldPLU1.SetFocus;
//  end;
  Memo1.Lines.Add('Scan from item to breakdown');
  fldPLU1.SetFocus;
  //...inv2
end;

procedure TfmInventoryInOut.SetScreen(ScreenToUse : byte);
begin
  case ScreenToUse of
    InitialScreen :
      begin
        //inv2...
//        grpBreakDown.Visible := false;
//        grpBreakDown.ItemIndex := -1;
        btnReceive.Enabled := bInventoryFunctionsAllowed;
        btnAdjust.Enabled := bInventoryFunctionsAllowed;
        btnMove.Enabled := bInventoryFunctionsAllowed;
        btnAddPending.Enabled := bInventoryFunctionsAllowed;
        lblBreakdownDesc.Visible := false;
        lblPLU1Name.Caption := '';
        //...inv2
        fldPLU2.Visible := false;
        fldToCount.Visible := false;
        LblToPLU.Visible := false;
        LblToCount.Visible := false;
        fldPLU1.Text := '';
        fldPLU1.Visible := true;
        LblCurrentCount.Caption := 'Current Count';
        fldCurrentCount.text := '';
        LblNewCount.Caption := 'New Count';
        fldNewCount.text := '';
        fldPLU2.text := '';
        fldToCount.text := '';
        fldNewCount.Visible := true;
        LblCurrentCount.Visible := true;

        btnSave.Enabled := false;
        btnCancel.Enabled := false;
        btnClose.Enabled := true;

        fldPLU1.Enabled := false;
        fldCurrentCount.Enabled := false;
        fldNewCount.Enabled := false;
        Memo1.Lines.Add('Select Receive, Adjust, Move or Close');
      end;
    IdleScreen :
      begin
        //inv2...
//        grpBreakDown.Visible := false;
//        grpBreakDown.ItemIndex := -1;
        btnReceive.Enabled := bInventoryFunctionsAllowed;
        btnAdjust.Enabled := bInventoryFunctionsAllowed;
        btnMove.Enabled := bInventoryFunctionsAllowed;
        btnAddPending.Enabled := bInventoryFunctionsAllowed;
        lblBreakdownDesc.Visible := false;
        lblPLU1Name.Caption := '';
        fldCurrentCount.Enabled := false;
        fldCurrentCount.Visible := true;
        //...inv2

        LblToPLU.Visible := false;
        LblToCount.Visible := false;
        LblFromPLU.Caption := 'PLU/UPC';
        LblCurrentCount.Caption := 'Current Count';
        LblCurrentCount.Visible := true;
        LblNewCount.Caption := 'New Count';
        LblNewCount.Visible := true;

        fldPLU2.Visible := false;
        fldToCount.Visible := false;
        fldPLU1.Text := '';
        fldPLU1.Visible := true;
        fldCurrentCount.text := '';
        LblNewCount.Caption := 'New Count';
        fldNewCount.text := '';
        fldPLU2.text := '';
        fldToCount.text := '';
        fldNewCount.Visible := true;
        //inv2...
//        fldPLU1.SetFocus;
        //...inv2

        btnSave.Enabled := false;
        btnCancel.Enabled := false;
        btnClose.Enabled := true;
        fldPLU1.Enabled := false;
        Memo1.Lines.Add('Select Receive, Adjust, Move or Close');
        //inv2...
        btnClose.SetFocus;
        //...inv2
      end;
    MoveScreen :
      begin
        //inv2...
//        grpBreakDown.Visible := true;
        btnReceive.Enabled := False;
        btnAdjust.Enabled := False;
        btnMove.Enabled := False;
        //...inv2
        btnAddPending.Enabled := false;
        LblCurrentCount.Caption := 'Count To Move';
        LblFromPLU.Caption := 'From PLU/UPC';
        LblToPLU.Caption := 'To PLU/UPC';
        fldCurrentCount.Text := '';

        fldPLU1.Enabled := true;
        //inv2...
//        fldPLU2.Enabled := true;
        //...inv2

        fldPLU2.Visible := true;
        fldToCount.Visible := true;
        LblToPLU.Visible := true;
        LblToCount.Visible := true;
        LblCurrentCount.visible := true;
        fldNewCount.Visible := false;
        LblNewCount.Visible := false;
      end;
    AdjustScreen :
      begin
        //inv2...
//        grpBreakDown.Visible := false;
//        grpBreakDown.ItemIndex := -1;
        btnReceive.Enabled := False;
        btnAdjust.Enabled := False;
        btnMove.Enabled := False;
        btnAddPending.Enabled := false;
        lblBreakdownDesc.Visible := false;
        lblPLU1Name.Caption := '';
        //...inv2

        LblToPLU.Visible := false;
        LblToCount.Visible := false;
        LblFromPLU.Caption := 'PLU/UPC';
        LblCurrentCount.Caption := 'Current Count';
        LblCurrentCount.Visible := true;
        LblNewCount.Caption := 'New Count';
        LblNewCount.Visible := true;

        fldPLU2.Visible := false;
        fldToCount.Visible := false;

        fldPLU1.Enabled := true;
        fldPLU1.Text := '';
        fldPLU1.Visible := true;

        fldCurrentCount.text := '';
        fldNewCount.Enabled := true;
        LblNewCount.Caption := 'New Count';
        fldNewCount.text := '';
        fldPLU2.text := '';
        fldToCount.text := '';
        fldNewCount.Visible := true;
        fldPLU1.SetFocus;

      end;
    ReceiveScreen :
      begin
        //inv2...
//        grpBreakDown.Visible := false;
//        grpBreakDown.ItemIndex := -1;
        btnReceive.Enabled := False;
        btnAdjust.Enabled := False;
        btnMove.Enabled := False;
        btnAddPending.Enabled := false;
        lblBreakdownDesc.Visible := false;
        lblPLU1Name.Caption := '';
        //...inv2

        LblToPLU.Visible := false;
        LblToCount.Visible := false;
        //inv2...
//        LblFromPLU.Caption := 'PLU/UPC';
//        LblCurrentCount.Caption := 'Current Count';
//        LblCurrentCount.Visible := true;
//        LblNewCount.Caption := 'New Count';
//        LblNewCount.Visible := true;
        LblFromPLU.Caption := 'Invoice';
        LblCurrentCount.Visible := false;
        LblNewCount.Visible := false;
        //...inv2

        fldPLU2.Visible := false;
        fldToCount.Visible := false;

        fldPLU1.Enabled := true;
        fldPLU1.Text := '';
        fldPLU1.Visible := true;

        fldCurrentCount.text := '';

        //inv2...
//        LblNewCount.Caption := 'Received Count';
//        fldNewCount.text := '';
//        fldNewCount.Enabled := true;
        fldCurrentCount.Visible := false;
        fldNewCount.Visible := false;
        fldNewCount.Enabled := false;
        //...inv2

        //inv2...
//        fldPLU2.text := '';
//        fldToCount.text := '';
//        fldNewCount.Visible := true;
        //...inv2
        fldPLU1.SetFocus;
      end;

    AddScreen :
      begin
        btnReceive.Enabled := False;
        btnAdjust.Enabled := False;
        btnMove.Enabled := False;
        btnAddPending.Enabled := false;
        lblBreakdownDesc.Visible := false;
        lblPLU1Name.Caption := '';
        LblToPLU.Visible := false;
        LblToCount.Visible := false;
        LblFromPLU.Caption := 'UPC to Add';
        LblCurrentCount.Caption := 'Current Count';
        LblCurrentCount.Visible := true;
        LblNewCount.Caption := 'Receive Count';
        LblNewCount.Visible := true;
        LblNewCount.Visible := true;
        fldPLU2.Visible := false;
        fldToCount.Visible := false;
        fldPLU1.Enabled := true;
        fldPLU1.Text := '';
        fldPLU1.Visible := true;
        fldCurrentCount.text := '';
        fldCurrentCount.Visible := true;
        fldNewCount.Visible := true;
        fldNewCount.Enabled := true;
        fldPLU1.SetFocus;
      end;
  end;//case
end;  // procedure SetScreen

procedure TfmInventoryInOut.POSButtonClick(Sender: TObject);
begin
  if (Sender is TPOSTouchButton) then
  begin
    sKeyType := TPOSTouchButton(Sender).KeyType ;
    sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
    sPreset  := TPOSTouchButton(Sender).KeyPreset ;
    ProcessKey;
  end;
end;


procedure TfmInventoryInOut.FormClose(Sender: TObject; var Action: TCloseAction);
var
  KeyNo : integer;
  //inv2...
  j : integer;
  qUPC : pUPCScanRecord;
  //...inv2
begin
  for KeyNo := 1 to 14 do
  begin
    POSButtons2[KeyNo].Free;
  end;
  //inv2...
  try
    for j := 0 to InitialUPCScannedList.Count - 1 do
    begin
      qUPC := InitialUPCScannedList.Items[j];
      Dispose(qUPC);
      InitialUPCScannedList.Items[j] := nil;
    end;  // for j := 0 to UPCList.Count - 1
    InitialUPCScannedList.Pack();
  except
  end;
  //...inv2
end;

procedure TfmInventoryInOut.BuildButton(RowNo, ColNo, KeyNo : short );
var
  TopKeyPos : short;
  KeyColOffset : short;
  sBtnColor : string;
  nBtnShape, nBtnCOlor : short;
  POSScreenSize : integer;

begin
  //Default
  TopKeyPos := 270;
  KeyColOffset := Trunc((fmInventoryInOut.Width - (3 * 65)) /2) ;
  if screen.width = 800 then
    POSScreenSize := 2
  else
    POSScreenSize := 1;
  case POSScreenSize of
  1: begin
       TopKeyPos := 270;
//       KeyColOffset := Trunc((fmInventoryInOut.Width - (3 * 65)) /2) ;
       KeyColOffset := 65;
     end;
  2: begin
       TopKeyPos := 210;  //20050722 - changed from 190
//       KeyColOffset := Trunc((fmInventoryInOut.Width - (3 * 50)) /2) ;
       KeyColOffset := 50;
     end;
  end;
  POSButtons2[KeyNo]             := TPOSTouchButton.Create(Self);
  POSButtons2[KeyNo].Parent      := Self;
  POSButtons2[KeyNo].Name        := 'Numbers' + IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons2[KeyNo].KeyRow      := RowNo;
  POSButtons2[KeyNo].KeyCol      := ColNo;
  case POSScreenSize of
  1: begin
       POSButtons2[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 65);
       POSButtons2[KeyNo].Left        := ((ColNo - 1) * 65) + KeyColOffset;
       POSButtons2[KeyNo].Height      := 60;
       POSButtons2[KeyNo].Width       := 60;
       POSButtons2[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
     end;
  2: begin
       POSButtons2[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 50);
       POSButtons2[KeyNo].Left        := ((ColNo - 1) * 50) + KeyColOffset;
       POSButtons2[KeyNo].Height      := 47;
       POSButtons2[KeyNo].Width       := 47;
       POSButtons2[KeyNo].Glyph.LoadFromResourceName(HInstance, 'BTN47');
     end;
  end;
  POSButtons2[KeyNo].Visible     := True;
  POSButtons2[KeyNo].OnClick     := POSButtonClick;
  POSButtons2[KeyNo].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons2[KeyNo].FrameStyle  := bfsNone;
  POSButtons2[KeyNo].WordWrap    := True;
  POSButtons2[KeyNo].Tag         := KeyNo;
  POSButtons2[KeyNo].NumGlyphs   := 14;
  POSButtons2[KeyNo].Frame       := 8;
  POSButtons2[KeyNo].MaskColor   := fmInventoryInOut.Color;
  POSButtons2[KeyNo].ShowHint := False;
  POSButtons2[KeyNo].Font.Name := 'Arial';
  POSButtons2[KeyNo].Font.Color := clBlack;
  POSButtons2[KeyNo].Font.Size := 10;
//  POSButtons2[KeyNo].Font.Style := [fsBold]

  if KeyNo = 10 then
  begin
    POSButtons2[KeyNo].KeyType := 'CLR - Clear';
    POSButtons2[KeyNo].Caption := 'Clear';
    sBtnColor := 'YELLOW';
    nBtnShape := 1;
  end
  else if KeyNo = 12 then
  begin
    POSButtons2[KeyNo].KeyType := 'ENT - Enter';
    POSButtons2[KeyNo].Caption := 'Enter';
    sBtnColor := 'RED';
    nBtnShape := 1;
  end
  else if KeyNo = 13 then
  begin
    POSButtons2[KeyNo].KeyType := 'NXT - Next';
    POSButtons2[KeyNo].Caption := 'Next';
    sBtnColor := 'WHITE';
    nBtnShape := 1;
  end
  else if KeyNo = 14 then
  begin
    POSButtons2[KeyNo].KeyType := 'BAK - Back';
    POSButtons2[KeyNo].Caption := 'Back';
    sBtnColor := 'WHITE';
    nBtnShape := 1;
  end
  else
  begin
    POSButtons2[KeyNo].KeyType := 'NUM';
    POSButtons2[KeyNo].Caption := KeyTops[KeyNo];
    POSButtons2[KeyNo].KeyVal  := KeyTops[KeyNo];
    sBtnColor := 'WHITE';
    nBtnShape := 2;
  end;
  nBtnColor := 6;
  if sBtnColor = 'BLUE' then
    nBtnColor := 1
  else if sBtnColor = 'GREEN' then
    nBtnColor := 2
  else if sBtnColor = 'RED' then
    nBtnColor := 3
  else if sBtnColor = 'WHITE' then
    nBtnColor := 4
  else if sBtnColor = 'MAGENTA' then
    nBtnColor := 5
  else if sBtnColor = 'CYAN' then
    nBtnColor := 6
  else if sBtnColor = 'YELLOW' then
    nBtnColor := 7 ;
  if nBtnShape = 1 then
    Inc(nBtnColor,7);
  POSButtons2[KeyNo].Frame := nBtnColor;
end;  // procedure BuildButton

procedure TfmInventoryInOut.ProcessKey;
//inv2...
var
  j : integer;
  TempCharArray :  array [0..1] of Char;
  TempString : string;
  LenField : integer;
//  UPCText : string;
//  ScanCount : integer;
//  OldScanCount : integer;
//  bUPCWasScanned : boolean;
//...inv2
begin
  if sKeyType = 'BAK' then
  begin
    //inv2...
//    if ReceiveData or AdjustData then
    if dbGridOnHand.Focused then
    begin
      //inv5...
//      if (dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) then
      if ((dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) and (ReceiveData or UpdateData)) then
      //...inv5
      begin
        TempString := dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row];
        LenField := Length(TempString);
        if (LenField > 0) then
        begin
          dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := Copy(TempString, 1, LenField - 1);
          dbGridOnHand.Refresh();
        end;
      end;
    end
    else if ReceiveData or AdjustData or AddData then
    //...inv2
    begin
      if fldPLU1.Focused then
      begin
        try
          if CheckUPC then
            ProcessScan1;
        except
          exit;
        end;
        if fldPLU1.Text <> '' then
          fldNewCount.SetFocus;
      end
      else if fldNewCount.Focused then
      begin
        try
          strtoint(fldNewCount.Text);
          //inv2...
          btnSave.Enabled := true;
          //...inv2
          btnSave.SetFocus;
        except
          if AdjustData then
            Memo1.Lines.Add('New count must be a number and cannot be blank')
          else if AddData then
            Memo1.Lines.Add('Added received count must be a number and cannot be blank')
          else if ReceiveData then
            Memo1.Lines.Add('Received count must be a number and cannot be blank');
          exit;
        end;
      end;
    end
    else if MoveData then
    begin
      if fldPLU1.Focused then
      begin
        try
          if CheckUPC then
            ProcessScan1;
//inv2          grpBreakDown.SetFocus;
        except
          exit;
        end
      end
      //inv2...
//      else if fldPLU2.Focused then
//      begin
//        try
//          if CheckUPC then
//            ProcessScan2;
//          fldPLU1.SetFocus;
//        except
//          exit;
//        end
//      end
      //...inv2
      else if fldCurrentCount.Focused then
      begin
        try
          strtoint(fldCurrentCount.Text);
          //inv2...
//          fldPLU2.SetFocus;
          fldPLU1.SetFocus;
          //...inv2
        except
          Memo1.Lines.Add('Count to move must be a number and cannot be blank');
          exit;
        end;
      end;
    end
    else
      Memo1.Lines.Add('You must select Receive, Adjust or Move prior to scanning!');
  end
  else if (sKeyType = 'ENT') or (sKeyType = 'NXT') then
  begin
    //inv2...
//    if (fldPLU1.Focused) or (fldPLU2.Focused) then
//    begin
//    if (dbGridOnHand.Focused) then
//    begin
//      if (dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) then
//      begin
//        try
//          ScanCount := StrToInt(dbGridOnHand.Cells[COLUMN_NUMBER_SCANNED, dbGridOnHand.Row]);
//        except
//          ScanCount := -1;
//        end;
//        if (ScanCount >= 0) then
//        begin
//          UPCText := dbGridOnHand.Cells[COLUMN_NUMBER_UPCTEXT, dbGridOnHand.Row];
//          if ((UPCText <> '') and (not (UPCText[1] in ['0'..'9']))) then
//            UPCText := Copy(UPCText, 2, Length(UPCText) - 1);  // Remove any prefix character added to display.
//          if not POSDataMod.IBDefaultTrans.InTransaction then
//            POSDataMod.IBDefaultTrans.StartTransaction;
//          try
//            POSDataMod.IBQryTemp.Close();
//            POSDataMod.IBQryTemp.SQL.Clear();
//            POSDataMod.IBQryTemp.SQL.Add('select ScanCount from InvUPCScanned');
//            POSDataMod.IBQryTemp.SQL.Add(' where UPCText = :pUPCText and AuditSeqNo = 0 and ScanType = :pScanType');
//            POSDataMod.IBQryTemp.ParamByName('pUPCText').AsString := UPCText;
//            POSDataMod.IBQryTemp.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
//            POSDataMod.IBQryTemp.Open();
//            bUPCWasScanned := (POSDataMod.IBQryTemp.RecordCount > 0);
//            if (bUPCWasScanned) then OldScanCount := POSDataMod.IBQryTemp.FieldByName('ScanCount').AsInteger
//            else                     OldScanCount := 0;
//            POSDataMod.IBQryTemp.Close();
//            POSDataMod.IBQryTemp.SQL.Clear();
//            if (ScanCount <> OldScanCount) then
//            begin
//              if (bUPCWasScanned) then
//              begin
//                POSDataMod.IBQryTemp.SQL.Add('update InvUPCScanned set ScanCount = :pScanCount');
//                POSDataMod.IBQryTemp.SQL.Add(' where UPCText = :pUPCText and AuditSeqNo = 0 and ScanType = :pScanType');
//              end
//              else
//              begin
//                POSDataMod.IBQryTemp.SQL.Add('insert into InvUPCScanned (UPCText, AuditSeqNo, ScanType, ImportTime, ScanCount)');
//                POSDataMod.IBQryTemp.SQL.Add(' Values (:pUPCText, 0, :pScanType, :pImportTime, :pScanCount)');
//                POSDataMod.IBQryTemp.ParamByName('pImportTime').AsDateTime := Now();
//              end;
//              POSDataMod.IBQryTemp.ParamByName('pScanCount').AsInteger := ScanCount;
//              POSDataMod.IBQryTemp.ParamByName('pUPCText').AsString := UPCText;
//              POSDataMod.IBQryTemp.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
//              POSDataMod.IBQryTemp.ExecSQL;
//              Memo1.Lines.Add('Scanned count for ' + UPCText + ' changed from ' + IntToStr(OldScanCount) + ' to ' + IntToStr(ScanCount));
//            end
//            else
//            begin
//              Memo1.Lines.Add('Scanned count already matches database value.');
//            end;
//          except
//            on E: Exception do
//              showmessage('Error ' + e.Message);
//          end;
//          if POSDataMod.IBDefaultTrans.InTransaction then
//            POSDataMod.IBDefaultTrans.Commit;
//        end
//        else
//        begin
//          Memo1.Lines.Add('ERROR: Scan count must be numeric.');
//        end;
//      end;
//    end
    if (fldPLU1.Focused) then
    begin
    //...inv2
      if ReceiveData then
      begin
        Memo1.Lines.Add('Select Save to increment inventory, or Cancel or Close');
        btnSave.Enabled := true;
        btnSave.SetFocus;
      end
      else
      begin
        try
          if CheckUPC then
            ProcessScan1;
        except
          Memo1.Lines.Add('Scan from item');
          fldPLU1.SetFocus;
        end;
      end;
    //inv2...
//      if fldPLU2.Focused then
//      try
//        if CheckUPC then
//          ProcessScan2;
//      except
//        Memo1.Lines.Add('Scan from item');
//        fldPLU2.SetFocus;
//      end;
//    end
    end
    else if MoveData  then
    begin
      btnSave.Enabled := false;   // will be reset if everything entered is OK.
      if fldPLU1.Text = '' then
      begin
        Memo1.Lines.Add('From PLU/UPC must be a number and cannot be blank');
        fldPLU1.SetFocus;
        exit;
      end
      else if fldPLU2.Text = '' then
      begin
        Memo1.Lines.Add('To PLU/UPC must be a number and cannot be blank');
        fldPLU1.SetFocus;
        exit;
      end
      else if fldCurrentCount.Text = '' then
      begin
        Memo1.Lines.Add('Count to move must be a number and cannot be blank');
        fldCurrentCount.SetFocus;
        exit;
      end

      else if fldCurrentCount.Text = '' then
      begin
        Memo1.Lines.Add('Count to move cannot be blank');
        fldCurrentCount.SetFocus;
        exit;
      end


      else
      begin
        // Verify count to move does not excede inventory on hand
        try
          j := StrToInt(fldCurrentCount.Text);
        except
          j := -1;
        end;
        if (j < 0) then
        begin
          Memo1.Lines.Add('Count to move must be a number');
          fldCurrentCount.SetFocus;
          exit;
        end
        else
        if (j > MAXBreakdownPackagesOnHand) then
        begin
          Memo1.Lines.Add('Count to move cannot be more than on hand: ' + IntToStr(MAXBreakdownPackagesOnHand));
          fldCurrentCount.SetFocus;
          exit;
        end
        else
        begin
          Memo1.Lines.Add('Select Save to update the package breakdown, or Cancel or Close');
          btnSave.Enabled := true;
          btnSave.SetFocus;
        end;
      end;
    end
    //...inv2
    else if fldCurrentCount.Focused then
    begin
      try
        strtoint(fldCurrentCount.Text);
      except
        fldCurrentCount.Text := '';
        Memo1.Lines.Add('Count to move must be a number and cannot be blank');
        exit;
      end
    end
    else if fldNewCount.Focused then
    begin
      try
        strtoint(fldNewCount.Text);
        //inv2...
//        if ReceiveData or AdjustData then
//          btnSave.SetFocus
//        else
//          grpBreakDown.SetFocus;
        if ReceiveData then
          Memo1.Lines.Add('Select Save to receive the inventory, or Cancel or Close')
        else if AddData then
          Memo1.Lines.Add('Select Save to include UPC in pending received list, or Cancel or Close')
        else if AdjustData then
          Memo1.Lines.Add('Select Save to adjust the inventory, or Cancel or Close');
        btnSave.Enabled := true;
        btnSave.SetFocus
        //...inv2
      except
        fldNewCount.Text := '';
        if ReceiveData then
          Memo1.Lines.Add('Received count must be a number and cannot be blank')
        else if AddData then
          Memo1.Lines.Add('Added pending received count must be a number and cannot be blank')
        else if AdjustData then
          Memo1.Lines.Add('New count must be a number and cannot be blank');
        exit;
      end;
    //inv2...
//    end
//    else if MoveData  then
//    begin
//      if (grpBreakDown.ItemIndex >= 0) and (fldPLU1.Text <> '') and
//        (fldPLU2.Text <> '') and (fldNewCount.Text <> '') then
//        btnSave.SetFocus
//      else if grpBreakDown.ItemIndex = -1 then
//      begin
//        Memo1.Lines.Add('Select a breakdown');
//        exit;
//      end
//      else if fldPLU1.Text = '' then
//      begin
//        Memo1.Lines.Add('From PLU/UPC must be a number and cannot be blank');
//        fldPLU1.SetFocus;
//        exit;
//      end
//      else if fldPLU2.Text = '' then
//      begin
//        Memo1.Lines.Add('To PLU/UPC must be a number and cannot be blank');
//        fldPLU2.SetFocus;
//        exit;
//      end
//      else if fldCurrentCount.Text = '' then
//      begin
//        Memo1.Lines.Add('Count to move must be a number and cannot be blank');
//        fldCurrentCount.SetFocus;
//        exit;
//      end;
    //...inv2
    end;


  end
  else if sKeyType = 'NUM' then
  begin
    //inv2...
//    if fldPLU1.Focused then
//      fldPLU1.Text := fldPLU1.Text + sKeyVal
    if (dbGridOnHand.Focused) then
    begin
      //inv5...
//      if (dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) then
      if ((dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) and (ReceiveData or UpdateData)) then
      //...inv5
      begin
        if (Length(dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row]) < 7) then
        begin
          dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] + sKeyVal;
          dbGridOnHand.Refresh();
        end
        else
        begin
          ShowMessage('Field full');
        end;
      end;
    end
    else if ((not MoveData) and (not AdjustData) and (not ReceiveData) and (not AddData)) then
    begin
      memo1.Lines.Add('Must select Receive, Add, Adjust, or Move prior to entering data.')
    end
    else if fldPLU1.Focused then
    begin
      if (fldPLU1.SelLength <= 0) then
      begin
        fldPLU1.Text := fldPLU1.Text + sKeyVal;
      end
      else
      begin
        TempCharArray[0] := sKeyVal[1];
        TempCharArray[1] := char(0);
        fldPLU1.SetSelTextBuf(TempCharArray);
      end;
    end
    //...inv2
    else if fldNewCount.Focused then
      fldNewCount.Text := fldNewCount.Text + sKeyVal
    //inv2...
//    else if fldToCount.Focused then
//      fldToCount.Text := fldToCount.Text + sKeyVal
//    else if fldPLU2.Focused then
//      fldPLU2.Text := fldPLU2.Text + sKeyVal
//    //...inv2
    else if fldCurrentCount.Focused then
      fldCurrentCount.Text := fldCurrentCount.Text + sKeyVal;
  end
  else if sKeyType = 'CLR' then
  Begin
    if fldPLU1.Focused then
    //inv2...
//      fldPLU1.Text := ''
    begin
      fldPLU1.Text := '';
      fldPLU2.Text := '';
      fldCurrentCount.Text := '';
      fldNewCount.Text := '';
      lblPLU1Name.Caption := '';
      lblBreakdownDesc.Caption := '';
    end
    else if dbGridOnHand.Focused then
    begin
      //inv5...
//      if (dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) then
      if ((dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) and (ReceiveData or UpdateData)) then
      //...inv5
      begin
        dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := '';
        dbGridOnHand.Refresh();
      end;
    end
    //...inv2
    else if fldNewCount.Focused then
      fldNewCount.Text := ''
    else if fldToCount.Focused then
      fldToCount.Text := ''
    //inv2...
//    else if fldPLU2.Focused then
//      fldPLU2.Text := ''
    //...inv2
    else if fldCurrentCount.Focused then
      fldCurrentCount.Text := '';
  end
  else if sKeyType = 'CLS' then
    close;
end; // procedure TfmInventoryInOut.ProcessKey

procedure TfmInventoryInOut.BuildTouchPad;
var
KeyNo, Row, Col : integer;
begin
  KeyNo := 1;
  for Row := 1 to 5 do
    for Col := 1 to 3 do
    begin
      if KeyNo <= 14 then
        BuildButton(Row, Col, KeyNo);
      Inc(KeyNo);
    end;
end;

procedure TfmInventoryInOut.FormShow(Sender: TObject);
begin
  BuildTouchPad;
  //inv2...
//  Memo1.Lines.Add('Select Receive, Adjust, Move or Close');
  SetupGridOnHand();
  BuildInvoiceField();
  //...inv2
  BuildDeptField();
end;

procedure TfmInventoryInOut.btnReceiveClick(Sender: TObject);
begin
  ReceiveData := true;
  AddData := false;
  //inv5...
  UpdateData := false;
  //...inv5
  Adjustdata := false;
  MoveData := false;
  btnCancel.Enabled := true;
  SetScreen(ReceiveScreen);
//inv5  DBGridOnHand.Enabled := True;
  memo1.Clear();
  if fldPLU1.Text = '' then
  begin
    //inv2...
//    Memo1.Lines.Add('Scan or manually enter an item');
    Memo1.Lines.Add('Enter invoice #');
    //...inv2
    fldPLU1.SetFocus;
  end;
end;

procedure TfmInventoryInOut.btnAdjustClick(Sender: TObject);
begin
  //inv7...
  if (bAllowMgrLock) then
  begin
    //...inv7
    AdjustData := true;
    ReceiveData := false;
    AddData := false;
    //inv5...
    UpdateData := false;
    //...inv5
    MoveData := false;
    btnCancel.Enabled := true;
    SetScreen(AdjustScreen);
    memo1.Clear();
    if fldPLU1.Text = '' then
    begin
      Memo1.Lines.Add('Scan or manually enter an item');
      fldPLU1.SetFocus;
    end;
  //inv7...
  end
  else
  begin
    Memo1.Lines.Add('Function not allowed for user.');
    ShowMessage('Function not allowed for user.');
  end;
  //...inv7
end;

procedure TfmInventoryInOut.fldNewCountChange(Sender: TObject);
begin
  if (fldNewCount.Text <> '') and (ReceiveData  or AdjustData or AddData)then
  begin
    //inv2...
//    btnSave.Enabled := true;
    //...inv2
    btnCancel.Enabled := true;
  end;
end;

function TfmInventoryInOut.CheckUPC : Boolean;
var
  Res : boolean;
  //inv2...
  xPLUNo : currency;
  //...inv2
begin
  if (fldPLU1.Focused) and (fldPLU1.Text = '') then
  begin
    Memo1.Lines.Add('PLU/UPC cannot be blank');
    Res := false;
  end
  //inv2...
//  else if (fldPLU2.Focused) and (fldPLU2.Text = '') then
//  begin
//    Memo1.Lines.Add('PLU/UPC cannot be blank');
//    Res := false;
//  end
//  else
//  begin
  else
  begin
    try
      xPLUNo := StrToFloat(fldPLU1.text);
    except
      Memo1.Lines.Add('PLU/UPC must be numeric');
      showmessage('PLU/UPC must be numeric');
      fldPLU1.SelectAll();
      fldPLU1.SetFocus();
      CheckUPC := false;
      exit;
    end;
  //...inv2
    if not POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.StartTransaction;
    with POSDataMod.IBQryInventory do
    begin
      Close();
      SQL.Clear();
      //inv2...
//      SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
//      if fldPLU1.Focused then
//        ParamByName('pPLUNo').AsString := fldPLU1.text
//      else if fldPLU2.Focused then
//        ParamByName('pPLUNo').AsString := fldPLU2.text;
      SQL.Add('Select * from PLU where PLUNo = :pPLUNo or UPC = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := xPLUNo;
      //...inv2
      open;
      if RecordCount = 0 then
      begin
        Res := false;
        close;
        //inv2...
        fldCurrentCount.Text := '';
        fldNewCount.Text := '';
        Memo1.Clear;
        Memo1.Lines.Add('PLU/UPC not on record.  Use SysMgr to add PLU.');
        //...inv2
        fldPLU1.text := '';
        lblPLU1Name.Caption := '';
      end
      else
      begin
        if fldPLU1.Focused then
          lblPLU1Name.Caption := FieldByName('Name').AsString;
        close;
        Res := true;
      end;
    end;  // with
    if POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.Commit;
  end;
  CheckUPC := Res;
end;  // function CheckUPC

//inv2...

procedure TfmInventoryInOut.SetUpGridOnHand();
var
//  sUPC : string;
//  LenUPC : integer;
  j : integer;
  LastScannedIndex : integer;
//  bWasScanned : boolean;
  sUPCScanned : string;
//  sUPCDefined : string;
//  xUPCScanned : double;
//  xUPCDefined : double;
  qUPC : pUPCScanRecord;
  TotalItemsScanned : integer;
begin
  TotalItemsScanned := 0;
  try
    for j := 0 to InitialUPCScannedList.Count - 1 do
    begin
      qUPC := InitialUPCScannedList.Items[j];
      Dispose(qUPC);
      InitialUPCScannedList.Items[j] := nil;
    end;  // for j := 0 to UPCList.Count - 1
    InitialUPCScannedList.Pack();
  except
  end;
  DBGridOnHand.Visible := False;
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  begin
    with POSDataMod.IBQryInventory do
    begin
      // Add all UPC items defined (in PLU table) and scanned for inventory.
      Close();
      SQL.Clear();
      (*
      SQL.Add('select  p.UPC, p.OnHand, h.OnHand as Scanned, p.Name from PLU p left outer join PLUScannedOnHand h');
      SQL.Add('on p.UPC = h.pluno where p.OnHand <> h.OnHand order by p.UPC');
      *)
      SQL.Add('select  u.UPCText, p.OnHand, u.ScanCount as Scanned, p.Name from PLU p left outer join InvUPCScanned u');
      SQL.Add(' on cast(p.UPC as double precision) = cast(u.UPCText as double precision) where u.AuditSeqNo = 0 and u.ScanType = 1 order by p.UPC');
      Open();
      dbGridOnHand.Cells[0,0]   := 'UPC';
      dbGridOnHand.Cells[1,0]   := 'On Hand';
      dbGridOnHand.Cells[2,0]   := 'Scanned';
      dbGridOnHand.Cells[3,0]   := 'Name';
      DBGridOnHand.RowCount     := 1;
      DBGridOnHand.ColWidths[0] := 100;
      DBGridOnHand.ColWidths[3] := 220;
      // Add a dummy record just to keep the indicies the same between dbGridonHand and InitialUPCScannedList.
      New(qUPC);
      qUPC^.UPCText := 'HEADER';
      qUPC^.ScanCount := FieldByName('OnHand').AsInteger;
      qUPC^.bScanned := true;
      InitialUPCScannedList.Add(qUPC);

      // process each record from the database
      while not eof do
      begin
        j := DBGridOnHand.RowCount;
        DBGridOnHand.RowCount := DBGridOnHand.RowCount + 1;
//        sUPC   := Trim(FieldByName('UPC').AsString);
//        LenUPC := Length(sUPC);
//        dbGridOnHand.Cells[0,j]   := Copy('0000000000000', 1, 13 - LenUPC) + sUPC;
        dbGridOnHand.Cells[0,j]   := Trim(FieldByName('UPCText').AsString);
        dbGridOnHand.Cells[1,j]   := FieldByName('OnHand').AsString;
        dbGridOnHand.Cells[2,j]   := FieldByName('Scanned').AsString;
        dbGridOnHand.Cells[3,j]   := FieldByName('Name').AsString;
        New(qUPC);
        qUPC^.UPCText := dbGridOnHand.Cells[0,j];
        qUPC^.ScanCount := FieldByName('Scanned').AsInteger;
        qUPC^.bScanned := true;
        Inc(TotalItemsScanned, qUPC^.ScanCount);
        InitialUPCScannedList.Add(qUPC);
        Next();
      end;

      // Add any UPC items scanned that are not defined in the PLU table.

      Close();
      SQL.Clear();
      (*
      SQL.Add('select  h.PLUNo, h.OnHand as Scanned from PLU p right outer join PLUScannedOnHand h');
      SQL.Add('on p.UPC = h.pluno where p.UPC is null order by h.PLUNo');
      *)
      SQL.Add('select  u.UPCText, u.ScanCount as Scanned from PLU p right outer join InvUPCScanned u');
      SQL.Add(' on cast(p.UPC as double precision) = cast(u.UPCText as double precision) where u.AuditSeqNo = 0 and u.ScanType = 1 and p.UPC is null order by u.UPCText');
      Open();
      while not eof do
      begin
        j := DBGridOnHand.RowCount;
        DBGridOnHand.RowCount := DBGridOnHand.RowCount + 1;
//        sUPC   := Trim(FieldByName('PLUNo').AsString);
//        LenUPC := Length(sUPC);
//        dbGridOnHand.Cells[0,j]   := '*' + Copy('0000000000000', 1, 13 - LenUPC) + sUPC;
        sUPCScanned := Trim(FieldByName('UPCText').AsString);
        dbGridOnHand.Cells[0,j]   := '*' + sUPCScanned;
        dbGridOnHand.Cells[1,j]   := 'MISSING';
        dbGridOnHand.Cells[2,j]   := FieldByName('Scanned').AsString;
        dbGridOnHand.Cells[3,j]   := '';
        New(qUPC);
        qUPC^.UPCText := sUPCScanned;
        qUPC^.ScanCount := FieldByName('Scanned').AsInteger;
        qUPC^.bScanned := true;
        Inc(TotalItemsScanned, qUPC^.ScanCount);
        InitialUPCScannedList.Add(qUPC);
        Next();
      end;

      Close();
      SQL.Clear();
      LastScannedIndex := DBGridOnHand.RowCount - 1;
      (*
      // Add all defined UPC values (in PLU table) that were not scanned for inventory.

//      SQL.Add('select  p.UPC, p.OnHand, p.Name from InvUPCScanned u right outer join PLU p');
//      SQL.Add(' on p.UPC = cast(u.UPCText as float) where u.UPCText is null order by p.UPC');
      LastScannedIndex := DBGridOnHand.RowCount - 1;
      SQL.Add('select  UPC, OnHand, Name from PLU order by UPC');
      Open();
      while not eof do
      begin
        bWasScanned := False;  // initial assumption
        // Only add if not added above.
        sUPCDefined   := Trim(FieldByName('UPC').AsString);
        try
          xUPCDefined := StrToFloat(sUPCDefined);
        except
          xUPCDefined := 0;
        end;
        if (xUPCDefined > 0) then
        begin
          for j := 1 to LastScannedIndex do
          begin
            sUPCScanned   := dbGridOnHand.Cells[0,j];
            if ((Length(sUPCScanned) > 0) and (sUPCScanned[1] in ['0'..'9'])) then
            begin
              try
                xUPCScanned := StrToFloat(sUPCScanned);
              except
                xUPCScanned := 0;
              end;
            end
            else
            begin
              xUPCScanned := 0;
            end;
            if (xUPCScanned = xUPCDefined) then
            begin
              bWasScanned := True;
              break;
            end;
          end;
        end;
        if ((xUPCDefined > 0) and (not bWasScanned)) then
        begin
          j := DBGridOnHand.RowCount;
          DBGridOnHand.RowCount := DBGridOnHand.RowCount + 1;
//          LenUPC := Length(sUPCDefined);
          dbGridOnHand.Cells[0,j]   := '+' + sUPCDefined;
          dbGridOnHand.Cells[1,j]   := FieldByName('OnHand').AsString;
          dbGridOnHand.Cells[2,j]   := 'NO SCAN';
          dbGridOnHand.Cells[3,j]   := FieldByName('Name').AsString;
          New(qUPC);
          qUPC^.UPCText := sUPCDefined;
          qUPC^.ScanCount := 0;
          qUPC^.bScanned := false;
          InitialUPCScannedList.Add(qUPC);
        end;
        next;
      end;
      *)

      if (LastScannedIndex > 0) then
      begin
        lblOnHandDifference.Caption := IntToStr(TotalItemsScanned) + ' items imported pending next inventory receive:';
        dbGridOnHand.FixedRows := 1;
        DBGridOnHand.Visible := true;
        DBGridOnHand.Refresh;
      end
      else
      begin
        lblOnHandDifference.Caption := 'No items pending an inventory receive.';
      end;
//      DBGridOnHand.Enabled := True;
//      DBGridOnHand.Visible := True;
      Close();
    end;
  end;
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;
end;  // procedure SetUpGridOnHand

procedure TfmInventoryInOut.AddPendingImportedInventory(const UPCTextToAdd : string; const ScanCountToAdd : integer);
var
  bInvRecordExists : boolean;
  ScanCount : integer;
begin
  try
    POSDataMod.IBQryInventory.Close();
    POSDataMod.IBQryInventory.SQL.Clear();
    POSDataMod.IBQryInventory.SQL.Add('select ScanCount from InvUpcScanned');
    POSDataMod.IBQryInventory.SQL.Add(' where AuditSeqNo = 0 and ScanType = :pScanType and UPCText = :pUPCText');
    POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
    POSDataMod.IBQryInventory.ParamByName('pUPCText').AsString := UPCTextToAdd;
    POSDataMod.IBQryInventory.Open();
    bInvRecordExists := (POSDataMod.IBQryInventory.RecordCount > 0);
    if (bInvRecordExists) then ScanCount := POSDataMod.IBQryInventory.FieldByName('ScanCount').AsInteger
    else                       ScanCount := 0;
    Inc(ScanCount, ScanCountToAdd);
    POSDataMod.IBQryInventory.Close();
    POSDataMod.IBQryInventory.SQL.Clear();
    if (bInvRecordExists) then
    begin
      POSDataMod.IBQryInventory.SQL.Add('update InvUPCScanned set ScanCount = :pScanCount');
      POSDataMod.IBQryInventory.SQL.Add(' where UPCText = :pUPCText and AuditSeqNo = 0 and ScanType = :pScanType');
    end
    else
    begin
      POSDataMod.IBQryInventory.SQL.Add('insert into InvUPCScanned (UPCText, AuditSeqNo, ScanType, ImportTime, ScanCount)');
      POSDataMod.IBQryInventory.SQL.Add(' Values (:pUPCText, 0, :pScanType, :pImportTime, :pScanCount)');
      POSDataMod.IBQryInventory.ParamByName('pImportTime').AsDateTime := Now();
    end;
    POSDataMod.IBQryInventory.ParamByName('pScanCount').AsInteger := ScanCount;
    POSDataMod.IBQryInventory.ParamByName('pUPCText').AsString := UPCTextToAdd;
    POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
    POSDataMod.IBQryInventory.ExecSQL;
  except
    on E: Exception do
    begin
      ShowMessage('Error ' + e.Message);
      if POSDataMod.IBQryInventory.Transaction.InTransaction then
        POSDataMod.IBQryInventory.Transaction.RollBack;
    end;
  end;  // try/except
  POSDataMod.IBQryInventory.Close();
end;  // procedure AddPendingImportedInventory()

//inv4...
//procedure TfmInventoryInOut.AdjustImportedInventory();
procedure TfmInventoryInOut.AdjustImportedInventory(const ScanType : integer);
//...inv4
var
  AuditSeqNo : integer;
//  bInvAuditHasRecords : boolean;
  bOnHandIsNull : boolean;
  sUPC : string;
  xUPC : currency;
  xPLUNo : currency;
  ChangeDate : TDateTime;
  InvoiceID : string;
begin
  ChangeDate := Now();
  InvoiceID := UpperCase(fldPLU1.Text);
//  if not POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.StartTransaction;
  try
    // Determine next available audit sequence number
    POSDataMod.IBQryInventory.Close();
    POSDataMod.IBQryInventory.SQL.Clear();
    POSDataMod.IBQryInventory.SQL.Add('Select Max(SeqNo) as MaxSeqNo from InvAudit');
    POSDataMod.IBQryInventory.Open();
    AuditSeqNo := POSDataMod.IBQryInventory.FieldByName('MaxSeqNo').AsInteger;
    // Select all unprocessed "receive" records from a prior inventory scanner import.
    POSDataMod.IBQryInventory.Close();
    POSDataMod.IBQryInventory.SQL.Clear();
    POSDataMod.IBQryInventory.SQL.Add('select * from InvUpcScanned');
    POSDataMod.IBQryInventory.SQL.Add(' where AuditSeqNo = 0 and ScanType = :pScanType and ScanCount is not null');
    POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
    POSDataMod.IBQryInventory.Open();
    while (not POSDataMod.IBQryInventory.Eof) do
    begin
      sUPC := POSDataMod.IBQryInventory.FieldByName('UPCText').AsString;
      if (Trim(sUPC) <> '') then xUPC := StrToFloat(sUPC)
      else                       xUPC := 0;
      if (xUPC > 0) then
      begin
        //inv4...
        if (ScanType = INV_SCAN_TYPE_RECEIVE) then
        begin
        //...inv4
          // Determine if on hand count is currently null (treat this value as a zero count)
          POSDataMod.IBQryInventory2.Close();
          POSDataMod.IBQryInventory2.SQL.Clear();
          POSDataMod.IBQryInventory2.SQL.Add('Select count(*) as OnHandIsNull from plu where upc = :pUPC and OnHand is null');
          POSDataMod.IBQryInventory2.ParamByName('pUPC').AsCurrency := xUPC;
          POSDataMod.IBQryInventory2.Open();
          bOnHandIsNull := (POSDataMod.IBQryInventory2.FieldByName('OnHandIsNull').AsInteger > 0);
          POSDataMod.IBQryInventory2.Close();
        //inv4...
        end
        else  // i.e., this is a full update.
        begin
          bOnHandIsNull := true;  // Actually, the OnHand column may not be null, but it will just be replaced.
        end;
        //...inv4
        // Update the item's on hand count.
        POSDataMod.IBQryInventory2.Close();
        POSDataMod.IBQryInventory2.SQL.Clear();
        if (bOnHandIsNull) then
          POSDataMod.IBQryInventory2.SQL.Add('update plu set onhand = :pOnHand where upc = :pUPC')
        else
          POSDataMod.IBQryInventory2.SQL.Add('update plu set OnHand = OnHand + :pOnHand where UPC = :pUPC');
        POSDataMod.IBQryInventory2.ParamByName('pOnHand').AsInteger := POSDataMod.IBQryInventory.FieldByName('ScanCount').AsInteger;
        POSDataMod.IBQryInventory2.ParamByName('pUPC').AsCurrency := xUPC;
        POSDataMod.IBQryInventory2.ExecSQL;
        // Leave an audit trail for the inventory update.
        POSDataMod.IBQryInventory2.Close();
        POSDataMod.IBQryInventory2.SQL.Clear();
        POSDataMod.IBQryInventory2.SQL.Add('select PLUNo from PLU where UPC = :pUPC');
        POSDataMod.IBQryInventory2.ParamByName('pUPC').AsCurrency := xUPC;
        POSDataMod.IBQryInventory2.Open();
        if (POSDataMod.IBQryInventory2.RecordCount > 0) then
          xPLUNo := POSDataMod.IBQryInventory2.FieldByName('PLUNo').AsCurrency
        else
          xPLUNo := xUPC;
        POSDataMod.IBQryInventory2.Close();
        POSDataMod.IBQryInventory2.SQL.Clear();
//        POSDataMod.IBQryTemp2.SQL.Add('Select count(*) as InvAuditRecords from InvAudit');
//        POSDataMod.IBQryTemp2.Open();
//        bInvAuditHasRecords := (POSDataMod.IBQryTemp2.FieldByName('InvAuditRecords').AsInteger > 0);
//        POSDataMod.IBQryTemp2.Close();
//        POSDataMod.IBQryTemp2.SQL.Clear();
        POSDataMod.IBQryInventory2.SQL.Add('Insert into InvAudit (SeqNo, UserNo, ChangeDate, PLUNo, UPCText, Adjustment, Breakdown, Receive, InvoiceID) ');
//        if (bInvAuditHasRecords) then
//          POSDataMod.IBQryTemp2.SQL.Add('Values ((Select Max(SeqNo) + 1 from InvAudit), :pUserNo, :pChangeDate, :pPLUNo, :pUPCText, :pAdjustment, 0, 1, :pInvoiceID)')
//        else
//          POSDataMod.IBQryTemp2.SQL.Add('Values (SeqNo, :pUserNo, :pChangeDate, :pPLUNo, :pAdjustment, 0, 1, :pInvoiceID)');
        //inv4...
//        POSDataMod.IBQryInventory2.SQL.Add('Values (:pSeqNo, :pUserNo, :pChangeDate, :pPLUNo, :pUPCText, :pAdjustment, 0, 1, :pInvoiceID)');
        POSDataMod.IBQryInventory2.SQL.Add('Values (:pSeqNo, :pUserNo, :pChangeDate, :pPLUNo, :pUPCText, :pAdjustment, 0, :pReceive, :pInvoiceID)');
        //...inv4
        Inc(AuditSeqNo);
        POSDataMod.IBQryInventory2.ParamByName('pSeqNo').AsInteger := AuditSeqNo;
        POSDataMod.IBQryInventory2.ParamByName('pUserNo').AsString := CurrentUserID;
        POSDataMod.IBQryInventory2.ParamByName('pChangeDate').AsDateTime := ChangeDate;
        POSDataMod.IBQryInventory2.ParamByName('pPLUNo').AsCurrency := xPLUNo;
        POSDataMod.IBQryInventory2.ParamByName('pUPCText').AsString := sUPC;
        POSDataMod.IBQryInventory2.ParamByName('pAdjustment').AsInteger := POSDataMod.IBQryInventory.FieldByName('ScanCount').AsInteger;
        //inv4...
        if (ScanType = INV_SCAN_TYPE_RECEIVE) then
          POSDataMod.IBQryInventory2.ParamByName('pReceive').AsInteger := 1
        else
          POSDataMod.IBQryInventory2.ParamByName('pReceive').AsInteger := 0;
        //...inv4
        POSDataMod.IBQryInventory2.ParamByName('pInvoiceID').AsString := InvoiceID;
        POSDataMod.IBQryInventory2.ExecSQL;
        // Link audit record with scanned record.
        POSDataMod.IBQryInventory2.Close();
        POSDataMod.IBQryInventory2.SQL.Clear();
        POSDataMod.IBQryInventory2.SQL.Add('update InvUpcScanned set AuditSeqNo = :pAuditSeqNo');
        POSDataMod.IBQryInventory2.SQL.Add(' where AuditSeqNo = 0 and UPCText = :pUPCText and ScanType = :pScanType and ScanCount is not null');
        POSDataMod.IBQryInventory2.ParamByName('pAuditSeqNo').AsInteger := AuditSeqNo;
        POSDataMod.IBQryInventory2.ParamByName('pUPCText').AsString := sUPC;
        POSDataMod.IBQryInventory2.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
        POSDataMod.IBQryInventory2.ExecSQL;
      end;
      POSDataMod.IBQryInventory.Next();
    end;  // while

  except
    on E: Exception do
    begin
      ShowMessage('Error ' + e.Message);
      if POSDataMod.IBQryInventory.Transaction.InTransaction then
        POSDataMod.IBQryInventory.Transaction.RollBack;
      if POSDataMod.IBQryInventory2.Transaction.InTransaction then
        POSDataMod.IBQryInventory2.Transaction.RollBack;
    end;
  end;  // try/except
  POSDataMod.IBQryInventory.Close();
  BuildInvoiceField();
//  if POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.Commit;
end;  // procedure AdjustImportedInventory

procedure TfmInventoryInOut.UpdateScanCounts();
{
Update any modifications made to the scan counts from the screen showig each UPC
}
var
  j : integer;
  ScanCountOnGrid : integer;
  qUPC : pUPCScanRecord;
begin
//  if not POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.StartTransaction;
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  try
    // Process each row on the screen (row 0 is a header row).
    for j := 1 to Min(dbGridOnHand.RowCount, InitialUPCScannedList.Count) - 1 do
    begin
      // Determine the scan count indicated on the screen
      qUPC := InitialUPCScannedList.Items[j];
      {$IFDEF DEV_TEST}
      if (qUPC^.UPCText = 'xyz') then
        showmessage('TEST:  UPCText = ' + qUPC^.UPCText);
      {$ENDIF}
      if ((Length(dbGridOnHand.Cells[2, j]) > 0) and (dbGridOnHand.Cells[2, j][1] in ['0'..'9'])) then
      begin
        try
          ScanCountOnGrid := StrToInt(dbGridOnHand.Cells[2, j]);
        except
          ScanCountOnGrid := qUPC^.ScanCount;  // Prevents an attempt to update this entry in the database.
        end;
      end
      else
      begin
        ScanCountOnGrid := 0;
      end;
      // Process only rows that changed
      if (ScanCountOnGrid <> qUPC^.ScanCount) then
      begin
        POSDataMod.IBQryInventory.Close();
        POSDataMod.IBQryInventory.SQL.Clear();
        if (qUPC^.bScanned) then
        begin
          POSDataMod.IBQryInventory.SQL.Add('update InvUPCScanned set ScanCount = :pScanCount');
          POSDataMod.IBQryInventory.SQL.Add(' where UPCText = :pUPCText and AuditSeqNo = 0 and ScanType = :pScanType');
        end
        else
        begin
          POSDataMod.IBQryInventory.SQL.Add('insert into InvUPCScanned (UPCText, AuditSeqNo, ScanType, ImportTime, ScanCount)');
          POSDataMod.IBQryInventory.SQL.Add(' Values (:pUPCText, 0, :pScanType, :pImportTime, :pScanCount)');
          POSDataMod.IBQryInventory.ParamByName('pImportTime').AsDateTime := Now();
        end;
        POSDataMod.IBQryInventory.ParamByName('pScanCount').AsInteger := ScanCountOnGrid;
        POSDataMod.IBQryInventory.ParamByName('pUPCText').AsString := qUPC^.UPCText;
        POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
        POSDataMod.IBQryInventory.ExecSQL;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error ' + e.Message);
      if POSDataMod.IBQryInventory.Transaction.InTransaction then
        POSDataMod.IBQryInventory.Transaction.RollBack;
    end;
  end;  // try/except
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;
end;  // procedure UpdateScanCounts

procedure TfmInventoryInOut.dbGridOnHandSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := true;
end;

//...inv2

procedure TfmInventoryInOut.btnScannerExportClick(Sender: TObject);
var
  FilePath  : string;
  FileName : string;
  EODExportPath : string;
  OutFile : TextFile;
begin

  EODExportPath := '';
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory do
  begin
    Close();
    SQL.Clear();
    SQL.Add('Select EODExportPath from Setup');
    open;
    if (RecordCount > 0) then
      EODExportPath := Trim(FieldByName('EODExportPath').AsString);
    close;
  end;

  FilePath := '\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude';     // Default assumption
  if (EODExportPath <> '') then
  begin
    if (DirectoryExists(EODExportPath)) then
    begin
      FilePath := EODExportPath;
    end
    else
    begin
      MkDir(EODExportPath);
      if (IOResult = 0) then
        FilePath := EODExportPath;
    end;
  end;

  FileName := FilePath + '\UPCExport.txt';
  AssignFile(OutFile, FileName);
  ReWrite(OutFile);

  with POSDataMod.IBQryInventory do
  begin
    Close();
    SQL.Clear();
    SQL.Add('Select UPC from PLU order by UPC');
    open;
    while (not EOF) do
    begin
      WriteLn(OutFile, FormatFloat('000000000000', FieldByName('UPC').AsCurrency));
      next();
    end;
    close;
  end;

  CloseFile(OutFile);
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;
end;  // procedure btnScannerExportClick

procedure TfmInventoryInOut.btnScannerImportClick(Sender: TObject);
var
  FilePath  : string;
  FileName : string;
  //inv4...
  FileName2 : string;
  //...inv4
  EODExportPath : string;
  InvScanType : integer;
  //inv4...
//begin
  bReceiveImport : boolean;
  bFullImport : boolean;
begin
  bReceiveImport := false;  // initial assumption
  bFullImport := false;     // initial assumption
  //...inv4

  EODExportPath := '';
  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory do
  begin
    Close();
    SQL.Clear();
    SQL.Add('Select EODExportPath from Setup');
    open;
    if (RecordCount > 0) then
      EODExportPath := Trim(FieldByName('EODExportPath').AsString);
    close;
  end;
  if POSDataMod.IBQryInventory.Transaction.InTransaction then
    POSDataMod.IBQryInventory.Transaction.Commit;

  FilePath := '\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude';     // Default assumption
  if (EODExportPath <> '') then
  begin
    if (DirectoryExists(EODExportPath)) then
    begin
      FilePath := EODExportPath;
    end
    else
    begin
      MkDir(EODExportPath);
      if (IOResult = 0) then
        FilePath := EODExportPath;
    end;
  end;

  FileName := FilePath + '\UPCImport.txt';
  if (FileExists(FileName)) then
  begin
    InvScanType := INV_SCAN_TYPE_RECEIVE;
    ImportScannedInventory(FileName, InvScanType);
  //inv4...
//  end  //   if (FileExists(FileName))
//  else
//  begin
//    ShowMessage('No Import File:  ' + FileName);
//  end;
    bReceiveImport := true;
  end;

  FileName2 := FilePath + '\UPCImportFull.txt';
  if (FileExists(FileName2)) then
  begin
    InvScanType := INV_SCAN_TYPE_FULL;
    ImportScannedInventory(FileName, InvScanType);
    bFullImport := true;
  end;

  if (bFullImport and bReceiveImport) then
    Memo1.Lines.Add('Both Full and Receive import files processed.')
  else if (bFullImport) then
    Memo1.Lines.Add('Full import files processed.')
  else if (bReceiveImport) then
    Memo1.Lines.Add('Receive import files processed.')
  else
    ShowMessage('No Import File:  ' + FileName);
  //...inv4
//  if POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.Commit;
  SetupGridOnHand();
end;  // procedure btnScannerImportClick

procedure TfmInventoryInOut.ImportScannedInventory(const InvFileName : string; const InvScanType : integer);
var
  InRecord : string;
  //inv6...
  UPCText : string;
  ItemCountIncrement : integer;
  IdxComma : integer;
  //...inv6
  InFile : TextFile;
  ImportTimestamp : TDateTime;
  UPCList : TList;
  j : integer;
  UPCFound : boolean;
  qUPC : pUPCScanRecord;
begin
  ImportTimestamp := Now();
  AssignFile(InFile, InvFileName);
  ReSet(InFile);

  UPCList := TList.Create();
  UPCList.Clear();


  // Read the file and count the number of times each UPC is represented.

  while (not eof(InFile)) do
  begin
    ReadLn(InFile, InRecord);
    //inv6...
    IdxComma := Pos(',', InRecord);
    if ((IdxComma > 0) and (IdxComma < Length(InRecord))) then
    begin
      UPCText := Copy(InRecord, 1, IdxComma - 1);
      try
        ItemCountIncrement := StrToInt(Copy(InRecord, IdxComma + 1, Length(InRecord) - IdxComma));
      except
        ItemCountIncrement := 1;
      end;
    end
    else
    begin
      UPCText := InRecord;
      ItemCountIncrement := 1;
    end;
    //...inv6
    UPCFound := False;
    for j := UPCList.Count - 1 downto 0 do
    begin
      qUPC := UPCList.Items[j];
      //inv6...
//      if (qUPC^.UPCText = InRecord) then
//      begin
//        Inc(qUPC^.ScanCount);
      if (qUPC^.UPCText = UPCText) then
      begin
        Inc(qUPC^.ScanCount, ItemCountIncrement);
      //...inv6
        UPCFound := True;
      end;
    end;  // for j := UPCList.Count - 1 downto 0
    if (not UPCFound) then
    begin
      New(qUPC);
      //inv6...
//      qUPC^.UPCText := InRecord;
//      qUPC^.bScanned := true;
//      qUPC^.ScanCount := 1;
      qUPC^.UPCText := UPCText;
      qUPC^.bScanned := true;
      qUPC^.ScanCount := ItemCountIncrement;
      //...inv6
      UPCList.Add(qUPC);
    end;
  end;  // while (not eof(InFile))

  try
    if not POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.StartTransaction;
    POSDataMod.IBQryInventory.Close();
    POSDataMod.IBQryInventory.SQL.Clear();
    POSDataMod.IBQryInventory.SQL.Add('delete from InvUPCScanned where AuditSeqNo = 0 and ScanType = :pScanType');
    POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := InvScanType;
    POSDataMod.IBQryInventory.ExecSQL;
    if POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.Commit;

    if not POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.StartTransaction;
    for j := 0 to UPCList.Count - 1 do
    begin
      qUPC := UPCList.Items[j];
      POSDataMod.IBQryInventory.Close();
      POSDataMod.IBQryInventory.SQL.Clear();
      POSDataMod.IBQryInventory.SQL.Add('insert into InvUPCScanned (UPCText, AuditSeqNo, ScanType, ImportTime, ScanCount)');
      POSDataMod.IBQryInventory.SQL.Add(' values (:pUPCText, 0, :pScanType, :pImportTime, :pScanCount)');
      POSDataMod.IBQryInventory.ParamByName('pUPCText').AsString := qUPC^.UPCText;
      POSDataMod.IBQryInventory.ParamByName('pScanType').AsInteger := INV_SCAN_TYPE_RECEIVE;
      POSDataMod.IBQryInventory.ParamByName('pImportTime').AsDateTime := ImportTimestamp;
      POSDataMod.IBQryInventory.ParamByName('pScanCount').AsInteger := qUPC^.ScanCount;
      POSDataMod.IBQryInventory.ExecSQL;
    end;  // for j := 0 to UPCList.Count - 1
    if POSDataMod.IBQryInventory.Transaction.InTransaction then
      POSDataMod.IBQryInventory.Transaction.Commit;

  except
    on E: Exception do
    begin
      ShowMessage('Error ' + e.Message);
      if POSDataMod.IBQryInventory.Transaction.InTransaction then
        POSDataMod.IBQryInventory.Transaction.RollBack;
    end;
  end;
  POSDataMod.IBQryInventory.Close();
  CloseFile(InFile);
  try
    for j := 0 to UPCList.Count - 1 do
    begin
      qUPC := UPCList.Items[j];
      Dispose(qUPC);
      UPCList.Items[j] := nil;
    end;  // for j := 0 to UPCList.Count - 1
    UPCList.Pack();
  except
  end;
  try
    UPCList.Destroy;
  except
  end;
end;  // procedure ImportScannedInventory

procedure TfmInventoryInOut.BuildInvoiceField();
var
  InvoiceID : string;
  ChangeDate : TDateTime;
begin
  if not POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory2 do
  begin
    Close();
    SQL.Clear();
    SQL.Add('select distinct InvoiceID, ChangeDate from InvAudit');
    SQL.Add(' where InvoiceID is not null order by ChangeDate');
    Open();
    fldInvoiceID.Clear();
    fldInvoiceID.Items.Add('<SELECT PRIOR INVOICE TO PRINT>');
    while not eof do
    begin
      InvoiceID := FieldByName('InvoiceID').AsString;
      ChangeDate := FieldByName('ChangeDate').AsDateTime;
      fldInvoiceID.Items.Add(Format('%-*.*s ', [MAX_INVOICE_WIDTH, MAX_INVOICE_WIDTH, InvoiceID]) + FormatDateTime('yyyy/mm/dd hh:mm', ChangeDate));
      Next();
    end;  // while not eof
  end; // with
  if POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.Commit;
  fldInvoiceID.ItemIndex := 0;
end;  // procedure BuildInvoiceField

procedure TfmInventoryInOut.BuildDeptField();
var
  DeptNo : integer;
  DeptName : string;
begin
  if not POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.StartTransaction;
  with POSDataMod.IBQryInventory2 do
  begin
    Close();
    SQL.Clear();
    SQL.Add('select DeptNo, Name from Dept order by DeptNo');
    Open();
    fldDeptToPrint.Clear();
    fldDeptToPrint.Items.Add('<SELECT DEPARTMENT FOR REPORT>');
    while not eof do
    begin
      DeptNo := FieldByName('DeptNo').AsInteger;
      DeptName := FieldByName('Name').AsString;
      fldDeptToPrint.Items.Add(Format('%*.*d - %-s', [LEN_DEPTNO_FIELD, LEN_DEPTNO_FIELD, DeptNo, DeptName]));
      Next();
    end;  // while not eof
  end; // with
  if POSDataMod.IBQryInventory2.Transaction.InTransaction then
    POSDataMod.IBQryInventory2.Transaction.Commit;
  fldDeptToPrint.ItemIndex := 0;
end;  // procedure BuildDeptField


procedure TfmInventoryInOut.btnPrintPriorInvoiceClick(Sender: TObject);
var
  InvoiceID : string;
begin
//  if not POSDataMod.IBQryInventory.Transaction.InTransaction then
//    POSDataMod.IBQryInventory.Transaction.StartTransaction;
  //AdjustImportedInventory();
  if (fldInvoiceID.ItemIndex > 0) then
  begin
    InvoiceID := Trim(Copy(fldInvoiceID.Items[fldInvoiceID.ItemIndex], 1, MAX_INVOICE_WIDTH));
    PrintInventoryReport(InvoiceID);
  end
  else
  begin
    ShowMessage('Must Select Invoice');
  end;
//  PrintInventoryReport('INV200511221300');
//  ShowMessage('Test for print inventory received report');
//  if POSDataMod.IBQryInventory.Transaction.InTransaction then
//    POSDataMod.IBQryInventory.Transaction.Commit;
  //SetupGridOnHand();
end;

procedure TfmInventoryInOut.fldPLU1Click(Sender: TObject);
begin
  btnSave.Enabled := false;
end;

procedure TfmInventoryInOut.fldCurrentCountClick(Sender: TObject);
begin
  btnSave.Enabled := false;
end;

procedure TfmInventoryInOut.fldNewCountClick(Sender: TObject);
begin
  btnSave.Enabled := false;
end;

procedure TfmInventoryInOut.fldPLU1KeyPress(Sender: TObject;
  var Key: Char);
const
  CARRIAGE_RETURN_BYTE = $0D;
begin
  if (byte(key) = CARRIAGE_RETURN_BYTE) then
  begin
    sKeyType := 'ENT';
    ProcessKey();
  end;
end;

procedure TfmInventoryInOut.dbGridOnHandKeyPress(Sender: TObject;
  var Key: Char);
begin
//  if ((dbGridOnHand.Row >= 0) and (dbGridOnHand.Row < dbGridOnHand.RowCount) and
//      (dbGridOnHand.Col >= 0) and (dbGridOnHand.Col < dbGridOnHand.ColCount)    ) then
//  dbGridOnHand.Cells[dbGridOnHand.Row, dbGridOnHand.Col] := dbGridOnHand.Cells[dbGridOnHand.Row, dbGridOnHand.Col] + Key;
end;

procedure TfmInventoryInOut.dbGridOnHandKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
//var
//  TempString : string;
//  LenField : integer;
begin
  if ((dbGridOnHand.Row >= 1) and (dbGridOnHand.Row < dbGridOnHand.RowCount) and
      (dbGridOnHand.Col = COLUMN_NUMBER_SCANNED) and (dbGridOnHand.Col < dbGridOnHand.ColCount) ) then  // Only allow change of "scanned" column
  begin
    if ((Key >= Byte('0')) and (Key <= Byte('9'))) then
    begin
//      if (Length(dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row]) < 7) then
//      begin
//        SetLength(TempString, 1);
//        TempString[1] := char(Key);
//        dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] + TempString;
//        dbGridOnHand.Refresh();
      SetLength(sKeyVal, 1);
      sKeyVal[1] := char(Key);
      sKeyType := 'NUM';
      ProcessKey();
//      end
//      else
//      begin
//        ShowMessage('Field full');
//      end;
    end
    else if (Key = VK_BACK) then
    begin
//      TempString := dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row];
//      LenField := Length(TempString);
//      if (LenField > 0) then
//      begin
//        dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := Copy(TempString, 1, LenField - 1);
//        dbGridOnHand.Refresh();
//      end;
      sKeyType := 'BAK';
      ProcessKey();
    end
    else if (Key = VK_DELETE) then
    begin
//      dbGridOnHand.Cells[dbGridOnHand.Col, dbGridOnHand.Row] := '';
//      dbGridOnHand.Refresh();
      sKeyType := 'CLR';
      ProcessKey();
    end;
  end;

end;  // procedure dbGridOnHandKeyUp


procedure TfmInventoryInOut.dbGridOnHandExit(Sender: TObject);
begin
  {$IFDEF DEV_TEST}
//inv5  ShowMessage('dbGridOnHandExit - enter');
  {$ENDIF}
end;

procedure TfmInventoryInOut.ProcessScan(PLUNo : string);
begin
  if fldPLU1.Focused then
  begin
    fldPLU1.text := PLUNo;
    ProcessScan1;
//  end
//  else if fldPLU2.Focused then
//  begin
//    fldPLU2.text := PLUNo;
//    ProcessScan2;
  end;
end;


procedure TfmInventoryInOut.btnPrintDeptInventoryClick(Sender: TObject);
var
  DeptNo : integer;
  DeptName : string;
begin
  if (fldDeptToPrint.ItemIndex > 0) then
  begin
    try
      DeptNo := StrToInt(Trim(Copy(fldDeptToPrint.Items[fldDeptToPrint.ItemIndex], 1, LEN_DEPTNO_FIELD)));
      DeptName := Trim(Copy(fldDeptToPrint.Items[fldDeptToPrint.ItemIndex], LEN_DEPTNO_FIELD + 4, MAX_DEPT_NO_WIDTH));
      PrintInventoryDeptReport(DeptNo, DeptName);
    except
      ShowMessage('Format error on dept: ' + fldDeptToPrint.Items[fldDeptToPrint.ItemIndex]);
    end;
  end
  else
  begin
    ShowMessage('Must Select Department');
  end;
end;

procedure TfmInventoryInOut.btnAddPendingClick(Sender: TObject);
begin
  ReceiveData := false;
  AddData := true;
  UpdateData := false;
  Adjustdata := false;
  MoveData := false;
  btnCancel.Enabled := true;
  SetScreen(AddScreen);
  memo1.Clear();
  if fldPLU1.Text = '' then
  begin
    Memo1.Lines.Add('Enter/scan UPC to add to pending receive list.');
    fldPLU1.SetFocus;
  end;

end;

procedure TfmInventoryInOut.FormDestroy(Sender: TObject);
begin
  DisposeTListItems(InitialUPCScannedList);
  try
    FreeAndNil(InitialUPCScannedList);
  except
  end;
end;

end.

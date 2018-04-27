unit SelectSuspend;

{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  {$IFDEF CISP_CODE}
  Encrypt,
  {$ENDIF}
  Dialogs, ElastFrm, StdCtrls, Buttons;

type
  TfmSuspend = class(TForm)
    LBSuspend: TListBox;
    btnSelectSuspended: TBitBtn;
    ElasticForm1: TElasticForm;
    btnClose: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSelectSuspendedClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmSuspend: TfmSuspend;

implementation
uses POSDM, LatTypes, POSMain;
{$R *.dfm}

procedure TfmSuspend.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmSuspend.FormShow(Sender: TObject);
var
  LastTransNo : string;
begin
  LBSuspend.Clear;
  if not POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.StartTransaction;
  with POSDataMod.IBSuspendQry do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from SuspendSale Order by TransactionNo, SeqNumber');
    Open;
    LastTransNo := '0';
    if RecordCount > 0 then
    begin
      while not eof do
      begin
        if LastTransNo <> fieldbyname('TransactionNo').AsString then
          LBSuspend.Items.Add(Format('%-10s',[fieldbyname('TransactionNo').AsString]) +
            Format('%-22s',[FieldByName('SaleName').AsString]) +
            Format('%4s',[FieldByName('Qty').AsString]) +
            Format('%10s',[(formatFloat('#,###.00;#,###.00-',fieldbyname('ExtPrice').AsCurrency))]));
        LastTransNo := fieldbyname('TransactionNo').AsString;
        Next;
      end;
    end;
    Close;
  end;
  if POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.Commit;
end;

procedure TfmSuspend.btnSelectSuspendedClick(Sender: TObject);
var
  j : integer;
  CurSaleData : pSalesData;
begin
  if LBSuspend.SelCount <> 0 then
  begin
    if not POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.StartTransaction;
    with POSDataMod.IBSuspendQry do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from SuspendSale where TransactionNo = :pTransNo order by SeqNumber');
      parambyname('pTransNo').AsString := Copy(trim(LBSuspend.Items[LBSuspend.ItemIndex]),1,10);
      Open;
      while not eof do
      begin
        New(CurSaleData);
        ZeroMemory(CurSaleData, sizeof(TSalesData));
        curSale.nTransNo := fieldByName('TransactionNo').AsInteger;
        CurSaleData^.SeqNumber := fieldByName('SeqNumber').AsInteger;
        CurSaleData^.LineType := fieldByName('LineType').AsString;
        CurSaleData^.SaleType := fieldByName('SaleType').AsString;
        CurSaleData^.Number := fieldByName('SaleNo').AsCurrency;
        CurSaleData^.Name := fieldByName('SaleName').AsString;
        CurSaleData^.Qty := fieldByName('Qty').AsCurrency;
        CurSaleData^.Price := fieldByName('Price').AsCurrency;
        CurSaleData^.ExtPrice := fieldByName('ExtPrice').AsCurrency;
        CurSaleData^.SavDiscable := fieldByName('SavDiscable').AsCurrency;
        CurSaleData^.SavDiscAmount := fieldByName('SavDiscAmount').AsCurrency;
        CurSaleData^.PumpNo := fieldByName('PumpNo').AsInteger;
        CurSaleData^.HoseNo := fieldByName('HoseNo').AsInteger;
        CurSaleData^.FuelSaleID := fieldByName('FuelSaleID').AsInteger;

        CurSaleData^.TaxNo := fieldByName('TaxNo').AsInteger;
        CurSaleData^.TaxRate := fieldByName('TaxRate').AsCurrency;
        CurSaleData^.Taxable := fieldByName('Taxable').AsCurrency;
        CurSaleData^.Discable := boolean(fieldByName('Disc').AsInteger);
        CurSaleData^.LineVoided := Boolean(fieldByName('Linevoided').AsInteger);

        CurSaleData^.WEXCode := fieldByName('WEXCode').AsInteger;
        CurSaleData^.PHHCode := fieldByName('PHHCode').AsInteger;
        CurSaleData^.IAESCode := fieldByName('IAESCode').AsInteger;
        CurSaleData^.VoyagerCode := fieldByName('VoyagerCode').AsInteger;

        CurSaleData^.CCAuthCode := fieldByName('CCAuthCode').AsString;
        CurSaleData^.CCApprovalCode := fieldByName('CCApprovalCode').AsString;
        CurSaleData^.CCDate := fieldByName('CCDate').AsString;
        CurSaleData^.CCTime := fieldByName('CCTime').AsString;
        CurSaleData^.CCCardNo := fieldByName('CCCardNo').AsString;
        {$IFDEF CISP_CODE}
        if (fmPOS.UseCISPEncryption(Setup.CreditAuthType)) then
        begin
          // Note:  Field for ccCardNo is to short to encrypt.  Once field is widened, it can be encrypted.
          CurSaleData^.CCCardName := DecryptString(FieldByName('CCCardName').AsString);
          CurSaleData^.CCExpDate := DecryptString(FieldByName('CCExpDate').AsString);
        end
        else
        {$ENDIF}
        begin
          CurSaleData^.CCCardName := fieldByName('CCCardName').AsString;
          CurSaleData^.CCExpDate := fieldByName('CCExpDate').AsString;
        end;
        CurSaleData^.CCCardType := fieldByName('CCCardType').AsString;
        CurSaleData^.CCBatchNo := fieldByName('CCBatchNo').AsString;
        CurSaleData^.CCSeqNo := fieldByName('CCSeqNo').AsString;
        CurSaleData^.CCEntryType := fieldByName('CCEntryType').AsString;
        CurSaleData^.CCVehicleNo := Trim(fieldByName('CCVehicleNo').AsString);    //20060906c (added trim)
        CurSaleData^.CCOdometer := Trim(fieldByName('CCOdometer').AsString);      //20060906c (added trim)
        for j := low(CurSaleData^.CCPrintLine) to high(CurSaleData^.CCPrintLine) do
          CurSaleData^.CCPrintLine[j] := fieldByName('CCPrintLine' + IntToStr(j)).AsString;
        CurSaleData^.CCBalance1 := fieldByName('CCBalance1').AsCurrency;
        CurSaleData^.CCBalance2 := fieldByName('CCBalance2').AsCurrency;
        CurSaleData^.CCBalance3 := fieldByName('CCBalance3').AsCurrency;
        CurSaleData^.CCBalance4 := fieldByName('CCBalance4').AsCurrency;
        CurSaleData^.CCBalance5 := fieldByName('CCBalance5').AsCurrency;
        CurSaleData^.CCBalance6 := fieldByName('CCBalance6').AsCurrency;
        CurSaleData^.CCRequestType := fieldByName('CCRequestType').AsInteger;
        CurSaleData^.CCAuthID := fieldByName('CCAuthID').AsInteger;
        CurSaleData^.PLUModifier := FieldByName('PLUModifier').AsInteger;
        CurSaleData^.PLUModifierGroup := FieldByName('PLUModifierGroup').AsCurrency;
        try
          CurSaleData^.ActivationState := TActivationState(FieldByName('ActivationState').AsInteger);  // asActivationDoesNotApply;
        except
          CurSaleData^.ActivationState := asActivationDoesNotApply;
        end;
        CurSaleData^.ActivationTransNo := FieldByName('ActivationTransNo').AsInteger;
        CurSaleData^.ActivationTimeout := FieldByName('ActivationTimeout').AsDateTime;
        CurSaleData^.LineID := FieldByName('LineID').AsInteger;
        CurSaleData^.ccPIN := FieldByName('CCPIN').AsString;
        fmPos.CurSaleList.Capacity := fmPos.CurSaleList.Count;
        fmPos.CurSaleList.Add(CurSaleData);
        fmPOS.DisplaySuspend(CurSaleData);
        Next;
      end;
      Close;SQL.Clear;
      SQL.Add('Delete from SuspendSale where TransactionNo = :pTransNo');
      parambyname('pTransNo').AsInteger := curSale.nTransNo;
      ExecSQL;
    end;
    if POSDataMod.IBSuspendTrans.InTransaction then
      POSDataMod.IBSuspendTrans.Commit;
    Close;
  end
  else
    ShowMessage('Select a sale');
end;

end.

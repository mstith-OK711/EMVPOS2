unit Kiosk;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TKioskFrame = class(TFrame)
  private
    { Private declarations }
    function VerifyConnection : boolean;
    function CheckPLU(KioskDesc : string; KioskPLU : Double; KioskPrice : Currency) : Boolean;
//20060922a    procedure InsertPLU(KioskDesc : string; KioskPLU : Double; KioskPrice : Currency);
  public
    { Public declarations }
    function KioskActive : Boolean;
    function GetKioskSale : Byte;
    procedure KioskComplete;
    procedure KioskPaid(OrderNo : Integer);
  end;



implementation
uses
  POSDM, POSMain, ExceptLog, ADODB,
  LatTypes,
  //20070621b Added connection message
  POSMsg;
{$R *.dfm}

var
  BuildConnectionString : string;
  KioskDeptNo, KioskTaxNo : Integer;

function TKioskFrame.VerifyConnection : boolean;
var
  Ret : Boolean;
  DBName,
  DBSource,
  DBUserName,
  DBPassword : string;
begin
  if not POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.StartTransaction;
  with POSDataMod.IBQryKiosk do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Kiosk');
    Open;
    DBName := FieldByName('DBName').AsString;
    DBSource := FieldByName('DBSource').AsString;
    DBUserName := FieldByName('DBUserName').AsString;
    DBPassword := FieldByName('DBPassWord').AsString;
    KioskDeptNo := FieldByName('DeptNo').AsInteger;
    KioskTaxNo := FieldByName('TaxNo').AsInteger;
    Close;
  end;
  BuildConnectionString := 'Provider=SQLOLEDB;Initial Catalog=' + DBName + ';Data Source=' + DBSource;
  if POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.Commit;
  if not POSDataMod.KioskConn.Connected then
  begin
    POSDataMod.KioskConn.ConnectionString := BuildConnectionString;
    try
      POSDataMod.KioskConn.Open( DBUserName, DBPassWord);
      if POSDataMod.KioskConn.Connected then
        Ret := True
      else
        Ret := False;
    except
      Ret := False;
    end;
  end
  else
  begin
    Ret := True;
  end;
  VerifyConnection := Ret;
end;

function TKioskFrame.KioskActive : Boolean;
var
  Ret : Boolean;
begin
  if not POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.StartTransaction;
  with POSDataMod.IBQryKiosk do
  begin
    Close;SQL.Clear;
    SQL.Add('Select FoodKiosk from Setup');
    Open;
    if Boolean(FieldByName('FoodKiosk').AsInteger) then
      Ret := true
    else
      Ret := False;
    Close;
  end;
  if POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.Commit;
  //20070621b... Added a message when attempting to connect to Kiosk database
  if Ret then
  begin
    fmPOSMsg.ShowMsg('Verifying Kiosk connection', '');
    KioskActive := VerifyConnection;
    fmPOSMsg.Close;
  end
  //...20070621b
  else
    KioskActive := Ret;
end;

function TKioskFrame.GetKioskSale : byte;
var
  Ret : Byte;
begin
  if not VerifyConnection then
  begin
    UpdateExceptLog('Unable to connect to Kiosk DB');
    Ret := 0;//False
  end
  else
  try
    with POSDataMod.KioskQry do
    begin
      POSDataMod.KioskQry.parameters.ParamByName('@I_OR_ID').Value := KioskOrderNo;
      Open;
      if RecordCount > 0 then
      begin
        Ret := 1;//True
        while not eof do
        begin
          if not Boolean(FieldByName('OR_PAIDFLAG').AsInteger) then
          begin
            KioskPLU := FieldByName('mi_number').Value;
            KioskPLUPrice := FieldByName('mi_price').Value;
            KioskPLUDesc := fieldbyname('mi_description').Value;
            KioskOrderNo := FieldByName('or_id').Value;
            sLineType := 'PLU';
            sSaleType := 'Sale';
//20060922a            if not CheckPLU(KioskPLUDesc, KioskPLU, KioskPLUPrice) then
//20060922a              InsertPLU(KioskPLUDesc, KioskPLU, KioskPLUPrice);
            fmPOS.ProcessKioskPLU(FloatToStr(KioskPLU), '')
          end
          else
          begin
            Ret := 2;//Order Paid;
            break;
          end;
          Next;
        end;
      end
      else
      begin
        Ret := 0;//False
      end;
      Close;
      KioskOrderNo := 0;
    end;
  except
    on E: Exception do
    begin
      UpdateExceptLog('Exception: '+ E.Message);
      Ret := 0;//False
    end;
  end;
  GetKioskSale := Ret;
end;

function TKioskFrame.CheckPLU(KioskDesc : string; KioskPLU : Double; KioskPrice : Currency) : Boolean;
var
  Ret : Boolean;
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
    SQL.Add(' and (DelFlag = 0 or DelFlag is null)');  //20070213a
    parambyname('pPLUNo').AsCurrency := KioskPLU;
    Open;
    if RecordCount > 0 then
    begin
      Close;SQL.Clear;
      SQL.Add('Update PLU set Name = :pName, Price = :pPrice where PLUNo = :pPLUNo');
      parambyname('pPLUNo').AsCurrency := KioskPLU;
      parambyname('pName').AsString := Copy(trim(KioskDesc),1,30);
      parambyname('pPrice').AsCurrency := KioskPrice;
      ExecSQL;
      Ret := true
    end
    else
      Ret := False;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  CheckPLU := Ret;
end;
//20060922a...
//procedure TKioskFrame.InsertPLU(KioskDesc : string; KioskPLU : Double; KioskPrice : Currency);
//begin
//  if not POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.StartTransaction;
//  with POSDataMod.IBTempQuery do
//  begin
//    Close;SQL.Clear;
//    SQL.Add('Insert into PLU (PLUNo, Name, DeptNo, Price, TaxNo, Disc) ');
//    SQL.Add('Values (:pPLUNo, :pName, :pDeptNo, :pPrice, :pTaxNo, 1) ');
//    parambyname('pPLUNo').AsCurrency := KioskPLU;
//    parambyname('pName').AsString := Copy(trim(KioskDesc),1,30);
//    parambyname('pDeptNo').AsInteger := KioskDeptNo;
//    parambyname('pPrice').AsCurrency := KioskPrice;
//    parambyname('pTaxNo').AsInteger := KioskTaxNo;
//    ExecSQL;
//  end;
//  if POSDataMod.IBTransaction.InTransaction then
//    POSDataMod.IBTransaction.Commit;
//end;
//...20060922a

procedure TKioskFrame.KioskComplete;
var
  SaleListNdx : Byte;
  CurSaleData : pSalesData;
begin
  if fmPos.CurSaleList.Count > 0 then
  begin
    for SaleListndx := 0 to fmPos.CurSaleList.Count - 1 do
    begin
      CurSaleData := fmPos.CurSaleList.Items[SaleListndx];
      if Copy(CurSaleData^.CCPrintLine[1],1,1) = 'K' then
        KioskPaid(strtoint(copy(CurSaleData^.CCPrintLine[1],2,Length(CurSaleData^.CCPrintLine[1]) -1)));
    end;
  end;
end;

procedure TKioskFrame.KioskPaid(OrderNo : Integer);
begin
  if not VerifyConnection then
  begin
    UpdateExceptLog('Unable to connect to Kiosk DB');
  end
  else
  try
    with POSDataMod.KioskCompleteQry do
    begin
      POSDataMod.KioskCompleteQry.parameters.ParamByName('@I_OR_ID').Value := OrderNo;
      ExecProc;
    end;
  except
    on E: Exception do
    begin
      UpdateExceptLog('Kiosk Paid Update Failed OrderNo:  '+ IntToStr(OrderNo) + ' ' + E.Message);
    end;
  end;
end;

end.

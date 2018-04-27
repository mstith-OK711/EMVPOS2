unit Test_SaleClasses;

interface

uses
  TestFramework,
  SysUtils,
  JclHashMapsCustom,
  IBDatabase,
  SaleClasses;

type

CRACK_TPOSConnector = class(TPOSConnector);

CRACK_TSale = class(TSale);

CRACK_TSaleLine = class(TSaleLine);

CRACK_TDeptLine = class(TDeptLine);

CRACK_TPLULine = class(TPLULine);

TTPCTestCase = class(TTestCase)
private
  FDB : TIBDatabase;
  FTran : TIBTransaction;
  FSQLB : TIBSqlBuilder;
  FPC : TPOSConnector;
  FTransNo : Currency;
public
  procedure setUp; override;
  procedure tearDown; override;
  procedure GetTransNo(var Value : Currency);
end;

Check_TPOSConnector = class(TTPCTestCase)
published
   procedure VerifyStartTransaction;
   procedure VerifyCommit;
   procedure VerifyRollback;
end;

Check_TSale = class(TTPCTestCase)
private
  FSale : TSale;
public
   procedure setUp;  override;
   procedure tearDown; override;
published
   procedure VerifyAdd;
   procedure VerifyGet;
end;

Check_TSaleLine = class(TTPCTestCase)
private
  FSale : TSale;
  FSaleLine : TSaleLine;
public
   procedure setUp;  override;
   procedure tearDown; override;
published
  procedure VerifyQty;
  procedure VerifyPrice;
  procedure VerifyCost;
  procedure VerifyExtPrice;
  procedure VerifyVoid;
  procedure VerifyLineType;
end;

Check_TDeptLine = class(TTPCTestCase)
private
  FSale : TSale;
  FSaleLine : TDeptLine;
  FError : string;
  procedure POSError (const S : string);
public
  procedure setUp;  override;
  procedure tearDown; override;
published
  procedure VerifyTransactionClosed;
  procedure VerifyCreateTaxableGrocery;
  procedure VerifyMerge;
  procedure VerifyPopulateReceipt;
end;

Check_TPLULine = class(TTPCTestCase)
private
  FSale : TSale;
  FSaleLine : TPLULine;
  FError : string;
  procedure POSError (const S : string);
public
   procedure setUp;  override;
   procedure tearDown; override;
published
  procedure VerifyTransactionClosed;
  procedure VerifyMerge;
  procedure VerifyPopulateReceipt;
  procedure VerifyQtyDiscount;
end;

function Suite : ITestSuite;

implementation

uses
  StrUtils, TestExtensions, DBInt;

function Suite : ITestSuite;
begin
  result := TTestSuite.Create('SaleClasses Tests');

  result.addTest(Check_TPOSConnector.Suite);

  result.addTest(Check_TSale.Suite);

  result.addTest(Check_TSaleLine.Suite);

  result.addTest(Check_TDeptLine.Suite);
//  result.AddTest(TRepeatedTest.Create(Check_TDeptLine.Create('VerifyCreateTaxableGrocery'),20));

  result.addTest(Check_TPLULine.Suite);
end;

procedure TTPCTestCase.GetTransNo(var Value: Currency);
begin
  Value := Self.FTransNo;
  Self.FTransNo := Self.FTransNo + 1;
end;

procedure TTPCTestCase.setUp;
begin
  // set up database connection
  Self.FDB := TIBDatabase.Create(nil);
  Self.FDB.LoginPrompt := False;
  Self.FDB.SQLDialect := 1;
  Self.FDB.DatabaseName := 'C:\Latitude\Data\RSGDATA.GDB';
  Self.FDB.Params.Clear();
  Self.FDB.Params.Add('user_name=rsgretail');
  Self.FDB.Params.Add('password=pos');
  Self.FDB.Open();
  // set up transaction
  Self.FTran := TIBTransaction.Create(Self.FDB);
  Self.FTran.AddDatabase(Self.FDB);

  Self.FSQLB := TIBSqlBuilder.Create(Self.FDB, Self.FTran);
  Self.FPC := TPOSConnector.Create(Self.FSQLB);
  Self.FPC.AssignTransNo := Self.GetTransNo;
  Self.FTransNo := 1;
end;

procedure TTPCTestCase.tearDown;
begin
  Self.FDB.Close();
end;

procedure Check_TPOSConnector.VerifyStartTransaction;
begin
  Self.FPC.StartTransaction();
  if not Self.FTran.InTransaction then
    fail('Started Transaction, yet we''re not in one.')
  else
    Self.FTran.Rollback;
end;

procedure Check_TPOSConnector.VerifyCommit;
begin
  Self.FPC.StartTransaction();
  Self.FPC.Commit();
  if Self.FTran.InTransaction then
    fail('Committed transaction, yet we''re still in one.');
end;

procedure Check_TPOSConnector.VerifyRollback;
begin
  Self.FPC.StartTransaction();
  Self.FPC.Rollback();
  if Self.FTran.InTransaction then
    fail('Rolled back transaction, yet we''re still in one.');
end;

procedure Check_TSale.setUp;
begin
  inherited;
  Self.FSale := TSale.Create(Self.FPC);
end;

procedure Check_TSale.tearDown;
begin
  inherited;
  Self.FSale.Free();
end;

procedure Check_TSale.VerifyAdd;
begin
   fail('Test Not Implemented Yet');
end;

procedure Check_TSale.VerifyGet;
begin
   fail('Test Not Implemented Yet');
end;

procedure Check_TSaleLine.setUp;
begin
  inherited;
  Self.FSale := TSale.Create(Self.FPC);
  Self.FSaleLine := TSaleLine.Create(Self.FSale);
  System.Randomize;
end;

procedure Check_TSaleLine.VerifyCost;
var tc : currency;
begin
  tc := System.Random(1599);
  Self.FSaleLine.Cost := tc;
  if Self.FSaleLine.Cost <> tc then
    raise ETestFailure.Create('Cost didn''t equal ' + CurrToStr(tc) + ' directly after setting it to that');
end;

procedure Check_TSaleLine.VerifyExtPrice;
var
  tc1, tc2 : currency;
begin
  tc1 := System.Random(1599);
  tc2 := System.Random(1599);
  Self.FSaleLine.Qty := tc1;
  Self.FSaleLine.Price := tc2;
  Check(Self.FSaleLine.ExtPrice = (tc1*tc2),'ExtPrice doesn''t equal Qty * Price');
end;

procedure Check_TSaleLine.VerifyLineType;
var
  linetypes : string;
  ndx : integer;
begin
  linetypes := 'DPT|DSC|FUL|MED|PLU|PPY|PRF';
  for ndx := 0 to 6 do
  begin
    Self.FSaleLine.LineType := StrUtils.MidStr(linetypes,ndx*4,3);
    Check(Self.FSaleLine.LineType = StrUtils.MidStr(linetypes,ndx*4,3), 'LineType does not equal what it was set to');
  end;
  try
    Self.FSaleLine.LineType := 'foo';
    raise ETestFailure.Create('Invalid LineType threw no exception');
  except on E: EInvalidData do begin end; 
  end;
end;

procedure Check_TSaleLine.VerifyPrice;
var
  tc1 : currency;
begin
  tc1 := System.Random(1599);
  Self.FSaleLine.Price := tc1;
  Check(Self.FSaleLine.Price = tc1, 'Price didn''t equal ' + CurrToStr(tc1) + ' directly after setting it to that');
end;

procedure Check_TSaleLine.VerifyQty;
var
  tc1 : currency;
begin
  tc1 := System.Random(1599);
  Self.FSaleLine.Qty := tc1;
  Check(Self.FSaleLine.Qty = tc1,'Qty didn''t equal 15 directly after setting it to that');
end;

procedure Check_TSaleLine.VerifyVoid;
begin
  Check(Self.FSaleLine.Void = False, 'SaleLine.Void does not default to False');
  Self.FSaleLine.Void := True;
  Check(Self.FSaleLine.Void = True,'Setting SaleLine to void has not voided it');
  try
    Self.FSaleLine.Void := False;
  except on E: Exception do Check(E is EPropReadOnly, 'Exception thrown unexpectedly - ' + E.Message);
  end;
end;

procedure Check_TSaleLine.tearDown;
begin
  Self.FSaleLine.Free();
  Self.FSale.Free();
end;

procedure Check_TDeptLine.POSError(const S: string);
begin
  FError := S;
end;

procedure Check_TDeptLine.setUp;
begin
  inherited;
  Self.FSale := TSale.Create(Self.FPC);
  Self.FPC.POSError := Self.POSError;
end;

procedure Check_TDeptLine.tearDown;
begin
  Self.FSaleLine.Free();
  inherited;
end;

procedure Check_TDeptLine.VerifyTransactionClosed;
begin
  Check(Self.FTran.InTransaction = False, 'Transaction check before');
  Self.FSaleLine := TDeptLine.Create(Self.FSale, 3, 1, 1);
  Check(Self.FTran.InTransaction = False, 'Transaction check after');
end;

procedure Check_TDeptLine.VerifyCreateTaxableGrocery;
var
  tc1, tc2 : currency;
  halo, lalo : currency;
begin
  tc1 := System.Random(98) + 1;
  tc2 := System.Random(50);
  Self.FSaleLine := TDeptLine.Create(Self.FSale,3,tc1,tc2);
  halo := Self.FSaleLine.DeptHALO;
  lalo := Self.FSaleLine.DeptLALO;
  if halo <> 0 then
  begin
    try
      FError := 'None';
      Self.FSaleLine := TDeptLine.Create(Self.FSale,3,tc1,100);
    except on E: Exception do Check(E is EHALO, 'Unexpected Exception for qty: ' + CurrToStr(tc1) + ' Price: 100 - ' + E.Message);
    end;
    Check(FError = 'Over High Amount Limit', 'Reported HALO error incorrect - ' + FError);
  end;
  if lalo <> 0 then
  begin
    try
      FError := 'None';
      Self.FSaleLine := TDeptLine.Create(Self.FSale,3,tc1,0);
    except on E: Exception do Check(E is ELALO, 'Unexpected Exception for qty: ' + CurrToStr(tc1) + ' Price: 0 - ' + E.Message);
    end;
    Check(FError = 'Under Low Amount Limit', 'Reported LALO error incorrect - ' + FError);
  end;
end;

procedure Check_TDeptLine.VerifyMerge;
var
  tc1 : currency;
  ml : TDeptLine;
begin
  tc1 := System.Random(49) + 1;
  Self.FSaleLine := TDeptLine.Create(Self.FSale,3,1,tc1);
  ml := TDeptLine.Create(Self.FSale,3,1,tc1);
  Check(Self.FSaleLine.Qty = 2, 'Qty incorrect on merged Departments');
  ml.Free();
end;

procedure Check_TDeptLine.VerifyPopulateReceipt;
var
  REC : TDBReceiptRec;
  tc1, tc2 : currency;
begin
  tc1 := System.Random(98) + 1;
  tc2 := System.Random(50);
  Self.FSaleLine := TDeptLine.Create(Self.FSale,3,tc1,tc2);
  Self.FSaleLine.PopulateReceipt(@REC);
  Check(REC.QTY = Self.FSaleLine.Qty,'Qty not up to date');
  Check(REC.PRICE = Self.FSaleLine.Price,'Price not up to date');
  Check(REC.EXTPRICE = Self.FSaleLine.Qty * Self.FSaleLine.Price);
  Check(REC.SALENO = Self.FSaleLine.DeptNo);
  Check(REC.SALENAME = Self.FSaleLine.DeptName);
  Check(REC.TAXNO = Self.FSaleLine.DeptTAXNO);
  Check(REC.DISC = Self.FSaleLine.DeptDISC);
  Check(REC.WEXCODE = Self.FSaleLine.WEXCODE);
  Check(REC.PHHCODE = Self.FSaleLine.PHHCODE);
  Check(REC.IAESCODE = Self.FSaleLine.IAESCODE);
  Check(REC.VOYAGERCODE = Self.FSaleLine.VOYAGERCODE);
end;

procedure Check_TPLULine.POSError(const S: string);
begin
  FError := S;
end;

procedure Check_TPLULine.setUp;
begin
  inherited;
  Self.FSale := TSale.Create(Self.FPC);
  Self.FPC.POSError := Self.POSError;
end;

procedure Check_TPLULine.tearDown;
begin
  inherited;
end;

procedure Check_TPLULine.VerifyTransactionClosed;
begin
  Check(Self.FPC.InTrans = False, 'Transaction check before');
  Self.FSaleLine := TPLULine.Create(Self.FSale, 1000, 1, True);
  Check(Self.FPC.InTrans = False, 'Transaction check after');
end;


procedure Check_TPLULine.VerifyMerge;
var
  ml : TPLULine;
begin
  Check(Self.FSale.Count = 0, 'Too many items on sale');
  Self.FSaleLine := TPLULine.Create(Self.FSale, 1000, 1);
  Check(Self.FSale.Count = 1, 'Too many items on sale');
  Check(Self.FSaleLine.Qty = 1, 'Qty incorrect after PLU Creation: ' + CurrToStr(Self.FSaleLine.Qty));
  ml := TPLULine.Create(Self.FSale, 1000, 1);
  Check(Self.FSaleLine.Qty = 2, 'Merge Failed');
  ml.Free();
end;

procedure Check_TPLULine.VerifyPopulateReceipt;
var
  REC : TDBReceiptRec;
  tc1 : currency;
begin
  tc1 := System.Random(98) + 1;
  Self.FSaleLine := TPLULine.Create(Self.FSale,1000, tc1);
  Self.FSaleLine.PopulateReceipt(@REC);
  Check(REC.QTY = Self.FSaleLine.Qty,'Qty not up to date');
  Check(REC.PRICE = Self.FSaleLine.Price,'Price not up to date');
  Check(REC.EXTPRICE = Self.FSaleLine.Qty * Self.FSaleLine.Price);
  Check(REC.SALENO = Self.FSaleLine.PLUNO);
  Check(REC.SALENAME = Self.FSaleLine.PLUName);
  Check(REC.TAXNO = Self.FSaleLine.DeptTAXNO);
  Check(REC.DISC = (Self.FSaleLine.DeptDISC and Self.FSaleLine.PLUDisc));
  Check(REC.WEXCODE = Self.FSaleLine.WEXCODE);
  Check(REC.PHHCODE = Self.FSaleLine.PHHCODE);
  Check(REC.IAESCODE = Self.FSaleLine.IAESCODE);
  Check(REC.VOYAGERCODE = Self.FSaleLine.VOYAGERCODE);
end;


procedure Check_TPLULine.VerifyQtyDiscount;
begin
  Check(Self.FSale.Count = 0, 'Too many items on sale');
  Self.FSaleLine := TPLULine.Create(Self.FSale, 689490000013, 10);
  Check(Self.FSaleLine.Discountable = True, 'Item not marked discountable');
  Check(Self.FSale.Items[0].ClassName = 'TPLULine', 'First Item not TPLULine');
  Check(Self.FSale.Items[1].ClassName = 'TDiscQuantity', 'Second Item not TDiscQuantity');
  Check(TDiscQuantity(Self.FSale.Items[1]).DiscNo = 3999, 'Third item discount number != 3999 - ' + CurrToStr( TDiscQuantity(Self.FSale.Items[1]).DiscNo ));
  Check(Self.FSale.Items[1].Linked[0] = 0, 'Disc Line link not 0 but: ' + IntToStr(Self.FSale.Items[1].Linked[0]));
  Check(Self.FSale.Items[0].Discount[0] = 1, 'PLU Line discounts link not 1 but: ' + IntToStr(Self.FSale.Items[0].Discount[0]));
  Check(Self.FSale.Count = 2 , 'Incorrect number of lines on sale: ' + IntToStr(Self.FSale.Count));
end;

initialization
  TestFramework.RegisterTest(Suite);
end.


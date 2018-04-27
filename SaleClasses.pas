{ OOP Interface to creating sales and items that belong on those sales }
unit SaleClasses;
{ 1218649022 226 17:37:02 <mmattice> so, I came up with an insane idea last night.
                                      TSaleLine, TDeptLine=class(TSaleLine), TPLULine=class(TDeptLine),
                                      TFuelLine=class(TDeptLine), TGiftLine=class(TPLULine), etc
  1218649059 226 17:37:39 <mmattice> and then, a TSale that would have a list inside it and you'd just
                                      create objects derived from TSaleLine and TSale.Add(TSaleLine)
  1218649135 226 17:38:55 <mmattice> also, potentinally a TTender derived from TSaleLine and different
                                      derived types that you could add to the sale to balance it
  1218649186 226 17:39:46 <rpayne> Sounds good.  (There are a lot of references to the sales list that would have to be modified.)
  1218649322 226 17:42:02 <mmattice> oh, I know, but if each TSaleLine has methods like ~.Amount and
                                      ~.RecieptRepr (representation), the window writing could just be
                                      a method call on the TSale and it would build it all itself }

interface

uses classes, SysUtils, IBSQL, DBInt, JclHashMapsCustom;

type

  EInvalidAct = Class(Exception);   //< Exception Class for Actions that are not allowed
  EInvalidData = Class(Exception);  //< Exception Class raised when data passed is invalid
  ENotified = Class(Exception);     //< Exception Class for already notified (ignorable) errors
  ENotFound = Class(ENotified);     //< Exception Class for records not found
  ERestricted = Class(ENotified);   //< Exception Class for Restricted items
  ELALO = Class(ENotified);         //< Exception Class for Low Amount Limit Violations
  EHALO = Class(ENotified);         //< Exception Class for High Amount Limit Violations
  EDeptMaxCount = Class(ENotified); //< Exception Class for Department Max sale count violations

  { Object procedure to return boolean result for integer parameter}
  TGetIntBoolProc = procedure (const Value : Integer; var ret : boolean) of object;
  { Object procedure to return integer result }
  TGetIntProc = procedure (var Value : Integer) of object;
  { Object procedure to return currency result }
  TGetCurrProc = procedure (var Value : Currency) of object;
  { Object function to return Integer result }
  TGetIntFunc = function () : integer of object;

  {@value ssNoSale No-Sale State - no items, no total
   @value ssSale   Sale State - items, total, pre-tender
   @value ssTender Tender State - post tender, pre No-Sale
   @value ssBankFunc Banking Function State
   @value ssBankFuncTender Banking Function Tender State, pre No-Sale
  }
  TSaleState = (ssNoSale, ssSale, ssTender, ssBankFunc, ssBankFuncTender );

  TSaleLine = Class;  //< forward declaration to allow TSale to work  @exclude
  TDiscLine = Class;  //< forward declaration to allow TSale to work  @exclude
  TSale     = Class;  //< forward declaration to allow TPOSConnector to work  @exclude

  { Interface class for POS to allow some state to be saved between transactions }
  TPOSConnector = class(TObject)
  private
    FCursors : TIBSqlBuilder;
    FPOSError : TGetStrProc;
    FZLogProc : TGetStrProc;
    FXCPTLog  : TGetStrProc;
    FRestCodeCheck : TGetIntBoolProc;
    FAssignTransNo : TGetCurrProc;
    FAssignLineID : TGetIntFunc;
    FChangeNotify : Array of TNotifyEvent;
    FCNCount : integer;  // Change Notify Count
    FSales : TThreadList;
    function GetInTrans() : boolean;
    function GetSaleCount() : integer;
    function GetSale(const Index:integer) : TSale;
  protected
  public
    constructor Create(sb : TIBSqlBuilder);
    procedure StartTransaction();
    procedure Commit();
    procedure Rollback();
    property InTrans : boolean read GetInTrans;

    { Attach a TSale to this Connector }
    procedure Attach(Sale : TSale);
    { Detach a TSale from this Connector }
    procedure Detach(Sale : TSale);
    { Current attached TSale count }
    property SaleCount : integer read GetSaleCount;
    { }
    property Sale[const Index:integer] : TSale read GetSale;

    function AddChangeNotify(OnChangeEvent : TNotifyEvent) : integer;
    procedure DelChangeNotify(CNid : integer);
    procedure ChangeNotify( ChangedObj : TObject );

    { Handler for errors to be displayed on screen for acknowledgement }
    property POSError : TGetStrProc read FPOSError write FPOSError ;
    { Handler for Exception log messages }
    property XCPTLogProc : TGetStrProc read FXCPTLog write FXCPTLog;
    { Handler for ZLogging }
    property ZLogProc : TGetStrProc read FZlogProc write FZlogProc;
    { Handler for checking if a product is subject to a restriction code }
    property RestrictionCodeCheck : TGetIntBoolProc read FRestCodeCheck write FRestCodeCheck;
    { Handler for assigning a transaction number to the current sale }
    property AssignTransNo : TGetCurrProc read FAssignTransNo write FAssignTransNo;
    { Handler for assigning unique line ids for product activations }
    property AssignLineID : TGetIntFunc read FAssignLineID write FAssignLineID;
  published
  end;

  { Class to manage a list TSaleLine that make up a sale}
  TSale = Class(TObject)
  private
    FDBC : TPOSConnector;
    FList : TList;
    FSaleState : TSaleState;
    FReturn    : boolean;
    FTransNo   : currency;
    FSaleLineNo : integer;
    procedure CheckDiscounts(const LineIndex : integer);
    procedure CheckDiscountValid(const LineIndex : integer);
    procedure LookForNewDiscounts(const LineIndex : integer);
    procedure SetSaleState(Value : TSaleState);
    function GetCount() : Integer;
    function GetSaleLineNo() : integer;
    property SaleLineNo : integer read GetSaleLineNo;
  protected
    function Get(Index: Integer): TSaleLine;
  public
    { Sale's Transaction Number }
    property TransNo : currency read FTransNo;
    { This sale's current state }
    property SaleState : TSaleState read FSaleState write SetSaleState;
    { This sale's list of SaleLines }
    property Items[Index: Integer]: TSaleLine read Get; default;
    { Count of SaleLines on this sale }
    property Count : integer read GetCount;
    { flag to indicate whether new lines should be positive or negative }
    property ReturnMode : boolean read FReturn write FReturn;
    { Add a TSaleLine to this TSale }
    procedure Add(sl : TSaleLine);
    procedure AddDiscount(dl : TDiscLine; sl : TSaleLine);
    
    constructor Create (DBConnector : TPOSConnector);
    destructor Destroy(); override;
  end;

  { Base class that defines a Sale Line - unusable by itself - subclass it }
  TSaleLine = Class(TObject)
  private
    FOwner : TSale;
    FQty,
    FPrice,
    FCost,
    FExtPrice : Currency;
    FVoid     : boolean;
    FLineType : string;
    FSaleType : string;
    FSeqNo  : integer;
    FLinked : TList;
    FDiscountable : boolean;
    FDiscounts : TList;
    FAutoMerged : boolean;
    procedure SetCost(const Value: Currency);
    procedure SetPrice(const Value: Currency);
    procedure SetQty(const Value: Currency);
    procedure SetVoid(const Value: boolean);
    procedure SetLineType(const Value: string);
    function GetLinked(const Index: integer) : integer;
    function GetLinkedCount() : integer;
    function GetDiscount(const Index: integer) : integer;
    function GetDiscountCount() : integer;
    function GetDiscountable() : boolean;
  protected
    procedure SetDiscountable(const Value : boolean);
  public
    property SeqNo    : integer read FSeqNo;
    property Qty      : Currency read FQty write SetQty;
    property Price    : Currency read FPrice write SetPrice;
    property Cost     : Currency read FCost write SetCost;
    property ExtPrice : Currency read FExtPrice;
    property Void     : boolean read FVoid write SetVoid;
    property LineType : string read FLineType write SetLineType;

    property Linked[const Index : integer]: Integer read GetLinked;
    property LinkedCount : Integer read GetLinkedCount;
    procedure AttachLinkedLine(const Index : integer);
    procedure DetachLinkedLine(const Index : integer);

    property Discount[const Index : integer]: Integer read GetDiscount;
    property DiscountCount : Integer read GetDiscountCount;
    procedure AttachDiscountLine(const Index : integer);
    procedure DetachDiscountLine(const Index : integer);

    function RecieptRepr() : TStringList; dynamic;
    { callable to combine like lines.  override in subclasses }
    function Merge(sl : TSaleLine) : boolean ; dynamic;
    property Discountable    : boolean  read GetDiscountable;
    procedure PopulateReceipt(rl: pDBReceiptRec); dynamic;
    constructor Create(Owner: TSale); dynamic;
  end;

  { Group information for SaleLine }
  TGroupLine = Class(TSaleLine)
  private
    FGrpSet : boolean;
    FGrpRec : TDBGrpRec;
    procedure SetGrpNo(const Value: smallint);
    function GetGrpName() : string;
  public
    property GrpNo           : smallint   read FGrpRec.GRPNO   write SetGrpNo;
    property GrpName         : string     read GetGrpNAME;
    property GrpType         : smallint   read FGrpRec.FUEL;
    constructor Create(Owner: TSale; GrpNo : smallint); reintroduce;
  end;

  { Department information for SaleLine }
  TDeptLine = Class(TGroupLine)
  private
    FDeptSet : boolean;
    FDeptRec : TDBDeptRec;
    procedure SetDeptNo(const Value: integer);
  public
    property DeptNo          : integer  read FDeptRec.DEPTNO write SetDeptNo;
    property DeptName        : string   read FDeptRec.DeptName;
    property DeptGrpNo       : integer  read FDeptRec.GRPNO;
    property DeptDisc        : boolean  read FDeptRec.DISC;
    property DeptHALO        : currency read FDeptRec.HALO;
    property DeptLALO        : currency read FDeptRec.LALO;
    property RESTRICTIONCODE : integer  read FDeptRec.RESTRICTIONCODE;
    property DeptSubtracting : boolean  read FDeptRec.SUBTRACTING;
    property DeptTaxNo       : integer  read FDeptRec.TAXNO;
    property WEXCode         : integer  read FDeptRec.WEXCODE;
    property PHHCODE         : integer  read FDeptRec.PHHCODE;
    property IAESCODE        : integer  read FDeptRec.IAESCODE;
    property VOYAGERCODE     : integer  read FDeptRec.VOYAGERCODE;
    property DeptFS          : boolean  read FDeptRec.FS;
    property DeptWIC         : boolean  read FDeptRec.WIC;
    property MAXCOUNT        : integer  read FDeptRec.MAXCOUNT;
    property DeptDelFlag     : integer  read FDeptRec.DELFLAG;
    function Merge(sl : TSaleLine) : boolean ; override;
    procedure PopulateReceipt( rl : pDBReceiptRec ); reintroduce;
    constructor Create(Owner: TSale; DeptNo: integer; Qty, Price : currency); reintroduce;
  end;

  { PLU information for DeptLine (PLU Sales are automatically Dept Sales)}
  TPLULine = Class(TDeptLine)
  private
    FPLUSet : boolean;
    FPLURec : TDBPLURec;
    procedure SetPLUNO(const Value: currency);
    procedure SetUPC(const Value: currency);
    function GetNAME() : string;
    function GetHOSTKEY() : string;
    function GetPACKSIZE() : string;
  public
    property PLUNO              : currency   read FPLURec.PLUNO write SetPLUNO;
    property UPC                : currency   read FPLURec.UPC   write SetUPC;
    property PLUNAME            : string     read GetNAME;
    property PLUDeptNo          : smallint   read FPLURec.DEPTNO;
    property PRICE              : currency   read FPLURec.PRICE;
    property ONHAND             : currency   read FPLURec.ONHAND;
    property PLUDisc            : boolean    read FPLURec.DISC;
    property PLUTaxNo           : smallint   read FPLURec.TAXNO;
    property SPLITQTY           : integer    read FPLURec.SPLITQTY;
    property SPLITPRICE         : currency   read FPLURec.SPLITPRICE;
    property VENDORNO           : integer    read FPLURec.VENDORNO;
    property PRODGRPNO          : integer    read FPLURec.PRODGRPNO;
    property PLUFS              : boolean    read FPLURec.FS;
    property PLUWIC             : boolean    read FPLURec.WIC;
    property LINKEDPLU          : currency   read FPLURec.LINKEDPLU;
    property PLUSubtracting     : boolean    read FPLURec.SUBTRACTING;
    property MODIFIERGROUP      : currency   read FPLURec.MODIFIERGROUP;
    property PLUDelFlag         : smallint   read FPLURec.DELFLAG;
    property HOSTKEY            : string     read GetHOSTKEY;
    property ITEMNO             : currency   read FPLURec.ITEMNO;
    property RETAILPRICE        : currency   read FPLURec.RETAILPRICE;
    property BREAKDOWNLINK      : currency   read FPLURec.BREAKDOWNLINK;
    property BREAKDOWNITEMCOUNT : integer    read FPLURec.BREAKDOWNITEMCOUNT;
    property ITEMISSOLD         : boolean    read FPLURec.ITEMISSOLD;
    property ITEMISPURCHASED    : boolean    read FPLURec.ITEMISPURCHASED;
    property UNITID             : integer    read FPLURec.UNITID;
    property PACKSIZE           : string     read GetPACKSIZE;
    property NeedsActivation    : boolean    read FPLURec.NeedsActivation;
    property NeedsSwipe         : boolean    read FPLURec.NeedsSwipe; 
    function Merge(sl : TSaleLine) : boolean ; override;
    procedure PopulateReceipt( rl : pDBReceiptRec ); reintroduce;
    constructor Create(Owner: TSale; ID : Currency ; Qty : Currency ; PLU : Boolean = True); reintroduce;
  end;

  { Fuel Sale line }
  TFuelLine = Class(TDeptLine)
  public
    //constructor Create(Owner: TSale; pump : smallint; type : string
  end;

  { Gift card Line }
  TGiftLine = Class(TDeptLine)
  private
    FGiftCardNo : string[19];
  public

    function Merge(sl : TSaleLine) : boolean ; override;
  end;

  TDiscInfo = record
    dNum : Currency;
    dType : string[3];
    dAmount : currency;
  end;
  PDiscInfo = ^TDiscInfo;

  { Discount Line }
  TDiscLine = Class(TSaleLine)
  private
    FDisc : TDiscInfo;
    FDiscNoSet : boolean;
    function GetDiscType() : string;
    //FApplyList : TList; // lists object lines this discount is linked to\
  public
    class procedure FindPotentials(sale : TSale; sl : TSaleLine ; disclist : TList); virtual;
    class function CreateDisc(Owner: TSale; dNo : currency; dType : string; sl : TSaleLine) : TDiscLine;
    property DiscNo    : currency read FDisc.dNum;
    property DiscType  : string   read GetDiscType;
    property DiscAmount: currency read FDisc.dAmount;
  end;

  TDiscMixMatch = Class(TDiscLine)
  end;

  TDiscQuantity = Class(TDiscLine)
  private
    procedure SetDiscNo(const value : currency);
  public
    class procedure FindPotentials(sale : TSale; sl : TSaleLine ; disclist : TList); override;
    constructor Create(Owner : TSale; dNo : currency; sl : TSaleLine); reintroduce;
  end;

  TDiscTime = Class(TDiscLine)
  end;

  TDiscMedia = Class(TDiscLine)
  end;

  TDiscLineClass = class of TDiscLine;

  TTender = Class(TSaleLine)
  private
  public
  end;

const
  DiscountTypes : Array[0..3] of TDiscLineClass = (TDiscQuantity, TDiscMedia, TDiscTime, TDiscMixMatch);



implementation

uses math;


{ TSaleLine }

constructor TSaleLine.Create(Owner: TSale);
begin
  Self.FCost := 0;
  Self.FQty  := 1;
  Self.FPrice := 0;
  Self.FVoid := False;
  Self.FExtPrice := 0;
  Self.FOwner := Owner;
  if Owner.ReturnMode then
    Self.FSaleType := 'Rtrn'
  else
    Self.FSaleType := 'Sale';
  Self.FLinked := nil;
  Self.FDiscountable := True;
end;

procedure TSaleLine.AttachDiscountLine(const Index: integer);
begin
  if not assigned(Self.FDiscounts) then
    Self.FDiscounts := TList.Create;
  Self.FDiscounts.Add(pointer(Index))
end;

procedure TSaleLine.DetachDiscountLine(const Index: integer);
begin
  if assigned(Self.FDiscounts) then
    Self.FDiscounts.Remove(pointer(Index));
  if Self.FDiscounts.Count = 0 then
  begin
    Self.FDiscounts.Free;
    Self.FDiscounts := nil;
  end;
end;

function TSaleLine.GetDiscount(const Index: integer): integer;
begin
  if assigned(Self.FDiscounts) then
    if Index < Self.FDiscounts.Count then
      Result := integer(Self.FDiscounts[Index])
    else
      Result := -1
  else
    Result := -1;
end;

function TSaleLine.GetDiscountCount: integer;
begin
  if assigned(Self.FDiscounts) then
    Result := Self.FDiscounts.Count
  else
    Result := 0;
end;

procedure TSaleLine.AttachLinkedLine(const Index: integer);
begin
  if not assigned(Self.FLinked) then
    Self.FLinked := TList.Create;
  Self.FLinked.Add(pointer(Index));
end;

procedure TSaleLine.DetachLinkedLine(const Index: integer);
begin
  if assigned(Self.FLinked) then
    Self.FLinked.Remove(pointer(Index));
  if Self.FLinked.Count = 0 then
  begin
    Self.FLinked.Free;
    Self.FLinked := nil;
  end;
end;

function TSaleLine.GetLinked(const Index: integer): integer;
begin
  if assigned(Self.FLinked) then
    if Index < Self.FLinked.Count then
      Result := integer(Self.FLinked[Index])
    else
      Result := -1
  else
    Result := -1;
end;

function TSaleLine.GetLinkedCount: integer;
begin
  if assigned(Self.FLinked) then
    Result := Self.FLinked.Count
  else
    Result := 0;
end;

function TSaleLine.Merge(sl: TSaleLine): boolean;
begin
  Merge := False;
end;

procedure TSaleLine.PopulateReceipt(rl: pDBReceiptRec);
begin
  rl.TRANSACTIONNO := Self.FOwner.FTransNo;
end;

function TSaleLine.RecieptRepr: TStringList;
begin
  RecieptRepr := nil;
end;

procedure TSaleLine.SetCost(const Value: Currency);
begin
  FCost := Value;
end;

procedure TSaleLine.SetLineType(const Value: string);
begin
  if (length(Value) = 3) and (Pos(Value, 'DPT|DSC|FUL|MED|PLU|PPY|PRF') > 0) then
    FLineType := Value
  else
    raise EInvalidData.Create('LineType cannot = ' + Value);
end;

procedure TSaleLine.SetPrice(const Value: Currency);
begin
  FPrice := Value;
  FExtPrice := FPrice * FQty;
end;

procedure TSaleLine.SetQty(const Value: Currency);
begin
  FQty := Value;
  FExtPrice := FPrice * FQty;
end;

procedure TSaleLine.SetVoid(const Value: boolean);
begin
  if not Value then
    raise EPropReadOnly.Create('TSaleLine.SetVoid := False');
  FVoid := Value;
  FSaleType := 'Void';
end;

function TSaleLine.GetDiscountable: boolean;
begin
  if Self.InheritsFrom(TTender) then
    Result := False
  else
    Result := Self.FDiscountable;
end;

procedure TSaleLine.SetDiscountable(const Value: boolean);
begin
  if Self.InheritsFrom(TTender) then
    raise EInvalidAct.Create('Attempt to set a Tender discountable not allowed')
  else
    Self.FDiscountable := Self.FDiscountable and Value;
end;

{ TGroupLine }

constructor TGroupLine.Create(Owner: TSale; GrpNo: smallint);
begin
  inherited Create(Owner);
  Self.SetGrpNo(GrpNo);
end;

function TGroupLine.GetGrpName: string;
begin
  GetGrpName := FGrpRec.GrpNAME;
end;

procedure TGroupLine.SetGrpNo(const Value: smallint);
var
  t : TIBSQL;
begin
  t := FOwner.FDBC.FCursors['GET-GRP'];
  t.ParamByName('pID').AsInteger := Value;
  t.ExecQuery;
  if t.Eof then
  begin
    t.Close();
    raise ENotFound.Create('GET-GRP: ' + IntToStr(Value));
  end;
  GetGrp(t, @Self.FGrpRec);
  t.Close();
  Self.FGrpSet := True;
  Self.SetDiscountable(True);
end;

{ TDeptLine }

constructor TDeptLine.Create(Owner: TSale; DeptNo: integer; Qty, Price : currency);
var
  transave : boolean;
begin
  FOwner := Owner;
  transave := FOwner.FDBC.InTrans;
  if not transave then  // if transave is set, we're in a transaction due to a super-class
    FOwner.FDBC.StartTransaction;
  try
    Self.SetDeptNo(DeptNo);
    inherited Create(Owner, Self.DeptGrpNo);
    Self.FLineType := 'DPT';
    Self.FQty := Qty;
    Self.FPrice := Price;
    if (Self.DeptLALO > 0) and (Self.FPrice < Self.DeptLALO) then
    begin
      FOwner.FDBC.FPOSError('Under Low Amount Limit');
      raise ELALO.Create(IntToStr(DeptNo) + ': ' + CurrToStr(Self.DeptLALO) + ' - ' + CurrToStr(Price));
    end;
    if (Self.DeptHALO > 0) and (Self.FPrice > Self.DeptHALO) then
    begin
      FOwner.FDBC.FPOSError('Over High Amount Limit');
      raise EHALO.Create(IntToStr(DeptNo) + ': ' + CurrToStr(Self.DeptHALO) + ' - ' + CurrToStr(Price));
    end;
    if not transave then
      FOwner.FDBC.Commit;
  except
    if not transave then
      FOwner.FDBC.Rollback;
    raise;
  end;
  if not transave then
    FOwner.Add(self);
end;

function TDeptLine.Merge(sl: TSaleLine): boolean;
begin
  Merge := False;
  if (Self.DeptNo = TDeptLine(sl).DeptNo) and (Self.Price = sl.Price) then
  begin
    Merge := True;
    Self.Qty := Self.Qty + sl.Qty;
    Self.FAutoMerged := True;
  end;
end;

procedure TDeptLine.PopulateReceipt(rl: pDBReceiptRec);
begin
  rl.QTY := self.Qty;
  rl.PRICE := self.Price;
  rl.EXTPRICE := self.Qty * self.Price;

  rl.SALENO := Self.DeptNo;
  //rl.DeptNo := Self.DeptNo;
  rl.SALENAME := Self.DeptName;
  rl.TAXNO := Self.DeptTAXNO;
  rl.DISC := Self.DeptDISC;
  rl.WEXCODE := Self.WEXCODE;
  rl.PHHCODE := Self.PHHCODE;
  rl.IAESCODE := self.IAESCODE;
  rl.VOYAGERCODE := self.VOYAGERCODE;
end;

procedure TDeptLine.SetDeptNo(const Value: integer);
var
  t : TIBSQL;
begin
  if Self.FDeptSet then
    raise EPropReadOnly.Create('Resetting Department not allowed');
  t := FOwner.FDBC.FCursors['GET-DPT'];
  t.ParamByName('pID').AsInteger := Value;
  t.ExecQuery;
  if t.Eof then
    raise ENotFound.Create('GET-DPT: ' + IntToStr(Value));
  GetDept(t, @Self.FDeptRec);
  t.Close();
  Self.FDeptSet := True;
  Self.SetDiscountable(Self.DeptDisc);
end;

{ TPLULine }

constructor TPLULine.Create(Owner: TSale; ID: Currency; Qty : Currency; PLU: Boolean);
var
  transave : boolean;
begin
  FOwner := Owner;
  transave := FOwner.FDBC.InTrans;
  if not transave then  // if transave is set, we're in a transaction due to a super-class
    FOwner.FDBC.StartTransaction;
  try
    if PLU then
      Self.SetPLUNO(ID)
    else
      Self.SetUPC(ID);
    inherited Create(Owner, Self.PluDeptNo, Qty, Self.PRICE);
    Self.FLineType := 'PLU';
    Self.FQty := Qty;
    Self.SetGrpNo(Self.FDeptRec.GRPNO);
    if not transave then
      FOwner.FDBC.Commit;
  except
    if not transave then
      FOwner.FDBC.Rollback;
    raise;
  end;
  if not transave then
    FOwner.Add(self);
end;

function TPLULine.GetHOSTKEY: string;
begin
  GetHOSTKEY := FPLURec.HOSTKEY;
end;

function TPLULine.GetNAME: string;
begin
  GetNAME := FPLURec.NAME;
end;

function TPLULine.GetPACKSIZE: string;
begin
  GetPACKSIZE := FPLURec.PACKSIZE;
end;

function TPLULine.Merge(sl: TSaleLine): boolean;
begin
  Merge := False;
  if (Self.PLUNO = TPLULine(sl).PLUNO) and not (Self.NeedsActivation or Self.NeedsSwipe) then
  begin
    Merge := True;
    Self.Qty := Self.Qty + sl.Qty;
    Self.FAutoMerged := True;
  end;
end;

procedure TPLULine.PopulateReceipt(rl: pDBReceiptRec);
begin

  rl.QTY := self.Qty;
  rl.PRICE := self.Price;
  rl.EXTPRICE := self.Qty * self.Price;

  rl.SALENO := Self.PluNo;
  rl.SALENAME := Self.PLUName;
  rl.TAXNO := Self.DeptTAXNO;
  rl.DISC := Self.DeptDisc and Self.PLUDisc;
  rl.WEXCODE := Self.WEXCODE;
  rl.PHHCODE := Self.PHHCODE;
  rl.IAESCODE := self.IAESCODE;
  rl.VOYAGERCODE := self.VOYAGERCODE;
end;

procedure TPLULine.SetPLUNO(const Value: currency);
var
  t : TIBSQL;
begin
  if Self.FPLUSet then
    raise EPropReadOnly.Create('Resetting PLU not allowed');
  t := FOwner.FDBC.FCursors['GET-PLU'];
  t.ParamByName('pID').AsCurrency := Value;
  t.ExecQuery;
  if t.Eof then
    raise ENotFound.Create('GET-PLU: ' + CurrToStr(Value));
  GetPLU(t, @Self.FPLURec);
  t.Close();
  Self.FPLUSet := True;
  Self.SetDiscountable(Self.PLUDisc);
end;

procedure TPLULine.SetUPC(const Value: currency);
var
  t : TIBSQL;
begin
  if Self.FPLUSet then
    raise EPropReadOnly.Create('Resetting PLU not allowed');
  t := FOwner.FDBC.FCursors['GET-UPC'];
  t.ParamByName('pID').AsCurrency := Value;
  t.ExecQuery;
  if t.Eof then
    raise ENotFound.Create('GET-UPC: ' + CurrToStr(Value));
  GetPLU(t, @Self.FPLURec);
  t.Close();
  Self.FPLUSet := True;
  Self.SetDiscountable(Self.PLUDisc);
end;

{ TSale }

{ Make sure current discounts still apply and look for new ones }
procedure TSale.CheckDiscounts(const LineIndex : integer);
var
  i : integer;
  CL  : TSaleLine;
begin
  CL := TSaleLine(Self.FList[LineIndex]);
  for i := 0 to CL.DiscountCount - 1 do  // loop through discount line list
    CheckDiscountValid(CL.Discount[i]);
  LookForNewDiscounts(LineIndex);
end;

procedure TSale.CheckDiscountValid(const LineIndex: integer);
begin

end;

procedure TSale.LookForNewDiscounts(const LineIndex: integer);
var
  sl : TSaleLine;
  DiscList : TList;
  i : integer;
  dl : TDiscLine;
  ds : pDiscInfo;
begin
  sl := TSaleLine(Self.FList[LineIndex]);
  if sl.Discountable then
  begin
    DiscList := TList.Create;
    Self.FDBC.StartTransaction;
    for i := low(DiscountTypes) to high(DiscountTypes) do
      DiscountTypes[i].FindPotentials(self, sl, DiscList);
    Self.FDBC.Commit;
    if DiscList.Count > 1 then
      raise Exception.Create('don''t know what to do with > 1 length discount list yet');
    if DiscList.Count = 1 then
    begin
      ds := DiscList[0];
      dl := TDiscLine.CreateDisc(self, ds.dNum, ds.dType, sl);
      Self.AddDiscount(dl, sl);
    end;
  end;
end;

procedure TSale.Add(sl: TSaleLine);
var
  ndx : integer;
  tcurr : currency;
  merged : boolean;
  restok : boolean;
  dl : TDeptLine;
begin

  if sl is TDeptLine then
  begin
    dl := TDeptLine(sl);
    // Check Restriction Code
    if (dl.RESTRICTIONCODE <> 0) and Assigned(FDBC.FRestCodeCheck) then
    begin
      FDBC.FRestCodeCheck(dl.RESTRICTIONCODE, restok);
      if not restok then
      begin
        // Self.FDBC.FPOSError('Purchase Restricted');  // don't notify to kill clutter
        raise ERestricted.Create(IntToStr(dl.RESTRICTIONCODE));
      end;
    end;
    // Check Department MaxCount
    if (dl.Qty > 0) and (dl.MAXCOUNT > 0) then
    begin
      tcurr := 0;
      for ndx := 0 to FList.Count - 1 do
      begin
        if TObject(FList[ndx]).InheritsFrom(TDeptLine) then
          tcurr := tcurr + TDeptLine(FList[ndx]).Qty;
      end;
      if ((tcurr + dl.Qty) > dl.MAXCOUNT) then
      begin
        Self.FDBC.FPOSError('Exceeds Department Max Count');
        raise EDeptMaxCount.CreateFmt('%i|%g|%g', [IntToStr(dl.DeptNo), dl.MAXCOUNT, tcurr]);
      end;
    end;
  end;
  if Self.FReturn then
  begin
    sl.FSaleType := 'Rtrn';
    sl.FQty := -sl.FQty;
  end;
  merged := False;
  for ndx := 0 to FList.Count - 1 do
  begin
    if sl.ClassNameIs(TObject(FList.Items[ndx]).ClassName) then
      merged := TSaleLine(FList.Items[ndx]).Merge(sl);
    if merged then break;
  end;
  if not merged then
  begin
    sl.FSeqNo := Self.SaleLineNo;
    ndx := FList.Add(sl);
  end;
  Self.SetSaleState(ssSale);
  Self.CheckDiscounts(ndx);
end;

procedure TSale.AddDiscount(dl : TDiscLine ; sl : TSaleLine);
begin
  dl.FSeqNo := Self.SaleLineNo;
  sl.AttachDiscountLine(dl.SeqNo);
  dl.AttachLinkedLine(sl.SeqNo);
  Self.FList.Add(dl);
end;

constructor TSale.Create(DBConnector: TPOSConnector);
begin
  FDBC := DBConnector;
  FList := TList.Create();
  Self.FSaleState := ssNoSale;
  Self.FTransNo := -1;
  Self.FReturn := False;
  FDBC.Attach(Self);
end;

destructor TSale.Destroy;
begin
  FDBC.Detach(Self);
  Inherited;
end;

procedure TSale.SetSaleState(Value: TSaleState);
begin
  // TfmPOS.SetSaleState for references?
  if (Value = ssNoSale) then
    raise EInvalidAct.Create('Cannot set a sale state back to ssNoSale - Create another sale instead');
  if (FSaleState = ssNoSale) then
  begin
    if Assigned(Self.FDBC.FAssignTransNo) then
      Self.FDBC.FAssignTransNo(Self.FTransNo)
    else
      raise EInvalidAct.Create('AssignTransNo proc not assigned - cannot get a TransNo');
    FSaleState := Value;
  end;
end;

function TSale.Get(Index: Integer): TSaleLine;
begin
  Result := TSaleLine(FList[Index]);
end;

function TSale.GetCount: Integer;
begin
  Result := Self.FList.Count;
end;

function TSale.GetSaleLineNo: integer;
begin
  Result := Self.FSaleLineNo;
  inc(Self.FSaleLineNo);
end;

{ TPOSConnector }

procedure TPOSConnector.Commit;
begin
  FCursors.Transaction.Commit;
end;

constructor TPOSConnector.Create(sb : TIBSqlBuilder);
begin
  Self.FCNCount := 0;
  SetLength(Self.FChangeNotify, Self.FCNCount);
  Self.FSales := TThreadList.Create;
  FCursors := sb;
  Self.StartTransaction;
  FCursors.AddCursor('GET-GRP', 'Select * from GRP where GRPNO = :pID');
  FCursors.AddCursor('GET-DPT', 'Select * from DEPT where DEPTNO = :pID and (delflag is NULL or delflag = 0)');
  FCursors.AddCursor('GET-PLU', 'Select * from PLU where PLUNO = :pID and (delflag is NULL or delflag = 0)');
  FCursors.AddCursor('GET-UPC', 'Select * from PLU where UPC   = :pID and (delflag is NULL or delflag = 0)');
  FCursors.AddCursor('PUT-RECEIPT', 'insert into RECEIPT (TRANSACTIONNO, SEQNUMBER, LINETYPE, SALETYPE, SALENO, ' +
                                      'SALENAME, QTY, PRICE, EXTPRICE, SAVDISCABLE, SAVDISCAMOUNT, PUMPNO, HOSENO, ' +
                                      'DISC, SUBTOTAL, TLTOTAL, TOTAL, CHANGEDUE, LINEVOIDED, TAXNO, TAXRATE, TAXABLE, ' +
                                      'WEXCODE, PHHCODE, IAESCODE, VOYAGERCODE, CCAUTHCODE, CCAPPROVALCODE, CCDATE, ' +
                                      'CCTIME, CCCARDTYPE, CCBATCHNO, CCSEQNO, CCENTRYTYPE, CCVEHICLENO, CCODOMETER, ' +
                                      'FUELSALEID, CCPRINTLINE1, CCPRINTLINE2, CCPRINTLINE3, CCPRINTLINE4, CCREQUESTTYPE, ' +
                                      'CCAUTHORIZER, CCBALANCE1, CCBALANCE2, CCBALANCE3, CCBALANCE4, CCBALANCE5, ' +
                                      'CCBALANCE6, CCCARDNO, CCEXPDATE, CCCARDNAME, XKEYID) ' +
                                      'values ( :pTRANSACTIONNO, :pSEQNUMBER, :pLINETYPE, :pSALETYPE, :pSALENO, ' +
                                      ':pSALENAME, :pQTY, :pPRICE, :pEXTPRICE, :pSAVDISCABLE, :pSAVDISCAMOUNT, :pPUMPNO, :pHOSENO, ' +
                                      ':pDISC, :pSUBTOTAL, :pTLTOTAL, :pTOTAL, :pCHANGEDUE, :pLINEVOIDED, :pTAXNO, :pTAXRATE, :pTAXABLE, ' +
                                      ':pWEXCODE, :pPHHCODE, :pIAESCODE, :pVOYAGERCODE, :pCCAUTHCODE, :pCCAPPROVALCODE, :pCCDATE, ' +
                                      ':pCCTIME, :pCCCARDTYPE, :pCCBATCHNO, :pCCSEQNO, :pCCENTRYTYPE, :pCCVEHICLENO, :pCCODOMETER,  ' +
                                      ':pFUELSALEID, :pCCPRINTLINE1, :pCCPRINTLINE2, :pCCPRINTLINE3, :pCCPRINTLINE4, :pCCREQUESTTYPE, ' +
                                      ':pCCAUTHORIZER, :pCCBALANCE1, :pCCBALANCE2, :pCCBALANCE3, :pCCBALANCE4, :pCCBALANCE5, ' +
                                      ':pCCBALANCE6, :pCCCARDNO, :pCCEXPDATE, :pCCCARDNAME, :pXKEYID )');
  FCursors.AddCursor('FIND-DISCQTY', 'Select dq.DiscNo, dq.qty, d.amount from DISC_QTY dq, DISC d ' +
                                     'where dq.DiscNo=d.DiscNo and dq.ProdType=:pProdType and dq.ProdCode=:pProdCode and dq.Qty >= :pQty');
  FCursors.AddCursor('GET-DISCQTY', 'Select dq.DiscNo, Dq.Qty, d.DiscType, d.Amount from DISC_QTY dq, DISC d ' +
                                    'where dq.DiscNo=d.DiscNo and d.DiscNo = :pDiscNo and d.DiscType = "QTY"');

  Self.Commit;
end;

procedure TPOSConnector.Rollback;
begin
  FCursors.Transaction.Rollback;
end;

procedure TPOSConnector.StartTransaction;
begin
  FCursors.Transaction.StartTransaction;
end;

function TPOSConnector.GetInTrans() : Boolean;
begin
  Result := FCursors.Transaction.InTransaction;
end;

function TPOSConnector.AddChangeNotify(
  OnChangeEvent: TNotifyEvent): integer;
begin
  Inc(Self.FCNCount);
  SetLength(Self.FChangeNotify, Self.FCNCount);
  Self.FChangeNotify[ Self.FCNCount - 1 ] := OnChangeEvent;
  AddChangeNotify := Self.FCNCount - 1;
end;

procedure TPOSConnector.DelChangeNotify(CNid: integer);
begin
  Self.FChangeNotify[ CNid ] := nil;
end;

procedure TPOSConnector.ChangeNotify(ChangedObj: TObject);
var
  i : integer;
begin
  if (Self.FCNCount > 0) then
    for i := 0 to (Self.FCNCount - 1) do
      if Assigned(Self.FChangeNotify [ i ]) then
        Self.FChangeNotify[ i ]( ChangedObj );
end;

procedure TPOSConnector.Attach(Sale: TSale);
begin
  Self.FSales.Add(Sale);
end;

procedure TPOSConnector.Detach(Sale: TSale);
begin
  Self.FSales.Remove(Sale);
end;

{$HINTS OFF}  // here to keep the Result assignments before the try blocks from complaining  @exclude
function TPOSConnector.GetSaleCount: integer;
var
  Sales : TList;
begin
  Result := -1;
  try
    Sales := Self.FSales.LockList;
    Result := Sales.Count;
  finally
    Self.FSales.UnlockList;
  end;
end;

function TPOSConnector.GetSale(const Index: integer): TSale;
var
  Sales : TList;
begin
  Result := nil;
  try
    Sales := Self.FSales.LockList;
    Result := TSale(Sales.Items[Index]);
  finally
    Self.FSales.UnlockList;
  end;
end;
{$HINTS ON}

{ TDiscLine }

class function TDiscLine.CreateDisc(Owner: TSale; dNo: currency; dType: string;
  sl: TSaleLine) : TDiscLine;
begin
  if dType = 'QTY' then
    Result := TDiscQuantity.Create(Owner, dNo, sl)
  else if dType = 'MM ' then
    raise Exception.Create('Cannot yet handle mixmatch discounts')
  else if dType = 'MED' then
    raise Exception.Create('Cannot yet handle media discounts')
  else if dType = 'TME' then
    raise Exception.Create('Cannot yet handle time discounts')
  else
    raise Exception.Create('Unknown Discount type "' + dType + '"');
end;

class procedure TDiscLine.FindPotentials(sale : TSale; sl: TSaleLine; disclist: TList);
begin
  // base discount class can't find discounts
end;

function TDiscLine.GetDiscType: string;
begin
  Result := Self.FDisc.dType;
end;

{ TDiscQuantity }

constructor TDiscQuantity.Create(Owner: TSale; dNo: currency; sl: TSaleLine);
var
  transave : boolean;
begin
  FOwner := Owner;
  transave := FOwner.FDBC.InTrans;
  if not transave then  // if transave is set, we're in a transaction due to a super-class
    FOwner.FDBC.StartTransaction;
  try
    inherited Create(Owner);
    Self.SetDiscNo(dNo);
    Self.FLineType := 'DSC';
    Self.FQty := Qty;
    if not transave then
      FOwner.FDBC.Commit;
  except
    if not transave then
      FOwner.FDBC.Rollback;
    raise;
  end;
  //FOwner.Add(self);

end;

class procedure TDiscQuantity.FindPotentials(sale : TSale; sl: TSaleLine; disclist: TList);
var
  t : TIBSQL;
  disc : pDiscInfo;
begin
  if sl is TPLULine then
  begin
    t := Sale.FDBC.FCursors['FIND-DISCQTY'];
    t.ParamByName('pProdType').AsString := 'PLU';
    t.ParamByName('pProdCode').AsCurrency := TPLULine(sl).PLUNO;
    t.ParamByName('pQty').AsCurrency := sl.Qty;
    t.ExecQuery;
    while not t.Eof do
    begin
      disc := new(pDiscInfo);
      disc.dNum := t.FieldByName('DiscNo').AsInteger;
      disc.dType := 'QTY';
      disc.dAmount := t.FieldByName('Amount').AsCurrency * floor(sl.Qty / t.FieldByName('Qty').AsCurrency);
      disclist.Add(disc);
      t.Next;
    end;
    t.Close;
  end;

end;

procedure TDiscQuantity.SetDiscNo(const value: currency);
var
  t : TIBSQL;
begin
  if Self.FDiscNoSet then
    raise EPropReadOnly.Create('Resetting Discount Number not allowed');
  t := FOwner.FDBC.FCursors['GET-DISCQTY'];
  t.ParamByName('pDiscNo').AsCurrency := Value;
  t.ExecQuery;
  if t.Eof then
    raise ENotFound.Create('GET-DISCQTY: ' + CurrToStr(Value));
  Self.FDisc.dNum := t.FieldByName('DiscNo').AsCurrency;
  Self.FDisc.dType := t.FieldByName('DiscType').AsString;
  Self.FDisc.dAmount := t.FieldByName('Amount').AsCurrency;
  t.Close();
  Self.FDiscNoSet := True;
  Self.SetDiscountable(False);
end;

{ TGiftLine }

function TGiftLine.Merge(sl: TSaleLine): boolean;
begin
  Merge := False;
end;

end.


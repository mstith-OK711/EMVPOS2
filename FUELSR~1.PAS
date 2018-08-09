unit Fuelsrvr_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Fuelsrvr Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_Fuelsrvr: TGUID = '{BF74F710-D775-11D0-9EA4-404000320608}';

const

{ Component class GUIDs }
  Class_TFuelSrvr: TGUID = '{BF74F712-D775-11D0-9EA4-404000320608}';

type

{ Forward declarations: Interfaces }
  ITFuelSrvr = interface;
  ITFuelSrvrDisp = dispinterface;

{ Forward declarations: CoClasses }
  TFuelSrvr = ITFuelSrvr;

{ Dispatch interface for TFuelSrvr Object }

  ITFuelSrvr = interface(IDispatch)
    ['{BF74F711-D775-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; MsgLen: Integer; const Msg: WideString); safecall;
    procedure GetHeaderFooterData(var Hdr1, Hdr2, Hdr3, Hdr4, Hdr5, Ftr1, Ftr2, Ftr3, Ftr4, Ftr5, Keyboard: WideString); safecall;
    procedure GetReaderData(var Readers: Integer; var UnitNo, TermNo, PumpStatus: WideString); safecall;
    function GetTransNo(const SaleData: WideString): Integer; safecall;
    function GetPumpStatus(Pump: Integer): Integer; safecall;
    procedure GetTechnicalData(var FuelStart1, FuelStart2: WideString; var FeedH, FeedF: Integer); safecall;
    procedure GetProdCodes(var ProdCodes: WideString); safecall;
  end;

{ DispInterface declaration for Dual Interface ITFuelSrvr }

  ITFuelSrvrDisp = dispinterface
    ['{BF74F711-D775-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; MsgLen: Integer; const Msg: WideString); dispid 1;
    procedure GetHeaderFooterData(var Hdr1, Hdr2, Hdr3, Hdr4, Hdr5, Ftr1, Ftr2, Ftr3, Ftr4, Ftr5, Keyboard: WideString); dispid 2;
    procedure GetReaderData(var Readers: Integer; var UnitNo, TermNo, PumpStatus: WideString); dispid 3;
    function GetTransNo(const SaleData: WideString): Integer; dispid 4;
    function GetPumpStatus(Pump: Integer): Integer; dispid 5;
    procedure GetTechnicalData(var FuelStart1, FuelStart2: WideString; var FeedH, FeedF: Integer); dispid 6;
    procedure GetProdCodes(var ProdCodes: WideString); dispid 7;
  end;

{ TFuelSrvrObject }

  CoTFuelSrvr = class
    class function Create: ITFuelSrvr;
    class function CreateRemote(const MachineName: string): ITFuelSrvr;
  end;



implementation

uses ComObj;

class function CoTFuelSrvr.Create: ITFuelSrvr;
begin
  Result := CreateComObject(Class_TFuelSrvr) as ITFuelSrvr;
end;

class function CoTFuelSrvr.CreateRemote(const MachineName: string): ITFuelSrvr;
begin
  Result := CreateRemoteComObject(MachineName, Class_TFuelSrvr) as ITFuelSrvr;
end;


end.

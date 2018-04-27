unit FuelProg_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 8/22/2003 5:38:48 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Latitude\FuelProg\FuelProg.tlb (1)
// LIBID: {BF74F710-D775-11D0-9EA4-404000320608}
// LCID: 0
// Helpfile: 
// HelpString: FuelProg Library
// DepndLst: 
//   (1) v1.0 stdole, (C:\WINNT\System32\stdole32.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  FuelProgMajorVersion = 1;
  FuelProgMinorVersion = 0;

  LIBID_FuelProg: TGUID = '{BF74F710-D775-11D0-9EA4-404000320608}';

  IID_ITFuelProg: TGUID = '{BF74F711-D775-11D0-9EA4-404000320608}';
  CLASS_TFuelProg: TGUID = '{BF74F712-D775-11D0-9EA4-404000320608}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITFuelProg = interface;
  ITFuelProgDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TFuelProg = ITFuelProg;


// *********************************************************************//
// Interface: ITFuelProg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BF74F711-D775-11D0-9EA4-404000320608}
// *********************************************************************//
  ITFuelProg = interface(IDispatch)
    ['{BF74F711-D775-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
    procedure GetHeaderFooterData(var Hdr1: WideString; var Hdr2: WideString; var Hdr3: WideString; 
                                  var Hdr4: WideString; var Hdr5: WideString; var Ftr1: WideString; 
                                  var Ftr2: WideString; var Ftr3: WideString; var Ftr4: WideString; 
                                  var Ftr5: WideString; var Keyboard: WideString); safecall;
    procedure GetReaderData(var Readers: Integer; var UnitNo: WideString; var TermNo: WideString; 
                            var PumpStatus: WideString); safecall;
    procedure GetTechnicalData(var FuelStart1: WideString; var FuelStart2: WideString; 
                               var FeedH: Integer; var FeedF: Integer); safecall;
    procedure GetProdCodes(var ProdCodes: WideString); safecall;
    procedure GetScrollMessage(var ScrollMsg: WideString; var StaticMsg: WideString; 
                               var ScrollActive: Integer); safecall;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               Clientid: Integer); safecall;
    function GetCATPort: Integer; safecall;
    function GetCreditInterface: Integer; safecall;
    function CheckUserLogOn(UserID: Integer; var TerminalNo: Integer): WordBool; safecall;
    function CheckTerminalsClosed(ClosingTerminal: Integer): WordBool; safecall;
    function StackSpaceAvail(PumpNo: Integer): WordBool; safecall;
    function GetCATPostAuthTimeOut: Integer; safecall;
    procedure LogCATSale(TransNo: Integer; PumpNo: Integer; HoseNo: Integer; Volume: Currency; 
                         UnitPrice: Currency; SaleAmount: Currency; const CardNo: WideString; 
                         const ExpDate: WideString; const BatchNo: WideString; 
                         const SeqNo: WideString; const AuthCode: WideString; 
                         const Approval: WideString; const CPSData: WideString); safecall;
    procedure GetCATMsg(CATMsgNo: Integer; var CATMsg: WideString; var CATSound: Integer); safecall;
    procedure DisConnectPOSClient(const MachineName: WideString; Clientid: Integer); safecall;
    function GetPymtPreSelect: WordBool; safecall;
    function GetSwipeAfterHandle: WordBool; safecall;
    procedure ForceCloseFuel; safecall;
    procedure ForceCloseCAT; safecall;
    function GetDebitAllowed: WordBool; safecall;
    function ValidFuelSale(TerminalNo: Integer; PumpNo: Integer; SaleID: Integer): WordBool; safecall;
    function GetCATInterfaceType: Integer; safecall;
    function GetDebitOutside: WordBool; safecall;
    function GetCATDisplayType: Integer; safecall;
    function GetCarwashInterface: Integer; safecall;
    function Reserved(PumpNo: Integer): WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  ITFuelProgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {BF74F711-D775-11D0-9EA4-404000320608}
// *********************************************************************//
  ITFuelProgDisp = dispinterface
    ['{BF74F711-D775-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); dispid 1;
    procedure GetHeaderFooterData(var Hdr1: WideString; var Hdr2: WideString; var Hdr3: WideString; 
                                  var Hdr4: WideString; var Hdr5: WideString; var Ftr1: WideString; 
                                  var Ftr2: WideString; var Ftr3: WideString; var Ftr4: WideString; 
                                  var Ftr5: WideString; var Keyboard: WideString); dispid 2;
    procedure GetReaderData(var Readers: Integer; var UnitNo: WideString; var TermNo: WideString; 
                            var PumpStatus: WideString); dispid 3;
    procedure GetTechnicalData(var FuelStart1: WideString; var FuelStart2: WideString; 
                               var FeedH: Integer; var FeedF: Integer); dispid 4;
    procedure GetProdCodes(var ProdCodes: WideString); dispid 5;
    procedure GetScrollMessage(var ScrollMsg: WideString; var StaticMsg: WideString; 
                               var ScrollActive: Integer); dispid 6;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               Clientid: Integer); dispid 7;
    function GetCATPort: Integer; dispid 8;
    function GetCreditInterface: Integer; dispid 9;
    function CheckUserLogOn(UserID: Integer; var TerminalNo: Integer): WordBool; dispid 10;
    function CheckTerminalsClosed(ClosingTerminal: Integer): WordBool; dispid 11;
    function StackSpaceAvail(PumpNo: Integer): WordBool; dispid 12;
    function GetCATPostAuthTimeOut: Integer; dispid 13;
    procedure LogCATSale(TransNo: Integer; PumpNo: Integer; HoseNo: Integer; Volume: Currency; 
                         UnitPrice: Currency; SaleAmount: Currency; const CardNo: WideString; 
                         const ExpDate: WideString; const BatchNo: WideString; 
                         const SeqNo: WideString; const AuthCode: WideString; 
                         const Approval: WideString; const CPSData: WideString); dispid 14;
    procedure GetCATMsg(CATMsgNo: Integer; var CATMsg: WideString; var CATSound: Integer); dispid 15;
    procedure DisConnectPOSClient(const MachineName: WideString; Clientid: Integer); dispid 16;
    function GetPymtPreSelect: WordBool; dispid 17;
    function GetSwipeAfterHandle: WordBool; dispid 18;
    procedure ForceCloseFuel; dispid 19;
    procedure ForceCloseCAT; dispid 20;
    function GetDebitAllowed: WordBool; dispid 21;
    function ValidFuelSale(TerminalNo: Integer; PumpNo: Integer; SaleID: Integer): WordBool; dispid 22;
    function GetCATInterfaceType: Integer; dispid 23;
    function GetDebitOutside: WordBool; dispid 24;
    function GetCATDisplayType: Integer; dispid 25;
    function GetCarwashInterface: Integer; dispid 26;
    function Reserved(PumpNo: Integer): WordBool; dispid 201;
  end;

// *********************************************************************//
// The Class CoTFuelProg provides a Create and CreateRemote method to          
// create instances of the default interface ITFuelProg exposed by              
// the CoClass TFuelProg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTFuelProg = class
    class function Create: ITFuelProg;
    class function CreateRemote(const MachineName: string): ITFuelProg;
  end;

implementation

uses ComObj;

class function CoTFuelProg.Create: ITFuelProg;
begin
  Result := CreateComObject(CLASS_TFuelProg) as ITFuelProg;
end;

class function CoTFuelProg.CreateRemote(const MachineName: string): ITFuelProg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TFuelProg) as ITFuelProg;
end;

end.

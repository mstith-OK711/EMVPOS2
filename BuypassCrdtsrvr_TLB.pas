unit BuypassCrdtsrvr_TLB;

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
// File generated on 7/9/2003 10:37:30 AM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Latitude\BuypassCredit\BuypassCredit.tlb (1)
// LIBID: {A63AF955-3965-42DB-9CE9-DB5D1CCFD084}
// LCID: 0
// Helpfile: 
// HelpString: BuypassCrdtsrvr Library
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
  BuypassCrdtsrvrMajorVersion = 1;
  BuypassCrdtsrvrMinorVersion = 0;

  LIBID_BuypassCrdtsrvr: TGUID = '{A63AF955-3965-42DB-9CE9-DB5D1CCFD084}';

  IID_ITBuypassCrdtSrvr: TGUID = '{D7DCB40E-BDAB-45F1-A6D9-7257E1C7F447}';
  CLASS_TBuypassCrdtSrvr: TGUID = '{453978F2-60FC-48AF-9271-B9D93072497E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITBuypassCrdtSrvr = interface;
  ITBuypassCrdtSrvrDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TBuypassCrdtSrvr = ITBuypassCrdtSrvr;


// *********************************************************************//
// Interface: ITBuypassCrdtSrvr
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D7DCB40E-BDAB-45F1-A6D9-7257E1C7F447}
// *********************************************************************//
  ITBuypassCrdtSrvr = interface(IDispatch)
    ['{D7DCB40E-BDAB-45F1-A6D9-7257E1C7F447}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); safecall;
    function ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                       const ServiceCode: WideString; var CardError: WideString; 
                       var CardType: WideString; var CardTypeName: WideString; 
                       var GetPIN: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                       var AskDebit: WordBool): WordBool; safecall;
    function GetUserData(CardType: Integer; const SalesData: WideString): WideString; safecall;
    procedure DisConnectPOSClient(const MachineName: WideString; ClientID: Integer); safecall;
    function ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                           const ServiceCode: WideString; CardType: Integer; 
                           const SalesData: WideString; var CardError: WideString): WordBool; safecall;
    procedure ForceCloseCredit; safecall;
    procedure ConnectFuelClient(const MachineName: WideString; const ServerName: WideString; 
                                ClientID: Integer); safecall;
    procedure DisconnectFuelClient(const MachineName: WideString; ClientID: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  ITBuypassCrdtSrvrDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D7DCB40E-BDAB-45F1-A6D9-7257E1C7F447}
// *********************************************************************//
  ITBuypassCrdtSrvrDisp = dispinterface
    ['{D7DCB40E-BDAB-45F1-A6D9-7257E1C7F447}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); dispid 1;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); dispid 2;
    function ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                       const ServiceCode: WideString; var CardError: WideString; 
                       var CardType: WideString; var CardTypeName: WideString; 
                       var GetPIN: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                       var AskDebit: WordBool): WordBool; dispid 3;
    function GetUserData(CardType: Integer; const SalesData: WideString): WideString; dispid 4;
    procedure DisConnectPOSClient(const MachineName: WideString; ClientID: Integer); dispid 5;
    function ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                           const ServiceCode: WideString; CardType: Integer; 
                           const SalesData: WideString; var CardError: WideString): WordBool; dispid 6;
    procedure ForceCloseCredit; dispid 7;
    procedure ConnectFuelClient(const MachineName: WideString; const ServerName: WideString; 
                                ClientID: Integer); dispid 8;
    procedure DisconnectFuelClient(const MachineName: WideString; ClientID: Integer); dispid 9;
  end;

// *********************************************************************//
// The Class CoTBuypassCrdtSrvr provides a Create and CreateRemote method to          
// create instances of the default interface ITBuypassCrdtSrvr exposed by              
// the CoClass TBuypassCrdtSrvr. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTBuypassCrdtSrvr = class
    class function Create: ITBuypassCrdtSrvr;
    class function CreateRemote(const MachineName: string): ITBuypassCrdtSrvr;
  end;

implementation

uses ComObj;

class function CoTBuypassCrdtSrvr.Create: ITBuypassCrdtSrvr;
begin
  Result := CreateComObject(CLASS_TBuypassCrdtSrvr) as ITBuypassCrdtSrvr;
end;

class function CoTBuypassCrdtSrvr.CreateRemote(const MachineName: string): ITBuypassCrdtSrvr;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TBuypassCrdtSrvr) as ITBuypassCrdtSrvr;
end;

end.

unit ADSCrdtsrvr_TLB;

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
// File generated on 1/29/2003 3:19:00 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Latitude\ADSCredit\ADSCredit.tlb (1)
// LIBID: {2EF562C0-D76A-11D0-9EA4-404000320608}
// LCID: 0
// Helpfile: 
// HelpString: ADSCrdtsrvr Library
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
  ADSCrdtsrvrMajorVersion = 1;
  ADSCrdtsrvrMinorVersion = 0;

  LIBID_ADSCrdtsrvr: TGUID = '{2EF562C0-D76A-11D0-9EA4-404000320608}';

  IID_ITADSCrdtSrvr: TGUID = '{2EF562C1-D76A-11D0-9EA4-404000320608}';
  CLASS_TADSCrdtSrvr: TGUID = '{2EF562C2-D76A-11D0-9EA4-404000320608}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITADSCrdtSrvr = interface;
  ITADSCrdtSrvrDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TADSCrdtSrvr = ITADSCrdtSrvr;


// *********************************************************************//
// Interface: ITADSCrdtSrvr
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {2EF562C1-D76A-11D0-9EA4-404000320608}
// *********************************************************************//
  ITADSCrdtSrvr = interface(IDispatch)
    ['{2EF562C1-D76A-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); safecall;
    function ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                       const ServiceCode: WideString; var CardError: WideString; 
                       var CardType: WideString; var CardTypeName: WideString; 
                       var GetPin: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                       var AskDebit: WordBool): WordBool; safecall;
    function GetUserData(CardType: Integer; const SalesData: WideString): WideString; safecall;
    procedure DisconnectPOSClient(const MachineName: WideString; ClientID: Integer); safecall;
    function ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                           const ServiceCode: WideString; CardType: Integer; 
                           const SalesData: WideString; var CardError: WideString): WordBool; safecall;
    procedure ForceCloseCredit; safecall;
    procedure ConnectFuelClient(const MachineName: WideString; const ServerName: WideString; 
                                ClientID: Integer); safecall;
    procedure DisconnectFuelClient(const MachineName: WideString; ClientID: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  ITADSCrdtSrvrDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {2EF562C1-D76A-11D0-9EA4-404000320608}
// *********************************************************************//
  ITADSCrdtSrvrDisp = dispinterface
    ['{2EF562C1-D76A-11D0-9EA4-404000320608}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); dispid 1;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); dispid 2;
    function ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                       const ServiceCode: WideString; var CardError: WideString; 
                       var CardType: WideString; var CardTypeName: WideString; 
                       var GetPin: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                       var AskDebit: WordBool): WordBool; dispid 201;
    function GetUserData(CardType: Integer; const SalesData: WideString): WideString; dispid 202;
    procedure DisconnectPOSClient(const MachineName: WideString; ClientID: Integer); dispid 203;
    function ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                           const ServiceCode: WideString; CardType: Integer; 
                           const SalesData: WideString; var CardError: WideString): WordBool; dispid 204;
    procedure ForceCloseCredit; dispid 205;
    procedure ConnectFuelClient(const MachineName: WideString; const ServerName: WideString; 
                                ClientID: Integer); dispid 206;
    procedure DisconnectFuelClient(const MachineName: WideString; ClientID: Integer); dispid 207;
  end;

// *********************************************************************//
// The Class CoTADSCrdtSrvr provides a Create and CreateRemote method to          
// create instances of the default interface ITADSCrdtSrvr exposed by              
// the CoClass TADSCrdtSrvr. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTADSCrdtSrvr = class
    class function Create: ITADSCrdtSrvr;
    class function CreateRemote(const MachineName: string): ITADSCrdtSrvr;
  end;

implementation

uses ComObj;

class function CoTADSCrdtSrvr.Create: ITADSCrdtSrvr;
begin
  Result := CreateComObject(CLASS_TADSCrdtSrvr) as ITADSCrdtSrvr;
end;

class function CoTADSCrdtSrvr.CreateRemote(const MachineName: string): ITADSCrdtSrvr;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TADSCrdtSrvr) as ITADSCrdtSrvr;
end;

end.

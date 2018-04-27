unit NBSCrdtsrvr_TLB;

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

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 4/11/2001 4:22:57 PM from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\Latitude\NBSCredit\NBSCredit.tlb (1)
// IID\LCID: {510D2244-3F5D-11D3-B513-00A024EC7B26}\0
// Helpfile: 
// DepndLst: 
//   (1) v1.0 stdole, (C:\WINDOWS\System32\stdole32.tlb)
//   (2) v2.0 StdType, (C:\WINDOWS\System32\olepro32.dll)
//   (3) v1.0 StdVCL, (C:\WINDOWS\System32\STDVCL32.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  NBSCrdtsrvrMajorVersion = 1;
  NBSCrdtsrvrMinorVersion = 0;

  LIBID_NBSCrdtsrvr: TGUID = '{510D2244-3F5D-11D3-B513-00A024EC7B26}';

  IID_ITNBSCrdtSrvr: TGUID = '{510D2245-3F5D-11D3-B513-00A024EC7B26}';
  CLASS_TNBSCrdtSrvr: TGUID = '{510D2246-3F5D-11D3-B513-00A024EC7B26}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITNBSCrdtSrvr = interface;
  ITNBSCrdtSrvrDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TNBSCrdtSrvr = ITNBSCrdtSrvr;


// *********************************************************************//
// Interface: ITNBSCrdtSrvr
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {510D2245-3F5D-11D3-B513-00A024EC7B26}
// *********************************************************************//
  ITNBSCrdtSrvr = interface(IDispatch)
    ['{510D2245-3F5D-11D3-B513-00A024EC7B26}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); safecall;
    function  ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                        const ServiceCode: WideString; var CardError: WideString; 
                        var CardType: WideString; var CardTypeName: WideString; 
                        var GetPIN: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                        var AskDebit: WordBool): WordBool; safecall;
    function  GetUserData(CardType: Integer; const SalesData: WideString): WideString; safecall;
    procedure DisConnectPOSClient(const MachineName: WideString; ClientID: Integer); safecall;
    function  ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                            const ServiceCode: WideString; CardType: Integer; 
                            const SalesData: WideString; var CardError: WideString): WordBool; safecall;
    procedure ForceCloseCredit; safecall;
  end;

// *********************************************************************//
// DispIntf:  ITNBSCrdtSrvrDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {510D2245-3F5D-11D3-B513-00A024EC7B26}
// *********************************************************************//
  ITNBSCrdtSrvrDisp = dispinterface
    ['{510D2245-3F5D-11D3-B513-00A024EC7B26}']
    procedure SendMsg(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); dispid 1;
    procedure ConnectPOSClient(const MachineName: WideString; const ServerName: WideString; 
                               ClientID: Integer); dispid 2;
    function  ValidCard(const CardNo: WideString; const ExpDate: WideString; 
                        const ServiceCode: WideString; var CardError: WideString; 
                        var CardType: WideString; var CardTypeName: WideString; 
                        var GetPIN: WordBool; var GetOdometer: WordBool; var GetRefNo: WordBool; 
                        var AskDebit: WordBool): WordBool; dispid 3;
    function  GetUserData(CardType: Integer; const SalesData: WideString): WideString; dispid 4;
    procedure DisConnectPOSClient(const MachineName: WideString; ClientID: Integer); dispid 5;
    function  ValidProducts(const CardNo: WideString; const ExpDate: WideString; 
                            const ServiceCode: WideString; CardType: Integer; 
                            const SalesData: WideString; var CardError: WideString): WordBool; dispid 6;
    procedure ForceCloseCredit; dispid 7;
  end;

// *********************************************************************//
// The Class CoTNBSCrdtSrvr provides a Create and CreateRemote method to          
// create instances of the default interface ITNBSCrdtSrvr exposed by              
// the CoClass TNBSCrdtSrvr. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTNBSCrdtSrvr = class
    class function Create: ITNBSCrdtSrvr;
    class function CreateRemote(const MachineName: string): ITNBSCrdtSrvr;
  end;

implementation

uses ComObj;

class function CoTNBSCrdtSrvr.Create: ITNBSCrdtSrvr;
begin
  Result := CreateComObject(CLASS_TNBSCrdtSrvr) as ITNBSCrdtSrvr;
end;

class function CoTNBSCrdtSrvr.CreateRemote(const MachineName: string): ITNBSCrdtSrvr;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TNBSCrdtSrvr) as ITNBSCrdtSrvr;
end;

end.

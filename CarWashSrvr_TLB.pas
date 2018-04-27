unit CarWashSrvr_TLB;

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
// File generated on 9/9/2003 1:46:33 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Latitude\Carwash\CarWash.tlb (1)
// LIBID: {479AB796-C564-11D6-B98D-0008C7527C22}
// LCID: 0
// Helpfile: 
// HelpString: Project1 Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\system32\stdole2.tlb)
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
  CarWashSrvrMajorVersion = 1;
  CarWashSrvrMinorVersion = 0;

  LIBID_CarWashSrvr: TGUID = '{479AB796-C564-11D6-B98D-0008C7527C22}';

  IID_ICarWash: TGUID = '{479AB797-C564-11D6-B98D-0008C7527C22}';
  DIID_ICarWashEvents: TGUID = '{479AB799-C564-11D6-B98D-0008C7527C22}';
  CLASS_TCarWash: TGUID = '{479AB79B-C564-11D6-B98D-0008C7527C22}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ICarWash = interface;
  ICarWashDisp = dispinterface;
  ICarWashEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TCarWash = ICarWash;


// *********************************************************************//
// Interface: ICarWash
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {479AB797-C564-11D6-B98D-0008C7527C22}
// *********************************************************************//
  ICarWash = interface(IDispatch)
    ['{479AB797-C564-11D6-B98D-0008C7527C22}']
    procedure SendMsg(const Dest: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
    procedure ForceCloseCarWash; safecall;
    function GetCarwashProductInfo(ProductIndex: Integer; var CWName: WideString; 
                                   var CWPrice: Currency; var CWPLUNo: Integer; 
                                   var CWDeptNo: Integer): WordBool; safecall;
    procedure SetMsgEvent(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); safecall;
  end;

// *********************************************************************//
// DispIntf:  ICarWashDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {479AB797-C564-11D6-B98D-0008C7527C22}
// *********************************************************************//
  ICarWashDisp = dispinterface
    ['{479AB797-C564-11D6-B98D-0008C7527C22}']
    procedure SendMsg(const Dest: WideString; TerminalNo: Integer; const Msg: WideString); dispid 1;
    procedure ForceCloseCarWash; dispid 7;
    function GetCarwashProductInfo(ProductIndex: Integer; var CWName: WideString; 
                                   var CWPrice: Currency; var CWPLUNo: Integer; 
                                   var CWDeptNo: Integer): WordBool; dispid 3;
    procedure SetMsgEvent(const Orig: WideString; TerminalNo: Integer; const Msg: WideString); dispid 201;
  end;

// *********************************************************************//
// DispIntf:  ICarWashEvents
// Flags:     (4096) Dispatchable
// GUID:      {479AB799-C564-11D6-B98D-0008C7527C22}
// *********************************************************************//
  ICarWashEvents = dispinterface
    ['{479AB799-C564-11D6-B98D-0008C7527C22}']
    procedure GotMsgEvent(const Dest: WideString; TerminalNo: Integer; const Msg: WideString); dispid 201;
  end;

// *********************************************************************//
// The Class CoTCarWash provides a Create and CreateRemote method to          
// create instances of the default interface ICarWash exposed by              
// the CoClass TCarWash. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTCarWash = class
    class function Create: ICarWash;
    class function CreateRemote(const MachineName: string): ICarWash;
  end;

implementation

uses ComObj;

class function CoTCarWash.Create: ICarWash;
begin
  Result := CreateComObject(CLASS_TCarWash) as ICarWash;
end;

class function CoTCarWash.CreateRemote(const MachineName: string): ICarWash;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TCarWash) as ICarWash;
end;

end.

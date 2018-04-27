unit OLECrdt;

interface

uses
  ComObj, ActiveX, NBSCrdtsrvr_TLB, SysUtils, Dialogs;

type
  TTNBSCrdtSrvr = class(TAutoObject, ITNBSCrdtSrvr)
  protected
    procedure SendMsg(const Orig: WideString; TerminalNo, MsgLen: Integer;
      const Msg: WideString); safecall;
    procedure ClientConnect(const MachineName, ServerName, GUID: WideString;
      ClientID: Integer); safecall;
  end;

Var
 OleMsg     : String;
 OleMsgLen  : Integer;

implementation

uses ComServ, NBSMain, MConnect;

procedure TTNBSCrdtSrvr.SendMsg(const Orig: WideString; TerminalNo,
  MsgLen: Integer; const Msg: WideString);
begin
   fmCreditServer.Socket1ReceiveMessage(Orig, TerminalNo, MsgLen, Msg)
end;

procedure TTNBSCrdtSrvr.ClientConnect(const MachineName, ServerName,
  GUID: WideString; ClientID: Integer);
begin
//  ShowMessage('Client Connect Initiated :' + #10#13 + MaschineName + ' / ' + ServerName + ' / ' + GUID);

  DCOMPOS := TDComConnection.Create(fmCreditServer);
  try
    DCOMPOS.ComputerName  := MachineName;
    DCOMPOS.ServerName    := ServerName;
    DCOMPOS.ServerGUID    := GUID;
    DCOMPOS.Connected     := True;               // Try to connect to calling Client
    ClientNo := ClientId;
  except
    on E: Exception do
      begin
        ShowMessage ('Error connecting to DCOM Application Client' + #10#13+ 'Reason: ' + E.Message);
        DComPOS.Free;
      end;
  end;

end;

initialization
  TAutoObjectFactory.Create(ComServer, TTNBSCrdtSrvr, Class_TNBSCrdtSrvr,
      ciMultiInstance, tmApartment);
end.

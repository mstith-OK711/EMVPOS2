{-----------------------------------------------------------------------------
 Unit Name: Mainmenu
 Author:    Gary Whetton
 Date:      9/11/2003 3:05:30 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit Mainmenu;
{$I ConditionalCompileSymbols.txt}  // PUMP_ICON_EXT
interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls, StdCtrls, Mask, TrayIcon, ShellAPI, DB, Registry;

const
WM_STARTPOS = WM_USER + 200;
WM_SHOWPOS   = WM_USER + 998;
WM_KILLPOS   = WM_USER + 999;
WM_CLOSEPOS = WM_USER + 300;

type
  TPOSMenu = class(TForm)
    Bevel1: TBevel;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure POS1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure FormActivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure StartPOS(var Msg: TMessage); message WM_STARTPOS;
    procedure KillPOS(var Msg: TMessage); message WM_KILLPOS;
    procedure ShowPOS(var Msg: TMessage); message WM_SHOWPOS;
    procedure ClosePOS(var Msg: TMessage); message WM_CLOSEPOS;
    procedure ResetScreen;
  end;

var
  POSMenu: TPOSMenu;
  RTop, RBottom : Integer;
  RLeft, RRight : Integer;
  SavedBmp, LastSavedBmp : TBitMap;
  R0, R1, R2, R3 : TRect;
  POSStarted : boolean = False;


implementation

uses POSMain, POSDM, POSMsg, POSErr, POSMisc, FuelSel, PluRpt, GetAge,
  //cwa...
//ADSCC, NBSCC, CCRecpt, FuelRcpt, PopMsg, PosUser;
     NBSCC,CWAccess, CCRecpt, FuelRcpt, PopMsg, PosUser, EnterAge,
     JCLDebug, ExceptLog;
  //...cwa
{$R *.DFM}
{$IFDEF PUMP_ICON_EXT}
  {$R POSFUEL_NEW.RES}
{$ELSE}
  {$R POSFUEL.RES}
{$ENDIF}
{$R BTNCLR.RES}
{$R POSSND.RES}
{$R SPLASH.RES}
{$R POSTRAY.RES}

{-----------------------------------------------------------------------------
  Name:      TPOSMenu.KillPOS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.KillPOS(var Msg:TMessage);
begin
  PostMessage(fmPOS.Handle, WM_KILLPOS,0,0);
end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.StartPOS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.StartPOS(var Msg:TMessage);
begin
  POS1Click(Self);
end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.ShowPOS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.ShowPOS(var Msg:TMessage);
begin
  fmPOS.Show;
end;

procedure TPOSMenu.ClosePOS(var Msg:TMessage);
begin
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.Exit1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.Exit1Click(Sender: TObject);
begin
  if MessageDlg('Are You Sure?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    Close;
end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.POS1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.POS1Click(Sender: TObject);
begin
  POSMenu.Image1.Repaint;
  fmPOS.Show;
  POSStarted := True;
end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.FormShow(Sender: TObject);
begin

  POSMenu.Left := 0;
  POSMenu.Top  := 0;

  POSMenu.Width  := Screen.Width;
  if POSMenu.Width = 1024 then
    begin
      POSMenu.Height := 763;
      Image1.Width := 1024;
      Image1.Height := 760;
      Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'SPLASHBG');
    end
  else
    begin
      POSMenu.Height := 595;
      Image1.Width := 800;
      Image1.Height := 575;
      Image1.Picture.Bitmap.LoadFromResourceName(HInstance, 'SPLASHSM');
    end;
  //Build 26
  (*for count := 1 to 5 do { until successful or Cancel button is pressed }
    begin
      try
        POSDataMod.IBDB. Connected := True;
        Break; { If no error, exit the loop }
      except
        on EDatabaseError do
          sleep(5000);
      end;
    end;*)
  //Build 26

  if fmPOSMsg.Visible = True then
    fmPOSMsg.Close;

end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.FormCreate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.FormCreate(Sender: TObject);
Var
//cwe  VerInfoSize: DWord;
//cwe  VerInfo: Pointer;
//cwe  VerValueSize: DWord;
//cwe  VerValue: PVSFixedFileInfo;
//cwe  V1, V2, V3, V4, Dummy: DWord;

POSRegEntry : TRegIniFile;
dblocation : string;


begin
  Include(JclStackTrackingOptions, stRawMode);
  Include(JclStackTrackingOptions, stStaticModuleList);
  JclStartExceptionTracking;

  Application.OnException := AppException;

  POSRegEntry    := TRegIniFile.Create('Latitude');
  dblocation     := POSRegEntry.ReadString( 'LatitudeConfig', 'DBLocation', '');
  POSRegEntry.Free;

  if dblocation = '' then
    Application.Terminate;

  updateexceptlog('Attempting connection to %s', [dblocation]);
  //POSDataMod.IBDB.DatabaseName := '\\' + MasterUNC + '\' + MasterDrive + ':\Latitude\Data\RsgData.gdb';
  POSDataMod.IBDB.DatabaseName := dblocation;

end;




// Application Exception Handler
{-----------------------------------------------------------------------------
  Name:      TPOSMenu.AppException
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; E: Exception
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.AppException(Sender: TObject; E: Exception);
var
  elog : TStrings;
  eline : integer;
begin
//  Application.ShowException(E);

  if (E is Exception) then            // Delphi Exception
    begin
      {$IFDEF DEBUG}
      if pos('range', e.Message) > 0 then
        ShowMessage('Range Error');
      {$ENDIF}
      {Log Exception to File}
      if Pos('DB is not open',E.Message) > 0 then
      try
        fmPOS.OpenTables(false);
        UpdateExceptLog('Reconnected during exception');
      except
      end;
//      {$IFDEF DEV_TEST}
//      if Pos('Error writing data to the connection',E.Message) > 0 then
//      begin
//        try
//          fmPOS.CloseTables();
//          fmPOS.OpenTables(false);
//          UpdateExceptLog('Reconnected during exception');
//        except
//        end;
//      end;
//      {$ENDIF}
      elog := TStringList.Create;
      elog.Add(Format('%s - %s: %s', [Sender.ClassName, E.ClassName, E.Message]));
      UpdateZLog('Exception occured: %s - %s: %s', [Sender.ClassName, E.ClassName, E.Message]);
      JclLastExceptStackListToStrings(elog, False, True, True, False);
      for eline := 0 to elog.Count-1 do
	 UpdateExceptLog(elog.Strings[eline]);
      elog.Destroy;
    end;

end; {procedure AppException}





{-----------------------------------------------------------------------------
  Name:      TPOSMenu.FormActivate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.FormActivate(Sender: TObject);
begin
  if POSStarted then
    ResetScreen;

end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.FormPaint
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.FormPaint(Sender: TObject);
begin

  if POSStarted then
    ResetScreen;

end;


{-----------------------------------------------------------------------------
  Name:      TPOSMenu.ResetScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TPOSMenu.ResetScreen;
begin

  SetForeGroundWindow(fmPOS.Handle);

  if (fmPOSErrorMsg.Visible = True) then
    begin
      if fmPOSErrorMsg.Handle <> GetActiveWindow then
        SetActiveWindow (fmPOSErrorMsg.Handle) ;
    end
  else if (fmPOSMsg.Visible = True) then
    begin
      if fmPOSMsg.Handle <> GetActiveWindow then
        SetActiveWindow (fmPOSMsg.Handle) ;
    end
  else if (fmFuelSelect.Visible = True) then
    begin
      if fmFuelSelect.Handle <> GetActiveWindow then
        SetActiveWindow (fmFuelSelect.Handle) ;
      exit;
    end
  else if (fmPLUSalesReport.Visible = True) then
    begin
      if fmPLUSalesReport.Handle <> GetActiveWindow then
        SetActiveWindow (fmPLUSalesReport.Handle) ;
      exit;
    end
  else if (fmValidAge.Visible = True) then
    begin
      if fmValidAge.Handle <> GetActiveWindow then
        SetActiveWindow (fmValidAge.Handle) ;
      exit;
    end
  else if (fmEnterAge.Visible = True) then
    begin
      if fmEnterAge.Handle <> GetActiveWindow then
        SetActiveWindow (fmEnterAge.Handle) ;
      exit;
    end
  (*else if (fmADSCCForm.Visible = True) then
    begin
      if fmADSCCForm.Handle <> GetActiveWindow then
        SetActiveWindow (fmADSCCForm.Handle) ;
    end*)
  else if (fmNBSCCForm.Visible = True) then
    begin
      if fmNBSCCForm.Handle <> GetActiveWindow then
        SetActiveWindow (fmNBSCCForm.Handle) ;
    end
  //cwa...
  else if (fmCWAccessForm.Visible = True) then
    begin
      if fmCWAccessForm.Handle <> GetActiveWindow then
        SetActiveWindow (fmCWAccessForm.Handle) ;
    end
  //...cwa
  else if (fmCardReceipt.Visible = True) then
    begin
      if fmCardReceipt.Handle <> GetActiveWindow then
        SetActiveWindow (fmCardReceipt.Handle) ;
      exit;
    end
  else if (fmFuelReceipt.Visible = True) then
    begin
      if fmFuelReceipt.Handle <> GetActiveWindow then
        SetActiveWindow (fmFuelReceipt.Handle) ;
      exit;
    end
  else if (fmPopUpMsg.Visible = True) then
    begin
      if fmPopUpMsg.Handle <> GetActiveWindow then
        SetActiveWindow (fmPopUpMsg.Handle) ;
    end
  else if (fmUser.Visible = True) then
    begin
      if fmUser.Handle <> GetActiveWindow then
        SetActiveWindow (fmUser.Handle) ;
      exit;
    end;

end;

end.

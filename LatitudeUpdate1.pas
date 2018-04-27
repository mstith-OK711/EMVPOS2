unit LatitudeUpdate1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const
WM_UPDATEPOS = WM_USER + 200;

type
  TfmLatitudeUpdate = class(TForm)
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdatePOS(var Msg: TMessage); message WM_UPDATEPOS;
    procedure CopyUpdateFile(UpdateFileName : string);
  end;

var
  fmLatitudeUpdate: TfmLatitudeUpdate;

implementation

uses
  Registry,
  NTProcess;

{$R *.DFM}

procedure TfmLatitudeUpdate.FormShow(Sender: TObject);
begin

  PostMessage(fmLatitudeUpdate.Handle, WM_UPDATEPOS,0,0);

end;

procedure TfmLatitudeUpdate.UpdatePOS(var Msg:TMessage);
var
  i,j              : Integer;
  ServerAppHandle  : Hwnd;
  zAppName:array[0..512] of char;
  zCurDir:array[0..255] of char;
  WorkDir:String;
  StartupInfo:TStartupInfo;
  ProcessInfo:TProcessInformation;
  ProcessList : TNTProcessList;
  Process : TNTProcess;
  found : boolean;
  en : string;
  han : THandle;
  POSRegEntry : TRegIniFile;
  dblocation : string;
begin

  Label1.Caption := 'Closing Prior Version';
  Label1.Refresh;

  i:= 1;
  Repeat
    ServerAppHandle := FindWindow('TPOSMenu', nil);
    If (ServerAppHandle <> 0) Then
      Begin
        Label1.Caption := 'Closing Prior Version ' + IntToStr(i);
        Label1.Refresh;

        PostMessage(ServerAppHandle, WM_Close , 0, 0);
        For j:= 1 to 1000 do
          Application.ProcessMessages;
        Inc(i);
        sleep(200);
      End
    else
      break;
  Until i > 50;

  ProcessList := nil;
  Process := nil;
  try
    ProcessList := TNTProcessList.Create(Self);
    try
    Process := TNTProcess.Create(Self);
    j := 0;
    repeat
      found := false;
      if ProcessList.Count > 0 then
      begin
        for i := 0 to ProcessList.Count - 1 do
        begin
          ProcessList.GetProcess(i,Process);
          try
            en := Process.BaseName;
          except
            en := 'UNKNOWN';
          end;
          if en = 'Latitude.exe' then
          begin
            Label1.Caption := 'UpdatePOS: Found Latitude.exe at pid ' + IntToStr(ProcessList.PID[i]);
            Label1.Refresh;
            found := true;
            han := OpenProcess (PROCESS_TERMINATE, False, ProcessList.PID[i]);
            if han <> 0 then
            try
              Windows.TerminateProcess(han, 0);
            except
              on E: Exception do
              begin
                Label1.Caption := 'UpdatePOS: Cannot TerminateProcess - ' + E.Message;
                Label1.Refresh;
              end;
            end;
          end;
        end;
      end;
      sleep(200);
      ProcessList.Refresh;
      inc(j);
    until (not found) or (j > 5);
  finally
    Process.Free;
  end
  finally
    ProcessList.Free;
  end;

  POSRegEntry    := TRegIniFile.Create('Latitude');
  dblocation     := POSRegEntry.ReadString( 'LatitudeConfig', 'DBLocation', '');
  if dblocation = '' then
  begin
    dblocation := POSRegEntry.ReadString( 'LatitudeConfig', 'MasterUNC', '') + ':' + POSRegEntry.ReadString( 'LatitudeConfig', 'MasterDrive', '') + ':/Latitude/Data/RsgData.gdb';
    POSRegEntry.WriteString('LatitudeConfig', 'DBLocation', dblocation);
  end;
  POSRegEntry.Free;

  Sleep(50);
  CopyUpdateFile( 'Latitude.exe' );
  CopyUpdateFile( 'Latitude.map' );

  Label1.Caption := 'Latitude is Re-Starting';
  Label1.Refresh;

  StrPCopy(zAppName, '\Latitude\Latitude.exe');
  GetDir(0,WorkDir);
  StrPCopy(zCurDir,WorkDir);
  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_NORMAL;
  if not CreateProcess(nil,
                       zAppName, { pointer to command line string}
                       nil, { pointer to process security attributes }
                       nil, { pointer to thread security attributes }
                       false, { handle inheritance flag }
                       CREATE_NEW_CONSOLE or { creation flags } NORMAL_PRIORITY_CLASS,
                       nil, { pointer to new environment block }
                       nil, { pointer to current directory name }
                       StartupInfo, { pointer to STARTUPINFO }
                       ProcessInfo) then  { pointer to PROCESS_INF }
  else
    begin
     CloseHandle( ProcessInfo.hProcess );
     CloseHandle( ProcessInfo.hThread );
    end;



  Label1.Caption := 'Closing Update';
  Label1.Refresh;

  Close;

end;


procedure TfmLatitudeUpdate.CopyUpdateFile(UpdateFileName : string);
begin

  Label1.Caption := 'Saving Prior Software Version';
  Label1.Refresh;
  if FileExists('\Latitude\' + UpdateFileName) then
    CopyFile( PChar('\Latitude\' + UpdateFileName),
      PChar('\Latitude\SWBackUp\' + UpdateFileName + 'sav' + FormatDateTime('yymmdd', Now)),
                 False);

  Label1.Caption := 'Removing Prior Version';
  Label1.Refresh;

  DeleteFile( '\Latitude\' + UpdateFileName );

  Label1.Caption := 'Installing New Software Version';
  Label1.Refresh;

  CopyFile( PChar('\Latitude\Update\' + UpdateFileName),
      PChar('\Latitude\' + UpdateFileName), False);

  Label1.Caption := 'Removing Update';
  Label1.Refresh;

  DeleteFile( '\Latitude\Update\' + UpdateFileName );

end;


end.

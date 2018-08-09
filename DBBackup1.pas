unit DBBackup1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TrayIcon, Db, DBTables, IBServices, IBDatabase, IBCustomDataSet, IBQuery, Registry;

const
UM_PROCESSCOMMAND  = WM_USER + 100;

type

  TForm1 = class(TForm)
    IBBackupService1: TIBBackupService;
    DB: TIBDatabase;
    IBTransaction1: TIBTransaction;
    TempQuery: TIBQuery;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ProcessCommand(var Msg:TMessage); message UM_PROCESSCOMMAND;
  end;

function GetBuildInfo( var v1, v2, v3, v4 : Word ): boolean;
function GetBuildInfoString: string;

var
  Form1: TForm1;
  fmDBBackupIcon: TTrayIcon;


implementation

{$R *.DFM}
{$R DB.RES}



function GetBuildInfo( var v1, v2, v3, v4 : Word ): boolean;
var
VerInfoSize: DWord;
VerInfo: Pointer;
VerValueSize: DWord;
VerValue: PVSFixedFileInfo;
Dummy: DWord;

begin
  Result := false;
  VerInfoSize := GetFileVersionInfoSize( PChar( Application.ExeName ), Dummy );
  if VerInfoSize > 0 then
    begin
      GetMem( VerInfo, VerInfoSize );
      try
        GetFileVersionInfo( PChar( Application.ExeName ), 0, VerInfoSize, VerInfo );
        VerQueryValue( VerInfo, '\', Pointer( VerValue ), VerValueSize );
        with VerValue^ do
          begin
            v1 := dwFileVersionMS shr 16;
            v2 := dwFileVersionMS and $FFFF;
            v3 := dwFileVersionLS shr 16;
            v4 := dwFileVersionLS and $FFFF;
          end;
        Result := TRUE;
      finally
        FreeMem( VerInfo, VerInfoSize );
      end;
   end;
end;

function GetBuildInfoString: string;
var
v1, v2, v3, v4: Word;
begin

  if GetBuildInfo( v1, v2, v3, v4 ) then
    Result := Format( 'Ver: %d.%d.%d.%d', [v1,v2,v3,v4] )
  else
    Result := '';
end;




procedure TForm1.ProcessCommand(var Msg:TMessage);
var
sFullBackUpFileName : string;
sBackUpFileName     : string;

FromName, ToName : array[0..200] of char;

MasterTerminalUNCName  : string;
MasterTerminalAppDrive : string;

BackupTerminalNo       : integer;
BackUpTerminalUNCName  : string;
BackUpTerminalAppDrive : string;

i : integer;

POSRegEntry : TRegIniFile;
MasterUNC, MasterDrive : string;

begin

  Application.ProcessMessages;

  POSRegEntry    := TRegIniFile.Create('Latitude');
  MasterUNC      := POSRegEntry.ReadString( 'LatitudeConfig', 'MasterUNC', '');
  MasterDrive    := POSRegEntry.ReadString( 'LatitudeConfig', 'MasterDrive', '');
  POSRegEntry.Free;

  if MasterUNC = '' then
    Application.Terminate;

  DB.DatabaseName := '\\' + MasterUNC + '\' + MasterDrive + ':\Latitude\Data\RsgData.gdb';

  for i := 1 to 5 do { once in a while the db is a little slow to open }
    begin
      try

        DB.Connected := True;
        Break;
      except
        on EDatabaseError do
          sleep(5000);
      end;
      if i = 5 then
        Application.Terminate;
    end;

  MasterTerminalUNCName  := '';
  MasterTerminalAppDrive := '';

  BackupTerminalNo       := 0;
  BackUpTerminalUNCName  := '';
  BackUpTerminalAppDrive := '';

  // Get the name and number of the Master Terminal

  with TempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Terminal where TerminalType = 1');
      Open;
      if Not eof then
        begin
          MasterTerminalUNCName  := FieldByName('TerminalName').AsString;
          MasterTerminalAppDrive := FieldByName('AppDrive').AsString;
        end;
      close;
    end;

  // Get the name and number of the Back Up Terminal

  with TempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Terminal where TerminalType = 2');
      Open;
      if Not eof then
        begin
          BackupTerminalNo       := FieldByName('TerminalNo').AsInteger;
          BackUpTerminalUNCName  := FieldByName('TerminalName').AsString;
          BackUpTerminalAppDrive := FieldByName('AppDrive').AsString;
        end;
      close;
    end;

  DB.Connected := False;

  for i := 1 to 10 do
    begin
      sBackUpFileName := FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ]) + '.gbk';
      sFullBackUpFileName := MasterTerminalAppDrive + ':\Latitude\BackUp\' + FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ])  + '.gbk';
      if NOT(FileExists(sFullBackUpFileName)) then
        break;
    end;


  IBBackupService1.ServerName   := MasterTerminalUNCName;
  IBBackupService1.Protocol     := Local;
  IBBackupService1.LoginPrompt  := False;
  IBBackupService1.DataBaseName := MasterTerminalAppDrive + ':\Latitude\Data\RsgData.gdb';

  IBBackupService1.BackupFile.Clear;
  IBBackupService1.BackupFile.Add( sFullBackUpFileName );

  IBBackupService1.Params.Clear;
  IBBackUpService1.Params.Add('user_name=rsgretail');
  IBBackUpService1.Params.Add('password=pos');

  IBBackupService1.Active := True;
  IBBackupService1.Verbose := True;
  IBBackupService1.ServiceStart;
  while not IBBackupService1.Eof do
    begin
      IBBackupService1.GetNextLine;
    end;

  IBBackupService1.Active := False;

  FromName := '';
  ToName   := '';
  // if there is a backup terminal then copy the db backup to it
  if BackupTerminalNo > 0 then
    begin

      strpcopy(FromName, sFullBackUpFileName);
      strpcopy(ToName, '\\' + BackupTerminalUNCName + '\' + BackupTerminalAppDrive + '\Latitude\BackUp\' + sBackUpFileName );
      try
        CopyFile(FromName, ToName, False);
      except
      end;

    end;

  Close;

end;


procedure TForm1.FormCreate(Sender: TObject);
var
Ver : string;
begin

  Left := -5000;  { move it off the screen because it will flash on for a second
                     before the application processes all the messages }
  ShowWindowAsync( Handle, SW_HIDE );
  fmDBBackupIcon := TTrayIcon.Create(Self);
  fmDBBackupIcon.Icon.Handle := LoadIcon(HInstance, 'DBBackup');

  Ver := GetBuildInfoString;
  fmDBBackupIcon.Tooltip := 'Latitude' + #13 + 'DB Backup' + #13 + Ver;
  fmDBBackupIcon.Active := True;
  PostMessage( Form1.Handle, UM_PROCESSCOMMAND, 0, 0);


end;

initialization
begin
   { We want to hide the application TASKBAR icon }
   ShowWindow( Application.Handle, SW_HIDE );
   Application.ProcessMessages;
   Application.ShowMainForm := False;

end;

end.

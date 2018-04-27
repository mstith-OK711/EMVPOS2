program DBBackup;

uses
  Forms,
  DBBackup1 in 'DBBackup1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

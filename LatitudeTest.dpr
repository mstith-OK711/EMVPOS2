program LatitudeTest;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  Test_SaleClasses in 'Test_SaleClasses.pas',
  SaleClasses in 'SaleClasses.pas',
  Test_Hashes in 'Test_Hashes.pas',
  Encrypt in 'Encrypt.pas',
  Test_Encrypt in 'Test_Encrypt.pas',
  Test_POSMisc in '..\lib\Test_POSMisc.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

program SigEx;

uses
  Forms,
  SigExtract in 'SigExtract.pas' {SigExtractMain},
  IngSig in '..\lib\IngSig.pas',
  POSMisc in '..\lib\POSMisc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSigExtractMain, SigExtractMain);
  Application.Run;
end.

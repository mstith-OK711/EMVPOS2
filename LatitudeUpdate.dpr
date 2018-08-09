program LatitudeUpdate;

uses
  Forms,
  LatitudeUpdate1 in 'LatitudeUpdate1.pas' {fmLatitudeUpdate};

{$R *.RES}

{$R LatitudeUpdateVer.RES}

begin
  Application.Initialize;
  Application.Title := 'Latitude Update';
  Application.CreateForm(TfmLatitudeUpdate, fmLatitudeUpdate);
  Application.Run;
end.

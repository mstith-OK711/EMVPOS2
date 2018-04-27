unit SoundPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MMSystem;

type
  TSoundFrame = class(TFrame)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MakeNoise(SoundType : Byte);
  end;

implementation
uses POSMain, MainMenu;
{$R *.dfm}

procedure TSoundFrame.MakeNoise(SoundType : Byte);
begin
  case SoundType of
    STARTUPSOUND :
      begin
        fmPOS.bPlayWave := PlaySound( 'POSSTART', HInstance, SND_ASYNC or SND_RESOURCE) ;
      end;
  end;
end;
end.

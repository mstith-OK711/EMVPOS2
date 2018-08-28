unit Sounds;
interface
  uses
    MMSystem;
procedure MakeNoise(SoundType : Byte);

implementation
uses POSMain, MainMenu, POSDM;

procedure MakeNoise(SoundType : Byte);
begin
  if fmPOS.bPlayWave then
  begin
    case SoundType of
      DRIVEOFFSOUND :
        begin
          case DriveOffNoise of
            0: PlaySound( 'DRIVEOFF', HInstance, SND_ASYNC or SND_RESOURCE) ;
            1: PlaySound( 'DRIVEOFF711', HInstance, SND_ASYNC or SND_RESOURCE) ;
            2: PlaySound( 'DOH', HInstance, SND_ASYNC or SND_RESOURCE) ;
            else
              PlaySound( 'DRIVEOFF', HInstance, SND_ASYNC or SND_RESOURCE) ;
          end;
        end;
      RESPONSESOUND :
        begin
          case RespondNoise of
            0:  PlaySound( 'ERROR', HInstance, SND_ASYNC or SND_RESOURCE) ;
            1:  PlaySound( 'RESPONSE2', HInstance, SND_ASYNC or SND_RESOURCE) ;
          end;
        end;
      VALIDATEAGESOUND :
        begin
          case ValidateAgeNoise of
            0:  PlaySound( 'VALIDATE', HInstance, SND_ASYNC or SND_RESOURCE) ;
            1:  PlaySound( 'VERIFYAGE', HInstance, SND_ASYNC or SND_RESOURCE) ;
          end;
        end;
      ENTERDATESOUND :
        begin
          case EnterDateNoise of
            0:
              case ValidateAgeNoise of
                0:  PlaySound( 'VALIDATE', HInstance, SND_ASYNC or SND_RESOURCE) ;
                1:  PlaySound( 'VERIFYAGE', HInstance, SND_ASYNC or SND_RESOURCE) ;
              end;
            1:  PlaySound( 'BIRTHDAY', HInstance, SND_ASYNC or SND_RESOURCE) ;
          end;
        end;
      CATHELPSOUND :
        begin
          case CATHelpNoise of
            0:  PlaySound( 'HELP', HInstance, SND_ASYNC or SND_RESOURCE) ;//Tweety
            1:  PlaySound( 'HELP711', HInstance, SND_ASYNC or SND_RESOURCE) ;//Beep Beep
            2:  PlaySound( 'PUMPHELP', HInstance, SND_ASYNC or SND_RESOURCE) ; //Need Assistance
            3:  PlaySound( 'YELLHELP', HInstance, SND_ASYNC or SND_RESOURCE) ;
            4:  PlaySound( 'HOMERHELP', HInstance, SND_ASYNC or SND_RESOURCE) ;
            5:  PlaySound( 'SCREAM', HInstance, SND_ASYNC or SND_RESOURCE) ;
            else
              PlaySound( 'HELP', HInstance, SND_ASYNC or SND_RESOURCE) ;
          end;
        end;
    end;
  end;
end;
end.

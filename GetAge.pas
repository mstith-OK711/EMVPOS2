{-----------------------------------------------------------------------------
 Unit Name: GetAge
 Author:    Gary Whetton
 Date:      9/11/2003 3:01:46 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit GetAge;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, POSMain, ElastFrm, POSBtn, MultiLineButton, MMSystem;

  {$I ConditionalCompileSymbols.txt}

type
  TfmValidAge = class(TForm)
    lBeforeDate: TPanel;
    btnOK: TButton;
    btnNO: TButton;
    ElasticForm1: TElasticForm;
    btnEnterBDay: TMultiLineButton;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnNOClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnEnterBDayClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
//    AgeValidationType : integer;
    AgeRestriction : integer;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
  end;

var
  fmValidAge: TfmValidAge;
  EntDate: TDateTime;
  Year, Month, Day: word;
  KeyBuff: array[0..200] of Char;
  BuffPtr: short;

implementation

uses POSDM, POSLog, Sounds;

var
  // Keyboard Handling (GetAge)
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmValidAge.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.FormShow(Sender: TObject);
begin

  fmValidAge.Top := Trunc(((Screen.Height - fmValidAge.Height) / 2)) + 50;
  fmValidAge.Left := Trunc(((Screen.Width - fmValidAge.Width) / 2));
  (*{$IFDEF TOC}
  if fmPOS.bPlayWave then PlaySound( 'VERIFYAGE', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$else}
  if fmPOS.bPlayWave then PlaySound( 'VALIDATE', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$ENDif}*)
  if fmPOS.bPlayWave then MakeNoise( VALIDATEAGESOUND) ;
end;


{-----------------------------------------------------------------------------
  Name:      TfmValidAge.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.CheckKey(var Msg : TWMPOSKey);
var
 sKeyChar  : string[2];
 s         : string;
begin
  KeyBuff[BuffPtr] := Msg.KeyCode;
  if BuffPtr = 1 then
    begin
      // Get KeyCode (2 chars) array
      sKeyChar := UpperCase(Copy(KeyBuff,1,2));
      if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
        begin
          sKeyType := KBDef[sKeyChar[1], sKeyChar[2]].KeyType;
          sKeyVal  := KBDef[sKeyChar[1], sKeyChar[2]].KeyVal;
          sPreset  := KBDef[sKeyChar[1], sKeyChar[2]].Preset;
          ProcessKey();
        end;

      KeyBuff := '';
      BuffPtr := 0;
    end
  else
    begin
      s:= UpperCase(KeyBuff[0]);
      if s[1] in ['A'..'N'] then
        Inc(BuffPtr,1) ;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      tfmValidAge.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure tfmValidAge.ProcessKey;

begin

  if sKeyType = 'ENT' then
    begin
      fmValidAge.ModalResult := mrOK;
      nCustBDay := nBeforeDate;
    end
  else if sKeyType = 'CLR' then
      fmValidAge.ModalResult := mrCancel
  else if sKeyType = 'PMP' then   {Pump Number - Process in POSMain}
    begin
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
    end
  else if sKeyType = 'EHL' then   { Emergency Halt }
     fmPOS.ProcessKeyEHL
  else if sKeyType = 'PAT' then   { Authorize }
     fmPOS.ProcessKeyPAT
  else if sKeyType = 'PAL' then   { Auth All }
     fmPOS.ProcessKeyPAL
  else if sKeyType = 'PHL' then   { Pump Halt }
     fmPOS.ProcessKeyPHL
  else
     MessageBeep(1);

end;


{-----------------------------------------------------------------------------
  Name:      TfmValidAge.btnOKClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.btnOKClick(Sender: TObject);
begin
  fmValidAge.ModalResult := mrOK;
  {$IFDEF INSIDE_2D_SCAN}  //20070103a
  nCustBDay := EntDate;
  fmPOS.nCustBDayLog := EntDate;
  {$ELSE}
  nCustBDay := nBeforeDate;
  {$ENDIF}
end;


{-----------------------------------------------------------------------------
  Name:      TfmValidAge.btnEnterBDayClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.btnEnterBDayClick(Sender: TObject);
begin
  fmValidAge.ModalResult := mrRetry;
end;


{-----------------------------------------------------------------------------
  Name:      TfmValidAge.btnNOClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.btnNOClick(Sender: TObject);
begin
  fmValidAge.ModalResult := mrCancel
end;


{-----------------------------------------------------------------------------
  Name:      TfmValidAge.FormActivate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmValidAge.FormActivate(Sender: TObject);
begin
  DecodeDate(Date, Year, Month, Day);
  Year := Year - fmValidAge.AgeRestriction;
  if (Month = 2) and (Day = 29) then
    Day := 28;
  nBeforeDate := EncodeDate(Year, Month,Day);

  {$IFDEF INSIDE_2D_SCAN}  //20070103a
  EntDate := nBeforeDate;
  {$ENDIF}

  case nAgeValidationType of
  VAL_PROMPTDATE :
    begin
      lBeforeDate.Caption := 'Customer Must Be Born On Or Before ' + DateToStr(nBeforeDate);
      btnOK.Caption := 'OK';
      btnEnterBDay.Caption := 'Enter|Birthdate';
      btnEnterBDay.Visible := False;
      btnEnterBDay.Refresh;

    end;
  VAL_DATEOPTION :
    begin
      lBeforeDate.Caption := 'Is the Customer Over ' + IntToStr(AgeRestriction) + '?';
      btnOK.Caption := 'Yes';
      btnEnterBDay.Caption := 'Enter|Birthdate';
      btnEnterBDay.Visible := True;
    end;
  end;

  fmValidAge.refresh;
  try  //20070509a
    fmValidAge.lBeforeDate.SetFocus;    //20070420a
  except
  end;
  KeyBuff := '';
  BuffPtr := 0;

end;


end.

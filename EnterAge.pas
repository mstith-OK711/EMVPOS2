{-----------------------------------------------------------------------------
 Unit Name: EnterAge
 Author:    Gary Whetton
 Date:      4/13/2004 3:19:35 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit EnterAge;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, StdCtrls, POSMain, ExtCtrls, POSBtn, ElastFrm, Mask, MMSystem;

  {$I ConditionalCompileSymbols.txt}

type
  TfmEnterAge = class(TForm)
    lSubtotal: TLabel;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    ElasticForm1: TElasticForm;
    Edit1: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure TestEntry;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    AgeRestriction : integer;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
    procedure ShowKeys(Visibility : boolean);
    procedure FormatEdit1Text;
  end;

var
  fmEnterAge: TfmEnterAge;
  KeyBuff: array[0..200] of Char;


  ListVisible  : Boolean;
  SelectedUserID : String;
  SelectedUser : String;

Keytops  : array[1..12] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT');
POSButtons    : array[1..12] of TPOSTouchButton;

DateEntry, DateDisplay : string;

implementation

Uses
  PosDM, POSLog, Sounds;

{$R *.DFM}
var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.CheckKey(var Msg : TWMPOSKey);
var
 sKeyChar  : string[2];
 s         : String;
begin
  KeyBuff[BuffPtr] := Msg.KeyCode;
  if BuffPtr = 1 then
    begin
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
  Name:      TfmEnterAge.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.ProcessKey;
begin

  if sKeyType = 'NUM' then
    begin
      DateEntry := DateEntry + sKeyVal;
      if fmEnterAge.Active then
        Edit1.Setfocus;
      FormatEdit1Text;
    end
  else if sKeyType = 'CLR' then
    begin
      if DateEntry = '' then
        begin
          ModalResult := mrCancel;
        end
      else
        begin
          DateEntry := '';
          DateDisplay := '';
//          Edit1.SelStart := 0;
//          Edit1.Setfocus;
          FormatEdit1Text;
        end;

    end
  else if sKeyType = 'ENT' then        { process entry }
     TestEntry()
  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL
  else if sKeyType = 'PMP' then        { Pump Number }
    begin
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
    end
  else if sKeyType = 'PAL' then        { Pump Authorize All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.FormShow(Sender: TObject);
begin
  //20071018b...
  fmPOS.PopUpMsgTimer.Enabled := False;
  fmPOS.Timer1.Enabled := False;  //20071019b
  //...20071018b
  if POSButtons[1] = nil then
    BuildTouchPad
  else
    ShowKeys(True);

  DateEntry   := '';
  DateDisplay := '';
//  Edit1.Setfocus;
//  Edit1.SelStart := 0;
  FormatEdit1Text;
  (*{$IFDEF TOC}
  if fmPOS.bPlayWave then PlaySound( 'Birthday', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$else}
  if fmPOS.bPlayWave then PlaySound( 'VALIDATE', HInstance, SND_ASYNC or SND_RESOURCE) ;
  {$ENDif}*)
  if fmPOS.bPlayWave then MakeNoise( ENTERDATESOUND) ;
end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.FormClose(Sender: TObject; var Action: TCloseAction);
var
Year, Month, Day : word;
begin
  //Build 20
  //fmPOS.ClearEntryField;
  //Build 20
  try
    month := strtoint(Copy(DateDisplay,1,2));
    day := strtoint(Copy(DateDisplay,4,2));
    year := strtoint(Copy(DateDisplay,7,4));
    fmPOS.nCustBDayLog := EncodeDate(year,month,day);
  except
  end;
  //20071018b...
  fmPOS.PopUpMsgTimer.Enabled := True;
  fmPOS.Timer1.Enabled := True;  //20071019b
  //...20071018b
  if not fmPOS.Active then
    fmPOS.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.FormatEdit1Text
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.FormatEdit1Text;
var
x, fmtpos : integer;
begin

  DateDisplay := '__/__/19__';
  FmtPos := 0;
  for x := 1 to Length(DateEntry) do
  begin
    Case x of
      1 :  FmtPos := 1;
      2 :  FmtPos := 2;
      3 :  FmtPos := 4;
      4 :  FmtPos := 5;
      5 :  FmtPos := 9;
      6 :  FmtPos := 10;
      (*5 :  FmtPos := 7;
      6 :  FmtPos := 8;
      7 :  FmtPos := 9;
      8 :  FmtPos := 10;*)
      else
        FmtPOS := 0;
    end;
    DateDisplay[FmtPos] := DateEntry[x];
    //if Length(DateEntry) = 6 then
    //  DateEntry := Copy(DateEntry,1,4) + '19' + Copy(DateEntry,5,2);
  end;
  Edit1.Text := DateDisplay;
  Edit1.SelText := DateDisplay;
  if FmtPos = 2 then FmtPos := 3
  //else if FmtPos = 5 then FmtPos := 6;
  else if FmtPos = 5 then FmtPos := 8;
  Edit1.SelStart := FmtPos;



end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.TestEntry
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   Validates the date entry 
-----------------------------------------------------------------------------}
procedure TfmEnterAge.TestEntry();
Var
  Year, Month, Day: word;

begin

  //if Length(DateEntry) = 8 then
  if Length(DateEntry) = 6 then
    begin
      DecodeDate(Date, Year, Month, Day);
      Year := Year - fmEnterAge.AgeRestriction;
      if (Month = 2) and (Day = 29) then
        Day := 28;
      nBeforeDate := EncodeDate(Year, Month,Day);
      try
        Month := StrToInt(Copy(DateEntry, 1, 2));
        Day   := StrToInt(Copy(DateEntry, 3, 2));
        Year  := 1900 + StrToInt(Copy(DateEntry, 5, 2));
      except
        Month := 0;
        Day   := 0;
        Year  := 0;
      end;
      try
        nCustBDay := EncodeDate(Year, Month, Day);
      except
        nCustBDay := 0;
      end;
      if (nCustBDay <> 0) and (nCustBDay <= nBeforeDate) then
        ModalResult := mrOk
      else
        ModalResult := mrCancel;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.ShowKeys
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Visibility : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.ShowKeys(Visibility : boolean);
var
x : integer;
begin

  for x := 1 to 12 do
    if POSButtons[x] <> nil then POSButtons[x].Visible := Visibility;
  fmEnterAge.Refresh;

end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.BuildTouchPad;
var
KeyNo, Row, Col : integer;
begin

  KeyNo := 1;
  for Row := 1 to 4 do
    for Col := 1 to 3 do
      begin
        BuildButton(Row, Col, KeyNo);
        Inc(KeyNo);
      end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmEnterAge.BuildButton(RowNo, ColNo, KeyNo : short );
var
TopKeyPos : short;
KeyColOffset : short;
sBtnColor : string;
nBtnShape, nBtnCOlor : short;
begin
  TopKeyPos := 0;
  KeyColOffset := 0;
 // if KeyNo = 12 then exit;

  case fmPOS.POSScreenSize of
  1 :
    begin
      TopKeyPos := 150;
      KeyColOffset := Trunc((fmEnterAge.Width - (3 * 65)) /2) ;
    end;
  2 :
    begin
      TopKeyPos := 90;
      KeyColOffset := Trunc((fmEnterAge.Width - (3 * 50)) /2) ;
    end;
  end;

  if POSButtons[KeyNo] = nil then
  begin
    POSButtons[KeyNo]             := TPOSTouchButton.Create(Self);
    POSButtons[KeyNo].Parent      := Self;
    POSButtons[KeyNo].Name        := 'User' + IntToStr(RowNo) + IntToStr(ColNo);
  end;

  POSButtons[KeyNo].KeyRow      := RowNo;
  POSButtons[KeyNo].KeyCol      := ColNo;

  case fmPOS.POSScreenSize of
  1 :
    begin
      POSButtons[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 65);
      POSButtons[KeyNo].Left        := ((ColNo - 1) * 65) + KeyColOffset;
      POSButtons[KeyNo].Height      := 60;
      POSButtons[KeyNo].Width       := 60;
      POSButtons[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
    end;
  2 :
    begin
      POSButtons[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 50);
      POSButtons[KeyNo].Left        := ((ColNo - 1) * 50) + KeyColOffset;
      POSButtons[KeyNo].Height      := 47;
      POSButtons[KeyNo].Width       := 47;
      POSButtons[KeyNo].Glyph.LoadFromResourceName(HInstance, 'BTN47');
    end;
  end;

  POSButtons[KeyNo].MaskColor   := fmEnterAge.Color;

  POSButtons[KeyNo].Visible     := True;
  POSButtons[KeyNo].OnClick     := POSButtonClick;
  POSButtons[KeyNo].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[KeyNo].FrameStyle  := bfsNone;
  POSButtons[KeyNo].WordWrap    := True;
  POSButtons[KeyNo].Tag         := KeyNo;
  POSButtons[KeyNo].NumGlyphs   := 14;
  POSButtons[KeyNo].Frame       := 8;
  POSButtons[KeyNo].ShowHint := False;

  POSButtons[KeyNo].Font.Name := 'System';
  POSButtons[KeyNo].Font.Color := clBlack;
  POSButtons[KeyNo].Font.Size := 12;
//  POSButtons[KeyNo].Font.Style := [fsBold]

  if KeyNo = 10 then
    begin
      POSButtons[KeyNo].KeyType := 'CLR - Clear';
      POSButtons[KeyNo].Caption := 'Clear';
      sBtnColor := 'YELLOW';
      nBtnShape := 1;
    end
  else if KeyNo = 12 then
    begin
      POSButtons[KeyNo].KeyType := 'ENT - Enter';
      POSButtons[KeyNo].Caption := 'Enter';
      sBtnColor := 'RED';
      nBtnShape := 1;
    end
  else
    begin
      POSButtons[KeyNo].KeyType := 'NUM';
      POSButtons[KeyNo].Caption := KeyTops[KeyNo];
      POSButtons[KeyNo].KeyVal  := KeyTops[KeyNo];
      sBtnColor := 'WHITE';
      nBtnShape := 2;
    end;
  nBtnColor := 6;
  if sBtnColor = 'BLUE' then
    nBtnColor := 1
  else if sBtnColor = 'GREEN' then
    nBtnColor := 2
  else if sBtnColor = 'RED' then
    nBtnColor := 3
  else if sBtnColor = 'WHITE' then
    nBtnColor := 4
  else if sBtnColor = 'MAGENTA' then
    nBtnColor := 5
  else if sBtnColor = 'CYAN' then
    nBtnColor := 6
  else if sBtnColor = 'YELLOW' then
    nBtnColor := 7 ;

  if nBtnShape = 1 then
    Inc(nBtnColor,7);

  POSButtons[KeyNo].Frame := nBtnColor;

end;


{-----------------------------------------------------------------------------
  Name:      TfmEnterAge.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmEnterAge.POSButtonClick(Sender: TObject);
begin

  if (Sender is TPOSTouchButton) then
    begin
      sKeyType := TPOSTouchButton(Sender).KeyType ;
      sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
      sPreset  := TPOSTouchButton(Sender).KeyPreset ;
      ProcessKey;
    end;

end;



end.

{-----------------------------------------------------------------------------
 Unit Name: Clock
 Author:    Gary Whetton
 Date:      9/11/2003 2:53:33 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit Clock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ElastFrm, POSBtn, Mask, ExtCtrls;

  const
UM_CHECKERRORSCREEN             = WM_USER + 200;

type
  TfmClockInOut = class(TForm)
    ElasticForm1: TElasticForm;
    Label1: TLabel;
    fldUserID: TEdit;
    Label2: TLabel;
    fldPassword: TEdit;
    Panel1: TPanel;
    procedure FormShow(Sender: TObject);
    procedure fldPasswordChange(Sender: TObject);
    procedure fldUserIDChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    //procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure CheckErrorScreen(var Msg: TMessage); message UM_CHECKERRORSCREEN;
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
    procedure ShowKeys(Visibility : boolean);
  end;

var
  fmClockInOut: TfmClockInOut;
  KeyBuff: array[0..200] of Char;


  ListVisible  : Boolean;
  SelectedUserID : String;
  SelectedUser : String;

  Keytops  : array[1..12] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT');
  POSButtons    : array[1..12] of TPOSTouchButton;
  FieldToken : short;

implementation

uses POSErr, POSMain, POSDM;

{$R *.dfm}

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.CheckErrorScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.CheckErrorScreen(var Msg : TMessage);
begin
  if (fmPOSErrorMsg.Visible = True) then
    fmPOSErrorMsg.Visible := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.ProcessKey;
begin
  if sKeyType = 'ENT' then
   Begin
      If FieldToken = 1 then
        begin
          FieldToken := 2;
          fldPassword.Setfocus;
        end
      Else
        fldPasswordChange(Self);
       end
  else if sKeyType = 'NUM' then
    begin
      If Length(fldUserID.Text) < 4 Then
        begin
          fldUserID.SelText := fldUserID.SelText + sKeyVal;
        end
      Else if Length(fldPassword.Text) < 4 Then
        begin
          fldPassword.SelText := fldPassword.SelText + sKeyVal;
        end;

      if (Length(fldUserID.Text) = 4) and (FieldToken = 1) then
        begin
          FieldToken := 2;
          fldPassword.SetFocus;
        end;
    end
  else if sKeyType = 'CLR' then
    Begin
      if FieldToken = 1 then
        fldUserID.Text := ''
      else
        begin
          if Length(fldPassword.Text) > 0 then
            fldPassword.Text := ''
          else
            begin
              FieldToken := 1;
              fldUserID.Setfocus;
            end;

        end;

    End
  else if sKeyType = 'UP ' then
    begin
//      POSDataMod.UserQuery.Prior;
    end
  else if sKeyType = 'DN ' then
    begin
//      POSDataMod.UserQuery.Next;
    end

  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PMP' then        { Pump Number }
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset)
  else if sKeyType = 'PAL' then        { Pump Authorize All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.BuildTouchPad;
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
  Name:      TfmClockInOut.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.BuildButton(RowNo, ColNo, KeyNo : short );
var
TopKeyPos : short;
KeyColOffset : short;
sBtnColor : string;
nBtnShape, nBtnCOlor : short;
begin
  TopKeyPos := 0;
  KeyColOffset := 0;
  if KeyNo = 12 then exit;

  case fmPOS.POSScreenSize of
  1 :
    begin
      TopKeyPos := 250;
      KeyColOffset := Trunc((fmClockInOut.Width - (3 * 65)) /2) ;
    end;
  2 :
    begin
      TopKeyPos := 190;
      KeyColOffset := Trunc((fmClockInOut.Width - (3 * 50)) /2) ;
    end;
  end;

  POSButtons[KeyNo]             := TPOSTouchButton.Create(Self);
  POSButtons[KeyNo].Parent      := Self;
  POSButtons[KeyNo].Name        := 'User' + IntToStr(RowNo) + IntToStr(ColNo);
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

  POSButtons[KeyNo].MaskColor   := fmClockInOut.Color;

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
    //  POSButtons[KeyNo].KeyType := 'ENT - Enter';
    //  POSButtons[KeyNo].Caption := 'Enter';
      POSButtons[KeyNo].Visible := False;
      POSButtons[KeyNo].KeyType := '';
      POSButtons[KeyNo].Caption := '';
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
  Name:      TfmClockInOut.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.POSButtonClick(Sender: TObject);
begin

  if (Sender is TPOSTouchButton) then
    begin
//      if not POSDataMod.TouchTable.Locate('CODE',TPOSTouchButton(Sender).Keycode,SearchOption) then
//        ShowMessage('Record Not Found')
//      else
//        begin
          sKeyType := TPOSTouchButton(Sender).KeyType ;
          sKeyVal  := TPOSTouchButton(Sender).KeyVal ;
          sPreset  := TPOSTouchButton(Sender).KeyPreset ;
          ProcessKey;
//        end;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.FormShow(Sender: TObject);
begin
  if POSButtons[1] = nil then
    BuildTouchPad
  else
    ShowKeys(True);

  fldUserID.Text := '';
  fldPassword.Text := '';
  fldUserID.Setfocus;
  FieldToken := 1;
  fldUserID.SelStart := 0;

  PostMessage(fmClockInOut.Handle, UM_CHECKERRORSCREEN, 0, 0);
end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.fldPasswordChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.fldPasswordChange(Sender: TObject);
Var
  UserFound : boolean;
begin

  UserFound := False;
  If Length(fldPassword.Text) = 4 Then
   Begin
     fldPassword.Refresh;
     ShowKeys(False);


     { We check if the Entry is correct.. }
     if not POSDataMod.IBTransaction.InTransaction then
       POSDataMod.IBTransaction.StartTransaction;
     with POSDataMod.IBTempQuery do
     begin
       Close;SQL.Clear;
       SQL.Add('Select * from Users Where Userid = ''' + Trim(fldUserID.Text) + '''');
       Open;
       If FieldbyName('UserPassword').AsString = fldpassword.Text Then
         UserFound := true;
       close;SQL.Clear;
       if UserFound then
       begin
         SQL.Add('select * from EmpClock where UserID = :pUserID and TimeIn = TimeOut');
         parambyname('pUserID').AsString := fldUserID.Text;
         open;
         if recordcount > 0 then
         begin
           Panel1.Caption := 'Clocking Out';
           Panel1.Refresh;
           close;
           close;SQL.Clear;
           SQL.Add('Update EmpClock set TimeOut = :pTimeOut where UserID = :pUserID ');
           SQL.Add('and TimeIn = TimeOut');
           parambyname('pUserID').AsString := fldUserID.text;
           parambyname('pTimeOut').AsDateTime := now;
           ExecSQL;
         end
         else
         begin
           Panel1.Caption := 'Clocking In';
           Panel1.Refresh;
           close;SQL.Clear;
           SQL.Add('Insert into EmpClock (UserID, TimeIn, TimeOut) ');
           SQL.Add('Values (:pUserId, :pTimeIn, :pTimeOut)');
           parambyname('pUserID').AsString := fldUserID.Text;
           parambyname('pTimeIn').AsDateTime := now;
           parambyname('pTimeOut').AsDateTime := now;
           ExecSQL;
         end;
       end;
     End;
     if POSDataMod.IBTransaction.InTransaction then
       POSDataMod.IBTransaction.Commit;
     close;
   end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.ShowKeys
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Visibility : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.ShowKeys(Visibility : boolean);
var
x : integer;
begin
  for x := 1 to 12 do
    if POSButtons[x] <> nil then POSButtons[x].Visible := true;//Visibility;
  fmClockInOut.Refresh;
end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.fldUserIDChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.fldUserIDChange(Sender: TObject);
begin
  if Length(fldUserID.text) >= 4 then fldPassword.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmClockInOut.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmClockInOut.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  x : byte;
begin
  for x := 1 to 12 do
    POSButtons[x] := nil;
  fmPOS.ClearEntryField;
  fmPOS.SetFocus;
end;

end.

{-----------------------------------------------------------------------------
 Unit Name: PosUser
 Author:    Gary Whetton
 Date:      4/13/2004 4:13:22 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PosUser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, StdCtrls, POSMain, ExtCtrls, POSBtn, ElastFrm, Mask;

const
{$I LatitudeConst.Inc}
  UM_CHECKERRORSCREEN             = WM_USER + 200;

type
  TfmUser = class(TForm)
    lSubtotal: TLabel;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    ElasticForm1: TElasticForm;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Edit2Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure CheckErrorScreen(var Msg: TMessage); message UM_CHECKERRORSCREEN;
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
    procedure ShowKeys(Visibility : boolean);
    procedure CompleteLogon(const bAlreadyLoggedOn        : boolean;
                            const bSupportAlreadyLoggedOn : boolean;
                            const OnTerminal              : Integer);
  end;

var
  fmUser: TfmUser;
  KeyBuff: array[0..200] of Char;


  ListVisible  : Boolean;
  SelectedUserID : String;
  SelectedUser : String;

Keytops  : array[1..12] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT');
POSButtons    : array[1..12] of TPOSTouchButton;
FieldToken : short;

implementation

Uses
  PosDM, POSLog, POSErr, POSMsg, ExceptLog;

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmUser.CheckErrorScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TMessage
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmUser.CheckErrorScreen(var Msg : TMessage);
begin
  if (fmPOSErrorMsg.Visible = True) then
    fmPOSErrorMsg.Visible := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfmUser.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmUser.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.ProcessKey;
begin

//  POSDataMod.UserQuery.SQL.Add('Select * from Users order by userid');
//  POSDataMod.UserQuery.Open;


  if sKeyType = 'ENT' then
   Begin
      If FieldToken = 1 then
        begin
          FieldToken := 2;
          Edit2.Setfocus;
        end
      Else
        Edit2Change(Self);
         (*
      If ListVisible Then
        Begin
          ListVisible  := False;
          fmUser.Width := 471;
          fmUser.Left  := ((GetSystemMetrics(SM_CXSCREEN) - fmUser.Width) div 2);
          Edit1.Text   := POSDataMod.UserQuery.FieldbyName('UserID').AsString;
          Edit2.Text   := '';
        End
       Else
        Begin
          ListVisible := True;
          fmUser.Width := 709;
          fmUser.Left  := ((GetSystemMetrics(SM_CXSCREEN) - fmUser.Width) div 2);
        End;
         *)

   end
  //...53h
  else if sKeyType = 'CAN' then
  begin
    ModalResult := mrCancel;
  end
  //...53h
  else if sKeyType = 'NUM' then
    begin
      If Length(Edit1.Text) < 4 Then
        begin
//          Edit1.Text := Edit1.Text + sKeyVal;
          Edit1.SelText := Edit1.SelText + sKeyVal;
        end
      Else if Length(Edit2.Text) < 4 Then
        begin
//          Edit2.Text := Edit2.Text + sKeyVal;

          Edit2.SelText := Edit2.SelText + sKeyVal;
        end;

      if (Length(Edit1.Text) = 4) and (FieldToken = 1) then
        begin
          FieldToken := 2;
          Edit2.SetFocus;
        end;
    end
  else if sKeyType = 'CLR' then
    Begin
      if FieldToken = 1 then
        Edit1.Text := ''
      else
        begin
          if Length(Edit2.Text) > 0 then
            Edit2.Text := ''
          else
            begin
              FieldToken := 1;
              Edit1.Setfocus;
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
  Name:      TfmUser.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.FormShow(Sender: TObject);
begin

  fmPOS.Timer1.Enabled := False;  //20071018b
  fmPOS.PopUpMsgTimer.Enabled := False;  //20071018b
  Panel1.Caption := 'System Log-On';
  ListVisible  := False;
//  fmUser.Width := 471;
// POSDataMod.UserQuery.SQL.Clear;
// POSDataMod.UserQuery.SQL.Add('Select * from Users order by userid');
// POSDataMod.UserQuery.Open;
  if POSButtons[1] = nil then
    BuildTouchPad
  else
    ShowKeys(True);

  Edit1.Text := '';
  Edit2.Text := '';
  Edit1.Setfocus;
  FieldToken := 1;
  Edit1.SelStart := 0;

  PostMessage(fmUser.Handle, UM_CHECKERRORSCREEN, 0, 0);


end;


{-----------------------------------------------------------------------------
  Name:      TfmUser.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  POSDataMod.IBTempQuery.Close;
  fmPOS.ClearEntryField;
  fmPOS.Timer1.Enabled := True;  //20071018b
  fmPOS.PopUpMsgTimer.Enabled := True;  //20071018b
  fmPOS.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmUser.Edit2Change
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmUser.Edit2Change(Sender: TObject);
Var
  CheckUser : integer;
  x : byte;
begin
  if Edit2.text <> '' then
  try
    strtoint(Edit1.Text);
    strtoint(Edit2.text);
  except
    MessageBeep(1);
    fmPOSMsg.ShowMsg('User ID and Password Must be', 'Numeric');
    for x := 1 to 100 do
    begin
      sleep(20);
      Application.Processmessages;
    end;
    fmPOSMsg.Close;
    Panel1.Caption := 'System Log-On';
    Edit1.text := '';
    Edit2.Text := '';
    Edit1.SetFocus;
    FieldToken := 1;
    ShowKeys(True);
    exit;
  end;
  If Length(Edit2.Text) = 4 Then
  Begin
    Panel1.Caption := 'Logging On';
    Panel1.Refresh;
    Edit2.Refresh;
    ShowKeys(False);
    CheckUser  := StrToInt(Edit1.Text);
    fmPOS.QueryLoggedOnInfo(LU_RET_LOGON, CheckUser);
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmUser.ShowKeys
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Visibility : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.ShowKeys(Visibility : boolean);
var
x : integer;
begin
  //53h...
//  for x := 1 to 12 do
//    if POSButtons[x] <> nil then POSButtons[x].Visible := Visibility;
  for x := 1 to 11 do
    if POSButtons[x] <> nil then POSButtons[x].Visible := Visibility;
  if POSButtons[12] <> nil then POSButtons[12].Visible := Visibility and bTempLogon;  // Cancel key
  //...53h
  fmUser.Refresh;
end;


{-----------------------------------------------------------------------------
  Name:      TfmUser.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.BuildTouchPad;
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
  Name:      TfmUser.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.BuildButton(RowNo, ColNo, KeyNo : short );
var
TopKeyPos : short;
KeyColOffset : short;
sBtnColor : string;
nBtnShape, nBtnCOlor : short;
begin
  TopKeyPos := 0;
  KeyColOffset := 0;
  //53h...
//  if KeyNo = 12 then exit;
  //...53h

  case fmPOS.POSScreenSize of
  1 :
    begin
      TopKeyPos := 250;
      KeyColOffset := Trunc((fmUser.Width - (3 * 65)) /2) ;
    end;
  2 :
    begin
      TopKeyPos := 200;
      KeyColOffset := Trunc((fmUser.Width - (3 * 50)) /2) ;
    end;
  4 :
    begin
      TopKeyPos := 350;
      KeyColOffset := Trunc((fmUser.Width - (3 * 80)) /2) ;
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
  4 :
    begin
      POSButtons[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 80);
      POSButtons[KeyNo].Left        := ((ColNo - 1) * 80) + KeyColOffset;
      POSButtons[KeyNo].Height      := 60;
      POSButtons[KeyNo].Width       := 60;
      POSButtons[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
    end;
  end;

  POSButtons[KeyNo].MaskColor   := fmUser.Color;

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
      //53h...
//      POSButtons[KeyNo].KeyType := '';
//      POSButtons[KeyNo].Caption := '';
      POSButtons[KeyNo].KeyType := 'CAN - Cancel';
      POSButtons[KeyNo].Caption := 'Cancel';
      //...53h
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
  Name:      TfmUser.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.POSButtonClick(Sender: TObject);
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
  Name:      TfmUser.Edit1Change
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmUser.Edit1Change(Sender: TObject);
var
  x : byte;
begin
  if Edit1.text <> '' then
  try
    strtoint(Edit1.Text);
  except
    MessageBeep(1);
    fmPOSMsg.ShowMsg('User ID and Password Must be', 'Numeric');
    for x := 1 to 100 do
    begin
      sleep(20);
      Application.Processmessages;
    end;
    fmPOSMsg.Close;
    Panel1.Caption := 'System Log-On';
    Edit1.text := '';
    Edit2.Text := '';
    Edit1.SetFocus;
    FieldToken := 1;
    ShowKeys(True);
    exit;
  end;
  if Length(Edit1.text) >= 4 then Edit2.SetFocus;
end;

procedure TfmUser.CompleteLogon(const bAlreadyLoggedOn        : boolean;
                                const bSupportAlreadyLoggedOn : boolean;
                                const OnTerminal              : Integer);
var
  Temp : String;
begin
  if bAlreadyLoggedOn then
  begin
    MessageBeep(1);
    if OnTerminal = 99 then
      fmPos.POSError('Please Wait... Closing In Progress' )
    else
      fmPOS.POSError('User Already Signed-On Terminal# ' + IntToStr(OnTerminal) );
    Panel1.Caption := 'System Log-On';
    Edit1.Text := '';
    Edit2.Text := '';
    Edit1.Setfocus;
    FieldToken := 1;
    ShowKeys(True);
    exit;
  end;

  if not POSDataMod.IBDB.TestConnected then
  begin
    fmPOS.OpenTables(False);
  end;

  { We check if the Entry is correct.. }
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  try
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from Users Where Userid = :puid');
      ParamByName('puid').asstring := Trim(Edit1.Text);
      Open;
      If FieldbyName('UserPassword').AsString = Edit2.Text Then
      Begin
        { If it is correct we close the window }
        SelectedUserID := FieldbyName('UserID').AsString;
        SelectedUser := FieldbyName('UserName').AsString;
        ModalResult := mrOk;
      End
      Else
      Begin
        { It might also be a Support Entry code : Username = MMDD, Password = Username reversed }
        Temp := FormatDateTime('MMDD',Now);
        If Edit1.Text = Temp Then
        Begin
          If (Edit2.Text[1] = Edit1.Text[4]) and (Edit2.Text[2] = Edit1.Text[3]) and
             (Edit2.Text[3] = Edit1.Text[2]) and (Edit2.Text[4] = Edit1.Text[1]) Then
          Begin
            { If it is correct we close the window }
            if bSupportAlreadyLoggedOn then
            begin
              if OnTerminal = 99 then
                fmPOS.POSError('Please Wait... Closing In Progress' )
              else
                fmPOS.POSError('User Already Signed-On Terminal# ' + IntToStr(OnTerminal) );
              Panel1.Caption := 'System Log-On';
              Edit1.Text := '';
              Edit2.Text := '';
              Edit1.Setfocus;
              FieldToken := 1;
              ShowKeys(True);
              exit;
            end
            else
            //...20070925b
            begin
              SelectedUserID := 'XXXX';
              SelectedUser := 'Support';
              ModalResult := mrOk;
            end;
          End
          Else
          Begin
            fmPOS.POSError('Incorrect User ID/Password entered');
            MessageBeep(1);
            Panel1.Caption := 'System Log-On';
            Edit1.Text := '';
            Edit2.Text := '';
            Edit1.Setfocus;
            FieldToken := 1;
            ShowKeys(True);
          End;
        End
        Else
        Begin
          fmPOS.POSError('Incorrect User ID/Password entered');
          MessageBeep(1);
          Panel1.Caption := 'System Log-On';
          Edit1.Text := '';
          Edit2.Text := '';
          Edit1.Setfocus;
          FieldToken := 1;
          ShowKeys(True);
        End;
      End;
      close;
    End;
  except
    on E: Exception do begin
      fmPOS.POSError('Exception caught');
      Panel1.Caption := 'System Log-On';
      Edit1.Text := '';
      Edit2.Text := '';
      Edit1.SetFocus;
      FieldToken := 1;
      ShowKeys(True);
      UpdateExceptLog('Logon Failed ' + E.Message);
      UpdateZLog('Logon Failed %s', [E.Message]);
      DumpTraceback(E);
    end;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;

end.

{-----------------------------------------------------------------------------
 Unit Name: FuelPric
 Author:    Gary Whetton
 Date:      9/11/2003 2:59:39 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit FuelPric;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  POSMain, Grids, DBGrids, StdCtrls, Mask, MaskUtils, DBCtrls, ExtCtrls, POSBtn;

type
  TfmChangeFuelPrice = class(TForm)
    Label1: TLabel;
    eCashPrice: TMaskEdit;
    pnlGradeName: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure ProcessKey;
    procedure POSButtonClick(Sender: TObject);
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure RefreshFields;
    procedure NextPrice;
    procedure BuildTouchPad;
    procedure BuildButton(RowNo, ColNo, KeyNo : short );
  end;

var
  fmChangeFuelPrice: TfmChangeFuelPrice;
  KeyBuff: array[0..200] of Char;


  CurField: Integer;
  Keytops  : array[1..12] of string = ('7', '8', '9', '4', '5', '6', '1', '2', '3', 'CLR', '0', 'ENT');
  POSButtons    : array[1..12] of TPOSTouchButton;



Const
  BuffPtr  :  short = 0;

implementation
uses POSDM, POSLog, ExceptLog, StrUtils;

{$R *.DFM}

const
  EM_THOUSANDTHS = '0.000;1;0';
  EM_HUNDREDTHS = '0.00X;1;0';

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmChangeFuelPrice.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmChangeFuelPrice.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.ProcessKey;
begin

  if sKeyType = 'ENT' then
    begin
      NextPrice;
    end
  else if sKeyType = 'CLR' then
//   fmChangeFuelPrice.Close
    begin
      RefreshFields;
      eCashPrice.SetFocus;
      eCashPrice.SelectAll;
    end

  else if sKeyType = 'ERC' then
    begin
      PostMessage(ActiveControl.Handle, WM_KEYDOWN, VK_BACK, 0);
    end

  else if sKeyType = 'NUM' then
    begin
      PostMessage(ActiveControl.Handle, WM_CHAR, vkKeyScan(sKeyVal[1]),0);
    end

// --- Pass Through Keys --------
  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PMP' then        { Pump Number }
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset)

  else if sKeyType = 'PAT' then   {Pump Authorize}
     fmPOS.ProcessKeyPAT

  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmChangeFuelPrice.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.FormShow(Sender: TObject);
begin
  if not POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
    POSDataMod.IBFuelPriceChangeTransaction.StartTransaction;
  with POSDataMod.IBFuelPriceChangeQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Delete from FuelPriceChange');
    ExecSQL;
  end;
  if POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
    POSDataMod.IBFuelPriceChangeTransaction.Commit;
  if not POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
    POSDataMod.IBFuelPriceChangeTransaction.StartTransaction;
  with POSDataMod.IBFuelPriceChangeQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select GradeNo, Name, CashPrice, thousandthsdigit From Grade where enabled=1 Order By GradeNo');
    Open;
  end;
  if POSButtons[1] = nil then
    BuildTouchPad;
  RefreshFields;
  eCashPrice.SetFocus;
  eCashPrice.SelectAll;
end;


{-----------------------------------------------------------------------------
  Name:      TfmChangeFuelPrice.RefreshFields
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.RefreshFields;
var
  cp : string;
begin
  with POSDataMod.IBFuelPriceChangeQuery do
    begin
      pnlGradeName.Caption   := FieldByName('Name').AsString;
      cp := FormatFloat('0.000', FieldByName('CashPrice').AsCurrency);
      if FieldByName('thousandthsdigit').IsNull then
        eCashPrice.EditMask := EM_THOUSANDTHS
      else
      begin
        cp := LeftStr(cp, 4);   //  Trim third digit if we've got a custom EditMask for forcing the last digit
        eCashPrice.EditMask := EM_HUNDREDTHS;  // force mask to three decimals to permit data to go in cleanly
      end;
      eCashPrice.Text        := cp;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmChangeFuelPrice.NextPrice
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.NextPrice;
var
RepeatCount : integer;
begin

  // Save Changes
  with POSDataMod.IBFuelPriceUpdateSQL do
    begin
      RepeatCount := 0;
      while True do
        begin
          try
            POSDataMod.IBFuelPriceUpdateTransaction.StartTransaction;
            Close;SQL.Clear;
            SQL.Add('Insert into FuelPriceChange (CashPrice, GradeNo) ');
            SQL.Add('Values (:pCashPrice, :pGradeNo)');
            if POSDataMod.IBFuelPriceChangeQuery.FieldByName('ThousandthsDigit').IsNull then
              ParamByName('pCashPrice').AsCurrency  := StrToCurr(eCashPrice.EditText)
            else
              ParamByName('pCashPrice').AsCurrency  := StrToCurr(stringreplace(eCashPrice.EditText, 'X', IntToStr(POSDataMod.IBFuelPriceChangeQuery.FieldByName('ThousandthsDigit').AsInteger), []));
            ParamByName('pGradeNo').AsInteger     := POSDataMod.IBFuelPriceChangeQuery.FieldByName('GradeNo').AsInteger;
            ExecQuery;
            POSDataMod.IBFuelPriceUpdateTransaction.Commit;
            break;
          except
            on E : Exception do
              begin
                UpdateExceptLog( 'Rollback Change Fuel Price ' + IntToStr(RepeatCount) + ' ' + e.message );
                if POSDataMod.IBFuelPriceUpdateTransaction.InTransaction then
                  POSDataMod.IBFuelPriceUpdateTransaction.Rollback;
                sleep(100);
                Inc(RepeatCount);
                if RepeatCount > 100 then
                  begin
                    // need to log that this happened
                    break;
                  end;
              end;
          end;
        end;
    end;

  // Move to Next Record
  POSDataMod.IBFuelPriceChangeQuery.Next;
  if POSDataMod.IBFuelPriceChangeQuery.EOF then
    begin
      POSDataMod.IBFuelPriceChangeQuery.Close;
      Self.ModalResult := mrOK;
      if POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
        POSDataMod.IBFuelPriceChangeTransaction.Commit;
    end
  else
    begin
      RefreshFields;
      eCashPrice.SetFocus;
      eCashPrice.SelectAll;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmChangeFuelPrice.BuildTouchPad
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.BuildTouchPad;
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
  Name:      TfmChangeFuelPrice.BuildButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, KeyNo : short
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.BuildButton(RowNo, ColNo, KeyNo : short );
var
TopKeyPos : short;
KeyColOffset : short;
sBtnColor : string;
nBtnShape, nBtnCOlor : short;
begin

  TopKeyPos := 110;

  KeyColOffset := Trunc((fmChangeFuelPrice.Width - (3 * 65)) /2) ;


  POSButtons[KeyNo]             := TPOSTouchButton.Create(Self);
  POSButtons[KeyNo].Parent      := Self;
  POSButtons[KeyNo].Name        := 'User' + IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[KeyNo].Top         := TopKeyPos + ((RowNo - 1) * 65);
  POSButtons[KeyNo].Left        := ((ColNo - 1) * 65) + KeyColOffset;
  POSButtons[KeyNo].KeyRow      := RowNo;
  POSButtons[KeyNo].KeyCol      := ColNo;
  POSButtons[KeyNo].Height      := 60;
  POSButtons[KeyNo].Width       := 60;
  POSButtons[KeyNo].Visible     := True;
  POSButtons[KeyNo].OnClick     := POSButtonClick;
  POSButtons[KeyNo].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[KeyNo].FrameStyle  := bfsNone;
  POSButtons[KeyNo].WordWrap    := True;
  POSButtons[KeyNo].Tag         := KeyNo;
  POSButtons[KeyNo].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
  POSButtons[KeyNo].NumGlyphs   := 14;
  POSButtons[KeyNo].Frame       := 8;
  POSButtons[KeyNo].ShowHint := False;
  POSButtons[KeyNo].MaskColor := fmChangeFuelPrice.Color;

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
  Name:      TfmChangeFuelPrice.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmChangeFuelPrice.POSButtonClick(Sender: TObject);
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

procedure TfmChangeFuelPrice.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F4) and (ssAlt in Shift) then
  begin
    UpdateZLog('%s: User pressed Alt-F4 - Blocked', [Self.Classname]);
    fmPOS.POSError('Invalid keypress - Call Support');
    Key := 0;
  end;
  if (Key = VK_F7) and (ssAlt in Shift) then
  begin
    UpdateZLog('%s: User pressed Alt-F7 - Closing', [Self.ClassName]);
    Self.modalresult := mrCancel;
  end;

end;

end.

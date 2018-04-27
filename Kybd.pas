unit Kybd;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, DBTables, Buttons, ExtCtrls;

type
  TfmKybdSetup = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure NameTheKey;
  public
    { Public declarations }
    procedure SetupKybd;
    procedure RemoveKybd;
    procedure ProcessKeyPress(Sender: TObject);
  end;

var
  fmKybdSetup: TfmKybdSetup;
  Instance:array[1..112] of TPanel;
  KeyBuff: array[0..200] of Char;
  BuffPtr: short;
  SearchOption: TLocateOptions;
  InstanceNo: Integer;

implementation

uses POSDM, POSMain, POSErr, FuelSel, MenuForm, PluRpt, GetAge,
  CCRecpt, FuelRcpt, FuelPric, PumpOnOf, ADSCC;

{$R *.DFM}

procedure TfmKybdSetup.SetupKybd;

var
  Row, Column: Integer;
  ColumnLetter:Char;
  Left, Top: Integer;

begin

  InstanceNo := 1;
  Top := 10;
  for Row := 1 to 8 do
    begin
      Left:= 10;
      for ColumnLetter := 'A' to 'N' do
      begin
        Instance[InstanceNo] := TPanel.Create(Self);
        Instance[InstanceNo].Parent := Self;
        Instance[InstanceNo].Left := Left;
        Instance[InstanceNo].Top := Top;
        Instance[InstanceNo].Height := 29;
        Instance[InstanceNo].Width := 54;
        Instance[InstanceNo].Name := ColumnLetter + IntToStr(Row);
        Instance[InstanceNo].BorderStyle := bsSingle;
        Instance[InstanceNo].BevelWidth  := 1;
        Instance[InstanceNo].OnClick     := ProcessKeyPress;
        Instance[InstanceNo].Tag         := InstanceNo;
        Instance[InstanceNo].Font.Name   := 'Arial';
        Instance[InstanceNo].Font.Size   := 7;

        POSDataMod.KybdTable.Locate('CODE',(ColumnLetter + IntToStr(Row)),SearchOption);
        Instance[InstanceNo].Hint := POSDataMod.KybdTable.FieldByName('TYPE').AsString;
        NameTheKey;
        Instance[InstanceNo].ShowHint := True;

        Inc(Left,55);
        Inc(InstanceNo);
      end;
      Inc(Top,30);
    end;

  KeyBuff := ' ';
  BuffPtr := 0;

  { Yellow Keys : }

  for Row := 1 to 3 do
      for Column := 7 to 14 do
         Instance[((Row - 1) * 14) + Column].Color   := clYellow;

  { Blue Keys : }

  for Row := 2 to 8 do
      for Column := 1 to 3 do
       begin
         Instance[((Row - 1) * 14) + Column].Color   := clBlue;
         Instance[((Row - 1) * 14) + Column].Font.Color := clWhite;
       End;

  { White Keys : }

  for Row := 4 to 8 do
      for Column := 4 to 7 do
         Instance[((Row - 1) * 14) + Column].Color   := clWhite;

  { Green Keys : }

  for Row := 8 to 8 do
      for Column := 10 to 14 do
         Instance[((Row - 1) * 14) + Column].Color   := clGreen;

  for Row := 6 to 8 do
      for Column := 13 to 14 do
         Instance[((Row - 1) * 14) + Column].Color   := clGreen;

  { Red Keys : }

  for Row := 1 to 1 do
      for Column := 1 to 2 do
         Instance[((Row - 1) * 14) + Column].Color   := clRed;

  for Row := 4 to 5 do
      for Column := 8 to 8 do
         Instance[((Row - 1) * 14) + Column].Color   := clRed;

  for Row := 4 to 5 do
      for Column := 14 to 14 do
         Instance[((Row - 1) * 14) + Column].Color   := clRed;

  { Olive Keys : }

  for Row := 2 to 3 do
      for Column := 4 to 5 do
         Instance[((Row - 1) * 14) + Column].Color   := clOlive;


end;


procedure TfmKybdSetup.RemoveKybd;
var
  Row: Integer;
  ColumnLetter:Char;
begin

  InstanceNo := 1;
  for Row := 1 to 8 do
    for ColumnLetter := 'A' to 'N' do
      begin
        Instance[InstanceNo].Free;
        Inc(InstanceNo);
      end;
End;

procedure TfmKybdSetup.NameTheKey;
var
  sKeyType: string[3];
begin

  sKeyType := Copy((POSDataMod.KybdTable.FieldByName('TYPE').AsString),1,3);
  if sKeyType = 'NUM' then
    begin
      Instance[InstanceNo].Caption := POSDataMod.KybdTable.FieldByName('KEYVAL').AsString;
      Instance[InstanceNo].Hint := Instance[InstanceNo].Hint + ' ' +  POSDataMod.KybdTable.FieldByName('KEYVAL').AsString;
    end
  else if sKeyType = 'PMP' then
    begin
      Instance[InstanceNo].Caption := 'Pump# ' + POSDataMod.KybdTable.FieldByName('KEYVAL').AsString;
      Instance[InstanceNo].Hint := Instance[InstanceNo].Hint + ' ' +  POSDataMod.KybdTable.FieldByName('KEYVAL').AsString;
    end
  else if sKeyType = 'MED' then
    begin
      if POSDataMod.KybdTable.FieldByName('PRESET').AsString = '' then
        begin
          POSDataMod.MediaTable.Locate('MediaNo',POSDataMod.KybdTable.FieldByName('KEYVAL').AsString,SearchOption);
          Instance[InstanceNo].Caption := POSDataMod.MediaTable.FieldByName('NAME').AsString;
          Instance[InstanceNo].Hint := Instance[InstanceNo].Hint + ' ' + POSDataMod.MediaTable.FieldByName('NAME').AsString;
        end
      else
        begin
          Instance[InstanceNo].Caption := '$' + FloatToStr(StrToInt(POSDataMod.KybdTable.FieldByName('PRESET').AsString) / 100);
          Instance[InstanceNo].Hint := Instance[InstanceNo].Hint + ' ' + Instance[InstanceNo].Caption
                                                + POSDataMod.MediaTable.FieldByName('NAME').AsString;
        end;
    end
  else if sKeyType = 'PLU' then
    begin
      if POSDataMod.KybdTable.FieldByName('PRESET').AsString = '' then
        Instance[InstanceNo].Caption := 'PLU'
      else
        begin
          POSDataMod.PLUTable.Locate('PluNo',POSDataMod.KybdTable.FieldByName('KEYVAL').AsString,SearchOption);
          Instance[InstanceNo].Caption := POSDataMod.PLUTable.FieldByName('NAME').AsString;
          Instance[InstanceNo].Hint := Instance[InstanceNo].Hint +  ' ' +
                                       POSDataMod.PLUTable.FieldByName('NAME').AsString + ' ' +
                                       POSDataMod.PLUTable.FieldByName('NAME').AsString;
        end;
    end
  else if sKeyType = 'DPT' then
    begin
      POSDataMod.DeptTable.Locate('DeptNo',POSDataMod.KybdTable.FieldByName('KEYVAL').AsString,SearchOption);
      Instance[InstanceNo].Caption := POSDataMod.DeptTable.FieldByName('NAME').AsString;
      Instance[InstanceNo].Hint := Instance[InstanceNo].Hint +  ' ' +
                                   POSDataMod.DeptTable.FieldByName('DeptNo').AsString + ' ' +
                                   POSDataMod.DeptTable.FieldByName('NAME').AsString;
      if POSDataMod.KybdTable.FieldByName('PRESET').AsString > '' then
        Instance[InstanceNo].Hint := Instance[InstanceNo].Hint +  ' ' +
                     FormatFloat('###.00',(StrToInt(POSDataMod.KybdTable.FieldByName('PRESET').AsString) / 100));
    end
  else if sKeyType = 'BNK' then
    begin
      POSDataMod.BankFuncTable.Locate('BankNo',POSDataMod.KybdTable.FieldByName('KEYVAL').AsString,SearchOption);
      Instance[InstanceNo].Caption := POSDataMod.BankFuncTable.FieldByName('NAME').AsString;
      Instance[InstanceNo].Hint := Instance[InstanceNo].Hint +  ' ' +
                                   POSDataMod.BankFuncTable.FieldByName('BankNo').AsString + ' ' +
                                   POSDataMod.BankFuncTable.FieldByName('NAME').AsString;
    end
  else if sKeyType = 'MNU' then
    begin
      POSDataMod.MenuTable.Locate('MenuNo', POSDataMod.KybdTable.FieldByName('KEYVAL').AsString ,SearchOption);
      Instance[InstanceNo].Caption := copy(POSDataMod.KybdTable.FieldByName('TYPE').AsString,6,10);
      Instance[InstanceNo].Hint := Instance[InstanceNo].Hint +  ' ' +
                                   POSDataMod.MenuTable.FieldByName('Name').AsString ;
    end
  else
    Instance[InstanceNo].Caption := copy(POSDataMod.KybdTable.FieldByName('TYPE').AsString,6,10);

end;

procedure TfmKybdSetup.ProcessKeyPress (Sender: TObject);
Var
  B    : TPanel;
  x,y  : Integer;
  s    : String;
Begin

 If Sender is TPanel Then
   Begin
     { First we evaluate the Keyboard Position from the Tag Value (Position on Keyboard) }

     B := TPanel(Sender);

     x := B.Tag mod 14;
     if x = 0 Then x := 14;

     y := ((B.Tag-1) div 14) + 1;
     S := IntToStr(y);

     if fmPOSErrorMsg.Visible = True then
       begin
         PostMessage(fmPOSErrorMsg.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmPOSErrorMsg.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmFuelSelect.Visible = True then
       begin
         PostMessage(fmFuelSelect.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmFuelSelect.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
      else if fmMenuForm.Visible = True then
       begin
         PostMessage(fmMenuForm.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmMenuForm.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmPLUSalesReport.Visible = True then
       begin
         PostMessage(fmPLUSalesReport.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmPLUSalesReport.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmValidAge.Visible = True then
       begin
         PostMessage(fmValidAge.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmValidAge.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmADSCCForm.Visible = True then
       begin
         PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmADSCCForm.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmCardReceipt.Visible = True then
       begin
         PostMessage(fmCardReceipt.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmCardReceipt.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmFuelReceipt.Visible = True then
       begin
         PostMessage(fmFuelReceipt.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmFuelReceipt.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmChangeFuelPrice.Visible = True then
       begin
         PostMessage(fmChangeFuelPrice.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmChangeFuelPrice.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else if fmPumpOnOff.Visible = True then
       begin
         PostMessage(fmPumpOnOff.Handle, WM_CHECKKEY, LongInt(Chr(x + 64)), 0);
         PostMessage(fmPumpOnOff.Handle, WM_CHECKKEY, LongInt(S[1]), 0);
       end
     else
       begin
          { POSMain is active... }
         POSMain.EntryBuff[0] := Chr(x + 64);
         POSMain.EntryBuff[1] := S[1];
         PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
       end;

   End;

End;

procedure TfmKybdSetup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    RemoveKybd;
end;

end.

unit MenuForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB,
  StdCtrls, POSMain, ExtCtrls;

type
  TfmMenuForm = class(TForm)
    ListBox1: TListBox;
    label1: TPanel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    MenuNo : short;
    ItemSelected : boolean;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure ProcessKey;
  end;

var
  fmMenuForm: TfmMenuForm;
  KeyBuff: array[0..200] of Char;
  BuffPtr: short;
  SearchOption : TLocateOptions;

  // Keyboard Handling (MenuForm)
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

implementation

uses POSDM, POSLog;

{$R *.DFM}

procedure TfmMenuForm.CheckKey(var Msg : TWMPosKey);
var
 sKeyChar  : string[2];
begin

  KeyBuff[BuffPtr] := Msg.KeyCode;
  If Error_SkipKey Then
   Begin
     Error_SkipKey := False;
     KeyBuff := '';
     BuffPtr := 0;
     Exit;
   End;

  if BuffPtr = 1 then
    begin
      // Get KeyCode (2 chars) array
      sKeyChar := UpperCase(Copy(KeyBuff,1,2));
      if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
        begin
          sKeyType := KBDef[sKeyChar[1], sKeyChar[2]].KeyType;
          sKeyVal  := KBDef[sKeyChar[1], sKeyChar[2]].KeyVal;
          sPreset  := KBDef[sKeyChar[1], sKeyChar[2]].Preset;

          // Write to Keys.Log
          LogKeys('MenuForm - ' + sKeyChar, sKeyType, sKeyval, sPreset);

          ProcessKey();
        end
      else
        begin
          Error_SkipKey := True;
        end;

      KeyBuff := '';
      BuffPtr := 0;
    end
  else
     Inc(BuffPtr,1) ;


end;

procedure TfmMenuForm.ProcessKey;
var
  Ndx : short;
begin

  if sKeyType = 'CLR' then
    close

  else if (sKeyType = 'NUM') or (sKeyType = 'ENT') then
    begin
      if sKeyType = 'NUM' then
        begin
          try
            Ndx := StrToInt(sKeyVal);
            if Ndx = 0 then
              Ndx := 10;
          except
             Ndx := 0;
          end;
        end
      else
        Ndx := ListBox1.ItemIndex + 1;
      if Ndx > 0 then
        begin
          ListBox1.ItemIndex := Ndx - 1 ;
          ListBox1.Refresh;
          fmPOS.sKeyType := Copy(POSDataMod.MenuTable.FieldByName('TYPE' + IntToStr(Ndx)).AsString,1,3);
          fmPOS.sKeyVal := POSDataMod.MenuTable.FieldByName('KEYVAL' + IntToStr(Ndx)).AsString;
          fmPOS.sPreset := POSDataMod.MenuTable.FieldByName('PRESET' + IntToStr(Ndx)).AsString;
          ItemSelected := True;
        end;
      close;
    end

  else if sKeyType = 'PMP' then   {Pump Number}
    begin
      fmPOS.sKeyType := sKeyType;
      fmPOS.sKeyVal  := sKeyVal;
      fmPOS.sPreset  := sPreset;
      fmPOS.ProcessKeyPMP;
    end

  else if (sKeyType = 'UP ') and (ListBox1.ItemIndex > 0) then
    ListBox1.ItemIndex := ListBox1.ItemIndex - 1

  else if (sKeyType = 'DN ') and (ListBox1.ItemIndex < ListBox1.Items.Count-1) then
    ListBox1.ItemIndex := ListBox1.ItemIndex + 1

  else if sKeyType = 'PAT' then   {Pump Authorize}
     fmPOS.ProcessKeyPAT

  else if sKeyType = 'PAL' then   {Pump Authorize All}
     fmPOS.ProcessKeyPAL

  else if sKeyType = 'EHL' then   { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PHL' then   { Pump Halt }
     fmPOS.ProcessKeyPHL;

end;

procedure TfmMenuForm.FormShow(Sender: TObject);
var
x : short;
ListRec : string;
sKeyType : string;
TypeName, KeyValName, PresetName : string;
begin

  if POSDataMod.MenuTable.Locate('MenuNo', MenuNo, SearchOption) then
    begin
      Label1.Caption := POSDataMod.MenuTable.FieldByName('Name').AsString;
      ListBox1.Items.Clear;
      for x := 1 to 10 do
        begin
          if x < 10 then
            ListRec := IntToStr(x)
          else
            ListRec := IntToStr(0);

          TypeName := 'Type' + IntToStr(x);
          KeyValName := 'KeyVal' + IntToStr(x);
          PresetName := 'Preset' + IntToStr(x);
          sKeyType := Copy(POSDataMod.MenuTable.FieldByName(TypeName).AsString,1,3);
          if sKeyType = 'PPL' then
            begin
              if POSDataMod.PLUTable.Locate('PluNo', POSDataMod.MenuTable.FieldByName(KeyValName).Value, SearchOption) then
                 ListRec := ListRec + ' ' +
                 Format('%-22s',[POSDataMod.PLUTable.FieldByName('Name').AsString]) +
                 Format('%6s',[( FormatFloat ( '##0.00', POSDataMod.PLUTable.FieldByName('Price').AsCurrency ))]);
            end
          else if sKeyType = 'MNU' then
            begin
              if POSDataMod.MenuLookUpTable.Locate('MenuNo', POSDataMod.MenuTable.FieldByName(KeyValName).Value, SearchOption) then
                 ListRec := ListRec + ' ' + POSDataMod.MenuLookUpTable.FieldByName('Name').AsString;
            end
          else if sKeyType = 'BNK' then
            begin
              if POSDataMod.BankFuncTable.Locate('BankNo', POSDataMod.MenuTable.FieldByName(KeyValName).Value, SearchOption) then
                 ListRec := ListRec + ' ' + POSDataMod.BankFuncTable.FieldByName('Name').AsString;
            end
          else if sKeyType = 'DPT' then
            begin
              if POSDataMod.DeptTable.Locate('DeptNo', POSDataMod.MenuTable.FieldByName(KeyValName).Value, SearchOption) then
                 ListRec := ListRec + ' ' + POSDataMod.DeptTable.FieldByName('Name').AsString;
            end
          else if Trim(sKeyType) <> '' then
            ListRec := ListRec + ' ' + Copy(POSDataMod.MenuTable.FieldByName(TypeName).AsString,7,23)  {CAP}
          else
            ListRec := '';
          ListBox1.Items.Add(ListRec);
        end;
    end;
  ListBox1.ItemIndex := 0;

end;

end.

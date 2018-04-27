unit Touchkey;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, DB, Mask, DBCtrls, Menus, Dialogs, Grids, DBGrids;

type
  TfmDefineKey = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    DBEditValue: TDBEdit;
    DBComboType: TDBComboBox;
    Label1: TLabel;
    lNumber: TLabel;
    Label2: TLabel;
    DBEditKeyPos: TDBEdit;
    lPreset: TLabel;
    DBEditPreset: TDBEdit;
    DBLookupDept: TDBLookupComboBox;
    DBLookupPLU: TDBLookupComboBox;
    DBLookupMedia: TDBLookupComboBox;
    DBLookupMenu: TDBLookupComboBox;
    ClearBtn: TBitBtn;
    DBLookupBankFunc: TDBLookupComboBox;
    Label3: TLabel;
    DBComboColor: TDBComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    DBCheckBox1: TDBCheckBox;
    DBRadioGroup: TDBRadioGroup;
    DBComboBoxFont: TDBComboBox;
    DBComboBoxFontColor: TDBComboBox;
    DBEdit1: TDBEdit;
    procedure CancelEdit(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBComboTypeChange(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
  private
    procedure SetupFields;
    { Private declarations }
  public
    { Public declarations }
  end;

//var
//  fmDefineKey: TfmDefineKey;

implementation

uses POSDM;

//uses POSDM;

{$R *.DFM}

procedure TfmDefineKey.CancelEdit(Sender: TObject);
begin
  POSDataMod.TouchKybdTable.Cancel;
end;

procedure TfmDefineKey.OKBtnClick(Sender: TObject);
begin
  try
    POSDataMod.TouchKybdTable.Post;
    Close;
  except
    raise;
  end;
end;


procedure TfmDefineKey.ClearBtnClick(Sender: TObject);
begin

  POSDataMod.TouchKybdTable.FieldByName('TYPE').Value   := ' ';
  POSDataMod.TouchKybdTable.FieldByName('KEYVAL').Value := ' ';
  POSDataMod.TouchKybdTable.FieldByName('PRESET').Value := ' ';
  POSDataMod.TouchKybdTable.Post;
  Close;
end;


procedure TfmDefineKey.FormShow(Sender: TObject);
begin

  DBComboBoxFont.Items := Screen.Fonts;

  POSDataMod.TouchKybdTable.Edit;
  SetupFields;
  DBComboType.Setfocus;
end;

procedure TfmDefineKey.DBComboTypeChange(Sender: TObject);
begin
  SetupFields;
end;

procedure TfmDefineKey.SetupFields;
var
sKeyType : string[3];

begin
  sKeyType := DBComboType.Text;
  if (sKeyType = 'NUM') or (sKeyType = 'PMP') then
    begin
      lNumber.Visible := True;
      lPreset.Visible := False;
      DBEditValue.Visible := True;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := False;
    end
  else if sKeyType = 'DPT' then
    begin
      lNumber.Visible := True;
      lPreset.Visible := True;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := True;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := True;
    end
  else if sKeyType = 'PPL' then
    begin
      lNumber.Visible := True;
      lPreset.Visible := False;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := True;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := False;
    end
  else if sKeyType = 'MED' then
    begin
      lNumber.Visible := True;
      lPreset.Visible := True;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := True;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := True;
    end
  else if sKeyType = 'MNU' then
    begin
      lNumber.Visible := True;
      lPreset.Visible := False;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := True;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := False;
    end
  else if sKeyType = 'BNK' then
    begin
      lNumber.Visible := True;
      lPreset.Visible := False;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := True;
      DBEditPreset.Visible := False;
    end
  else
    begin
      lNumber.Visible := False;
      lPreset.Visible := False;
      DBEditValue.Visible := False;
      DBLookupDept.Visible := False;
      DBLookupPLU.Visible := False;
      DBLookupMedia.Visible := False;
      DBLookupMenu.Visible := False;
      DBLookupBankFunc.Visible := False;
      DBEditPreset.Visible := False;
//      DM.TouchKybdTable.FieldByName('KEYVAL').AsString := ' ';
    end;

end;



end.

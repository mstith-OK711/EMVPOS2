unit ccsetup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Mask, DBCtrls, DB, NBSMain, ComCtrls;

type
  TfmCreditSetup = class(TForm)
    OKButton: TBitBtn;
    CancelButton: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    eModemName: TComboBox;
    Label6: TLabel;
    Label8: TLabel;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    Label11: TLabel;
    DBEdit10: TDBEdit;
    btnModemCfg: TBitBtn;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    DBEdit11: TDBEdit;
    DBEdit12: TDBEdit;
    DBEdit13: TDBEdit;
    TabSheet2: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    DBEdit8: TDBEdit;
    DBEdit9: TDBEdit;
    TabSheet3: TTabSheet;
    Label15: TLabel;
    DBEdit14: TDBEdit;
    Label16: TLabel;
    DBEdit15: TDBEdit;
    Label17: TLabel;
    DBEdit16: TDBEdit;
    Label18: TLabel;
    DBEdit17: TDBEdit;
    Label20: TLabel;
    DBEdit18: TDBEdit;
    DBEdit73: TDBEdit;
    Label31: TLabel;
    DBEdit77: TDBEdit;
    DBEdit78: TDBEdit;
    Label36: TLabel;
    Label5: TLabel;
    fldAutoBatchBal: TDateTimePicker;
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnModemCfgClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCreditSetup: TfmCreditSetup;

  SearchOption: TLocateOptions;


implementation

uses ccDM, ModmProp;

{$R *.DFM}

procedure TfmCreditSetup.OKButtonClick(Sender: TObject);
begin

  try
    CCDataMod.SetupTable.FieldByName('AutoBatchBal').AsDateTime := fldAutoBatchBal.Time;
  except
    CCDataMod.SetupTable.FieldByName('AutoBatchBal').AsDateTime := 0 ;
  end;
  CCDataMod.SetupTable.FieldByName('ModemName').AsString := eModemName.Text;
  CCDataMod.SetupTable.Post;
end;

procedure TfmCreditSetup.CancelButtonClick(Sender: TObject);
begin
  CCDataMod.SetupTable.Cancel;
end;

procedure TfmCreditSetup.FormShow(Sender: TObject);

var
ndx : short;
begin

  with CCDataMod.SetupTable do
    begin
      Active := True;
      if Locate('CCNo', 0, SearchOption) then
        Edit
      else
        begin
          Insert;
          FieldByName('CCNo').AsInteger      := 0;
          FieldByName('SWVersion').AsString  := '1.00';
          FieldByName('BatchNo').AsInteger   := 1;
          FieldByName('SeqNo').AsInteger     := 1;
          Post;
          Edit;
        end;
    end;

  fmCreditServer.ModemDB.Open := True;
  eModemName.Items := fmCreditServer.ModemDB.Modems;

  eModemName.ItemIndex := 0;
  for  ndx := 0 to eModemName.Items.Count do
    begin
      if eModemName.Items[ndx] = iModemName then
        begin
          eModemName.ItemIndex := ndx;
          break;
        end
    end;

  try
    fldAutoBatchBal.Time := Frac(CCDataMod.SetupTable.FieldByName('AutoBatchBal').AsDateTime);
  except
    fldAutoBatchBal.Time := 0;
  end;


end;

procedure TfmCreditSetup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  fmCreditServer.ModemDB.Open := False;
end;

procedure TfmCreditSetup.btnModemCfgClick(Sender: TObject);
begin

  fmModemProperties.ModemName := eModemName.Text;
  fmModemProperties.ShowModal;
end;



end.

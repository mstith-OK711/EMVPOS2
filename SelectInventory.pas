unit SelectInventory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ElastFrm;

type
  TfmInventorySelect = class(TForm)
    ElasticForm1: TElasticForm;
    btnReceive: TBitBtn;
    btnAdjust: TBitBtn;
    btnCancel: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
    procedure btnReceiveClick(Sender: TObject);
    procedure btnAdjustClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmInventorySelect: TfmInventorySelect;

implementation

uses Receive, Adjust;

{$R *.dfm}

procedure TfmInventorySelect.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfmInventorySelect.btnReceiveClick(Sender: TObject);
begin
  fmReceive := TfmReceive.Create(Self);
  fmReceive.ShowModal;
  fmReceive.Release;
end;

procedure TfmInventorySelect.btnAdjustClick(Sender: TObject);
begin
  fmAdjust := TfmAdjust.Create(Self);
  fmAdjust.ShowModal;
  fmAdjust.Release;
end;

end.

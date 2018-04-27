
unit PinPadMsgEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ElastFrm, RXCtrls, RXSpin, ExtCtrls, DBCtrls, Buttons, prohelp;

type
  TfmPinPadMsgEdit = class(TForm)
    ElasticForm1: TElasticForm;
    edPinPadPrompt: TEdit;
    btnSave: TBitBtn;
    igHelpButton1: TigHelpButton;
    btnCancel: TBitBtn;
    lbPromptName: TLabel;
    Label2: TLabel;
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


var
  fmPinPadMsgEdit: TfmPinPadMsgEdit;

implementation

uses PosDm;

{$R *.DFM}


procedure TfmPinPadMsgEdit.btnSaveClick(Sender: TObject);
begin
  //No need to validate because blanks are allowed
  if not POSDataMod.IBDefaultTrans.InTransaction then
    POSDataMod.IBDefaultTrans.StartTransaction;
  with POSDataMod.IBQryTemp do
  begin
    close;
    SQL.Clear;
    SQL.Add('Update PinMsg set PINPrompt = :pPinPrompt ');
    SQL.Add('where PinMsgNo = :pPinMsgNo and PinPadType = :pPinPadType');
    parambyname('pPINPrompt').AsString := edPinPadPrompt.Text;
    parambyname('pPinMsgNo').AsString :=
      POSDataMod.IBQryPINPadMsg.fieldbyname('PinMsgNo').AsString;
    parambyname('pPinPadType').AsString :=
      POSDataMod.IBQryPINPadMsg.fieldbyname('PinPadType').AsString;
    ExecSQL;
    close;
  end;
  POSDataMod.IBDefaultTrans.Commit;
  close;
end;


procedure TfmPinPadMsgEdit.btnCancelClick(Sender: TObject);
begin
  if POSDataMod.IBDefaultTrans.InTransaction then
    POSDataMod.IBDefaultTrans.Rollback;
  Close;
end;

procedure TfmPinPadMsgEdit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Escape then
    btnCancelClick(Sender);
end;

procedure TfmPinPadMsgEdit.FormActivate(Sender: TObject);
begin

  with POSDataMod.IBQryTemp do
  begin
    close;
    SQL.Clear;
    SQL.Add('Select * from PinMsg where PinMsgNo = :pPinMsgNo and PinPadType = :pPinPadType');

    parambyname('pPinMsgNo').AsString :=
      POSDataMod.IBQryPINPadMsg.fieldbyname('PinMsgNo').AsString;
    parambyname('pPinPadType').AsString :=
      POSDataMod.IBQryPINPadMsg.fieldbyname('PinPadType').AsString;
    open;
    edPinPadPrompt.text := FieldByName('PINPrompt').AsString ;
    lbPromptName.Caption := 'Prompt Name ' + FieldByName('PINMsgName').AsString ;
    close;
  end;

end;

end.

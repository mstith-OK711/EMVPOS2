unit MoDocNo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMoDocEntry = class(TForm)
    Label1: TLabel;
    DocNo: TLabel;
    lStatus: TPanel;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ProcessScan(const symbology, data : string);
  end;

var
  MoDocEntry: TMoDocEntry;

implementation

uses POSMain, StrUtils, POSMisc;

{$R *.dfm}

procedure TMoDocEntry.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TMoDocEntry.FormShow(Sender: TObject);
begin
  self.Top := Trunc(((Screen.Height - self.Height) / 2)) + 100;
  self.Left := Trunc(((Screen.Width - self.Width) / 2));
  lStatus.Caption := 'Please scan MO barcode';
  DocNo.Caption := '';
end;

procedure TMoDocEntry.ProcessScan(const symbology, data: string);
begin
  if symbology = fmPos.Config.Str['SCAN_MO_SYMBOLOGY'] then
  begin
    DocNo.Caption := StrUtils.LeftStr(data,10);
    fmPOS.MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(CMD_MOSETDOCNO)) + BuildTag(TAG_MODOCNO, DocNo.Caption));
    ModalResult := mrOK;;
  end
  else
    fmPOS.POSError('Barcode Symbology incorrect - "' + symbology + '"');
end;


end.

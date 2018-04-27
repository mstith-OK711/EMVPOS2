unit SigVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmSigVerify = class(TForm)
    SigImg: TImage;
    btnAccept: TButton;
    btnReject: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSigVerify: TfrmSigVerify;

implementation

{$R *.dfm}

procedure TfrmSigVerify.FormShow(Sender: TObject);
var
  AX, RX : integer;
begin
  AX := btnAccept.Left;
  RX := btnReject.Left;
  btnAccept.Left := RX;
  btnReject.Left := AX;
end;

end.

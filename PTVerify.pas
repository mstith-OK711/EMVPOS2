unit PTVerify;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmPTVerify = class(TForm)
    btnAccept: TButton;
    btnReject: TButton;
    Label1: TLabel;
    Notice: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnRejectClick(Sender: TObject);
  private
    FTendered: currency;
    FPreviousBalance: currency;
    procedure SetPreviousBalance(const Value: currency);
    procedure SetTendered(const Value: currency);
    { Private declarations }
  public
    { Public declarations }
    property Tendered : currency read FTendered write SetTendered;
    property PreviousBalance : currency read FPreviousBalance write SetPreviousBalance;
  end;

var
  frmPTVerify: TfrmPTVerify;

implementation

{$R *.dfm}

uses ExceptLog;

procedure TfrmPTVerify.FormShow(Sender: TObject);
var
  AX, RX : integer;
begin
  AX := btnAccept.Left;
  RX := btnReject.Left;
  btnAccept.Left := RX;
  btnReject.Left := AX;
  Label1.Width := Self.Width;
  Label1.Alignment := taCenter;
  Label1.Invalidate;
  Notice.Caption := Format('$%.02g of $%.02g will be applied to the sale.', [FTendered, FPreviousBalance]);
  Notice.Width := Self.Width;
  Notice.Alignment := taCenter;
  Notice.Invalidate;
  Self.SetBounds((Screen.Width - Self.Width) div 2, (Screen.Height - Self.Height) div 2, Self.Width, Self.Height);
end;

procedure TfrmPTVerify.SetPreviousBalance(const Value: currency);
begin
  FPreviousBalance := Value;
end;

procedure TfrmPTVerify.SetTendered(const Value: currency);
begin
  FTendered := Value;
end;

procedure TfrmPTVerify.btnAcceptClick(Sender: TObject);
begin
  UpdateZLog('TfrmPTVerify - Accept clicked');
end;

procedure TfrmPTVerify.btnRejectClick(Sender: TObject);
begin
  UpdateZLog('TfrmPTVerify - Reject clicked');
end;

end.

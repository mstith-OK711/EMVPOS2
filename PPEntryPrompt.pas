unit PPEntryPrompt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmPPEntryPrompt = class(TForm)
    Panel1: TPanel;
    btCancel: TButton;
    procedure FormShow(Sender: TObject);
  private
    Fresponse: string;
    procedure Setresponse(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    function ShowPrompt(const prompt : string) : integer;
    property response : string read Fresponse write Setresponse;
  end;

var
  fmPPEntryPrompt: TfmPPEntryPrompt;

implementation

{$R *.dfm}

procedure TfmPPEntryPrompt.FormShow(Sender: TObject);
begin
  Self.Left := (Screen.Width - Self.Width) div 2;
  Self.Top := (Screen.Height - Self.Height) div 2;
end;

procedure TfmPPEntryPrompt.Setresponse(const Value: string);
begin
  Fresponse := Value;
end;

function TfmPPEntryPrompt.ShowPrompt(const prompt: string): integer;
begin
  Self.Panel1.Caption := prompt;
  Result := Self.ShowModal;
end;

end.

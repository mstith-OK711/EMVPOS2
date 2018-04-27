unit BOMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons;

type
  TfmBOMenu = class(TForm)
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmBOMenu: TfmBOMenu;

implementation

{$R *.DFM}

procedure TfmBOMenu.FormShow(Sender: TObject);
begin
  fmBOMenu.Width := 33;
end;

end.

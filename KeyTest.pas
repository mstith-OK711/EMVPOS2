unit KeyTest;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Mask, DBCtrls, Grids, DBGrids;

type
  TForm2 = class(TForm)
    BitBtn1: TBitBtn;
    DBEdit1: TDBEdit;
    DBLookupComboBox1: TDBLookupComboBox;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses POSDM;

{$R *.DFM}

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

end.

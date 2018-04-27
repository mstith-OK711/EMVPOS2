unit prtchk;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, AdPort;

type
  TForm1 = class(TForm)
    ReceiptPort: TApdComPort;
    BitBtn1: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  c : char;
const

PrtStatus  : String = #27#118;


implementation

{$R *.DFM}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin

  ReceiptPort.Open := True;
  ReceiptPort.Output := PrtStatus ;
  c := #255;
  sleep(1000);
  if ReceiptPort.CharReady then
    c := ReceiptPort.GetChar;

  c := #0;

end;

end.

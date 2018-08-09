{-----------------------------------------------------------------------------
 Unit Name: TermNo
 Author:    Gary Whetton
 Date:      4/13/2004 4:23:36 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit TermNo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, RXSpin, POSMain, ElastFrm ;

type
  TfmSetTerminal = class(TForm)
    Label1: TLabel;
    edTerminalNo: TRxSpinEdit;
    btnOK: TBitBtn;
    ElasticForm1: TElasticForm;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmSetTerminal: TfmSetTerminal;

implementation

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmSetTerminal.btnOKClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSetTerminal.btnOKClick(Sender: TObject);
begin
  fmPOS.ThisTerminalNo := Trunc(edTerminalNo.Value);
  Close;
end;

end.

{-----------------------------------------------------------------------------
 Unit Name: SelTermShift
 Author:    Gary Whetton
 Date:      4/13/2004 4:20:51 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit SelTermShift;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ElastFrm, POSBtn;

type
  TfmSelectTermShift = class(TForm)
    btnTerminalUp: TPOSTouchButton;
    btnTerminalDown: TPOSTouchButton;
    ElasticForm1: TElasticForm;
    btnOK: TPOSTouchButton;
    btnCancel: TPOSTouchButton;
    btnShiftUp: TPOSTouchButton;
    btnShiftDown: TPOSTouchButton;
    edTerminal: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edShift: TEdit;
    procedure btnTerminalUpClick(Sender: TObject);
    procedure btnTerminalDownClick(Sender: TObject);
    procedure btnShiftUpClick(Sender: TObject);
    procedure btnShiftDownClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SelShift, SelTerminal : integer;
    procedure RefreshDisplay;
  end;

var
  fmSelectTermShift: TfmSelectTermShift;
  MaxShift, MaxTerminal : integer;

implementation

uses POSDM, POSMain;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnTerminalUpClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnTerminalUpClick(Sender: TObject);
begin
  if (edTerminal.Tag < MaxTerminal) then
    edTerminal.Tag := edTerminal.Tag + 1;
  RefreshDisplay;

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnTerminalDownClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnTerminalDownClick(Sender: TObject);
begin
  if edTerminal.Tag > 0  then
    edTerminal.Tag := edTerminal.Tag - 1;
  RefreshDisplay;

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnShiftUpClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnShiftUpClick(Sender: TObject);
begin
  if edShift.Tag < MaxShift then
    edShift.Tag := edShift.Tag + 1;
  RefreshDisplay;

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnShiftDownClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnShiftDownClick(Sender: TObject);
begin
  if edShift.Tag > 0 then
    edShift.Tag := edShift.Tag - 1;
  RefreshDisplay;

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnOKClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnOKClick(Sender: TObject);
begin
  SelTerminal := edTerminal.Tag;
  SelShift    := edShift.Tag;
  fmSelectTermShift.ModalResult := mrOK;
//  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.RefreshDisplay
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.RefreshDisplay;
begin

  if edTerminal.Tag = 0 then
    edTerminal.Text := 'All Terminals'
  else
    edTerminal.Text := 'Terminal# ' + IntToStr(edTerminal.Tag);

  if edShift.Tag = 0 then
    edShift.Text := 'All Shifts'
  else
    edShift.Text := 'Shift# ' + IntToStr(edShift.Tag);

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.btnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.btnCancelClick(Sender: TObject);
begin

  fmSelectTermShift.ModalResult := mrCancel;
//  Close;

end;


{-----------------------------------------------------------------------------
  Name:      TfmSelectTermShift.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmSelectTermShift.FormShow(Sender: TObject);
begin

   edTerminal.Tag := 0;
   edShift.Tag := 0;
   edTerminal.Text := 'All Terminals';
   edShift.Text    := 'All Shifts';
   MaxShift := 0;
   MaxTerminal := 0;
   if not POSDataMod.IBTransaction.InTransaction then
     POSDataMod.IBTransaction.StartTransaction;
   with POSDataMod.IBTempQuery do
   begin
     Close;SQL.Clear;
     SQL.Add('Select MAX(CurShift) MaxShift, Count(*) MaxTerminal from Terminal');
     Open;
     MaxShift := Fields[0].AsInteger;
     MaxTerminal := Fields[1].AsInteger;
     Close;
   end;
   if POSDataMod.IBTransaction.InTransaction then
     POSDataMod.IBTransaction.Commit;
  case fmPOS.POSScreenSize of
  1:
    begin

      btnTerminalUp.Height := 60;
      btnTerminalDown.Height := 60;
      btnShiftUp.Height := 60;
      btnShiftDown.Height := 60;
      btnOK.Height := 60;
      btnCancel.Height := 60;
      btnTerminalUp.Width := 60;
      btnTerminalDown.Width := 60;
      btnShiftUp.Width := 60;
      btnShiftDown.Width := 60;
      btnOK.Width := 60;
      btnCancel.Width := 60;


      btnOK.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnCancel.Glyph.LoadFromResourceName(HInstance, 'BIGRED_SQ');
      btnTerminalUp.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnTerminalDown.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnShiftUp.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnShiftDown.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');

    end;

  2:
    begin

      btnTerminalUp.Height := 47;
      btnTerminalDown.Height := 47;
      btnShiftUp.Height := 47;
      btnShiftDown.Height := 47;
      btnOK.Height := 47;
      btnCancel.Height := 47;
      btnTerminalUp.Width := 47;
      btnTerminalDown.Width := 47;
      btnShiftUp.Width := 47;
      btnShiftDown.Width := 47;
      btnOK.Width := 47;
      btnCancel.Width := 47;

      btnOK.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnCancel.Glyph.LoadFromResourceName(HInstance, 'SMLRED_SQ');
      btnTerminalUp.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnTerminalDown.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnShiftUp.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnShiftDown.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');

    end;
  end;

end;

end.

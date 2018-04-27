{-----------------------------------------------------------------------------
 Unit Name: PLUSearch
 Author:    Gary Whetton
 Date:      9/11/2003 3:12:00 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PLUSearch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, RXDBCtrl, Db, DBTables, RxQuery, StdCtrls,
  RXSlider, POSBtn, RxGrdCpt, ElastFrm;

type
  TfrmPLULookup = class(TForm)
    Grid1: TRxDBGrid;
    sldLtr: TRxSlider;
    tbtnA: TPOSTouchButton;
    tBtnZ: TPOSTouchButton;
    lblCurLtr: TStaticText;
    tbtnSelect: TPOSTouchButton;
    tbtnCancel: TPOSTouchButton;
    RxGradientCaption1: TRxGradientCaption;
    POSTouchButton1: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    ElasticForm1: TElasticForm;
    procedure sldLtrChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sldLtrChanged(Sender: TObject);
    procedure tbtnAClick(Sender: TObject);
    procedure tBtnZClick(Sender: TObject);
    procedure AfterScroll(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbtnCancelClick(Sender: TObject);
    procedure tbtnSelectClick(Sender: TObject);
    procedure Grid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Grid1DblClick(Sender: TObject);
    procedure POSTouchButton1Click(Sender: TObject);
    procedure POSTouchButton2Click(Sender: TObject);
    procedure Grid1TitleClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    ItemSelected : boolean;
    SelectedPLU : double;
    SelectedPLUModifier : integer;

  end;

const

Letters: array[1..26] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';



var
  frmPLULookup: TfrmPLULookup;
  LtrPosIncr, LtrPosOffset : short;

implementation

uses POSDM, POSMain;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.sldLtrChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.sldLtrChange(Sender: TObject);
begin

  lblCurLtr.caption := Letters[sldLtr.value];
  if (sldLtr.value > 1) and (sldLtr.Value < 26) then
    begin
      lblCurLtr.Left := (sldLtr.Left - LtrPosOffset) + ((sldLtr.Value ) * LtrPosIncr);
      lblCurLtr.Visible := True
    end
  else
    lblCurLtr.Visible := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.FormShow(Sender: TObject);
begin



 // POSDataMod.PLUMemTable.OrderBy := 'NAME';
  POSDataMod.PLUMemTable.First;
  POSDataMod.PLUMemTable.AfterScroll := AfterScroll;
  sldLtr.Value := 1;
  lblCurLtr.Visible := False;
  lblCurLtr.caption := Letters[sldLtr.value];
  LtrPosIncr := Trunc(sldLtr.Width / 26);
  LtrPosOffset := Trunc(lblCurLtr.Width / 2);


  case fmPOS.POSScreenSize of
  1:
    begin

      tbtnA.Height := 60;
      tBtnZ.Height := 60;
      tbtnSelect.Height := 60;
      tbtnCancel.Height := 60;
      POSTouchButton1.Height := 60;
      POSTouchButton2.Height := 60;
      tbtnA.Width := 60;
      tBtnZ.Width := 60;
      tbtnSelect.Width := 60;
      tbtnCancel.Width := 60;
      POSTouchButton1.Width := 60;
      POSTouchButton2.Width := 60;

      tbtnA.Glyph.LoadFromResourceName(HInstance, 'BIGCYN_SQ');
      tBtnZ.Glyph.LoadFromResourceName(HInstance, 'BIGCYN_SQ');
      tbtnSelect.Glyph.LoadFromResourceName(HInstance, 'BIGRED_SQ');
      tbtnCancel.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');

    end;

  2:
    begin

      tbtnA.Height := 47;
      tBtnZ.Height := 47;
      tbtnSelect.Height := 47;
      tbtnCancel.Height := 47;
      POSTouchButton1.Height := 47;
      POSTouchButton2.Height := 47;
      tbtnA.Width := 47;
      tBtnZ.Width := 47;
      tbtnSelect.Width := 47;
      tbtnCancel.Width := 47;
      POSTouchButton1.Width := 47;
      POSTouchButton2.Width := 47;

      tbtnA.Glyph.LoadFromResourceName(HInstance, 'SMLCYN_SQ');
      tBtnZ.Glyph.LoadFromResourceName(HInstance, 'SMLCYN_SQ');
      tbtnSelect.Glyph.LoadFromResourceName(HInstance, 'SMLRED_SQ');
      tbtnCancel.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');

    end;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.sldLtrChanged
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.sldLtrChanged(Sender: TObject);
begin
  POSDataMod.PLUMemTable.Locate( 'Name', Letters[sldLtr.value], [loCaseInsensitive, loPartialKey]);
  grid1.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.tbtnAClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.tbtnAClick(Sender: TObject);
begin
  sldLtr.Value := 1;
  sldLtrChanged(self);
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.tBtnZClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.tBtnZClick(Sender: TObject);
begin

  sldLtr.Value := 26;
  sldLtrChanged(self);

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.AfterScroll
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: DataSet: TDataSet
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.AfterScroll(DataSet: TDataSet);
begin
  if Letters[sldLtr.Value] <> Copy(POSDataMod.PluMemTable.FieldByName('Name').AsString,1,1) then
    sldLtr.Value := AnsiPos(Copy(POSDataMod.PLUMemTable.FieldByName('Name').AsString,1,1), Letters);

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  POSDataMod.PLUMemTable.AfterScroll := nil;

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.tbtnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.tbtnCancelClick(Sender: TObject);
begin
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.tbtnSelectClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.tbtnSelectClick(Sender: TObject);
begin
  SelectedPLU := POSDataMod.PLUMemTable.FieldByName('PLUNo').AsCurrency;
  SelectedPLUModifier := POSDataMod.PLUMemTable.FieldByName('ModifierNo').AsInteger;
  ItemSelected := True;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.Grid1KeyDown
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Key: Word; Shift: TShiftState
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.Grid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    begin
      SelectedPLU := POSDataMod.PLUMemTable.FieldByName('PLUNo').AsCurrency;
      SelectedPLUModifier := POSDataMod.PLUMemTable.FieldByName('ModifierNo').AsInteger;
      ItemSelected := True;
      Close;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.Grid1DblClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.Grid1DblClick(Sender: TObject);
begin
  SelectedPLU := POSDataMod.PLUMemTable.FieldByName('PLUNo').AsCurrency;
  SelectedPLUModifier := POSDataMod.PLUMemTable.FieldByName('ModifierNo').AsInteger;
  ItemSelected := True;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.POSTouchButton1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.POSTouchButton1Click(Sender: TObject);
begin
  POSDataMod.PLUMemTable.Prior;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.POSTouchButton2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.POSTouchButton2Click(Sender: TObject);
begin
  POSDataMod.PLUMemTable.Next;
end;


{-----------------------------------------------------------------------------
  Name:      TfrmPLULookup.Grid1TitleClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Column: TColumn
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfrmPLULookup.Grid1TitleClick(Column: TColumn);
begin

  case Column.Index of
  0 :
    begin
      //Build 23
      //POSDataMod.PLUMemTable.OrderBy := 'PLUNO';
      POSDataMod.PLUMemTable.SortOnFields('PLUNo');
      //Build 23
      POSDataMod.PLUMemTable.Refresh;
      Grid1.Refresh;
    end;
  1 :
    begin
      //Build 23
      //POSDataMod.PLUMemTable.OrderBy := 'UPC';
      POSDataMod.PLUMemTable.SortOnFields('UPC');
      //Build 23
      POSDataMod.PLUMemTable.Refresh;
      Grid1.Refresh;
    end;
  2 :
    begin
      //Build 23
      //POSDataMod.PLUMemTable.OrderBy := 'Name';
      POSDataMod.PLUMemTable.SortOnFields('Name');
      //Build 23
      POSDataMod.PLUMemTable.Refresh;
      Grid1.Refresh;
    end;
  end;



end;

end.

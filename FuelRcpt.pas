{-----------------------------------------------------------------------------
 Unit Name: FuelRcpt
 Author:    Gary Whetton
 Date:      9/11/2003 2:59:55 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit FuelRcpt;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, POSMain,
  Grids, DB, DBGrids, StdCtrls, ElastFrm, POSBtn;

type
  TfmFuelReceipt = class(TForm)
    DBGrid1: TDBGrid;
    lSubtotal: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ElasticForm1: TElasticForm;
    tbtnCancel: TPOSTouchButton;
    tbtnSelect: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    POSTouchButton1: TPOSTouchButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure tbtnCancelClick(Sender: TObject);
    procedure tbtnSelectClick(Sender: TObject);
    procedure POSTouchButton1Click(Sender: TObject);
    procedure POSTouchButton2Click(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure PrintFuelReceipt;
  end;

var
  fmFuelReceipt: TfmFuelReceipt;
  KeyBuff: array[0..200] of Char;


implementation
{$R *.DFM}

uses POSDM, POSLog, POSPrt;

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.PrintFuelReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
Procedure TfmFuelReceipt.PrintFuelReceipt;
var
  sTransNo : integer;
  sShiftNo : integer;
Begin

  If POSDataMod.IBFuelTranQuery.BOF and POSDataMod.IBFuelTranQuery.EOF Then
      Exit;  { Empty Table... }


  sTransNo := rcptSale.nTransNo;
  sShiftNo := nRcptShiftNo;

  rcptSale.nTransNo := POSDataMod.IBFuelTranQuery.FieldByName('TransNo').AsInteger;
  nRcptShiftNo := nShiftNo;

  PRINTING_REPORT := True;        { to make sure all the lines get printed...}
  POSPrt.PrintReprint;

  { First the Fuel ---------------------}
  PrintLine('Pump# ' + IntToStr(POSDataMod.IBFuelTranQuery.FieldbyName('PumpNo').AsInteger)
                  + POSDataMod.IBFuelTranQuery.FieldbyName('GradeName').AsString);

  PrintLine(Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',POSDataMod.IBFuelTranQuery.FieldbyName('Volume').AsCurrency))])
          + ' @ ' +
          Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',POSDataMod.IBFuelTranQuery.FieldbyName('UnitPrice').AsCurrency))]) +
          Format('%15s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBFuelTranQuery.FieldbyName('Amount').AsCurrency))]));

  { Now the Total ----------------------}

  PrintLine('                ' + PrtBold + 'Total'+ PrtMode + '   ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBFuelTranQuery.FieldbyName('Amount').AsCurrency))]));

  PosPrt.PrintSeq;

  PRINTING_REPORT := False;

   { All that is left is to Log the Printing of the Receipt, so the }
   { afterworld knows what happend to this Saleid...                }

   LogCCReceipt('Fuel Receipt Reprint');

   rcptSale.nTransNo := sTransNo;
   nRcptShiftNo := sShiftNo;

end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.CheckKey(var Msg : TWMPOSKey);
var
 sKeyChar  : string[2];
 s         : String;
begin
  KeyBuff[BuffPtr] := Msg.KeyCode;
  if BuffPtr = 1 then
    begin
      sKeyChar := UpperCase(Copy(KeyBuff,1,2));
      if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
        begin
          sKeyType := KBDef[sKeyChar[1], sKeyChar[2]].KeyType;
          sKeyVal  := KBDef[sKeyChar[1], sKeyChar[2]].KeyVal;
          sPreset  := KBDef[sKeyChar[1], sKeyChar[2]].Preset;

          ProcessKey();
        end;

      KeyBuff := '';
      BuffPtr := 0;
    end
  else
   begin
     s:= UpperCase(KeyBuff[0]);
     if s[1] in ['A'..'N'] then
        Inc(BuffPtr,1) ;
   end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.ProcessKey;
begin

  if sKeyType = 'ENT' then
   Begin
     PrintFuelReceipt;
     ModalResult := mrOk;
   end

  else if sKeyType = 'CLR' then
     ModalResult := mrCancel

  else if sKeyType = 'UP ' then
    begin
      POSDataMod.IBFuelTranQuery.Prior;
    end
  else if sKeyType = 'DN ' then
    begin
      POSDataMod.IBFuelTranQuery.Next;
    end

  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL

  else if sKeyType = 'PMP' then        { Pump Number }
    begin
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
    end

  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PAL' then        { Pump Auth All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;


end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  POSDataMod.IBFuelTranQuery.Close;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  fmPOS.ClearEntryField;
  fmPOS.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.FormShow(Sender: TObject);
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBFuelTranQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select F.TransNo TransNo, F.CollectTime CollectTime, F.PumpNo PumpNo, F.PrePayAmount PrePayAmount, ');
      SQL.Add('F.Volume Volume, F.UnitPrice UnitPrice, F.Amount Amount, G.Name GradeName From FuelTran F, PumpDef P, Grade G ');
      SQL.Add('Where F.PumpNo = P.PumpNo and F.HoseNo = P.HoseNo and G.GradeNo = P.GradeNo');
      SQL.Add('and ((F.SaleType = :pSaleType1) or (F.SaleType = :pSaleType2)) and F.Completed = 1 ');
      SQL.Add('Order By TransNo desc ');
      parambyname('pSaleType1').AsString := 'POS';
      parambyname('pSaleType2').AsString := 'PPY';
      POSDataMod.IBFuelTranQuery.Open;

    end;
 (POSDataMod.IBFuelTranQuery.FieldByName('CollectTime') As TDateTimeField).DisplayFormat := 'hh:mm am/pm';
 (POSDataMod.IBFuelTranQuery.FieldByName('Volume') As TNumericField).DisplayFormat := '#.000 ;#.000-';
 (POSDataMod.IBFuelTranQuery.FieldByName('Amount') As TNumericField).DisplayFormat := '#.00 ;#.00-';
 (POSDataMod.IBFuelTranQuery.FieldByName('PrePayAmount') As TNumericField).DisplayFormat := '0.00 ;0.00-;#.## ';

  case fmPOS.POSScreenSize of
  1:
    begin
      DBGrid1.Columns[1].Width := 90;
      tbtnSelect.Height := 60;
      tbtnCancel.Height := 60;
      POSTouchButton1.Height := 60;
      POSTouchButton2.Height := 60;
      tbtnSelect.Width := 60;
      tbtnCancel.Width := 60;
      POSTouchButton1.Width := 60;
      POSTouchButton2.Width := 60;

      tbtnSelect.Glyph.LoadFromResourceName(HInstance, 'BIGRED_SQ');
      tbtnCancel.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');

    end;

  2:
    begin
      DBGrid1.Columns[1].Width := 70;
      DBGrid1.Columns[2].Width := 60;
      DBGrid1.Columns[3].Width := 80;
      DBGrid1.Columns[4].Width := 60;
      DBGrid1.Columns[5].Width := 70;
      DBGrid1.Columns[6].Width := 60;
      tbtnSelect.Height := 47;
      tbtnCancel.Height := 47;
      POSTouchButton1.Height := 47;
      POSTouchButton2.Height := 47;
      tbtnSelect.Width := 47;
      tbtnCancel.Width := 47;
      POSTouchButton1.Width := 47;
      POSTouchButton2.Width := 47;

      tbtnSelect.Glyph.LoadFromResourceName(HInstance, 'SMLRED_SQ');
      tbtnCancel.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');

    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.POSTouchButton1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.POSTouchButton1Click(Sender: TObject);
begin
  POSDataMod.IBFuelTranQuery.Prior;
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.tbtnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.tbtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.tbtnSelectClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.tbtnSelectClick(Sender: TObject);
begin
  PrintFuelReceipt;
  ModalResult := mrOk;
end;


{-----------------------------------------------------------------------------
  Name:      TfmFuelReceipt.POSTouchButton2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmFuelReceipt.POSTouchButton2Click(Sender: TObject);
begin
  POSDataMod.IBFuelTranQuery.Next;
end;

end.

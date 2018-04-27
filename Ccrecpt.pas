{-----------------------------------------------------------------------------
 Unit Name: CCRecpt
 Author:    Gary Whetton
 Date:      9/11/2003 2:51:08 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}


unit CCRecpt;

{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, POSMain,
  Grids, DB, DBGrids, StdCtrls, ElastFrm, POSBtn;

type
  TfmCardReceipt = class(TForm)
    DBGrid1: TDBGrid;
    lSubtotal: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ElasticForm1: TElasticForm;
    POSTouchButton1: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    tbtnSelect: TPOSTouchButton;
    tbtnCancel: TPOSTouchButton;
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
    procedure PrintCardReceipt;
    procedure FormatAmount(Sender: TField; var Text: string; DisplayText: Boolean);

    {$IFDEF CISP_CODE}
    procedure GetCardNameEvent(Sender: TField; var Text : string; DisplayText : boolean);
    {$ENDIF}

  end;

var
  fmCardReceipt: TfmCardReceipt;
  KeyBuff: array[0..200] of Char;


implementation
{$R *.DFM}

uses POSDM, POSLog, POSPrt, StrUtils;

var
  // Keyboard Handling
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.PrintCardReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
Procedure TfmCardReceipt.PrintCardReceipt;
var
  tStr  : array[0..40] of char;
  n,x   : short;
  //cwc...
  CWValue : currency;
  TotalAmount : currency;
  CWAccessCode : string;
  //...cwc
  //cwf...
  CWExpDate : TDateTime;
  //...cwf
  //20061023e...
  FuelAmount : currency;
  DiscAmount : currency;
  DiscLabel : string;
  CreditAuthID : integer;
  //...20061023e
  ccAuthErrorCode : string;
  cardno : string;
Begin

  ccAuthErrorCode := '';  // Will be reset below if applies

  If POSDataMod.IBCCBatchQuery.BOF and POSDataMod.IBCCBatchQuery.EOF Then
      Exit;  { Empty Table... }

  rcptSale.nTransNo := POSDataMod.IBCCBatchQuery.FieldByName('TransNo').AsInteger;
  PRINTING_REPORT := True;        { to make sure all the lines get printed...}
  POSPrt.PrintReprint;

  { First the Fuel ---------------------}
  if not POSDataMod.IBReceiptTransaction.InTransaction then
    POSDataMod.IBReceiptTransaction.StartTransaction;
  with POSDataMod.IBReceiptQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select Name from Grade Where GradeNo = :pGradeNo');
      ParamByName('pGradeNo').AsInteger := POSDataMod.IBCCBatchQuery.FieldbyName('FuelGrade').AsInteger;
      Open;
      if NOT Eof then
        POSPrt.PrintLine('Pump# ' + IntToStr(POSDataMod.IBCCBatchQuery.FieldbyName('PumpNo').AsInteger) +
                        ' ' + Trim(FieldbyName('Name').AsString));
      Close;
    end;
  if POSDataMod.IBReceiptTransaction.InTransaction then
    POSDataMod.IBReceiptTransaction.Commit;

  //20061023e...
  // Check for discount.  These transactions represent pay-at-pump with credit/debit, so
  // the entire amount pumped (plus carwash amount if applicable) should be on the card.
  // Any amount not charged must be a discount that was applied at the CAT.
  DiscAmount := 0.0;        // Initial assumption (potentially reset below)
  DiscLabel := 'Discount';  // Initial assumption (potentially reset below)
  FuelAmount := POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency;  // Initial assumption (potentially reset below)
  CreditAuthID := POSDataMod.IBCCBatchQuery.FieldbyName('AuthID').AsInteger;
  if (CreditAuthID > 0) then
  begin
    with POSDataMod.IBTempQry1 do
    begin

      if (not Transaction.InTransaction) then
        Transaction.StartTransaction;

      Close();
      SQL.Clear();
      SQL.Add('Select * from FuelTran where AuthID = :pAuthID');
      ParamByName('pAuthID').AsInteger  := CreditAuthID;
      Open();
      if (RecordCount > 0) then
      begin
        FuelAmount := FieldByName('Amount').AsCurrency;
        DiscAmount := POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency - FieldByName('Amount').AsCurrency;
        {$IFDEF ODOT_VMT}
        if (FieldByName('VMTFee').AsCurrency > 0.0) then
          DiscLabel := 'ST Fuel Tax';
        {$ENDIF}
      end;
      Close();

      // Check for any error message to display from credit authorization:

      SQL.Clear();
      SQL.Add('Select ErrorCode from ccAuth where AuthID = :pAuthID');
      ParamByName('pAuthID').AsInteger  := CreditAuthID;
      Open();
      if (RecordCount > 0) then
        ccAuthErrorCode := Trim(FieldByName('ErrorCode').AsString);
      Close();

      if (Transaction.InTransaction) then
        Transaction.Commit();
    end;  //with
  end;  // CreditAuthID > 0
  //...20061023e

  POSPrt.PrintLine(Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',POSDataMod.IBCCBatchQuery.FieldbyName('Gallons').AsCurrency))])
          + ' @ ' +
          Format('%10s',[(FormatFloat('#,###.000 ;#,###.000-',POSDataMod.IBCCBatchQuery.FieldbyName('Gradeprice').AsCurrency))]) +
          //20061023e...
//          Format('%15s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency))]);
          Format('%15s',[(FormatFloat('#,###.00 ;#,###.00-', FuelAmount))]));
          //...20061023e

//  {$IFDEF ODOT_VMT}  //20061023f  ( Moved to below)
//  POSPrt.PrintVMTData(0, POSDataMod.IBCCBatchQuery.FieldbyName('AuthID').AsInteger);
//  {$ENDIF}

  { Now the Total ----------------------}

  {$IFNDEF ODOT_VMT}  //20061023e
  POSPrt.PrintLine(Format('%26s',['Subtotal'])  + '   ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency))]));
  {$ENDIF}

  //cwc...
  { Check for carwash purchase ----------------------}
  CWAccessCode := Trim(POSDataMod.IBCCBatchQuery.FieldbyName('AccessCode').AsString);
  if (CWAccessCode <> '') then
    begin
      CWValue := POSDataMod.IBCCBatchQuery.FieldbyName('CWValue').AsCurrency;
      POSPrt.PrintLine(Format('%26s',[POSDataMod.IBCCBatchQuery.FieldbyName('CWName').AsString])  + '   ' + Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',CWValue))]));
    end
  else
    begin
      CWValue := 0.0;
    end;

  //20061023e...
  // Print any discount.
  if (DiscAmount < 0.0) then
    POSPrt.PrintLine(Format('%26s',[DiscLabel])  + '   ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', DiscAmount))]));
  //...20061023e

  TotalAmount := POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency + CWValue;
  //...cwc

  POSPrt.PrintLine('                ' + PrtBold + 'Total'+ PrtMode + '   ' +
  //cwc...
//          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency))]);
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', TotalAmount))]));
  //...cwc

  {$IFDEF ODOT_VMT}  //20061023f  ( Moved from above)
  POSPrt.PrintVMTData(0, CreditAuthID);
  {$ENDIF}

  { Now the Media ----------------------}
  if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
  with POSDataMod.IBTempQry1 do
  begin
    close;SQL.Clear;
    SQL.Add('Select * from CCCardTypes where CardType = :pCardType');
    parambyname('pCardType').AsString := Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CardType').AsString);
    open;
    PosPrt.PrintLine(Format('%26s',[POSDataMod.IBTempQry1.fieldbyname('FullName').asString])  + '   ' +
      //cwc...
//      Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',POSDataMod.IBCCBatchQuery.FieldbyName('FuelPrice').AsCurrency))]);
      Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', TotalAmount))]));
      //...cwc
    close;
  end;
  if POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.Commit;

  { And The Card Data ------------------}

  if (fmPOS.UseCISPEncryption(POSDataMod.IBCCBatchQuery.FieldbyName('HostID').AsInteger)) then
  begin
    if (Pos(PFSCHAR, POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString) > 0) then
      cardno := copy(POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString, 1, 4)
    else if (Pos('#', POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString) > 0) then
      cardno := copy(POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString, 1, 4)
    else
      cardno := 'UNKNOWN';
    PrintLine(Format('%-15s %20s',[Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CardType').AsString), cardno]));
//20070718a            Format('%5s',[Trim(fmEncryption.DecryptString(POSDataMod.IBCCBatchQuery.FieldbyName('ExpDate').AsString))]) ;
    x := Pos('#', POSDataMod.IBCCBatchQuery.FieldbyName('CardName').AsString);
    if (x > 0) then
      printline(copy(POSDataMod.IBCCBatchQuery.FieldbyName('CardName').AsString, 1, x - 1));
  end
  else
  begin
    StrPCopy(tStr, Trim(POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString));
    x := Length(Trim(POSDataMod.IBCCBatchQuery.FieldbyName('AcctNumber').AsString));
    for n := 0 to (x-5) do
      tStr[n] := 'X';

    PrintLine(Format('%-15s',[Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CardType').AsString)]) +
              Format('%-20s',[tStr]) +
              Format('%5s',[Trim(POSDataMod.IBCCBatchQuery.FieldbyName('ExpDate').AsString)])) ;

    PrintLine(Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CardName').AsString));
  end;

//  'Auth#00 bbsss In tttt    Approval nnnnnn'

  PrintLine('Auth#' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('AuthCode').AsString)
            + ' ' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('BatchNo').AsString)
                  + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('SeqNo').AsString)
        + ' In '  + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('TermTime').AsString)
                  + '    Approval ' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('ApprovalCode').AsString));


  if Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CPSData').AsString) <> '' then
    PrintLine('CPS ' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CPSData').AsString));

  if length(Trim(POSDataMod.IBCCBatchQuery.FieldbyName('Odometer').AsString)) > 0 then
    PrintLine('  Odometer ' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('Odometer').AsString));

  if length(Trim(POSDataMod.IBCCBatchQuery.FieldbyName('RefNo').AsString)) > 0 then
    PrintLine('  Reference ' + Trim(POSDataMod.IBCCBatchQuery.FieldbyName('RefNo').AsString));

  // Print any error (often just informational) message from credit server.
  if (ccAuthErrorCode <> '') then
  begin
    PrintLine('');
    PrintLine(ccAuthErrorCode);
    PrintLine('');
  end;


  //cwc...
  { If carwash purchased, then print access code ----------------------}
  if (CWAccessCode <> '') then
    begin
      //Build 23
      PrintLine('  Carwash Access Code:  ' + PrtBold + CWAccessCode + PrtMode);
      try
        CWExpDate := POSDataMod.IBCCBatchQuery.FieldbyName('CWExpDate').AsDateTime;
      except
        CWExpDate := 0.0;
      end;
      if (CWExpDate > 0.0) then
        PrintLine('Valid Through: ' + FormatDateTime('mm/dd/yy', CWExpDate));
      //...cwf
    end;
  //...cwc
  { And the Rest ----------------------}

   PosPrt.PrintSeq;

   PRINTING_REPORT := False;

   { All that is left is to Log the Printing of the Receipt, so the }
   { afterworld knows what happend to this Saleid...                }

   LogCCReceipt('Credit Card Receipt Reprint');

end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.CheckKey(var Msg : TWMPOSKey);
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
  Name:      TfmCardReceipt.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.ProcessKey;
begin

  if sKeyType = 'ENT' then
   Begin
     PrintCardReceipt;
     ModalResult := mrOk;
   end
  else if sKeyType = 'CLR' then
     ModalResult := mrCancel
  else if sKeyType = 'UP ' then
    begin
      POSDataMod.IBCCBatchQuery.Prior;
    end
  else if sKeyType = 'DN ' then
    begin
      POSDataMod.IBCCBatchQuery.Next;
    end
  else if sKeyType = 'EHL' then        { Emergency Halt }
     fmPOS.ProcessKeyEHL
  else if sKeyType = 'PMP' then        { Pump Number }
    begin
      fmPOS.ProcessKeyPMP(sKeyVal, sPreset);
    end
  else if sKeyType = 'PAL' then        { Pump Authorize All }
    fmPOS.ProcessKeyPAL
  else if sKeyType = 'PAT' then        { Pump Authorize }
    fmPOS.ProcessKeyPAT
  else if sKeyType = 'PHL' then        { Pump Halt }
    fmPOS.ProcessKeyPHL;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  POSDataMod.IBCCBatchQuery.Close;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  fmPOS.ClearEntryField;
  fmPOS.SetFocus;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.FormatAmount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TField; var Text: string; DisplayText: Boolean
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.FormatAmount(Sender: TField; var Text: string; DisplayText: Boolean);
begin
end;

procedure TfmCardReceipt.GetCardNameEvent(Sender: TField; var Text : string; DisplayText : boolean);
begin
  Text := Trim(POSDataMod.IBCCBatchQuery.FieldbyName('CardName').AsString);
  if pos('#', Text) > 0 then
     Text := LeftStr(Text, pos('#', Text) -1);
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.FormShow(Sender: TObject);
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  POSDataMod.IBCCBatchQuery.Open;
  {$IFDEF CISP_CODE}
 (POSDataMod.IBCCBatchQuery.FieldByName('CardName') As TStringField).OnGetText := GetCardNameEvent;
  {$ENDIF}
 (POSDataMod.IBCCBatchQuery.FieldByName('Gallons') As TNumericField).DisplayFormat := '##.000 ;##.000-';
 (POSDataMod.IBCCBatchQuery.FieldByName('GradePrice') As TNumericField).DisplayFormat := '#.000 ;#.000-';
 (POSDataMod.IBCCBatchQuery.FieldByName('FuelPrice') As TNumericField).DisplayFormat := '###.00 ;###.00-';

  case fmPOS.POSScreenSize of
  1:
    begin
      DBGrid1.Columns[1].Width := 215;
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
      DBGrid1.Columns[1].Width := 150;
      DBGrid1.Columns[2].Width := 20;
      DBGrid1.Columns[3].Width := 78;
      DBGrid1.Columns[4].Width := 78;
      DBGrid1.Columns[5].Width := 60;
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
  Name:      TfmCardReceipt.POSTouchButton1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.POSTouchButton1Click(Sender: TObject);
begin
  POSDataMod.IBCCBatchQuery.Prior;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.tbtnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.tbtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.tbtnSelectClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.tbtnSelectClick(Sender: TObject);
begin
  PrintCardReceipt;
  ModalResult := mrOk;
end;


{-----------------------------------------------------------------------------
  Name:      TfmCardReceipt.POSTouchButton2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmCardReceipt.POSTouchButton2Click(Sender: TObject);
begin
  POSDataMod.IBCCBatchQuery.Next;
end;

end.

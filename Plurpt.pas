{-----------------------------------------------------------------------------
 Unit Name: PluRpt
 Author:    Gary Whetton
 Date:      9/11/2003 3:10:43 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PluRpt;

{$I ConditionalCompileSymbols.txt}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, Grids, DBGrids, DB, ExtCtrls, POSMain, ElastFrm, POSBtn;

type
  TfmPLUSalesReport = class(TForm)
    SrcList: TListBox;
    SrcLabel: TLabel;
    DstList: TListBox;
    Label1: TLabel;
    ElasticForm1: TElasticForm;
    btnUp: TPOSTouchButton;
    btnDown: TPOSTouchButton;
    btnPrint: TPOSTouchButton;
    btnSelect: TPOSTouchButton;
    btnRemove: TPOSTouchButton;
    btnCancel: TPOSTouchButton;
    btnPrices: TPOSTouchButton;
    POSTouchButton1: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    btnSort: TPOSTouchButton;
    procedure InitLists(Sender: TObject);
    procedure PrintReport;
    procedure PrintPrices;
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnPricesClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
  private
    { Private declarations }
    procedure ProcessKey;
  public
    { Public declarations }
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
  end;

var
  fmPLUSalesReport: TfmPLUSalesReport;
  KeyBuff: array[0..200] of Char;
  BuffPtr: short;
  SearchOption : TLocateOptions;


  iListIdx: Integer;


implementation
uses POSdm, Reports, POSPrt, PosMisc, JCLStringLists, POSLog, DBInt, Math;

var
  // Keyboard Handling (GetAge)
  sKeyType  : string[3];
  sKeyVal   : string[5];
  sPreset   : string[10];

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.InitLists
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.InitLists(Sender: TObject);
begin
  SrcList.Items.Clear;
  DstList.Items.Clear;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Dept Order By DeptNo');
    Open;
    while not EOF do
    begin
      SrcList.Items.AddObject(Format( '%-30.30s %5s',[FieldByName('Name').AsString,
          FieldByName('DeptNo').AsString]), TObject(FieldByName('DeptNo').AsInteger) );
      Next;
    end;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  SrcList.ItemIndex := 0;

  case fmPOS.POSScreenSize of
  1:
    begin

      btnUp.Height := 60;
      btnDown.Height := 60;
      btnSelect.Height := 60;
      btnCancel.Height := 60;
      btnPrint.Height := 60;
      btnRemove.Height := 60;
      btnUp.Width := 60;
      btnDown.Width := 60;
      btnSelect.Width := 60;
      btnCancel.Width := 60;
      btnPrint.Width := 60;
      btnRemove.Width := 60;
      btnSelect.Glyph.LoadFromResourceName(HInstance, 'BIGCYN_SQ');
      btnRemove.Glyph.LoadFromResourceName(HInstance, 'BIGCYN_SQ');
      btnPrint.Glyph.LoadFromResourceName(HInstance, 'BIGRED_SQ');
      btnCancel.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnUp.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnDown.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnPrices.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      btnSort.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');

    end;

  2:
    begin

      btnUp.Height := 47;
      btnDown.Height := 47;
      btnSelect.Height := 47;
      btnCancel.Height := 47;
      btnPrint.Height := 47;
      btnRemove.Height := 47;
      btnUp.Width := 47;
      btnDown.Width := 47;
      btnSelect.Width := 47;
      btnCancel.Width := 47;
      btnPrint.Width := 47;
      btnRemove.Width := 47;

      btnSelect.Glyph.LoadFromResourceName(HInstance, 'SMLCYN_SQ');
      btnRemove.Glyph.LoadFromResourceName(HInstance, 'SMLCYN_SQ');
      btnPrint.Glyph.LoadFromResourceName(HInstance, 'SMLRED_SQ');
      btnCancel.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnUp.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnDown.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnPrices.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      btnSort.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');

    end;
  end;

end; {procedure InitLists}


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.CheckKey(var Msg : TWMPOSKey);
var
  sKeyChar: string[2];
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
    Inc(BuffPtr,1);
end;  {proc FormKeyPress}


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.ProcessKey;
begin

  if sKeyType = 'CLR' then          {Clear - Closes Form}
    Close

  else if (sKeyType = 'UP ') and (SrcList.ItemIndex > 0) then
    SrcList.ItemIndex := SrcList.ItemIndex - 1

  else if (sKeyType = 'DN ') and (SrcList.ItemIndex < SrcList.Items.Count-1) then
    SrcList.ItemIndex := SrcList.ItemIndex + 1

  else if (sKeyType = 'ERC') then    {Err Correct - Delete Last DstList Item}
    begin
      if DstList.Items.Count > 0 then
        begin
          iListIdx := DstList.ItemIndex;
          SrcList.Items.Add(DstList.Items[iListIdx]);
          DstList.Items.Delete(iListIdx);
          DstList.ItemIndex := DstList.Items.Count-1;
        end
      else
        MessageBeep(1);
    end  {Err Correct}

  else if (sKeyType = 'ENT') then   {Enter - Adds Items to DstList}
    begin
      if SrcList.Items.Count > 0 then
        begin
          iListIdx := SrcList.ItemIndex;
          DstList.Items.Add(SrcList.Items[iListIdx]);
          SrcList.Items.Delete(iListIdx);
          if iListIdx < SrcList.Items.Count-1 then
            SrcList.ItemIndex := iListIdx
          else
            SrcList.ItemIndex := SrcList.Items.Count-1
        end
      else
        MessageBeep(1);
    end {Enter Key}

  else if (sKeyType = 'PLR') then   {Print Last Receipt - Starts Report}
    if DstList.Items.Count > 0 then
      begin
        PrintReport;
        Close;
      end
    else
      fmPOS.POSError('No Categories Selectect!')
  else
    MessageBeep(1);

end;  {proc ProcessKey}


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.PrintReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.PrintReport;
var
  nDeptQty: Double;
  nDeptSales: Double;
  nTotalSales: Double;
  sDepts: shortstring;
  sLastDept: string[32];
  I: Integer;
  sName : string;
  DayId : integer;
  deptlist : TStringList;
begin
  nDeptQty := 0;;
  nDeptSales := 0;
  nTotalSales := 0;
  deptlist := TStringList.Create();
  for i := 0 to pred( DstList.Items.Count ) do
    deptlist.Add( IntToStr( Integer( DstList.Items.Objects[i] ) ) );
  {$IFDEF PLU_MOD_DEPT}  //20060717b
  sDepts := 'P.DeptNo In ('+ JCLStringListStrings(deptlist).join(',') + ')';
  {$ELSE}
  sDepts := 'D.DeptNo In ('+ JCLStringListStrings(deptlist).join(',') + ')';
  {$ENDIF}
  deptlist.Free;

  PRINTING_REPORT := True;
  if not POSDataMod.IBReportTransaction.InTransaction then
    POSDataMod.IBReportTransaction.StartTransaction;
  with POSDataMod.IBReportQuery do
  begin
    DayId := POSDataMod.GetDayId(Transaction);
    Close; SQL.Clear;
    {$IFDEF PLU_MOD_DEPT}    //20060717b
    SQL.Add('SELECT P.DeptNo, PS.PLUNo, PS.PLUModifier, Sum(PS.DlyCount) DlyCount, ');
    SQL.Add('Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(D.Name) DeptName ');
    SQL.Add('FROM (PLU P INNER JOIN PLUSHIFT PS ON P.PluNo = PS.PLUNo) ');
    SQL.Add('INNER JOIN DEPT D ON P.DeptNo = D.DeptNo ');
    SQL.Add('WHERE (PS.DlyCount <> 0) AND PLUModifier = 0  And ' + sDepts );
    SQL.Add('GROUP BY P.DeptNo, PS.PLUNo, P.Name, D.Name, PS.PLUModifier ');
    SQL.Add('UNION ');
    SQL.Add('SELECT PM.DeptNo, PS.PLUNo, PS.PLUModifier, Sum(PS.DlyCount) DlyCount, ');
    SQL.Add('Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(D.Name) DeptName  ');
    SQL.Add('FROM (PLU P INNER JOIN PLUSHIFT PS ON P.PluNo = PS.PLUNo) ');
    SQL.Add('INNER JOIN PLUMOD PM on ((PS.PLUNO = PM.PLUNO) AND (PS.PLUMODIFIER = PM.PLUMODIFIER)) ');
    SQL.Add('INNER JOIN DEPT D ON PM.DeptNo = D.DeptNo ');
    SQL.Add('WHERE PS.DayId=:pDayId and (PS.DlyCount <> 0) AND PLUModifier <> 0  And ' + sDepts );
    SQL.Add('GROUP BY PM.DeptNo, PS.PLUNo, P.Name, D.Name, PS.PLUModifier ');
    SQL.Add('ORDER BY 1,2 ');
    {$ELSE}
    SQL.Add('SELECT P.DeptNo, PS.PLUNo, PS.PLUModifier, Sum(PS.DlyCount) DlyCount, ');
    SQL.Add('Sum(PS.DlySales) DlySales, Min(P.Name) Name, Min(D.Name) DeptName ');
    SQL.Add('FROM (PLU P INNER JOIN PLUSHIFT PS ON P.PluNo = PS.PLUNo)');
    SQL.Add('INNER JOIN DEPT D ON P.DeptNo = D.DeptNo');
    SQL.Add('WHERE PS.DayId=:pDayId and (PS.DlyCount <> 0) And ' + sDepts );
    SQL.Add('GROUP BY P.DeptNo, PS.PLUNo, P.Name, D.Name, PS.PLUModifier');
    //SQL.Add('GROUP BY P.DeptNo, PS.PLUNo');
    SQL.Add('ORDER BY P.DeptNo, PS.PLUNo');
    {$ENDIF}
    ParamByName('pDayId').AsInteger := DayId;
    Open;

    ReportHdr('PLU Sales - Store');

    LineOut('Category / PLU           Qty    Sales Amt');
    LineOut('------------------------ ------ ----------');

    sLastDept := FieldByName('DeptName').AsString;
    LineOut(sLastDept);
    while not EOF do {Begin Processing Query}
    begin
      sName := '';
      if fieldbyname('PLUModifier').AsString = '0' then
        sName := fieldbyname('Name').AsString
      else
      begin
        if not POSDataMod.IBTempTrans1.InTransaction then
          POSDataMod.IBTempTrans1.StartTransaction;
        with POSDataMod.IBTempQry1 do
        begin
          close;SQL.Clear;
          SQL.Add('Select ModifierName as ModName from Modifier where ModifierGroup = :pModifierGroup ');
          SQL.Add('and ModifierNo = :pModifierNo');
          parambyname('pModifierGroup').AsString := POSDataMod.IBReportQuery.fieldbyname('PluNo').AsString;
          parambyname('pModifierNo').AsString := POSDataMod.IBReportQuery.fieldbyname('PLUModifier').AsString;
          open;
          if RecordCount > 0 then
            sName := Trim(FieldByName('ModName').AsString) + ' ' +  POSDataMod.IBReportQuery.FieldByName('Name').AsString
          else
            sName := POSDataMod.IBReportQuery.FieldByName('Name').AsString;
          close;
        end;
        if POSDataMod.IBTempTrans1.InTransaction then
          POSDataMod.IBTempTrans1.Commit;
      end;
      LineOut( Format( '%12.12s %-12.12s %4.4s %9.9s',[
       FieldByName('PluNo').AsString,
       sName,
       FormatFloat( '####', FieldByName('DlyCount').AsCurrency),
       FormatFloat('#####.00 ;#####.00-',FieldByName('DlySales').AsCurrency)]));

      nDeptSales := nDeptSales + FieldByName('DlySales').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      nDeptQty := nDeptQty + FieldByName('DlyCount').AsCurrency;
      Next;

      if EOF or (sLastDept <> FieldByName('DeptName').AsString) then
      begin {Print Dept Footer}
        LineOut( Format( '%12.12s %12.12s %4.4s %9.9s',['','Category Total:',
         FormatFloat( '####', nDeptQty),
         FormatFloat('#####.00 ;#####.00-',nDeptSales)]));
        if not EOF then
        begin {Reset & Print Dept Header}
          sLastDept := FieldByName('DeptName').AsString;
          nDeptQty   := 0;
          nDeptSales := 0;
          LineOut(''); LineOut(sLastDept);
        end;
      end; {sLastDept <> DeptName}

    end; {while not EOF}

    {Print Report Footer}
    LineOut('------------------------ ------ ----------');
    LineOut( Format( '%4.4s %14.14s %7s %12s',['','REPORT TOTAL:', '',
     FormatFloat('##,###.00 ;##,###.00-', nTotalSales)]));

    (*LineOut('---------------------- ------ ----------');
    LineOut( Format( '%4.4s %17.17s %6.6s %11.11s',['','REPORT TOTAL:', '',
     FormatFloat('##,###.00 ;##,###.00-', nTotalSales)]));*)

    ReportFtr;

    fmPOS.AssignTransNo;
    POSPrt.PrintSeq;
    LogRpt('PLU Sales Report');

    Close;
    SQL.Clear;

    PRINTING_REPORT := False;
  end; {with ReportQuery}
  if POSDataMod.IBReportTransaction.InTransaction then
    POSDataMod.IBReportTransaction.Commit;
end; {procedure PrintReport}


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnUpClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnUpClick(Sender: TObject);
begin
  if (SrcList.ItemIndex > 0) then
    SrcList.ItemIndex := SrcList.ItemIndex - 1;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnDownClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnDownClick(Sender: TObject);
begin
  if (SrcList.ItemIndex < SrcList.Items.Count-1) then
    SrcList.ItemIndex := SrcList.ItemIndex + 1;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnPrintClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnPrintClick(Sender: TObject);
begin
  if DstList.Items.Count > 0 then
  begin
    PrintReport;
    Close;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnCancelClick(Sender: TObject);
begin
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnSelectClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnSelectClick(Sender: TObject);
begin
  if SrcList.Items.Count > 0 then
    begin
      iListIdx := SrcList.ItemIndex;
      DstList.Items.AddObject(SrcList.Items[iListIdx], SrcList.Items.Objects[iListIdx]);
      SrcList.Items.Delete(iListIdx);
      if iListIdx < SrcList.Items.Count-1 then
        SrcList.ItemIndex := iListIdx
      else
        SrcList.ItemIndex := SrcList.Items.Count-1;
      if not DstList.Sorted then
        SortTStringsByIntegerObject(DstList.Items, 0, pred(DstList.Items.Count));
    end;

end;

procedure TfmPLUSalesReport.btnSelectAllClick(Sender: TObject);
begin
  while SrcList.Items.Count > 0 do
  begin
    DstList.Items.AddObject(SrcList.Items[0], SrcList.Items.Objects[0]);
    SrcList.Items.Delete(0);
  end;
  if not DstList.Sorted then
    SortTStringsByIntegerObject(DstList.Items, 0, pred(DstList.Items.Count));
end;

{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnRemoveClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnRemoveClick(Sender: TObject);
begin
  if DstList.Items.Count > 0 then
    begin
      iListIdx := DstList.ItemIndex;
      SrcList.Items.AddObject(DstList.Items[iListIdx], DstList.Items.Objects[iListIdx]);
      DstList.Items.Delete(iListIdx);
      DstList.ItemIndex := DstList.Items.Count-1;
      if not SrcList.Sorted then
        SortTStringsByIntegerObject(SrcList.Items, 0, pred( srclist.Items.Count ));
    end;
end;

procedure TfmPLUSalesReport.btnRemoveAllClick(Sender: TObject);
begin
  while DstList.Items.Count > 0 do
  begin
    SrcList.Items.AddObject(dstList.Items[0], dstList.Items.Objects[0]);
    DstList.Items.Delete(0);
  end;
  if not SrcList.Sorted then
    SortTStringsByIntegerObject(SrcList.Items, 0, pred( srclist.Items.Count ));
end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.btnPricesClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.btnPricesClick(Sender: TObject);
begin
  if DstList.Items.Count > 0 then
  begin
    PrintPrices;
    Close;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPLUSalesReport.PrintPrices
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPLUSalesReport.PrintPrices;
var
  Price : double;
  sDepts: shortstring;
  sLastDept: string[32];
  I: Integer;
  sName : string;
  sModifier : string;
  deptlist : TStringList;
  bexpired : boolean;
  expired : string;
  n, MixStartDate, MixExpirationDate, MixStartTime, MixEndTime : TDateTime;
begin
  n := Now();
  deptlist := TStringList.Create();
  for i := 0 to pred( DstList.Items.Count ) do
    deptlist.Add( IntToStr( Integer( DstList.Items.Objects[i] ) ) );
  {$IFDEF PLU_MOD_DEPT}  //20060717b
  sDepts := 'P.DeptNo In ('+ JCLStringListStrings(deptlist).join(',') + ')';
  {$ELSE}
  sDepts := 'D.DeptNo In ('+ JCLStringListStrings(deptlist).join(',') + ')';
  {$ENDIF}
  deptlist.Free;

  PRINTING_REPORT := True;
  if POSDataMod.IBReportTransaction.InTransaction then
    POSDataMod.IBReportTransaction.Commit;
  POSDataMod.IBReportTransaction.StartTransaction;

  with POSDataMod.IBRptSub1 do
  begin
    SQL.Clear;
    {$IFDEF PLU_MOD_DEPT}  //20060717b
      SQL.Add('Select PLUModifier, PLUPrice, PLUModifierGroup from PLUMod where ');
      SQL.Add('PLUNo = :pPLUNo and DeptNo = :pDeptNo');
    {$ELSE}
      SQL.Add('Select PLUModifier, PLUPrice from PLUMod where ');
      SQL.Add('PLUNo = :pPLUNo');
    {$ENDIF}
  end;
  with POSDataMod.IBRptSub2 do
  begin
    SQL.Clear;
    SQL.Add('Select ModifierName as ModName from Modifier where ModifierGroup = :pModifierGroup ');
    SQL.Add('and ModifierNo = :pModifierNo');
  end;
  with POSDataMod.IBRptSub3.SQL do
  begin
    Clear;
    Add('Select * from mixmatch where mmtype1=:pMMType1 and mmtype2=:pMMType2 ');
    Add('  and mmno1=:pMMNo1');
  end;
  with POSDataMod.IBReportQuery do
  begin
    Close; SQL.Clear;
    {$IFDEF PLU_MOD_DEPT}  //20060717b
    SQL.Add('SELECT D.DeptNo, P.PLUNo, P.ModifierGroup, P.Price, ');
    SQL.Add('P.Name Name, D.Name DeptName ');
    SQL.Add('FROM PLU P INNER JOIN DEPT D ON P.DeptNo = D.DeptNo ');
    SQL.Add('WHERE ModifierGroup = 0  And ' + sDepts );
    SQL.Add('UNION ');
    SQL.Add('SELECT PM.DeptNo, P.PLUNo, P.ModifierGroup, P.Price Price, ');
    SQL.Add('P.Name Name, D.Name DeptName ');
    SQL.Add('FROM PLU P INNER JOIN PLUMOD PM on ((P.PLUNO = PM.PLUNO) AND (P.MODIFIERGROUP = PM.PLUMODIFIERGROUP)) ');
    SQL.Add('INNER JOIN DEPT D ON PM.DeptNo = D.DeptNo ');
    SQL.Add('WHERE ModifierGROUP <> 0 And ' + sDepts );
    SQL.Add('ORDER BY 1,2');
    {$ELSE}
    SQL.Add('SELECT P.PLUNo, P.Name, P.Price, D.Name as DeptName, D.DeptNo from PLU P, Dept D ');
    //Build 18
    //SQL.Add('where ' + sDepts + ' and D.DeptNo = p.DeptNo Order by PLUNo');
    SQL.Add('where ' + sDepts + ' and D.DeptNo = p.DeptNo Order by D.DeptNo, P.PLUNo');
    //Build 18
    {$ENDIF}
    Open;

    ReportHdr('PLU Prices - Store');

    //LineOut('Category / PLU         Modif  Price    ');
    //LineOut('---------------------- ------ ----------');
    LineOut('Category / PLU           Modif  Price    ');
    LineOut('------------------------ ------ ----------');

    sLastDept := FieldByName('DeptName').AsString;
    LineOut(sLastDept);
    while not EOF do {Begin Processing Query}
    begin
      Price := POSDataMod.IBReportQuery.fieldbyname('Price').AsCurrency;
      sName := POSDataMod.IBReportQuery.fieldbyname('Name').AsString;
      with POSDataMod.IBRptSub1 do
      begin
        {$IFDEF PLU_MOD_DEPT}  //20060717b
        parambyname('pPLUNo').AsString :=
          POSDataMod.IBReportQuery.fieldbyname('PLUNo').AsString;
        parambyname('pDeptNo').AsString :=
          POSDataMod.IBReportQuery.fieldbyname('DeptNo').AsString;
        {$ELSE}
        parambyname('pPLUNo').AsString :=
          POSDataMod.IBReportQuery.fieldbyname('PLUNo').AsString;
        {$ENDIF}
        open;
        if RecordCount > 0 then
        begin
          while not EOF do
          begin
            price := POSDataMod.IBRptSub1.fieldbyname('PLUPrice').AsCurrency;
            with POSDataMod.IBRptSub2 do
            begin
              {$IFDEF PLU_MOD_DEPT}  //20060717b
              parambyname('pModifierGroup').AsString := POSDataMod.IBRptSub1.fieldbyname('PLUModifierGroup').AsString;
              {$ELSE}
              parambyname('pModifierGroup').AsString := POSDataMod.IBReportQuery.fieldbyname('PluNo').AsString;
              {$ENDIF}
              parambyname('pModifierNo').AsString := POSDataMod.IBRptSub1.fieldbyname('PLUModifier').AsString;
              open;
              if RecordCount > 0 then
                sModifier := Trim(FieldByName('ModName').AsString)
              else
                sModifier := '';
              close;
            end;
            LineOut( Format( '%12.12s %-12.12s %4.4s %9.9s',[
            POSDataMod.IBReportQuery.FieldByName('PluNo').AsString,
            sName,
            sModifier,
            FormatFloat('##,###.00 ;##,###.00-',Price)]));
            next;
          end;
        end
        else
        begin
          //LineOut( Format( '%4.4s %-17.17s %6.6s %11.11s',[
          sModifier := '';
          LineOut( Format( '%12.12s %-18.18s %4.4s %6.6s',[
          POSDataMod.IBReportQuery.FieldByName('PluNo').AsString,
          sName,
          sModifier,
          FormatFloat('###.00 ;###.00-',Price)]));
        end;
        Close;
        with POSDataMod.IBRptSub3 do
        begin
          parambyname('pMMType1').AsInteger := MM_PLU;
          parambyname('pMMType2').AsInteger := MM_NONE;
          parambyname('pMMNo1').AsCurrency := POSDataMod.IBReportQuery.FieldByName('PluNo').AsCurrency;
          open;
          while not EOF do
          begin
            DateTimeByName(PosDataMod.IBRptSub3, 'StartDate', MixStartDate, 0);
            DateTimeByName(PosDataMod.IBRptSub3, 'ExpirationDate', MixExpirationDate, MaxDouble);
            DateTimeByName(PosDataMod.IBRptSub3, 'StartTime', MixStartTime, 0);
            DateTimeByName(PosDataMod.IBRptSub3, 'EndTime', MixEndTime, 1);
            bexpired := not (between(n, MixStartDate, MixExpirationDate) and
                             between(n, MixStartTime, MixEndTime));
            if bexpired then expired := '**Expired**' else expired := '';
            LineOut( Format( '  Qty Disc %3d@   %13.13s   %9.9s',
                            [ FieldByName('Qty').AsInteger,
                              expired,
                              FormatFloat( '##,###.00 ;##,###.00-', FieldByName('Price').AsCurrency ) ] ) );
            next;
          end;
          close;
        end;
      end;
      Next;
      if EOF or (sLastDept <> POSDataMod.IBReportQuery.FieldByName('DeptName').AsString) then
      begin {Print Dept Footer}
        if not EOF then
        begin {Reset & Print Dept Header}
          sLastDept := FieldByName('DeptName').AsString;
          LineOut(''); LineOut(sLastDept);
        end;
      end; {sLastDept <> DeptName}
    end;
    POSDataMod.IBReportTransaction.Commit;


    {Print Report Footer}
    LineOut('------------------------ ------ ----------');

    POSPrt.PrintSeq;

    ReportFtr;

    fmPOS.AssignTransNo;
    //POSPrt.PrintSeq;
    LogRpt('PLU Price Report');

    //Close;
    //SQL.Clear;

    PRINTING_REPORT := False;
  end; {with ReportQuery}

end; {procedure PrintReport}

procedure TfmPLUSalesReport.btnSortClick(Sender: TObject);
begin
  Self.SrcList.Sorted := not Self.SrcList.Sorted;
  Self.DstList.Sorted := not Self.DstList.Sorted;
  if not SrcList.Sorted and ( SrcList.items.Count > 0 ) then
    SortTStringsByIntegerObject(SrcList.Items, 0, pred( SrcList.Items.Count ));
  if not DstList.Sorted and ( DstList.items.Count > 0 ) then
    SortTStringsByIntegerObject(DstList.Items, 0, pred( DstList.Items.Count ));

end;

end.

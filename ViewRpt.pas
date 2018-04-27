{-----------------------------------------------------------------------------
 Unit Name: ViewRpt
 Author:    Gary Whetton
 Date:      4/13/2004 4:23:53 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit ViewRpt;
{$I ConditionalCompileSymbols.txt}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RXCtrls, POSBtn, ElastFrm;

type
  TfmViewReport = class(TForm)
    RptListBox: TTextListBox;
    POSTouchButton1: TPOSTouchButton;
    POSTouchButton2: TPOSTouchButton;
    tbtnCancel: TPOSTouchButton;
    ElasticForm1: TElasticForm;
    procedure FormShow(Sender: TObject);
    procedure POSTouchButton1Click(Sender: TObject);
    procedure POSTouchButton2Click(Sender: TObject);
    procedure tbtnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    nViewReportType : short;
    nTerminalNo        : short;
    nShiftNo        : short;
    procedure BuildStore;
    procedure BuildPLU;
    procedure BuildHourly;
    procedure BuildJournal;
    procedure AddLine(const sLine: shortstring);
    procedure FormatLine(sCaption: shortstring; nQty: Double; nAmount: Double);
  end;

var
  fmViewReport: TfmViewReport;

implementation

uses POSDM, POSMain, RptUtils;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmViewReport.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.FormShow(Sender: TObject);
begin


  case nViewReportType of
  1   :  BuildStore;
  2   :  BuildPLU;
  3   :  BuildHourly;
  5     :  BuildJournal;
  end;
  RptListBox.ItemIndex := 0;


  case fmPOS.POSScreenSize of
  1:
    begin

      POSTouchButton1.Height := 60;
      POSTouchButton1.Width := 60;
      POSTouchButton2.Height := 60;
      POSTouchButton2.Width := 60;
      tbtnCancel.Height := 60;
      tbtnCancel.Width := 60;
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'BIGWHT_SQ');
      tBtnCancel.Glyph.LoadFromResourceName(HInstance, 'BIGRED_SQ');
    end;
  2 :
    begin

      POSTouchButton1.Height := 47;
      POSTouchButton1.Width := 47;
      POSTouchButton2.Height := 47;
      POSTouchButton2.Width := 47;
      tbtnCancel.Height := 47;
      tbtnCancel.Width := 47;
      POSTouchButton1.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      POSTouchButton2.Glyph.LoadFromResourceName(HInstance, 'SMLWHT_SQ');
      tBtnCancel.Glyph.LoadFromResourceName(HInstance, 'SMLRED_SQ');
    end;
  end;


end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.BuildStore
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.BuildStore;
var

  TotalTaxes, TotalDisc, TotalMM: Currency;
  nTotalQty   : Double;
  nTotalSales : Double;
  nGroupQty   : Double;
  nGroupSales : Double;

  sLastGrp : shortstring;
  sQtyStr : shortstring;
  HdrStr : string;
  InsideSales, FuelGallons : currency;

begin
  nTotalQty := 0;
  TotalTaxes := 0;
  TotalDisc := 0;
  TotalMM := 0;
  if not POSDataMod.IBReportTransaction.InTransaction then
    POSDataMod.IBReportTransaction.StartTransaction;
  with POSDataMod.IBReportQuery do
  begin
    close;SQL.Clear;
    SQL.Add('SELECT GEN_ID(TRANSNO_GEN,0) TransNumber, ');
    SQL.Add('Max(RESETCOUNT) ResetCount, ');
    SQL.Add('Max(BEGGT) BegGT, ');
    SQL.Add('Max(CURGT) CurGT, ');
    SQL.Add('Sum(DLYND) DlyND, ');
    SQL.Add('Sum(DLYDS) DlyDS, ');
    SQL.Add('Sum(DLYPREPAYCOUNT) DlyPrePayCount, ');
    SQL.Add('Sum(DLYPREPAYRCVD) DlyPrePayRcvd, ');
    SQL.Add('Sum(DLYPREPAYCOUNTUSED) DlyPrePayCountUsed, ');
    SQL.Add('Sum(DLYPREPAYUSED) DlyPrePayUsed, ');
    SQL.Add('Sum(DLYPREPAYRFNDCOUNT) DlyPrePayRfndCount, ');
    SQL.Add('Sum(DLYPREPAYRFND) DlyPrePayRfnd, ');
    SQL.Add('Sum(DLYTRANSCOUNT) DlyTransCount, ');
    SQL.Add('Sum(DLYITEMCOUNT) DlyItemCount, ');
    SQL.Add('Sum(DLYNOSALECOUNT) DlyNoSaleCount, ');
    SQL.Add('Sum(TILLTIMEOUTCOUNT) TillTimeOutCount, ');
    SQL.Add('Sum(STARTINGTILL) StartingTill, ');
    SQL.Add('Sum(DLYRETURNTAX) DlyReturnTax, ');
    SQL.Add('Sum(DLYNOTAX) DlyNoTax, ');
    SQL.Add('Sum(FUELCOUNT) FuelCount, ');
    SQL.Add('Sum(FUELAMOUNT) FuelAmount, ');
    SQL.Add('Sum(MDSECOUNT) MdseCount, ');
    SQL.Add('Sum(MDSEAMOUNT) MdseAmount, ');
    SQL.Add('Sum(FMCOUNT) FMCount, ');
    SQL.Add('Sum(FMAMOUNT) FMAmount, ');
    SQL.Add('Sum(DLYVOIDCOUNT) DlyVoidCount, ');
    SQL.Add('Sum(DLYVOIDAMOUNT) DlyVoidAmount, ');
    SQL.Add('Sum(DLYRTRNCOUNT) DlyRtrnCount, ');
    SQL.Add('Sum(DLYRTRNAMOUNT) DlyRtrnAmount, ');
    SQL.Add('Sum(DLYCANCELCOUNT) DlyCancelCount, ');
    SQL.Add('Sum(DLYCANCELAMOUNT) DlyCancelAmount, ');
    //cwh...
    SQL.Add('Sum(DLYCATCARWASHCOUNT) DlyCATCarwashCount, ');
    SQL.Add('Sum(DLYCATCARWASHAMOUNT) DlyCATCarwashAmount, ');
    //...cwh
    SQL.Add('Sum(DLYCATCOUNT) DlyCATCount, ');
    SQL.Add('Sum(DLYCATAMOUNT) DlyCATAmount FROM TOTALS ');
    if ((nTerminalNo = 0) and (nShiftNo = 0)) then
    begin
      SQL.Add('WHERE TotalNo = 0');
    end
    else if ((nTerminalNo > 0) and (nShiftNo = 0)) then
    begin
      SQL.Add('WHERE TerminalNo = ' + IntToStr(nTerminalNo) );
      SQL.Add('GROUP BY TerminalNo' );
      SQL.Add('ORDER BY TerminalNo' );
    end
    else if ((nTerminalNo = 0) and (nShiftNo > 0)) then
    begin
      SQL.Add('WHERE ShiftNo = ' + IntToStr(nShiftNo) );
      SQL.Add('GROUP BY ShiftNo' );
      SQL.Add('ORDER BY ShiftNo' );
    end
    else
    begin
      SQL.Add('WHERE ShiftNo = ' + IntToStr(nShiftNo) + ' And TerminalNo = ' + IntToStr(nTerminalNo) );
    end;
    Open;

    if EOF and BOF then
    begin
      if POSDataMod.IBReportTransaction.InTransaction then
        POSDataMod.IBReportTransaction.Commit;
      exit;
    end;

    HdrStr := 'Daily Sales - ';
    if (nTerminalNo = 0) and (nShiftNo = 0) then
      HdrStr := HdrStr + 'Store'
    else
    begin
      if nTerminalNo > 0 then
        HdrStr := HdrStr + ' Terminal# ' + IntToStr(nTerminalNo);
      if nShiftNo > 0 then
        HdrStr := HdrStr + ' Shift# ' + IntToStr(nShiftNo) + ' ';

    end;

    AddLine(HdrStr);
    AddLine('________________________________________________________________');
    AddLine('');

//    AddLine ('Reset Count ' + Format('%6.6d', [FieldByName('ResetCount').AsInteger]) );

    AddLine( Format( '%-40.40s %3s %19s',['Beginning Grand Total',
      '',
      FormatFloat('###,###,###,###.00 ;###,###,###,###.00-',FieldByName('BegGT').AsCurrency)]));

    AddLine( Format( '%-40.40s %3s %19s',['Current Grand Total',
      '',
      FormatFloat('###,###,###,###.00 ;###,###,###,###.00-',FieldByName('CurGT').AsCurrency)]));


    FormatLine('Net Daily Sales', 0, FieldByName('DlyND').AsCurrency);
    FormatLine('Total Daily Sales', 0, FieldByName('DlyDS').AsCurrency);
    FormatLine('# of Transactions', FieldByName('DlyTransCount').AsInteger, 0);
    FormatLine('# of Items', FieldByName('DlyItemCount').AsInteger, 0);
    FormatLine('# of No Sales', FieldByName('DlyNoSaleCount').AsInteger, 0);
    FormatLine('# of Till Timeouts', FieldByName('TillTimeOutCount').AsInteger, 0);
    if nShiftNo > 0 then
      FormatLine('Starting Till', 0, FieldByName('StartingTill').AsCurrency);

    FormatLine('Prepay Sales Rcvd', FieldByName('DlyPrePayCount').AsInteger,
     FieldByName('DlyPrePayRcvd').AsCurrency);
    FormatLine('Prepay Sales Used', FieldByName('DlyPrePayCountUsed').AsInteger,
     FieldByName('DlyPrePayUsed').AsCurrency);
    FormatLine('Prepay Sales Rfnd', FieldByName('DlyPrePayRfndCount').AsInteger,
     FieldByName('DlyPrePayRfnd').AsCurrency);

    //cwh...
    //Build 23
    if Setup.CarWashInterfaceType > 1 then
    begin
      AddLine('');
      FormatLine('PAP Carwashes',0, FieldByName('DlyCATCarwashAmount').AsCurrency);
      FormatLine('# PAP Carwashes', FieldByName('DlyCATCarwashCount').AsInteger, 0);
      AddLine('');
    end;
    //Build 23
    //...cwh

    AddLine('');
    FormatLine('Outside Sales',0, FieldByName('DlyCATAmount').AsCurrency);
    FormatLine('# Outside Sales', FieldByName('DlyCATCount').AsInteger, 0);
    AddLine('');
    AddLine('');
    FormatLine('Mdse Only Sales', FieldByName('MdseCount').AsInteger, FieldByName('MdseAmount').AsCurrency);
    FormatLine('Fuel Only Sales', FieldByName('FuelCount').AsInteger, FieldByName('FuelAmount').AsCurrency);
    FormatLine('F&M  Only Sales', FieldByName('FMCount').AsInteger, FieldByName('FMAmount').AsCurrency);
    AddLine('');
    AddLine('Taxable Sales');

    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close; SQL.Clear;
      SQL.Add('SELECT TS.TaxNo, Sum(TS.DlyCount) DlyCount, ' +
       //20070227i...
       'Sum(TS.FSTaxExemptSales) FSTaxExemptSales, ' +
       //...20070227i
       'Sum(TS.DlyTaxableSales) DlyTaxableSales, Min(T.Name) Name,' +
       'Sum(TS.DlyTaxCharged) DlyTaxCharged, Min(T.Rate) Rate FROM TaxShift TS, Tax T ' +
       'WHERE (TS.TaxNo = T.TaxNo)');
      if nTerminalNo > 0 then
        SQL.Add('And (TS.TerminalNo = ' + IntToStr(nTerminalNo) + ') ');
      if nShiftNo > 0 then
        SQL.Add('And (TS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY TS.TaxNo');
      SQL.Add('ORDER BY TS.TaxNo');
      Open;
      while Not EOF do
      begin
        if FieldByName('DlyCount').AsInteger > 0 then
        begin
          FormatLine(FieldByName('Name').AsString + ' Taxable Sales', 0, FieldByName('DlyTaxableSales').AsCurrency);
         //20070227i...
          FormatLine(FieldByName('Name').AsString + ' Exempt', 0, FieldByName('FSTaxExemptSales').AsCurrency);
         //...20070227i
          FormatLine(FieldByName('Name').AsString + ' Tax Collected', 0, FieldByName('DlyTaxCharged').AsCurrency);
          TotalTaxes := TotalTaxes + FieldByName('DlyTaxCharged').asCurrency;
        end;
        Next;
      end;  {while Not EOF}
      Close;
    end; {with TempQuery}

    // Print Total Taxes Charged
    AddLine('');
    FormatLine('Total Taxes Charged', 0, TotalTaxes);
    AddLine('');

    FormatLine('Non Taxable Sales',0, FieldByName('DlyNoTax').AsCurrency);
    {$IFDEF HUCKS_REPORTS}
    AddLine('');
    FormatLine('*** Voids ***',FieldByName('DlyVoidCount').AsInteger,
      FieldByName('DlyVoidAmount').AsCurrency);
    AddLine('');
    {$ELSE}
    FormatLine('Voids',FieldByName('DlyVoidCount').AsInteger,
      FieldByName('DlyVoidAmount').AsCurrency);
    {$ENDIF}
    FormatLine('Returns',FieldByName('DlyRtrnCount').AsInteger, FieldByName('DlyRtrnAmount').AsCurrency);
    FormatLine('Cancels',FieldByName('DlyCancelCount').AsInteger,
      FieldByName('DlyCancelAmount').AsCurrency);

    AddLine('');
    AddLine('Discounts');
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      {$IFDEF PDI_PROMOS}
      //20070312 Added Count of PROMONO
//      SQL.Add('SELECT PS.PromoNo, Sum(PS.DlyCount) DlyCount, ' +
      SQL.Add('SELECT PS.PromoNo, Count(PS.PromoNo) PromoCount, Sum(PS.DlyCount) DlyCount, ' +
       'Sum(PS.DlyAmount) DlyAmount, Min(P.PromoName) Name FROM PromoShift PS, Promotions P ' +
       'WHERE (PS.PromoNo = P.PromoNo)');
      if nTerminalNo > 0 then
        SQL.Add('And (PS.TerminalNo = ' + IntToStr(nTerminalNo) + ') ');
      if nShiftNo > 0 then
        SQL.Add('And (PS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY PS.PromoNo');
      SQL.Add('ORDER BY PS.PromoNo');
      {$ELSE}
      SQL.Add('SELECT DS.DiscNo, Sum(DS.DlyCount) DlyCount, ' +
       'Sum(DS.DlyAmount) DlyAmount, Min(D.Name) Name FROM DiscShift DS, Disc D ' +
       'WHERE (DS.DiscNo = D.DiscNo)');
      if nTerminalNo > 0 then
        SQL.Add('And (DS.TerminalNo = ' + IntToStr(nTerminalNo) + ') ');
      if nShiftNo > 0 then
        SQL.Add('And (DS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY DS.DiscNo');
      SQL.Add('ORDER BY DS.DiscNo');
      {$ENDIF}

      Open;
      while Not EOF do
      begin
        if FieldByName('DlyCount').AsInteger > 0 then
        begin
          //20070312... Adjust counts and amounts for multi List Promotions
          {$IFDEF PDI_PROMOS}
          FormatLine(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger / FieldByName('PromoCount').AsInteger, FieldByName('DlyAmount').AsCurrency / FieldByName('PromoCount').AsInteger);
          TotalDisc := TotalDisc + FieldByName('DlyAmount').AsCurrency / FieldByName('PromoCount').AsInteger;
          {$ELSE}
          FormatLine(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger, FieldByName('DlyAmount').AsCurrency);
          TotalDisc := TotalDisc + FieldByName('DlyAmount').AsCurrency;
          {$ENDIF}
          //...20070312
        end;
        Next;
      end;  {while Not EOF}
      Close;
    end; {with TempQuery}

    AddLine('');
//20070305a (moved below)   {$IFNDEF PDI_PROMOS}
    if FieldByName('DlyDS').AsCurrency <> 0 then
      AddLine('Discount as % of Total Sales = ' +
       FormatFloat('##0.000%', ( Abs(TotalDisc)/ FieldByName('DlyDS').AsCurrency) * 100) );  //20070227h (mult. value by 100)
    AddLine('');

    {$IFNDEF PDI_PROMOS}  //20070305a (moved from above)
    AddLine('Mix Match');
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('SELECT MS.MMNo, Sum(MS.DlyCount) DlyCount, ' +
       'Sum(MS.DlyAmount) DlyAmount, Min(MM.Name) Name FROM MixMatchShift MS, MixMatch MM ' +
       'WHERE (MS.MMNo = MM.MMNo)');
      if nTerminalNo > 0 then
        SQL.Add('And (MS.TerminalNo = ' + IntToStr(nTerminalNo) + ') ');
      if nShiftNo > 0 then
        SQL.Add('And (MS.ShiftNo = ' + IntToStr(nShiftNo) + ') ');
      SQL.Add('GROUP BY MS.MMNo');
      SQL.Add('ORDER BY MS.MMNo');

      Open;
      while Not EOF do
      begin
        if FieldByName('DlyCount').AsInteger > 0 then
        begin
          FormatLine(FieldByName('Name').AsString, FieldByName('DlyCount').AsInteger, FieldByName('DlyAmount').AsCurrency);
          TotalMM := TotalDisc + FieldByName('DlyAmount').AsCurrency;
        end;
        Next;
      end;  {while Not EOF}
      Close;
    end; {with TempQuery}

    AddLine('');
    if FieldByName('DlyDS').AsCurrency <> 0 then
      AddLine('Mix Match as % of Total Sales = ' +
       FormatFloat('##0.000%', ( Abs(TotalMM)/ FieldByName('DlyDS').AsCurrency)) );

    AddLine('');
    if FieldByName('DlyDS').AsCurrency <> 0 then
      AddLine('TL Disc as % of Total Sales = ' +
       FormatFloat('##0.000%', ( Abs(TotalDisc + TotalMM) / FieldByName('DlyDS').AsCurrency)) );
    {$ENDIF}
    InsideSales := POSDataMod.IBReportQuery.FieldByName('DlyND').AsCurrency;

    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('select sum(dlysales) fuelsales from depshift ds, dept d, grp g where ds.deptno = d.deptno');
      SQL.Add('and d.grpno = g.grpno and g.fuel = 1');
      Open;
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('FuelSales').AsCurrency;
      Close;
    end;

    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('select sum(dlysales) LotterySales from depshift ds, dept d where ds.deptno = d.deptno');
      SQL.Add('and d.grpno = 100');
      Open;
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('LotterySales').AsCurrency;
      Close;
    end;

    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('select sum(dlysales) MoneyOrderSales from depshift ds, dept d where ds.deptno = d.deptno');
      SQL.Add('and d.grpno = 500');
      Open;
      if NOT Eof then
        InsideSales := InsideSales - FieldByName('MoneyOrderSales').AsCurrency;
      Close;
    end;
    FormatLine('Inside Sales',  0, InsideSales);
    FuelGallons := 0;

    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('select sum(dlycount) FuelGallons from depshift ds, dept d where ds.deptno = d.deptno');
      SQL.Add('and d.grpno = 99');
      Open;
      if NOT Eof then
        FuelGallons := FieldByName('FuelGallons').AsCurrency;
      Close;
    end;
    FormatLine('Fuel Gallons ', 0, FuelGallons);
    Close;SQL.Clear;
  end; {with POSDataMod.ReportQuery}
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;

  with POSDataMod.IBReportQuery do
  begin
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT D.GrpNo, DS.DeptNo, Min(D.Name) DeptName, ' +
     'Min(G.Name) GrpName, Sum(DS.DlyCount) DlyCount, ' +
     'Sum(DS.DlySales) DlySales ' +
     'FROM DEPSHIFT DS, DEPT D, GRP G ' +
     'WHERE DS.DeptNo = D.DeptNo And D.GrpNo = G.GrpNo And DS.DlySales <> 0');
    if nTerminalNo > 0 then
      SQL.Add('And DS.TerminalNo = ' + IntToStr(nTerminalNo));
    if nShiftNo > 0 then
      SQL.Add('And DS.ShiftNo = ' + IntToStr(nShiftNo));
    SQL.Add('GROUP BY D.GrpNo, DS.DeptNo');
    SQL.Add('ORDER BY D.GrpNo, DS.DeptNo');
    Open;

    sLastGrp := FieldByName('GrpName').AsString;

    AddLine('');
    AddLine('Group Sales');

    AddLine('Group / Category                             Qty       Sales Amt');
          // 1234567890123456789012345678901234567890 12345678901 12345678901'
    AddLine('________________________________________________________________');

    AddLine( sLastGrp );
    nGroupQty   := 0;
    nGroupSales := 0;
    nTotalSales := 0;
    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('GrpNo').AsInteger = 1 then  {Qty Format String 1=Fuel}
        sQtyStr := '###,###.000'
      else
        sQtyStr := '###,###,###';

      AddLine( Format( '%-40.40s %11s %11s',[FieldByName('DeptName').AsString,
       FormatFloat(sQtyStr, FieldByName('DlyCount').AsCurrency),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nGroupQty   := nGroupQty + FieldByName('DlyCount').AsCurrency;
      nGroupSales := nGroupSales + FieldByName('DlySales').AsCurrency;
      nTotalQty   := nTotalQty + FieldByName('DlyCount').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;

      Next;

      {Check to Print Group Footer/Header}
      if EOF or (sLastGrp <> FieldByName('GrpName').AsString) then {End Of Group}
      begin {Print Group Footer}
        AddLine( Format( '%40.40s %11s %11s',['Group Total:',
         FormatFloat( sQtyStr, nGroupQty),
         FormatFloat('###,###.00 ;###,###.00-',nGroupSales)]));

        if not EOF then
        begin {Reset & Print Group Header}
          sLastGrp := FieldByName('GrpName').AsString;
          nGroupQty   := 0;
          nGroupSales := 0;
          AddLine('');
          AddLine(sLastGrp);
        end;
      end; {sLastGrp <> GrpName}

    end; {while not EOF}
    {Print Report Footer}

    AddLine('');
    AddLine( Format( '%40.40s %11s %11s',['TOTAL GROUP SALES:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    Close;
    SQL.Clear;
  end; {with ReportQuery}

  with POSDataMod.IBReportQuery do
  begin
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT DS.DeptNo, Min(D.Name) DeptName, Sum(DS.DlyCount) DlyCount,');
    SQL.Add('Sum(DS.DlySales) DlySales');
    SQL.Add('FROM DepShift DS, Dept D');
    SQL.Add('WHERE DS.DeptNo = D.DeptNo');
    if nTerminalNo > 0 then
      SQL.Add('And DS.TerminalNo = ' + IntToStr(nTerminalNo));
    if nShiftNo > 0 then
      SQL.Add('And DS.ShiftNo = ' + IntToStr(nShiftNo));
    SQL.Add('GROUP BY DS.DeptNo');
    SQL.Add('ORDER BY DS.DeptNo');
    Open;

    AddLine('');
    AddLine('Category Sales');
    AddLine('');

    AddLine('  #            Description                   Qty       Sales Amt');
          // 1234567890123456789012345678901234567890 12345678901 12345678901'
    AddLine('________________________________________________________________');

    nTotalSales := 0;

    while not EOF do {Begin Processing Query}
    begin

      AddLine( Format( '%4d %-35.35s %11s %11s',[FieldByName('DeptNo').AsInteger,
       FieldByName('DeptName').Value,
       FormatFloat( '###,### ; ###,###-', FieldByName('DlyCount').AsInteger),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;

      Next;

    end; {while not EOF}
    {Print Report Footer}
    AddLine('________________________________________________________________');
    AddLine( Format( '     %35.35s %11s %11s',['TOTAL CATEGORY SALES:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    Close;
    SQL.Clear;
  end; {with ReportQuery}

  with POSDataMod.IBReportQuery do
  begin
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT MS.MediaNo, Min(M.Name) Name,');
    SQL.Add('Sum(MS.DlyCount) DlyCount, Sum(MS.DlySales) DlySales');
    SQL.Add('FROM MEDSHIFT MS, MEDIA M');
    SQL.Add('WHERE MS.MediaNo = M.MediaNo');
    if nTerminalNo > 0 then
       SQL.Add('And MS.TerminalNo =' + IntToStr(nTerminalNo));
    if nShiftNo > 0 then
       SQL.Add('And MS.ShiftNo =' + IntToStr(nShiftNo));
    SQL.Add('GROUP BY MS.MediaNo');
    SQL.Add('ORDER BY MS.MediaNo');
    Open;

    AddLine('');
    AddLine('Tender Media Sales');
    AddLine('');

    AddLine('  #            Description                   Qty       Sales Amt');
          // 1234567890123456789012345678901234567890 12345678901 12345678901'
    AddLine('________________________________________________________________');

    nTotalSales := 0;
    while not EOF do {Begin Processing Query}
    begin

      AddLine( Format( '%4d %-35.35s %11s %11s',[FieldByName('MediaNo').AsInteger,
       FieldByName('Name').Value,
       FormatFloat( '###,### ; ###,###-', FieldByName('DlyCount').AsInteger),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      Next;

    end; {while not EOF}
    {Print Report Footer}
    AddLine('________________________________________________________________');
    AddLine( Format( '     %35.35s %11s %11s',['TOTAL MEDIA SALES:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    Close;
    SQL.Clear;
  end; {with ReportQuery}

  with POSDataMod.IBReportQuery do
  begin
    // Build SQL Statement
    SQL.Clear;
    SQL.Add('SELECT BS.BankNo, Min(B.Name) Name,');
    SQL.Add('Sum(BS.DlyCount) DlyCount, Sum(BS.DlySales) DlySales');
    SQL.Add('FROM BANKSHIFT BS, BANKFUNC B');
    SQL.Add('WHERE BS.BankNo = B.BankNo');
    if nTerminalNo > 0 then
       SQL.Add('And BS.TerminalNo =' + IntToStr(nTerminalNo));
    if nShiftNo > 0 then
       SQL.Add('And BS.ShiftNo =' + IntToStr(nShiftNo));
    SQL.Add('GROUP BY BS.BankNo');
    SQL.Add('ORDER BY BS.BankNo');

    Open;

    AddLine('');
    AddLine('Bank Function Totals');
    AddLine('');

    AddLine('  #            Description                   Qty       Sales Amt');
          // 1234567890123456789012345678901234567890 12345678901 12345678901'
    AddLine('________________________________________________________________');

    nTotalSales := 0;

    while not EOF do {Begin Processing Query}
    begin

      AddLine( Format( '%4d %-35.35s %11s %11s',[FieldByName('BankNo').AsInteger,
       FieldByName('Name').AsString,
       FormatFloat( '###,### ;###,###-', FieldByName('DlyCount').AsInteger),
       FormatFloat('###,###.00 ;###,###.00-',FieldByName('DlySales').AsCurrency)]));

      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      Next;

    end; {while not EOF}
    {Print Report Footer}
    AddLine('________________________________________________________________');
    AddLine( Format( '     %35.35s %11s %11s',['TOTAL BANK FUNCTION:', '',
     FormatFloat('###,###.00 ;###,###.00-', nTotalSales)]));

    Close;
    SQL.Clear;
  end; {with ReportQuery}
  if POSDataMod.IBReportTransaction.InTransaction then
    POSDataMod.IBReportTransaction.Commit;
end; {procedure DailySalesReport}


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.FormatLine
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: sCaption: shortstring; nQty: Double; nAmount: Double
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.FormatLine(sCaption: shortstring; nQty: Double; nAmount: Double);
begin
  AddLine( Format('%-40.40s %11s %11s',[sCaption,
   FormatFloat('###,### ; ###,###-', nQty),
   FormatFloat('###,###.00 ;###,###.00-', nAmount)]));
end; {procedure FormatLine}


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.AddLine
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const sLine: shortstring
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.AddLine(const sLine: shortstring);
begin
  RptListBox.Items.Add(sLine);
end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.BuildPLU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.BuildPLU;

var
  nDeptQty: Double;
  nDeptSales: Double;
  nTotalSales: Double;
  sLastDept: string[32];
  sNameStr : string;
  HdrStr : string;
  DayId : integer;
begin
  if not POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.StartTransaction;
  with POSDataMod.IBReportQuery do
  begin
    DayId := POSDataMod.GetDayId(Transaction);
    SQL.Clear;
    SQL.Add('SELECT DeptNo, PLUNo, Sum(DlyCnt) As DlyCount,');
    SQL.Add('Sum(DlySls) AS DlySales, min(PName) as Name, min(DNAME) as DeptName, Min(Modifiername) As ModifierName ');
    {$IFDEF PLU_MOD_DEPT}  //20060717b
    SQL.Add('From PLUReportDeptMod ');
    {$ELSE}
    SQL.Add('From PLUReport ');
    {$ENDIF}
    AddTSsql(SQL, {$IFDEF PLU_MOD_DEPT}'PLUReportDeptMod'{$ELSE}'PLUReport'{$ENDIF}, nTerminalNo, nShiftNo, fmPOS.ConsolidateShifts);
    SQL.Add('GROUP BY DeptNo, PLUNo, PName, DName, ModifierName');
    //SQL.Add('GROUP BY DeptNo, PLUNo');
    SQL.Add('ORDER BY DeptNo, PLUNo');
    AddTSparams(POSDataMod.IBRptSQL03Main, nTerminalNo, nShiftNo);
    ParamByName('pDayId').AsInteger := DayId;
    Open;

    HdrStr := 'PLU Sales - ';
    if (nTerminalNo = 0) and (nShiftNo = 0) then
      HdrStr := HdrStr + 'Store'
    else
      begin
        if nTerminalNo > 0 then
          HdrStr := HdrStr + ' Terminal# ' + IntToStr(nTerminalNo);
        if nShiftNo > 0 then
          HdrStr := HdrStr + ' Shift# ' + IntToStr(nShiftNo) + ' ';

      end;
    AddLine(HdrStr);


//           0123456789012345678901234567890123456789
    AddLine('');
    AddLine('Category / PLU                     Qty    Sales Amt');
    AddLine('___________________________________________________');
//           123456 1234567890123456789012345 123456 12345678901
//                                  99,999 999,999.99-
    nDeptQty := 0;
    nDeptSales  := 0;
    nTotalSales := 0;
    sLastDept := FieldByName('DeptName').AsString;
    AddLine(sLastDept);

    while not EOF do {Begin Processing Query}
    begin
      if FieldByName('ModifierName').AsString = '' then
        sNameStr := FieldByName('Name').AsString
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
          parambyname('pModifierNo').AsString := POSDataMod.IBReportQuery.fieldbyname('ModifierName').AsString;
          open;
          if RecordCount > 0 then
            sNameStr := Trim(FieldByName('ModName').AsString) + ' ' +  POSDataMod.IBReportQuery.FieldByName('Name').AsString
          else
            sNameStr := POSDataMod.IBReportQuery.FieldByName('Name').AsString;
          close;
          //sNameStr := Trim(FieldByName('ModifierName').AsString) + ' ' +  FieldByName('Name').AsString;
        end;
        if POSDataMod.IBTempTrans1.InTransaction then
          POSDataMod.IBTempTrans1.Commit;
      end;


      AddLine( Format( '%6.6s %-25.25s %6.6s %11.11s',[
       FieldByName('PluNo').AsString,
       sNameStr,
       FormatFloat( '##,###', FieldByName('DlyCount').AsCurrency),
       FormatFloat('##,###.00 ;##,###.00-',FieldByName('DlySales').AsCurrency)]));

      nDeptSales := nDeptSales + FieldByName('DlySales').AsCurrency;
      nTotalSales := nTotalSales + FieldByName('DlySales').AsCurrency;
      nDeptQty := nDeptQty + FieldByName('DlyCount').AsCurrency;
      Next;

      if EOF or (sLastDept <> FieldByName('DeptName').AsString) then
      begin {Print Dept Footer}
        AddLine( Format( '%6.6s %25.25s %6.6s %11.11s',['','Category Total:',
         FormatFloat( '##,###', nDeptQty),
         FormatFloat('##,###.00 ;##,###.00-',nDeptSales)]));

        if not EOF then
        begin {Reset & Print Dept Header}
          sLastDept := FieldByName('DeptName').AsString;
          nDeptQty   := 0;
          nDeptSales := 0;
          AddLine(''); AddLine(sLastDept);
        end;
      end; {sLastDept <> DeptName}

    end; {while not EOF}

    {Print Report Footer}
    AddLine('___________________________________________________');

    AddLine( Format( '%6.6s %25.25s %6s %11s',['','REPORT TOTAL:', '',
     FormatFloat('##,###.00 ;##,###.00-', nTotalSales)]));

    Close;

    SQL.Clear;
  end; {with ReportQuery}
  if POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.BuildHourly
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.BuildHourly;
var
  nTotalTrans : Double;
  nTotalSales : Double;
  TmpStr : string;
begin
  nTotalTrans := 0;
  nTotalSales := 0;
  if not POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.StartTransaction;
  with POSDataMod.IBReportQuery do
  begin
    SQL.Clear;

    SQL.Add('SELECT H.HourNo, ');
    SQL.Add('Sum(H.DlyCount) DlyCount, Sum(H.DlySales) DlySales');
    SQL.Add('FROM HOURLYSHIFT H');
    SQL.Add('WHERE DlyCount <> 0 ');
    if nTerminalNo > 0 then
      SQL.Add('And H.TerminalNo = ' + IntToStr(nTerminalNo));
    if nShiftNo > 0 then
      SQL.Add('And H.ShiftNo =' + IntToStr(nShiftNo));
    SQL.Add('GROUP BY H.HourNo');
    SQL.Add('ORDER BY H.HourNo');
    Open;

    TmpStr := 'Hourly Sales - ';
    if (nTerminalNo = 0) and (nShiftNo = 0) then
      TmpStr := TmpStr + 'Store'
    else
      begin
        if nTerminalNo > 0 then
          TmpStr := TmpStr + 'Terminal ' + IntToStr(nTerminalNo) + ' ';
        if nShiftNo > 0 then
          TmpStr := TmpStr + 'Shift ' + IntToStr(nShiftNo) ;
      end;

    AddLine(TmpStr);


    AddLine('Time Start   # of Trans  Sales Amt');
    AddLine('-----------  ----------  ------------');

    while not EOF do
    begin
      { Format Record }
      AddLine( FormatDateTime('hh:mm AM/PM', FieldByName('HourNo').Value) +
       Format('  %10s  %12s',[FormatFloat('##,###,##0', FieldByName('DlyCount').Value),
       FormatFloat('#,###,###.00 ;#,###,###.00-',FieldByName('DlySales').Value)]));

      nTotalTrans := nTotalTrans + FieldByName('DlyCount').Value;
      nTotalSales := nTotalSales + FieldByName('DlySales').Value;
      Next;
    end;

    AddLine( '-----------  ----------  ------------');
    AddLine( Format('   TOTAL: %10s  %12s',[FormatFloat('##,###,##0', nTotalTrans),
     FormatFloat('#,###,###.00 ;#,###,###.00-',nTotalSales)]));

    Close;
    SQL.Clear;
  end; {with ReportQuery}
  if POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.Commit;
end; {procedure HourlySalesReport}


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.BuildJournal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.BuildJournal;
begin
  if not POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.StartTransaction;
  with POSDataMod.IBReportQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT Data FROM POSLOG ORDER BY LOGID');
    Open;
    while not EOF do
    begin
      { Format Record }
      RptListBox.Items.Add(FieldByName('Data').AsString);
      Next;
    end;
    Close;
    SQL.Clear;
  end; {with ReportQuery}
  if POSDataMod.IBReportTransaction.InTransaction then
      POSDataMod.IBReportTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.POSTouchButton1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.POSTouchButton1Click(Sender: TObject);
begin

  if RptListBox.ItemIndex > 0 then
    RptListBox.ItemIndex := RptListBox.ItemIndex - 1;

end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.POSTouchButton2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.POSTouchButton2Click(Sender: TObject);
begin

  if RptListBox.ItemIndex <  (RptListBox.Items.Count - 1) then
    RptListBox.ItemIndex := RptListBox.ItemIndex + 1;

end;


{-----------------------------------------------------------------------------
  Name:      TfmViewReport.tbtnCancelClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmViewReport.tbtnCancelClick(Sender: TObject);
begin
  RptListBox.Clear;
  Close;

end;

end.

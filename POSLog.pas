{-----------------------------------------------------------------------------
 Unit Name: POSLog
 Author:    Gary Whetton
 Date:      9/11/2003 3:15:54 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSLog;
{$I ConditionalCompileSymbols.txt}

interface

uses
  Classes;

procedure LogSale(const PostSaleList : TList);
procedure LogNoSale;
procedure LogCancel;
procedure LogSuspend;

procedure LogRpt(RptName: string) ;
procedure LogCCReceipt(str : string) ;
procedure LogPOSStart;
procedure LogSignOnOff(SignOn : boolean);

procedure LogCATReset(ResetMsg : string);
procedure LogCreditReset;
procedure LogFuelReset;
procedure LogPumpRefresh(PumpNo : string);
procedure LogMemo(LogType, LogText : string);

implementation

uses
  SysUtils,
  ExceptLog,
  POSDM,
  POSMain,
  POSMisc,
  LatTaxes,
  IBHeader;

var
  logdatalen : integer;
  sLog, sType: string;

procedure LogDept; forward;
procedure LogFuel; forward;
procedure LogDisc; forward;
procedure LogXMD; forward;
procedure LogMedia; forward;
procedure LogChange; forward;
procedure LogTotal; forward;
procedure LogSeq; forward;
procedure AddLog; forward;

{-----------------------------------------------------------------------------
  Name:      LogSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure LogSale(const PostSaleList : TList);
var
bTotalLogged: Boolean;
nLogNdx: byte;
RepeatCount : integer;
Year, Month, Day: Word;
begin
  RepeatCount := 1;
  while True do
  begin
    try
      POSDataMod.IBLogTransaction.StartTransaction;
      bTotalLogged := False;
      if (PostSaleList.Count > 0) then
      for nLogNdx := 0 to (PostSaleList.Count - 1) do
      begin
        PostSaleData := PostSaleList.Items[nLogNdx];
        if PostSaleData^.LineType = 'DPT' then
          LogDept
        else if PostSaleData^.LineType = 'PLU' then
          LogDept
        else if PostSaleData^.LineType = 'PPY' then
          LogDept
        else if PostSaleData^.LineType = 'PRF' then
          LogDept
        else if PostSaleData^.LineType = 'FUL' then
          LogFuel
        else if PostSaleData^.LineType = 'DSC' then
          LogDisc
        else if PostSaleData^.LineType = 'XMD' then
          LogXMD
        else if PostSaleData^.LineType = 'BNK' then
          LogDisc
        else if PostSaleData^.LineType = 'MED' then
        begin
          if not bTotalLogged then
          begin
            LogTotal;
            bTotalLogged := True;
          end;
          LogMedia;
        end;
      end;
      LogChange;
      if fmPOS.nCustBDayLog > 0 then
      begin
        DecodeDate(fmPOS.nCustBDayLog,Year, Month, Day);
        sLog := 'Birth Date:  '+ IntToStr(month) + '/' + IntToStr(Day) + '/' + IntToStr(year);
        sType := 'AGE';
        AddLog;
        fmPOS.nCustBDayLog := 0;
      end;
      LogSeq;
      POSDataMod.IBLogTransaction.Commit;
      break;
    except
      on E : Exception do
      begin
        UpdateExceptLog( 'Rollback Log Sale %d - %s -%s', [RepeatCount, E.ClassName, e.message]);
        UpdateZLog( 'Rollback Log Sale %d - %s -%s', [RepeatCount, E.ClassName, e.message]);
        if RepeatCount = 1 then DumpTraceBack(E, 5);
        if POSDataMod.IBLogTransaction.InTransaction then
          POSDataMod.IBLogTransaction.Rollback;
        Inc(RepeatCount);
        if RepeatCount > 100 then
          break;
      end;
    end; {if FI^.PumpSale1Amount > 0}
  end;
end;


{-----------------------------------------------------------------------------
  Name:      LogDept
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogDept;
{  999 Sale 999999999999999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999 999,999.00 999,999.00-xx}
begin
  sType := PostSaleData^.LineType;
  sLog := Format('%3d %-4s %15.0f %-30s %3s %10s %11s',
                  [PostSaleData^.SeqNumber,
                   PostSaleData^.Saletype,
                   PostSaleData^.Number,
                   PostSaleData^.Name,
                   FormatFloat('###',PostSaleData^.Qty),
                   FormatFloat('###,###.00', PostSaleData^.Price),
                   FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice)
                   ]);
  //Build 18
  if PostSaleData^.PriceOverridden then
  begin
    sLog := sLog + 'POR';
    AddLog;
    exit;
  end;
  //Build 18

  if (ItemTaxed(PostSaleData)) then
    sLog := sLog + 'T'
  else
    sLog := sLog + ' ';

  if PostSaleData^.Discable then
    sLog := sLog + 'D'
  else
    sLog := sLog + ' ';

  if PostSaleData^.FoodStampable then
    sLog := sLog + 'F'
  else
    sLog := sLog + ' ';

  AddLog;

  if PostSaleData^.MODocNo <> '' then
  begin
    sType := 'MOP';
    sLog := Format('%40s %20s %11s',[PostSaleData^.Name,PostSaleData^.MODocNo,(FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice))]);
    AddLog;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      LogFuel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogFuel;
{  999 Sale 999999999999999 xxxxxxxxxxxxxxxxxxxx 999.999 99.999 999,999.00-xx}
begin
  sType := PostSaleData^.LineType;
  sLog := Format('%3d %-4s %15.0f %-30s %7s %6s %11s',
                  [PostSaleData^.SeqNumber,
                   PostSaleData^.Saletype,
                   PostSaleData^.Number,
                   PostSaleData^.Name,
                   FormatFloat('###.000',PostSaleData^.Qty),
                   FormatFloat('##.000', PostSaleData^.Price),
                   FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice)
                   ]);
  //Build 18
  if PostSaleData^.PriceOverridden then
  begin
    sLog := sLog + 'POR';
    AddLog;
    exit;
  end;
  //Build 18
  if PostSaleData^.TaxNo > 0 then
    sLog := sLog + 'T'
  else
    sLog := sLog + ' ';

  if PostSaleData^.Discable then
    sLog := sLog + 'D'
  else
    sLog := sLog + ' ';
  if PostSaleData^.FoodStampable then
    sLog := sLog + 'F'
  else
    sLog := sLog + ' ';

  AddLog;
end;


{-----------------------------------------------------------------------------
  Name:      LogDisc
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogDisc;
{  999 Sale 999999999999999 xxxxxxxxxxxxxxxxxxxx 999 999,999.00 999,999.00-}
begin
  sType := PostSaleData^.LineType;
  sLog := Format('%3d %-4s %15.0f %-30s %3s %10s %11s',
                  [PostSaleData^.SeqNumber,
                   PostSaleData^.Saletype,
                   PostSaleData^.Number,
                   PostSaleData^.Name,
                   ' ',
                   ' ',
                   FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice)
                   ]);
  AddLog;
end;

{-----------------------------------------------------------------------------
  Name:      LogXMD
  Author:    Gary Whetton
  Date:      11-May-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogXMD;
{  999 Sale 999999999999999 xxxxxxxxxxxxxxxxxxxx 999 999,999.00 999,999.00-}
begin
  sType := PostSaleData^.LineType;
  sLog := Format('%3d %-4s %15.0f %-30s %3s %10s %11s',
                  [PostSaleData^.SeqNumber,
                   PostSaleData^.Saletype,
                   0,
                   PostSaleData^.Name,
                   ' ',
                   ' ',
                   FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice)
                   ]);
  AddLog;
end;


{-----------------------------------------------------------------------------
  Name:      LogMedia
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogMedia;
begin
  sLog := Format('%70s %11s',
                 [PostSaleData^.Name,
                  FormatFloat('###,###.00 ;###,###.00-',PostSaleData^.ExtPrice)
                  ]);
  sType := 'MED';
  AddLog;

  if PostSaleData^.CCAuthCode > '' then
    begin
      sLog := Format('%1s %-20s Card: %-20s Exp: %-10s', [PostSaleData^.CCEntryType, PostSaleData^.CCCardType,
                                                          cnRepl(PostSaleData^.CCCardNo), PostSaleData^.CCExpDate]);
      sType := 'MED';
      AddLog;
      sLog := Format('%-82s', ['Auth ' + PostSaleData^.CCAuthCode + ' Approval ' + PostSaleData^.CCApprovalCode
                                                + ' Date ' + PostSaleData^.CCDate
                                                + ' Time ' + PostSaleData^.CCTime
                                                + ' Batch'  + PostSaleData^.CCBatchNo
                                                + ' Seq ' + PostSaleData^.CCSeqNo]);

      sType := 'MED';
      AddLog;

      if PostSaleData^.CCCPSData <> '' then
        begin
          sLog := Format('%-82s',[' CPS ' + PostSaleData^.CCCPSData]);
          sType := 'MED';
          AddLog;
        end;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      LogChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogChange;
begin
  try
    sLog := Format('%70s %11s',['Change', FormatFloat('###,###.00 ;###,###.00-',pstSale.nChangeDue)]);
  except
    sLog := Format('%70s %11s',['Change', FormatFloat('###,###.00 ;###,###.00-',0.00)]);
  end;
  sType := 'CNG';
  AddLog;
end;


{-----------------------------------------------------------------------------
  Name:      LogTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogTotal;
var
  taxname : string;
begin

  sLog := Format('%70s %11s',['Subtotal', FormatFloat('###,###.00 ;###,###.00-',pstSale.nSubtotal)]);
  sType := 'SUB';
  AddLog;

  if pstSale.bSalesTaxXcpt then
    taxname := 'Tax Exempt'
  else
    taxname := 'Tax';

  sLog := Format('%70s %11s',[taxname, FormatFloat('###,###.00 ;###,###.00-',pstSale.nTlTax)]);
  sType := 'TAX';
  AddLog;

  sLog := Format('%70s %11s',['Total', FormatFloat('###,###.00 ;###,###.00-',pstSale.nTotal)]);
  sType := 'TOT';
  AddLog;

end;


{-----------------------------------------------------------------------------
  Name:      LogSeq
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogSeq;
begin

  sLog := '  Reg# ' + Format('%1d',[fmPOS.ThisTerminalNo]) + '  Shift# ' + Format('%1d',[nShiftNo]) + '  Trans# '
                    + Format('%6d',[pstSale.nTransNo]) + '  Time '
                    + FormatDateTime('h:mm AM/PM',Time) + '  Date '
                    + FormatDateTime('mm/dd/yy',Date)
                    + ' UserID ' + CurrentUserID  ;
  sType := 'SEQ';
  AddLog;

end;


{-----------------------------------------------------------------------------
  Name:      AddLog
  Author:    Mike Mattice
  Date:      2009-04-09
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure AddLog;
begin
  if not POSDataMod.IBLogSQL.Prepared then
  with POSDataMod.IBLogSQL do
  begin
    SQL.Clear;
    SQL.Add('INSERT INTO POSLog (LogNo, TimeStmp, RecType, Data) Values ' +
                                '(:LogNo, :TimeStmp, :RecType, :Data)');
    Prepare();
    logdatalen := ParamByName('Data').Size;
    if ParamByName('Data').SQLType = SQL_VARYING then logdatalen := logdatalen - 2;
    UpdateZLog('Prepared IBLogSQL - Data length = ' + IntToStr(logdatalen));
  end;
  with POSDataMod.IBLogSQL do
  begin
    ParamByName('LogNo').AsInteger := pstSale.nTransNo;
    ParamByName('TimeStmp').AsDatetime := Now;
    ParamByName('RecType').AsString := sType;
    ParamByName('Data').AsString := copy(sLog,1, logdatalen);
    if length(sLog) > logdatalen then
    begin
      UpdateExceptLog('Attempt to put %d characters into POSLog.Data which holds %d (truncated)', [length(sLog), logdatalen]); 
    end;
    ExecQuery;
    Close;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      LogRpt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RptName : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogRpt( RptName : string) ;
var
RepeatCount : integer;
begin

  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'RPT';
        sLog := '                               ***** ' + RptName + ' *****';
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log Report ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;



end;


{-----------------------------------------------------------------------------
  Name:      LogCCReceipt
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: str : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogCCReceipt(str : string) ;
var
RepeatCount : integer;
begin

  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'CCR';
        sLog := '                               ***** ' + str + ' *****';
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log Receipt ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;

end;


{-----------------------------------------------------------------------------
  Name:      LogNoSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogNoSale;
var
RepeatCount : integer;
begin


  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'NSL';
        sLog := '                               ***** NO SALE *****';
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log No Sale ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;

end;


{-----------------------------------------------------------------------------
  Name:      LogCancel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogCancel;
var
RepeatCount : integer;
begin


  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'CNL';
        sLog := '                          ***** CANCELLED SALE *****';
        AddLog;

        sLog := '                          SALE TOTAL WAS ' +
                Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTotal))]);
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Post LogCancel ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;

end;


{-----------------------------------------------------------------------------
  Name:      LogSuspend
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogSuspend;
var
RepeatCount : integer;
begin


  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'SUS';
        sLog := '                          ***** SUSPENDED SALE *****';
        AddLog;

        sLog := '                          SALE TOTAL WAS ' +
                Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTotal))]);
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log Suspend ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;


end;


{-----------------------------------------------------------------------------
  Name:      LogPOSStart
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogPOSStart;
begin
  LogMemo('OPN', '                          ***** POS Startup *****');
end;


{-----------------------------------------------------------------------------
  Name:      LogCATReset
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ResetMsg : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogCATReset(ResetMsg : string);
begin
  LogMemo('CTR', '                          ***** ' + ResetMsg + ' *****');
end;


{-----------------------------------------------------------------------------
  Name:      LogCreditReset
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogCreditReset;
begin
  LogMemo('CDR', '                          ***** Credit Reset ****');
end;


{-----------------------------------------------------------------------------
  Name:      LogFuelReset
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogFuelReset;
begin
  LogMemo('FLR', '                          ***** Fuel Reset  *****');
end;


{-----------------------------------------------------------------------------
  Name:      LogPumpRefresh
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: PumpNo : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogPumpRefresh(PumpNo : string);
begin
  LogMemo('PMR', '                          ***** Pump Refresh ' + PumpNo +  ' *****');
end;


{-----------------------------------------------------------------------------
  Name:      LogMemo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: LogType, LogText : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure LogMemo(LogType, LogText : string);
var
  RepeatCount : integer;
begin
  //20070905d...
  if (POSDataMod.IBDB.TestConnected) then
  begin
  //...20070905d
    RepeatCount := 1;
    while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := LogType;
        //20070926d...
//        sLog := LogText;
        sLog := Copy(LogText, 1, 80);
        //...20070926d
        AddLog;
        LogSeq;

        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log ' + Trim(LogText) + ' ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;  // while
  //20070905d...
  end  // if DB connected
  else
  begin
    UpdateExceptLog('LogMemo - DB not connected - LogType = ' + LogType + ' - LogText = ' + LogText);  //20070905dd (change 'LogMenu' to 'LogMemo')
  end;
  //...20070905d
end;


{-----------------------------------------------------------------------------
  Name:      LogSignOnOff
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: SignOn : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure LogSignOnOff(SignOn : boolean);
var
RepeatCount : integer;
begin

  RepeatCount := 1;
  while True do
    begin
      try
        POSDataMod.IBLogTransaction.StartTransaction;
        sType := 'USO';
        sLog := '   ***** ' + CurrentUser;
        if SignOn then
          sLog := sLog + ' Sign On *****'
        else
          sLog := sLog + ' Sign Off *****';
        UpdateZLog(slog);
        AddLog;
        LogSeq;
        POSDataMod.IBLogTransaction.Commit;
        break;
      except
        on E : Exception do
          begin
            UpdateExceptLog( 'Rollback Log Sign On-Off ' + IntToStr(RepeatCount) + ' ' + e.message);
            if POSDataMod.IBLogTransaction.InTransaction then
              POSDataMod.IBLogTransaction.Rollback;
            Inc(RepeatCount);
            if RepeatCount > 100 then
              break;
          end;
      end; {if FI^.PumpSale1Amount > 0}
    end;
end;



end.

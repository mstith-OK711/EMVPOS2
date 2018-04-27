{-----------------------------------------------------------------------------
 Unit Name: POSPole
 Author:    Gary Whetton
 Date:      4/13/2004 4:10:05 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit POSPole;
{$I ConditionalCompileSymbols.txt}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, AdPort, DB, LatTypes, OposLineDisplay_1_5_Lib_TLB;

procedure PoleMdse(const CurSaleData : pSalesData; const SaleState:TSaleState);
procedure PoleTL(const nCurTotal:currency);
procedure PoleMedia(const CurSaleData : pSalesData);
procedure PoleChange(const nCurChangeDue, nCurTotal: currency);
procedure BlankPole;
procedure ClosePole;
procedure PrintPole;
procedure ScrollPole(var sStr : shortstring);
procedure AssignPoleString(S : String);

var
  pStr : shortstring;
  poleport : TApdComPort;
  iPoleType : shortint;
  sPoleOpenMess : string;
  sPoleCloseMess : string;
  bPoleActive : shortint;
  OPOSPoleDisplay: TOPOSLineDisplay;

implementation

uses POSDM, POSPrt, LatTaxes;

{-----------------------------------------------------------------------------
  Name:      CheckPoleTax
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure CheckPoleTax(const CurSaleData : pSalesData);
begin

  if (ItemTaxed(CurSaleData)) then
    pStr := pStr + 'T'
  else
    pStr := pStr + ' ';

  if CurSaleData^.Discable then
    pStr := pStr + 'D'
  else
    pStr := pStr + ' ';

end;


{-----------------------------------------------------------------------------
  Name:      PoleMdse
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PoleMdse(const CurSaleData : pSalesData; const SaleState:TSaleState);
begin
  //Build 26
  if iPoleType = 24 then
    pStr := Format('%-20s',[CurSaleData^.Name])  +
          Format('%17s',[(FormatFloat('#,###.00 ;#,###.00-',CurSaleData^.ExtPrice))])
  else
    pStr := Format('%-20s',[CurSaleData^.Name])  + '         ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',CurSaleData^.ExtPrice))]);
  //Build 26
  CheckPoleTax(CurSaleData);

  if ( (SaleState <> ssBankFunc)        // No Bank Functions on Pole Display
       {$IFDEF PDI_PROMOS}
       and (CurSaleData^.SaleType <> 'Info')  // Do not print Discounts on Pole Display
       {$ENDIF}
                                       )then
    PrintPole;

end;


{-----------------------------------------------------------------------------
  Name:      PoleTL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PoleTL(const nCurTotal:currency);
begin

  pStr := 'TOTAL      ' +  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',nCurTotal))]);
  PrintPole;

end;


{-----------------------------------------------------------------------------
  Name:      PoleMedia
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PoleMedia(const CurSaleData : pSalesData);
var
MedName : string;
begin

  MedName := CurSaleData^.Name;
  if CurSaleData^.Extprice < 0 then
    begin
      MedName := MedName + ' Refund';
    end;

  pStr := Format('%-26s',[MedName])  + '   ' +
  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-', CurSaleData^.ExtPrice))]);
  PrintPole;

end;


{-----------------------------------------------------------------------------
  Name:      PoleChange
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PoleChange(const nCurChangeDue, nCurTotal: currency);
begin
  //Build 26
  //if nRcptChangeDue <> 0 then
  if nCurChangeDue <> 0 then
    begin
      if iPoleType <> 24 then
        pStr := '      Thank You     Your Change' +
              Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',nCurChangeDue))])
      else
        pStr := '      Thank You     Your Change' +
              Format('%8s',[(FormatFloat('#,###.00 ;#,###.00-',nCurChangeDue))]);
      PrintPole;
    end
  else
  //Build 26
    begin
      pStr := 'TOTAL      ' +  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',nCurTotal))]) +
                     '      Thank You';
      PrintPole;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      BlankPole
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure BlankPole();
begin
  pStr := sPoleOpenMess;
  PrintPole;
end;


{-----------------------------------------------------------------------------
  Name:      ClosePole
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure ClosePole();
begin
  pStr := sPoleCloseMess;
  PrintPole ;
end;


{-----------------------------------------------------------------------------
  Name:      AssignPoleString
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: S : String
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure AssignPoleString(S : String);
Begin
  pStr := s;
End;


{-----------------------------------------------------------------------------
  Name:      PrintPole
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PrintPole;
begin

  case bPoleActive of
  1 :
    begin
      //Build 26
      //fmPOS.PolePort.Output := #30 + pStr;
      if iPoleType = 24 then
        PolePort.Output := #31 + #20 + pStr
      else
        PolePort.Output := #30 + pStr;
      //Build 26
    end;
  2 :
    begin
      OPOSPoleDisplay.ClearText;
      OPOSPoleDisplay.DisplayTextAt( 0, 0, pStr, 0 )
    end;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      ScrollPole
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var sStr : shortstring
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure ScrollPole(var sStr : shortstring);
begin

  case bPoleActive of
  1 :
    begin
      if iPoleType = 24 then
        PolePort.Output := #31 + #20 + sStr
      else
        PolePort.Output := sStr;
    end;
  2 :
    begin
      OPOSPoleDisplay.DisplayTextAt( 0, 0, copy(sStr,6,20), 0 );
    end;
  end;

end;



end.

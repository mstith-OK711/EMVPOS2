{-----------------------------------------------------------------------------
 Unit Name: PriceSgn
 Author:    Gary Whetton
 Date:      4/13/2004 4:17:15 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit PriceSgn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, AdPort, ExtCtrls;

    procedure RemoteReset(item:char);
    procedure CommTest(item:char);
    procedure RptConfig(item:char);
    procedure RptPositions(item:char);
    procedure SendPrice(item:char;price:string);
    procedure PriceSignPortTriggerAvail(CP: TObject; Count: Word);
    function GetChecksum (ArrayIn : PChar; Len :Byte) : Char;
    function Getcomp(c : Char) : Char;

const
 ItemDigits: set of '0'..'4' = ['0'..'4'];

var
  intItem  : integer;
  chrError : CHar = #240;
  flgRemoteRst : boolean;
  chrRemoteRst : CHar = #80;
  chrRemoteRstRsp : CHar = #88;
  flgCommTest : boolean;
  chrCommTest : CHar = #0;
  flgRptCfg : boolean;
  chrRptCfg : CHar = #16;
  flgRptPos : boolean;
  chrRptPos : CHar = #32;
  flgNewPos : boolean;
  chrNewPos : CHar = #144;
  chrNewPosRsp : CHar = #152;
  flgInMotion    : boolean;
  flgBatteryLowShow  : Boolean = True;
  PriceADollar  : char;
  PriceBDollar  : char;
  PriceADime    : char;
  PriceBDime    : char;
  PriceAPenny   : char;
  PriceBPenny   : char;
  BatLow        : char;
  VerHi         : char;
  VerLo         : char;
  VerSize       : char;
  VerType       : char;
  Commodity     : string;
  SingleDouble  : char;
  InputBuff : Array [0..50] of Char;
  OutputBuff : Array [0..50] of Char;
  InputBuffCnt : integer = 0;
implementation

Uses
  POSMain;

{-----------------------------------------------------------------------------
  Name:      Getcomp
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: c : Char
  Result:    Char
  Purpose:   
-----------------------------------------------------------------------------}
function Getcomp(c : Char) : Char;
Var
  i,j : Byte;
  Res : Byte;
Begin
 j  :=1;
 Res := 0;
 For i := 1 to 8 do
   Begin
     If (J and Byte(C)) = 0 Then
         Res := Res + j;
     j:= j * 2;
   End;

 GetComp := Char(Res);
End;


{-----------------------------------------------------------------------------
  Name:      GetChecksum
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ArrayIn : PChar; Len :Byte
  Result:    Char
  Purpose:   
-----------------------------------------------------------------------------}
function GetChecksum (ArrayIn : PChar; Len :Byte) : Char;
Var
  i    : Byte;
  Temp : Integer;
  c    : Byte;
  Endc : Char;
Begin
  temp := 0;
  For i:= 0 to Len-1 do
   Begin
     Temp := Temp + Byte(ArrayIn[i]);
   End;

  C := Byte(Temp and 255);
  Endc := Char(c);
  Endc := GetComp(Endc);
  getchecksum :=endc;
End;


{-----------------------------------------------------------------------------
  Name:      RemoteReset
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item:char
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure RemoteReset(Item:char);
begin
  InputBuffCnt := 0;
  InputBuff := '';
  OutputBuff := '';
  flgRemoteRst := false;
   if Item = '' then
     begin
       intItem := 0;
     end
   else
     begin
     if Item in ItemDigits then
      begin
         intItem := strtoint(Item);
      end
     else
      begin
        intItem := 0;
      end;
     end;
  OutputBuff[0] :=chr(intItem + ord(chrRemoteRst));
  OutputBuff[1] := #164;
  OutputBuff[2] := #164;
  OutputBuff[3] := GetChecksum (OutputBuff,3);
  fmPOS.PriceSignPort.PutBlock(OutputBuff,4);
end;


{-----------------------------------------------------------------------------
  Name:      CommTest
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item:char
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure CommTest(Item:char);
begin
  InputBuffCnt := 0;
  InputBuff := '';
  OutputBuff := '';
  flgCommTest := false;
  if Item = '' then
     begin
       intItem := 0;
     end
   else
     begin
     if Item in ItemDigits then
      begin
         intItem := strtoint(Item);
      end
     else
      begin
        intItem := 0;
      end;
     end;
  OutputBuff[1] := #164;
  OutputBuff[2] := #164;
  OutputBuff[3] := #1;
  OutputBuff[4] := #2;
  OutputBuff[5] := #3;
  OutputBuff[6] := #4;
  OutputBuff[7] := GetChecksum (OutputBuff,7);
  fmPOS.PriceSignPort.PutBlock(OutputBuff,8);
end;


{-----------------------------------------------------------------------------
  Name:      RptConfig
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item:char
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure RptConfig(Item:char);
begin
  InputBuffCnt := 0;
  InputBuff := '';
  OutputBuff := '';
  flgRptCfg := false;
  Commodity     := '';
  SingleDouble  := ' ';

   if Item = '' then
     begin
       intItem := 0;
     end
   else
     begin
     if Item in ItemDigits then
      begin
         intItem := strtoint(Item);
      end
     else
      begin
        intItem := 0;
      end;
     end;
  OutputBuff[0] :=chr(intItem + ord(chrRptCfg));
  OutputBuff[1] := #164;
  OutputBuff[2] := #164;
  OutputBuff[3] := GetChecksum (OutputBuff,3);
  fmPOS.PriceSignPort.PutBlock(OutputBuff,4);
end;


{-----------------------------------------------------------------------------
  Name:      RptPositions
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item:char
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure RptPositions(Item:char);
begin
  InputBuffCnt := 0;
  InputBuff := '';
  OutputBuff := '';
  flgRptPos := false;
  flgInMotion := true;
  PriceADollar  := ' ';
  PriceBDollar  := ' ';
  PriceADime    := ' ';
  PriceBDime    := ' ';
  PriceAPenny   := ' ';
  PriceBPenny   := ' ';
  BatLow        := ' ';
  VerHi         := ' ';
  VerLo         := ' ';
  VerSize       := ' ';
  VerType       := ' ';

  if Item = '' then
     begin
       intItem := 0;
     end
   else
     begin
     if Item in ItemDigits then
      begin
         intItem := strtoint(Item);
      end
     else
      begin
        intItem := 0;
      end;
     end;
  OutputBuff[0] :=chr(intItem + ord(chrRptPos));
  OutputBuff[1] := #164;
  OutputBuff[2] := #164;
  OutputBuff[3] := GetChecksum (OutputBuff,3);
  fmPOS.PriceSignPort.PutBlock(OutputBuff,4);
end;


{-----------------------------------------------------------------------------
  Name:      SendPrice
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item:char;Price:string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure SendPrice(Item:char;Price:string);
const
  AsciiDigits: set of '0'..'9' = ['0'..'9'];
var
Amount : single;
dollars : char;
dimes : char;
pennies : char;
begin
  If (bPriceSignActive = 0) or (fmPOS.PriceSignPort.Open = False ) Then
   Begin
    MessageBeep(1);
    fmPOS.POSError('Price Sign not active ! Call Support');
    fmPOS.FuelPriceTimer.Tag := 0;
    Exit;
   End;

  InputBuffCnt := 0;
  InputBuff := '';
  OutputBuff := '';
  flgNewPos := false;
  flgInMotion := true;
  flgBatteryLowShow := True;

  // Price Edit Checks
   if Price = '' then
     begin
       dollars := chr(15);
       dimes := chr(15);
       pennies := chr(15);
     end
   else
     begin
     try
        begin
        Amount := strtocurr(Price);
        dollars := chr(trunc(Amount*100) div 100);
        dimes := chr((trunc(Amount*100) - (ord(dollars)* 100)) div 10);
        pennies := chr((trunc(Amount*100) - (ord(dollars)* 100) - (ord(dimes) * 10)) div 1);
        end
     except
     on EConvertError do
        begin
           dollars := chr(15);
           dimes := chr(15);
           pennies := chr(15);
        end;
     on EDivByZero do
        begin
           dollars := chr(15);
           dimes := chr(15);
           pennies := chr(15);
        end;
     end;
  end;

  //Add Address(item) to first byte
   if Item = '' then
     begin
       intItem := 0;
     end
   else
     begin
     if Item in ItemDigits then
      begin
         intItem := strtoint(Item);
      end
     else
      begin
        intItem := 0;
      end;
   end;
   OutputBuff[0] :=chr(intItem + ord(chrNewPos));
   OutputBuff[1] := #164;
   OutputBuff[2] := #164;
   OutputBuff[3] := dollars;
   OutputBuff[4] := dimes;
   OutputBuff[5] := pennies;
   OutputBuff[6] := GetChecksum (OutputBuff,6);
   fmPOS.PriceSignPort.PutBlock(OutputBuff,7);

end;


{-----------------------------------------------------------------------------
  Name:      PriceSignPortTriggerAvail
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CP: TObject; Count: Word
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure PriceSignPortTriggerAvail(CP: TObject; Count: Word);
var
i             : word;
c             : char;
MotionAPenny  : char;
MotionBPenny  : char;
MotionADime   : char;
MotionBDime   : char;
MotionADollar : char;
MotionBDollar : char;
intTempDigit   : integer;
begin
  for i := 1 to count do
    begin
      c :=  fmPOS.PriceSignPort.GetChar;
      InputBuff[InputBuffCnt] := c;
      inc(InputBuffCnt);
    end;

// Timing Error Check
    if (InputBuff[0] = chrError) and
    (InputBuff[1] = #5) and
    (InputBuff[2] = GetChecksum (InputBuff,2)) then
    begin
     MessageBeep(1);
     fmPOS.POSError('Price Sign:A timing Error occured...');
     OutputBuff := '';
    End;

// Confirmation Error Check
    if (InputBuff[0] = chrError) and
    (InputBuff[1] = #6) and
    (InputBuff[2] = GetChecksum (InputBuff,2)) then
    begin
     MessageBeep(1);
     fmPOS.POSError('Price Sign:A Confirmation Information Error occured...');
     OutputBuff := '';
    End;

// Unknown Error Check
    if (InputBuff[0] = chrError) and
    (InputBuff[2] = GetChecksum (InputBuff,2)) then
    begin
     MessageBeep(1);
     fmPOS.POSError('Price Sign: A Unknown Error occured...');
     OutputBuff := '';
    End;

// Remote Reset Response Check
    if (InputBuff[0] = chr(intItem + ord(chrRemoteRst))) and
    (InputBuff[1] = GetChecksum (InputBuff,1)) then
    begin
     OutputBuff := '';
     OutputBuff[0] :=chr(intItem + ord(chrRemoteRstRsp));
     OutputBuff[1] := #164;
     OutputBuff[2] := #164;
     OutputBuff[3] := GetChecksum (OutputBuff,3);
     fmPOS.PriceSignPort.PutBlock(OutputBuff,4);
     flgRemoteRst := True;
     OutputBuff := '';
    End;

// Comm Test Response Check
    if (InputBuff[0] = chr(intItem + ord(chrCommTest))) and
    (InputBuff[1] = OutputBuff[3]) and
    (InputBuff[2] = OutputBuff[4]) and
    (InputBuff[3] = OutputBuff[5]) and
    (InputBuff[4] = OutputBuff[6]) and
    (InputBuff[5] = GetChecksum (InputBuff,5)) then
    begin
     OutputBuff := '';
     flgCommTest := True;
    End;

// Rpt Config Response Check
    if (InputBuff[0] = chr(intItem + ord(chrRptCfg))) and
    (InputBuff[2] = GetChecksum (InputBuff,2)) then
    begin
     if (ord(InputBuff[1]) and 8) > 0  then
        SingleDouble := '1'
     else
        SingleDouble := '0';

     case (ord(InputBuff[1]) and 7) of
        0, 4: Commodity := 'Regular';
        1, 5: Commodity := 'No Lead';
        2, 6: Commodity := 'Diesel';
        3, 7: Commodity := 'Premium';
     else
        Commodity := 'Unknown';
     end;
     flgRptCfg := True;
     OutputBuff := '';
    End;

// Rpt Positions Response Check
    if (InputBuff[0] = chr(intItem + ord(chrRptPos))) and
    (InputBuff[7] = GetChecksum (InputBuff,7)) then
    begin
     //Motion Status Pennys
     if (ord(InputBuff[1]) and 128) > 0  then
        MotionAPenny := #1
     else
        MotionAPenny := #0;
     if (ord(InputBuff[1]) and 64) > 0  then
        MotionBPenny := #1
     else
        MotionBPenny := #0;
     //Motion Status Dimes
     if (ord(InputBuff[1]) and 32) > 0  then
        MotionADime := #1
     else
        MotionADime := #0;
     if (ord(InputBuff[1]) and 16) > 0  then
        MotionBDime := #1
     else
        MotionBDime := #0;
     //Motion Status Dollar
     if (ord(InputBuff[1]) and 8) > 0  then
        MotionADollar := #1
     else
        MotionADollar := #0;
     if (ord(InputBuff[1]) and 4) > 0  then
        MotionBDollar := #1
     else
        MotionBDollar := #0;

     if (ord(MotionAPenny) or ord(MotionBPenny)  or ord(MotionADime) or ord(MotionBDime)
     or ord(MotionADollar) or ord(MotionBDollar)) = 1  then
       Begin
        flgInMotion := true;
       End
     else
       Begin
        flgInMotion := false;
       End;

     //Battery Status
     if (ord(InputBuff[1]) and 1) > 0  then
        begin
          BatLow := '1';
          MessageBeep(1);
          If flgBatteryLowShow then
            Begin
              fmPOS.POSError('Price Sign Battery is Low. - Call for service.');
              flgBatteryLowShow := False;
            end;
        End
     else
        Begin
          BatLow := '0';
        End;

     //A & B Side Price(Dollar) Status
     intTempDigit := ord(InputBuff[2]) and 15;
     Case  intTempDigit of
       0..9:PriceADollar := inttostr(intTempDigit)[1];
        10:PriceADollar := '?';
        15:PriceADollar := ' ';
     else
        PriceADollar := 'X';
     end;
     intTempDigit := round((ord(InputBuff[2]) and 240)/16);
     Case  intTempDigit of
       0..9:PriceBDollar := inttostr(intTempDigit)[1];
        10:PriceBDollar := '?';
        15:PriceBDollar := ' ';
     else
        PriceBDollar := 'X';
     end;
     //A & B Side Price(Dime) Status
     intTempDigit := ord(InputBuff[3]) and 15;
     Case  intTempDigit of
       0..9:PriceADime := inttostr(intTempDigit)[1];
        10:PriceADime := '?';
        15:PriceADime := ' ';
     else
        PriceADime := 'X';
     end;
     intTempDigit := round((ord(InputBuff[3]) and 240)/16);
     Case  intTempDigit of
       0..9:PriceBDime := inttostr(intTempDigit)[1];
        10:PriceBDime := '?';
        15:PriceBDime := ' ';
     else
        PriceBDime := 'X';
     end;
     //A & B Side Price(Penny) Status
     intTempDigit := ord(InputBuff[4]) and 15;
     Case  intTempDigit of
       0..9:PriceAPenny := inttostr(intTempDigit)[1];
        10:PriceAPenny := '?';
        15:PriceAPenny := ' ';
     else
        PriceAPenny := 'X';
     end;
     intTempDigit := round((ord(InputBuff[4]) and 240)/16);
     Case  intTempDigit of
       0..9:PriceBPenny := inttostr(intTempDigit)[1];
        10:PriceBPenny := '?';
        15:PriceBPenny := ' ';
     else
        PriceBPenny := 'X';
     end;
     //Version
        VerLo := inttostr(ord(InputBuff[5]) and 15)[1];
        VerHi := inttostr(round((ord(InputBuff[5]) and 240)/16))[1];
     //Type/Version
        VerSize := inttostr(ord(InputBuff[6]) and 15)[1];
        VerType := inttostr(round((ord(InputBuff[6]) and 240)/16))[1];
     flgRptPos := True;
     OutputBuff := '';
    End;

// Send Price Response Check

    if (InputBuff[0] = chr(intItem + ord(chrNewPos))) and
    (InputBuff[1] = OutputBuff[3]) and
    (InputBuff[2] = OutputBuff[4]) and
    (InputBuff[3] = OutputBuff[5]) and
    (InputBuff[4] = GetChecksum (InputBuff,4)) then
    begin
     OutputBuff := '';
     OutputBuff[0] := chr(intItem + ord(chrNewPosRsp));
     OutputBuff[1] := #164;
     OutputBuff[2] := #164;
     OutputBuff[3] := #1;
     OutputBuff[4] := #2;
     OutputBuff[5] := #3;
     OutputBuff[6] := GetChecksum (OutputBuff,6);
     fmPOS.PriceSignPort.PutBlock(OutputBuff,7);
     flgNewPos := True;
     OutputBuff := '';
    End;
end;
end.




unit Encrypt;

{$I ConditionalCompileSymbols.txt}  //20060924a

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Math,
  IdSSLOpenSSLHeaders,
  Dialogs;

const
  MAPPED_PER_WORD     = 9;
  BYTES_PER_WORD      = 8;
  HEX_DIGITS_PER_WORD = BYTES_PER_WORD * 2;
  PRINTABLE_PER_WORD  = 10;
  BASE_VALUE = 94;
  IDX_MOST_SIGNIFICANT_8_BYTES = 7;

type
  TVariantRec = record
  case Integer of
    0:  (L: Int64);
    1:  (B: array [0..7] of Byte);
  end;

{ Public declarations }
function EncryptString(const PlainText : string) : string;
function DecryptString(const EncryptText : string) : string;
function HexToPrintable(const HEXString : string) : string;
function PrintableToHex(const PrintableString : string) : string;
function pkcs5pad(const input: string): string;
function pkcs5unpad(const input: string): string;

procedure SetKeys(const k1, k2, k3 : string);

implementation

uses
  POSMisc;

var
  ks1, ks2, ks3 : des_key_schedule;

function pkcs5pad(const input: string): string;
var
  mv, i : integer;
begin
  mv := 8 - (length(input) mod 8);
  Result := input;
  if mv <> 8 then
    for i := 0 to pred(mv) do Result := Result + chr(mv);
end;

function pkcs5unpad(const input: string): string;
var
  mv, l, i : integer;
  mvc : char;
  good : boolean;
begin
  good := True;
  l := length(input);
  if l > 0 then
  begin
    mvc := input[l];
    mv := ord(mvc);
    if mv <= 8 then
    begin
      for i := pred(l) downto (l - mv)+1 do
        if good and (input[i] <> mvc) then good := False;
      if good then
        Result := copy(input, 1, l - mv);
    end
    else
      Result := input;
  end
  else
    Result := input;
end;

function hexifyblock(const pblock: Pconst_DES_cblock): string;
var
  i : integer;
  ts : string;
begin
  ts := '';
  for i := 0 to pred(sizeof(DES_cblock)) do
    ts := ts + Format('%2.2x', [pblock^[i] ]);
  hexifyblock := ts;
end;

function stringifyblock(const pblock: Pconst_DES_cblock): string;
var
  i : integer;
  s : string;
begin
  s := '';
  for i := 0 to pred(sizeof(DES_cblock)) do
    s := s + chr(pblock[i]);
  stringifyblock := s;
end;

function EncryptString(const PlainText : string) : string;
{
Encrypt a string into a string of printable characters.
Function DecryptString() is the inverse of this function.
}
var
  inblk, outblk : DES_cblock;
  strInput : string;
  OutString : string;
  i : integer;

begin
  OutString := '';
  strInput := pkcs5pad(PlainText);
  for i := 0 to pred(length(strInput) div sizeof(DES_cblock)) do
  begin
    move(strInput[1+i*sizeof(DES_cblock)], inblk, sizeof(DES_cblock));
    DES_ecb3_encrypt(@inblk, @outblk, ks1, ks2, ks3, 1);
    outstring := outstring + hexifyblock(@outblk);
  end;

  {$IFDEF CISP_WIDE_FIELDS}  //20060924a
  EncryptString := OutString;
  {$ELSE}
  // Map to printable characters (format uses fewer characters than HEX)
  RetString := HEXToPrintable(OutString);
  EncryptString := RetString;
  {$ENDIF}
end; // function EncryptString

function DecryptString(const EncryptText : string) : string;
{
Decrypt a string into a string of printable characters encrypted by the function EncryptString()
back into the original string.
}
var
  strInput : string;
  inblk, outblk : DES_cblock;
  TempString : string;
  i : integer;
  {$IFNDEF CISP_WIDE_FIELDS}  //20060924a
  //20060309...
  LengthEncryptText :integer;
  //...20060309
  {$ENDIF}

begin
  // Map the printiable characters back to the HEX format of the original encryypted data.
  {$IFDEF CISP_WIDE_FIELDS}
  strInput := unhexifystring(EncryptText);
  {$ELSE}
  //  Following change was implemented to remove extra spaces the DBMS places into char() fields.
  //  This is not an issue with varchar() fields, but some database copies may still have some
  //  encrypted fields defined as char().
  //  If spaces were not allowed in the encrypted text, then a simple trim() function could
  //  remove the excess spaces.
  //  To prevent from having to use an encryption formatting method that does not use spaces,
  //  the solution below utilizes the fact that the encrypted text is always in blocks of
  //  PRINTABLE_PER_WORD characters.  The likelyhood of encrypting to a block of PRINTABLE_PER_WORD
  //  spaces is almost zero, so only keep blocks of PRINTABLE_PER_WORD characters that contain
  //  non-spaces.
  LengthEncryptText := ((Length(Trim(EncryptText)) + PRINTABLE_PER_WORD - 1) div
                                        PRINTABLE_PER_WORD)                   * PRINTABLE_PER_WORD;
  strInput := unhexifystring(PrintableToHEX(Copy(EncryptText, 1, LengthEncryptText)));
  {$ENDIF}
  // Decrypt the string.
  for i := 0 to pred(length(strInput) div sizeof(DES_cblock)) do
  begin
    move(strInput[1+i*sizeof(DES_cblock)], inblk, sizeof(DES_cblock));
    DES_ecb3_encrypt(@inblk, @outblk, ks1, ks2, ks3, 0);
    TempString := TempString + stringifyblock(@outblk);
  end;

  DecryptString := pkcs5unpad(TempString);
end; // function DecryptString

{$IFNDEF CISP_WIDE_FIELDS}  //20060924a
function Map96(const UnMapped : string) : string;
{
Pack a string of the printable characters (ASCII $20 thru $7F) plus the null character into a string of bits
that use all 8 bits of a byte.  (This is the inverse function of UnMap96()).
}
var
  LongWord : Int64;
  TVarRec  : TvariantRec;
  NumberMappedWords : integer;
  NumberMappedBytes : integer;
  idxUnMapped : integer;
  idxMapped : integer;
  j : integer;
  j2 : integer;
  BaseDigit : integer;
  RetString : string;
begin

  NumberMappedWords := ((Length(UnMapped) + 1) div MAPPED_PER_WORD) + 1;
  NumberMappedBytes := NumberMappedWords * BYTES_PER_WORD;
  SetLength(RetString, NumberMappedBytes);

  idxUnMapped := 1;
  idxMapped := 1;
  for j2 := 1 to NumberMappedWords do
  begin
    LongWord := Int64(0);
    for j := 0 to BYTES_PER_WORD - 1 do
    begin
      if (idxUnMapped <= Length(UnMapped)) then BaseDigit := Byte(UnMapped[idxUnMapped]) and $7F
      else                                      BaseDigit := 0;
      Inc(idxUnMapped);
      if      (BaseDigit =  $00) then BaseDigit := BASE_VALUE - 1    // For detecting end of string
      else if (BaseDigit >= $20) then Dec(BaseDigit, $20)            // printable characters (0...BASE_VALUE-2)
      else                       BaseDigit := 0;                     // map non-printable to space.
      LongWord := LongWord * Int64(BASE_VALUE) + Int64(BaseDigit);
    end;
    TVarRec.L := LongWord;
    for j := 0 to BYTES_PER_WORD - 1 do
    begin
      RetString[IdxMapped] := Char(TVarRec.B[j]);
      Inc(IdxMapped);
    end;
  end;

  Map96 := RetString;

end;  // function Map96


function UnMap96(const Mapped : string) : string;
{
Unpack a string of bits that use all 8 bits of a byte into a string of the printable characters (ASCII $20 thru $7F)
plus the null character.  (This is the inverse function of Map96()).
}
var
  LongWord : Int64;
  TVarRec  : TvariantRec;
  NumberUnMappedWords : integer;
  NumberUnMappedBytes : integer;
  idxUnMapped : integer;
  idxMapped : integer;
  j : integer;
  j2 : integer;
  BaseDigit : integer;
  RetString : string;
  WordString : string;
  bEndOfString : boolean;
begin

  NumberUnMappedWords := ((Length(Mapped) + BYTES_PER_WORD - 1) div BYTES_PER_WORD);
  NumberUnMappedBytes := NumberUnMappedWords * MAPPED_PER_WORD;
  SetLength(RetString, NumberUnMappedBytes);

  idxUnMapped := 1;
  idxMapped := 1;
  bEndOfString := False;
  for j2 := 1 to NumberUnMappedWords do
  begin
    for j := 0 to BYTES_PER_WORD - 1 do
    begin
      TVarRec.B[j] := Byte(Mapped[IdxMapped]);
      Inc(IdxMapped);
    end;
    LongWord := TVarRec.L;
    WordString := '';
    SetLength(WordString, MAPPED_PER_WORD);
    for j := MAPPED_PER_WORD downto 1 do
    begin
      BaseDigit := LongWord mod Int64(BASE_VALUE);
      if (BaseDigit = (BASE_VALUE - 1)) then WordString[j] := Char($00)
      else                                   WordString[j] := Char($20 + BaseDigit);
      LongWord := LongWord div Int64(BASE_VALUE);
    end;
    for j := 1 to MAPPED_PER_WORD do
    begin
      if (WordString[j] = Char($00)) then
      begin
        bEndOfString := True;
        break;
      end
      else
      begin
        RetString[idxUnMapped] := WordString[j];
      end;
      Inc(IdxUnMapped);
    end;
    if (bEndOfString) then
      break;
  end;


  SetLength(RetString, idxUnMapped - 1);
  UnMap96 := RetString;

end;  // function UnMap96

{$ENDIF}  // not def CISP_WIDE_FIELDS


function HexToPrintable(const HEXString : string) : string;
{
  This function maps a sting of HEX formatted bytes (i.e., %2.2x) to a string of printable characters
  (ASCII $20 thru $7F).  The idea is to use fewer characters to store the same binary representation as
  the HEX format.  This function is the inverse of PrintableToHex.
}
var
  TVarRec  : TvariantRec;
  SaveLeadingBit : Byte;
  InputString : string;
  RetString : string;
  LongWord : Int64;
  HEXDigitsProcessed : integer;
  idxOutput : integer;
  DigitValue : integer;
  NumberHexDigits : integer;
  j : integer;
  j2 : integer;
begin
  InputString := UpperCase(HEXString);
  RetString := '';
  NumberHexDigits := Length(InputString);
  SetLength(RetString, NumberHexDigits);  // Actual length is about ((Len/2 + 7) / 8) * 10, but will be reduced at end.
  LongWord := Int64(0);
  HexdigitsProcessed := 0;
  idxOutput := 0;
  // Process each hex digit.
  for j := 1 to NumberHexDigits do
  begin
    // Convert groups of hex digits into a word value.
    DigitValue := Byte(InputString[j]);
    if (DigitValue > $40) then Dec(DigitValue, $37)   // "A" thru "F"
    else                       Dec(DigitValue, $30);  // "0" thru "9"
    LongWord := (LongWord shl Int64(4)) + Int64(DigitValue);
    Inc(HexDigitsProcessed);
    if ((HexDigitsProcessed >= HEX_DIGITS_PER_WORD) or (j = NumberHexDigits)) then
    begin
      // Save leading bit then clear it (so that the long word will be a positive value.)
      TVarRec.L := LongWord;
      SaveLeadingBit := TVarRec.B[IDX_MOST_SIGNIFICANT_8_BYTES] and $80;
      TVarRec.B[IDX_MOST_SIGNIFICANT_8_BYTES] := TVarRec.B[IDX_MOST_SIGNIFICANT_8_BYTES] and $7F;
      LongWord := TVarRec.L;
      // Process the long word value as a large base number (BASE is at least the number of printable characters)
      // Each digit of this large base number is mapped into one of the printable characters.
      for j2 := 1 to PRINTABLE_PER_WORD do
      begin
        DigitValue := LongWord mod Int64(BASE_VALUE);
        LongWord := LongWord div Int64(BASE_VALUE);
        Inc(IdxOutput);
        //20060418...
//        RetString[idxOutput] := Char($20 + DigitValue);
        if (DigitValue > $0A) then  // Skip comma ( ASCII $2C)
          RetString[idxOutput] := Char($22 + DigitValue)
        else
          RetString[idxOutput] := Char($21 + DigitValue);
        //...20060418
      end;  // for each printable character in a word
      // Adjust the most significant character for the sign bit.  Because of the base arithmetic,
      // the most significant character will always be in the lower half of the printable character range;
      // therefore, if the original word had a sign bit, then move this character to the upper half.
      // (If the last word does not use the most significant character (i.e., idxOutput does not point to
      // the most significant character of a word), then the sign bit will not be set anyway.)
      if (SaveLeadingBit <> 0) then
      //20060508...
      //  RetString[idxOutput] := Char(Byte(RetString[idxOutput]) + (BASE_VALUE div 2));
      begin
        if (DigitValue > $0A) then  // Skip comma ( ASCII $2C)
          RetString[idxOutput] := Char(Byte(RetString[idxOutput]) + (BASE_VALUE div 2))
        else
          RetString[idxOutput] := Char(Byte(RetString[idxOutput]) + (BASE_VALUE div 2) + 1);
      end;
      //...20060508
      LongWord := Int64(0);  // Actually, should already be zero from above.
      HexDigitsProcessed := 0;
    end;  // if end of a word
  end;  // for each HEX digit

  HexToPrintable := Copy(RetString, 1, idxOutput);
end;  // function HexToPrintable

function PrintableToHex(const PrintableString : string) : string;
{
  This function maps a sting of printable characters (ASCII $20 thru $7F) to a string of HEX formatted bytes
  (i.e., %2.2x).  Both the printable an hex representation map to the same original binary values, but the
  printable format is more compact.
  This function is the inverse of PrintableToHex.
}
var
  TVarRec  : TvariantRec;
  LongWord : Int64;
  SaveLeadingBit : Byte;
  InputString : string;
  RetString : string;
  NumberPrintableCharacters : integer;
  DigitsProcessed : integer;
  idxInput : integer;
  idxOutput : integer;
  TempValue : integer;
  DigitValue : integer;
  j : integer;
  j2 : integer;
begin
  InputString := PrintableString;
  NumberPrintableCharacters := Length(InputString);
  RetString := '';
  SetLength(RetString, 2 * NumberPrintableCharacters);
  DigitsProcessed := 0;
  SaveLeadingBit := Byte($00);
  LongWord := Int64(0);
  idxOutput := 0;
  idxInput := Min(PRINTABLE_PER_WORD, NumberPrintableCharacters);
  // Process each character
  for j := 1 to NumberPrintableCharacters do
  begin
    //20060418...
//    DigitValue := Byte(InputString[idxInput]) - $20;
    DigitValue := Byte(InputString[idxInput]) - $21;
    if (DigitValue > $0A) then Dec(DigitValue);  // Comma is not used, so move character values back one.
    //...20060418
    Dec(idxInput);
    // If this character represents the most significant digit, then determine the sign bit
    // of the original long word value and (if the sign bit is set), recover the original value
    // of the character.
    if (DigitsProcessed = 0) then
    begin
      // Character is most significant.  Also make sure it is not a partial word at the end of the string.
      if ((j mod PRINTABLE_PER_WORD) = 1) then
      begin
        if (DigitValue >= (BASE_VALUE div 2)) then  // If character has sign bit encoded into it.
        begin
          Dec(DigitValue, (BASE_VALUE div 2));      // remove the encoding of the sign bit from the character.
          SaveLeadingBit := Byte($80); // Sign bit will be added once all digits of the long word are processed.
        end;
      end;
    end;

    // Re-construct the large base number (BASE is at least the number of printable characters)
    // Each printable character maps to a digit in this large base number.
    LongWord := (LongWord * Int64(BASE_VALUE)) + Int64(DigitValue);
    Inc(DigitsProcessed);
    // Check to see if processing is at a long word boundry.
    if ((DigitsProcessed >= PRINTABLE_PER_WORD) or (j = NumberPrintableCharacters)) then
    begin
      // Jump to end of next group of characters.
      Inc(idxInput, 2 * PRINTABLE_PER_WORD);
      if (idxInput > NumberPrintableCharacters) then
        idxInput := NumberPrintableCharacters;
      // Process each byte of the long word
      TVarRec.L := LongWord;
      TVarRec.B[IDX_MOST_SIGNIFICANT_8_BYTES] := TVarRec.B[IDX_MOST_SIGNIFICANT_8_BYTES] or SaveLeadingBit;   // Restore sign bit.
      SaveLeadingBit := Byte($00);
      LongWord := Int64(0);
      for j2 := BYTES_PER_WORD - 1 downto 0 do
      begin
        // Convert to HEX format (first the left hex digit; then the righ hex digit)
        TempValue := TvarRec.B[j2];
        DigitValue := (TempValue shr 4) and $0F;  // First convert left HEX value...
        if (DigitValue > 9) then Inc(DigitValue, $37)    // "A" thru "F"
        else                     Inc(DigitValue, $30);   // "0" thru "9"
        Inc(idxOutput);
        RetString[IdxOutput] := Char(DigitValue);
        DigitValue := TempValue and $0F;          // ... then convert right HEX value
        if (DigitValue > 9) then Inc(DigitValue, $37)    // "A" thru "F"
        else                     Inc(DigitValue, $30);   // "0" thru "9"
        Inc(idxOutput);
        RetString[IdxOutput] := Char(DigitValue);
      end;  // for each byte of the long word
      DigitsProcessed := 0;
    end;  // if end of word
  end;  // for each input character

  PrintableToHex := Copy(RetString, 1, idxOutput);
end;  // function PrintableToHex



procedure SetKeys(const k1, k2, k3 : string);
var
  s : string;
  kcb : const_DES_cblock;
begin
  s := unhexifystring(k1);
  move(s[1], kcb, sizeof(const_DES_cblock));
  DES_set_key(@kcb, ks1);
  s := unhexifystring(k2);
  move(s[1], kcb, sizeof(const_DES_cblock));
  DES_set_key(@kcb, ks2);
  s := unhexifystring(k3);
  move(s[1], kcb, sizeof(const_DES_cblock));
  DES_set_key(@kcb, ks3);
end;

end.

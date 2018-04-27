unit LoadFileBuffer;

{$I ConditionalCompileSymbols.txt}

{
This unit defines a class that handles the buffering and encoding of files to be downloaded
to the pin pad.
}

interface

const
  READ_RECORD_SIZE = 1;
  READ_RECORD_COUNT = 28;
  READ_BLOCK_SIZE = READ_RECORD_SIZE * READ_RECORD_COUNT;
  BUFFER_SIZE = 16 * READ_BLOCK_SIZE;           // must be multiple of block size

type
  TEncodingType = (mEncodingTypeNone, mEncodingType7Bit, mEncodingType8Bit);
  TIOBuffer = record
    BufferText : array [0..BUFFER_SIZE - 1] of char;
    IndexToGet : integer;
    IndexToPut : integer;
    TotalGets : integer;
    TotalPuts : integer;
  end;
  TLoadFileBuffer = class(TObject)
  private
    FFilePath : string;
    FEncodingType : TEncodingType;
    FileBuffer : TIOBuffer;
    FileDesc : file;
    FileEOF : boolean;
    procedure LoadBufferFromFile();
    procedure ResetFileBuffer();
    procedure SetFilePath(const NewFilePath : string);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure GetEncodedFileBlock(const qChar : pchar;
                                  const MaxChars : integer;
                                  var CharsReturned : integer;
                                  var bEOFEncountered : boolean);
    property FilePath : string  read FFilePath write SetFilePath;
    property EncodingType : TEncodingType read FEncodingType write FencodingType;
    property TotalCharsEncoded : integer read FileBuffer.TotalGets;
  end;



implementation

uses
  SysUtils,
  ExceptLog;

constructor TLoadFileBuffer.Create();
begin
  Inherited Create();
  FEncodingType := mEncodingType8Bit;
  ResetFileBuffer();
end;

destructor TLoadFileBuffer.Destroy();
begin
  Inherited Destroy();
end;

procedure TLoadFileBuffer.GetEncodedFileBlock(const qChar : pchar;
                                              const MaxChars : integer;
                                              var CharsReturned : integer;
                                              var bEOFEncountered : boolean);
{
Return the next block of encoded text from the file.
}
const
  NULL_CHAR = char($00);
var
  q : pChar;
  NextByte : byte;
  NextIndex : integer;
  ByteOffset : integer;
  EscChar : char;
begin
  CharsReturned := 0;
  q := qChar;
  while (CharsReturned < MaxChars) do
  begin
    NextIndex := (FileBuffer.IndexToGet + 1) mod sizeof(FileBuffer.BufferText);
    if (FileBuffer.TotalGets = FileBuffer.TotalPuts) then
      break;                  // Everything's been read
    EscChar := NULL_CHAR;
    ByteOffset := $00;  // default value (if no encoding needed)
    NextByte := Byte(FileBuffer.BufferText[NextIndex]);
    if (FEncodingType = mEncodingType8Bit) then
    begin
      if (NextByte in [$00..$1F, $FF]) then  // escape seq.
      begin
        if (NextByte <> $FF) then
          ByteOffset := $20;
        EscChar := Char($FF);
      end;
    end
    else if (FEncodingType = mEncodingType7Bit) then
    begin
      if (NextByte in [$00..$1F]) then  // escape seq.
      begin
        ByteOffset := $20;
        EscChar := Char($7D);
      end
      else if (NextByte in [$7D..$9F]) then
      begin
        ByteOffset := -$20;
        EscChar := Char($7E);
      end
      else if (NextByte in [$AD..$FF]) then
      begin
        ByteOffset := -$80;
        EscChar := Char($7F);
      end;
    end;
    if (EscChar <> NULL_CHAR) then  // if escape char needed.
    begin
      if (CharsReturned >= MaxChars - 1) then
        break;  //  escape char cannnot be last character to return
      q^ := EscChar;
      Inc(q);
      Inc(CharsReturned);
    end;
    q^ := Char(NextByte + ByteOffset);
    Inc(q);
    Inc(CharsReturned);
    FileBuffer.IndexToGet := NextIndex;
    Inc(FileBuffer.TotalGets);
  end;  // while (CharsReturned < MaxChars)
  bEOFEncountered := FileEOF and (FileBuffer.TotalGets = FileBuffer.TotalPuts);
  LoadBufferFromFile();
end;

procedure TLoadFileBuffer.SetFilePath(const NewFilePath : string);
{
Open the file once the file path is established.
}
const
  FILE_MODE_READ_ONLY = 0;
begin
  if (NewFilePath <> '') then
  begin
    try
      AssignFile(FileDesc, NewFilePath);
      FileMode := FILE_MODE_READ_ONLY;
      Reset(FileDesc, READ_RECORD_SIZE);
      FFilePath := NewFilePath;
    except
      on e : exception do
      begin
        UpdateExceptLog('Cannot open pin pad download file "' + NewFilePath + '" - ' + e.Message);
        FilePath := '';
      end;
    end;
    if (FFilePath = NewFilePath) then
    try
      LoadBufferFromFile();
    except
      on e : exception do
      begin
        UpdateExceptLog('Initial read failed on pin pad download file "' + NewFilePath + '" - ' + e.Message);
        FilePath := '';
      end;
    end;
  end
  else if (FFilePath <> '') then
  begin
    try
      CloseFile(FileDesc);
      ResetFileBuffer();
    except
      on e : exception do
      begin
        UpdateExceptLog('Cannot close pin pad download file "' + FFilePath + '" - ' + e.Message);
      end;
    end;
  end;
end;

procedure TLoadFileBuffer.ResetFileBuffer();
begin
  FFilePath := '';
  FileBuffer.IndexToGet := High(FileBuffer.BufferText);
  FileBuffer.IndexToPut := Low(FileBuffer.BufferText);
  FileBuffer.TotalGets := 0;
  FileBuffer.TotalPuts := 0;
  FileEOF := True;
end;

procedure TLoadFileBuffer.LoadBufferFromFile();
{
Load as much of the file as possible into the buffer.
}
var
  NumberBlocksToRead : integer;
  RecordsXfered : integer;
  CharsRead : integer;
  j : integer;
begin
  NumberBlocksToRead := (((sizeof(FileBuffer.BufferText) + FileBuffer.IndexToGet - FileBuffer.IndexToPut)
                          mod sizeof(FileBuffer.BufferText)) + 1) div READ_BLOCK_SIZE;
  for j := 1 to NumberBlocksToRead do
  begin
    try
      BlockRead(FileDesc, FileBuffer.BufferText[FileBuffer.IndexToPut], READ_RECORD_COUNT, RecordsXfered);
      FileEOF := Eof(FileDesc) or (RecordsXfered < READ_RECORD_COUNT);
      CharsRead := RecordsXfered * READ_RECORD_SIZE;
      FileBuffer.IndexToPut := (FileBuffer.IndexToPut + CharsRead) mod sizeof(FileBuffer.BufferText);
      Inc(FileBuffer.TotalPuts, CharsRead);
      if (FileEOF) then
        break;
    except
      on e : exception do
      begin
        UpdateExceptLog('File block read failed on pin pad download file "' + FilePath + '" - ' + e.Message);
        FilePath := '';
        break;
      end;
    end;
  end;
end;

end.

unit DevMessage;
{$I ConditionalCompileSymbols.txt}


interface


const
  MAX_BUFFER_SIZE = 247;

type
  TDevMessage = class(TObject)
  private
    { Private declarations }
    FDevBuffer : array [0..MAX_BUFFER_SIZE] of char;
    FDevBufferLen : integer;
    FBufferLRC : byte;
    function GetDevBufferRead() : string;
  public
    { Public declarations }
    constructor Create();
    destructor Destroy(); override;
    procedure DevBufferAppend(const NewChar : char);
    property BufferLength : integer read FDevBufferLen;
    property DevBufferRead : string read GetDevBufferRead;
    property BufferLRC : byte  read FBufferLRC;
  end;

implementation

uses
   SysUtils;

constructor TDevMessage.Create();
begin
  Inherited Create();
  FDevBufferLen := 0;
  FBufferLRC := $00;
end;

destructor TDevMessage.Destroy();
begin
  Inherited Destroy();
end;

function TDevMessage.GetDevBufferRead() : string;
begin
  Result := '';
  if (FDevBufferLen > 0) then
  begin
    SetLength(Result, FDevBufferLen);
    Move(FDevBuffer[0], Result[1], FDevBufferLen)
  end;
end;

procedure TDevMessage.DevBufferAppend(const NewChar : char);
begin
  if (FDevBufferLen < MAX_BUFFER_SIZE) then
  begin
    FDevBuffer[FDevBufferLen] := NewChar;
    Inc(FDevBufferLen);
    FBufferLRC := FbufferLRC xor Byte(NewChar);
  end
  else
  begin
    raise Exception.Create('Message overflow from PIN pad');
  end;
end;

end.

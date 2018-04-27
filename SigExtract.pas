unit SigExtract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus;

  
type
  TSigExtractMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    SigImg: TImage;
    OpenDialog1: TOpenDialog;
    ComboBox1: TComboBox;
    CopyToClipBoard: TButton;
    procedure Open1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure CopyToClipBoardClick(Sender: TObject);
  private
    { Private declarations }
    function ProcessSig(SigData : ansistring) : TImage;
  public
    { Public declarations }
  end;

var
  SigExtractMain: TSigExtractMain;

implementation

{$R *.dfm}

uses AdPort, PosMisc, StrUtils, Clipbrd, IngSig;

procedure TSigExtractMain.Open1Click(Sender: TObject);
var
  InFile : TextFile;
  readstr : ansistring;
  splitpoint : integer;
  authid : ansistring;
  sigdata : ansistring;
  authidint : longint;
begin
  if OpenDialog1.Execute then
  begin
    AssignFile(InFile, OpenDialog1.FileName);
    Reset(InFile);
    readln(InFile, readstr);
    if readstr = 'AUTHID,SIGNATUREDATA' then
    begin
      ComboBox1.Clear;
      while not System.Eof(InFile) do
      begin
        readln(InFile, readstr);
        splitpoint := pos(',', readstr);
        authid := AnsiLeftStr(readstr, splitpoint - 1);
        if (splitpoint > 0) then
        begin
          try
            authidint := StrToInt(authid);
            sigdata := AnsiRightStr(readstr, length(readstr)-splitpoint);
            ComboBox1.AddItem(authid, Self.ProcessSig(sigdata));
          except
          end;
        end;
      end;
      if (Self.ComboBox1.Items.Count > 0) then
        Self.ComboBox1.Enabled := True;
    end;
    CloseFile(InFile);
  end;
end;

function TSigExtractMain.ProcessSig(SigData : ansistring) : TImage;
var
  Sig : TIngSig;
  img : TImage;
begin
  img := TImage.Create(ComboBox1);
  img.Width := Self.SigImg.Width;
  img.Height := Self.SigImg.Height;
  
  Sig := TIngSig.Create();
  Sig.PenWidth := 2;
  Sig.SigData3BA := SigData;
  img.Picture.Bitmap := Sig.GetBitmap(Self.SigImg.Width, Self.SigImg.Height);
  Sig.Destroy;
  
  Result := img;
end;


procedure TSigExtractMain.ComboBox1Change(Sender: TObject);
begin
  if Self.ComboBox1.Enabled and (Self.ComboBox1.ItemIndex >= 0) then
  begin
    Self.SigImg.Picture.Bitmap := TImage(Self.ComboBox1.Items.Objects[Self.ComboBox1.ItemIndex]).Picture.Bitmap;
    Self.CopyToClipBoard.Enabled := True;
  end
  else
  begin
    Self.SigImg.Picture.Bitmap := nil;
    Self.CopyToClipBoard.Enabled := False;
  end;
end;

procedure TSigExtractMain.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TSigExtractMain.CopyToClipBoardClick(Sender: TObject);
begin
  Clipboard.Assign(Self.SigImg.Picture)

end;

end.

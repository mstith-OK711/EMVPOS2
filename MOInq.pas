unit MOInq;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, IdHTTP;

type
  TMORec = record
    SerialNo : string[20];
    DocValue : currency;
    PurchTS : TDateTime;
    Store : integer;
    TransNo : integer;
    Voided : boolean;
    VoidTS : TDateTime;
    VoidStore : integer;
  end;

  TfmMOInq = class;  // forward declaration to allow some bi-directional referencing

  THTTPInquireThread = class(TThread)
  private
    //FLastException: Exception;
    FDocNo,
    FMOurl : string;
    FHTTP : TIdHTTP;
    FOwner : TfmMOInq;
    FLogStr : string;
    FStore : integer;
    FFound : boolean;
    FSysErr : boolean;
  protected
    procedure Execute; override;
    procedure ParseXML(xmlin : string);
    procedure UpdateScreen;
    procedure UpdateExceptLog;
  public
    constructor Create(CreateSuspended : boolean);
    property Store : integer read FStore write FStore;
    property DocNo : string read FDocNo write FDocNo;
    property MOUrl : string write FMOurl;
    property Owner : TfmMOInq write FOwner;
    property Found : boolean read FFound;
    property SysErr : boolean read FSysErr;
  end;

  TfmMOInq = class(TForm)
    lStatus: TPanel;
    btnCancel: TButton;
    DocNo: TEdit;
    Label1: TLabel;
    btnFind: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure DocNoChange(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
  private
    { Private declarations }
    FMO : TMORec;
    FHIT : THTTPInquireThread;
    procedure DoFind();
  public
    { Public declarations }
    procedure ProcessScan(const symbology, data : string);
    property MO : TMORec read FMO;
  end;

var
  fmMOInq: TfmMOInq;

implementation

uses POSMain, StrUtils, DateUtils, XMLDoc, xmldom, XMLIntf, ExceptLog, ActiveX;

{$R *.dfm}

procedure TfmMOInq.FormShow(Sender: TObject);
begin
  self.Top := Trunc(((Screen.Height - self.Height) / 2)) + 100;
  self.Left := Trunc(((Screen.Width - self.Width) / 2));
  lStatus.Caption := 'Please scan MO barcode';
end;

procedure TfmMOInq.btnFindClick(Sender: TObject);
begin
  DoFind();
end;

procedure TfmMOInq.DocNoChange(Sender: TObject);
begin
  btnFind.Visible := length(DocNo.Text) = 10;
end;

procedure TfmMOInq.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := 1;
  Self.Close;
end;

procedure TfmMOInq.DoFind();
var
  timeout : integer;
  endtime : TDateTime;
begin
  try
    timeout := fmPos.Config.Int['MO_INQ_TIMEOUT'];
  except
    timeout := 30;
  end;

    FHIT := THTTPInquireThread.Create(True);
    FHIT.Store := StrToInt(Setup.NUMBER);
    FHIT.DocNo := DocNo.Text;
    FHIT.MOUrl := fmPos.Config.Str['MO_CH_POSTURL'];
    FHIT.Owner := Self;
    FHIT.Resume;
    endtime := Now + (timeout * OneSecond);
    while (not FHIT.Terminated) and (Now < endtime) do
      Application.ProcessMessages;
    if FHIT.Terminated then
    begin
      FHIT.WaitFor;
      if FHIT.SysErr then
      begin
        fmPOS.POSError('Network error - call support');
        Self.ModalResult := mrCancel;
      end
      else if FHIT.Found then
      begin
        if MO.Voided then
        begin
          fmPOS.POSError('Docment already voided');
          Self.ModalResult := mrCancel;
        end
        else
          Self.ModalResult := mrOK;
      end
      else
      begin
        fmPOS.POSError('Document not found in system');
        Self.ModalResult := mrCancel;
      end;
    end
    else
    begin
      FHIT.Terminate;
      fmPOS.POSError('Inquiry timed out');
      Self.ModalResult := mrCancel;
    end;
end;

procedure TfmMOInq.ProcessScan(const symbology, data: string);
begin
  if symbology = fmPos.Config.Str['SCAN_MO_SYMBOLOGY'] then
  begin
    DocNo.Text := StrUtils.LeftStr(data,10);
    DoFind();
  end
  else
    fmPOS.POSError('Barcode Symbology incorrect - "' + symbology + '"');
end;

{ THTTPInquireThread }

constructor THTTPInquireThread.Create(CreateSuspended: boolean);
begin
  inherited create(CreateSuspended);
  FHTTP := TIdHTTP.Create(Application);
end;

procedure THTTPInquireThread.Execute;
var
  xmlstr : string;
begin
  CoInitialize(nil);
  Self.FLogStr := 'Making Inquiry';
  Self.Synchronize(self.UpdateScreen);
  try
    xmlstr := FHTTP.Get(Self.FMOurl + '?' + 'method=inquire&SerialNo=' + trim(Self.FDocNo) + '&Store=' + IntToStr(Self.FStore));
  except on E: Exception do
    begin
      Self.FFound := False;
      Self.FLogStr := 'Problem Getting inquiry: "' + E.ClassName + '" - ' + E.Message;
      Self.Synchronize(UpdateExceptLog);
    end;
  end;
  if FHTTP.ResponseCode = 200 then
  begin
    Self.FFound := True;
    Self.FLogStr := 'Parsing Response';
    Self.Synchronize(self.UpdateScreen);
    try
      Self.ParseXML(xmlstr);
    except on E : Exception do
      begin
        Self.FSysErr := True;
        Self.FFound := False;
        Self.FLogStr := 'Exception trying to ParseXML: ' + E.Message;
        Self.Synchronize(UpdateExceptLog);
      end;
    end;
  end
  else if FHTTP.ResponseCode = 500 then
  begin
    Self.FSysErr := True;
  end
  else
    Self.FFound := False;
  Self.FLogStr := 'Terminating Thread';
  Self.Synchronize(self.UpdateScreen);
  Self.Terminate;
  CoUninitialize;
end;

procedure THTTPInquireThread.ParseXML(xmlin: string);
var
  xd : IXMLDocument;
  FormatSettings: TFormatSettings;
  inl : IXMLNodeList;
begin
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'hh:mm:ss';
  xd := TXMLDocument.Create(nil);  // requires unit xmldoc
  xd.LoadFromXML( xmlin );
//<MOInfo>
//  <Store>720</Store>
//  <SerialNo>2003361009</SerialNo>
//  <DocValue>4.29</DocValue>
//  <PurchTS>2008-09-30 12:46:49</PurchTS>
//  <TransNo>7110</TransNo>
//  <Voided>False</Voided>
//  <VoidTS></VoidTS>
//  <VoidStore></VoidStore>
//</MOInfo>
  if xd.ChildNodes.IndexOf('MOInfo') >= 0 then
  begin
    inl := xd.ChildNodes.Nodes['MOInfo'].ChildNodes;
    try
      Self.FFound := True;
      self.Fowner.FMO.Store := StrToInt(inl.Nodes['Store'].Text);
      self.Fowner.FMO.SerialNo := inl.Nodes['SerialNo'].Text;
      self.Fowner.FMO.DocValue := StrToCurr(inl.Nodes['DocValue'].Text);
      self.Fowner.FMO.PurchTS := StrToDateTime(inl.Nodes['PurchTS'].Text, FormatSettings);
      self.FOwner.FMO.TransNo := StrToInt(inl.Nodes['TransNo'].Text);
      self.FOwner.FMO.Voided := inl.Nodes['Voided'].Text = 'True';
      if inl.Nodes['VoidTS'].Text <> '' then
        self.FOwner.FMO.VoidTS := StrToDateTime(inl.Nodes['VoidTS'].Text, FormatSettings)
      else
        self.Fowner.FMO.VoidTS := 0;
      if inl.Nodes['VoidStore'].Text <> '' then
        self.Fowner.FMO.VoidStore := StrToInt(inl.Nodes['VoidStore'].Text)
      else
        self.Fowner.FMO.VoidStore := -1;
    except on E: Exception do
      begin
        Self.FFound := False;
        Self.FLogStr := 'Exception Parsing Response ';
        Self.Synchronize(self.UpdateScreen);
        Self.FLogStr := Self.FLogStr + E.Message;
        Self.Synchronize(UpdateExceptLog);
      end;
    end;
  end
  else
  begin
    Self.FFound := False;
    Self.FLogStr := 'Response Malformed';
    Self.Synchronize(self.UpdateScreen);
    Self.FLogStr := Self.FLogStr + ': ' + xmlin;
    Self.Synchronize(UpdateExceptLog);
  end;
end;

procedure THTTPInquireThread.UpdateExceptLog;
begin
  ExceptLog.UpdateExceptLog(FLogStr);
end;

procedure THTTPInquireThread.UpdateScreen;
begin
  FOwner.lStatus.Caption := FLogStr;
end;





end.

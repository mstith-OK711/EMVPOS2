unit MOLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMOmode = (MOmLoad, MOmAssign);

  TfmMOLoad = class(TForm)
    lStatus: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    btnLoad: TButton;
    btnCancel: TButton;
    docnostart: TLabel;
    docnoend: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Fmode : TMOmode;
    procedure momoveinsert ( moaction : char; rangeb, rangee : currency );
  public
    procedure ProcessScan(const symbology, data : string);
    { Public declarations }
    property loadmode : TMOmode read Fmode write Fmode;
  end;

var
  fmMOLoad: TfmMOLoad;

implementation

{$R *.dfm}

uses StrUtils, POSMain, DBInt, POSDM, POSMisc, ExceptLog, DateUtils;

procedure TfmMOLoad.btnCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfmMOLoad.btnLoadClick(Sender: TObject);
var
  rb, re, lp : currency;
begin
  if Fmode = MOmAssign then
  begin
    rb := StrToCurr(docnostart.Caption);
    re := StrToCurr(docnoend.Caption);

    self.momoveinsert('A', rb, re );
  end
  else if fMode = MOmLoad then
  begin
    rb := fmPos.Config.Cur['MO_LOADEDBEGIN'];
    re := fmPos.Config.Cur['MO_LOADEDEND'];
    lp := fmPos.Config.Cur['MO_LASTPRINTED'];
    if (lp >= rb) and (lp <= re) then
    begin                                   // we've printed from this stack
      self.momoveinsert('S', rb, lp);       // mark beginning of range as sold
      if lp < re then
        self.momoveinsert('R', lp + 1.0, re)  // and remove a partial
    end
    else
      self.momoveinsert('R', rb, re);  // last printed isn't from this stack, so remove entire stack

    rb := StrToCurr(docnostart.Caption);
    re := StrToCurr(docnoend.Caption);
    fmPos.Config.Cur['MO_LOADEDBEGIN'] := rb;
    fmPos.Config.Cur['MO_LOADEDEND'] := re;

    self.momoveinsert('L', rb, re );
  end;
  fmPOS.SendMOSMessage(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPOST)));
  Self.ModalResult := 1;
end;

procedure TfmMOLoad.FormShow(Sender: TObject);
begin
  self.Top := Trunc(((Screen.Height - self.Height) / 2)) + 100;
  self.Left := Trunc(((Screen.Width - self.Width) / 2));
  btnLoad.Enabled := False;
  if Fmode = MOmAssign then
  begin
    self.Caption := 'Money Order Assign';
    self.lStatus.Color := clYellow;
    self.btnLoad.Caption := 'Assign';
  end
  else if Fmode = MOmLoad then
  begin
    self.Caption := 'Money Order Load';
    self.lStatus.Color := clRed;
    self.btnLoad.Caption := 'Load'
  end;
  lStatus.Caption := 'Please scan beginning MO barcode';
end;

procedure TfmMOLoad.ProcessScan(const symbology, data: string);
var
  t, checkno : string;
  bclen : integer;
begin
  try
    bclen := fmPos.Config.Int['MO_DOCNO_LENGTH'];
  except
    fmPos.Config.Int['MO_DOCNO_LENGTH'] := 10;
    bclen := 10
  end;
  if symbology = fmPos.Config.Str['SCAN_MO_SYMBOLOGY'] then
  begin
    if length(data) = (bclen + 3) then
      checkno := StrUtils.RightStr(data,bclen)
    else if length(data) = (bclen + 1) then
      checkno := StrUtils.LeftStr(data,bclen);
    if docnostart.Caption = '' then
    begin
      docnostart.Caption := checkno;
      lStatus.Caption := 'Please scan ending MO barcode';
    end
    else if docnoend.Caption = '' then
    begin
      docnoend.Caption := checkno;
      lStatus.Caption := 'Please verify MO document numbers';
      btnLoad.Enabled := True;
      if StrToCurr(docnoend.Caption) < StrToCurr(docnostart.Caption) then
      begin
        t := docnoend.Caption;
        docnoend.Caption := docnostart.Caption;
        docnostart.Caption := t;
      end;
    end
    else
    begin
      docnostart.Caption := checkno;
      docnoend.Caption := '';
      lStatus.Caption := 'Please scan ending MO barcode';
    end;
  end
  else
    fmPOS.POSError('Barcode Symbology incorrect - "' + symbology + '"');
end;

procedure TfmMOLoad.FormCreate(Sender: TObject);
begin
  self.Fmode := MOmLoad;
end;

procedure TfmMOLoad.momoveinsert(moaction: char; rangeb, rangee: currency);
var
  tts : TDateTime;
begin
  try
    POSDataMod.Cursors.StartTransaction;
    with POSDataMod.Cursors['MOM-Insert'] do
    begin
      ParamByName('pAct').AsString := moaction;
      ParamByName('pRangeB').AsString := CurrToStr(rangeb);
      ParamByName('pRangeE').AsString := CurrToStr(rangee);
      tts := Now();
      ParamByName('pTS').AsDateTime := tts;
      ParamByName('pTSMS').AsInteger := MillisecondOf(tts);
      ExecQuery();
      Close();
    end;
    POSDataMod.Cursors.Commit;
  except
    on E: Exception do
    begin
       POSDataMod.Cursors.Rollback;
       UpdateExceptLog('Cannot post money order move ' + E.Message);
       fmPOS.POSError('Failed to post MO movement - call support');
    end;
  end;
end;

end.

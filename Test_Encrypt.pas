unit Test_Encrypt;

interface

uses
  TestFramework,
  Classes,
  IdSSLOpenSSLHeaders,
  Encrypt;

type
  Check_Encrypt = class(TTestCase)
  private
  public
    procedure setUp;  override;
    procedure tearDown; override;
  published
    procedure VerifyPKCS5pad;
    procedure VerifyPKCS5unpad;
    procedure VerifyEncryptDecryptCycle;
  end;

implementation

uses
  SysUtils,
  IdGlobal,
  EncryptKey1, EncryptKey2,
  TestExtensions;

function Suite : ITestSuite;
begin
  result := TTestSuite.Create('Encrypt Tests');

  result.addTest(Check_Encrypt.Suite);

end;

{ Check_Encrypt }

procedure Check_Encrypt.setUp;
begin
  inherited;
  IdSSLOpenSSLHeaders.Load();
  SetKeys(GetEncryptKey1(), GetEncryptKey2(), GetEncryptKey1());
end;

procedure Check_Encrypt.tearDown;
begin
  inherited;
  IdSSLOpenSSLHeaders.Unload();
end;

procedure Check_Encrypt.VerifyEncryptDecryptCycle;
var
  i, e, o : string;
begin
  i := 'xxxx';
  e := encryptstring(i);
  o := decryptstring(e);
  check(e = 'A50E906424469D37', i + ' encrypts to ' + e);
  check(o = i, i + ' encrypts and decrypts to ' + o);
  i := '';
  o := decryptstring(encryptstring(i));
  check(o = i, i + ' encrypts and decrypts to ' + o);
  i := 'XXXXXXXX';
  o := decryptstring(encryptstring(i));
  check(o = i, i + ' encrypts and decrypts to ' + o);
  i := 'XXXXXXXXX';
  o := decryptstring(encryptstring(i));
  check(o = i, i + ' encrypts and decrypts to ' + o);
  i := 'XXXXXXXXXXXXXXXX';
  o := decryptstring(encryptstring(i));
  check(o = i, i + ' encrypts and decrypts to ' + o);
  e := '4B15AD1134860C97DA573A2F56E7C73BA2FA1AF12956F25D';
  o := decryptstring(e);
  check(o = '4485532222222224', e + ' decrypts to ' + o);
  e := 'FE31E481EA7EEEF7F77006DF819386C5A2FA1AF12956F25D';
  o := decryptstring(e);
  check(o = '6372350000000006', e + ' decrypts to ' + o);
  e := '03F1CEFA9B9E409904FC5157F78DE2BF';
  o := decryptstring(e);
  check(o = 'VISA TEST/GOOD', e + ' decrypts to ' + o);
  e := '03F1CEFA9B9E40990295B08A757D528DC3D25D4F0EA78243';
  o := decryptstring(e);
  check(o = 'VISA TEST CARD/GOOD', e + ' decrypts to ' + o);
end;

procedure Check_Encrypt.VerifyPKCS5pad;
var
  i, o : string;
begin
  i := 'xxxx';
  o := pkcs5pad(i);
  check(o = ('xxxx' +#04 +#04 +#04 +#04), i + ' pads to ' + o);
  i := 'x';
  o := pkcs5pad(i);
  check(o = ('x' +#07 + #07 + #07 + #07 + #07 + #07 + #07), i + ' pads to ' + o);
  i := 'xxxxxxx';
  o := pkcs5pad(i);
  check(o = ('xxxxxxx' +#01 ), i + ' pads to ' + o);
  i := 'xxxxxxxx';
  o := pkcs5pad(i);
  check(o = 'xxxxxxxx', i + ' pads to ' + o);
  i := '';
  o := pkcs5pad(i);
  check(o = '', i + ' pads to ' + o);
end;

procedure Check_Encrypt.VerifyPKCS5unpad;
var
  i, o : string;
begin
  i := 'xxxx' +#04 +#04 +#04 +#04;
  o := pkcs5unpad(i);
  check(o = 'xxxx', i + ' unpads to ' + o);
  i := 'x' + #07 + #07 + #07 + #07 + #07 + #07 + #07;
  o := pkcs5unpad(i);
  check(o = 'x', i + ' unpads to ' + o);
  i := 'xxxxxxx' + #01;
  o := pkcs5unpad(i);
  check(o = 'xxxxxxx', i + ' unpads to ' + o);
  i := 'xxxxxxxx';
  o := pkcs5unpad(i);
  check(o = 'xxxxxxxx', i + ' unpads to ' + o);
  i := '';
  o := pkcs5unpad(i);
  check(o = '', i + ' unpads to ' + o);
end;

initialization
  TestFramework.RegisterTest(Suite);
end.

{-----------------------------------------------------------------------------
 Unit Name: GiftRestrict
 Author:    Gary Whetton
 Date:      9/11/2003 3:03:06 PM
 Revisions: Build Number   Date      Author

-----------------------------------------------------------------------------}
unit GiftRestrict;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ElastFrm;

type
  TfmGiftRestrict = class(TForm)
    ElasticForm1: TElasticForm;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure FormShow(Sender: TObject);
    procedure OnGiftCardRestrict1Click(Sender: TObject);
    procedure OnGiftCardRestrict2Click(Sender: TObject);
    procedure OnGiftCardRestrict3Click(Sender: TObject);
    procedure OnGiftCardRestrict4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GiftCardRestrictionCode : Integer;
  end;

var
  fmGiftRestrict: TfmGiftRestrict;

implementation

uses POSMain;

{$R *.DFM}

{-----------------------------------------------------------------------------
  Name:      TfmGiftRestrict.FormShow
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftRestrict.FormShow(Sender: TObject);
begin
  GiftCardRestrictionCode := RC_UNSPECIFIED;
  Button1.Caption := GIFT_CARD_RESTRICTION_DESC[RC_NO_RESTRICTION];
  Button2.Caption := GIFT_CARD_RESTRICTION_DESC[RC_NO_SIN];
  Button3.Caption := GIFT_CARD_RESTRICTION_DESC[RC_ONLY_FUEL];
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftRestrict.OnGiftCardRestrict1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftRestrict.OnGiftCardRestrict1Click(Sender: TObject);
begin
  GiftCardRestrictionCode := RC_NO_RESTRICTION;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftRestrict.OnGiftCardRestrict2Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftRestrict.OnGiftCardRestrict2Click(Sender: TObject);
begin
  GiftCardRestrictionCode := RC_NO_SIN;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftRestrict.OnGiftCardRestrict3Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftRestrict.OnGiftCardRestrict3Click(Sender: TObject);
begin
  GiftCardRestrictionCode := RC_ONLY_FUEL;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmGiftRestrict.OnGiftCardRestrict4Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmGiftRestrict.OnGiftCardRestrict4Click(Sender: TObject);
begin
  GiftCardRestrictionCode := RC_UNKNOWN;  // Use existing restriction (to be determined by CRD server).
  Close;
end;

end.
// ... GiftCard

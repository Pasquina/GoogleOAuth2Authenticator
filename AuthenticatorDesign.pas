unit AuthenticatorDesign;

interface

procedure Register;

implementation

uses OAuth2AuthenticatorGoogle, System.Classes;

procedure Register;
begin
  RegisterComponents('REST Client', [TOAuth2AuthenticatorGoogle]);
end;

end.

unit AuthenticatorDesign;

interface

procedure Register;

implementation

uses OAuth2AuthenticatorGoogle, pVDEtc, pVDLogger, System.Classes;

procedure Register;
begin
  RegisterComponents('REST Client', [TOAuth2AuthenticatorGoogle,
                                     TVDEtc,
                                     TVDLogger]);
end;

end.

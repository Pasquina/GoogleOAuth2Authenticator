unit pOA2Cons;

interface

const

  { From https://accounts.google.com/.well-known/openid-configuration and
    https://developers.google.com/identity/protocols/OAuth2InstalledApp }

  ExBaseURL                = 'https://www.googleapis.com';
  ExRequestResource        = 'oauth2/v4/token';
  ExCode                   = 'code';
  ExClientID               = 'client_id';
  ExClientSecret           = 'client_secret';
  ExRedirectURI            = 'redirect_uri';
  ExGrantType              = 'grant_type';
  ExAuthorizationCode      = 'authorization_code';

  ExAccessToken            = 'access_token';
  ExRefreshToken           = 'refresh_token';
  ExExpiresIn              = 'expires_in';

implementation

end.

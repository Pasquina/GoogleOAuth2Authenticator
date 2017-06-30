unit OAuth2AuthenticatorGoogle;

interface

uses
  System.SysUtils, System.Classes, Data.Bind.Components, Data.Bind.ObjectScope, REST.Client, REST.Authenticator.OAuth;

type
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  TOAuth2AuthenticatorGoogle = class(TOAuth2Authenticator)
  private
    { Private declarations }
    FLoginHint: string;
    procedure SetLoginHint(const Value: string);
    function GetAuthCodeGoogle: Boolean;
    function GetTokensGoogle: Boolean;

  protected
    { Protected declarations }
    procedure DoAuthenticate(ARequest: TCustomRESTRequest); override;
    procedure WebFormTitleChanged(const ATitle: string; var DoCloseWebView: Boolean);

  public
    { Public declarations }
  published
    { Published declarations }
    property LoginHint: string // Google allows for a Login Hint to make the process a little eaier
      read FLoginHint write SetLoginHint;
  end;

implementation

uses
  REST.Authenticator.OAuth.WebForm.Win, REST.Utils, System.StrUtils, VCL.Dialogs, REST.Types, pOA2Cons, System.DateUtils;

{ TOAuth2AuthenticatorGoogle }

{ DoAuthenticate is executed as a result of a REST Request using a Client that uses this
  authenticator. It first checks for an access token, and if none is found, invokes the
  authentication routines. Finally, the access token is added to the request. }

procedure TOAuth2AuthenticatorGoogle.DoAuthenticate(ARequest: TCustomRESTRequest);
begin
  if AccessToken = '' then    // no access token; must authorize
    if GetAuthCodeGoogle then // obtain the authorization code
      GetTokensGoogle;        // exchange auth code for access tokens
  inherited;                  // normal processing inserts access code into request
end;

procedure TOAuth2AuthenticatorGoogle.SetLoginHint(const Value: string);
begin
  FLoginHint := Value;
end;

{ Extract Authorization Code from the Web Form when returned by Google }

procedure TOAuth2AuthenticatorGoogle.WebFormTitleChanged(const ATitle: string; var DoCloseWebView: Boolean);
begin
  if (StartsText('Success code', ATitle)) then // if success code indicated
  begin
    AuthCode := Copy(                          // save the authorization code
      ATitle, 14, Length(ATitle));
    if (AuthCode <> '') then                   // if authorization code found
      DoCloseWebView := True;                  // close the browser form
  end;
end;

{ Display browser window with OAuth2 login screen }

function TOAuth2AuthenticatorGoogle.GetAuthCodeGoogle: Boolean;
var
  LURL: TStringBuilder;
  LBrowser: Tfrm_OAuthWebForm;
begin
  Result := False;               // assume failure
  { build the URL to obtain the authorization code }
  LURL := TStringBuilder.Create; // create the URL build area
  try
    LURL.Append(AuthorizationEndpoint);
    LURL.AppendFormat('?response_type=%s', [URIEncode('code')]);
    LURL.AppendFormat('&client_id=%s', [URIEncode(ClientID)]);
    LURL.AppendFormat('&redirect_uri=%s', [URIEncode(RedirectionEndPoint)]);
    LURL.AppendFormat('&scope=%s', [URIEncode(Scope)]);
    LURL.AppendFormat('&login_hint=%s', [URIEncode(LoginHint)]);
    { Display the OAuth2 in a web browser }
    LBrowser := Tfrm_OAuthWebForm.Create(nil);        // create the browser form
    try
      LBrowser.OnTitleChanged := WebFormTitleChanged; // event to check for an auth code
      LBrowser.ShowWithURL(LURL.ToString);            // show the OAuth2 web page
    finally
      LBrowser.Release;                               // free the browser window
      if AuthCode <> '' then
        Result := True;                               // auth code successfully obtained
    end;
  finally
    LURL.Free;                                        // free the URL build area
  end;
end;

{ Exchange the authorization code from Google for the access tokens }

function TOAuth2AuthenticatorGoogle.GetTokensGoogle: Boolean;
var
  LClient: TRESTClient;                               // to request the exchange
  LRequest: TRestRequest;                             // to request the exchange
  LToken: string;                                     // local token hold area
begin
  LClient := TRESTClient.Create(ExBaseURL);           // create the client
  LRequest := TRestRequest.Create(nil);               // create the request
  try
    LRequest.Client := LClient;                       // chain the request to the client
    LRequest.Method := rmPOST;
    LRequest.Resource := ExRequestResource;
    // required parameters
    LRequest.AddParameter(ExCode, AuthCode, pkGETorPOST);
    LRequest.AddParameter(ExClientID, ClientID, pkGETorPOST);
    LRequest.AddParameter(ExClientSecret, ClientSecret, pkGETorPOST);
    LRequest.AddParameter(ExRedirectURI, RedirectionEndPoint, pkGETorPOST);
    LRequest.AddParameter(ExGrantType, ExAuthorizationCode, pkGETorPOST);

    LRequest.Execute;                 // attempt token exchange

    { Test successful return of tokens. Save if returned. }

    if LRequest.Response.GetSimpleValue(ExAccessToken, LToken) then
    begin
      AccessToken := LToken;          // save access token if present
    end;

    if LRequest.Response.GetSimpleValue(ExRefreshToken, LToken) then
    begin
      RefreshToken := LToken;         // save refresh token if present
    end;

    if LRequest.Response.GetSimpleValue(ExExpiresIn, LToken) then
    begin
      AccessTokenExpiry := IncSecond( // save token expiry as datetime
        Now(), LToken.ToInteger);
    end;

    if (AccessToken <> '') and (RefreshToken <> '') then
      Result := True                  // both tokens must be present to return true
    else
      Result := False;                // failed to get tokens

  finally
    LRequest.Free;                    // release resources
    LClient.Free;                     // release resources
  end;
end;

end.

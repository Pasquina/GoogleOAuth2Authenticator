# GoogleOAuth2Authenticator
## Delphi OAuth2 Authenticator Component

This component is descended from the TOAuth2Authenticator provided by Embarcadero. It makes extenstion to the Embarcadero component that support the Google implementation of OAuth2.

## Caveats

  * The code provided has been tested for Windows VCL 32-bit and VCL 64-bit.
  * Because the code uses a TBrowser component, additional development is required to also support FireMonkey and (if possible) Unix.

## Usage

  * Install the component in the customary manner you use for your own custom component development.
  * Drop the component on a form in place of the customary OAUTH2Authenticator provided by Embarcadero.
  * Make sure the TRESTClient you are using is connected to the OAUTH2AuthenticatorGoogle component.
  * Provide the component with the appropriate URLs, URIs, Client ID, Client Secret, etc.
  * When you make a REST request, Google OAuth2 Authentication will take place if no Access Code is detected. No special handling of authentication is required other than the use and property settings in this component.

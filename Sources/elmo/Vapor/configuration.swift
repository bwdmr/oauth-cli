import Vapor
import OAuth



struct EmailAccessToken: OAuthHeadToken, GoogleToken {
  enum CodingKeys: String, CodingKey {
    case endpoint = "endpoint"
    case accessToken = "access_token"
    case email = "email"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case scope = "scope"
    case tokenType = "token_type"
  }
  
  var endpoint: URL?
  var accessToken: AccessTokenClaim?
  var email: EmailClaim?
  var expiresIn: ExpiresInClaim?
  var refreshToken: RefreshTokenClaim?
  var scope: ScopeClaim?
  var tokenType: TokenTypeClaim?
}



public func configure(
  _ app: Application,
  port: String,
  clientID: String,
  clientSecret: String,
  redirectURI: String,
  scope: String
) async throws {
  guard let port = Int(port) else { throw Abort(.internalServerError) }
  
  app.http.server.configuration.port = port
  
  app.middleware = .init()
  app.middleware.use(app.sessions.middleware)
  
  let tokenEndpoint = "https://oauth2.googleapis.com/token"
  let authenticationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
  let infoEndpoint = "https://www.googleapis.com/oauth2/v3/userinfo"
  guard let infoendpointURL = URL(string: infoEndpoint) else { throw Abort(.notFound) }
  let clientID = ClientIDClaim(stringLiteral: clientID)
  let clientSecret = ClientSecretClaim(stringLiteral: clientSecret)
  let redirectURI = RedirectURIClaim(stringLiteral: redirectURI)
  let scopeClaim = ScopeClaim(stringLiteral: scope)
  let emailToken = EmailAccessToken(endpoint: infoendpointURL, scope: scopeClaim)
 
  let oauthGoogle = GoogleService(
    authenticationEndpoint: authenticationEndpoint,
    tokenEndpoint: tokenEndpoint,
    clientID: clientID,
    clientSecret: clientSecret,
    redirectURI: redirectURI,
    scope: scopeClaim
  )
 
  try await app.oauth.google.make(service: oauthGoogle, token: [emailToken], head: emailToken)
}

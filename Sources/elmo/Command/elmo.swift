import Vapor
import OAuthKit
import ArgumentParser



struct PreflightCode: Content {
  var clientID: String
  var redirectURI: String
  var scope: String
  var responseType: String?
  
  init(
    clientID: String,
    redirectURI: String,
    responseType: String? = nil,
    scope: String
  ) {
    let responseType = responseType ?? "code"
    
    self.clientID = clientID
    self.redirectURI = redirectURI
    self.responseType = responseType
    self.scope = scope
  }
  
  func preflightURL() throws -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "accounts.google.com"
    components.path = "/o/oauth2/v2/auth"
    components.queryItems = [
      URLQueryItem(name: "client_id", value: self.clientID),
      URLQueryItem(name: "redirect_uri", value: self.redirectURI),
      URLQueryItem(name: "response_type", value: self.responseType),
      URLQueryItem(name: "scope", value: self.scope),
    ]
    
    guard let url = components.url else {
      throw Abort(.internalServerError) }
    
    return url
  }
  
  func preflightRequest() async throws {
    let url = try preflightURL()
    
    let process = Process()
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
    process.arguments = ["-a", "/Applications/Firefox.app", "\(url.absoluteString)" ]
    try process.run()
  }
}



@main
public struct Elmo: AsyncParsableCommand {
  public init() {}
  
  public func preflight(
    clientID: String,
    redirectURI: String,
    scope: String
  ) async throws {
    
    let preflight = PreflightCode(
      clientID: clientID,
      redirectURI: redirectURI,
      scope: scope)
    try await preflight.preflightRequest()
  }
  
  
  public func serve(
    port: String,
    clientID: String,
    clientSecret: String,
    redirectURI: String,
    scope: String
  ) async throws {
    let app = Application()
    defer { app.shutdown() }

    try await configure(
      app,
      port: port,
      clientID: clientID,
      clientSecret: clientSecret,
      redirectURI: redirectURI,
      scope: scope )
    try app.server.start()
    try await app.server.onShutdown.get()
  }
  
  
  public struct Options: ParsableArguments {
    public init() {}
    
    @ArgumentParser.Flag(name: .customLong("google"), help: "The Provider relied on.")
    var isGoogle: Int
    
    @ArgumentParser.Option(name: [.customLong("clientid")], help: "The client id assigned by the OAuthProvider.")
    var clientID: String?
    
    @ArgumentParser.Option(name: [.customLong("clientsecret")], help: "The client secret assigned by the OAuthProvider.")
    var clientSecret: String?
    
    @ArgumentParser.Option(name: [.customLong("redirecturi")], help: "The client redirect uri set by the User to redirect to.")
    var redirectURI: String?
    
    @ArgumentParser.Option(name: [.customLong("scope")], help: "The scope set by the User to get privileges from.")
    var scope: String?
  }
  
  @OptionGroup()
  var options: Options
  
  public var help: String { "Generates ASCII picture of a cow with a message." }
  
  public func run() async throws {
    
    guard let clientID = options.clientID else { throw Abort(.internalServerError) }
    
    guard let clientSecret = options.clientSecret else { throw Abort(.internalServerError) }
    
    guard
      let redirectURLString = options.redirectURI,
      let redirectURL = URL(string: redirectURLString),
      let port = redirectURL.port
    else { throw Abort(.internalServerError) }
    
    guard let scope = options.scope else { throw Abort(.internalServerError) }
    
    let message =
"""
\n
Generating output for:
id: \(clientID)
secret: \(clientSecret)
redirecturi: \(redirectURL)
\n
"""
    print(message)
    
    try await withThrowingTaskGroup(of: Void.self) { group in
      
      group.addTask {
        try await serve(
          port: port.description,
          clientID: clientID,
          clientSecret: clientSecret,
          redirectURI: redirectURLString,
          scope: scope)
      }
      
      group.addTask {
        guard let redirectURI = options.redirectURI?.description else { throw Abort(.notFound) }
        
        try await preflight(
          clientID: clientID,
          redirectURI: redirectURI,
          scope: scope)
      }
      
      try await group.waitForAll()
    }
  }
}

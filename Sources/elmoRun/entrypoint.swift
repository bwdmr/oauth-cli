//import elmo
//import Vapor
//
//
//
//@main
//struct Entrypoint {
//  static func main() async throws {
//    var env = try Environment.detect()
//    try LoggingSystem.bootstrap(from: &env)
//    
//    let app = Application(env)
//    defer { app.shutdown() }
//    
//    try await configure(app)
//    try await app.run()
//  }
//}
//
//
//extension Application {
//  public func run() async throws {
//    do {
//      try await self.startup()
//      try await self.running?.onStop.get()
//    } catch {
//      self.logger.report(error: error)
//      throw error
//    }
//  }
//}

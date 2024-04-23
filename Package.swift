// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription


let package = Package(
    name: "oauth-cli",
    platforms: [ .macOS(.v14)],
    products: [ .executable(name: "oauth-cli", targets: ["OAuthCli"])],
    dependencies: [
      .package(url: "https://github.com/vapor/vapor.git", from: "4.92.4"),
      .package(url: "https://github.com/bwdmr/oauth.git", branch: "main"),
      .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
      .executableTarget(name: "OAuthCli", dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "OAuth", package: "oauth"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]),
      .testTarget(name: "OAuthCliTests", dependencies: [
        .target(name: "OAuthCli"),
        .product(name: "XCTVapor", package: "vapor")
      ])
    ]
)

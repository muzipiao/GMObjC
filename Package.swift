// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMObjC",
    platforms: [.iOS(.v11), .macOS(.v10_13)],
    products: [
        .library(name: "GMObjC", targets: ["GMObjC"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GMObjC", dependencies: ["OpenSSL"], path: "GMObjC", publicHeadersPath: "include"),
        .binaryTarget(name: "OpenSSL", path: "Frameworks/OpenSSL.xcframework"),
    ]
)

// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMObjC",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        .library(name: "GMObjC", targets: ["GMObjC"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "GMObjC", path: "Frameworks/GMObjC.xcframework"),
    ]
)

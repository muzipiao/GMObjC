// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMObjC",
    products: [
        .library(name: "GMObjC", targets: ["GMObjC"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GMObjC", dependencies: ["openssl"], path: "GMObjC", resources: [.copy("PrivacyInfo.xcprivacy")]),
        .binaryTarget(name: "openssl", path: "XCFrameworks/openssl.xcframework"),
    ]
)

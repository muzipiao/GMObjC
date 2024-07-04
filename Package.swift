// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GMObjC",
    products: [
        .library(name: "GMObjC", targets: ["GMObjC", "openssl"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GMObjC", path: "GMObjC", resources: [.copy("PrivacyInfo.xcprivacy")]),
        .binaryTarget(name: "openssl", path: "XCFrameworks/OpenSSL.xcframework"),
    ]
)

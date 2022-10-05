// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Colander",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Colander",
            targets: ["Colander"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
        .package(url: "https://github.com/malcommac/SwiftDate.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "Colander",
            dependencies: [])
    ],
    swiftLanguageVersions: [.v5]
)

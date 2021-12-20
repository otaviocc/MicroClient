// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MicroClient",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(
            name: "MicroClient",
            targets: ["MicroClient"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MicroClient",
            dependencies: []
        )
    ]
)

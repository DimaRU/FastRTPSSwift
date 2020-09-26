// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FastRTPSBridge",
    products: [
        .library(
            name: "FastRTPSBridge",
            targets: ["FastRTPSBridge"]),
    ],
    dependencies: [
        .package(name: "CDRCodable", url: "https://github.com/DimaRU/CDRCodable.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "FastRTPSWrapper",
            path: "Sources/FastRTPSWrapper"),
        .target(
            name: "FastRTPSBridge",
            dependencies: ["CDRCodable", "FastRTPSWrapper"],
            path: "Sources/FastRTPSBridge",
            linkerSettings: [
                .linkedLibrary("fastrtps"),
                .unsafeFlags(["-L/usr/local/lib"])
            ]
        ),
        .testTarget(
            name: "FastRTPSBridgeTests",
            dependencies: ["FastRTPSBridge"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx14
)

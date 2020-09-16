// swift-tools-version:5.3

import PackageDescription
import Foundation

let package = Package(
    name: "FastRTPSBridge",
    products: [
        .library(
            name: "FastRTPSBridge",
            type: .static,
            targets: ["FastRTPSBridge"]),
    ],
    dependencies: [
        .package(name: "CDRCodable", url: "https://github.com/DimaRU/CDRCodable.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "FastRTPSWrapper",
            path: "Sources/FastRTPSWrapper",
            cxxSettings: [.headerSearchPath("../../build/include")]),
        .target(
            name: "FastRTPSBridge",
            dependencies: ["CDRCodable", "FastRTPSWrapper"],
            path: "Sources/FastRTPSBridge",
            linkerSettings: [
                .linkedLibrary("fastrtps"),
                .linkedLibrary("fastcdr"),
                .linkedLibrary("foonathan_memory-0.6.2"),
                .unsafeFlags(["-Lbuild/lib"])
            ]
        ),
        .testTarget(
            name: "FastRTPSBridgeTests",
            dependencies: ["FastRTPSBridge"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx14
)

// swift-tools-version:5.3

import PackageDescription

#if os(Linux)
let dependencies: [Target.Dependency] = []
let linkerSettings: [LinkerSetting]? = [
    .linkedLibrary("fastrtps", .when(platforms: [.linux])),
    .unsafeFlags(["-L/usr/local/lib"], .when(platforms: [.linux]))
]
#else
let dependencies: [Target.Dependency] = ["FastRTPS"]
let linkerSettings: [LinkerSetting]? = nil
#endif

let package = Package(
    name: "FastRTPSBridge",
    platforms: [.iOS(.v11), .macOS(.v10_13)],
    products: [
        .library(
            name: "FastRTPSBridge",
            type: .dynamic,
            targets: ["FastRTPSBridge"]),
    ],
    dependencies: [
        .package(name: "CDRCodable", url: "https://github.com/DimaRU/CDRCodable.git", from: "1.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "FastRTPS",
            url: "https://github.com/DimaRU/FastDDSPrebuild/releases/download/v1.0.0/fastrtps.xcframework.zip",
            checksum: "30df55cb2f793c5c78d66d7ea404fe24ffd4cc47e066cd09a6c99569c2641d7c"),
        .target(
            name: "FastRTPSWrapper",
            dependencies: dependencies,
            path: "Sources/FastRTPSWrapper",
            cxxSettings: [.define("FASTRTPS_FILTER")]),
        .target(
            name: "FastRTPSBridge",
            dependencies: ["CDRCodable", "FastRTPSWrapper"],
            path: "Sources/FastRTPSBridge",
            cxxSettings: [.define("FASTRTPS_FILTER")],
            swiftSettings: [.define("FASTRTPS_FILTER")],
            linkerSettings: linkerSettings),
        .testTarget(
            name: "FastRTPSBridgeTests",
            dependencies: ["FastRTPSBridge"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx11
)

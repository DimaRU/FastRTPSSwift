// swift-tools-version:5.3

import PackageDescription

#if os(Linux)
let dependencies: [Target.Dependency] = []
let linkerSettings: [LinkerSetting]? = [
    .linkedLibrary("fastrtps", .when(platforms: [.linux])),
    .unsafeFlags(["-L/usr/local/lib"], .when(platforms: [.linux]))
]
#else
let dependencies: [Target.Dependency] = ["FastDDS"]
let linkerSettings: [LinkerSetting]? = nil
#endif

let package = Package(
    name: "FastRTPSBridge",
    products: [
        .library(
            name: "FastRTPSBridge",
            type: .dynamic,
            targets: ["FastRTPSBridge"]),
    ],
    dependencies: [
        .package(name: "CDRCodable", url: "https://github.com/DimaRU/CDRCodable.git", from: "1.0.0"),
        .package(name: "FastDDS", url: "https://github.com/DimaRU/FastDDSPrebuild.git", .revision("whitelist-2.0.2"))
    ],
    targets: [
        .target(
            name: "FastRTPSWrapper",
            dependencies: dependencies,
            path: "Sources/FastRTPSWrapper",
            cxxSettings: [.define("FASTRTPS_WHITELIST")]),
        .target(
            name: "FastRTPSBridge",
            dependencies: ["CDRCodable", "FastRTPSWrapper"],
            path: "Sources/FastRTPSBridge",
            cxxSettings: [.define("FASTRTPS_WHITELIST")],
            swiftSettings: [.define("FASTRTPS_WHITELIST")],
            linkerSettings: linkerSettings),
        .testTarget(
            name: "FastRTPSBridgeTests",
            dependencies: ["FastRTPSBridge"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx11
)

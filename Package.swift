// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "FastRTPSSwift",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "FastRTPSSwift",
            targets: ["FastRTPSSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DimaRU/CDRCodable.git", from: "1.0.0"),
        .package(url: "https://github.com/DimaRU/FastDDSPrebuild.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "FastRTPSWrapper",
            dependencies: [
                .product(name: "FastDDS", package: "FastDDSPrebuild", condition: .when(platforms: [.macOS, .iOS, .tvOS, .visionOS]))
            ]
        ),
        .target(
            name: "FastRTPSSwift",
            dependencies: ["CDRCodable", "FastRTPSWrapper"],
            swiftSettings: [.interoperabilityMode(.Cxx)],
            linkerSettings: [
                .linkedLibrary("fastrtps", .when(platforms: [.linux])),
                .unsafeFlags(["-L/usr/local/lib"], .when(platforms: [.linux]))
            ]
        ),
        .testTarget(
            name: "FastRTPSSwiftTests",
            dependencies: ["FastRTPSSwift"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    cxxLanguageStandard: .cxx20
)

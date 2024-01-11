// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FastRTPSSwift",
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
                .product(name: "FastDDS", package: "FastDDSPrebuild")
            ]),
        .target(
            name: "FastRTPSSwift",
            dependencies: ["CDRCodable", "FastRTPSWrapper"]),
        .testTarget(
            name: "FastRTPSSwiftTests",
            dependencies: ["FastRTPSSwift"]),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx14
)

#if os(Linux)
package.dependencies.removeAll(where: { $0.name == "FastDDS"})
package.targets.first(where: { $0.name == "FastRTPSWrapper"})!.dependencies = []
package.targets.first(where: { $0.name == "FastRTPSSwift"})!.linkerSettings = [
    .linkedLibrary("fastrtps", .when(platforms: [.linux])),
    .unsafeFlags(["-L/usr/local/lib"], .when(platforms: [.linux]))
]
#endif

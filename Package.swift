// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-bitset",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Bitset",
            targets: ["Bitset"]
        ),
        .library(
            name: "Bitset Standard Library Integration",
            targets: ["Bitset Standard Library Integration"]
        ),
        .library(
            name: "Bitset Apple Foundation Integration",
            targets: ["Bitset Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Bitset",
            dependencies: []
        ),
        .target(
            name: "Bitset Standard Library Integration",
            dependencies: ["Bitset"]
        ),
        .target(
            name: "Bitset Apple Foundation Integration",
            dependencies: [
                "Bitset",
                "Bitset Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Bitset Tests",
            dependencies: [
                "Bitset",
                "Bitset Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}

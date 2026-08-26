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
            name: "Bitset Test Support",
            targets: ["Bitset Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-sequence.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Bitset",
            dependencies: [
                .product(name: "Iterator Protocol", package: "swift-iterator")
            ]
        ),
        .target(
            name: "Bitset Test Support",
            dependencies: [
                "Bitset",
                .product(
                    name: "Sequence Test Support",
                    package: "swift-sequence"
                ),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Bitset Tests",
            dependencies: [
                "Bitset",
                "Bitset Test Support",
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

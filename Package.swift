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
        .library(name: "Bitset", targets: ["Bitset"]),
        .library(name: "Bitset Foundation Integration", targets: ["Bitset Foundation Integration"]),
        .library(name: "Bitset Test Support", targets: ["Bitset Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-sequence.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Bitset",
            dependencies: [
                .product(name: "Iterator", package: "swift-iterator"),
            ],
            path: "Sources/Bitset"
        ),
        
        .target(
            name: "Bitset Foundation Integration",
            dependencies: [
                .target(name: "Bitset"),
            ],
            path: "Sources/Bitset Foundation Integration"
        ),
        .target(
            name: "Bitset Test Support",
            dependencies: [
                .target(name: "Bitset"),
                .product(name: "Sequence Test Support", package: "swift-sequence"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Bitset Tests",
            dependencies: [
                .target(name: "Bitset"),
                .target(name: "Bitset Test Support"),
                .target(name: "Bitset Foundation Integration"),
            ],
            path: "Tests/Bitset Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}

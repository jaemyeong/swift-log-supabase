// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-log-supabase",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SupabaseLogging",
            targets: [
                "SupabaseLogging",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.6.1")),
        .package(url: "https://github.com/kean/Pulse.git", .upToNextMajor(from: "5.1.1")),
    ],
    targets: [
        .target(
            name: "SupabaseLogging",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Pulse", package: "Pulse"),
            ]
        ),
        .testTarget(
            name: "SupabaseLoggingTests",
            dependencies: [
                "SupabaseLogging",
            ]
        ),
    ]
)

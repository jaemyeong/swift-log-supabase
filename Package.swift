// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "swift-log-supabase",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
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
        .package(url: "https://github.com/apple/swift-log", from: "1.6.1"),
    ],
    targets: [
        .target(
            name: "SupabaseLogging",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
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

// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ToPwr",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "ToPwr",
            targets: ["ToPwr"]
        ),
        .library(
            name: "Common",
            targets: ["ToPwr"]
        ),
        .library(
            name: "SplashFeature",
            targets: ["ToPwr"]
        ),
        
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "0.25.0"
        )
    ],
    targets: [
        .target(
            name: "ToPwr",
            dependencies: [
                "SplashFeature",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "ToPwrTests",
            dependencies: ["ToPwr"]
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"]
        ),
        .target(
            name: "SplashFeature",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "SplashFeatureTests",
            dependencies: ["SplashFeature"]
        ),
    ]
)

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
        .library(
            name: "MenuFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "HomeFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "MapFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "FacultiesFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "ClubsFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "InfoFeature",
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
                "MenuFeature",
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
        .target(
            name: "MenuFeature",
            dependencies: [
                "HomeFeature",
                "MapFeature",
                "FacultiesFeature",
                "ClubsFeature",
                "InfoFeature",
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "MenuFeatureTests",
            dependencies: ["MenuFeature"]
        ),
        .target(
            name: "HomeFeature",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "HomeFeatureTests",
            dependencies: ["HomeFeature"]
        ),
        .target(
            name: "MapFeature",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "MapFeatureTests",
            dependencies: ["MapFeature"]
        ),
        .target(
            name: "FacultiesFeature",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "FacultiesFeatureTests",
            dependencies: ["FacultiesFeature"]
        ),
        .target(
            name: "ClubsFeature",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "ClubsFeatureTests",
            dependencies: ["ClubsFeature"]
        ),
        .target(
            name: "InfoFeature",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "InfoFeatureTests",
            dependencies: ["InfoFeature"]
        ),
    ]
)

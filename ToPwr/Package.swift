// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ToPwr",
    defaultLocalization: "en",
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
        .library(
            name: "CellsFeature",
            targets: ["ToPwr"]
        ),
        .library(
            name: "Api",
            targets: ["ToPwr"]
        ),
        .library(
            name: "Storage",
            targets: ["ToPwr"]
        ),
        .library(
            name: "CoreLogic",
            targets: ["ToPwr"]
        ),
        .library(
            name: "Strings",
            targets: ["ToPwr"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            from: "0.25.0"
        ),
        .package(
            url: "https://github.com/kean/NukeUI",
            from: "0.7.0"
        )
    ],
    targets: [
        .target(
            name: "ToPwr",
            dependencies: [
                "SplashFeature",
                "Common",
                "CoreLogic",
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
                .product(
                    name: "NukeUI",
                    package: "NukeUI"
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
                "Strings",
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
                "CellsFeature",
                "Strings",
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
        .target(
            name: "Storage",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: ["Storage"]
        ),
        .target(
            name: "CoreLogic",
            dependencies: [
                "Common",
                "Api",
                "Storage",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "CoreLogicTests",
            dependencies: ["CoreLogic"]
        ),
        .target(
            name: "Api",
            dependencies: [
                "Common",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "ApiTests",
            dependencies: ["Api"]
        ),
        .target(
            name: "CellsFeature",
            dependencies: [
                "Common",
                "Strings",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "CellsFeatureTests",
            dependencies: ["CellsFeature"]
        ),
        .target(
            name: "Strings",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "StringsTests",
            dependencies: ["Strings"]
        ),
    ]
)

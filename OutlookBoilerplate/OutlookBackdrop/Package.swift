// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "OutlookBackdrop",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "OutlookBackdrop", targets: ["OutlookBackdrop"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/microsoft/fluentui-apple",
            exact: "0.35.0"
        ),
    ],
    targets: [
        .target(
            name: "OutlookBackdrop",
            dependencies: [
                .product(name: "FluentUI", package: "fluentui-apple"),
            ],
            swiftSettings: [
                // FluentTheme.shared (a singleton in fluentui-apple 0.35.0) isn't
                // annotated @MainActor in that release. Swift 6 strict concurrency
                // rejects accesses to it. Compile this package in Swift 5 mode so
                // the singleton access is allowed; the package and its consumers
                // run on the main thread in practice (SwiftUI View bodies).
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

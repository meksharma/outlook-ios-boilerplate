// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "OutlookBackdrop",
    platforms: [.iOS(.v17)],
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
            ]
        ),
    ]
)

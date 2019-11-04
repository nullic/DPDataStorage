// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DPDataStorage",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "DPDataStorage",
            type: .dynamic,
            targets: ["DPDataStorage"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DPDataStorage",
            path: "DPDataStorage"
        )
    ]
)

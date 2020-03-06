// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DPDataStorage",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "DataMapping", targets: ["DataMapping"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "DataStorage", targets: ["DataStorage", "DataMapping", "DataSource"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DataMapping", path: "DataMapping"),
        .target(name: "DataSource", path: "DataSource"),
        .target(name: "DataStorage", path: "DataStorage"),
    ]
)

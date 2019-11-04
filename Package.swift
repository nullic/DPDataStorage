// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DPDataStorage",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "DPDataMapping", targets: ["DataMapping"]),
        .library(name: "DPDataSource", targets: ["DataSource"]),
        .library(name: "DPDataStorage", targets: ["DataStorage", "DataMapping", "DataSource"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DataMapping", path: "DataMapping"),
        .target(name: "DataSource", path: "DataSource"),
        .target(name: "DataStorage", path: "DataStorage"),
    ]
)

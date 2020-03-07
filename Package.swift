// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DPDataStorage",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_10)
    ],
    products: [
        .library(name: "DataMapping", targets: ["DataMapping"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "CellSizeCache", targets: ["CellSizeCache"]),
        .library(name: "DataStorage", targets: ["DataStorage", "DataMapping", "DataSource"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DataMapping", path: "DataMapping"),
        .target(name: "DataSource", path: "DataSource", cSettings: [.define("OS_IOS", .when(platforms: [.iOS]))]),
        .target(name: "CellSizeCache", dependencies: ["DataSource"], path: "CellSizeCache"),
        .target(name: "DataStorage", path: "DataStorage"),
    ]
)

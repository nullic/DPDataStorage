// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DPDataStorage",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "DataMapping", targets: ["DataMapping"]),
        .library(name: "DataSource", targets: ["DataSource"]),
        .library(name: "CellSizeCache", targets: ["CellSizeCache"]),
        .library(name: "DataStorage", targets: ["DataStorage", "DataMapping", "DataSource"]),
        
        .library(name: "DataMapping-Static", type: .static, targets: ["DataMapping"]),
        .library(name: "DataSource-Static", type: .static, targets: ["DataSource"]),
        .library(name: "CellSizeCache-Static", type: .static, targets: ["CellSizeCache"]),
        .library(name: "DataStorage-Static", type: .static, targets: ["DataStorage", "DataMapping", "DataSource"]),

        .library(name: "DataMapping-Dynamic", type: .dynamic, targets: ["DataMapping"]),
        .library(name: "DataSource-Dynamic", type: .dynamic, targets: ["DataSource"]),
        .library(name: "CellSizeCache-Dynamic", type: .dynamic, targets: ["CellSizeCache"]),
        .library(name: "DataStorage-Dynamic", type: .dynamic, targets: ["DataStorage", "DataMapping", "DataSource"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "DataMapping", path: "DataMapping"),
        .target(name: "DataSource", path: "DataSource"),
        .target(name: "CellSizeCache", dependencies: ["DataSource"], path: "CellSizeCache"),
        .target(name: "DataStorage", path: "DataStorage"),
        .testTarget(name: "DataSourceTests", dependencies: ["DataSource"], path: "Tests/DataSource"),
        .testTarget(name: "CellSizeCacheTests", dependencies: ["CellSizeCache"], path: "Tests/CellSizeCache"),
    ]
)

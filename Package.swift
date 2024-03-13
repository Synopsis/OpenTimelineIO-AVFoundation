// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenTimelineIO-AVFoundation",
    platforms: [.macOS(.v13),
                .iOS(.v16)],

    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OpenTimelineIO-AVFoundation",
            targets: ["OpenTimelineIO-AVFoundation"]),
    ],

    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url:"https://github.com/openTimelineIO/OpenTimelineIO-Swift-Bindings", branch: "main"),
         .package(url: "https://github.com/orchetect/TimecodeKit", branch: "main")
    ],

    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OpenTimelineIO-AVFoundation",
            dependencies: [ .product(name: "OpenTimelineIO", package: "OpenTimelineIO-Swift-Bindings"),
                            .product(name: "TimecodeKit", package: "TimecodeKit") ]
        ),
        .testTarget(
            name: "OpenTimelineIO-AVFoundationTests",
            dependencies: [.product(name: "OpenTimelineIO", package: "OpenTimelineIO-Swift-Bindings"),
                           .product(name: "TimecodeKit", package: "TimecodeKit")
                           , "OpenTimelineIO-AVFoundation"]),
    ]
)

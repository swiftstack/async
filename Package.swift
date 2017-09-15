// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Async",
    products: [
        .library(name: "Async", targets: ["Async"]),
        .library(name: "AsyncDispatch", targets: ["AsyncDispatch"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/platform.git",
            from: "0.4.0"
        ),
        .package(
            url: "https://github.com/swift-stack/test.git",
            from: "0.4.0"
        )
    ],
    targets: [
        .target(name: "Async", dependencies: ["Platform"]),
        .target(name: "AsyncDispatch", dependencies: ["Async"]),
        .testTarget(
            name: "AsyncDispatchTests",
            dependencies: ["AsyncDispatch", "Test"])
    ]
)

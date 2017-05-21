// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Async",
    products: [
        .library(name: "Async", targets: ["Async"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-stack/platform.git",
            from: "0.4.0"
        )
    ],
    targets: [
        .target(name: "Async", dependencies: ["Platform"])
    ]
)

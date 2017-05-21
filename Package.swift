import PackageDescription

let package = Package(
    name: "Async",
    dependencies: [
        .Package(
            url: "https://github.com/swift-stack/platform.git",
            majorVersion: 0,
            minor: 3
        )
    ]
)

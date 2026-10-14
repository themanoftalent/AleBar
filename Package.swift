// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AleBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "AleBar",
            targets: ["AleBar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AleBar",
            path: "Sources/AleBar",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        )
    ]
)

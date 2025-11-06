// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NaloFocus",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "NaloFocus", targets: ["NaloFocus"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NaloFocus",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-disable-availability-checking"])
            ]
        ),
        .testTarget(
            name: "NaloFocusTests",
            dependencies: ["NaloFocus"]
        )
    ]
)

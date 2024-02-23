// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SFSymbolsGenerator",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "sfgenerate", targets: ["SFSymbolsGenerator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.3.0")),
    ],
    targets: [
        .executableTarget(
            name: "SFSymbolsGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: .packageSettings
        ),
        .testTarget(name: "SFSymbolsGeneratorTests", dependencies: [
            "SFSymbolsGenerator",
            .product(name: "Testing", package: "swift-testing"),
        ]),
    ]
)

extension [PackageDescription.SwiftSetting] {
    /// Settings intended to be applied to every Swift target in this package.
    /// Analogous to project-level build settings in an Xcode project.
    static var packageSettings: Self {
        [
            .enableUpcomingFeature("ExistentialAny"),
            .define("SWT_TARGET_OS_APPLE", .when(platforms: [.macOS])),
        ]
    }
}

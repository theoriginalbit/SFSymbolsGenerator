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
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.1.1"),
        .package(url: "https://github.com/apple/swift-testing.git", exact: "0.4.2"),
        .package(url: "https://github.com/theoriginalbit/GitVersionPlugin.git", exact: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SFSymbolsGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: .packageSettings,
            plugins: [
                .plugin(name: "GitVersionPlugin", package: "GitVersionPlugin"),
            ]
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

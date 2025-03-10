// swift-tools-version: 6.0
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
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.5.0"),
        .package(url: "https://github.com/JohnSundell/Files", exact: "4.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SFSymbolsGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files"),
            ],
            path: "Sources"
        ),
        
        .testTarget(
            name: "SFSymbolsGeneratorTests",
            dependencies: ["SFSymbolsGenerator"],
            path: "Tests"
        ),
    ]
)

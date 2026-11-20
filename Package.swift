// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "SFSymbolsGenerator",
	platforms: [
		.macOS(.v15),

		// Declared so it can be a plugin on a project of the following
		.iOS(.v18), .watchOS(.v11), .tvOS(.v18), .visionOS(.v2),
	],
	products: [
		.executable(
			name: "sfgenerate",
			targets: ["sfgenerate"],
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.8.2")),
		.package(url: "https://github.com/theoriginalbit/SwiftStructureKit", .upToNextMajor(from: "4.1.0")),
	],
	targets: [
		.target(
			name: "_SFSymbolsGeneratorCore",
			dependencies: [
				.product(name: "SwiftStructureKit", package: "SwiftStructureKit"),
			],
		),
		.executableTarget(
			name: "sfgenerate",
			dependencies: [
				.target(name: "_SFSymbolsGeneratorCore"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			path: "Sources/SFSymbolsGenerator",
			plugins: [
				.plugin(name: "GitVersionPlugin"),
			],
		),
		.testTarget(
			name: "_SFSymbolsGeneratorCoreTests",
			dependencies: [
				.target(name: "_SFSymbolsGeneratorCore"),
				.product(name: "SwiftStructureKitTestSupport", package: "SwiftStructureKit"),
			],
			resources: [
				.copy("Resources"),
			],
		),
		.testTarget(
			name: "SFSymbolsGeneratorTests",
			dependencies: [
				.target(name: "sfgenerate"),
			],
		),
		.plugin(
			name: "GitVersionPlugin",
			capability: .buildTool(),
		),
	],
)

for target in package.targets where target.type != .plugin {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: [
		.swiftLanguageMode(.v6),
		.enableUpcomingFeature("MemberImportVisibility"),
		.enableUpcomingFeature("ApproachableConcurrency"),
	])
	target.swiftSettings = settings
}

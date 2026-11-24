//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import PackagePlugin

@main
struct SFSymbolsGeneratorPlugin {
	func createBuildCommands(
		pluginWorkDirectory: URL,
		tool findTool: (String) throws -> PluginContext.Tool,
		configurationURL: URL?,
	) throws -> [Command] {
		let tool = try findTool("sfgenerate")
		let outputDirectory = pluginWorkDirectory.appending(
			path: "Generated",
			directoryHint: .isDirectory,
		)
		let configuration = try GeneratorConfiguration.load(from: configurationURL)

		var arguments = [
			"generate",
			"--output-directory",
			outputDirectory.path(),
			"--build-tool",
		]
		if let accessModifier = configuration.accessModifier {
			arguments.append("--\(accessModifier)")
		}
		if !configuration.uiFrameworks.isEmpty {
			arguments.append("--ui-frameworks")
			arguments.append(configuration.uiFrameworks.joined(separator: ","))
		}
		if configuration.symbolExtensions == false {
			arguments.append("--disable-symbol-extensions")
		}
		if configuration.rawIdentifiers == true {
			arguments.append("--enable-raw-identifiers")
		}

		let outputs = try generatedFiles(in: outputDirectory)
		return [
			.buildCommand(
				displayName: "Generate SF Symbols",
				executable: tool.url,
				arguments: arguments,
				outputFiles: outputs,
			),
		]
	}
}

extension SFSymbolsGeneratorPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
		try createBuildCommands(
			pluginWorkDirectory: context.pluginWorkDirectoryURL,
			tool: context.tool,
			configurationURL: context.package.directoryURL.appending(path: ".sfgenerate.json"),
		)
	}
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SFSymbolsGeneratorPlugin: XcodeBuildToolPlugin {
	func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
		let configurationFiles = target.inputFiles.filter {
			$0.url.lastPathComponent == ".sfgenerate.json"
		}
		guard configurationFiles.count <= 1 else {
			throw PluginError("Expected at most one .sfgenerate.json config file in the Xcode target inputs.")
		}

		return try createBuildCommands(
			pluginWorkDirectory: context.pluginWorkDirectoryURL,
			tool: context.tool,
			configurationURL: configurationFiles.first?.url,
		)
	}
}
#endif

private extension SFSymbolsGeneratorPlugin {
	private func generatedFiles(in outputDirectory: URL) throws -> [URL] {
		let resolver = try CategoryResolver(
			resourceFolder: CoreGlyphs.systemResourceFolder,
			nameAliases: [:] // not needed, we won't be asking it for a category of a particular symbol
		)
		let fileURLProvider = FileURLProvider(outputDirectory: outputDirectory)

		var outputs = [
			fileURLProvider.symbolResourceFile(),
		]
		for category in resolver.categories {
			outputs.append(fileURLProvider.categoryFile(for: category))

			for framework in FileURLProvider.UIFramework.allCases {
				outputs.append(fileURLProvider.frameWorkConvenienceFile(framework, for: category))
			}
		}
		return outputs
	}
}

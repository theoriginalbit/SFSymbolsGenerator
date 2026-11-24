//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import ArgumentParser
import Foundation

struct GenerateCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "generate",
		abstract: "Generate a type-safe Swift file from Xcode build settings.",
	)

	@Option(
		name: .long,
		help: ArgumentHelp(
			"Path for the generated Swift file.",
			discussion: "If not provided it will be generated in the current working directory.",
		),
		completion: .directory,
	)
	private var outputDirectory: URL? = nil

	@Flag(
		inversion: .prefixedEnableDisable,
		help: ArgumentHelp(
			"Generate SF Symbol extensions on Apple framework image types.",
			visibility: .private,
		),
	)
	private var symbolExtensions: Bool = true

	@Option(
		help: "Generate SF Symbol support for the specified UI frameworks, comma-separated.",
	)
	private var uiFrameworks: Set<UIFramework> = Set(UIFramework.allCases)

	@Flag(
		exclusivity: .exclusive,
		help: "The access modifier applied to the generated code"
	)
	private var accessModifier: AccessModifier = .internal

	@Option(
		name: .customLong("mode"),
		help: ArgumentHelp(
			"Adjusts the diagnostic message output",
		),
	)
	private var diagnosticMode: DiagnosticMode = .cli

	@Flag(
		inversion: .prefixedEnableDisable,
		exclusivity: .chooseLast,
		help: "Whether identifiers should be emitted using the raw identifier syntax introduced in Swift 6.2"
	)
	private var rawIdentifiers: Bool = false

	@Flag(
		name: .customLong("build-tool"),
		inversion: .prefixedNo,
		exclusivity: .chooseLast,
		help: .private,
	)
	private var isRunningAsBuildTool: Bool = false

	@Flag(
		name: .shortAndLong,
		help: "Increase verbosity (-vvv).",
	)
	private var verbose: Int

	func run() throws {
		do {
			let diagnostics = StandardDiagnosticCollector(mode: diagnosticMode, verbosity: verbose)
			let outputDirectory = try resolvedOutputDirectory(diagnostics: diagnostics)

			let context = CodeGenerator.Context(
				outputDirectory: outputDirectory,
				diagnostics: diagnostics,
				accessModifier: accessModifier,
				symbolExtensions: symbolExtensions,
				uiFrameworks: uiFrameworks,
				rawIdentifiers: rawIdentifiers,
				isRunningAsBuildTool: isRunningAsBuildTool,
			)

			let generator = CodeGenerator()
			try generator.run(using: context)
		} catch let error as GeneratorError where error.alreadyLogged {
			// there was an error but it reports there will already be diagnostics
			// so just throw failure so there isn't a double printout of the error
			throw ExitCode.failure
		}
	}

	private func resolvedOutputDirectory(diagnostics: some DiagnosticCollector) throws(GeneratorError) -> URL {
		if let outputDirectory {
			return outputDirectory
		}
		if isRunningAsBuildTool {
			diagnostics.error("internal error: running as build tool but output file path is missing.")
			throw .specifyOutputDirectory
		}
		return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
	}
}

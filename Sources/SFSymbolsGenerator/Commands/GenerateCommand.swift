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
		name: [.short, .customLong("output"), .long],
		help: ArgumentHelp(
			"Path for the generated Swift file.",
			discussion: "If not provided it will be generated in the current working directory.",
		),
		completion: .directory,
	)
	private var outputDirectory: URL? = nil

	@Flag(
		exclusivity: .exclusive,
		help: ArgumentHelp(
			"Show diagnostic messages with short filenames (best for CLI) or long file paths for Xcode's issue navigator to annotate (best for parsing.)",
			visibility: .hidden,
		),
	)
	private var diagnosticMode: DiagnosticMode = .cli

	@Flag(
		exclusivity: .exclusive,
		help: "The access modifier applied to the generated code. Defaults to `internal`."
	)
	private var accessModifier: AccessModifier = .internal

	@Flag(
		name: .customLong("build-tool"),
		inversion: .prefixedNo,
		exclusivity: .chooseLast,
		help: .private,
	)
	private var isRunningAsBuildTool: Bool = false

	@Flag(name: .shortAndLong, help: "Increase verbosity (-vvv).")
	private var verbose: Int

	func run() throws {
		do {
			let diagnostics = StandardDiagnosticCollector(mode: diagnosticMode, verbosity: verbose)
			let outputDirectory = try resolvedOutputDirectory(diagnostics: diagnostics)

			let context = CodeGenerator.Context(
				outputDirectory: outputDirectory,
				diagnostics: diagnostics,
				accessModifier: accessModifier,
			)

			let generator = CodeGenerator()
			try generator.run(with: context)
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

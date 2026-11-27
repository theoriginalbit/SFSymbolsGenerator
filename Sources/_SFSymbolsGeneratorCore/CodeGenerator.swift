//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

package struct CodeGenerator {
	package init() {}

	package func run(using context: Context<some DiagnosticOutput>) throws {
		// Try to load early, in case CoreGlyphs is missing (how?) or changed.
		let metadata = try SFSymbolMetadata()

		// Make sure the output directory exists
		try FileManager.default.createDirectory(
			at: context.outputDirectory,
			withIntermediateDirectories: true,
		)

		context.note("Output directory:      \(context.outputDirectory)")
		context.note("Enabled UI frameworks: \(context.uiFrameworks.map(\.rawValue), separator: ",")")
		context.note("Access modifier:       \(context._accessModifier)")
		context.note("Symbol extensions:     \(context.symbolExtensions)")
		context.note("Raw identifiers:       \(context.rawIdentifiers)")

		if case .cli = context.diagnostics.mode {
			print()
		}

		informUserAboutFilesThatWillBeSkippedBasedOnContext(context)

		let context = SymbolContext(context: context, metadata: metadata)
		let (totalFiles, totalSymbols) = try generateSFSymbolFiles(using: context)
		print("Generated", totalFiles, "files for", totalSymbols, "SF Symbols")

		// Abort if any diagnostic errors were prevented complete generation
		guard !context.diagnostics.hasErrors else {
			throw GeneratorError.generationFailed
		}
	}

	func generateSFSymbolFiles(
		using context: SymbolContext<some DiagnosticOutput>,
	) throws -> (totalFiles: Int, totalSymbols: Int) {
		// counters for a nice little message at the end
		var totalFiles = 1
		var totalSymbols = 0

		try generateSFSymbolResourceFile(using: context)

		for category in context.metadata.categories {
			let (filesCount, symbolsCount) = try generateSFSymbolFiles(for: category, using: context)
			totalFiles += filesCount
			totalSymbols += symbolsCount
		}

		return (totalFiles, totalSymbols)
	}

	func generateSFSymbolResourceFile(
		using context: SymbolContext<some DiagnosticOutput>,
	) throws {
		let output = context.symbolResourceFile()
		let file = SFSymbolResourceFile.generate(fileName: output.lastPathComponent, using: context)
		try renderIfChanged(file, to: output, using: context)
	}

	func generateSFSymbolFiles(
		for category: SFSymbolCategory,
		using context: SymbolContext<some DiagnosticOutput>,
	) throws -> (filesCount: Int, symbolsCount: Int) {
		let symbols = context.metadata.symbols(in: category)

		var filesCount: Int = 0

		filesCount += try generateSFSymbolDefinitionsFile(symbols, for: category, using: context)
		// always attempt all compatible UI frameworks, let the generate function determine how
		// to write it based on context.uiFrameworks
		for framework in UIFramework.allCases {
			filesCount += try generateSFSymbolFrameworkExtensionsFile(framework, symbols: symbols, for: category, using: context)
		}

		return (filesCount, symbols.count)
	}

	func generateSFSymbolDefinitionsFile(
		_ symbols: [SFSymbol],
		for category: SFSymbolCategory,
		using context: SymbolContext<some DiagnosticOutput>,
	) throws -> Int {
		let output = context.categoryFile(for: category)
		let file = SFSymbolDefinitionsFile.generate(symbols, for: category, fileName: output.lastPathComponent, using: context)
		try renderIfChanged(file, to: output, using: context)
		return 1
	}

	func generateSFSymbolFrameworkExtensionsFile(
		_ framework: UIFramework,
		symbols: [SFSymbol],
		for category: SFSymbolCategory,
		using context: SymbolContext<some DiagnosticOutput>,
	) throws -> Int {
		guard let output = context.frameWorkConvenienceFile(framework, for: category) else {
			// should already have been logged by informUserAboutFilesThatWillBeSkippedBasedOnContext
			return 0
		}

		guard context.symbolExtensions, context.uiFrameworks.contains(framework) else {
			if context.isRunningAsBuildTool {
				try renderIfChanged(Data(), to: output, using: context)
				return 1
			}
			context.note("Skipping writing to \(output)")
			return 0
		}

		guard let file = SFSymbolFrameworkExtensionsFile.generate(
			framework,
			symbols: symbols,
			fileName: output.lastPathComponent,
			using: context
		) else { return 0 } // assume function emitted diagnostics

		try renderIfChanged(file, to: output, using: context)
		return 1
	}

	func renderIfChanged(
		_ file: SwiftFile,
		to outputURL: URL,
		using context: SymbolContext<some DiagnosticOutput>,
	) throws {
		let data = file.render(indentUsing: .spaces(4))
		try renderIfChanged(data, to: outputURL, using: context)
	}

	func renderIfChanged(
		_ data: Data,
		to outputURL: URL,
		using context: SymbolContext<some DiagnosticOutput>,
	) throws {
		if let existingData = try? Data(contentsOf: outputURL), existingData == data {
			// Content is identical, no write needed otherwise we would update the modified time
			context.note("No changes needed to \(outputURL)")
			return
		}

		try data.write(to: outputURL, options: .atomic)
		context.note("Written to \(outputURL)")
	}

	private func informUserAboutFilesThatWillBeSkippedBasedOnContext(_ context: Context<some DiagnosticOutput>) {
		if context.symbolExtensions, context.uiFrameworks.contains(.swiftUI) {
			context.note("SwiftUI Image will not have symbol conveniences (e.g. Image.circleFilled) generated, use explicit Image(system: .circleFilled) instead")
		}

		for framework in [UIFramework.appKit, .uiKit] {
			guard !context.symbolExtensions || !context.uiFrameworks.contains(framework) else {
				continue
			}
			var failingReason = context.symbolExtensions
				? "Requested UI frameworks did not include \(framework.rawValue)"
				: "UI framework extensions were disabled"
			if context.isRunningAsBuildTool {
				failingReason += "; will generate empty \(framework.rawValue) files for build tool"
			} else {
				failingReason += "; will not generate \(framework.rawValue) files"
			}
			context.note(DiagnosticMessage(failingReason))
		}
	}
}

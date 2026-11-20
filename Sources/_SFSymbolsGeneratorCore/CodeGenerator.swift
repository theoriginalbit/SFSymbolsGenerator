//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

package struct CodeGenerator {
	private static let resourceStructName = "SFSymbolResource"
	private static let systemNameProperty = "systemName"

	package init() {}

	package func run(with context: Context<some DiagnosticCollector>) throws {
		// Try to load early, in case CoreGlyphs is missing (how?) or changed.
		let metadata = try SFSymbolMetadata()

		// Make sure the output directory exists
		try FileManager.default.createDirectory(
			at: context.outputDirectory,
			withIntermediateDirectories: true,
		)

		informUserAboutFilesThatWillBeSkippedBasedOnContext(context)

		let context = SymbolContext(context: context, metadata: metadata)

		// counters for a nice little message at the end
		var totalFiles = 1
		var totalSymbols = 0

		try generateSFSymbolResourceFile(with: context)

		for category in metadata.categories {
			let (filesCount, symbolsCount) = try generateSFSymbolFiles(for: category, with: context)
			totalFiles += filesCount
			totalSymbols += symbolsCount
		}
		print("Generated", totalFiles, "files for", totalSymbols, "SF Symbols")

		// Abort if any diagnostic errors were prevented complete generation
		guard !context.diagnostics.hasErrors else {
			throw GeneratorError.generationFailed
		}
	}

	func generateSFSymbolResourceFile(
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		let output = context.symbolResourceFile()
		let file = SFSymbolResourceFile.generate(fileName: output.lastPathComponent, with: context)
		try renderIfChanged(file, to: output, with: context)
	}

	func generateSFSymbolFiles(
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> (filesCount: Int, symbolsCount: Int) {
		let symbols = context.metadata.symbols(in: category)

		var filesCount: Int = 0

		filesCount += try generateSFSymbolDefinitionsFile(symbols, for: category, with: context)
		// always attempt all UI frameworks, let the generate function determine how
		// to write it based on context.uiFrameworks
		for framework in UIFramework.allCases {
			filesCount += try generateSFSymbolFrameworkExtensionsFile(framework, symbols, for: category, with: context)
		}

		return (filesCount, symbols.count)
	}

	func generateSFSymbolDefinitionsFile(
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> Int {
		let output = context.categoryFile(for: category)
		let file = SFSymbolDefinitionsFile.generate(symbols, for: category, fileName: output.lastPathComponent, with: context)
		try renderIfChanged(file, to: output, with: context)
		return 1
	}

	func generateSFSymbolFrameworkExtensionsFile(
		_ framework: UIFramework,
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> Int {
		let output = context.frameWorkConvenienceFile(framework, for: category)

		guard context.symbolExtensions, context.uiFrameworks.contains(framework) else {
			if context.isRunningAsBuildTool {
				try renderIfChanged(Data(), to: output, with: context)
				return 1
			}
			context.info("Skipping writing to \(output.path())")
			return 0
		}

		let file = SFSymbolFrameworkExtensionsFile.generate(
			framework,
			symbols,
			for: category,
			fileName: output.lastPathComponent,
			with: context
		)

		try renderIfChanged(file, to: output, with: context)
		return 1
	}

	func renderIfChanged(
		_ file: SwiftFile,
		to outputURL: URL,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		let data = file.render(indentUsing: .spaces(4))
		try renderIfChanged(data, to: outputURL, with: context)
	}

	func renderIfChanged(
		_ data: Data,
		to outputURL: URL,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		if let existingData = try? Data(contentsOf: outputURL), existingData == data {
			// Content is identical, no write needed otherwise we would update the modified time
			context.info("No changes needed to \(outputURL.path())")
			return
		}

		try data.write(to: outputURL, options: .atomic)
		context.info("Written to \(outputURL.path())")
	}

	private func informUserAboutFilesThatWillBeSkippedBasedOnContext(_ context: Context<some DiagnosticCollector>,) {
		for framework in UIFramework.allCases {
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
			context.info(failingReason)
		}
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore
import SwiftStructureKitTestSupport

@Suite(.tags(.compiler)) struct GeneratedFilesCompilationTests {
	@Test func `generated resource file compiles`() async throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }

		let generator = CodeGenerator()
		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: Set(UIFramework.allCases))
		let resourceURL = try generateResourceFile(in: directory, using: generator, using: context)

		await assertCompilation(resourceURL)
	}

	@Test func `generated symbol definitions file compiles`() async throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }

		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: Set(UIFramework.allCases))
		let symbols = [
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: nil,
				restriction: nil,
			),
		]

		let generator = CodeGenerator()
		let definitionsURL = try generateDefinitionsFile(symbols, in: directory, using: generator, using: context)

		await assertCompilation(
			try generateResourceFile(in: directory, using: generator, using: context), // required for definitions to compile
			definitionsURL
		)
	}

	@Test func `generated framework extensions files compile`() async throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }

		let context = try GeneratorTestContext.make(
			outputDirectory: directory,
			uiFrameworks: Set(UIFramework.allCasesSupportingSymbolExtensions)
		)
		let symbols = [
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: nil,
				restriction: nil,
			),
		]

		let generator = CodeGenerator()

		var files: [URL] = [
			// required for extensions to compile
			try generateResourceFile(in: directory, using: generator, using: context),
			try generateDefinitionsFile(symbols, in: directory, using: generator, using: context),
		]

		// generate the extensions
		for framework in UIFramework.allCasesSupportingSymbolExtensions {
			let extensionsURL = try #require(context.frameWorkConvenienceFile(framework, for: .init(key: "shapes")))
			let file = SFSymbolFrameworkExtensionsFile.generate(
				framework,
				symbols: symbols,
				fileName: extensionsURL.lastPathComponent,
				using: context,
			)
			let extensionsFile = try #require(file)
			try generator.renderIfChanged(extensionsFile, to: extensionsURL, using: context)
			files.append(extensionsURL)
		}

		let nonSupportingCases = Set(UIFramework.allCases).subtracting(UIFramework.allCasesSupportingSymbolExtensions)
		for framework in nonSupportingCases {
			#expect(context.frameWorkConvenienceFile(framework, for: .init(key: "shapes")) == nil)
		}

		await assertCompilation(files)
	}

	// MARK: Helpers

	func generateResourceFile(
		in directory: URL,
		using codeGenerator: CodeGenerator,
		using context: CodeGenerator.SymbolContext<TestDiagnosticCollector>
	) throws -> URL {
		let resourceFile = SFSymbolResourceFile.generate(
			fileName: "SFSymbolResource.generated.swift",
			using: context,
		)
		let resourceURL = context.symbolResourceFile()
		try codeGenerator.renderIfChanged(resourceFile, to: resourceURL, using: context)
		return resourceURL
	}

	func generateDefinitionsFile(
		_ symbols: [SFSymbolMetadata.Symbol],
		in directory: URL,
		using codeGenerator: CodeGenerator,
		using context: CodeGenerator.SymbolContext<TestDiagnosticCollector>,
	) throws -> URL {
		let definitionsFile = SFSymbolDefinitionsFile.generate(
			symbols,
			for: .init(key: "shapes"),
			fileName: "SFSymbolResource+Shapes.generated.swift",
			using: context,
		)

		let definitionsURL = context.categoryFile(for: .init(key: "shapes"))
		try codeGenerator.renderIfChanged(definitionsFile, to: definitionsURL, using: context)
		return definitionsURL
	}
}

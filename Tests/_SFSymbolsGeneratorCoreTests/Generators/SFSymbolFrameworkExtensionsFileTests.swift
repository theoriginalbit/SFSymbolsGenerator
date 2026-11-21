//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore
import SwiftStructureKitTestSupport

@Suite(.tags(.renderer)) struct SFSymbolFrameworkExtensionsFileTests {
	@Test func `generates UIKit convenience accessors for valid symbols`() throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }
		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: [.uiKit])
		let symbols = [
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: nil,
				restriction: nil,
			),
		]

		let file = SFSymbolFrameworkExtensionsFile.generate(
			.uiKit,
			symbols: symbols,
			fileName: "SFSymbolResource+Shapes+UIKit.generated.swift",
			with: context,
		)
		let outputURL = try #require(context.frameWorkConvenienceFile(.uiKit, for: SFSymbolMetadata.Category(key: "shapes")))

		try CodeGenerator().renderIfChanged(try #require(file), to: outputURL, with: context)
		let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)

		expectRendered(output, equals: try Fixtures.url("SFSymbolFrameworkUIKitExtensionsFile"))
	}

	@Test func `generates AppKit convenience accessors for valid symbols`() throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }
		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: [.appKit])
		let symbols = [
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: nil,
				restriction: nil,
			),
		]

		let file = SFSymbolFrameworkExtensionsFile.generate(
			.appKit,
			symbols: symbols,
			fileName: "SFSymbolResource+Shapes+AppKit.generated.swift",
			with: context,
		)
		let outputURL = try #require(context.frameWorkConvenienceFile(.uiKit, for: SFSymbolMetadata.Category(key: "shapes")))

		try CodeGenerator().renderIfChanged(try #require(file), to: outputURL, with: context)
		let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)

		expectRendered(output, equals: try Fixtures.url("SFSymbolFrameworkAppKitExtensionsFile"))
	}

	@Test func `SwiftUI extensions do not generate even if it is a requested framework`() throws {
		let directory = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: directory) }

		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: [.swiftUI])
		let symbols = [
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: nil,
				restriction: nil,
			),
		]

		#expect(SFSymbolFrameworkExtensionsFile.generate(
			.swiftUI,
			symbols: symbols,
			fileName: "unused.swift",
			with: context,
		) == nil)
	}
}

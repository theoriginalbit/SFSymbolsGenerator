//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore
import SwiftStructureKitTestSupport

@Suite(.tags(.renderer)) struct SFSymbolDefinitionsFileTests {
	@Test func `generates symbol properties with Swift names and original system names`() throws {
		let resources = try TempDir.create()
		defer { try? FileManager.default.removeItem(at: resources) }

		let context = try GeneratorTestContext.make(outputDirectory: resources)
		let symbols = [
			SFSymbol(
				name: "circle.fill",
				availability: nil,
				replacementName: "circle",
				replacementAvailability: nil,
				restriction: "Use the replacement symbol.",
			),
		]

		let file = SFSymbolDefinitionsFile.generate(
			symbols,
			for: .init(key: "shapes"),
			fileName: "SFSymbolResource+Shapes.generated.swift",
			using: context,
		)
		let outputURL = resources.appending(component: "SFSymbolResource+Shapes.generated.swift")
		try CodeGenerator().renderIfChanged(file, to: outputURL, using: context)
		let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)

		expectRendered(output, equals: try Fixtures.url("SFSymbolDefinitionsFile"))
	}

	@Test func `deprecates symbols when their replacement is introduced`() throws {
		let directory = try TempDir.create()
		defer { try? TempDir.remove(directory) }

		let context = try GeneratorTestContext.make(outputDirectory: directory, rawIdentifiers: true)
		let symbols = [
			SFSymbol(
				name: "a.magnify",
				availability: .init(iOS: "13.0", macOS: "11.0", tvOS: "14.0", watchOS: "7.0", visionOS: "1.0"),
				replacementName: "character.magnify",
				replacementAvailability: .init(iOS: "16.0", macOS: "15.0", tvOS: "17.0", watchOS: "10.0", visionOS: "1.0"),
				restriction: nil,
			),
		]

		let file = SFSymbolDefinitionsFile.generate(
			symbols,
			for: .init(key: "shapes"),
			fileName: "SFSymbolResource+Shapes.generated.swift",
			using: context,
		)
		let outputURL = directory.appending(component: "SFSymbolResource+Shapes.generated.swift")
		try CodeGenerator().renderIfChanged(file, to: outputURL, using: context)
		let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)

		expectRendered(output, equals: try Fixtures.url("SFSymbolDefinitionsFile_PlatformDeprecation"))
	}
}

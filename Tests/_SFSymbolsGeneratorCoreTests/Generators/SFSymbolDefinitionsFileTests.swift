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
			SFSymbolMetadata.Symbol(
				name: "circle.fill",
				availability: nil,
				replacementName: "circle",
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
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore
import SwiftStructureKitTestSupport

@Suite(.tags(.renderer)) struct SFSymbolResourceFileTests {
	@Test(arguments: Self.permutations) func `generates convenience initializers only for requested frameworks`(_ input: TestInput) throws {
		let directory = try TempDir.create()
		defer { try? TempDir.remove(directory) }

		let context = try GeneratorTestContext.make(outputDirectory: directory, uiFrameworks: Set(input.uiFrameworks))
		let file = SFSymbolResourceFile.generate(
			fileName: "SFSymbolResource.generated.swift",
			using: context,
		)

		let outputURL = context.symbolResourceFile()
		try CodeGenerator().renderIfChanged(file, to: outputURL, using: context)
		let output = String(decoding: try Data(contentsOf: outputURL), as: UTF8.self)

		expectRendered(output, equals: try Fixtures.url(input.fixture))
	}

	// MARK: Test support

	struct TestInput {
		let uiFrameworks: [UIFramework]
		let fixture: String

		init(_ uiFrameworks: [UIFramework], _ fixture: String) {
			self.uiFrameworks = uiFrameworks
			self.fixture = fixture
		}
	}

	static let permutations: [TestInput] = [
		TestInput(UIFramework.allCases, "SFSymbolResourceFile_AppKitSwiftUIUIKit"),
		TestInput([.appKit], "SFSymbolResourceFile_AppKit"),
		TestInput([.swiftUI], "SFSymbolResourceFile_SwiftUI"),
		TestInput([.uiKit], "SFSymbolResourceFile_UIKit"),
	]
}

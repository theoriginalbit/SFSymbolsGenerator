//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct DiagnosticCollectorTests {
	@Test func `canEmit based on verbosity`() {
		let diagnostics = TestDiagnosticCollector(verbosity: .warning)
		#expect(diagnostics.canEmit(.fault("fault")))
		#expect(diagnostics.canEmit(.error("error")))
		#expect(diagnostics.canEmit(.warning("warning")))
		#expect(diagnostics.canEmit(.note("note")) == false)
		#expect(diagnostics.canEmit(.info("info")) == false)

		diagnostics.verbosity = .note
		#expect(diagnostics.canEmit(.fault("fault")))
		#expect(diagnostics.canEmit(.error("error")))
		#expect(diagnostics.canEmit(.warning("warning")))
		#expect(diagnostics.canEmit(.note("note")))
		#expect(diagnostics.canEmit(.info("info")) == false)

		diagnostics.verbosity = .info
		#expect(diagnostics.canEmit(.fault("fault")))
		#expect(diagnostics.canEmit(.error("error")))
		#expect(diagnostics.canEmit(.warning("warning")))
		#expect(diagnostics.canEmit(.note("notice")))
		#expect(diagnostics.canEmit(.info("info")))
	}

	static let describeForModes = [
		(DiagnosticMode.cli, "file.config"),
		(.xcode, "/Users/dev/Project/file.config"),
	]
	@Test(arguments: Self.describeForModes) func `Diagnostic description formatting in possible modes`(
		_ mode: DiagnosticMode,
		_ outputPath: String,
	) {
		let collector = TestDiagnosticCollector(mode: mode)
		let file = URL(fileURLWithPath: "/Users/dev/Project/file.config")

		// With line and column
		let loc1 = SourceLocation(file: file, line: 42, column: 8)
		let desc1 = collector.describe(.warning("Check value", location: loc1))
		#expect(desc1 == "\(outputPath):42:8: warning: Check value")

		// With line only
		let loc2 = SourceLocation(file: file, line: 15, column: nil)
		let desc2 = collector.describe(.error("Failed parse", location: loc2))
		#expect(desc2 == "\(outputPath):15: error: Failed parse")

		// With file only (no line/column)
		let loc3 = SourceLocation(file: file, line: nil, column: nil)
		let desc3 = collector.describe(.note("Loaded", location: loc3))
		#expect(desc3 == "\(outputPath): note: Loaded")

		// Without source location
		let desc4 = collector.describe(.note("Global notice"))
		#expect(desc4 == "note: Global notice")
	}
}

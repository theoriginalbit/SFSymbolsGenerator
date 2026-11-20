//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct StandardDiagnosticCollectorTests {
	@Test func `directs stdout and stderr appropriately`() {
		let stdOut = TestOutputHandle()
		let stdErr = TestOutputHandle()
		let collector = StandardDiagnosticCollector(
			stdOut: stdOut,
			stdErr: stdErr,
			mode: .cli,
			verbosity: 2, // allow info, notice, warning, error
		)

		#expect(!collector.hasErrors)

		collector.note("Notice text")
		collector.info("Info text")
		collector.warning("Warning text")

		#expect(stdOut.output.contains("note: Notice text\n"))
		#expect(stdOut.output.contains("info: Info text\n"))
		#expect(stdOut.output.contains("warning: Warning text\n"))
		#expect(stdErr.output.isEmpty)
		#expect(!collector.hasErrors)

		collector.error("Error text")
		#expect(stdOut.output.contains("note: Notice text\n"))
		#expect(stdOut.output.contains("info: Info text\n"))
		#expect(stdOut.output.contains("warning: Warning text\n"))
		#expect(stdErr.output.contains("error: Error text\n"))
		#expect(collector.hasErrors)
	}

	@Test func `respects verbosity filtering`() {
		let stdOut = TestOutputHandle()
		let stdErr = TestOutputHandle()
		let collector = StandardDiagnosticCollector(
			stdOut: stdOut,
			stdErr: stdErr,
			mode: .cli,
			verbosity: 0, // warnings, errors, faults only
		)

		collector.info("Info text")
		collector.note("Notice text")
		#expect(stdOut.output.isEmpty)

		collector.warning("Warning text")
		#expect(stdOut.output.contains("warning: Warning text\n"))
	}
}

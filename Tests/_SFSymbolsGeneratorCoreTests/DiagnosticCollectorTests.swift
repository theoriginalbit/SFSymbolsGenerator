//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct DiagnosticCollectorTests {
	@Test func `directs stdout and stderr appropriately`() {
		let output = TestDiagnosticOutput()
		let collector = DiagnosticCollector(
			mode: .xcode,
			verbose: true, // allow note, warning, error
			output: output
		)

		#expect(!collector.hasErrors)

		collector.note("Notice text")
		collector.warning("Warning text")

		#expect(output.contains("note: Notice text"))
		#expect(output.contains("warning: Warning text"))
		#expect(!collector.hasErrors)

		collector.error("Error text")
		#expect(output.contains("note: Notice text"))
		#expect(output.contains("warning: Warning text"))
		#expect(output.contains("error: Error text"))
		#expect(collector.hasErrors)
	}

	@Test func `respects verbosity filtering`() {
		let output = TestDiagnosticOutput()
		let collector = DiagnosticCollector(
			mode: .xcode,
			verbose: false, // allow warning, error
			output: output
		)

		collector.note("Notice text")
		#expect(output.isEmpty)

		collector.warning("Warning text")
		#expect(output.contains("warning: Warning text"))

		collector.error("Error text")
		#expect(output.contains("error: Error text"))
	}

	@Test func `url output for xcode`() {
		let output = TestDiagnosticOutput()
		let collector = DiagnosticCollector(
			mode: .xcode,
			verbose: false,
			output: output
		)

		let url = URL(fileURLWithPath: "/usr/whoami")
		let file = url.appending(path: "output", directoryHint: .isDirectory)
			.appending(component: "file.swift", directoryHint: .notDirectory)

		collector.error("Unable to locate file \(file)")
		#expect(output.contains("error: Unable to locate file /usr/whoami/output/file.swift"))
	}

	@Test func `url output for cli`() {
		let url = URL(fileURLWithPath: "/usr/whoami")

		let output = TestDiagnosticOutput()
		let collector = DiagnosticCollector(
			mode: .cli(basePath: url),
			verbose: false,
			output: output
		)

		let file = url.appending(path: "output", directoryHint: .isDirectory)
			.appending(component: "file.swift", directoryHint: .notDirectory)

		collector.error("Unable to locate file \(file)")
		#expect(output.contains("error: Unable to locate file output/file.swift"))
	}
}

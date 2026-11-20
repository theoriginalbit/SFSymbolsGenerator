//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Testing
@testable import _SFSymbolsGeneratorCore

final class TestDiagnosticCollector: DiagnosticCollector, @unchecked Sendable {
	let mode: DiagnosticMode
	var verbosity: Diagnostic.Severity
	var diagnostics: [Diagnostic] = []
	var writeToConsole: Bool = false

	var didEmitAnything: Bool {
		!diagnostics.isEmpty
	}

	var hasErrors: Bool {
		diagnostics.contains { $0.severity == .error }
	}

	var errors: [Diagnostic] {
		diagnostics.filter { $0.severity == .error }
	}

	var warnings: [Diagnostic] {
		diagnostics.filter { $0.severity == .warning }
	}

	var notices: [Diagnostic] {
		diagnostics.filter { $0.severity == .note }
	}

	var infos: [Diagnostic] {
		diagnostics.filter { $0.severity == .info }
	}

	init(mode: DiagnosticMode = .cli, verbosity: Diagnostic.Severity = .info) {
		self.mode = mode
		self.verbosity = verbosity
	}

	func emit(_ diagnostic: Diagnostic) {
		guard canEmit(diagnostic) else { return }
		if writeToConsole {
			print(diagnostic.message)
		}
		diagnostics.append(diagnostic)
	}
}

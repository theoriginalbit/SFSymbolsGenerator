//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Testing
@testable import _SFSymbolsGeneratorCore

final class TestDiagnosticOutput: DiagnosticOutput {
	private(set) var storage: [String] = []

	var isEmpty: Bool {
		storage.isEmpty
	}

	init() {}

	func writeLine(_ line: String) {
		storage.append(line)
	}

	func contains(_ string: String) -> Bool {
		storage.contains(string)
	}
}

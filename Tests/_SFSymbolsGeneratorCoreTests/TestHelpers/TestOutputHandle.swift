//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

final class TestOutputHandle: DiagnosticOutputHandle, @unchecked Sendable {
	private var _output = ""

	var output: String {
		_output
	}

	func write(_ data: Data) {
		if let string = String(data: data, encoding: .utf8) {
			_output += string
		}
	}
}

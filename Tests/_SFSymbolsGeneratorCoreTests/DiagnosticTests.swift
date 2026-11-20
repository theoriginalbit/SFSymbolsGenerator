//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct DiagnosticTests {
	@Test func `severity is ordered correctly`() {
		// synthesized enum ordering: fault < error < warning < notice < info
		#expect(Diagnostic.Severity.fault < .error)
		#expect(Diagnostic.Severity.error < .warning)
		#expect(Diagnostic.Severity.warning < .note)
		#expect(Diagnostic.Severity.note < .info)
	}

	@Test func `severity from verbosity`() {
		#expect(Diagnostic.Severity(verbosity: -1) == .warning)
		#expect(Diagnostic.Severity(verbosity: 0) == .warning)
		#expect(Diagnostic.Severity(verbosity: 1) == .note)
		#expect(Diagnostic.Severity(verbosity: 2) == .info)
		#expect(Diagnostic.Severity(verbosity: 5) == .info)
	}
}

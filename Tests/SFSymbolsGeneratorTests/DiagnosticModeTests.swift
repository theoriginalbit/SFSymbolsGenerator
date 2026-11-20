//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import Testing
@testable import sfgenerate

@Suite struct DiagnosticModeTests {
	@Test func `Ensure DiagnosticMode.allCases returns all cases`() {
		#expect(DiagnosticMode.allCases == [.cli, .xcode])
	}
}

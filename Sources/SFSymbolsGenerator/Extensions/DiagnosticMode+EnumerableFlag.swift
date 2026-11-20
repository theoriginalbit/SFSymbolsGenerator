//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import ArgumentParser

extension DiagnosticMode: EnumerableFlag {
	package static let allCases: [DiagnosticMode] = [.cli, .xcode]
}

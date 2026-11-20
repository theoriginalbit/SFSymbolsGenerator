//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import ArgumentParser

extension DiagnosticMode: ExpressibleByArgument {
	package init?(argument: String) {
		self.init(rawValue: argument)
	}

	package static var allValueStrings: [String] {
		allCases.map(\.rawValue)
	}

	package static var allValueDescriptions: [String : String] {
		[
			"cli": "Uses short file paths",
			"xcode": "Uses fully qualified file paths",
		]
	}

	package static var defaultCompletionKind: CompletionKind {
		.list(allValueStrings)
	}
}

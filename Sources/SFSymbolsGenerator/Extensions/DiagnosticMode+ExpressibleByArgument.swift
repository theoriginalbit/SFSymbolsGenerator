//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import ArgumentParser

extension DiagnosticMode: ExpressibleByArgument {
	package init?(argument: String) {
		switch argument.lowercased() {
		case "xcode": self = .xcode
		case "cli": self = .cli()
		default: return nil
		}
	}

	package static var allValueStrings: [String] {
		["xcode", "cli"]
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

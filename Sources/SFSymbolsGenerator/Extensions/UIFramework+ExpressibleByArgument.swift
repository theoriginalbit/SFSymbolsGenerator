//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import _SFSymbolsGeneratorCore
import ArgumentParser
import Foundation

extension UIFramework: ExpressibleByArgument {
	package init?(argument: String) {
		guard let match = Self.allCases.first(where: {
			$0.rawValue.caseInsensitiveCompare(argument) == .orderedSame
		}) else { return nil }
		self = match
	}

	package var defaultValueDescription: String {
		rawValue
	}

	package static var allValueStrings: [String] {
		Self.allCases.map(\.rawValue)
	}

	package static var defaultCompletionKind: CompletionKind {
		.list(allValueStrings)
	}
}

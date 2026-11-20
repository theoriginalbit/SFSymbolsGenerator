//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import ArgumentParser
import Foundation

extension Set: @retroactive ExpressibleByArgument where Element: CaseIterable & ExpressibleByArgument {
	public init?(argument: String) {
		var result: Set<Element> = []
		for part in argument.split(separator: ",") {
			guard let element = Element(argument: String(part)) else {
				return nil
			}
			result.insert(element)
		}
		self = result
	}

	public var defaultValueDescription: String {
		guard !isEmpty else { return "none" }
		return Element.allCases.lazy.filter(contains).map(\.defaultValueDescription).joined(separator: ",")
	}

	public static var defaultCompletionKind: CompletionKind {
		Element.defaultCompletionKind
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import SwiftStructureKit

extension ArrayBuilder {
	/// Allow function calls that return `Void`/`()` such as diagnostics
	static func buildExpression(_ expression: ()) -> Result {
		[]
	}

	static func buildExpression(_ expression: T?) -> Result {
		if let expression {
			return [expression]
		}
		return []
	}
}

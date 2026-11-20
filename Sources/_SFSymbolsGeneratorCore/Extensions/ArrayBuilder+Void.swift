//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import SwiftStructureKit

extension ArrayBuilder {
	/// Allow function calls that return `Void`/`()` such as diagnostics
	static func buildExpression(_ expression: ()) -> Result {
		[]
	}
}

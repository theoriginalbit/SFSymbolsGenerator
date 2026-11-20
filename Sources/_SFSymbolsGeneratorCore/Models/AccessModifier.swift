//
// Copyright © 2026 BuildSettingsKit. All rights reserved.
//

import Foundation

package enum AccessModifier: String, CaseIterable {
	case `public`
	case package
	case `internal`

	package static let allCasesAsList = AccessModifier.allCases
		.map(\.rawValue)
		.formatted(.list(type: .or))
}

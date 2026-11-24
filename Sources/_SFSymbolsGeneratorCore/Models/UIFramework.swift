//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

package enum UIFramework: String, Hashable, CaseIterable {
	case appKit = "AppKit"
	case uiKit = "UIKit"
	case swiftUI = "SwiftUI"

	package static let allCasesAsList = UIFramework.allCases
		.map(\.rawValue)
		.joined(separator: ",")
}

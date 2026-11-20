//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

package enum UIFramework: String, Hashable, CaseIterable {
	case uiKit = "UIKit"
	case appKit = "AppKit"
	case swiftUI = "SwiftUI"

	package static let allCasesAsList = UIFramework.allCases
		.map(\.rawValue)
		.joined(separator: ",")
}

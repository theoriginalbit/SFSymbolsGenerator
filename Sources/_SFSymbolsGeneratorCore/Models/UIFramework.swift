//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

package enum UIFramework: String, Hashable, CaseIterable {
	case appKit = "AppKit"
	case uiKit = "UIKit"
	case swiftUI = "SwiftUI"

	var fileNameDescription: String {
		rawValue
	}

	package static let allCasesSupportingSymbolExtensions: [UIFramework] = [.appKit, .uiKit]

	package static let allCasesAsList = UIFramework.allCases
		.map(\.rawValue)
		.joined(separator: ",")
}

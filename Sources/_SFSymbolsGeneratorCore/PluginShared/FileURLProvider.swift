//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct FileURLProvider {
	private static let fileNameBase = "SFSymbolResource"
	private static let fileExtension = "generated.swift"

	let outputDirectory: URL

	func symbolResourceFile() -> URL {
		let fileName = "\(Self.fileNameBase).\(Self.fileExtension)"
		return outputDirectory.appending(component: fileName)
	}

	func categoryFile(for category: SFSymbolCategory) -> URL {
		let fileName = "\(Self.fileNameBase)+\(category.fileNameDescription).\(Self.fileExtension)"
		return outputDirectory.appending(component: fileName)
	}

	func frameWorkConvenienceFile(_ uiFramework: UIFramework, for category: SFSymbolCategory) -> URL {
		let fileName = "\(Self.fileNameBase)+\(category.fileNameDescription)+\(uiFramework.fileNameDescription).\(Self.fileExtension)"
		return outputDirectory.appending(component: fileName)
	}

	enum UIFramework: String, Hashable, CaseIterable {
		case appKit = "AppKit"
		case uiKit = "UIKit"

		var fileNameDescription: String {
			rawValue
		}
	}
}

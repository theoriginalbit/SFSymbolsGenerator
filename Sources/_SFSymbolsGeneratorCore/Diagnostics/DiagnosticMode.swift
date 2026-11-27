//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

package enum DiagnosticMode {
	case cli(basePath: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
	case xcode

	func path(for url: URL) -> String {
		guard url.isFileURL else {
			return url.absoluteString
		}
		guard case let .cli(baseURL) = self else {
			return url.path(percentEncoded: false)
		}

		let baseComponents = baseURL.standardizedFileURL.resolvingSymlinksInPath().pathComponents
		let urlComponents = url.standardizedFileURL.resolvingSymlinksInPath().pathComponents

		guard urlComponents.starts(with: baseComponents), urlComponents.count > baseComponents.count else {
			return url.absoluteString
		}

		return urlComponents.dropFirst(baseComponents.count).joined(separator: "/")
	}

	func severity(_ severity: DiagnosticSeverity) -> String {
		switch severity {
		case .error: "error:"
		case .warning: "warning:"
		case .note:
			if case .xcode = self {
				"note:"
			} else {
				""
			}
		}
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct PluginError: LocalizedError {
	let message: String

	init(_ message: String) {
		self.message = message
	}

	var errorDescription: String? { message }
}

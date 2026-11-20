//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import ArgumentParser
import struct Foundation.URL

extension URL: @retroactive ExpressibleByArgument {
	/// Initializes a `URL` instance using the path provided as an argument string.
	public init?(argument: String) {
		self.init(fileURLWithPath: argument)
	}
}

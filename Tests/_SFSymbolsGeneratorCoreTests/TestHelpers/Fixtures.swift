//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing

enum Fixtures {
	static func url(
		_ name: String,
		in bundle: Bundle = .module,
		sourceLocation: SourceLocation = #_sourceLocation,
	) throws -> URL {
		let url = bundle.url(
			forResource: name,
			withExtension: "fixture",
			subdirectory: "Resources",
		)
		return try #require(url, "Unable to find fixture '\(name)'", sourceLocation: sourceLocation)
	}
}

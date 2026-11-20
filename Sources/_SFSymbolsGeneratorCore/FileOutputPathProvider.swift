//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct FileOutputPathProvider {
	let outputDirectory: URL

	init(outputDirectory: URL) {
		self.outputDirectory = outputDirectory
	}

	func symbolResourceFile() -> URL {
		outputDirectory.appending(component: "SFSymbolResource.generated.swift")
	}

	func categoryFile(for category: SFSymbolMetadata.Category) -> URL {
		outputDirectory.appending(component: "SFSymbolResource+\(category).generated.swift")
	}
}

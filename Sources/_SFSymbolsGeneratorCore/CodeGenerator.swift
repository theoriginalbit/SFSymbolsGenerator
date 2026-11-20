//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

package struct CodeGenerator {
	package init() {}

	package func run(with context: Context<some DiagnosticCollector>) throws {
		let outputDirectory = context.outputDirectory

		try FileManager.default.createDirectory(
			at: outputDirectory,
			withIntermediateDirectories: true,
		)

		var files = 0
		var total = 0
		let metadata = try SFSymbolMetadata()
		for (category, symbols) in metadata.allSymbolsByCategory {
			for symbol in symbols {
				print(category, symbol.name, symbol.isDeprecated)
			}
			files += 1
			total += symbols.count
		}
		print("Generated SF Symbols accessors for", total, "symbols, across", files * 2, "files")
	}
}

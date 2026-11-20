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
	}
}

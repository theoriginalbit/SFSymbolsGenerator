//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

package extension CodeGenerator {
	struct Context<Diagnostics: DiagnosticCollector> {
		let outputDirectory: URL
		let diagnostics: Diagnostics

		package init(
			outputDirectory: URL,
			diagnostics: Diagnostics,
		) {
			self.outputDirectory = outputDirectory
			self.diagnostics = diagnostics
		}
	}
}

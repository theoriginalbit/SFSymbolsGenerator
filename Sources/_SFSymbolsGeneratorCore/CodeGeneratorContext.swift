//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

package extension CodeGenerator {
	struct Context<Diagnostics: DiagnosticCollector> {
		let outputDirectory: URL
		let diagnostics: Diagnostics
		let accessModifier: AccessModifier

		package init(
			outputDirectory: URL,
			diagnostics: Diagnostics,
			accessModifier: AccessModifier
		) {
			self.outputDirectory = outputDirectory
			self.diagnostics = diagnostics
			self.accessModifier = accessModifier
		}
	}
}

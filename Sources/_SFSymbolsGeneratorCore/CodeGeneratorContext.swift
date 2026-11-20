//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL
import enum SwiftStructureKit.AccessModifierDescriptor

package extension CodeGenerator {
	struct Context<Diagnostics: DiagnosticCollector> {
		let outputDirectory: URL
		let diagnostics: Diagnostics
		let accessModifier: AccessModifierDescriptor

		package init(
			outputDirectory: URL,
			diagnostics: Diagnostics,
			accessModifier: AccessModifier
		) {
			self.outputDirectory = outputDirectory
			self.diagnostics = diagnostics
			self.accessModifier = switch accessModifier {
			case .public: .public
			case .package: .package
			case .internal: .internal
			}
		}
	}
}

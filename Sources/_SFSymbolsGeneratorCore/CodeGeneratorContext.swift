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
		let symbolExtensions: Bool
		let uiFrameworks: Set<UIFramework>
		let rawIdentifiers: Bool
		let isRunningAsBuildTool: Bool

		package init(
			outputDirectory: URL,
			diagnostics: Diagnostics,
			accessModifier: AccessModifier,
			symbolExtensions: Bool,
			uiFrameworks: Set<UIFramework>,
			rawIdentifiers: Bool,
			isRunningAsBuildTool: Bool,
		) {
			self.outputDirectory = outputDirectory
			self.diagnostics = diagnostics
			self.accessModifier = switch accessModifier {
			case .public: .public
			case .package: .package
			case .internal: .internal
			}
			self.symbolExtensions = symbolExtensions
			self.uiFrameworks = uiFrameworks
			self.rawIdentifiers = rawIdentifiers
			self.isRunningAsBuildTool = isRunningAsBuildTool
		}
	}
}

package extension CodeGenerator.Context {
	func note(_ message: String, location: SourceLocation? = nil) {
		diagnostics.note(message, location: location)
	}

	func info(_ message: String, location: SourceLocation? = nil) {
		diagnostics.info(message, location: location)
	}

	func warning(_ message: String, location: SourceLocation? = nil) {
		diagnostics.warning(message, location: location)
	}

	func error(_ message: String, location: SourceLocation? = nil) {
		diagnostics.error(message, location: location)
	}

	/// - Important: Emitting a fault will output the diagnostic and immediately exit the process
	func fault(_ message: String, location: SourceLocation? = nil) {
		diagnostics.fault(message, location: location)
	}
}

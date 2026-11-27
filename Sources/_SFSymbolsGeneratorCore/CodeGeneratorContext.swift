//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import enum SwiftStructureKit.AccessModifierDescriptor

package extension CodeGenerator {
	struct Context<Output: DiagnosticOutput> {
		let outputDirectory: URL
		let diagnostics: DiagnosticCollector<Output>
		let _accessModifier: AccessModifier
		let accessModifier: AccessModifierDescriptor
		let symbolExtensions: Bool
		let uiFrameworks: Set<UIFramework>
		let rawIdentifiers: Bool
		let isRunningAsBuildTool: Bool

		package init(
			outputDirectory: URL,
			diagnostics: DiagnosticCollector<Output>,
			accessModifier: AccessModifier,
			symbolExtensions: Bool,
			uiFrameworks: Set<UIFramework>,
			rawIdentifiers: Bool,
			isRunningAsBuildTool: Bool,
		) {
			self.outputDirectory = outputDirectory
			self.diagnostics = diagnostics
			self._accessModifier = accessModifier
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
	func note(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		diagnostics.note(message, at: location)
	}

	func warning(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		diagnostics.warning(message, at: location)
	}

	func error(_ message: DiagnosticMessage, location: SourceLocation? = nil) {
		diagnostics.error(message, at: location)
	}

	func fault(_ message: DiagnosticMessage, location: SourceLocation? = nil, exitCode: Int32 = EXIT_FAILURE) -> Never {
		diagnostics.fault(message, at: location)
	}
}

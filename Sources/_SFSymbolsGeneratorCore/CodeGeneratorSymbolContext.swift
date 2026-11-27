//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

extension CodeGenerator {
	/// Context required to generate files in addition to the Context supplied by the command.
	@dynamicMemberLookup
	struct SymbolContext<Output: DiagnosticOutput> {

		let context: Context<Output>
		let metadata: SFSymbolMetadata
		let fileURLProvider: FileURLProvider

		init(context: Context<Output>, metadata: SFSymbolMetadata) {
			self.context = context
			self.metadata = metadata
			self.fileURLProvider = FileURLProvider(outputDirectory: context.outputDirectory)
		}

		subscript<T>(dynamicMember keyPath: KeyPath<Context<Output>, T>) -> T {
			context[keyPath: keyPath]
		}

		func swiftIdentifier(for value: SFSymbol) -> String? {
			if context.rawIdentifiers {
				return "`\(value.name)`"
			} else {
				return Identifier.camelCased(value.name)?.value
			}
		}

		func swiftRenameParameter(for value: String) -> String? {
			if context.rawIdentifiers {
				// BUG: SE-0451 did not support raw identifiers in renamed attribute
				//   Fix is expected in Swift 6.5 but for now we must handle
				//   Ref: https://forums.swift.org/t/se-0451-vs-renamed-attributes/86268
				nil
			} else {
				Identifier.camelCased(value)?.value
			}
		}

		func symbolResourceFile() -> URL {
			fileURLProvider.symbolResourceFile()
		}

		func categoryFile(for category: SFSymbolCategory) -> URL {
			fileURLProvider.categoryFile(for: category)
		}

		func frameWorkConvenienceFile(_ uiFramework: UIFramework, for category: SFSymbolCategory) -> URL? {
			switch uiFramework {
			case .appKit:
				fileURLProvider.frameWorkConvenienceFile(.appKit, for: category)
			case .uiKit:
				fileURLProvider.frameWorkConvenienceFile(.uiKit, for: category)
			case .swiftUI:
				nil
			}
		}

		// MARK: Diagnostics conveniences

		func note(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
			context.diagnostics.note(message, at: location)
		}

		func warning(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
			context.diagnostics.warning(message, at: location)
		}

		func error(_ message: DiagnosticMessage, location: SourceLocation? = nil) {
			context.diagnostics.error(message, at: location)
		}

		func fault(_ message: DiagnosticMessage, location: SourceLocation? = nil, exitCode: Int32 = EXIT_FAILURE) -> Never {
			context.diagnostics.fault(message, at: location)
		}
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

extension CodeGenerator {
	/// Context required to generate files in addition to the Context supplied by the command.
	@dynamicMemberLookup
	struct SymbolContext<Diagnostics: DiagnosticCollector> {
		let context: Context<Diagnostics>
		let metadata: SFSymbolMetadata

		init(context: Context<Diagnostics>, metadata: SFSymbolMetadata) {
			self.context = context
			self.metadata = metadata
		}

		subscript<T>(dynamicMember keyPath: KeyPath<Context<Diagnostics>, T>) -> T {
			context[keyPath: keyPath]
		}

		func symbolResourceFile() -> URL {
			context.outputDirectory.appending(component: "SFSymbolResource.generated.swift")
		}

		func categoryFile(for category: SFSymbolMetadata.Category) -> URL {
			context.outputDirectory.appending(component: "SFSymbolResource+\(category).generated.swift")
		}

		func frameWorkConvenienceFile(_ uiFramework: UIFramework, for category: SFSymbolMetadata.Category) -> URL {
			context.outputDirectory.appending(component: "SFSymbolResource+\(category)+\(uiFramework.rawValue).generated.swift")
		}

		// MARK: Diagnostics conveniences

		func note(_ message: String, location: SourceLocation? = nil) {
			context.diagnostics.note(message, location: location)
		}

		func info(_ message: String, location: SourceLocation? = nil) {
			context.diagnostics.info(message, location: location)
		}

		func warning(_ message: String, location: SourceLocation? = nil) {
			context.diagnostics.warning(message, location: location)
		}

		func error(_ message: String, location: SourceLocation? = nil) {
			context.diagnostics.error(message, location: location)
		}

		/// - Important: Emitting a fault will output the diagnostic and immediately exit the process
		func fault(_ message: String, location: SourceLocation? = nil) {
			context.diagnostics.fault(message, location: location)
		}
	}
}

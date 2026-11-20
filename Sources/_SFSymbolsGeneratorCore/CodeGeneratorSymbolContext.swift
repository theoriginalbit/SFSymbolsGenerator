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
	}
}

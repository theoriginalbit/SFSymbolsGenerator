//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

enum SFSymbolFrameworkExtensionsFile {
	static func generate(
		_ framework: UIFramework,
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		fileName: String,
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> SwiftFile {
		SwiftFile(headerComment: CommonFile.fileHeader(fileName: fileName)) {
			conditionalImport(for: framework)
		}
	}

	static func conditionalImport(for framework: UIFramework) -> TopLevelDeclarationDescriptor {
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(\(framework.rawValue))") {
			ImportDescriptor(framework.rawValue)
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}
}

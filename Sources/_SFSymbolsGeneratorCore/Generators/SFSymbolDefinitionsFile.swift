//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

enum SFSymbolDefinitionsFile {
	static func generate(
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		fileName: String,
		using context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> SwiftFile {
		SwiftFile(headerComment: CommonFile.fileHeader(fileName: fileName)) {
			ExtensionDescriptor(.identifier(CommonFile.resourceStructName), accessModifier: context.accessModifier) {
				for symbol in symbols {
					if let identifier = context.swiftIdentifier(for: symbol) {
						PropertyDescriptor.let(
							identifier,
							comment: CommonFile.propertyComment(for: symbol),
							attributes: CommonFile.propertyAttributes(for: symbol, using: context),
							isStatic: true,
							type: .identifier(CommonFile.resourceStructName),
							defaultValue: ExpressionDescriptor.functionCall(.identifier(CommonFile.resourceStructName)) {
								Argument(label: CommonFile.systemNameProperty, value: .literal(.string(symbol.name)))
							},
						)
					} else {
						context.fault("internal error: could not generate valid identifier for symbol \(symbol.name)")
					}
				}
			}
		}
	}
}

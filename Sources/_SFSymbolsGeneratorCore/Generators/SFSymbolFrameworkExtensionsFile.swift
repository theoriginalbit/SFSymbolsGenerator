//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

enum SFSymbolFrameworkExtensionsFile {
	static func generate(
		_ framework: UIFramework,
		symbols: [SFSymbolMetadata.Symbol],
		fileName: String,
		using context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> SwiftFile? {
		let fileBody: TopLevelDeclarationDescriptor?
		switch framework {
		case .appKit:
			fileBody = appKitConvenienceAccessorExtension(for: symbols, using: context)
		case .uiKit:
			fileBody = uiKitConvenienceAccessorExtension(for: symbols, using: context)
		case .swiftUI:
			// SwiftUI Image will not have conveniences generated, as per Apple resource symbol generation
			return nil
		}
		guard let fileBody else { return nil }
		return SwiftFile(headerComment: CommonFile.fileHeader(fileName: fileName)) {
			fileBody
		}
	}

	static func appKitConvenienceAccessorExtension(
		for symbols: [SFSymbolMetadata.Symbol],
		using context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> TopLevelDeclarationDescriptor? {
		guard context.uiFrameworks.contains(.appKit) else {
			return nil
		}
		let attributes: [AttributeDescriptor] = [
			.available(.platform(.macCatalyst), .unavailable)
		]
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(AppKit)") {
			ImportDescriptor("AppKit")

			ExtensionDescriptor(.identifier("AppKit.NSImage"), accessModifier: context.accessModifier, attributes: attributes) {
				for symbol in symbols {
					if let identifier = context.swiftIdentifier(for: symbol) {
						FunctionDescriptor.function(
							comment: CommonFile.propertyComment(for: symbol),
							attributes: CommonFile.propertyAttributes(for: symbol, using: context),
							name: identifier,
							returns: .identifier("AppKit.NSImage"),
							isStatic: true,
							parameters: ParametersList {
								Parameter("accessibilityDescription", type: .optional(.string), defaultValue: .literal(.nil))
							},
						) {
							StatementDescriptor.compilerControl(.conditional(
								.if(.raw("!targetEnvironment(macCatalyst)")) {
									ExpressionDescriptor.functionCall("self.init") {
										Argument(label: "system", value: .memberAccess(nil, identifier))
										Argument(label: "accessibilityDescription", value: .identifier("accessibilityDescription"))
									}
								} else: {
									ExpressionDescriptor.functionCall("self.init")
								}
							))
						}
					} else {
						context.fault("internal error: could not generate valid identifier for symbol \(symbol.name)")
					}
				}
			}
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}

	static func uiKitConvenienceAccessorExtension(
		for symbols: [SFSymbolMetadata.Symbol],
		using context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> TopLevelDeclarationDescriptor? {
		guard context.uiFrameworks.contains(.uiKit) else {
			return nil
		}
		let attributes: [AttributeDescriptor] = [
			.available(.platform(.watchOS), .unavailable)
		]
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(UIKit)") {
			ImportDescriptor("UIKit")

			ExtensionDescriptor(.identifier("UIKit.UIImage"), accessModifier: context.accessModifier, attributes: attributes) {
				for symbol in symbols {
					if let identifier = context.swiftIdentifier(for: symbol) {
						PropertyDescriptor.computed(
							identifier,
							comment: CommonFile.propertyComment(for: symbol),
							attributes: CommonFile.propertyAttributes(for: symbol, using: context),
							isStatic: true,
							type: .identifier("UIKit.UIImage"),
						) {
							StatementDescriptor.compilerControl(.conditional(
								.if(.raw("!os(watchOS)")) {
									ExpressionDescriptor.functionCall("self.init") {
										Argument(label: "system", value: .memberAccess(nil, identifier))
									}
								} else: {
									ExpressionDescriptor.functionCall("self.init")
								}
							))
						}
					} else {
						context.fault("internal error: could not generate valid identifier for symbol \(symbol.name)")
					}
				}
			}
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}
}

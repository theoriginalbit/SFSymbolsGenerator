//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

enum SFSymbolResourceFile {
	static func generate(
		fileName: String,
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> SwiftFile {
		SwiftFile(headerComment: CommonFile.fileHeader(fileName: fileName)) {
			StructDescriptor(
				CommonFile.resourceStructName,
				comment: "An SF Symbol resource.",
				accessModifier: context.accessModifier,
				conformances: ["Hashable", .sendable]
			) {
				PropertyDescriptor.let(
					CommonFile.systemNameProperty,
					comment: "An SF Symbol system name.",
					accessModifier: context.accessModifier,
					type: .string
				)

				FunctionDescriptor.initializer(
					comment: "Initialize a ``\(CommonFile.resourceStructName)`` with `\(CommonFile.systemNameProperty)`.",
					// fileprivate would be ideal, but since we are splitting code generation over
					// multiple files for compiler/previewing performance it must be internal
					accessModifier: .internal,
					parameters: [
						Parameter("name", label: CommonFile.systemNameProperty, type: .string, comment: "The SF Symbol system name.")
					]
				) {
					StatementDescriptor.assignment(.selfMember(CommonFile.systemNameProperty), .identifier("name"))
				}
			}

			for framework in UIFramework.allCases {
				switch framework {
				case .appKit: appKitConvenienceInitExtension(with: context)
				case .uiKit: uiKitConvenienceInitExtension(with: context)
				case .swiftUI: swiftUIConvenienceInitExtension(with: context)
				}
			}
		}
	}

	static func appKitConvenienceInitExtension(
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> TopLevelDeclarationDescriptor? {
		guard context.uiFrameworks.contains(.appKit) else {
			return nil
		}
		let attributes: [AttributeDescriptor] = [
			.available(.platform(.macCatalyst), .unavailable)
		]
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(AppKit)") {
			ImportDescriptor("AppKit")

			ProtocolDescriptor("_SFResourceInitProtocol", accessModifier: context.accessModifier) {}

			ExtensionDescriptor(.identifier("AppKit.NSImage"), conformances: [.identifier("_SFResourceInitProtocol")])

			ExtensionDescriptor(.identifier("_SFResourceInitProtocol"), accessModifier: context.accessModifier, attributes: attributes) {
				FunctionDescriptor.initializer(
					comment: "Initialize an `NSImage` with an SF Symbol resource.",
					parameters: ParametersList {
						Parameter("resource", label: "system", type: .identifier(CommonFile.resourceStructName))
						Parameter("accessibilityDescription", type: .optional(.string))
					}) {
						StatementDescriptor.assignment(
							AssignmentStatementDescriptor(
								"self",
								ExpressionDescriptor.forcedValue(
									.functionCall("AppKit.NSImage") {
										Argument(label: "systemSymbolName", value: .memberAccess("resource", CommonFile.systemNameProperty))
										Argument(label: "accessibilityDescription", value: .identifier("accessibilityDescription"))
									}
								).as(.selfType, .forced)
							)
						)
					}
			}
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}

	static func uiKitConvenienceInitExtension(
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
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
				FunctionDescriptor.initializer(
					comment: "Initialize a `UIImage` with an SF Symbol resource.",
					convenience: true,
					parameters: ParametersList {
						Parameter("resource", label: "system", type: .identifier(CommonFile.resourceStructName))
					}) {
						StatementDescriptor.compilerControl(.conditional(
							.if(.raw("!os(watchOS)")) {
								ExpressionDescriptor.functionCall("self.init") {
									Argument(label: CommonFile.systemNameProperty, value: .memberAccess("resource", CommonFile.systemNameProperty))
								}
							} else: {
								ExpressionDescriptor.functionCall("self.init")
							}
						))
					}
			}
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}

	static func swiftUIConvenienceInitExtension(
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> TopLevelDeclarationDescriptor? {
		guard context.uiFrameworks.contains(.swiftUI) else {
			return nil
		}
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(SwiftUI)") {
			ImportDescriptor("SwiftUI")

			ExtensionDescriptor(.identifier("SwiftUI.Image"), accessModifier: context.accessModifier) {
				FunctionDescriptor.initializer(
					comment: "Initialize an `Image` with an SF Symbol resource.",
					parameters: ParametersList {
						Parameter("resource", label: "system", type: .identifier(CommonFile.resourceStructName))
					}) {
						ExpressionDescriptor.functionCall("self.init") {
							Argument(label: CommonFile.systemNameProperty, value: .memberAccess("resource", CommonFile.systemNameProperty))
						}
					}
			}
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}
}

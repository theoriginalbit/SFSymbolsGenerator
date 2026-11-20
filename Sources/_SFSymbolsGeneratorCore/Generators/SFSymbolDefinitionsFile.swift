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
		with context: CodeGenerator.SymbolContext<some DiagnosticCollector>,
	) -> SwiftFile {
		SwiftFile(headerComment: CommonFile.fileHeader(fileName: fileName)) {
			ExtensionDescriptor(.identifier(CommonFile.resourceStructName), accessModifier: context.accessModifier) {
				for symbol in symbols {
					if let identifier = Identifier.camelCased(symbol.name)?.value {
						PropertyDescriptor.let(
							identifier,
							comment: propertyComment(for: symbol),
							attributes: propertyAttributes(for: symbol),
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

	private static func propertyComment(for symbol: SFSymbolMetadata.Symbol) -> DocCommentDescriptor {
		guard let restriction = symbol.restriction else {
			return #"The "\#(symbol.name)" SF Symbol."#
		}
		return """
			The "\(symbol.name)" SF Symbol.

			- Important: \(restriction)
			"""
	}

	private static func propertyAttributes(for symbol: SFSymbolMetadata.Symbol) -> [AttributeDescriptor] {
		var result: [AttributeDescriptor] = []
		if let attribute = availabilityAttribute(for: symbol) {
			result.append(attribute)
		}
		if let attribute = deprecationAttribute(for: symbol) {
			result.append(attribute)
		}
		return result
	}

	private static func availabilityAttribute(for symbol: SFSymbolMetadata.Symbol) -> AttributeDescriptor? {
		guard let iOS = platformVersion(\.iOS, from: symbol),
			  let macOS = platformVersion(\.macOS, from: symbol),
			  let watchOS = platformVersion(\.watchOS, from: symbol),
			  let tvOS = platformVersion(\.tvOS, from: symbol),
			  let visionOS = platformVersion(\.visionOS, from: symbol)
				else { return nil }
		return .available(
			AvailabilityArgumentsList(
				iOS: iOS,
				macOS: macOS,
				watchOS: watchOS,
				tvOS: tvOS,
				visionOS: visionOS
			)
		)
	}

	private static func platformVersion(
		_ keyPath: KeyPath<SFSymbolMetadata.Availability, String>,
		from symbol: SFSymbolMetadata.Symbol
	) -> PlatformVersion? {
		guard let availability = symbol.availability?[keyPath: keyPath] else {
			return nil
		}
		return PlatformVersion(parsing: availability)
	}

	private static func deprecationAttribute(for symbol: SFSymbolMetadata.Symbol) -> AttributeDescriptor? {
		guard let replacementName = symbol.replacementName else {
			return nil
		}
		return .available(
			.deprecated,
			.renamed(replacementName),
			.message("This name has been deprecated. You should use a more modern name if your app does not need to support older platforms.")
		)
	}
}

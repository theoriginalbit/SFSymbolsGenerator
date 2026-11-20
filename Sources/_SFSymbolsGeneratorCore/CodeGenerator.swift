//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import SwiftStructureKit

package struct CodeGenerator {
	private static let resourceStructName = "SFSymbolResource"
	private static let systemNameProperty = "systemName"

	package init() {}

	package func run(with context: Context<some DiagnosticCollector>) throws {
		// Try to load early, in case CoreGlyphs is missing (how?) or changed.
		let metadata = try SFSymbolMetadata()

		// Make sure the output directory exists
		try FileManager.default.createDirectory(
			at: context.outputDirectory,
			withIntermediateDirectories: true,
		)

		informUserAboutFilesThatWillBeSkippedBasedOnContext(context)

		let context = SymbolContext(context: context, metadata: metadata)

		// counters for a nice little message at the end
		var totalFiles = 1
		var totalSymbols = 0

		try generateSFSymbolResourceFile(with: context)

		for category in metadata.categories {
			let (filesCount, symbolsCount) = try generateSFSymbolFiles(for: category, with: context)
			totalFiles += filesCount
			totalSymbols += symbolsCount
		}
		print("Generated", totalFiles, "files for", totalSymbols, "SF Symbols")

		// Abort if any diagnostic errors were prevented complete generation
		guard !context.diagnostics.hasErrors else {
			throw GeneratorError.generationFailed
		}
	}

	func generateSFSymbolResourceFile(
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		let output = context.symbolResourceFile()

		let file = SwiftFile(headerComment: fileHeader(for: output)) {
			StructDescriptor(
				Self.resourceStructName,
				comment: "An SF Symbol resource.",
				accessModifier: context.accessModifier,
				conformances: ["Hashable", .sendable]
			) {
				PropertyDescriptor.let(
					Self.systemNameProperty,
					comment: "An SF Symbol system name.",
					accessModifier: context.accessModifier,
					type: .string
				)

				FunctionDescriptor.initializer(
					comment: "Initialize a ``\(Self.resourceStructName)`` with `\(Self.systemNameProperty)`.",
					// fileprivate would be ideal, but since we are splitting code generation over
					// multiple files for compiler/previewing performance it must be internal
					accessModifier: .internal,
					parameters: [
						Parameter("name", label: Self.systemNameProperty, type: .string, comment: "The SF Symbol system name.")
					]
				) {
					StatementDescriptor.assignment(.selfMember(Self.systemNameProperty), .identifier("name"))
				}
			}
		}

		try renderIfChanged(file, to: output, with: context)
	}

	func generateSFSymbolFiles(
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> (filesCount: Int, symbolsCount: Int) {
		let symbols = context.metadata.symbols(in: category)

		var filesCount: Int = 0

		filesCount += try generateSFSymbolDefinitionsFile(symbols, for: category, with: context)
		// always attempt all UI frameworks, let the generate function determine how
		// to write it based on context.uiFrameworks
		for framework in UIFramework.allCases {
			filesCount += try generateSFSymbolFrameworkExtensionsFile(framework, symbols, for: category, with: context)
		}

		return (filesCount, symbols.count)
	}

	func generateSFSymbolDefinitionsFile(
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> Int {
		let output = context.categoryFile(for: category)

		let file = SwiftFile(headerComment: fileHeader(for: output)) {
			ExtensionDescriptor(.identifier(Self.resourceStructName), accessModifier: context.accessModifier) {
				for symbol in symbols {
					if let identifier = Identifier.camelCased(symbol.name)?.value {
						PropertyDescriptor.let(
							identifier,
							comment: propertyComment(for: symbol),
							attributes: propertyAttributes(for: symbol),
							isStatic: true,
							type: .identifier(Self.resourceStructName),
							defaultValue: ExpressionDescriptor.functionCall(.identifier(Self.resourceStructName)) {
								Argument(label: Self.systemNameProperty, value: .literal(.string(symbol.name)))
							},
						)
					} else {
						context.fault("internal error: could not generate valid identifier for symbol \(symbol.name)")
					}
				}
			}
		}

		try renderIfChanged(file, to: output, with: context)
		return 1
	}

	func generateSFSymbolFrameworkExtensionsFile(
		_ framework: UIFramework,
		_ symbols: [SFSymbolMetadata.Symbol],
		for category: SFSymbolMetadata.Category,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws -> Int {
		let output = context.frameWorkConvenienceFile(framework, for: category)

		guard context.symbolExtensions, context.uiFrameworks.contains(framework) else {
			if context.isRunningAsBuildTool {
				try renderIfChanged(Data(), to: output, with: context)
				return 1
			}
			context.info("Skipping writing to \(output.path())")
			return 0
		}

		let file = SwiftFile(headerComment: fileHeader(for: output)) {
			conditionalImport(for: framework)
		}

		try renderIfChanged(file, to: output, with: context)
		return 1
	}

	func renderIfChanged(
		_ file: SwiftFile,
		to outputURL: URL,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		let data = file.render(indentUsing: .spaces(4))
		try renderIfChanged(data, to: outputURL, with: context)
	}

	func renderIfChanged(
		_ data: Data,
		to outputURL: URL,
		with context: SymbolContext<some DiagnosticCollector>,
	) throws {
		if let existingData = try? Data(contentsOf: outputURL), existingData == data {
			// Content is identical, no write needed otherwise we would update the modified time
			context.info("No changes needed to \(outputURL.path())")
			return
		}

		try data.write(to: outputURL, options: .atomic)
		context.info("Written to \(outputURL.path())")
	}

	private func fileHeader(for outputURL: URL) -> FileHeaderCommentDescriptor {
		"""
		\(outputURL.lastPathComponent)
		Auto-generated by SFSymbolsGenerator.
		DO NOT EDIT — changes will be overwritten on the next build.
		"""
	}

	private func propertyComment(for symbol: SFSymbolMetadata.Symbol) -> DocCommentDescriptor {
		guard let restriction = symbol.restriction else {
			return #"The "\#(symbol.name)" SF Symbol."#
		}
		return """
			The "\(symbol.name)" SF Symbol.

			- Important: \(restriction)
			"""
	}

	private func propertyAttributes(for symbol: SFSymbolMetadata.Symbol) -> [AttributeDescriptor] {
		var result: [AttributeDescriptor] = []
		if let attribute = availabilityAttribute(for: symbol) {
			result.append(attribute)
		}
		if let attribute = deprecationAttribute(for: symbol) {
			result.append(attribute)
		}
		return result
	}

	private func availabilityAttribute(for symbol: SFSymbolMetadata.Symbol) -> AttributeDescriptor? {
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

	private func platformVersion(
		_ keyPath: KeyPath<SFSymbolMetadata.Availability, String>,
		from symbol: SFSymbolMetadata.Symbol
	) -> PlatformVersion? {
		guard let availability = symbol.availability?[keyPath: keyPath] else {
			return nil
		}
		return PlatformVersion(parsing: availability)
	}

	private func deprecationAttribute(for symbol: SFSymbolMetadata.Symbol) -> AttributeDescriptor? {
		guard let replacementName = symbol.replacementName else {
			return nil
		}
		return .available(
			.deprecated,
			.renamed(replacementName),
			.message("This name has been deprecated. You should use a more modern name if your app does not need to support older platforms.")
		)
	}

	private func conditionalImport(for framework: UIFramework) -> TopLevelDeclarationDescriptor {
		let conditionalImport = TopLevelCompilerConditionalIfDescriptor("canImport(\(framework.rawValue))") {
			ImportDescriptor(framework.rawValue)
		}
		return .compilerControl(.conditional(.if(conditionalImport)))
	}

	private func informUserAboutFilesThatWillBeSkippedBasedOnContext(_ context: Context<some DiagnosticCollector>,) {
		for framework in UIFramework.allCases {
			guard !context.symbolExtensions || !context.uiFrameworks.contains(framework) else {
				continue
			}
			var failingReason = context.symbolExtensions
			? "Requested UI frameworks did not include \(framework.rawValue)"
			: "UI framework extensions were disabled"
			if context.isRunningAsBuildTool {
				failingReason += "; will generate empty \(framework.rawValue) files for build tool"
			} else {
				failingReason += "; will not generate \(framework.rawValue) files"
			}
			context.info(failingReason)
		}
	}
}

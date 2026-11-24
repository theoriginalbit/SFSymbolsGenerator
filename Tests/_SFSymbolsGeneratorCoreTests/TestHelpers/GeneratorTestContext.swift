//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
@testable import _SFSymbolsGeneratorCore

enum GeneratorTestContext {
	static func make(
		outputDirectory: URL,
		uiFrameworks: Set<UIFramework> = [],
		rawIdentifiers: Bool = false,
	) throws -> CodeGenerator.SymbolContext<TestDiagnosticCollector> {
		try writePlist(
			[
				"symbols": ["circle.fill": "unmapped-year"],
				"year_to_release": [String: [String: String]](),
			] as [String: Any],
			named: "name_availability.plist",
			to: outputDirectory,
		)
		try writePlist([String: String](), named: "symbol_restrictions.strings", to: outputDirectory)
		try writePlist([String: String](), named: "name_aliases.strings", to: outputDirectory)
		try writePlist([["key": "shapes"]], named: "categories.plist", to: outputDirectory)
		try writePlist(["circle.fill": ["shapes"]], named: "symbol_categories.plist", to: outputDirectory)

		let metadata = try SFSymbolMetadata(resourceFolder: outputDirectory)
		return CodeGenerator.SymbolContext(
			context: CodeGenerator.Context(
				outputDirectory: outputDirectory,
				diagnostics: TestDiagnosticCollector(),
				accessModifier: .public,
				symbolExtensions: true,
				uiFrameworks: uiFrameworks,
				rawIdentifiers: rawIdentifiers,
				isRunningAsBuildTool: false,
			),
			metadata: metadata,
		)
	}

	private static func writePlist(_ value: Any, named name: String, to directory: URL) throws {
		let data = try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: 0)
		try data.write(to: directory.appending(component: name))
	}
}

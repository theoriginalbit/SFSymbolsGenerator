//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct SFSymbolMetadataTests {
	@Test func `uses replacement symbol availability for deprecated aliases`() throws {
		let resources = try TempDir.create()
		defer { try? TempDir.remove(resources) }

		try writePlist(
			[
				"symbols": ["old.symbol": "old-year", "new.symbol": "new-year"],
				"year_to_release": [
					"old-year": [
						"iOS": "14.0", "macOS": "11.0", "tvOS": "14.0", "watchOS": "7.0", "visionOS": "1.0",
					],
					"new-year": [
						"iOS": "17.0", "macOS": "15.0", "tvOS": "17.0", "watchOS": "10.0", "visionOS": "1.0",
					],
				],
			] as [String: Any],
			named: "name_availability.plist",
			to: resources,
		)
		try writePlist(["old.symbol": "new.symbol"], named: "name_aliases.strings", to: resources)
		try writePlist([String: String](), named: "symbol_restrictions.strings", to: resources)
		try writePlist([Any](), named: "categories.plist", to: resources)
		try writePlist([String: [String]](), named: "symbol_categories.plist", to: resources)

		let metadata = try SFSymbolMetadata(resourceFolder: resources)
		let symbol = try #require(metadata.symbols(in: .init(key: "uncategorized")).first { $0.name == "old.symbol" })

		#expect(symbol.replacementName == "new.symbol")
		#expect(symbol.replacementAvailability?.iOS == "17.0")
		#expect(symbol.replacementAvailability?.macOS == "15.0")
	}

	private func writePlist(_ value: Any, named name: String, to directory: URL) throws {
		let data = try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: 0)
		try data.write(to: directory.appending(component: name))
	}
}

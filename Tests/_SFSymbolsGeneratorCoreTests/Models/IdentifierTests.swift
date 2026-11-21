//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Testing
@testable import _SFSymbolsGeneratorCore

@Suite struct IdentifierTests {
	@Test func `validates Swift identifier and raw identifier syntax`() {
		for value in ["symbolName", "_symbol2", "étoile", "e\u{301}", "`class`", "`symbol-name`"] {
			#expect(Identifier.isValid(value), "\(value) should be a valid identifier")
		}

		for value in ["", "2symbol", "class", "`", "``", "`   `", "`missingEnd", "missingStart`", "`bad`name`", "`line\nbreak`", "`back\\slash`"] {
			#expect(!Identifier.isValid(value), "\(value) should not be a valid identifier")
		}
	}

	@Test func `camel cases symbol names into valid Swift identifiers`() {
		let cases = [
			("circle", "circle"),
			("circle.fill", "circleFill"),
			("person.crop.circle.badge.plus", "personCropCircleBadgePlus"),
			("123.circle", "_123Circle"),
			("class", "_class"),
			(".leading", "leading"),
			("arrow-left", "arrowleft"),
			("🙂", nil),
		] as [(String, String?)]

		for (symbolName, expected) in cases {
			#expect(Identifier.camelCased(symbolName)?.value == expected, "Unexpected identifier for \(symbolName)")
		}
	}
}

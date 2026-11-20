//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

/// Validated declaration name: `identifier | raw-identifier` per:
/// [](https://docs.swift.org/latest/documentation/the-swift-programming-language/summaryofthegrammar/#Lexical-Structure)
struct Identifier {
	enum Role {
		case typeName
		case memberName
	}

	let value: String

	init?(_ value: String) {
		guard Self.isValid(value) else { return nil }
		self.value = value
	}

	/// Validates if the identifier conforms to a naming convention
	///
	/// ### Conventions
	/// - Types: UpperCamelCase
	/// - Members: lowerCamelCase.
	///
	/// - Note: Raw identifiers will always return `true`.
	func followsNamingConvention(_ role: Role) -> Bool {
		guard let first = value.unicodeScalars.first, first != "`" else { return true }
		let isUpper = Character(first).isUppercase
		return role == .typeName ? isUpper : !isUpper
	}

	static func camelCased(_ value: String) -> Identifier? {
		if value.isEmpty { return nil }
		let parts = value.lowercased().split(separator: "_")
		guard let first = parts.first, !first.isEmpty else { return nil }
		let result = String(first) + parts.dropFirst().map(\.capitalized).joined()
		return Identifier(result)
	}

	static func isValid(_ value: String) -> Bool {
		let scalars = value.unicodeScalars
		guard let first = scalars.first else {
			return false // empty is not valid
		}

		// raw-identifier: ` raw-identifier-characters `
		if first == "`" {
			guard scalars.count >= 3, scalars.last == "`" else {
				// can't be only backticks, or be missing the trailing backtick
				return false
			}
			let body = scalars.dropFirst().dropLast()

			// cannot be entirely whitespace
			if body.allSatisfy(\.properties.isWhitespace) {
				return false
			}
			return body.allSatisfy { !["`", "\\", "\u{0}", "\u{A}", "\u{D}"].contains($0) }
		}

		// identifier → identifier-head identifier-characters?
		guard inRanges(first, head),
		      scalars.dropFirst().allSatisfy({ ("0" ... "9").contains($0) || inRanges($0, combining) || inRanges($0, head) }),
		      !keywords.contains(value) else { return false }
		return true
	}

	private static func inRanges(_ c: Unicode.Scalar, _ r: [ClosedRange<UInt32>]) -> Bool {
		r.contains { $0.contains(c.value) }
	}

	private static let combining: [ClosedRange<UInt32>] = [
		0x0300 ... 0x036F,
		0x1DC0 ... 0x1DFF,
		0x20D0 ... 0x20FF,
		0xFE20 ... 0xFE2F,
	]

	private static let head: [ClosedRange<UInt32>] = {
		var ranges: [ClosedRange<UInt32>] = [
			0x41 ... 0x5A, 0x61 ... 0x7A, 0x5F ... 0x5F,
			0xA8 ... 0xA8, 0xAA ... 0xAA, 0xAD ... 0xAD, 0xAF ... 0xAF, 0xB2 ... 0xB5, 0xB7 ... 0xBA,
			0xBC ... 0xBE, 0xC0 ... 0xD6, 0xD8 ... 0xF6, 0xF8 ... 0xFF,
			0x100 ... 0x2FF, 0x370 ... 0x167F, 0x1681 ... 0x180D, 0x180F ... 0x1DBF,
			0x1E00 ... 0x1FFF,
			0x200B ... 0x200D, 0x202A ... 0x202E, 0x203F ... 0x2040, 0x2054 ... 0x2054, 0x2060 ... 0x206F,
			0x2070 ... 0x20CF, 0x2100 ... 0x218F, 0x2460 ... 0x24FF, 0x2776 ... 0x2793,
			0x2C00 ... 0x2DFF, 0x2E80 ... 0x2FFF,
			0x3004 ... 0x3007, 0x3021 ... 0x302F, 0x3031 ... 0x303F, 0x3040 ... 0xD7FF,
			0xF900 ... 0xFD3D, 0xFD40 ... 0xFDCF, 0xFDF0 ... 0xFE1F, 0xFE30 ... 0xFE44,
			0xFE47 ... 0xFFFD,
		]
		for plane in 1 ... 14 as ClosedRange<UInt32> {
			ranges.append((plane << 16) ... ((plane << 16) | 0xFFFD))
		}
		return ranges
	}()

	private static let keywords: Set<String> = [
		"associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import",
		"init", "inout", "internal", "let", "open", "operator", "private", "precedencegroup",
		"protocol", "public", "rethrows", "static", "struct", "subscript", "typealias", "var",
		"break", "case", "catch", "continue", "default", "defer", "do", "else", "fallthrough",
		"for", "guard", "if", "in", "repeat", "return", "throw", "switch", "where", "while",
		"Any", "as", "await", "false", "is", "nil", "self", "Self", "super", "throws", "true", "try",
	]
}

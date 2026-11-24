//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

/// Picks the single subject category each symbol is grouped under.
///
/// When a symbol resolves to multiple candidate categories it will pick from
/// most to least specific: the category with the fewest symbols, and then the
/// plist declared order. The goal is to ensure categories are as small as possible
/// so generated files are small, viewable in Xcode, and compile fast(-ish).
///
/// ``CategoryResolver/nonSubjectCategoryKeys`` stores some known
/// large categories which overlap with other categories. They are ignored. If
/// a symbol only existed in one of those categories then it will be added to the
/// uncategorized group.
struct CategoryResolver {
	/// Symbol categories that will be ignored as they hold large, overlapping portions of the symbols
	/// and we want to reduce generated file size.
	private static let nonSubjectCategoryKeys: Set<String> = [
		"all",
		"whatsnew",
		"multicolor",
		"variable",
		"draw"
	]
	private static let uncategorized = SFSymbolCategory(key: "uncategorized")

	let categories: [SFSymbolCategory]
	private let nameAliases: [String: String]
	private let categoryLookup: [String: SFSymbolCategory]

	init(
		resourceFolder resources: URL,
		nameAliases: [String: String],
	) throws {
		let allCategories = try readPlistFile(in: resources, "categories.plist", to: [SFSymbolCategory].self)
		let symbolCategories = try readPlistFile(in: resources, "symbol_categories.plist", to: [String: [String]].self)

		let categories = allCategories.filter { !Self.nonSubjectCategoryKeys.contains($0.key) }
		let lookup = Dictionary(uniqueKeysWithValues: categories.map { ($0.key, $0) })

		var sizes: [String: Int] = [:]
		for key in symbolCategories.values.joined() {
			sizes[key, default: 0] += 1
		}

		// Fewest symbols first, then plist order
		let rank: [String: Int] = Dictionary(
			uniqueKeysWithValues: categories.enumerated()
				.sorted { (sizes[$0.element.key] ?? 0, $0.offset) < (sizes[$1.element.key] ?? 0, $1.offset) }
				.enumerated()
				.map { ($0.element.element.key, $0.offset) }
		)

		self.categories = categories
		self.nameAliases = nameAliases
		self.categoryLookup = symbolCategories.compactMapValues { keys in
			keys.compactMap { lookup[$0] }.min { rank[$0.key, default: .max] < rank[$1.key, default: .max] }
		}
	}

	func category(for name: String) -> SFSymbolCategory {
		if let category = categoryLookup[name] {
			return category
		}
		if let alias = nameAliases[name], let category = categoryLookup[alias] {
			return category
		}
		return Self.uncategorized
	}
}

struct SFSymbolCategory: Hashable, Sendable, Decodable, CustomStringConvertible {
	let key: String

	var description: String { key }

	var fileNameDescription: String {
		guard let first = key.first else { return "" }
		return first.uppercased() + key.dropFirst()
	}
}

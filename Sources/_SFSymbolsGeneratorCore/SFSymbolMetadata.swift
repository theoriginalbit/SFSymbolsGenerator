//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct SFSymbolMetadata: Sendable {
	/// The location of the CoreGlyphs system resources.
	private static let systemResourceFolder = URL(
		filePath: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources",
		directoryHint: .isDirectory
	)

	let allSymbolsByCategory: [String: [Symbol]]

	let categories: [Category]

	init(resourceFolder resources: URL = Self.systemResourceFolder) throws {
		let nameAvailability = try readFile(in: resources, "name_availability.plist", to: NameAvailability.self)
		let symbolRestrictions = try readFile(in: resources, "symbol_restrictions.strings", to: [String: String].self)
		let nameAliases = try readFile(in: resources, "name_aliases.strings", to: [String: String].self)

		let categoryResolver = try CategoryResolver(
			resourceFolder: resources,
			nameAliases: nameAliases,
		)

		// `name_availability.plist` maps each symbol to a release year, which in turn maps to the platform versions
		let symbols = nameAvailability.symbols
			.compactMap { (name, year) -> Symbol? in
				// L10n and RTL are handled by the UI framework
				guard !Self.hasLanguageCode(name), !Self.hasRightToLeftSpecifier(name) else {
					return nil
				}
				return Symbol(
					name: name,
					availability: nameAvailability.yearToRelease[year].map(Availability.init),
					replacementName: nameAliases[name],
					restriction: symbolRestrictions[name],
				)
			}
			.sorted { $0.name < $1.name }

		allSymbolsByCategory = Dictionary(grouping: symbols, by: {
			categoryResolver.category(for: $0.name)
		})
		categories = categoryResolver.categories
	}

	/// A set of all language codes, used to determine if the last segment of a symbol is a language code.
	private static let isoLanguageCodes = Set(Locale.LanguageCode.isoLanguageCodes.map(\.identifier))

	private static func hasLanguageCode(_ value: String) -> Bool {
		if let lastSegment = value.split(separator: ".").last {
			return isoLanguageCodes.contains(String(lastSegment))
		}
		return false
	}

	private static func hasRightToLeftSpecifier(_ value: String) -> Bool {
		value.hasSuffix(".rtl")
	}
}

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
private struct CategoryResolver {
	/// Symbol categories that will be ignored as they hold large, overlapping portions of the symbols
	/// and we want to reduce generated file size.
	private static let nonSubjectCategoryKeys: Set<String> = [
		"all",
		"whatsnew",
		"multicolor",
		"variable",
		"draw"
	]

	let categories: [SFSymbolMetadata.Category]
	let symbolCategories: [String: [String]]
	let nameAliases: [String: String]
	let rank: [String: Int]

	init(
		resourceFolder resources: URL,
		nameAliases: [String: String],
	) throws {
		let allCategories = try readFile(in: resources, "categories.plist", to: [SFSymbolMetadata.Category].self)
		let symbolCategories = try readFile(in: resources, "symbol_categories.plist", to: [String: [String]].self)

		self.categories = allCategories.lazy.filter { !Self.nonSubjectCategoryKeys.contains($0.key) }
		self.symbolCategories = symbolCategories
		self.nameAliases = nameAliases

		var sizes: [String: Int] = [:]
		for key in symbolCategories.values.joined() {
			sizes[key, default: 0] += 1
		}
		let ranked = categories.enumerated()
			.sorted { (sizes[$0.element.key] ?? 0, $0.offset) < (sizes[$1.element.key] ?? 0, $1.offset) }
		self.rank = Dictionary(uniqueKeysWithValues: ranked.enumerated().map { ($0.element.element.key, $0.offset) })
	}

	func category(for name: String) -> String {
		return [name, nameAliases[name]].lazy
			.compactMap(\.self)
			.compactMap(directCategory(for:))
			.first ?? "uncategorized"
	}

	private func directCategory(for name: String) -> String? {
		guard let categories = symbolCategories[name] else {
			return nil
		}
		return categories.min(by: { rank[$0, default: .max] < rank[$1, default: .max] })
	}
}

// MARK: - Supporting types

extension SFSymbolMetadata {
	struct Symbol: Hashable, Sendable {
		let name: String
		let availability: Availability?
		let replacementName: String?
		let restriction: String?
		var isDeprecated: Bool { replacementName != nil }
	}

	struct Category: Hashable, Sendable, Decodable, CustomStringConvertible {
		let key: String

		var description: String { key }
	}

	struct Availability: Hashable, Sendable {
		let iOS: String
		let macOS: String
		let tvOS: String
		let watchOS: String
		let visionOS: String

		fileprivate init(_ release: YearMapping) {
			self.iOS = release.iOS
			self.macOS = release.macOS
			self.tvOS = release.tvOS
			self.watchOS = release.watchOS
			self.visionOS = release.visionOS
		}
	}
}

private extension SFSymbolMetadata {
	/// The contents of `name_availability.plist`.
	struct NameAvailability: Decodable {
		enum CodingKeys: String, CodingKey {
			case symbols
			case yearToRelease = "year_to_release"
		}

		/// Maps a symbol name to the year it was released.
		let symbols: [String: String]
		/// Maps a release year to the platform versions of that year.
		let yearToRelease: [String: YearMapping]
	}

	/// The platform versions released in a given year as specified by the CoreGlyphs system resource.
	struct YearMapping: Decodable {
		let macOS: String
		let tvOS: String
		let watchOS: String
		let iOS: String
		let visionOS: String
	}
}

private func readFile<T>(in resources: URL, _ filename: String, to type: T.Type) throws -> T where T: Decodable {
	let decoder = PropertyListDecoder()
	let data = try Data(contentsOf: resources.appending(component: filename, directoryHint: .notDirectory))
	var format: PropertyListSerialization.PropertyListFormat = .openStep
	return try decoder.decode(T.self, from: data, format: &format)
}

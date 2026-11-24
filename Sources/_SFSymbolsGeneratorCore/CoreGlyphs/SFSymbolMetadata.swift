//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct SFSymbolMetadata: Sendable {
	private let allSymbolsByCategory: [SFSymbolCategory: [SFSymbol]]

	let categories: [SFSymbolCategory]

	init(resourceFolder resources: URL = CoreGlyphs.systemResourceFolder) throws {
		let nameAvailability = try readPlistFile(in: resources, "name_availability.plist", to: NameAvailability.self)
		let symbolRestrictions = try readPlistFile(in: resources, "symbol_restrictions.strings", to: [String: String].self)
		let nameAliases = try readPlistFile(in: resources, "name_aliases.strings", to: [String: String].self)

		let categoryResolver = try CategoryResolver(
			resourceFolder: resources,
			nameAliases: nameAliases,
		)

		// `name_availability.plist` maps each symbol to a release year, which in turn maps to the platform versions
		let symbols = nameAvailability.symbols
			.compactMap { (name, year) -> SFSymbol? in
				// L10n and RTL are handled by the UI framework
				guard !Self.hasLanguageCode(name), !Self.hasRightToLeftSpecifier(name) else {
					return nil
				}
				return SFSymbol(
					name: name,
					availability: nameAvailability.yearToRelease[year].map(SFSymbol.Availability.init),
					replacementName: nameAliases[name],
					replacementAvailability: nameAliases[name]
						.flatMap { nameAvailability.symbols[$0] }
						.flatMap { nameAvailability.yearToRelease[$0] }
						.map(SFSymbol.Availability.init),
					restriction: symbolRestrictions[name],
				)
			}
			.sorted { $0.name < $1.name }

		allSymbolsByCategory = Dictionary(grouping: symbols, by: {
			categoryResolver.category(for: $0.name)
		})
		categories = categoryResolver.categories
	}

	func symbols(in category: SFSymbolCategory) -> [SFSymbol] {
		allSymbolsByCategory[category, default: []]
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

// MARK: - Supporting types

struct SFSymbol: Hashable, Sendable {
	let name: String
	let availability: Availability?
	let replacementName: String?
	let replacementAvailability: Availability?
	let restriction: String?
	var isDeprecated: Bool { replacementName != nil }

	struct Availability: Hashable, Sendable {
		let iOS: String
		let macOS: String
		let tvOS: String
		let watchOS: String
		let visionOS: String

		init(iOS: String, macOS: String, tvOS: String, watchOS: String, visionOS: String) {
			self.iOS = iOS
			self.macOS = macOS
			self.tvOS = tvOS
			self.watchOS = watchOS
			self.visionOS = visionOS
		}

		fileprivate init(_ release: SFSymbolMetadata.YearMapping) {
			self.init(
				iOS: release.iOS,
				macOS: release.macOS,
				tvOS: release.tvOS,
				watchOS: release.watchOS,
				visionOS: release.visionOS,
			)
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

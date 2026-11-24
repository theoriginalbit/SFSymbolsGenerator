//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

struct GeneratorConfiguration: Decodable {
	let symbolExtensions: Bool?
	let accessModifier: String?
	let uiFrameworks: [String]
	let rawIdentifiers: Bool?

	private enum CodingKeys: String, CodingKey {
		case symbolExtensions
		case accessModifier
		case uiFrameworks
		case rawIdentifiers
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		symbolExtensions = try values.decodeIfPresent(Bool.self, forKey: .symbolExtensions)
		rawIdentifiers = try values.decodeIfPresent(Bool.self, forKey: .rawIdentifiers)

		if let modifier = try values.decodeIfPresent(String.self, forKey: .accessModifier) {
			guard ["public", "package", "internal"].contains(modifier.lowercased()) else {
				throw PluginError("Invalid accessModifier '\(modifier)'; expected public, package, or internal.")
			}
			accessModifier = modifier.lowercased()
		} else {
			accessModifier = nil
		}

		let uiFrameworks = try values.decodeIfPresent([String].self, forKey: .uiFrameworks) ?? []
		for framework in uiFrameworks {
			guard ["appkit", "swiftui", "uikit"].contains(framework.lowercased()) else {
				throw PluginError("Invalid uiFrameworks entry '\(framework)'; expected AppKit, SwiftUI, or UIKit.")
			}
		}
		self.uiFrameworks = uiFrameworks
	}

	static func load(from url: URL?) throws -> Self {
		guard let url, FileManager.default.fileExists(atPath: url.path()) else {
			return try JSONDecoder().decode(Self.self, from: Data("{}".utf8))
		}
		return try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
	}
}

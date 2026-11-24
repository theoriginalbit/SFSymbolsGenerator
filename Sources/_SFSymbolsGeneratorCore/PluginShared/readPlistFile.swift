//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

func readPlistFile<T>(in resources: URL, _ filename: String, to type: T.Type) throws -> T where T: Decodable {
	let decoder = PropertyListDecoder()
	let data = try Data(contentsOf: resources.appending(component: filename, directoryHint: .notDirectory))
	var format: PropertyListSerialization.PropertyListFormat = .openStep
	return try decoder.decode(T.self, from: data, format: &format)
}

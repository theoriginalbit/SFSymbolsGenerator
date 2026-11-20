//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

@propertyWrapper
package struct SourceLocatable<Value>: CustomStringConvertible {
	package let wrappedValue: Value

	private let sourceLocation: SourceLocation?

	package var projectedValue: SourceLocation? {
		sourceLocation
	}

	package var description: String {
		if let sourceLocation {
			"\(wrappedValue) [\(sourceLocation)]"
		} else {
			String(describing: wrappedValue)
		}
	}

	package init(wrappedValue value: Value) {
		wrappedValue = value
		sourceLocation = nil
	}

	package init(wrappedValue value: Value, location: SourceLocation?) {
		wrappedValue = value
		sourceLocation = location
	}
}

extension SourceLocatable: Decodable where Value: Decodable {
	package init(from decoder: any Decoder) throws {
		let value = try decoder.singleValueContainer().decode(Value.self)
		var location: SourceLocation?
		if let file = decoder.userInfo[.sourceFile] as? URL {
			// TODO: figure out how to determine line and column from JSON
			location = SourceLocation(file: file, line: nil, column: nil)
		}
		self.init(wrappedValue: value, location: location)
	}
}

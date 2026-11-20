//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

package struct GeneratorError: Error, Equatable, CustomStringConvertible {
	package let description: String
	package let alreadyLogged: Bool

	private init(message description: String, alreadyLogged: Bool = false) {
		self.description = description
		self.alreadyLogged = alreadyLogged
	}
}

package extension GeneratorError {
	@inlinable
	static var specifyOutputDirectory: Self {
		GeneratorError(message: "internal error: running as build tool but output file path is missing.", alreadyLogged: true)
	}

	static let generationFailed = GeneratorError(message: "Code generation failed due to previous errors.", alreadyLogged: true)
}

extension DecodingError {
	var failingPath: [CodingKey] {
		switch self {
		case let .keyNotFound(key, context):
			context.codingPath + CollectionOfOne(key)
		case let .dataCorrupted(context),
		     let .typeMismatch(_, context),
		     let .valueNotFound(_, context):
			context.codingPath
		@unknown default:
			[]
		}
	}

	var friendlyDescription: String {
		func path(_ context: Context) -> String {
			return context.codingPath.reduce("root") { result, nextKey in
				if let intValue = nextKey.intValue {
					return "\(result)[\(intValue)]"
				}
				return "\(result).\(nextKey.stringValue)"
			}
		}

		switch self {
		case let .keyNotFound(key, context):
			let parent = path(context)
			return "Missing required key '\(key.stringValue)' at \(parent)"

		case let .valueNotFound(type, context):
			return "Expected \(type) but found null at \(path(context))"

		case let .typeMismatch(type, context):
			return "Type mismatch at \(path(context)): expected \(type)"

		case let .dataCorrupted(context):
			return "Invalid data at \(path(context)): \(context.debugDescription)"

		@unknown default:
			return String(describing: self)
		}
	}
}

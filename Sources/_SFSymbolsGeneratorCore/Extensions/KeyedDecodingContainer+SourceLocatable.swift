//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

extension KeyedDecodingContainer {
	/// Optional properties get synthesized with `decode` not `decodeIfPresent`
	/// because of `SourceLocatable`. This overload fixes that.
	func decode<T: Decodable & ExpressibleByNilLiteral>(
		_: SourceLocatable<T>.Type, forKey key: Key,
	) throws -> SourceLocatable<T> {
		try decodeIfPresent(SourceLocatable<T>.self, forKey: key) ?? SourceLocatable(wrappedValue: nil)
	}
}

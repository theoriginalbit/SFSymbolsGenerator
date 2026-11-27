//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

package struct DiagnosticMessage: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {
	fileprivate enum Component {
		case text(String)
		case fileURL(URL)
	}

	private var components: [Component]

	package init(stringLiteral value: String) {
		self.components = [.text(value)]
	}

	package init(stringInterpolation: Interpolation) {
		self.components = stringInterpolation.components
	}

	package init(_ value: String) {
		self.init(stringLiteral: value)
	}

	package func render(for mode: DiagnosticMode) -> String {
		var result = ""
		for component in components {
			switch component {
			case let .text(value):
				result.append(value)
			case let .fileURL(url):
				result.append(mode.path(for: url))
			}
		}
		return result
	}

	package struct Interpolation: StringInterpolationProtocol {
		fileprivate var components: [Component] = []

		package init(literalCapacity: Int, interpolationCount: Int) {
			components.reserveCapacity(literalCapacity + interpolationCount)
		}

		package mutating func appendLiteral(_ literal: String) {
			components.append(.text(literal))
		}

		package mutating func appendInterpolation(_ value: String) {
			components.append(.text(value))
		}

		package mutating func appendInterpolation(_ url: URL) {
			components.append(url.isFileURL ? .fileURL(url) : .text(url.absoluteString))
		}

		package mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T) {
			components.append(.text(String(describing: value)))
		}

		package mutating func appendInterpolation<T: RawRepresentable>(_ value: T) where T.RawValue: CustomStringConvertible {
			components.append(.text(String(describing: value.rawValue)))
		}

		package mutating func appendInterpolation<Element: CustomStringConvertible>(_ values: some Collection<Element>) {
			appendInterpolation(values, separator: ", ")
		}

		package mutating func appendInterpolation<Element: CustomStringConvertible>(_ values: some Collection<Element>, separator: String) {
			components.append(.text(values.map(\.description).joined(separator: separator)))
		}
	}
}

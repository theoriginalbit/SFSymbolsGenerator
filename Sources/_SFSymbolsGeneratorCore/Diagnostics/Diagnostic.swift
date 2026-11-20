//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

package struct Diagnostic: Error {
	/// ordered most → least severe for automatic comparable synthesis
	package enum Severity: Comparable {
		case fault
		case error
		case warning
		case note
		case info

		/// Minimum severity shown for a given `-v` count.
		package init(verbosity: Int) {
			switch verbosity {
			case ...0: self = .warning	// default: warnings + errors + faults
			case 1:    self = .note		// -v
			default:   self = .info		// -vv and up
			}
		}
	}

	package let severity: Severity
	package let message: String
	package var location: SourceLocation?
}

package extension Diagnostic {
	static func note(_ message: String, location: SourceLocation? = nil) -> Self {
		Self(severity: .note, message: message, location: location)
	}

	static func info(_ message: String, location: SourceLocation? = nil) -> Self {
		Self(severity: .info, message: message, location: location)
	}

	static func warning(_ message: String, location: SourceLocation? = nil) -> Self {
		Self(severity: .warning, message: message, location: location)
	}

	static func error(_ message: String, location: SourceLocation? = nil) -> Self {
		Self(severity: .error, message: message, location: location)
	}

	/// - Important: Emitting a fault will output the diagnostic and immediately exit the process
	static func fault(_ message: String, location: SourceLocation? = nil) -> Self {
		Self(severity: .fault, message: message, location: location)
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Synchronization

package enum DiagnosticSeverity {
	case error
	case warning
	case note
}

package struct DiagnosticCollector<Output: DiagnosticOutput> {
	final class MutableState: Sendable {
		let hasErrors = Atomic<Bool>(false)
	}

	package let mode: DiagnosticMode
	package let verbose: Bool

	private let state = MutableState()
	package private(set) var hasErrors: Bool {
		get { state.hasErrors.load(ordering: .relaxed) }
		nonmutating set { state.hasErrors.store(newValue, ordering: .relaxed) }
	}

	private let output: Output

	init(mode: DiagnosticMode, verbose: Bool, output: Output) {
		self.mode = mode
		self.verbose = verbose
		self.output = output
	}

	package init(mode: DiagnosticMode, verbose: Bool) where Output == FileHandleOutput {
		self.mode = mode
		self.verbose = verbose
		self.output = FileHandleOutput(.standardError)
	}

	func render(_ severity: DiagnosticSeverity, _ message: DiagnosticMessage, _ location: SourceLocation?) -> String {
		var prefix = ""
		if let location {
			prefix = "\(mode.path(for: location.file)):"
			if let line = location.line {
				prefix += "\(line):"
				if let column = location.column {
					prefix += "\(column):"
				}
			}
			prefix += " "
		}
		return "\(prefix)\(mode.severity(severity)) \(message.render(for: mode))"
	}

	package func emit(_ severity: DiagnosticSeverity, _ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		if severity == .note, !verbose {
			return
		}
		output.writeLine(render(severity, message, location))
	}

	package func note(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		emit(.note, message, at: location)
	}

	package func warning(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		emit(.warning, message, at: location)
	}

	package func error(_ message: DiagnosticMessage, at location: SourceLocation? = nil) {
		emit(.error, message, at: location)
		hasErrors = true
	}

	package func fault(_ message: DiagnosticMessage, at location: SourceLocation? = nil, exitCode: Int32 = EXIT_FAILURE) -> Never {
		emit(.error, message, at: location)
		hasErrors = true
		exit(exitCode)
	}
}

package protocol DiagnosticOutput {
	func writeLine(_ line: String)
}

package struct FileHandleOutput: DiagnosticOutput {
	private let handle: FileHandle

	package init(_ handle: FileHandle) {
		self.handle = handle
	}

	public func writeLine(_ line: String) {
		handle.write(Data((line + "\n").utf8))
	}
}

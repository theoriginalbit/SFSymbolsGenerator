//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.Data
import func Foundation.exit
import let Foundation.EXIT_FAILURE
import class Foundation.FileHandle
import struct Synchronization.Atomic

package struct StandardDiagnosticCollector<StdOut: DiagnosticOutputHandle, StdErr: DiagnosticOutputHandle>: DiagnosticCollector {
	final class MutableState: Sendable {
		let hasErrors = Atomic<Bool>(false)
	}

	let stdOut: StdOut
	let stdErr: StdErr
	package let mode: DiagnosticMode
	package let verbosity: Diagnostic.Severity

	private let state = MutableState()
	package private(set) var hasErrors: Bool {
		get { state.hasErrors.load(ordering: .relaxed) }
		nonmutating set { state.hasErrors.store(newValue, ordering: .relaxed) }
	}

	package init(
		stdOut: StdOut = FileHandle.standardOutput,
		stdErr: StdErr = FileHandle.standardError,
		mode: DiagnosticMode,
		verbosity: Int,
	) {
		self.stdOut = stdOut
		self.stdErr = stdErr
		self.mode = mode
		self.verbosity = Diagnostic.Severity(verbosity: verbosity)
	}

	package func emit(_ diagnostic: Diagnostic) {
		guard canEmit(diagnostic) else { return }
		let message = describe(diagnostic) + "\n"

		switch diagnostic.severity {
		case .note, .info, .warning:
			stdOut.write(Data(message.utf8))
		case .error:
			hasErrors = true
			stdErr.write(Data(message.utf8))
		case .fault:
			// no need to set hasErrors since we immediately exit
			stdErr.write(Data(message.utf8))
			exit(EXIT_FAILURE)
		}
	}
}

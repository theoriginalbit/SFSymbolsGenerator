//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation

enum TempDir {
	static func create() throws -> URL {
		let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
		try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
		return tempDir
	}
}

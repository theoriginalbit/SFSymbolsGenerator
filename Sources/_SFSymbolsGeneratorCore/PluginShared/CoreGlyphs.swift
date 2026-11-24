//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

enum CoreGlyphs {
	/// The location of the CoreGlyphs system resources.
	static let systemResourceFolder = URL(
		filePath: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources",
		directoryHint: .isDirectory
	)
}

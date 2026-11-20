//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import struct Foundation.URL

/// A source position within a file. Indexes start at `1`.
///
/// Used to attach YAML source positions to setting entries so that
/// diagnostics can point at the exact line in a file.
package struct SourceLocation {
	/// The file the location represents.
	package let file: URL

	/// The line within the file. Indexes start at `1`.
	package let line: Int?

	/// The column within the file. Indexes start at `1`.
	package let column: Int?
}

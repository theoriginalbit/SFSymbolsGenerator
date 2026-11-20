//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import Testing
@testable import sfgenerate

@Test func `URL ExpressibleByArgument conformance`() {
	let url = URL(argument: "/path/to/my/project")
	#expect(url != nil)
	#expect(url?.isFileURL == true)
	#expect(url?.path == "/path/to/my/project")
}

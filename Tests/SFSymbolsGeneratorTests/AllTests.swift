//
//  AllTests.swift
//
//
//  Created by Joshua Asbury on 21/2/2024.
//

import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}

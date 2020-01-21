//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import XCTest
@testable import youda

final class youdaTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual(youda().text, "Hello, World!")
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}

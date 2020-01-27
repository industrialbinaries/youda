//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit
import XCTest
@testable import youda

final class IAPServiceConfigurationTests: XCTestCase {
  func testMockConfiguration() {
    let iapService = IAPService.configureService(
      products: [],
      deviceID: nil,
      environment: .mock(available: [], purchased: [])
    )

    XCTAssert(iapService is IAPServiceMock)
  }

  func testConfiguration() {
    let iapService = IAPService.configureService(
      products: [],
      deviceID: nil,
      environment: .default
    )

    #if targetEnvironment(simulator)
      XCTAssert(iapService is IAPServiceMock)
    #else
      XCTAssert(iapService is IAPService)
    #endif
  }
}

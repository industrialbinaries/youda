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
  func testInitStubConfiguration() {
    let iapService = IAPService.configureService(
      products: [],
      deviceID: nil,
      environment: .stub(available: [], purchased: [])
    )

    XCTAssert(iapService is IAPServiceStub)
  }

  func testInitDefauleConfiguration() {
    let iapService = IAPService.configureService(
      products: [],
      deviceID: nil,
      environment: .default
    )

    #if targetEnvironment(simulator)
      XCTAssert(iapService is IAPServiceStub)
    #else
      XCTAssert(iapService is IAPService)
    #endif
  }
}

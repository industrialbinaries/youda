//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit
import XCTest
@testable import youda

final class IAPServiceMockTest: XCTestCase {
  func testAvailableProducts() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    XCTAssertEqual(apiService.availableProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
    XCTAssertEqual(apiService.availableProducts.count, 1)
  }

  func testPurchasedProducts() {
    let apiService = IAPServiceMock(
      availableProducts: [],
      purchasedProducts: .mockPurchasedProducts
    )

    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedProductIdentifier)
  }

  func testBuyProductNotification() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    let expectation = XCTestExpectation(description: "Buy products timeout")
    NotificationCenter.default.addObserver(
      forName: .subscriptionChange,
      object: nil,
      queue: nil
    ) { _ in
      expectation.fulfill()
    }

    apiService.buy(product: .purchasedAvailableIdentifier, delay: 0)

    wait(for: [expectation], timeout: 5)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }

  func testRestoreProductsNotification() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    let expectation = XCTestExpectation(description: "Restore products timeout")
    NotificationCenter.default.addObserver(
      forName: .subscriptionChange,
      object: nil,
      queue: nil
    ) { _ in
      expectation.fulfill()
    }

    apiService.restoreProducts(delay: 0)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }

  func testBuyProductDelegate() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    let expectation = XCTestExpectation(description: "Buy products timeout")
    let delegate = IAPServiceMockDelecgateTest(didUpdate: expectation.fulfill)
    apiService.delegate = delegate
    apiService.buy(product: .purchasedAvailableIdentifier, delay: 0)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }

  func testRestoreProductsDelegate() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    let expectation = XCTestExpectation(description: "Restore products timeout")
    let delegate = IAPServiceMockDelecgateTest(didUpdate: expectation.fulfill)
    apiService.delegate = delegate
    apiService.restoreProducts(delay: 0)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }
}

private class IAPServiceMockDelecgateTest: IAPServiceDelegate {
  private let didUpdate: () -> Void

  init(didUpdate: @escaping () -> Void) {
    self.didUpdate = didUpdate
  }

  func didUpdate(_ iapService: IAPServiceProtocol, purchasedProducts: [SKProduct]) {
    didUpdate()
  }
}

private extension Sequence where Iterator.Element == SKProduct {
  static var mockAvailableProducts: [SKProduct] {
    return [
      SKProduct(productIdentifier: .purchasedAvailableIdentifier),
    ]
  }

  static var mockPurchasedProducts: [SKProduct] {
    return [
      SKProduct(productIdentifier: .purchasedProductIdentifier),
    ]
  }
}

private extension String {
  static let purchasedAvailableIdentifier = "co.industrial-binaries.available"
  static let purchasedProductIdentifier = "co.industrial-binaries.purchased"
}

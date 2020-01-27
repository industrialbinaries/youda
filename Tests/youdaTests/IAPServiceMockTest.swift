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

    apiService.buy(product: .purchasedAvailableIdentifier)

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

    apiService.restoreProducts()

    wait(for: [expectation], timeout: 5)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }

  private var expectation: XCTestExpectation!

  func testBuyProductDelegate() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    expectation = XCTestExpectation(description: "Buy products timeout")
    apiService.delegate = self
    apiService.buy(product: .purchasedAvailableIdentifier)

    wait(for: [expectation], timeout: 5)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }

  func testRestoreProductsDelegate() {
    let apiService = IAPServiceMock(
      availableProducts: .mockAvailableProducts,
      purchasedProducts: []
    )

    expectation = XCTestExpectation(description: "Restore products timeout")
    apiService.delegate = self
    apiService.restoreProducts()

    wait(for: [expectation], timeout: 5)
    XCTAssertEqual(apiService.purchasedProducts.first?.productIdentifier, .purchasedAvailableIdentifier)
  }
}

extension IAPServiceMockTest: IAPServiceDelegate {
  func didUpdate(_ iapService: IAPServiceProtocol, purchasedProducts: [SKProduct]) {
    expectation.fulfill()
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

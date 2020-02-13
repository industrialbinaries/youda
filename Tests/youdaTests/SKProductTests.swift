//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit
import XCTest
@testable import youda

final class SKProductTests: XCTestCase {
  func testCreateStubProduct() {
    let product: SKProduct = .stub
    XCTAssertEqual(product.productIdentifier, .productIdentifier)
    XCTAssertEqual(product.price.stringValue, .price)
  }

  func testLocalPriceProduct() {
    let product: SKProduct = .stub
    XCTAssertEqual(product.localPrice(), "$0.99")

    product.setValue(Locale.sk, forKey: "priceLocale") // Update local price to €
    XCTAssertEqual(product.localPrice(), "0,99 €")
  }
}

private extension SKProduct {
  static var stub: SKProduct {
    SKProduct(
      productIdentifier: .productIdentifier,
      price: .price,
      priceLocale: .us
    )
  }
}

private extension String {
  static let productIdentifier = "co.industrial-binaries.test"
  static let price = "0.99"
}

private extension Locale {
  static var us = Locale(identifier: "en_US")
  static var sk = Locale(identifier: "sk_SK")
}

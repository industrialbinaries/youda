//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

public protocol InAppPurchasesProtocol {
  /// Available products from apple developer
  var availableProducts: [SKProduct] { get }
  /// Purchased products
  var purchasedProducts: Set<InAppProductId> { get }

  /// Initialize new InAppPurchases service
  /// - Parameter products: products for request from apple developer acount
  /// - Parameter deviceID: Device ID for validate receipt hash
  init(products: Set<InAppProductId>, deviceID: UUID?)

  /// Try buy new `product`
  /// - Parameter product: new requested product
  func buy(product: SKProduct)
  /// Restore bought products, f.e. when you log in on new device or uninstall app
  func restoreProducts()
}

//
//  lola
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

  /// Try buy new `product`
  /// - Parameter product: new requested product
  func buy(product: SKProduct)
  /// Restore bought products, f.e. when you log in on new device or uninstall app
  func restoreProducts()
}

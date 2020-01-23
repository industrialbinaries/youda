//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

public struct IAPProduct {
  /// The string that identifies the product to the Apple App Store.
  let productIdentifier: String
  /// The name of the product.
  let title: String
  /// A description of the product.
  let description: String
  /// The cost of the product formatted in the local currency.
  let localPrice: String?
  /// The period off the subscription formatted in the local calendar/language.
  let localSubscriptionPeriod: String?
  /// Information about a product previously registered in App Store Connect. Can be nil in case you use `test` environment
  let product: SKProduct?

  /// Create `IAPProduct` from `SKProduct`
  /// - Parameter product: Product for initialize `IAPProduct`
  init(with product: SKProduct) {
    self.product = product
    localPrice = product.localPrice
    localSubscriptionPeriod = product.subscriptionPeriod?.localPeriod
    description = product.localizedDescription
    title = product.localizedTitle
    productIdentifier = product.productIdentifier
  }

  /// Create `IAPProduct` for test app
  /// - Parameters:
  ///   - productIdentifier: The string that identifies the product to the Apple App Store.
  ///   - title: The name of the product
  ///   - description: A description of the product.
  ///   - localPrice: The cost of the product formatted in the local currency.
  ///   - localSubscriptionPeriod: The period off the subscription formatted in the local calendar/language.
  init(
    productIdentifier: String,
    title: String,
    description: String,
    localPrice: String?,
    localSubscriptionPeriod: String?
  ) {
    self.productIdentifier = productIdentifier
    self.title = title
    self.description = description
    self.localPrice = localPrice
    self.localSubscriptionPeriod = localSubscriptionPeriod
    product = nil
  }
}

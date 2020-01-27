//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

public final class IAPServiceMock: IAPServiceProtocol {
  // MARK: - Public properties

  /// Available products from iTunesConnect, it is all products which you can buy from your app
  public private(set) var availableProducts = [SKProduct]()
  /// Purchased products
  public private(set) var purchasedProducts = [SKProduct]()
  /// IAP delegate for inform about purchase updates
  public weak var delegate: IAPServiceDelegate?

  /// Initialize Mock IAP Service
  /// - Parameters:
  ///   - availableProducts: Array of mock products which will be return when you try bought product
  ///   - purchasedProducts: Array of purchased products
  public init(
    availableProducts: [SKProduct] = [],
    purchasedProducts: [SKProduct] = []
  ) {
    self.availableProducts = availableProducts
    self.purchasedProducts = purchasedProducts
  }

  /// Try buy new `product`, In test product will be bought and add to `availableProducts` after 2 seconds for simulate API delay
  /// - Parameter product: Product identifier for purchase
  public func buy(product productIdentifier: String) {
    guard !purchasedProducts.contains(where: { $0.productIdentifier == productIdentifier }) else {
      return // Maybe throw error when product was bought?
    }

    if let product = availableProducts
      .first(where: { $0.productIdentifier == productIdentifier }) { // Is there prepared mock
      purchasedProducts.append(product)
    } else {
      let product = SKProduct(productIdentifier: productIdentifier)
      purchasedProducts.append(product)
    }

    // Delay 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      // Send notification to inform about change purchased products
      NotificationCenter.default.post(name: .subscriptionChange, object: nil)
      // Call delegate with new purchased products
      self.delegate?.didUpdate(self, purchasedProducts: self.purchasedProducts)
    }
  }

  /// Restore bought products, f.e. when you log in on new device or uninstall app
  public func restoreProducts() {
    purchasedProducts = availableProducts

    // Delay 2 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      // Send notification to inform about change purchased products
      NotificationCenter.default.post(name: .subscriptionChange, object: nil)
      // Call delegate with new purchased products
      self.delegate?.didUpdate(self, purchasedProducts: self.purchasedProducts)
    }
  }
}

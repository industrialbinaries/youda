//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

public protocol IAPServiceProtocol {
  /// Available products from iTunesConnect, it is all products which you can buy from your app
  var availableProducts: [SKProduct] { get }
  /// Purchased products
  var purchasedProducts: [SKProduct] { get }
  /// IAP delegate for inform about purchase updates
  var delegate: IAPServiceDelegate? { get set }

  /// Try buy new `product`
  /// - Parameter product: Product identifier for purchase
  func buy(product productIdentifier: String)
  /// Restore bought products, f.e. when you log in on new device or uninstall app
  func restoreProducts()
}

/// IAP youda environment
enum IAPEnvironment {
  /// Default environment mean sandbox when you launch app from Xcode on your iPhone or production in case when you download app from AppStore, when you try app simulator, it will use `stub` environemnts
  case `default`
  /// Stub environment for debug app in simulator
  /// - Parameters:
  ///   - availableProducts: Array of stub products which will be return when you try bought product, in case it is nil will return default "Test product"
  ///   - purchasedProducts: Array of purchased products
  case stub(available: [SKProduct], purchased: [SKProduct])
}

extension IAPService {
  /// Initialize new instance of `IAPServiceProtocol` base on current environments
  /// - Parameters:
  ///   - products: Products for request from apple developer acount
  ///   - deviceID: Device ID for validate receipt hash
  ///   - environment: Environment of instance
  static func configureService(products: Set<String>, deviceID: UUID?, environment: IAPEnvironment = .default) -> IAPServiceProtocol {
    switch environment {
    case .default:
      #if targetEnvironment(simulator)
        return IAPServiceStub()
      #else
        return IAPService(products: products, deviceID: deviceID)
      #endif
    case let .stub(available: available, purchased: purchased):
      return IAPServiceStub(availableProducts: available, purchasedProducts: purchased)
    }
  }
}

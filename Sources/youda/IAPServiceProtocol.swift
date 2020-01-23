//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

public protocol IAPServiceProtocol {
  /// Available products from iTunesConnect, it is all products which you can buy from your app
  var availableProducts: [IAPProduct] { get }
  /// Purchased products
  var purchasedProducts: [IAPProduct] { get }
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
  /// Default environment mean sandbox when you launch app from Xcode on your iPhone or production in case when you download app from AppStore, when you try app simulator, it will use `mock` environemnts
  case `default`
  /// Mock environment for debug app in simulator
  case mock
}

extension IAPServiceProtocol {
  /// Initialize new instance of `IAPServiceProtocol` base on current environments
  /// - Parameters:
  ///   - products: Products for request from apple developer acount
  ///   - deviceID: Device ID for validate receipt hash
  ///   - environment: Environment of instance
  static func configureService(products: Set<String>, deviceID: UUID?, environment: IAPEnvironment = .default) -> IAPServiceProtocol {
    #if targetEnvironment(simulator)
      return IAPServiceMock()
    #else
      switch environment {
      case .default:
        return IAPService(products: products, deviceID: deviceID)
      case .mock:
        return IAPServiceMock()
      }
    #endif
  }
}

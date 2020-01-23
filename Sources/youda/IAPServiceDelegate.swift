//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

/// IAP Service delegate for IAP updates
public protocol IAPServiceDelegate: class {
  /// Call when `IAPService` update `purchasedProducts`, this function call as many times as add new product
  /// - Parameter purchasedProducts: Set of current `purchasedProducts`
  func didUpdate(purchasedProducts: [IAPProduct])
}

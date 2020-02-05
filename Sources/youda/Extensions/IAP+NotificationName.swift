//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

extension Notification.Name {
  /// The notification triggered when bought products are updated.
  public static var subscriptionChange: Notification.Name {
    Notification.Name(rawValue: "co.industrial-binaries.youda.subscription-change")
  }
}

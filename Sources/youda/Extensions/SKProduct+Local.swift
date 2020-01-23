//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

extension SKProduct {
  /// The cost of the product formatted in the local currency.
  var localPrice: String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = priceLocale
    return formatter.string(from: price)
  }
}

extension SKProductSubscriptionPeriod {
  /// - returns: The period off the subscription formatted in the local calendar/language.
  var localPeriod: String? {
    var components = DateComponents()
    components.calendar = Calendar.current
    switch unit {
    case .day: components.setValue(numberOfUnits, for: .day)
    case .week: components.setValue(numberOfUnits, for: .weekOfMonth)
    case .month: components.setValue(numberOfUnits, for: .month)
    case .year: components.setValue(numberOfUnits, for: .year)
    default: return nil
    }

    let formatter = DateComponentsFormatter()
    formatter.maximumUnitCount = 1
    formatter.unitsStyle = .full
    formatter.zeroFormattingBehavior = .dropAll
    return formatter.string(from: components)
  }
}

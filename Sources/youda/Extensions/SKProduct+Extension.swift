//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit

extension SKProduct {
    
    /// Create new `SKProduct` for mock or tests
    /// - Parameters:
    ///   - productIdentifier: Your product identifier for example `co.industrial-binaries.test-pro-version`
    ///   - price: Price of product, default value is `0.99`
    ///   - priceLocale: Price local, default value is `en_US`
    public convenience init(
        productIdentifier: String,
        price: String = "0.99",
        priceLocale: Locale = Locale(identifier: "en_US")
    ) {
        self.init()
        self.setValue(productIdentifier, forKey: "productIdentifier")
        self.setValue(NSDecimalNumber(string: price), forKey: "price")
        self.setValue(priceLocale, forKey: "priceLocale")
    }
    
    /// The cost of the product formatted in the local currency.
    /// - Parameter formatter: Formatter for format price, default value is currency formatter
    public func localPrice(formatter priceFormatter: NumberFormatter? = nil) -> String? {
        let formatter = priceFormatter ?? .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}

extension SKProductSubscriptionPeriod {
    /// The period of the subscription formatted in the local calendar/language.
    /// - Parameter formatter: Date formatter
    public func localPeriod(formatter: DateComponentsFormatter? = nil) -> String? {
        var components = DateComponents()
        components.calendar = Calendar.current
        switch unit {
        case .day: components.setValue(numberOfUnits, for: .day)
        case .week: components.setValue(numberOfUnits, for: .weekOfMonth)
        case .month: components.setValue(numberOfUnits, for: .month)
        case .year: components.setValue(numberOfUnits, for: .year)
        default: return nil
        }
        
        return (formatter ?? .default).string(from: components)
    }
}

private extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}

private extension DateComponentsFormatter {
    static var `default`: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }
}

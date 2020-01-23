//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

struct Purchase {
  /// The number of items purchased.
  /// This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
  var quantity: Int?
  /// The product identifier of the item that was purchased.
  /// This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
  var productIdentifier: String?
  /// The transaction identifier of the item that was purchased.
  /// This value corresponds to the transaction’s transactionIdentifier property. For a transaction that restores a previous transaction, this value is different from the transaction identifier of the original purchase transaction.
  /// In an auto-renewable subscription receipt, a new value for the transaction identifier is generated every time the subscription automatically renews or is restored on a new device.
  var transactionIdentifier: String?
  /// For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier.
  /// This value corresponds to the original transaction’s transactionIdentifier property. This value is the same for all receipts that have been generated for a specific subscription.
  /// This value is useful for relating together multiple iOS 6 style transaction receipts for the same individual customer’s subscription.
  var originalTransactionIdentifier: String?
  /// The date and time that the item was purchased.
  /// This value corresponds to the transaction’s transactionDate property. For a transaction that restores a previous transaction, the purchase date is the same as the original purchase date.
  /// Use Original Purchase Date to get the date of the original transaction. In an auto-renewable subscription receipt, the purchase date is the date when the subscription was either purchased or renewed (with or without a lapse).
  /// For an automatic renewal that occurs on the expiration date of the current period, the purchase date is the start date of the next period, which is identical to the end date of the current period.
  var purchaseDate: Date?
  /// For a transaction that restores a previous transaction, the date of the original transaction.
  /// This value corresponds to the original transaction’s transactionDate property.
  ///  In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
  var originalPurchaseDate: Date?
  /// The expiration date for the subscription, expressed as the number of milliseconds since January 1, 1970, 00:00:00 GMT.
  /// This key is only present for auto-renewable subscription receipts. Use this value to identify the date when the subscription will renew or expire, to determine if a customer should have access to content or service.
  /// After validating the latest receipt, if the subscription expiration date for the latest renewal transaction is a past date, it is safe to assume that the subscription has expired.
  var subscriptionExpirationDate: Date?
  /// For an auto-renewable subscription, whether or not it is in the introductory price period.
  /// This key is only present for auto-renewable subscription receipts.
  /// The value for this key is "true" if the customer’s subscription is currently in an introductory price period, or "false" if not.
  /// Note: If a previous subscription period in the receipt has the value “true” for either the is_trial_period or the is_in_intro_offer_period key, the user is not eligible for a free trial or introductory price within that subscription group.
  var subscriptionIntroductoryPricePeriod: Int?
  /// For a transaction that was canceled by Apple customer support, the time and date of the cancellation.
  /// For an auto-renewable subscription plan that was upgraded, the time and date of the upgrade transaction. Treat a canceled receipt the same as if no purchase had ever been made.
  /// Note: A canceled in-app purchase remains in the receipt indefinitely.
  /// Only applicable if the refund was for a non-consumable product, an auto-renewable subscription, a non-renewing subscription, or for a free subscription.
  var cancellationDate: Date?
  /// The primary key for identifying subscription purchases.
  /// This value is a unique ID that identifies purchase events across devices, including subscription renewal purchase events.
  var webOrderLineItemID: Int?
}

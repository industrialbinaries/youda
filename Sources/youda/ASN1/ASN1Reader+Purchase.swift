//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import ASN1Decoder
import Foundation

extension ASN1Decoder {
  func readPurchase(payloadLength: Int) throws -> Purchase {
    // Prepare Purchase properties
    var quantity: Int?
    var productIdentifier: String?
    var transactionIdentifier: String?
    var originalTransactionIdentifier: String?
    var purchaseDate: Date?
    var originalPurchaseDate: Date?
    var subscriptionExpirationDate: Date?
    var subscriptionIntroductoryPricePeriod: Int?
    var cancellationDate: Date?
    var webOrderLineItemID: Int?

    let endOfPayload = pointer.advanced(by: payloadLength)

    let asn1Set = readObject(&pointer, with: payloadLength)
    guard asn1Set.type == ASN1Type.set.rawValue else {
      throw ReceiptError.invalidPurchase
    }

    // Read Purchase properties
    while pointer! < endOfPayload {
      let sequence = try readSequence(with: endOfPayload)

      switch ASN1Type(rawValue: sequence.type) {
      case .purchaseQuantity:
        var pointer = self.pointer
        quantity = readInteger(&pointer, with: sequence.length)
      case .purchaseProductIdentifier:
        var pointer = self.pointer
        productIdentifier = readString(&pointer, with: sequence.length)
      case .purchaseTransactionIdentifier:
        var pointer = self.pointer
        transactionIdentifier = readString(&pointer, with: sequence.length)
      case .purchaseOriginalTransactionIdentifier:
        var pointer = self.pointer
        originalTransactionIdentifier = readString(&pointer, with: sequence.length)
      case .purchaseDate:
        var pointer = self.pointer
        purchaseDate = readDate(&pointer, length: sequence.length)
      case .originalPurchaseDate:
        var pointer = self.pointer
        originalPurchaseDate = readDate(&pointer, length: sequence.length)
      case .purchaseSubscriptionExpirationDate:
        var pointer = self.pointer
        subscriptionExpirationDate = readDate(&pointer, length: sequence.length)
      case .purchaseSubscriptionIntroductoryPricePeriod:
        var pointer = self.pointer
        subscriptionIntroductoryPricePeriod = readInteger(&pointer, with: sequence.length)
      case .purchaseCancellationDate:
        var pointer = self.pointer
        cancellationDate = readDate(&pointer, length: sequence.length)
      case .purchaseWebOrderLineItemID:
        var pointer = self.pointer
        webOrderLineItemID = readInteger(&pointer, with: sequence.length)
      default:
        break
      }

      updateLocation(sequence.length)
    }

    return Purchase(
      quantity: quantity,
      productIdentifier: productIdentifier,
      transactionIdentifier: transactionIdentifier,
      originalTransactionIdentifier: originalTransactionIdentifier,
      purchaseDate: purchaseDate,
      originalPurchaseDate: originalPurchaseDate,
      subscriptionExpirationDate: subscriptionExpirationDate,
      subscriptionIntroductoryPricePeriod: subscriptionIntroductoryPricePeriod,
      cancellationDate: cancellationDate,
      webOrderLineItemID: webOrderLineItemID
    )
  }
}

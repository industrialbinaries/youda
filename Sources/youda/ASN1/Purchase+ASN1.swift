//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation
import OpenSSL

extension Purchase {

  init(
    reader: ASN1Reader,
    payloadLength: Int
  ) throws {
    let endOfPayload = reader.pointer.advanced(by: payloadLength)

    let asn1Set = reader.readNextObject(&reader.pointer, with: payloadLength)
    guard asn1Set.type == V_ASN1_SET else {
      throw ReceiptError.invalidPurchase
    }

    // Decode Payload
    // Step through payload (ASN1 Set) and parse each ASN1 Sequence within (ASN1 Sets contain one or more ASN1 Sequences)
    while reader.pointer! < endOfPayload {
      let sequence = try reader.readSequence(with: endOfPayload)

      switch ASPN1Type(rawValue: sequence.type) {
      case .purchaseQuantity:
        var pointer = reader.pointer
        quantity = reader.readInteger(&pointer, with: sequence.length)
      case .purchaseProductIdentifier:
        var pointer = reader.pointer
        productIdentifier = reader.readString(&pointer, with: sequence.length)
      case .purchaseTransactionIdentifier:
        var pointer = reader.pointer
        transactionIdentifier = reader.readString(&pointer, with: sequence.length)
      case .purchaseOriginalTransactionIdentifier:
        var pointer = reader.pointer
        originalTransactionIdentifier = reader.readString(&pointer, with: sequence.length)
      case .purchaseDate:
        var pointer = reader.pointer
        purchaseDate = reader.readDate(&pointer, length: sequence.length)
      case .purchaseOriginalPurchaseDate:
        var pointer = reader.pointer
        purchaseOriginalPurchaseDate = reader.readDate(&pointer, length: sequence.length)
      case .purchaseSubscriptionExpirationDate:
        var pointer = reader.pointer
        subscriptionExpirationDate = reader.readDate(&pointer, length: sequence.length)
      case .purchaseSubscriptionIntroductoryPricePeriod:
        var pointer = reader.pointer
        subscriptionIntroductoryPricePeriod = reader.readInteger(&pointer, with: sequence.length)
      case .purchaseCancellationDate:
        var pointer = reader.pointer
        cancellationDate = reader.readDate(&pointer, length: sequence.length)
      case .purchaseWebOrderLineItemID:
        var pointer = reader.pointer
        webOrderLineItemID = reader.readInteger(&pointer, with: sequence.length)
      default:
        break
      }

      reader.updateLocation(sequence.length)
    }
  }

}

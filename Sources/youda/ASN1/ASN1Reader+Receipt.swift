//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import ASN1Decoder
import Foundation

extension ASN1Decoder {
  func readReceipt(
    container: PKCS7Container
  ) throws -> Receipt {
    // Prepare Receipt properties
    var bundleId: String?
    var bundleIdRawData: NSData?
    var bundleVersion: String?
    var opaque: NSData?
    var hash: NSData?
    var shortVersion: String?
    var expirationDate: Date?
    var creationDate: Date?
    var purchases = [Purchase]()

    let sign = container.data?.pointee.d.sign
    let octets = sign?.pointee.contents.pointee.d.data
    let octetsLenght = Int(octets?.pointee.length ?? 0)

    let endOfPayload = pointer.advanced(by: octetsLenght)
    let asn1Set = readObject(&pointer, with: octetsLenght)
    guard asn1Set.type == ASN1Type.set.rawValue else {
      throw ReceiptError.invalidReceipt
    }

    // Read Receipt properties
    while pointer < endOfPayload {
      let sequence = try readSequence(with: endOfPayload)

      switch ASN1Type(rawValue: sequence.type) {
      case .bundleId:
        var pointer = self.pointer
        bundleId = readString(&pointer, with: sequence.length)
        bundleIdRawData = readData(&pointer, with: sequence.length)
      case .bundleVersion:
        var pointer = self.pointer
        bundleVersion = readString(&pointer, with: sequence.length)
      case .opaque:
        var pointer = self.pointer
        opaque = readData(&pointer, with: sequence.length)
      case .hash:
        var pointer = self.pointer
        hash = readData(&pointer, with: sequence.length)
      case .createDate:
        var pointer = self.pointer
        creationDate = readDate(&pointer, length: sequence.length)
      case .set:
        let reader = ASN1Decoder(pointer: pointer)
        let purchase = try reader.readPurchase(payloadLength: sequence.length)
        purchases.append(purchase)
      case .shortVersion:
        var pointer = self.pointer
        shortVersion = readString(&pointer, with: sequence.length)
      case .expirationDate:
        var pointer = self.pointer
        expirationDate = readDate(&pointer, length: sequence.length)
      default:
        break
      }

      updateLocation(sequence.length)
    }
    return Receipt(
      bundleId: bundleId,
      bundleIdRawData: bundleIdRawData,
      bundleVersion: bundleVersion,
      opaque: opaque,
      hash: hash,
      shortVersion: shortVersion,
      expirationDate: expirationDate,
      creationDate: creationDate,
      purchases: purchases
    )
  }
}

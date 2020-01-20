//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

extension Receipt {
  init(
    container: PKCS7Container
  ) throws {
    let sign = container.data?.pointee.d.sign
    let octets = sign?.pointee.contents.pointee.d.data
    let octetsLenght = Int(octets?.pointee.length ?? 0)

    let payloadASN1 = UnsafePointer(octets?.pointee.data)!
    let reader = ASN1Reader(pointer: payloadASN1)

    let endOfPayload = reader.pointer.advanced(by: octetsLenght)
    let asn1Set = reader.readNextObject(&reader.pointer, with: octetsLenght)
    guard asn1Set.type == V_ASN1_SET else {
      throw ReceiptError.invalidReceipt
    }

    while reader.pointer < endOfPayload {
      let sequence = try reader.readSequence(with: endOfPayload)

      switch ASPN1Type(rawValue: sequence.type) {
      case .bundleId:
        var pointer = reader.pointer
        bundleId = reader.readString(&pointer, with: sequence.length)
        bundleIdRawData = reader.readData(&pointer, with: sequence.length)
      case .bundleVersion:
        var pointer = reader.pointer
        bundleVersion = reader.readString(&pointer, with: sequence.length)
      case .opaque:
        var pointer = reader.pointer
        opaque = reader.readData(&pointer, with: sequence.length)
      case .hash:
        var pointer = reader.pointer
        hash = reader.readData(&pointer, with: sequence.length)
      case .createDate:
        var pointer = reader.pointer
        creationDate = reader.readDate(&pointer, length: sequence.length)
      case .purchase:
        let purchase = try Purchase(
          reader: ASN1Reader(pointer: reader.pointer),
          payloadLength: sequence.length
        )
        purchases.append(purchase)
      case .shortVersion:
        var pointer = reader.pointer
        shortVersion = reader.readString(&pointer, with: sequence.length)
      case .expirationDate:
        var pointer = reader.pointer
        expirationDate = reader.readDate(&pointer, length: sequence.length)
      default:
        break
      }

      reader.updateLocation(sequence.length)
    }
  }
}

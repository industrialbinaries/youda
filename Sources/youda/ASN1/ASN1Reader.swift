//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

final class ASN1Reader {
  var pointer: UnsafePointer<UInt8>!

  init(pointer: UnsafePointer<UInt8>?) {
    self.pointer = pointer
  }

  func readNextObject(_ pointer: inout UnsafePointer<UInt8>?, with objectLength: Int) -> ASN1Object {
    var type = Int32(0)
    var xclass = Int32(0)
    var length = 0

    ASN1_get_object(
      &pointer,
      &length,
      &type,
      &xclass,
      objectLength
    )

    return ASN1Object(
      type: type,
      xclass: xclass,
      length: length
    )
  }

  func readInteger(_ pointer: inout UnsafePointer<UInt8>?, with objectLength: Int) -> Int? {
    let object = readNextObject(&pointer, with: objectLength)

    guard object.type == V_ASN1_INTEGER else {
      return nil
    }

    let integer = c2i_ASN1_INTEGER(
      nil,
      &pointer,
      object.length
    )
    let result = ASN1_INTEGER_get(integer)
    ASN1_INTEGER_free(integer)
    return result
  }

  func readString(_ pointer: inout UnsafePointer<UInt8>?, with objectLength: Int) -> String? {
    let object = readNextObject(&pointer, with: objectLength)

    switch object.type {
    case V_ASN1_UTF8STRING:
      let stringPointer = UnsafeMutableRawPointer(mutating: pointer)
      return String(
        bytesNoCopy: stringPointer!,
        length: object.length,
        encoding: String.Encoding.utf8,
        freeWhenDone: false
      )
    case V_ASN1_IA5STRING:
      let stringPointer = UnsafeMutableRawPointer(mutating: pointer)
      return String(
        bytesNoCopy: stringPointer!,
        length: object.length,
        encoding: String.Encoding.ascii,
        freeWhenDone: false
      )
    default:
      return nil
    }
  }

  func readData(_ pointer: inout UnsafePointer<UInt8>?, with length: Int) -> NSData {
    return NSData(bytes: &pointer, length: length)
  }

  func readDate(_ pointer: inout UnsafePointer<UInt8>?, length: Int) -> Date? {
    guard let dateInString = readString(&pointer, with: length) else {
      return nil
    }

    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)

    return formatter.date(from: dateInString)
  }

  func readSequence(with endOfSequence: UnsafePointer<UInt8>) throws -> ASN1Sequence {
    // Get next ASN1 Sequence
    let length = pointer!.distance(to: endOfSequence)
    let sequence = readNextObject(&pointer, with: length)
    guard sequence.type == V_ASN1_SEQUENCE else {
      throw ReceiptError.invalidReceipt
    }

    // Read `Type`
    var nexLength = pointer!.distance(to: endOfSequence)
    guard let type = readInteger(&pointer, with: nexLength) else {
      throw ReceiptError.invalidReceipt
    }

    // Read `Version`
    nexLength = pointer!.distance(to: endOfSequence)
    guard readInteger(&pointer, with: nexLength) != nil else {
      throw ReceiptError.invalidReceipt
    }

    // Read octet string
    let octet = readNextObject(&pointer, with: length)
    guard octet.type == V_ASN1_OCTET_STRING else {
      throw ReceiptError.invalidReceipt
    }

    return ASN1Sequence(
      length: octet.length,
      type: type
    )
  }

  func updateLocation(_ length: Int) {
    pointer = pointer?.advanced(by: length)
  }
}

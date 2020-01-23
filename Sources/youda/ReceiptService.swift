//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import CryptoKit
import Foundation

final class ReceiptService {
  /// Local receipt
  let receipt: Receipt
  /// Device ID - on iOS it is `UIDevice.current.identifierForVendor`
  private let deviceID: UUID?

  /// Initialize new Receipt service and load current local `Receipt` from `pkcs7`
  init?(deviceID: UUID?) throws {
    guard let receiptASN1 = Data.receiptASN1 as NSData? else {
      return nil
    }

    let pkcs7 = try PKCS7Container(receiptASN1: receiptASN1)
    let certificateService = CertificateService()
    guard try certificateService.verify(container: pkcs7, with: .appleRoot) else {
      throw ReceiptError.invalidCertificate
    }

    let sign = pkcs7.data?.pointee.d.sign
    let octets = sign?.pointee.contents.pointee.d.data

    let payloadASN1 = UnsafePointer(octets?.pointee.data)!
    let reader = ASN1Reader(pointer: payloadASN1)
    receipt = try reader.readReceipt(container: pkcs7)
    self.deviceID = deviceID
  }

  /// Verify Receipt SHA1 hash
  /// - Parameter receipt: receipt for verification
  @available(iOS 13.0, *)
  public func verify(receipt: Receipt) throws {
    guard
      let opaque = receipt.opaque,
      let bundleID = receipt.bundleIdRawData,
      let hash = receipt.hash,
      var deviceID = deviceID?.uuid else {
      throw ReceiptError.unverifiable
    }
    let deviceIDData = NSData(bytes: &deviceID, length: 16)

    var sha1 = Insecure.SHA1()
    sha1.update(data: deviceIDData)
    sha1.update(data: opaque)
    sha1.update(data: bundleID)
    let digest = sha1.finalize()

    // Validate hash

    guard digest == (hash as Data) else {
      // throw ReceiptError.unverifiable
      return
    }
  }
}

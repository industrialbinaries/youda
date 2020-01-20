//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import CryptoKit
import Foundation
import UIKit

final class ReceiptService {
  /// Local receipt
  let receipt: Receipt

  /// Initialize new Receipt service and load current local `Receipt` from `pkcs7`
  init?() throws {
    guard let receiptASN1 = Data.receiptASN1 as NSData? else {
      return nil
    }

    let pkcs7 = try PKCS7Container(receiptASN1: receiptASN1)
    let certificateService = CertificateService()
    guard try certificateService.verify(container: pkcs7, with: .appleRoot) else {
      throw ReceiptError.invalidCertificate
    }

    receipt = try Receipt(container: pkcs7)
  }

  /// Verify Receipt SHA1 hash
  /// - Parameter receipt: receipt for verification
  @available(iOS 13.0, *)
  public func verify(receipt: Receipt) throws {
    guard
      let opaque = receipt.opaque,
      let bundleID = receipt.bundleIdRawData,
      let hash = receipt.hash,
      var deviceID = UIDevice.current.identifierForVendor?.uuid else {
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
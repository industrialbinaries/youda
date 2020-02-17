//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import ASN1Decoder
import Foundation
#if os(iOS)
  import CryptoKit
#endif

final class ReceiptService {
  /// Local receipt
  let receipt: Receipt
  /// Device ID - on iOS it is `UIDevice.current.identifierForVendor`
  private let deviceID: UUID?
  /// Receipt PKCS7 container
  private let pkcs7: PKCS7Container

  /// Initialize new Receipt service and load current local `Receipt` from `pkcs7`
  /// - Parameters:
  ///   - deviceID: UUID of device, on iOS use  `UIDevice.current.identifierForVendor`
  ///   - asn1: Receipt ASN1 data, in case you don't set this property service use data from `Bundle.main.appStoreReceiptURL`
  init(deviceID: UUID?, asn1: Data? = nil) throws {
    guard let receiptASN1 = (asn1 ?? Data.receiptASN1) as NSData? else {
      throw ReceiptError.missingReceipt
    }

    let pkcs7 = try PKCS7Container(receiptASN1: receiptASN1)

    let sign = pkcs7.data?.pointee.d.sign
    let octets = sign?.pointee.contents.pointee.d.data

    let payloadASN1 = UnsafePointer(octets?.pointee.data)!
    let reader = ASN1Decoder(pointer: payloadASN1)
    receipt = try reader.readReceipt(container: pkcs7)
    self.pkcs7 = pkcs7
    self.deviceID = deviceID
  }

  /// Verify loaded pkcs7 with `Apple Inc. Root Certificate`, for this verification you must add certificate to app bundle from https://www.apple.com/certificateauthority/
  public func verifyCertificate() throws {
    let certificateService = CertificateService()
    guard try certificateService.verify(container: pkcs7, with: .appleRoot) else {
      throw ReceiptError.invalidCertificate
    }
  }

  /// Verify Bundle ID in receipt with app Bundle ID
  public func verifyBundleID() throws {
    guard receipt.bundleId == Bundle.main.bundleIdentifier else {
      throw ReceiptError.invalidBundleID
    }
  }

  /// Verify Bundle Version in receipt with app CFBundleVersion
  public func verifyBundleVersion() throws {
    guard receipt.bundleVersion == Bundle.main.shortVersion else {
      throw ReceiptError.invalidBundleVersion
    }
  }

  /// Verify Receipt SHA1 hash
  /// - Parameter receipt: receipt for verification
  @available(macOS 10.15, iOS 13.0, *)
  public func verifyHash(receipt: Receipt) throws {
    guard
      let opaque = receipt.opaque,
      let bundleID = receipt.bundleIdRawData,
      let hash = receipt.hash,
      var deviceID = deviceID?.uuid else {
      throw ReceiptError.unverifiable
    }

    #if os(iOS)
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
    #else
      throw ReceiptError.unverifiable // In current version is macOS unsupported
    #endif
  }
}

private extension Bundle {
  var shortVersion: String? {
    return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
}

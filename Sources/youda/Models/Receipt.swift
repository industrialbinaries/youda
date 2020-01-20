//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

struct Receipt {
  /// Bundle ID - The app’s bundle identifier.
  /// This corresponds to the value of CFBundleIdentifier in the Info.plist file. Use this value to validate if the receipt was indeed generated for your app.
  var bundleId: String? = nil
  /// Bundle ID - The app’s bundle identifier.
  /// Same like BundleID but in raw data from PKCS7
  var bundleIdRawData: NSData? = nil
  /// Bundle Version - The app’s version number.
  /// This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in macOS) in the Info.plist.
  var bundleVersion: String? = nil
  /// Opaque - An opaque value used, with other data, to compute the SHA-1 hash during validation.
  var opaque: NSData? = nil
  /// Hash - A SHA-1 hash, used to validate the receipt.
  var hash: NSData? = nil
  /// Original Application Version - This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in macOS)
  /// in the Info.plist file when the purchase was originally made. In the sandbox environment, the value of this field is always “1.0”.
  var shortVersion: String? = nil
  /// Receipt Expiration Date - The date that the app receipt expires.
  /// This key is present only for apps purchased through the Volume Purchase Program. If this key is not present, the receipt does not expire.
  /// When validating a receipt, compare this date to the current date to determine whether the receipt is expired.
  /// Do not try to use this date to calculate any other information, such as the time remaining before expiration.
  var expirationDate: Date? = nil
  /// Receipt Creation Date -
  /// When validating a receipt, use this date to validate the receipt’s signature.
  var creationDate: Date? = nil
  /// In-App Purchase Receipt -
  /// The receipt for an in-app purchase. In the JSON file, the value of this key is an array containing all in-app purchase receipts based on the in-app purchase transactions present in the input base-64 receipt-data
  /// For receipts containing auto-renewable subscriptions, check the value of the latest_receipt_info key to get the status of the most recent renewal.
  /// In the ASN.1 file, there are multiple fields that all have type 17, each of which contains a single in-app purchase receipt.
  var purchases = [Purchase]()
}

//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation

enum ReceiptError: Error {
  case missingReceipt
  case missingContainer
  case emptyReceiptContents
  case missingCertificate
  case invalidCertificate
  case invalidReceipt
  case invalidPurchase
  case unverifiable
  case invalidHash
}

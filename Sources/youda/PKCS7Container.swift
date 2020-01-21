//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation
import OpenSSL

/// * The PKCS #7 container (the receipt) and the output of the verification. */
// BIO *b_p7;
// PKCS7 *p7;
struct PKCS7Container {
  let data: UnsafeMutablePointer<PKCS7>?

  init(receiptASN1: NSData) throws {
    /// * ... Initialize both BIO variables using BIO_new_mem_buf() with a buffer and its size ... */
    /// * Initialize b_out as an output BIO to hold the receipt payload extracted during signature verification. */
    let receiptBIO = BIO_new(BIO_s_mem())
    let receiptBytes = receiptASN1.bytes
    let receiptLength = Int32(receiptASN1.length)
    BIO_write(
      receiptBIO,
      receiptBytes,
      receiptLength
    )

    /// * Capture the content of the receipt file and populate the p7 variable with the PKCS #7 container. */
    // p7 = d2i_PKCS7_bio(b_p7, NULL);
    guard let receiptPKCS7Container = d2i_PKCS7_bio(receiptBIO, nil) else {
      throw ReceiptError.missingContainer
    }

    data = receiptPKCS7Container
  }
}

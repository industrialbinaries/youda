//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation
import OpenSSL
import StoreKit

/// * The Apple root certificate, as raw data and in its OpenSSL representation. */
// BIO *b_x509;
// X509 *Apple;
struct CertificateService {
  enum Certificate: String {
		/// Apple Inc Root Certificate for verify Receipt from https://www.apple.com/certificateauthority/
    case appleRoot = "AppleIncRootCertificate"
  }

  func verify(
    container: PKCS7Container,
    with certificate: Certificate
  ) throws -> Bool {
    let certificateData = try load(certificate: certificate)

    /// * The root certificate for chain-of-trust verification. */
    let x509Store = X509_STORE_new()
    X509_STORE_add_cert(x509Store, certificateData)
//        OpenSSL_add_all_digests() // TODO: Fix later

    /// * Verify the signature. If the verification is correct, b_out will contain the PKCS #7 payload and rc will be 1. */
    // int rc = PKCS7_verify(p7, NULL, store, NULL, b_out, 0);
    return PKCS7_verify(
      container.data, nil,
      x509Store, nil, nil, 0
    ) == 1
  }

  private func load(certificate: Certificate) throws -> OpaquePointer {
    /// * ... Load the Apple root certificate into b_X509 ... */
    guard
      let certificateURL = Bundle.main.url(
        forResource: certificate.rawValue,
        withExtension: "cer"
      ),
      let certificateData = try? Data(
        contentsOf: certificateURL
      )
    else {
      throw ReceiptError.missingCertificate
    }

    /// * Initialize b_x509 as an input BIO with a value of the Apple root certificate and load it into X509 data structure. Then add the Apple root certificate to the structure. */
    // Apple = d2i_X509_bio(b_x509, NULL);
    // X509_STORE_add_cert(store, Apple);
    let certificateBIO = BIO_new(BIO_s_mem())
    let certificateBytes = (certificateData as NSData).bytes
    let certificateLength = Int32(certificateData.count)
    BIO_write(
      certificateBIO,
      certificateBytes,
      certificateLength
    )

    return d2i_X509_bio(certificateBIO, nil)
  }
}

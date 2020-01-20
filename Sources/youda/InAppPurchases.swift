//
//  lola
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import StoreKit
import UIKit

public struct InAppProductId: Hashable {
  let identifier: String
}

public let subscriptionChangeNotification: Notification.Name = Notification.Name(rawValue: "io.insdustrial-binaries.subscription-change")

final class InAppPurchases: NSObject {
  // MARK: - Public properties

  /// Available products from apple developer
  private(set) var availableProducts = [SKProduct]()
  /// Purchased products
  private(set) var purchasedProducts = Set<InAppProductId>()

  // MARK: - Private properties

  /// App In-App-Purchases products
  private let products: Set<InAppProductId>

  /// Initialize new InAppPurchases service
  /// - Parameter products: products for request from apple developer acount
  init(products: Set<InAppProductId>) {
    self.products = products
    super.init()
    // Add SKProductsRequestDelegate
    setupTransactionObserver()
    // Request products
    requestProducts()
    // Load receipts from bundle
    try? loadReceipts()
  }

  private func setupTransactionObserver() {
    SKPaymentQueue.default().add(self)
    NotificationCenter.default.addObserver(
      forName: UIApplication.willTerminateNotification,
      object: nil,
      queue: nil
    ) { _ in
      SKPaymentQueue.default().remove(self)
    }
  }

  private func addPurchasedProduct(identifier: String) {
    purchasedProducts.insert(InAppProductId(identifier: identifier))
    // inform about subscription change
    NotificationCenter.default.post(Notification(name: subscriptionChangeNotification))
  }
}

// MARK: - InAppPurchasesProtocol

extension InAppPurchases: InAppPurchasesProtocol {
  /// Try buy new `product`
  /// - Parameter product: new requested product
  func buy(product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  /// Restore bought products, f.e. when you log in on new device or uninstall app
  func restoreProducts() {
    refreshReceipt()
  }
}

// MARK: - SKProductsRequestDelegate

extension InAppPurchases: SKProductsRequestDelegate {
  func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
    availableProducts = response.products
  }

  func requestDidFinish(_ request: SKRequest) {
    guard request is SKReceiptRefreshRequest else { return }
    try? loadReceipts()
  }

  private func requestProducts() {
    let identifiers = Set(products.map { $0.identifier })
    let productsRequest = SKProductsRequest(productIdentifiers: identifiers)
    productsRequest.delegate = self
    productsRequest.start()
  }
}

// MARK: - SKPaymentTransactionObserver

extension InAppPurchases: SKPaymentTransactionObserver {
  func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch transaction.transactionState {
      case .purchased, .restored:
        addPurchasedProduct(identifier: transaction.payment.productIdentifier)
      case .failed:
        finish(transaction: transaction)
      default: break
      }
    }
  }

  private func finish(transaction: SKPaymentTransaction) {
    SKPaymentQueue.default().finishTransaction(transaction)
  }
}

// MARK: - Receipt helpers

private extension InAppPurchases {
  func loadReceipts() throws {
    let receiptService = try ReceiptService()
    let receipt = receiptService?.receipt

    for receipt in receipt?.purchases ?? [] {
      if let identifier = receipt.productIdentifier,
        let expirationDate = receipt.subscriptionExpirationDate,
        expirationDate >= Date() {
        addPurchasedProduct(identifier: identifier)
      }
    }
  }

  /// Refresh user receipt, required user login
  func refreshReceipt() {
    let request = SKReceiptRefreshRequest()
    request.delegate = self
    request.start()
  }
}

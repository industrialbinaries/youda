//
//  youda
//
//  Copyright (c) 2020 Industrial Binaries
//  MIT license, see LICENSE file for details
//

import Foundation
import StoreKit

extension Notification.Name {
  /// Notification trigged when update bought products
  static var subscriptionChange: Notification.Name {
    Notification.Name(rawValue: "co.industrial-binaries.youda.subscription-change")
  }
}

public final class IAPService: NSObject {
  // MARK: - Public properties

  /// Available products from iTunesConnect, it is all products which you can buy from your app
  public private(set) var availableProducts = [IAPProduct]()
  /// Purchased products from available products
  public var purchasedProducts: [IAPProduct] {
    return availableProducts
      .filter { purchasedProductsIdentifiers.contains($0.productIdentifier) }
  }

  /// IAP delegate for inform about purchase updates
  public weak var delegate: IAPServiceDelegate?

  // MARK: - Private properties

  /// Products for request from iTunesConnect
  private let requestedProductIdentifiers: Set<String>
  /// Purchased products identifiers
  private var purchasedProductsIdentifiers = Set<String>()
  /// Device ID for validate receipt hash
  private let deviceID: UUID?

  /// Remove service from payment queue, please call when your app is terminate `UIApplication.willTerminateNotification`
  deinit {
    SKPaymentQueue.default().remove(self)
  }

  /// Initialize new InAppPurchases service
  /// - Parameters:
  ///   - products: Products for request from iTunesConnect
  ///   - deviceID: Device ID for validate receipt hash
  public init(products: Set<String>, deviceID: UUID?) {
    requestedProductIdentifiers = products
    self.deviceID = deviceID
    super.init()
    // Add SKProductsRequestDelegate
    setupTransactionObserver()
    // Request products
    requestProducts()
    // Load local receipts from bundle
    try? loadReceipts()
  }

  private func setupTransactionObserver() {
    SKPaymentQueue.default().add(self)
  }

  private func addPurchasedProduct(identifier: String) {
    purchasedProductsIdentifiers.insert(identifier)
    // Send notification to inform about change purchased products
    NotificationCenter.default.post(name: .subscriptionChange, object: nil)
    // Call delegate with new purchased products
    delegate?.didUpdate(purchasedProducts: purchasedProducts)
  }
}

// MARK: - InAppPurchasesProtocol

extension IAPService: IAPServiceProtocol {
  /// Try buy new `product`
  /// - Parameter product: Product identifier for purchase
  public func buy(product productIdentifier: String) {
    guard let product = availableProducts
      .first(where: { $0.productIdentifier == productIdentifier })?
      .product else { return }
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  /// Restore bought products, f.e. when you log in on new device or uninstall app
  public func restoreProducts() {
    refreshReceipt()
  }
}

// MARK: - SKProductsRequestDelegate

extension IAPService: SKProductsRequestDelegate {
  public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
    availableProducts = response
      .products
      .map { IAPProduct(with: $0) }
  }

  public func requestDidFinish(_ request: SKRequest) {
    guard request is SKReceiptRefreshRequest else { return }
    try? loadReceipts()
  }

  private func requestProducts() {
    let productsRequest = SKProductsRequest(productIdentifiers: requestedProductIdentifiers)
    productsRequest.delegate = self
    productsRequest.start()
  }
}

// MARK: - SKPaymentTransactionObserver

extension IAPService: SKPaymentTransactionObserver {
  public func paymentQueue(
    _: SKPaymentQueue,
    updatedTransactions transactions: [SKPaymentTransaction]
  ) {
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

private extension IAPService {
  func loadReceipts() throws {
    let receiptService = try ReceiptService(deviceID: deviceID)
    let receipt = receiptService?.receipt

    for receipt in receipt?.purchases ?? [] {
      if let identifier = receipt.productIdentifier,
        let expirationDate = receipt.subscriptionExpirationDate,
        expirationDate >= Date() {
        addPurchasedProduct(identifier: identifier)
      }
    }
  }

  /// Refresh user receipt - required user login
  func refreshReceipt() {
    let request = SKReceiptRefreshRequest()
    request.delegate = self
    request.start()
  }
}

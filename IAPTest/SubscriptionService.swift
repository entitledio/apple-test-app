import Foundation
import StoreKit

class SubscriptionService: NSObject {
    
    static let iapLoadedNotification = Notification.Name("SubscriptionServiceIAPLoadedNotification")
    static let purchaseSuccessfulNotification = Notification.Name("purchaseSuccessfulNotification")
    
    static let shared = SubscriptionService()
    
    var receipt: String?
    
    var options: [SKProduct]? {
        didSet {
            NotificationCenter.default.post(name: SubscriptionService.iapLoadedNotification, object: options)
        }
    }
    
    func loadSubscriptionOptions() {
        let productIDs = Set(["com.entitled.IAPTest.iap.onetime", "com.entitled.IAPTest.ias.weekly", "com.entitled.IAPTest.ias.monthly"])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        
        request.delegate = self
        request.start()
    }
    
    func purchase(subscription: SKProduct) {
        let payment = SKPayment(product: subscription)
        SKPaymentQueue.default().add(payment)
    }
    
    func getReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        receipt = loadReceipt()?.base64EncodedString()
    }

    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
}

extension SubscriptionService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("invalidProductIdentifiers \(response.invalidProductIdentifiers)")
        print("Products Count \(response.products.count)")
        print("Products \(response.products)")
        print("Products TYPE \(type(of: response.products))")
        options = response.products
        NotificationCenter.default.post(name: AppDelegate.IAPLoadedNotification, object: self)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("IAP products Failed Loading: \(error.localizedDescription)")
        }
    }
}


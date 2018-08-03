//
//  ViewController.swift
//  IAPTest
//
//  Created by Sagar Shah on 8/2/18.
//  Copyright © 2018 Entitled. All rights reserved.
//

import UIKit
// Imports StoreKit which is required for IAP functions
import StoreKit

class ViewController: UIViewController {
    var inAppPurchaseItems: [SKProduct]?
    var receipt: String?
    
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var receiptButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var receiptText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monthlyButton.isEnabled = false
        monthlyButton.addTarget(self, action: #selector(handleMonthlySubscribe), for: .touchUpInside)
        weeklyButton.isEnabled = false
        weeklyButton.addTarget(self, action: #selector(handleWeeklySubscribe), for: .touchUpInside)
        receiptButton.isEnabled = false
        receiptButton.addTarget(self, action: #selector(handleReceiptRequest), for: .touchUpInside)
        purchaseButton.isEnabled = false
        purchaseButton.addTarget(self, action: #selector(handleOneTimePurchase), for: .touchUpInside)
        inAppPurchaseItems = SubscriptionService.shared.options
        receipt = SubscriptionService.shared.receipt
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleIAPLoaded(notification:)),
                                               name: SubscriptionService.iapLoadedNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessful(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleWeeklySubscribe(){
        let weeklyProduct = inAppPurchaseItems?.first(where: { $0.productIdentifier == "com.entitled.IAPTest.ias.weekly" })
        print("weekly \(String(describing: weeklyProduct))")
        SubscriptionService.shared.purchase(subscription: weeklyProduct!)
    }

    @objc func handleMonthlySubscribe(){
        let monthlyProduct = inAppPurchaseItems?.first(where: { $0.productIdentifier == "com.entitled.IAPTest.ias.monthly" })
        print("monthly \(String(describing: monthlyProduct))")
        SubscriptionService.shared.purchase(subscription: monthlyProduct!)
    }

    @objc func handleOneTimePurchase(){
        let oneTimeProduct = inAppPurchaseItems?.first(where: { $0.productIdentifier == "com.entitled.IAPTest.iap.onetime" })
        print("onetime \(String(describing: oneTimeProduct))")
        SubscriptionService.shared.purchase(subscription: oneTimeProduct!)
    }
    
    @objc func handleReceiptRequest(){
        SubscriptionService.shared.getReceipt()
        receiptText.text = SubscriptionService.shared.receipt
    }

    @objc func handleIAPLoaded(notification: Notification) {
        inAppPurchaseItems = SubscriptionService.shared.options
        receiptButton.isEnabled = true
        receiptButton.backgroundColor = UIColor.darkGray
        
        for iap in inAppPurchaseItems! {
            switch iap.productIdentifier {
            case "com.entitled.IAPTest.iap.onetime":
                purchaseButton.isEnabled = true
                purchaseButton.backgroundColor = UIColor.darkGray
                purchaseButton.setTitle("$\(iap.price)", for: .normal)
            case "com.entitled.IAPTest.ias.weekly":
                weeklyButton.isEnabled = true
                weeklyButton.backgroundColor = UIColor.darkGray
                weeklyButton.setTitle("$\(iap.price) / week", for: .normal)
            case "com.entitled.IAPTest.ias.monthly":
                monthlyButton.isEnabled = true
                monthlyButton.backgroundColor = UIColor.darkGray
                monthlyButton.setTitle("$\(iap.price) / month", for: .normal)
            default:
                print("Unknown IAP")
            }
        }
    }
    
    @objc func handlePurchaseSuccessful(notification: Notification) {
        receipt = SubscriptionService.shared.receipt
        receiptText.text = receipt
    }
}

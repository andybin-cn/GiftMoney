//
//  MaketManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift
import Common

enum MarketServiceType {
    case media
    case event
    case relation
    case modifyEvent
    case exportAndImport
    case backupAndRecover
    case autoSyncToiCloud
    case speechRecognize
}

class MarketManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum Level: Int {
        case free
        case paid1
        case paid2
    }
    
    static let shared = MarketManager()
    var paidProducts = [String]() {
        didSet {
            self.resetCurrentLevel()
            UserDefaults.standard.set(paidProducts, forKey: "MarketManager_paidProducts")
        }
    }
    var hasVip1Paid: Bool {
        return paidProducts.contains("vip001")
    }
    var hasVip2Paid: Bool {
        return paidProducts.contains("vip002")
    }
    var speechRecognizedCount: Int {
        didSet {
            UserDefaults.standard.set(speechRecognizedCount, forKey: "MarketManager_speechRecognizedCount")
        }
    }
    let speechRecognizedLimit = 30
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    private override init() {
        paidProducts = UserDefaults.standard.object(forKey: "MarketManager_paidProducts") as? [String] ?? [String]()
        speechRecognizedCount = UserDefaults.standard.integer(forKey: "MarketManager_speechRecognizedCount")
        super.init()
        
        self.resetCurrentLevel()
        _ = InviteManager.shared.invitedCountRelay.subscribe(onNext: { (count) in
            self.resetCurrentLevel()
        })
        
        SKPaymentQueue.default().add(self)
    }
    
    func resetCurrentLevel() {
        self.currentLevel = .free
        if hasVip1Paid {
            self.currentLevel = .paid1
        }
        if hasVip2Paid {
            self.currentLevel = .paid2
        }
        let count = InviteManager.shared.invitedCount
        if count >= 20 {
            self.currentLevel = .paid2
        } else if self.currentLevel == .free && count >= 5 {
            self.currentLevel = .paid1
        }
    }
    
    var currentLevel = Level.free
    
    func checkAuth(type: MarketServiceType, controller: UIViewController, count: Int = 0, formValue: String = "") -> Bool {
        if currentLevel != .free {
            return true
        }
        if scoreFor(type: type, count: count, formValue: formValue) > AccountManager.shared.score.value {
            self.showPayMessage(msg: "您的活跃积分已不足，快去获取活跃积分吧！", controller: controller)
            return false
        }
        return true
    }
    
    func scoreFor(type: MarketServiceType, count: Int = 0, formValue: String = "") -> Int {
        switch type {
        case .autoSyncToiCloud:
            return 5
        case .backupAndRecover:
            return 5
        case .exportAndImport:
            return 50
        case .relation:
            if Relationship.systemRelationship.contains(Relationship(name: formValue)) {
                return 0
            }
            let latestusedRelationships = Relationship.latestusedRelationships
            if latestusedRelationships.contains(Relationship(name: formValue)) {
                return 0
            }
            return 5
        case .event:
            if Event.systemEvents.contains(Event(name: formValue, time: nil, lastUseTime: nil, compareWithTime: false)) {
                return 0
            }
            let latestusedEvents = Event.latestusedEvents
            if latestusedEvents.contains(Event(name: formValue, time: nil, lastUseTime: nil, compareWithTime: false)) {
                return 0
            }
            return 5
        case .media:
            return count * 2
        case .modifyEvent:
            return 0
        case .speechRecognize:
            return 1
        }
    }
    
    func showPayMessage(msg: String, controller: UIViewController) {
        controller.showAlertView(title: msg, message: nil, actions: [
            UIAlertAction(title: "好的", style: .cancel, handler: { (_) in
                controller.present(MarketVC(superVC: controller), animated: true, completion: nil)
            })
        ])
    }
    
    func recoverProducts() -> Observable<(String, SKPaymentTransactionState)> {
        self.payObserver?.onCompleted()
        return Observable<(String, SKPaymentTransactionState)>.create { (observer) -> Disposable in
            self.payObserver = observer
            SKPaymentQueue.default().restoreCompletedTransactions()
            return Disposables.create {
                self.payObserver = nil
            }
        }
    }
    
    private var fetchProductObserver: AnyObserver<SKProduct>?
    func fetchProductForCode(code: String) -> Observable<SKProduct> {
        self.fetchProductObserver?.onCompleted()
        return Observable<SKProduct>.create { (observer) -> Disposable in
            self.fetchProductObserver = observer
            let productsRequest = SKProductsRequest(productIdentifiers: Set<String>(arrayLiteral: code))
            productsRequest.delegate = self
            productsRequest.start()
            return Disposables.create {
                self.fetchProductObserver = nil
            }
        }
    }
    
    private var payObserver: AnyObserver<(String, SKPaymentTransactionState)>?
    func payFor(product: SKProduct) -> Observable<(String, SKPaymentTransactionState)> {
        self.payObserver?.onCompleted()
        return Observable<(String, SKPaymentTransactionState)>.create { (observer) -> Disposable in
            self.payObserver = observer
            let payment = SKMutablePayment(product: product)
            //        payment.simulatesAskToBuyInSandbox = true
            SKPaymentQueue.default().add(payment)
            return Disposables.create {
                self.payObserver = nil
            }
        }.observeOn(MainScheduler.instance)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            fetchProductObserver?.onNext(product)
            fetchProductObserver?.onCompleted()
        } else {
            fetchProductObserver?.onError(CommonError(message: "获取产品信息失败"))
        }
    }
    
    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        SLog.debug("updatedTransactions: start")
        for transaction in transactions {
            let productID = transaction.payment.productIdentifier
            switch transaction.transactionState {
            case .deferred:
                //该交易处于队列中，但其最终状态正在等待“要求购买”等外部操作。
                //更新您的用户界面以显示延迟状态，并等待另一个指示最终状态的回调。
                SLog.debug("updatedTransactions - deferred： \(productID)")
                self.payObserver?.onNext((productID, transaction.transactionState))
                break
            case .purchasing:
                //该交易正在由App Store处理。
                SLog.debug("updatedTransactions: purchasing： \(productID)")
                self.payObserver?.onNext((productID, transaction.transactionState))
                break
            case .failed:
                //交易失败
                SLog.info("updatedTransactions: failed： \(productID)")
                self.payObserver?.onNext((productID, transaction.transactionState))
                if let error = transaction.error {
                    self.payObserver?.onError(error)
                } else {
                    self.payObserver?.onError(CommonError(message: "支付失败"))
                }
                break
            case .restored, .purchased:
                SLog.info("updatedTransactions: success： \(productID)")
                //购买成功
                //恢复用户先前购买的内容。 可查看originalTransaction属性以获取有关原始购买的信息。
                if !paidProducts.contains(productID) {
                    paidProducts.append(productID)
                    if transaction.transactionState == .purchased {
                        MobClick.event("purchSuccess-\(productID)")
                    }
                }
                self.payObserver?.onNext((productID, transaction.transactionState))
                self.payObserver?.onCompleted()
                break
            @unknown default:
                break
            }
        }
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.payObserver?.onCompleted()
    }
}


extension MarketManager.Level {
    var label: String {
        switch self {
        case .free:
            return "免费账号"
        case .paid1:
            return "【黄金VIP】"
        case .paid2:
            return "【钻石VIP】"
        }
    }
    
}

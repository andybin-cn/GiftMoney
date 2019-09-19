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
    
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    private override init() {
        paidProducts = UserDefaults.standard.object(forKey: "MarketManager_paidProducts") as? [String] ?? [String]()
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
        if count >= 30 {
            self.currentLevel = .paid2
        } else if self.currentLevel == .free && count >= 5 {
            self.currentLevel = .paid1
        }
    }
    
    var currentLevel = Level.free
    
    func checkAuth(type: MarketServiceType, controller: UIViewController, count: Int = 0, formValue: String = "") -> Bool {
        switch type {
        case .exportAndImport, .backupAndRecover, .autoSyncToiCloud:
            if currentLevel != .paid2 {
                controller.present(MarketVC(superVC: controller), animated: true, completion: nil)
                return false
            }
        case .relation:
            if Relationship.systemRelationship.contains(Relationship(name: formValue)) {
                return true
            }
            let latestusedRelationships = Relationship.latestusedRelationships
            if latestusedRelationships.contains(Relationship(name: formValue)) {
                return true
            }
            let customCount = latestusedRelationships.filter { (relation) -> Bool in
                return !Relationship.systemRelationship.contains(relation)
            }.count
            if currentLevel == .free && customCount >= 1 {
                self.showPayMessage(msg: "\(Level.free.label)最多只能添加 1个自定义关系，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && customCount >= 5 {
                self.showPayMessage(msg: "\(Level.paid1.label)最多只能添加 5个自定义关系，快去升级\(Level.paid2.label)解除限制吧", controller: controller)
                return false
            }
        case .event:
            if Event.systemEvents.contains(Event(name: formValue, time: nil, lastUseTime: nil, compareWithTime: false)) {
                return true
            }
            let latestusedEvents = Event.latestusedEvents
            if latestusedEvents.contains(Event(name: formValue, time: nil, lastUseTime: nil, compareWithTime: false)) {
                return true
            }
            let customCount = latestusedEvents.filter { (event) -> Bool in
                return !Event.systemEvents.contains(event)
            }.count
            
            if currentLevel == .free && customCount >= 1 {
                self.showPayMessage(msg: "\(Level.free.label)最多只能添加 1个自定义事件，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && customCount >= 5 {
                self.showPayMessage(msg: "\(Level.paid1.label)最多只能添加 5个自定义事件，快去升级\(Level.paid2.label)解除限制吧", controller: controller)
                return false
            }
        case .media:
            if currentLevel == .free && count >= 1 {
                self.showPayMessage(msg: "\(Level.free.label)最多只能添加 1张图片或视频，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 5 {
                self.showPayMessage(msg: "\(Level.paid1.label)最多只能添加 5张图片或视频，快去升级\(Level.paid2.label)解除限制吧", controller: controller)
                return false
            }
        case .modifyEvent:
            if currentLevel == .free {
                self.showPayMessage(msg: "免费账号不支持批量修改事件信息，快去购买Vip解除限制吧", controller: controller)
                return false
            }
        }
        return true
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
        }
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
                if transaction.transactionState == .purchased {
                    MobClick.event("purchSuccess-\(productID)")
                }
                //购买成功
                //恢复用户先前购买的内容。 可查看originalTransaction属性以获取有关原始购买的信息。
                if !paidProducts.contains(productID) {
                    paidProducts.append(productID)
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

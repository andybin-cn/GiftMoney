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
}

class MarketManager {
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
    
    
    private init() {
        paidProducts = UserDefaults.standard.object(forKey: "MarketManager_paidProducts") as? [String] ?? [String]()
        
        self.resetCurrentLevel()
        _ = InviteManager.shared.invitedCountRelay.subscribe(onNext: { (count) in
            self.resetCurrentLevel()
        })
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
    
    func checkAuth(type: MarketServiceType, controller: UIViewController, count: Int = 0) -> Bool {
        switch type {
        case .exportAndImport, .backupAndRecover:
            if currentLevel != .paid2 {
                controller.present(MarketVC(), animated: true, completion: nil)
                return false
            }
        case .relation:
            if currentLevel == .free && count >= 2 {
                self.showPayMessage(msg: "免费账号最多只能添加 2个自定义关系，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 8 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 8个自定义关系，快去升级【黄金VIP】解除限制吧", controller: controller)
                return false
            }
        case .event:
            if currentLevel == .free && count >= 1 {
                self.showPayMessage(msg: "免费账号最多只能添加 1个自定义事件，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 4 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 4个自定义事件，快去升级【黄金VIP】解除限制吧", controller: controller)
                return false
            }
        case .media:
            if currentLevel == .free && count >= 1 {
                self.showPayMessage(msg: "免费账号最多只能添加 1张图片或视频，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 3 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 3张图片或视频，快去升级【黄金VIP】解除限制吧", controller: controller)
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
                    controller.present(MarketVC(), animated: true, completion: nil)
                })
            ])
    }
    
    
    func payForCode(code: String) -> Observable<SKPaymentTransactionState> {
        return StoreObserver(productCode: code).requestPay().do(onNext: { (state) in
            if state == .purchased || state == .restored {
                if !self.paidProducts.contains(code) {
                    self.paidProducts.append(code)
                }
            }
        }).observeOn(MainScheduler())
    }
}



class StoreObserver: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    deinit {
        print("StoreObserver released!")
    }
    
    var productsRequest: SKProductsRequest?
    var productCode: String
    init(productCode: String) {
        self.productCode = productCode
    }
    
    func requestPay() -> Observable<SKPaymentTransactionState> {
        return fetchProductForCode(code: productCode).flatMap { self.payFor(product: $0) }
    }
    
    private var observer: AnyObserver<SKProduct>?
    func fetchProductForCode(code: String) -> Observable<SKProduct> {
        return Observable<SKProduct>.create { [unowned self] (observer) -> Disposable in
            self.observer = observer
            let productsRequest = SKProductsRequest(productIdentifiers: Set<String>(arrayLiteral: code))
            productsRequest.delegate = self
            productsRequest.start()
            self.productsRequest = productsRequest
            return Disposables.create {
                self.productsRequest = nil
                productsRequest.delegate = nil
            }
        }
    }
    
    private var payObserver: AnyObserver<SKPaymentTransactionState>?
    func payFor(product: SKProduct) -> Observable<SKPaymentTransactionState> {
        return Observable<SKPaymentTransactionState>.create { [unowned self] (observer) -> Disposable in
            self.payObserver = observer
            let payment = SKMutablePayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            return Disposables.create {
                SKPaymentQueue.default().remove(self)
            }
        }
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            observer?.onNext(product)
            observer?.onCompleted()
        } else {
            observer?.onError(CommonError(message: "获取产品信息失败"))
        }
    }
    
    
    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            self.payObserver?.onNext(transaction.transactionState)
            switch transaction.transactionState {
            case .deferred:
                //该交易处于队列中，但其最终状态正在等待“要求购买”等外部操作。
                //更新您的用户界面以显示延迟状态，并等待另一个指示最终状态的回调。
                break
            case .purchasing:
                //该交易正在由App Store处理。
                break
            case .failed:
                //交易失败
                if let error = transaction.error {
                    SLog.error("transaction failed:\(error)")
                    self.payObserver?.onError(error)
                } else {
                    self.payObserver?.onError(CommonError(message: "支付未完成"))
                }
                break
            case .purchased:
                //App Store已成功处理付款。
                self.payObserver?.onCompleted()
                break
            case .restored:
                //恢复用户先前购买的内容。 可查看originalTransaction属性以获取有关原始购买的信息。
                self.payObserver?.onCompleted()
                break
            @unknown default:
                SLog.error("Unexpected transaction state:\(transaction.transactionState)")
                self.payObserver?.onCompleted()
                break
            }
        }
    }
    
}

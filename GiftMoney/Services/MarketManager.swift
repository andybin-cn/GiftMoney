//
//  MaketManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

enum MarketServiceType {
    case media
    case event
    case relation
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
    
    private init() {
        
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
            if currentLevel == .free && count >= 4 {
                self.showPayMessage(msg: "免费账号最多只能添加 4个自定义关系，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 8 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 8个自定义关系，快去升级【黄金Vip】解除限制吧", controller: controller)
                return false
            }
        case .event:
            if currentLevel == .free && count >= 2 {
                self.showPayMessage(msg: "免费账号最多只能添加 2个自定义事件，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 4 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 4个自定义事件，快去升级【黄金Vip】解除限制吧", controller: controller)
                return false
            }
        case .media:
            if currentLevel == .free && count >= 1 {
                self.showPayMessage(msg: "免费账号最多只能添加 1张图片或视频，快去购买Vip解除限制吧", controller: controller)
                return false
            } else if currentLevel == .paid1 && count >= 8 {
                self.showPayMessage(msg: "【白银Vip】最多只能添加 8张图片或视频，快去升级【黄金Vip】解除限制吧", controller: controller)
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
}

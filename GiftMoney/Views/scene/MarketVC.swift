//
//  MarketVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Common
import RxSwift
import StoreKit

class MarketVC: BaseViewController {
    
    let scrollView = UIScrollView()
    let closeButton = UIButton()
    let recoverButton = UIButton()
    let stackView = UIStackView()
    
    let ruleGroup: MarketServiceGroup
    let scoreGroup: MarketServiceGroup
//    let vip2Group: MarketServiceGroup
//    let inviteGroup: MarketServiceGroup
    
    weak var superVC: UIViewController?
    
    init(superVC: UIViewController?) {
        self.superVC = superVC
        
        let headerTitle = MarketServiceHeader(title: "活跃积分使用规则：", image: nil)
        let freeItems: [MarketServiceItem] = [
            MarketServiceItem(title: "启用iCloud自动同步功能（5积分/次）"),
            MarketServiceItem(title: "iCloud备份恢复功能（5积分/次）"),
            MarketServiceItem(title: "自定义关系（5积分/个）"),
            MarketServiceItem(title: "自定义事件（5积分/个）"),
            MarketServiceItem(title: "附加图片或视频（2积分/个）"),
            MarketServiceItem(title: "语音识别录入功能（1积分/次）"),
            MarketServiceItem(title: "附加图片或视频（1积分/个）"),
            MarketServiceItem(title: "数据导入导出功能（50积分/次）"),
        ]
        ruleGroup = MarketServiceGroup(header: headerTitle, items: freeItems)
        
        let scoreTitle = MarketServiceHeader(title: "如何获取活跃积分：", image: nil)
        let vip1Items: [MarketServiceItem] = [
            MarketServiceItem(title: "每日登陆签到获取积分"),
            MarketServiceItem(title: "分享好友获取积分"),
            MarketServiceItem(title: "观看广告获取积分")
        ]
        scoreGroup = MarketServiceGroup(header: scoreTitle, items: vip1Items)
        
//        let inviteHeader = MarketServiceHeader(title: "邀请好友获取会员资格", image: UIImage(named: "icons8-vip")?.ui_renderImage(tintColor: UIColor.from(hexString: "#FF6100")))
//        let inviteItems: [MarketServiceItem] = [
//            MarketServiceItem(title: "成功邀请5位好友，解锁【黄金VIP】所有功能"),
//            MarketServiceItem(title: "成功邀请20位好友，解锁【钻石VIP】所有功能")
//        ]
//        inviteGroup = MarketServiceGroup(header: inviteHeader, items: inviteItems, showPay: true)
//        inviteGroup.buyButton.setTitle("立即邀请", for: .normal)
//        inviteGroup.buyButton.setTitle("立即邀请", for: .disabled)
//        inviteGroup.buyButton.setImage(UIImage(named: "icons8-invite")?.ui_resizeImage(to: CGSize(width: 20, height: 20)), for: .normal)
//        inviteGroup.buyButton.snp.updateConstraints { (make) in
//            make.width.equalTo(120)
//        }
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.addTo(view) { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = .clear
            scrollView.addTo(self.view) { (make) in
                make.edges.equalToSuperview()
            }
            
            UIView().apply { (widthView) in
                widthView.addTo(scrollView) { (make) in
                    make.left.right.top.equalToSuperview()
                    make.height.equalTo(0)
                    make.width.equalTo(self.view)
                }
            }
        }
        
        stackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.spacing = 15
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(100)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40).priority(ConstraintPriority.low)
            }
        }
        stackView.addArrangedSubview(ruleGroup)
        stackView.addArrangedSubview(scoreGroup)
        
        closeButton.apply { (button) in
            button.setTitle("关闭", for: UIControl.State.normal)
            button.addTarget(self, action: #selector(onCloseButtonTapped), for: .touchUpInside)
            button.addTo(view) { (make) in
                make.left.equalTo(15)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
        }
        
        recoverButton.apply { (button) in
            button.setTitle("恢复购买", for: UIControl.State.normal)
            button.addTarget(self, action: #selector(onRecoverButtonTapped), for: .touchUpInside)
            button.addTo(view) { (make) in
                make.right.equalTo(-15)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }
        }
        
        addEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshUI()
    }
    
    func refreshUI() {
//        scoreGroup.buyButton.isEnabled = !MarketManager.shared.hasVip1Paid
    }
    
    func addEvents() {
//        scoreGroup.buyButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
//            MobClick.event("buyVIP1BtnTapped")
//            self?.payForProduct(code: "vip001")
//        }).disposed(by: disposeBag)
//        vip2Group.buyButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
//            MobClick.event("buyVIP2BtnTapped")
//            self?.payForProduct(code: "vip002")
//        }).disposed(by: disposeBag)
//
//        inviteGroup.buyButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
//            MobClick.event("buyInviteBtnTapped")
//            self?.onInviteButtonTapped()
//        }).disposed(by: disposeBag)
    }
    
    func onInviteButtonTapped() {
//        self.showLoadingIndicator(text: "正在获取邀请码")
//        InviteManager.shared.fetchAndGeneratorInviteCode().subscribe(onNext: { [weak self] (_, _) in
//            self?.hiddenLoadingIndicator()
//            let controller = InviteCodeVC()
//            self?.present(BaseNavigationController(rootViewController: controller), animated: true, completion: nil)
//        }, onError: { (error) in
//            SLog.error("fetchAndGeneratorInviteCode error:\(error)")
//            self.catchError(error: error)
//        }).disposed(by: self.disposeBag)
    }
    
    func payForProduct(code: String) {
        self.showLoadingIndicator(text: "正在生成订单")
        MarketManager.shared.fetchProductForCode(code: code).flatMap { (product) -> Observable<(String, SKPaymentTransactionState)> in
            DispatchQueue.main.async {
                self.showLoadingIndicator(text: "正在生成订单", afterDelay: 60)
            }
            return MarketManager.shared.payFor(product: product)
        }.subscribe(onNext: { [weak self] (productID, state) in
            if state == .purchasing {
                self?.showLoadingIndicator(text: "正在生成订单", afterDelay: 2)
            } else if state == .deferred {
                self?.showLoadingIndicator(text: "正在进行支付，请稍后", afterDelay: 5)
            } else if state == .purchased  {
                self?.showAlertView(title: "恭喜你，已经将您的账号升级为\(MarketManager.shared.currentLevel.label)")
            } else if state == .restored {
                self?.showAlertView(title: "您已经购买过此产品，已经将您的账号恢复为\(MarketManager.shared.currentLevel.label)，无需再次支付。")
            }
            self?.refreshUI()
            SLog.info("MarketManager.shared.payForCode inProgree:\(state)")
        }, onError: { [weak self] (error) in
            self?.refreshUI()
            self?.catchError(error: error)
        }, onCompleted: { [weak self] in
            self?.refreshUI()
            self?.showTipsView(text: "购买成功")
        }).disposed(by: self.disposeBag)
    }
    
    @objc func onCloseButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onRecoverButtonTapped() {
        self.showLoadingIndicator(text: "正在与Apple服务进行通讯", afterDelay: 60)
        MarketManager.shared.recoverProducts().subscribe(onError: { [weak self] (error) in
            self?.refreshUI()
            self?.catchError(error: error)
        }, onCompleted: { [weak self] in
            self?.refreshUI()
            if MarketManager.shared.currentLevel == .free {
                self?.showAlertView(title: "恢复完成,您还未购买任何服务")
            } else {
                self?.showAlertView(title: "恢复完成，已经将您的账号升级为\(MarketManager.shared.currentLevel.label)")
            }
        }).disposed(by: self.disposeBag)
    }
    
    
}


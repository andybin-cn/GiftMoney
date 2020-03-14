//
//  MineViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import MessageUI
import Social
import Common
//import StoreKit

class MineViewController: BaseViewController, UIDocumentPickerDelegate {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let desc4 = MineDescriptionRow(text: "邀请好友下载App，解锁【钻石VIP】会员资格")
    let inviteCodeRow = MineTextRow(title: "填写邀请码", image: UIImage(named: "icons8-invite"))
    let share = MineTextRow(title: "分享给好友", image: UIImage(named: "icons8-share"))
    
    let desc5 = MineDescriptionRow(text: "您的意见对我们很重要，非常期待您的反馈")
    let praiseRow = MineTextRow(title: "给个好评吧", image: UIImage(named: "icons8-trust"))
    let feedBack = MineTextRow(title: "意见反馈", image: UIImage(named: "icons8-feedback"))
    let aboutUs = MineTextRow(title: "关于我们", image: UIImage(named: "icons8-about"))
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dynamicTitle: String {
        switch MarketManager.shared.currentLevel {
        case .free:
            return "普通用户（升级VIP体验更多功能）"
        case .paid1:
            return "黄金VIP用户"
        case .paid2:
            return "钻石Vip用户"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = dynamicTitle
        
        scrollView.apply { (scrollView) in
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            scrollView.backgroundColor = UIColor.appGrayBackground
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
            stackView.spacing = 0.5
            stackView.addTo(scrollView) { (make) in
                make.top.equalTo(20)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40).priority(ConstraintPriority.low)
            }
        }
        
        inviteCodeRow.subLabel.text = InviteManager.shared.usedCode
        
        stackView.addArrangedSubview(AccountHeader(mode: .home, viewController: self))
        stackView.addArrangedSubview(desc4)
        stackView.addArrangedSubview(inviteCodeRow)
        stackView.addArrangedSubview(share)
        
        stackView.addArrangedSubview(desc5)
        stackView.addArrangedSubview(praiseRow)
        stackView.addArrangedSubview(feedBack)
        stackView.addArrangedSubview(aboutUs)
        
        addEvents()
        
        #if DEBUG
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "测试", style: .done, target: self, action: #selector(onTestButtonTapped))
        #endif
    }
    
    @objc func onTestButtonTapped() {
//        let controller = UIViewController()
//        controller.view.addSubview(SpeechButtonView()) { (make) in
//            make.left.right.bottom.equalToSuperview()
//        }
//        navigationController?.pushViewController(controller, animated: true)
//        self.feedBackError()
        MainTabViewController.shared.present(SpeechHelpVC(), animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = dynamicTitle
        inviteCodeRow.subLabel.text = InviteManager.shared.usedCode
    }
    
    func addEvents() {
        inviteCodeRow.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            MobClick.event("inviteCodeButtonTapped")
            if InviteManager.shared.hasUsedCode {
                self?.showTipsView(text: "您已经填写过邀请码了，无法进行修改")
               return
            }
            let controller = FillInviteCodeVC()
            self?.navigationController?.pushViewController(controller, animated: true)
        }).disposed(by: disposeBag)
        
        share.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            MobClick.event("shareButtonTapped")
            self.showLoadingIndicator(text: "正在获取邀请码")
            InviteManager.shared.fetchAndGeneratorInviteCode().subscribe(onNext: { [weak self] (_, _) in
                self?.hiddenLoadingIndicator()
                let controller = InviteCodeVC()
                self?.navigationController?.pushViewController(controller, animated: true)
            }, onError: { (error) in
                SLog.error("fetchAndGeneratorInviteCode error:\(error)")
                self.catchError(error: error)
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        praiseRow.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            MobClick.event("praiseButtonTapped")
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1478354248?action=write-review") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.showTipsView(text: "无法打开链接")
            }
        }).disposed(by: disposeBag)
        
        feedBack.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            MobClick.event("feedBackButtonTapped")
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setToRecipients(["reciprocityApp@163.com"])
            mailComposerVC.setSubject("【礼金小助手App】意见反馈")
            mailComposerVC.setMessageBody("\n\n感谢您的宝贵意见，我们会尽快给您回复。谢谢！", isHTML: false)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
            } else {
                self.showAlertView(title: "无法打开邮件，您可以发送邮件至 reciprocityApp@163.com 我们会尽快给您回复!", message: nil, actions: [
                    UIAlertAction(title: "取消", style: .cancel, handler: nil),
                    UIAlertAction(title: "复制邮箱地址", style: .destructive, handler: { (_) in
                        UIPasteboard.general.string = "reciprocityApp@163.com"
                        self.showTipsView(text: "邮箱地址已经复制到剪切板")
                    })
                ])
            }
        }).disposed(by: disposeBag)
        
        
        aboutUs.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            MobClick.event("aboutUsButtonTapped")
            self?.navigationController?.pushViewController(AboutUsVC(), animated: true)
        }).disposed(by: disposeBag)
    }

}

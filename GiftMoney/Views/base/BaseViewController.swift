//
//  BaseViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common
import RxSwift
import CloudKit
import MessageUI

class BaseViewController: UIViewController {
    var navigationBar: UIView
    var titleLabel: UILabel
    let disposeBag: DisposeBag = DisposeBag()
    
//    override var title: String? {
//        didSet {
//            titleLabel.text = title
//        }
//    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        navigationBar = UIView(frame: CGRect.zero)
        titleLabel = UILabel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
//        self.extendedLayoutIncludesOpaqueBars = false
//        if #available(iOS 11.0, *) {
//
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("\(type(of: self)) released!")
        for i in 0...100 {
            Log.info("\(i)")
            Log.info("SpeechManager.shared.peakPower.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [unownedSpeechManager.shared.peakPower.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [unowned")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //        if let delegate = self as? UIGestureRecognizerDelegate {
        //            self.navigationController?.interactivePopGestureRecognizer?.delegate = delegate
        //        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("\(type(of: self))")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("\(type(of: self))")
    }
}


extension UIViewController: MFMailComposeViewControllerDelegate {
    func catchError(error: Error) {
        if let error = error as? CommonError {
            self.showTipsView(text: error.message)
        } else if let error = error as? AuthorizationError {
            self.showAlertView(title: error.localizedDescription, message: nil, actions: [
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                UIAlertAction(title: "前往设置", style: .destructive, handler: { (_) in
                    DeviceSupport.default.openSystemSetting()
                })
            ])
        } else {
            Log.error("\(error)")
            self.showAlertView(title: "App遇到了无法解决的错误", message: "您可以进行多次尝试，如无法解决问题。请将问题反馈给我们，我们会尽快为您解决！", actions: [
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                UIAlertAction(title: "反馈问题", style: .destructive, handler: { (_) in
                    self.feedBackError()
                })
            ])
        }
    }
    
    private func addAttachmentErrorLogData(mailComposerVC: MFMailComposeViewController) {
        DispatchQueue.global().async {
            Log.logFileURLs.enumerated().forEach({ (index, url) in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        mailComposerVC.addAttachmentData(data, mimeType: "text/plain", fileName: "错误日志-\(url.lastPathComponent)")
                    }
                }
                
            })
        }
    }
    
    func feedBackError() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["reciprocityApp@163.com"])
        mailComposerVC.setSubject("【礼金小助手App】错误反馈")
        mailComposerVC.setMessageBody("\n\n请提供尽量详细的错误信息，如截图，视频等\n\n感谢您的反馈，我们会尽快为您解决。谢谢！", isHTML: false)
        addAttachmentErrorLogData(mailComposerVC: mailComposerVC)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showAlertView(title: "无法打开邮件，您可以手动发送邮件至 reciprocityApp@163.com !", message: "分享错误信息给我们可以加快问题的解决速度！", actions: [
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                UIAlertAction(title: "分享错误信息", style: .destructive, handler: { (_) in
                    UIPasteboard.general.string = "reciprocityApp@163.com"
                    if let url = Log.logFileURLs.first {
                        let controler = TempExcelPreviewVC(url: url, titleStr: "分享错误日志")
                        self.present(controler, animated: true, completion: nil)
                        controler.showTipsView(text: "邮箱地址已经复制到剪切板")
                    } else {
                        self.showTipsView(text: "邮箱地址已经复制到剪切板")
                    }
                })
            ])
        }
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

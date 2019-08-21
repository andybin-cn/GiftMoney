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

class MineViewController: BaseViewController, MFMailComposeViewControllerDelegate, UIDocumentPickerDelegate {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let importiAndExport = MineTextRow(title: "Excel导入/导出", image: UIImage(named: "icons8-ms_excel"))
    let desc1 = MineDescriptionRow(text: "购买服务，永久解锁Excel导入/导出功能。")
    let backupData = MineTextRow(title: "备份数据到Apple Cloud", image: UIImage(named: "icons8-cloud_database"))
    let recoverData = MineTextRow(title: "从Apple Cloud恢复数据", image: UIImage(named: "icons8-data_recovery"))
    let desc2 = MineDescriptionRow(text: "购买服务，永久备份和恢复功能。此功能不会收集用户的任何数据，备份功能会将数据保存至iCloud上，请放心使用！")
    
    let faceID: MineSwitchRow
    let share = MineTextRow(title: "分享给好友", image: UIImage(named: "icons8-share"))
    let feedBack = MineTextRow(title: "意见反馈", image: UIImage(named: "icons8-feedback"))
    
    init() {
        let biometryString = LocalAuthManager.shared.biometryType == .faceID ? "FaceID解锁" : "指纹解锁"
        faceID = MineSwitchRow(title: biometryString, image: UIImage(named: "icons8-lock2"))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "普通用户（升级VIP体验更多功能）"
        
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
        stackView.addArrangedSubview(importiAndExport)
        stackView.addArrangedSubview(desc1)
        stackView.addArrangedSubview(backupData)
        stackView.addArrangedSubview(recoverData)
        stackView.addArrangedSubview(desc2)
        stackView.addArrangedSubview(faceID)
        stackView.addArrangedSubview(share)
        stackView.addArrangedSubview(feedBack)
        
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
        
        addEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
    }
    
    func addEvents() {
        importiAndExport.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            
//            if MaketManager.shared.currentLevel == .free {
//                let controller = MarketVC()
//                MainTabViewController.shared.present(controller, animated: true, completion: nil)
//            }
            self.showActionSheetView(title: "选择", actions: [
                UIAlertAction(title: "导出Excel数据", style: .default, handler: { (_) in
                    self.exportXLSX()
                }),
                UIAlertAction(title: "从Excel导入数据", style: .default, handler: { (_) in
                    self.importDdataFromExcel()
                })
            ])
        }).disposed(by: disposeBag)
        
        faceID.switcher.rx.isOn.asObservable().subscribe(onNext: { [unowned self] (isOn) in
            if isOn {
                if !LocalAuthManager.shared.localAuthAvailability {
                    self.faceID.switcher.isOn = false
                } else if !LocalAuthManager.shared.localAuthEnabled {
                    MainTabViewController.shared.showLocalAuthView(viewMode: .open)
                }
            } else if LocalAuthManager.shared.localAuthEnabled {
                MainTabViewController.shared.showLocalAuthView(viewMode: .close)
            }
        }).disposed(by: disposeBag)
        
        share.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            let controller = UIActivityViewController(activityItems: [URL(string: "http://www.baidu.com")!], applicationActivities: nil)
            self.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        feedBack.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setToRecipients(["810018715@qq.com"])
            mailComposerVC.setSubject("【礼尚往来App】意见反馈")
            mailComposerVC.setMessageBody("\n\n感谢您的宝贵意见，我们会尽快给您回复。谢谢！", isHTML: false)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposerVC, animated: true, completion: nil)
            } else {
                
            }
        }).disposed(by: disposeBag)
        
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func exportXLSX() {
        self.showLoadingIndicator()
        let url = NSTemporaryDirectory() + "\(NSUUID().uuidString).xlsx"
        XLSXManager.shared.exportXLSX(fileUrl: URL(fileURLWithPath: url)).subscribe(onNext: { [unowned self] (url) in
            self.hiddenLoadingIndicator()
            self.present(TempExcelPreviewVC(url: url), animated: true, completion: nil)
        }, onError: { [unowned self] (error) in
            self.showTipsView(text: error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    func importDdataFromExcel() {
//        let documentTypes = ["public.content",
//                            "public.text",
//                            "public.source-code",
//                            "public.image",
//                            "public.audiovisual-content",
//                            "com.adobe.pdf",
//                            "com.apple.keynote.key",
//                            "com.microsoft.word.doc",
//                            "com.microsoft.excel.xls",
//                            "com.microsoft.powerpoint.ppt"
//        ]
        let controller = UIDocumentPickerViewController(documentTypes: ["com.microsoft.excel.xls"], in: UIDocumentPickerMode.open)
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - UIDocumentPickerDelegate
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        self.showLoadingIndicator()
        XLSXManager.shared.importFromXLSX(url: url).subscribe(onNext: { (count) in
            self.showAlertView(title: "一共导入了\(count)条数据")
        }, onError: { (error) in
            self.showTipsView(text: error.localizedDescription)
        }).disposed(by: disposeBag)
    }

}

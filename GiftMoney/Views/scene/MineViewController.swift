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
    let documentTypes = ["public.item", "public.content", "public.composite-content", "public.message", "public.contact", "public.archive", "public.disk-image", "public.data", "public.directory", "com.apple.resolvable", "public.symlink", "public.executable", "com.apple.mount-point", "com.apple.alias-file", "com.apple.alias-record", "com.apple.bookmark", "public.url", "public.file-url", "public.text", "public.plain-text", "public.utf8-plain-text", "public.utf16-external-plain-text", "public.utf16-plain-text", "public.delimited-values-text", "public.comma-separated-values-text", "public.tab-separated-values-text", "public.utf8-tab-separated-values-text", "public.rtf", "public.html", "public.xml", "public.source-code", "public.assembly-source", "public.c-source", "public.objective-c-source", "public.swift-source", "public.c-plus-plus-source", "public.objective-c-plus-plus-source", "public.c-header", "public.c-plus-plus-header", "com.sun.java-source", "public.script", "com.apple.applescript.text", "com.apple.applescript.script", "com.apple.applescript.script-bundle", "com.netscape.javascript-source", "public.shell-script", "public.perl-script", "public.python-script", "public.ruby-script", "public.php-script", "public.json", "com.apple.property-list", "com.apple.xml-property-list", "com.apple.binary-property-list", "com.adobe.pdf", "com.apple.rtfd", "com.apple.flat-rtfd", "com.apple.txn.text-multimedia-data", "com.apple.webarchive", "public.image", "public.jpeg", "public.jpeg-2000", "public.tiff", "com.apple.pict", "com.compuserve.gif", "public.png", "com.apple.quicktime-image", "com.apple.icns", "com.microsoft.bmp", "com.microsoft.ico", "public.camera-raw-image", "public.svg-image", "com.apple.live-photo", "public.audiovisual-content", "public.movie", "public.video", "public.audio", "com.apple.quicktime-movie", "public.mpeg", "public.mpeg-2-video", "public.mpeg-2-transport-stream", "public.mp3", "public.mpeg-4", "public.mpeg-4-audio", "com.apple.protected-mpeg-4-audio", "com.apple.protected-mpeg-4-video", "public.avi", "public.aiff-audio", "com.microsoft.waveform-audio", "public.midi-audio", "public.playlist", "public.m3u-playlist", "public.folder", "public.volume", "com.apple.package", "com.apple.bundle", "com.apple.plugin", "com.apple.metadata-importer", "com.apple.quicklook-generator", "com.apple.xpc-service", "com.apple.framework", "com.apple.application", "com.apple.application-bundle", "com.apple.application-file", "public.unix-executable", "com.microsoft.windows-executable", "com.sun.java-class", "com.sun.java-archive", "com.apple.systempreference.prefpane", "org.gnu.gnu-zip-archive", "public.bzip2-archive", "public.zip-archive", "public.spreadsheet", "public.presentation", "public.database", "public.vcard", "public.to-do-item", "public.calendar-event", "public.email-message", "com.apple.internet-location", "com.apple.ink.inktext", "public.font", "public.bookmark", "public.3d-content", "com.rsa.pkcs-12", "public.x509-certificate", "org.idpf.epub-container", "public.log", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.excel.xlsx", "com.microsoft.powerpoint.ppt"]
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let excelImportAndExport = MineTextRow(title: "Excel导入/导出", image: UIImage(named: "icons8-ms_excel"))
    let imageImportAndExport = MineTextRow(title: "图片、视频导入/导出", image: UIImage(named: "icons8-image"))
    let desc1 = MineDescriptionRow(text: "购买服务，永久解锁数据导入/导出功能。")
    let backupData = MineTextRow(title: "备份数据到Apple Cloud", image: UIImage(named: "icons8-cloud_database"))
    let recoverData = MineTextRow(title: "从Apple Cloud恢复数据", image: UIImage(named: "icons8-data_recovery"))
    let desc2 = MineDescriptionRow(text: "购买服务，永久备份和恢复功能。此功能不会收集用户的任何数据，备份功能会将数据保存至iCloud上，请放心使用！")
    
    let faceID: MineSwitchRow
    let share = MineTextRow(title: "分享给好友", image: UIImage(named: "icons8-share"))
    let feedBack = MineTextRow(title: "意见反馈", image: UIImage(named: "icons8-feedback"))
    let aboutUs = MineTextRow(title: "关于我们", image: UIImage(named: "icons8-about"))
    
    init() {
        let biometryString = LocalAuthManager.shared.biometryType == .faceID ? "FaceID解锁" : "指纹解锁"
        faceID = MineSwitchRow(title: biometryString, image: UIImage(named: "icons8-lock2"))
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
            return "白银Vip"
        case .paid2:
            return "黄金Vip"
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
        stackView.addArrangedSubview(excelImportAndExport)
        stackView.addArrangedSubview(imageImportAndExport)
        stackView.addArrangedSubview(desc1)
        stackView.addArrangedSubview(backupData)
        stackView.addArrangedSubview(recoverData)
        stackView.addArrangedSubview(desc2)
        stackView.addArrangedSubview(faceID)
        stackView.addArrangedSubview(share)
        stackView.addArrangedSubview(feedBack)
        stackView.addArrangedSubview(aboutUs)
        
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
        
        addEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.title = dynamicTitle
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
    }
    
    func addEvents() {
        excelImportAndExport.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            guard MarketManager.shared.checkAuth(type: .exportAndImport, controller: MainTabViewController.shared) else {
                return
            }
            self.showActionSheetView(title: "选择", actions: [
                UIAlertAction(title: "导出Excel数据", style: .default, handler: { (_) in
                    self.exportXLSX()
                }),
                UIAlertAction(title: "从Excel导入数据", style: .default, handler: { (_) in
                    self.importDataFromExcel()
                })
            ])
        }).disposed(by: disposeBag)
        
        imageImportAndExport.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            guard MarketManager.shared.checkAuth(type: .exportAndImport, controller: MainTabViewController.shared) else {
                return
            }
            self.showActionSheetView(title: "选择", actions: [
                UIAlertAction(title: "导出图片和视频(.zip文件)", style: .default, handler: { (_) in
                    self.exportImages()
                }),
                UIAlertAction(title: "导入图片和视频(.zip文件)", style: .default, handler: { (_) in
                    self.importImagesFromZip()
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
        
        backupData.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            guard MarketManager.shared.checkAuth(type: .backupAndRecover, controller: MainTabViewController.shared) else {
                return
            }
            self?.backupTradesToCloud()
        }).disposed(by: disposeBag)
        
        share.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            self.showLoadingIndicator(text: "正在获取邀请码")
            InviteManager.shared.fetchAndGeneratorInviteCode().subscribe(onNext: { [weak self] (_, _) in
                self?.hiddenLoadingIndicator()
                let controller = InviteCodeVC()
                self?.navigationController?.pushViewController(controller, animated: true)
            }, onError: { (error) in
                self.showLoadingIndicator(text: error.localizedDescription)
            }).disposed(by: self.disposeBag)
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
                self.showAlertView(title: "无法打开邮件，您可以发送邮件至 810018715@qq.com 我们会尽快给您回复!", message: nil, actions: [
                    UIAlertAction(title: "取消", style: .cancel, handler: nil),
                    UIAlertAction(title: "复制邮箱地址", style: .destructive, handler: { (_) in
                        UIPasteboard.general.string = "810018715@qq.com"
                        self.showTipsView(text: "邮箱地址已经复制的剪切板")
                    })
                ])
            }
        }).disposed(by: disposeBag)
        
        
        aboutUs.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            self?.navigationController?.pushViewController(AboutUsVC(), animated: true)
        }).disposed(by: disposeBag)
    }
    
    func backupTradesToCloud() {
        self.showLoadingIndicator()
        CloudManager.shared.backupTrades().subscribe(onNext: { (progress) in
            SLog.info("backupTrades progress:\(progress.finishCount)/\(progress.totoalCount)")
        }, onError: { (error) in
            self.showTipsView(text: "备份失败")
            SLog.error(error.localizedDescription)
        }, onCompleted: {
            self.showTipsView(text: "备份完成")
        }).disposed(by: disposeBag)
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func exportXLSX() {
        self.showLoadingIndicator()
        XLSXManager.shared.exportXLSX().subscribe(onNext: { [unowned self] (url) in
            self.hiddenLoadingIndicator()
            self.present(TempExcelPreviewVC(url: url), animated: true, completion: nil)
        }, onError: { [unowned self] (error) in
            self.showTipsView(text: error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    
    func importDataFromExcel() {
        let controller = UIDocumentPickerViewController(documentTypes: documentTypes, in: UIDocumentPickerMode.import)
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func exportImages() {
        self.showLoadingIndicator()
        ImagesManager.shared.exportImages().subscribe(onNext: { [unowned self] (url) in
            self.hiddenLoadingIndicator()
            self.present(TempExcelPreviewVC(url: url), animated: true, completion: nil)
        }, onError: { [unowned self] (error) in
            self.showTipsView(text: error.localizedDescription)
        }).disposed(by: disposeBag)
    }
    weak var pickerZipController: UIDocumentPickerViewController?
    func importImagesFromZip() {
        let controller = UIDocumentPickerViewController(documentTypes: documentTypes, in: UIDocumentPickerMode.import)
        controller.delegate = self
        pickerZipController = controller
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
        if pickerZipController == controller {
            self.showLoadingIndicator()
            ImagesManager.shared.importFromZip(url: url).subscribe(onNext: { (count) in
                self.showAlertView(title: "一共导入了\(count)个图片和视频")
            }, onError: { (error) in
                self.showTipsView(text: error.localizedDescription)
            }).disposed(by: disposeBag)
        } else {
            self.showLoadingIndicator()
            XLSXManager.shared.importFromXLSX(url: url).subscribe(onNext: { (count) in
                self.showAlertView(title: "一共导入了\(count)条数据")
            }, onError: { (error) in
                self.showTipsView(text: error.localizedDescription)
            }).disposed(by: disposeBag)
        }
    }

}

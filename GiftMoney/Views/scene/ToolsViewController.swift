//
//  ToolsViewController.swift
//  GiftMoney
//
//  Created by binea on 2020/3/7.
//  Copyright © 2020 binea. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import MessageUI
import Social
import Common
import StoreKit
import GoogleMobileAds

class ToolsViewController: BaseViewController, UIDocumentPickerDelegate, GADBannerViewDelegate {
    let documentTypes = ["public.item", "public.content", "public.composite-content", "public.message", "public.contact", "public.archive", "public.disk-image", "public.data", "public.directory", "com.apple.resolvable", "public.symlink", "public.executable", "com.apple.mount-point", "com.apple.alias-file", "com.apple.alias-record", "com.apple.bookmark", "public.url", "public.file-url", "public.text", "public.plain-text", "public.utf8-plain-text", "public.utf16-external-plain-text", "public.utf16-plain-text", "public.delimited-values-text", "public.comma-separated-values-text", "public.tab-separated-values-text", "public.utf8-tab-separated-values-text", "public.rtf", "public.html", "public.xml", "public.source-code", "public.assembly-source", "public.c-source", "public.objective-c-source", "public.swift-source", "public.c-plus-plus-source", "public.objective-c-plus-plus-source", "public.c-header", "public.c-plus-plus-header", "com.sun.java-source", "public.script", "com.apple.applescript.text", "com.apple.applescript.script", "com.apple.applescript.script-bundle", "com.netscape.javascript-source", "public.shell-script", "public.perl-script", "public.python-script", "public.ruby-script", "public.php-script", "public.json", "com.apple.property-list", "com.apple.xml-property-list", "com.apple.binary-property-list", "com.adobe.pdf", "com.apple.rtfd", "com.apple.flat-rtfd", "com.apple.txn.text-multimedia-data", "com.apple.webarchive", "public.image", "public.jpeg", "public.jpeg-2000", "public.tiff", "com.apple.pict", "com.compuserve.gif", "public.png", "com.apple.quicktime-image", "com.apple.icns", "com.microsoft.bmp", "com.microsoft.ico", "public.camera-raw-image", "public.svg-image", "com.apple.live-photo", "public.audiovisual-content", "public.movie", "public.video", "public.audio", "com.apple.quicktime-movie", "public.mpeg", "public.mpeg-2-video", "public.mpeg-2-transport-stream", "public.mp3", "public.mpeg-4", "public.mpeg-4-audio", "com.apple.protected-mpeg-4-audio", "com.apple.protected-mpeg-4-video", "public.avi", "public.aiff-audio", "com.microsoft.waveform-audio", "public.midi-audio", "public.playlist", "public.m3u-playlist", "public.folder", "public.volume", "com.apple.package", "com.apple.bundle", "com.apple.plugin", "com.apple.metadata-importer", "com.apple.quicklook-generator", "com.apple.xpc-service", "com.apple.framework", "com.apple.application", "com.apple.application-bundle", "com.apple.application-file", "public.unix-executable", "com.microsoft.windows-executable", "com.sun.java-class", "com.sun.java-archive", "com.apple.systempreference.prefpane", "org.gnu.gnu-zip-archive", "public.bzip2-archive", "public.zip-archive", "public.spreadsheet", "public.presentation", "public.database", "public.vcard", "public.to-do-item", "public.calendar-event", "public.email-message", "com.apple.internet-location", "com.apple.ink.inktext", "public.font", "public.bookmark", "public.3d-content", "com.rsa.pkcs-12", "public.x509-certificate", "org.idpf.epub-container", "public.log", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.excel.xlsx", "com.microsoft.powerpoint.ppt"]
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    let aboutScoreRow = MineTextRow(title: "关于活跃积分的说明", image: UIImage(named: "icons8-fire_element"))
    let helpRow = MineTextRow(title: "使用帮助", image: UIImage(named: "icons8-help"))
    let excelImportAndExport = MineTextRow(title: "Excel导入/导出", image: UIImage(named: "icons8-ms_excel"))
    let imageImportAndExport = MineTextRow(title: "图片、视频导入/导出", image: UIImage(named: "icons8-image"))
    let desc1 = MineDescriptionRow(text: "购买服务，永久解锁数据导入/导出功能。")
    let autoSyncToiCloudRow = MineSwitchRow(title: "自动同步数据至iCloud", image: UIImage(named: "icons8-cloud_refresh"))
    let recoverAndBackupData = MineTextRow(title: "手动从iCloud备份/恢复数据", image: UIImage(named: "icons8-data_recovery"))
    let desc2 = MineDescriptionRow(text: "购买服务，永久备份和恢复功能。此功能不会收集用户的任何数据，备份功能会将数据保存至iCloud上，请放心使用！")
    let desc3 = MineDescriptionRow(text: "隐私安全")
    let faceID: MineSwitchRow
    
//    let desc4 = MineDescriptionRow(text: "邀请好友下载App，解锁【钻石VIP】会员资格")
//    let inviteCodeRow = MineTextRow(title: "填写邀请码", image: UIImage(named: "icons8-invite"))
//    let share = MineTextRow(title: "分享给好友", image: UIImage(named: "icons8-share"))
//
//    let desc5 = MineDescriptionRow(text: "您的意见对我们很重要，非常期待您的反馈")
//    let praiseRow = MineTextRow(title: "给个好评吧", image: UIImage(named: "icons8-trust"))
//    let feedBack = MineTextRow(title: "意见反馈", image: UIImage(named: "icons8-feedback"))
//    let aboutUs = MineTextRow(title: "关于我们", image: UIImage(named: "icons8-about"))
    
    init() {
        let biometryString = LocalAuthManager.shared.biometryType == .faceID ? "FaceID解锁" : "指纹解锁"
        faceID = MineSwitchRow(title: biometryString, image: UIImage(named: "icons8-lock2"))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dynamicTitle: String {
        return "小工具"
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
                make.bottom.equalToSuperview().offset(-100).priority(ConstraintPriority.low)
            }
        }
        
        stackView.addArrangedSubview(AccountHeader(mode: .home, viewController: self))
        stackView.addArrangedSubview(aboutScoreRow)
        stackView.addArrangedSubview(helpRow)
        stackView.addArrangedSubview(desc1)
        stackView.addArrangedSubview(excelImportAndExport)
        stackView.addArrangedSubview(imageImportAndExport)
        
        stackView.addArrangedSubview(desc2)
        stackView.addArrangedSubview(autoSyncToiCloudRow)
        stackView.addArrangedSubview(recoverAndBackupData)
        
        stackView.addArrangedSubview(desc3)
        stackView.addArrangedSubview(faceID)
        
        autoSyncToiCloudRow.switcher.isOn = AccountManager.shared.autoSyncToiCloudEnable
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
        
        addEvents()
        
        #if DEBUG
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "测试", style: .done, target: self, action: #selector(onTestButtonTapped))
        #endif
        
        setupBannerAdvert()
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
        autoSyncToiCloudRow.switcher.isOn = AccountManager.shared.autoSyncToiCloudEnable
        faceID.switcher.isOn = LocalAuthManager.shared.localAuthEnabled
    }
    
    func addEvents() {
        aboutScoreRow.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { (_) in
            MobClick.event("aboutScoreRowTapped")
            let controller = MarketVC(superVC: MainTabViewController.shared)
            MainTabViewController.shared.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        helpRow.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { (_) in
            MobClick.event("helpRowTapped")
            let controller = SpeechHelpVC()
            MainTabViewController.shared.present(controller, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        excelImportAndExport.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            MobClick.event("excelImportAndExportTapped")
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
            MobClick.event("imageImportAndExport")
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
        
        autoSyncToiCloudRow.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] (_) in
            let isOn = self.autoSyncToiCloudRow.switcher.isOn
            MobClick.event("AutomaticSyncToiCloud")
            guard MarketManager.shared.checkAuth(type: .autoSyncToiCloud, controller: MainTabViewController.shared) else {
                self.autoSyncToiCloudRow.switcher.isOn = false
                return
            }
            AccountManager.shared.autoSyncToiCloudEnable = isOn
        }).disposed(by: disposeBag)
        
        recoverAndBackupData.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            MobClick.event("recoverDataFromiCloud")
            guard MarketManager.shared.checkAuth(type: .backupAndRecover, controller: MainTabViewController.shared) else {
                return
            }
            self?.showActionSheetView(title: "iCloud备份和恢复", actions: [
                UIAlertAction(title: "备份数据", style: .default, handler: { (_) in
                    self?.backupTradesToCloud()
                }),
                UIAlertAction(title: "恢复数据", style: .default, handler: { (_) in
                    self?.recoverTradesFromCloud()
                })
            ])
        }).disposed(by: disposeBag)
        
        faceID.switcher.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self] (_) in
            let isOn = self.faceID.switcher.isOn
            if isOn {
                if !LocalAuthManager.shared.localAuthAvailability {
                    self.faceID.switcher.isOn = false
                } else if !LocalAuthManager.shared.localAuthEnabled {
                    MainTabViewController.shared.showLocalAuthView(viewMode: .open)
                }
            } else if LocalAuthManager.shared.localAuthAvailability && LocalAuthManager.shared.localAuthEnabled {
                MainTabViewController.shared.showLocalAuthView(viewMode: .close)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func backupTradesToCloud() {
        self.showLoadingIndicator(text: "正在备份数据")
        CloudManager.shared.backupTrades().subscribe(onNext: { (progress) in
            self.showLoadingIndicator(text: "已备份\(progress.finishCount)条数据，共\(progress.totoalCount)条")
            SLog.info("backupTrades progress:\(progress.finishCount)/\(progress.totoalCount)")
        }, onError: { (error) in
            self.showTipsView(text: "备份失败")
            SLog.error(error.localizedDescription)
        }, onCompleted: {
            self.showTipsView(text: "备份完成")
        }).disposed(by: disposeBag)
    }
    
    func recoverTradesFromCloud() {
        self.showLoadingIndicator()
        var tempProgress: CloudSyncProgress?
        CloudManager.shared.recoverTrades().subscribe(onNext: { (progress) in
            tempProgress = progress
            self.showLoadingIndicator(text: "已恢复\(progress.finishCount)条数据")
            SLog.info("recoverTradesFromCloud progress:\(progress.finishCount)/\(progress.totoalCount)")
        }, onError: { (error) in
            self.catchError(error: error)
            SLog.error(error.localizedDescription)
        }, onCompleted: {
            if let progress = tempProgress {
                self.showAlertView(title: "一共恢复了\(progress.finishCount)条数据，跳过了\(progress.totoalCount - progress.finishCount)条数据")
            } else {
                self.showTipsView(text: "已经是最新的数据了")
            }
        }).disposed(by: disposeBag)
    }
    
    func exportXLSX() {
        self.showLoadingIndicator()
        XLSXManager.shared.exportXLSX().subscribe(onNext: { [unowned self] (url) in
            self.hiddenLoadingIndicator()
            self.present(TempExcelPreviewVC(url: url), animated: true, completion: nil)
        }, onError: { [unowned self] (error) in
            self.catchError(error: error)
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
            self.catchError(error: error)
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
                self.catchError(error: error)
            }).disposed(by: disposeBag)
        } else {
            self.showLoadingIndicator()
            XLSXManager.shared.importFromXLSX(url: url).subscribe(onNext: { (count) in
                self.showAlertView(title: "一共导入了\(count)条数据")
            }, onError: { (error) in
                self.catchError(error: error)
            }).disposed(by: disposeBag)
        }
    }

    //MARK: - GADBannerView
    var bannerView: GADBannerView!
    func setupBannerAdvert() {
        if MarketManager.shared.currentLevel != .free {
            return
        }
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        bannerView.addTo(self.view) { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-ScreenHelp.tabBarHeight)
        }
        #if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        bannerView.adUnitID = "ca-app-pub-3156075797045250/2998326874"
        #endif
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    //MARK: - GADBannerViewDelegate
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }

}

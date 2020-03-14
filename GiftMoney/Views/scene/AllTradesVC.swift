//
//  AllTradesVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/13.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class AllTradesVC: BaseViewController, GADBannerViewDelegate {
    let tabbar = UIView()
    let segmented = UISegmentedControl(items: ["送出的", "收到的"])
    let containerView = UIView()
//    let inAccountVC = InAccountTradeVC()
    let outAccountVC = OutAccountTradeVC()
    let inAccountGroupVC = InAccountEventGroupVC()
    var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIButton().apply { (button) in
//            button.addTarget(self, action: #selector(addRecordButtonTapped), for: .touchUpInside)
//            button.setTitle("新增", for: .normal)
//            button.setTitleColor(UIColor.appSecondaryYellow, for: .normal)
//            let addRecordButton = UIBarButtonItem(customView: button)
//            self.navigationItem.rightBarButtonItems = [addRecordButton]
//        }
//        let searchButton = UIBarButtonItem(image: UIImage(named: "icons8-search"), style: .done, target: self, action: #selector(searchButtonTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        
        let addRecordButton = UIBarButtonItem(title: "新增", style: UIBarButtonItem.Style.plain, target: self, action: #selector(addRecordButtonTapped))
        self.navigationItem.rightBarButtonItems = [addRecordButton]
        
//        tabbar.apply { (tabbar) in
//            tabbar.snp.makeConstraints { (make) in
//                make.height.equalTo(44)
//                make.width.equalTo(ScreenHelp.windowWidth - 80)
//            }
////            tabbar.addTo(view) { (make) in
////                make.left.right.equalToSuperview()
////                make.height.equalTo(44)
////                make.top.equalTo(ScreenHelp.navBarHeight)
////            }
//        }
        
        segmented.selectedSegmentIndex = 0
        segmented.tintColor = .appSecondaryYellow
        segmented.addTarget(self, action: #selector(onSegmentedChanged), for: UIControl.Event.valueChanged)
        segmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainRed, NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 18)], for: .selected)
        segmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow, NSAttributedString.Key.font : UIFont.appFont(ofSize: 13)], for: .normal)
        if #available(iOS 13, *) {
            segmented.layer.borderColor = UIColor.appSecondaryYellow.cgColor
            segmented.layer.borderWidth = 1
            segmented.setBackgroundImage(UIColor.appSecondaryYellow.toImage(), for: .selected, barMetrics: .default)
            segmented.setBackgroundImage(UIColor.appMainRed.toImage(), for: .normal, barMetrics: .default)
        }
        segmented.apply { (segmented) in
            segmented.snp.makeConstraints { (make) in
                make.height.equalTo(35)
                make.width.equalTo(ScreenHelp.windowWidth / 2)
            }
//            segmented.addTo(tabbar) { (make) in
//                make.center.bottom.equalToSuperview()
//                make.height.equalTo(38)
//                make.width.equalToSuperview().inset(40)
//            }
        }
        
        self.navigationItem.titleView = segmented
        
        containerView.apply { (containerView) in
            containerView.addTo(view) { (make) in
//                make.left.right.bottom.equalToSuperview()
//                make.top.equalTo(tabbar.snp.bottom)
                make.edges.equalToSuperview()
            }
        }
        
        view.bringSubviewToFront(tabbar)
        
        onSegmentedChanged()
    }
    
    @objc func searchButtonTapped() {
        let controller = SearchTradeVC()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func addRecordButtonTapped() {
        let type = segmented.selectedSegmentIndex == 0 ? Trade.TradeType.outAccount :  Trade.TradeType.inAccount
        navigationController?.pushViewController(AddTradeViewController(tradeType: type, event: nil), animated: true)
    }
    
    @objc func onSegmentedChanged() {
        let newVC = segmented.selectedSegmentIndex == 0 ? outAccountVC : inAccountGroupVC
        if newVC == currentVC {
            return
        }
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        currentVC = newVC
        addChild(newVC)
        containerView.addSubview(newVC.view) { (make) in
            make.edges.equalToSuperview()
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
        containerView.snp.remakeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bannerView.snp.top)
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


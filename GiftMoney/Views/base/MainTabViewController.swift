//
//  MainTabViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class MainTabViewController: UITabBarController {
    static let shared: MainTabViewController = MainTabViewController()
    
    let inoutRecordsVC = AllTradesVC()
//    let statisticsVC = StatisticsViewController()
    let mineVC = MineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inoutRecordsVC.hidesBottomBarWhenPushed = false
//        statisticsVC.hidesBottomBarWhenPushed = false
        mineVC.hidesBottomBarWhenPushed = false
        
        let inoutRecordsNav = BaseNavigationController(rootViewController: inoutRecordsVC)
//        let statisticsNav = BaseNavigationController(rootViewController: statisticsVC)
        let mineNav = BaseNavigationController(rootViewController: mineVC)

        let barItem1 = UITabBarItem(title: "礼尚往来", image: UIImage(named: "icons8-wish_list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icons8-wish_list")?.ui_renderImage(tintColor: UIColor.appMainRed).withRenderingMode(.alwaysOriginal))
        barItem1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainRed], for: UIControl.State.selected)
        
        inoutRecordsNav.tabBarItem = barItem1

        
//        let statisticsNav = BaseNavigationController(rootViewController: statisticsVC)
//        let barItem2 = UITabBarItem(title: "统计", image: UIImage(named: "icons8-financial_analytics")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icons8-financial_analytics")?.ui_renderImage(tintColor: UIColor.appMainRed).withRenderingMode(.alwaysOriginal))
//        barItem2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainRed], for: UIControl.State.selected)
//        statisticsNav.tabBarItem = barItem2

        let barItem3 = UITabBarItem(title: "辅助功能", image: UIImage(named: "icons8-settings")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icons8-settings")?.ui_renderImage(tintColor: UIColor.appMainRed).withRenderingMode(.alwaysOriginal))
        barItem3.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainRed], for: UIControl.State.selected)
        
        mineNav.tabBarItem = barItem3

        self.viewControllers = [inoutRecordsNav, mineNav]
    }
    
    var localAuthVC: LocalAuthVC?
    func showLocalAuthView(viewMode: LocalAuthVC.ViewMode) {
        if localAuthVC == nil {
            let controller = LocalAuthVC(viewMode: viewMode)
            controller.viewMode = viewMode
            localAuthVC = controller
            self.view.addSubview(controller.view) { (make) in
                make.edges.equalToSuperview()
            }
            controller.authWithIPhone()
        }
    }
    
    func hideLocalAuthView() {
        localAuthVC?.view.removeFromSuperview()
        localAuthVC = nil
    }
}

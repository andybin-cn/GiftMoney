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
    let statisticsVC = StatisticsViewController()
    let mineVC = MineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        hidesBottomBarWhenPushed = true
        inoutRecordsVC.hidesBottomBarWhenPushed = false
        statisticsVC.hidesBottomBarWhenPushed = false
        mineVC.hidesBottomBarWhenPushed = false
        
        let inoutRecordsNav = BaseNavigationController(rootViewController: inoutRecordsVC)
        let statisticsNav = BaseNavigationController(rootViewController: statisticsVC)
        let mineNav = BaseNavigationController(rootViewController: mineVC)

        let barItem1 = UITabBarItem(title: "礼尚往来", image: UIImage(named: "icons8-wish_list")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icons8-wish_list")?.ui_renderImage(tintColor: UIColor.appMainYellow).withRenderingMode(.alwaysOriginal))
        barItem1.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainYellow], for: UIControl.State.selected)
        
        inoutRecordsNav.tabBarItem = barItem1

//        statisticsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.search, tag: 1)

        let barItem2 = UITabBarItem(title: "设置", image: UIImage(named: "icons8-settings")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icons8-settings")?.ui_renderImage(tintColor: UIColor.appMainYellow).withRenderingMode(.alwaysOriginal))
        barItem2.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainYellow], for: UIControl.State.selected)
        
        mineNav.tabBarItem = barItem2
//        UITabBarItem(title: "设置", image: UIImage(named: "icons8-settings"), selectedImage: UIImage(named: "icons8-settings")?.ui_renderImage(tintColor: UIColor.appMainYellow))

        self.viewControllers = [inoutRecordsNav, mineNav]
        
        
//        inoutRecordsVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 0)
//
//        statisticsVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.search, tag: 1)
//
//        mineVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.featured, tag: 2)
//
//        self.viewControllers = [inoutRecordsVC, statisticsVC, mineVC]
    }

}

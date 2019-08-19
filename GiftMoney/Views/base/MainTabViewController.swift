//
//  MainTabViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

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

        inoutRecordsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 0)

        statisticsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.search, tag: 1)

        mineNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.featured, tag: 2)

        self.viewControllers = [inoutRecordsNav, statisticsNav, mineNav]
        
        
//        inoutRecordsVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 0)
//
//        statisticsVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.search, tag: 1)
//
//        mineVC.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.featured, tag: 2)
//
//        self.viewControllers = [inoutRecordsVC, statisticsVC, mineVC]
    }

}

//
//  TabViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    let inoutRecordsVC = InoutRecordsViewController()
    let statisticsVC = StatisticsViewController()
    let mineVC = MineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let inoutRecordsNav = UINavigationController(rootViewController: inoutRecordsVC)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        let mineNav = UINavigationController(rootViewController: mineVC)
        
        inoutRecordsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.history, tag: 0)
        
        statisticsNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.search, tag: 1)
        
        mineNav.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarItem.SystemItem.featured, tag: 2)
        
        
        self.viewControllers = [inoutRecordsNav, statisticsNav, mineNav]
        
        
        
    }

}

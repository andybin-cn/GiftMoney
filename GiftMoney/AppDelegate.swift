//
//  AppDelegate.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        BaseNavigationController.root.isNavigationBarHidden = true
        window = UIWindow()
        window?.rootViewController = MainTabViewController.shared
        window?.makeKeyAndVisible()
        
        IQKeyboardManager.shared.enable = true
        
        SLog.info("NSHomeDirectory: \(NSHomeDirectory())")
        
        if LocalAuthManager.shared.localAuthEnabled {
            MainTabViewController.shared.showLocalAuthView(viewMode: .verify)
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "ResignActiveTime")
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        let resignActiveTime = UserDefaults.standard.double(forKey: "ResignActiveTime")
        if abs(Date().timeIntervalSince1970 - resignActiveTime) > 60 * 3 {
            if LocalAuthManager.shared.localAuthEnabled {
                MainTabViewController.shared.showLocalAuthView(viewMode: .verify)
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }

    // MARK: UISceneSession Lifecycle

//    @available(iOS 13.0, *)
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    @available(iOS 13.0, *)
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

}


//
//  BaseNavigationController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    static let root: BaseNavigationController = BaseNavigationController(rootViewController: MainTabViewController.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
        interactivePopGestureRecognizer?.delegate = self
//        if #available(iOS 11.0, *) {
//            self.additionalSafeAreaInsets = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

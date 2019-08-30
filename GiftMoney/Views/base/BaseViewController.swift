//
//  BaseViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common
import RxSwift
import CloudKit

class BaseViewController: UIViewController {
    var navigationBar: UIView
    var titleLabel: UILabel
    let disposeBag: DisposeBag = DisposeBag()
    
//    override var title: String? {
//        didSet {
//            titleLabel.text = title
//        }
//    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        navigationBar = UIView(frame: CGRect.zero)
        titleLabel = UILabel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
//        self.extendedLayoutIncludesOpaqueBars = false
//        if #available(iOS 11.0, *) {
//
//        } else {
//            self.automaticallyAdjustsScrollViewInsets = false
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        SLog.info("\(type(of: self)) released!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //        if let delegate = self as? UIGestureRecognizerDelegate {
        //            self.navigationController?.interactivePopGestureRecognizer?.delegate = delegate
        //        }
        
    }
}


extension UIViewController {
    func catchError(error: Error) {
        if let error = error as? CommonError {
            self.showTipsView(text: error.message)
        } else if error is CKError {
            self.showTipsView(text: CommonError.iCloudError.message)
        } else {
            SLog.error("catchError:\(String(describing: error))")
            self.showTipsView(text: error.localizedDescription)
        }
    }
}

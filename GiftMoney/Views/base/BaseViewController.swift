//
//  BaseViewController.swift
//  GiftMoney
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import Common

class BaseViewController: UIViewController {
    var navigationBar: UIView
    var titleLabel: UILabel
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        navigationBar = UIView(frame: CGRect.zero)
        titleLabel = UILabel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
        NSLog("\(type(of: self)) released!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.normalBackground
        //        if let delegate = self as? UIGestureRecognizerDelegate {
        //            self.navigationController?.interactivePopGestureRecognizer?.delegate = delegate
        //        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("viewDidAppear:\(self.view.frame)")
    }
    
    func addNavigationBar() {
        navigationBar.backgroundColor = UIColor.gray
        
        view.addSubview(navigationBar)
        view.addSubview(navigationBar) { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(ScreenHelp.navBarHeight)
        }
        titleLabel.font = UIFont.appBoldFont(ofSize: 20)
        titleLabel.textColor = UIColor.appText
        navigationBar.addSubview(titleLabel) { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    let backButton = UIButton()
    func setDefaultBackButton() {
        backButton.apply { (button) in
            button.setImage(#imageLiteral(resourceName: "fanhui").ui_renderImage(tintColor: UIColor.appText), for: UIControl.State.normal)
            button.setEnlargeEdge(top: 10, right: 20, bottom: 10, left: 15)
            button.addTarget(self, action: #selector(defaultBackButtonTapped(sender:)), for: UIControl.Event.touchUpInside)
        }
        navigationBar.addSubview(backButton) { (make) in
            make.left.equalTo(15)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }
    }
    
    @objc func defaultBackButtonTapped(sender: Any) {
        if (navigationController?.children.count ?? 0) > 1 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}

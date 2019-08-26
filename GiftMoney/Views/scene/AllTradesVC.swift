//
//  AllTradesVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/13.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

class AllTradesVC: BaseViewController {
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
        segmented.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 16)], for: .normal)
        if #available(iOS 13, *) {
            segmented.layer.borderColor = UIColor.appSecondaryYellow.cgColor
            segmented.layer.borderWidth = 1
            segmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appMainRed, NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 16)], for: .selected)
            segmented.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow, NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 16)], for: .normal)
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
    
}

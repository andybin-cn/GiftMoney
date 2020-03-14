//
//  AccountHeader.swift
//  GiftMoney
//
//  Created by binea on 2020/3/14.
//  Copyright © 2020 binea. All rights reserved.
//

import UIKit
import RxSwift

class AccountHeader: UIView {
    enum ViewMode {
        case home
        case help
    }
    var disposeBag = DisposeBag()
    let scoreLabel = UILabel(textColor: UIColor.appWhiteText, font: .appBoldFont(ofSize: 20), textAlignment: .center, text: "我的活跃积分：")
    let scoreValue = UILabel(textColor: UIColor.systemYellow, font: .appBoldFont(ofSize: 26), textAlignment: .center, text: "")
    let checkInButton = UIButton()
    let advertInButton = UIButton()
    weak var viewController: UIViewController?
    init(mode: ViewMode, viewController: UIViewController) {
        self.viewController = viewController
        super.init(frame: .zero)
        AccountManager.shared.score.subscribe(onNext: { [unowned self] (score) in
            self.scoreValue.text = "\(score)"
            self.checkInButton.isEnabled = !AccountManager.shared.hasCheckIn()
        }).disposed(by: disposeBag)
        
        if mode == .home {
            scoreLabel.textColor = .appDarkText
            scoreValue.textColor = .systemYellow
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.clear
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(110)
        }
        
        scoreLabel.apply { (label) in
            label.addTo(self) { (make) in
                make.left.equalTo(20)
                make.top.equalTo(20)
            }
        }
        
        scoreValue.apply { (label) in
            label.addTo(self) { (make) in
                make.left.equalTo(scoreLabel.snp.right).offset(10)
                make.bottom.equalTo(scoreLabel)
            }
        }
        
        checkInButton.apply { (button) in
            button.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
            button.layer.cornerRadius = 4
            button.clipsToBounds = true
            button.setTitle("签到获取积分\n（连续签到积分递增）", for: .normal)
            button.setTitle("今日已签到\n（明天可以获取更多）", for: .disabled)
            button.titleLabel?.font = UIFont.appFont(ofSize: 12)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.numberOfLines = 0
            button.setTitleColor(UIColor.appMainRed, for: .normal)
            button.setTitleColor(UIColor.appGrayText, for: .disabled)
            button.isEnabled = !AccountManager.shared.hasCheckIn()
            
            button.addTo(self) { (make) in
                make.right.equalTo(-15)
                make.left.equalTo(self.snp.centerX).offset(8)
                make.bottom.equalTo(-10)
                make.height.equalTo(40)
            }
        }
        
        advertInButton.apply { (button) in
            button.layer.cornerRadius = 4
            button.clipsToBounds = true
            button.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
            button.setTitle("看广告获取积分", for: .normal)
            button.titleLabel?.font = UIFont.appFont(ofSize: 15)
            button.setTitleColor(UIColor.appMainRed, for: .normal)
            
            button.addTo(self) { (make) in
                make.left.equalTo(15)
                make.right.equalTo(self.snp.centerX).offset(-8)
                make.bottom.equalTo(-10)
                make.height.equalTo(40)
            }
        }
        
        checkInButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] (_) in
            let result = AccountManager.shared.checkIn()
            MainTabViewController.shared.showTipsView(text: "成功签到，获得\(result)积分")
            self.checkInButton.isEnabled = !AccountManager.shared.hasCheckIn()
        }).disposed(by: disposeBag)
        
        advertInButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] (_) in
            self.showRewardAdvert()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showRewardAdvert() {
        guard let controller = viewController else {
            return
        }
        controller.showLoadingIndicator()
        AccountManager.shared.showRewardAdvert(controller: controller).subscribe(onNext: { (addScore) in
            controller.showTipsView(text: "成功获得\(addScore)积分")
        }, onError: { (error) in
            controller.catchError(error: error)
        }).disposed(by: disposeBag)
    }
    
}

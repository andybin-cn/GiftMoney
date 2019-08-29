//
//  FillInviteCodeVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/29.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import SnapKit

class FillInviteCodeVC: BaseViewController {
    
    let codeField = InputField(name: "", labelString: "请输入邀请码")
    let button = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeField.addTo(self.view) { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        button.addTo(self.view) { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(34)
            make.top.equalTo(codeField.snp.bottom).offset(20)
        }
        
        button.setTitle("使用邀请码", for: .normal)
        button.setTitleColor(.appSecondaryYellow, for: .normal)
        button.setBackgroundImage(UIColor.appMainRed.toImage(), for: .normal)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onSaveButtonTapped), for: .touchUpInside)
        
    }
    
    @objc func onSaveButtonTapped() {
        guard let code = codeField.textfield.text, code.count == 6 else {
            self.showTipsView(text: "请输入正确的邀请码")
            return
        }
        
        self.showLoadingIndicator()
        InviteManager.shared.useInviteCode(code: code.uppercased()).subscribe(onNext: { [unowned self] (_) in
            self.hiddenLoadingIndicator()
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.showTipsView(text: "使用邀请码成功")
        }, onError: { [unowned self] (error) in
            self.catchError(error: error)
        }).disposed(by: disposeBag)
    }
    
    
}

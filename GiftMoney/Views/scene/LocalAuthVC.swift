//
//  LocalAuthVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import SnapKit



class LocalAuthVC: BaseViewController {
    
    enum ViewMode {
        case open
        case close
        case verify
    }
    
    let faceImage = UIImageView()
    let descLabel: UILabel
    var viewMode: ViewMode
    init(viewMode: ViewMode) {
        self.viewMode = viewMode
        let descString = LocalAuthManager.shared.biometryType == .faceID ? "点击进行人脸识别" : "点击进行指纹识别"
        descLabel = UILabel(textColor: UIColor.appTextBlue, font: UIFont.appFont(ofSize: 14), textAlignment: .center, text: descString)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        faceImage.apply { (faceImage) in
            faceImage.image = UIImage(named: "icons8-face_id")
            faceImage.addTo(self.view) { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-80)
            }
        }
        
        descLabel.addTo(self.view) { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(faceImage.snp.bottom).offset(20)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onSelfViewTapped))
        self.view.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func onSelfViewTapped() {
        authWithIPhone()
    }
    
    func authWithIPhone() {
        LocalAuthManager.shared.authWithIPhone().subscribe(onNext: { [unowned self] (success) in
            if success {
                switch self.viewMode {
                case .open:
                    LocalAuthManager.shared.localAuthEnabled = true
                case .close:
                    LocalAuthManager.shared.localAuthEnabled = false
                case .verify:
                    break
                }
                MainTabViewController.shared.hideLocalAuthView()
            }
        }).disposed(by: disposeBag)
    }
}

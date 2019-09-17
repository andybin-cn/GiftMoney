//
//  UploadStateButton.swift
//  GiftMoney
//
//  Created by binea on 2019/9/17.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


class UploadStateButton: UIButton {
    enum UploadStateButtonState {
        case notUpload
        case uploading
        case warning
        case uploadted
    }
    let icon = UIImageView()
    let title = UILabel()
    var uploadState: UploadStateButtonState = .notUpload {
        didSet {
            self.refreshState()
        }
    }
    
    
    init() {
        super.init(frame: .zero)
        
        self.snp.makeConstraints { (make) in
            make.width.height.equalTo(46)
        }
        icon.contentMode = .scaleAspectFill
        icon.addTo(self) { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }
        
        title.font = UIFont.appFont(ofSize: 9)
        title.addTo(self) { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom)
        }
        self.titleLabel?.font = UIFont.appFont(ofSize: 10)
        self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        self.layer.cornerRadius = 23
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.appSecondaryGray.cgColor
        self.setBackgroundImage(UIColor.appSecondaryGray.toImage(), for: .normal)
        
        refreshState()
    }
    
    func refreshState() {
        switch uploadState {
        case .notUpload:
            isUserInteractionEnabled = true
            icon.image = UIImage(named: "icons8-upload_to_cloud")
            title.text = "未上传"
            title.textColor = UIColor.appSecondaryBlue
        case .uploading:
            isUserInteractionEnabled = false
            icon.image = UIImage(named: "icons8-cloud_refresh")
            title.text = "正在上传"
            title.textColor = UIColor.appSecondaryBlue
        case .warning:
            isUserInteractionEnabled = true
            icon.image = UIImage(named: "icons8-error_cloud")
            title.text = "点击重试"
            title.textColor = UIColor.appSecondaryRed
        case .uploadted:
            isUserInteractionEnabled = false
            icon.image = UIImage(named: "icons8-cloud_checked")
            title.text = "已上传"
            title.textColor = UIColor.appSecondaryBlue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

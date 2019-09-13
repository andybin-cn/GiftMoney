//
//  SpeechViewController.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/10.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common
import SnapKit
import RxSwift
import Speech

class SpeechViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    let text = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 14))
    let speechButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.numberOfLines = 0
        text.lineBreakMode = .byWordWrapping
        text.addTo(self.view) { (make) in
            make.top.equalTo(200)
            make.left.equalTo(20)
            make.right.equalTo(20)
        }
        
        speechButton.setTitle("按住说话", for: .normal)
        speechButton.titleLabel?.font = UIFont.appFont(ofSize: 12)
        speechButton.layer.cornerRadius = 40
        speechButton.layer.masksToBounds = true
        speechButton.backgroundColor = UIColor.appSecondaryGray
        speechButton.setTitleColor(.appMainRed, for: .normal)
        speechButton.addTo(self.view) { (make) in
            make.bottom.equalTo(0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
//        let gesture = UIGestureRecognizer(target: self, action: #selector(onGestureRecognizer(sender:)))
//        gesture.delegate = self
//        speechButton.addGestureRecognizer(gesture)
        
        speechButton.rx.controlEvent(.touchDown).asObservable().subscribe(onNext: { [unowned self] (_) in
            self.startRecognizer()
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [unowned self] (_) in
            self.stopRecognizer()
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpOutside).asObservable().subscribe(onNext: { [unowned self] (_) in
            self.stopRecognizer()
        }).disposed(by: disposeBag)
    }
    
    var speechDispose: Disposable?
    func startRecognizer() {
        SLog.info("startRecognizer")
        stopRecognizer()
        speechDispose = SpeechManager.shared.startSpeech().subscribe(onNext: { [unowned self] (result) in
            SLog.info("speech result:\(result.bestTranscription.formattedString)")
            self.text.text = result.bestTranscription.formattedString
        }, onError: { [unowned self] (error) in
            self.stopRecognizer()
        }, onCompleted: { [unowned self] in
            self.stopRecognizer()
        })
        speechDispose?.disposed(by: disposeBag)
    }
    func stopRecognizer() {
        SLog.info("stopRecognizer")
        speechDispose?.dispose()
        speechDispose = nil
    }
    
    //MARK: - UIGestureRecognizerDelegate
    @objc func onGestureRecognizer(sender: Any) {
        SLog.info("onGestureRecognizer")
        SLog.info("onGestureRecognizer:\(type(of: sender))")
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

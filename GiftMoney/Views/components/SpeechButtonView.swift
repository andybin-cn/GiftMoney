//
//  SpeechButtonView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/10.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common
import SnapKit
import RxSwift
import RxRelay
import Speech

class SpeechButtonView: UIView {
    let disposeBag = DisposeBag()
    
    let exampleLabel = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 14))
    let textLabel = UILabel(textColor: .appSecondaryBlue, font: .appBoldFont(ofSize: 15))
    let speechButton = UIButton()
    let buttonContainer = UIView()
    let animateView = UIView()
    let speechResult = PublishRelay<AnalyzeResult>()
    let blurEffectView: UIVisualEffectView
    let logoImage = UIImageView(image: UIImage(named: "logo"))
    
    weak var controller: UIViewController?
    
    init() {
        let blurEffect = UIBlurEffect.init(style: UIBlurEffect.Style.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: .zero)
        logoImage.apply { (logo) in
            logo.alpha = 0
            logo.addTo(self, layout: { (make) in
                make.edges.equalToSuperview()
            })
        }
        
        blurEffectView.addTo(logoImage) { (make) in
            make.edges.equalToSuperview()
        }
        
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
        self.snp.makeConstraints { (make) in
            make.height.equalTo(100)
        }
        
        buttonContainer.addTo(self) { (make) in
            make.bottom.equalTo(0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(260)
        }
        
        exampleLabel.apply { (label) in
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.isHidden = true
            label.addTo(self) { (make) in
                make.top.equalTo(8).priority(ConstraintPriority.low)
                make.left.equalTo(15)
                make.right.equalTo(15)
            }
            let attrStr = NSMutableAttributedString()
            attrStr.append(NSAttributedString(string: "请大声准确的对我说话，例句：\n", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appDarkText]))
            attrStr.append(NSAttributedString(string: "1.结婚典礼收到大学同学小明200元红包。", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryGray]))
//            attrStr.append(NSAttributedString(string: "(可选)", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryGray]))
//            attrStr.append(NSAttributedString(string: "大学同学", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.appMainRed]))
////            attrStr.append(NSAttributedString(string: "(可选)", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryGray]))
//            attrStr.append(NSAttributedString(string: "小明", attributes: [NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow]))
//            attrStr.append(NSAttributedString(string: "200元", attributes: [NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.appMainRed]))
//            attrStr.append(NSAttributedString(string: "红包。", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryBlue]))
            
            attrStr.append(NSAttributedString(string: "\n2.朋友李萌萌200元", attributes: [NSAttributedString.Key.font : UIFont.appFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryGray]))
//            attrStr.append(NSAttributedString(string: "李萌萌同学200元", attributes: [NSAttributedString.Key.font : UIFont.appBoldFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.appSecondaryYellow]))
            label.attributedText = attrStr
        }
        textLabel.apply { (label) in
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.isHidden = true
            label.addTo(self) { (make) in
                make.top.equalTo(exampleLabel.snp.bottom).offset(8)
                make.bottom.lessThanOrEqualTo(buttonContainer.snp.top).priority(.high)
                make.left.equalTo(20)
                make.right.equalTo(20)
            }
        }
        
        speechButton.setTitle("按住说话", for: .normal)
        speechButton.titleLabel?.font = UIFont.appFont(ofSize: 12)
        speechButton.layer.cornerRadius = 40
        speechButton.layer.masksToBounds = true
        speechButton.backgroundColor = UIColor.appSecondaryRed
        speechButton.setTitleColor(.appWhiteText, for: .normal)
        speechButton.addTo(buttonContainer) { (make) in
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        animateView.apply { (animateView) in
            animateView.layer.cornerRadius = 40
            animateView.layer.masksToBounds = true
            animateView.backgroundColor = UIColor.appSecondaryGray
            animateView.addTo(buttonContainer) { (make) in
                make.center.equalTo(speechButton)
                make.width.height.equalTo(speechButton)
            }
        }
        buttonContainer.sendSubviewToBack(animateView)
        
        speechButton.rx.controlEvent(.touchDown).asObservable().subscribe(onNext: { [unowned self] (_) in
            MobClick.event("speechButtonTapped")
            if !MarketManager.shared.checkAuth(type: .speechRecognize, controller: self.controller ?? MainTabViewController.shared) {
                return
            }
            _ = ContactManager.shared.initContactsAndReqAuthorizationIfNeed().subscribe()
            self.startRecognizer()
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            self?.speechButton.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.stopRecognizer()
                self?.speechButton.isUserInteractionEnabled = true
            })
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpOutside).asObservable().subscribe(onNext: { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.stopRecognizer()
            })
        }).disposed(by: disposeBag)
        
    SpeechManager.shared.peakPower.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (power) in
        var scale: CGFloat = 1
            if self.isInSpeech {
                scale = min(CGFloat(1.1 + power * 80), 3)
            }
//            self.animateView.layer.transform = CATransform3DMakeScale(scale, scale, 1)
            UIView.animate(withDuration: 0.1, animations: {
                self.animateView.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            })
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var isInSpeech: Bool {
        return speechDispose != nil
    }
    var speechDispose: Disposable?
    func startRecognizer() {
        SLog.info("startRecognizer")
        if isInSpeech {
            return
        }
        self.textLabel.text = ""
        speechDispose = SpeechManager.shared.requestAuthorizeAndStart().subscribe(onNext: { [weak self] (result) in
            SLog.debug("speech result:\(result.bestTranscription.formattedString)")
            self?.textLabel.text = result.bestTranscription.formattedString
        }, onError: { [weak self] (error) in
            let analyzeResult = AnalyzeResult()
            analyzeResult.error = error
            self?.speechResult.accept(analyzeResult)
            self?.speechDispose = nil
            self?.stopRecognizer()
        }, onCompleted: { [weak self] in
            self?.speechDispose = nil
            self?.stopRecognizer()
        })
        speechDispose?.disposed(by: disposeBag)
        self.snp.updateConstraints({ (make) in
            make.height.equalTo(360)
        })
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.logoImage.alpha = 1
        }) { (_) in
            self.exampleLabel.isHidden = false
            self.textLabel.isHidden = false
        }
    }
    func stopRecognizer() {
        SLog.info("stopRecognizer")
        speechDispose?.dispose()
        speechDispose = nil
        self.snp.updateConstraints({ (make) in
            make.height.equalTo(100)
        })
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.2) {
            self.animateView.transform = CGAffineTransform.identity
            self.logoImage.alpha = 0
        }
        if let text = self.textLabel.text, !text.isEmpty, let result = JieBaBridge.jiebaTag(text) as? Array<JieBaTag> {
            let analyzeResult = WordAnalyze(tags: result).analyzeSentence()
            if analyzeResult.name.isEmpty || analyzeResult.value.isEmpty {
                analyzeResult.error = CommonError(message: "无法识别的句子，请尽量按照例句中的格式录入语音", code: 100)
            } else {
                MarketManager.shared.speechRecognizedCount += 1
            }
            speechResult.accept(analyzeResult)
        }
        self.textLabel.text = nil
        self.exampleLabel.isHidden = true
        self.textLabel.isHidden = true
    }
}

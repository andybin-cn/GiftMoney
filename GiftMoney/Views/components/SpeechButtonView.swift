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
    
    let text = UILabel(textColor: .appDarkText, font: .appFont(ofSize: 14))
    let speechButton = UIButton()
    let buttonContainer = UIView()
    let animateView = UIView()
    let speechResult = BehaviorRelay<AnalyzeResult>(value: AnalyzeResult())
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.snp.makeConstraints { (make) in
            make.height.equalTo(100)
        }
        
        buttonContainer.addTo(self) { (make) in
            make.bottom.equalTo(0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(260)
        }
        
        text.numberOfLines = 0
        text.lineBreakMode = .byWordWrapping
        text.addTo(self) { (make) in
            make.bottom.equalTo(buttonContainer.snp.top)
            make.left.equalTo(20)
            make.right.equalTo(20)
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
            self.startRecognizer()
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpInside).asObservable().subscribe(onNext: { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.stopRecognizer()
            })
        }).disposed(by: disposeBag)
        speechButton.rx.controlEvent(.touchUpOutside).asObservable().subscribe(onNext: { [weak self] (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.stopRecognizer()
            })
        }).disposed(by: disposeBag)
        
    SpeechManager.shared.peakPower.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (power) in
            SLog.info("peakPower:\(power)")
            let scale = min(CGFloat(1 + power * 100), 3)
//            self.animateView.layer.transform = CATransform3DMakeScale(scale, scale, 1)
            UIView.animate(withDuration: 0.1, animations: {
                self.animateView.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            })
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var speechDispose: Disposable?
    func startRecognizer() {
        SLog.info("startRecognizer")
        stopRecognizer()
        self.text.text = ""
        speechDispose = SpeechManager.shared.startSpeech().subscribe(onNext: { [unowned self] (result) in
            SLog.info("speech result:\(result.bestTranscription.formattedString)")
            self.text.text = result.bestTranscription.formattedString
        }, onError: { [unowned self] (error) in
            self.stopRecognizer()
        }, onCompleted: { [unowned self] in
            self.stopRecognizer()
        })
        speechDispose?.disposed(by: disposeBag)
        self.snp.updateConstraints({ (make) in
            make.height.equalTo(320)
        })
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.layoutIfNeeded()
        }
    }
    func stopRecognizer() {
        SLog.info("stopRecognizer")
        speechDispose?.dispose()
        speechDispose = nil
        self.snp.updateConstraints({ (make) in
            make.height.equalTo(100)
        })
        UIView.animate(withDuration: 0.2) {
            self.animateView.transform = CGAffineTransform.identity
            self.backgroundColor = UIColor.white
            self.layoutIfNeeded()
        }
        if let text = self.text.text, !text.isEmpty, let result = JieBaBridge.jiebaTag(text) as? Array<JieBaTag> {
            let analyzeResult = WordAnalyze(tags: result).analyzeSentence()
            if analyzeResult.name.isEmpty || analyzeResult.value.isEmpty {
                analyzeResult.error = CommonError(message: "无法识别的句子，请尽量按照例句中的格式录入语音")
            }
            speechResult.accept(analyzeResult)
        } else {
            let analyzeResult = AnalyzeResult()
            analyzeResult.error = CommonError(message: "请按照例句中的格式录入语音")
            speechResult.accept(analyzeResult)
        }
        self.text.text = nil
    }
}

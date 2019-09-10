//
//  SpeechManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/9/10.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Speech
import RxSwift
import Common
import RxRelay

class SpeechManager: NSObject, SFSpeechRecognizerDelegate {
    private let audioEngine = AVAudioEngine()
    
    var speechAvailable = BehaviorRelay<Bool>(value: true)
    
    func requestAuthorization() -> Observable<SFSpeechRecognizerAuthorizationStatus> {
        return Observable<SFSpeechRecognizerAuthorizationStatus>.create { (observer) -> Disposable in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                observer.onNext(authStatus)
                observer.onCompleted()
            }
            return Disposables.create { }
        }
    }
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var speechRecognizer = SFSpeechRecognizer(locale: .current)
    
    func startSpeech() -> Observable<SFSpeechRecognitionResult> {
        return Observable<SFSpeechRecognitionResult>.create { (observer) -> Disposable in
            self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = self.recognitionRequest else {
                observer.onError(CommonError(message: "语音识别服务不可用"))
                return Disposables.create { }
            }
            guard let speechRecognizer = self.speechRecognizer else {
                observer.onError(CommonError(message: "语音识别服务不可用"))
                return Disposables.create { }
            }
            recognitionRequest.shouldReportPartialResults = true
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = self.audioEngine.inputNode
                
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    recognitionRequest.append(buffer)
                }
                
                self.audioEngine.prepare()
                try self.audioEngine.start()
                _ = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                    var isFinal = false
                    
                    if let result = result {
                        observer.onNext(result)
                        isFinal = result.isFinal
                    }
                    if isFinal {
                        observer.onCompleted()
                    } else if let error = error {
                        observer.onError(error)
                    }
                }
            } catch let error {
                observer.onError(error)
            }
            
            return Disposables.create {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
            }
        }
    }
    
    //MARK - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        speechAvailable.accept(available)
    }
}

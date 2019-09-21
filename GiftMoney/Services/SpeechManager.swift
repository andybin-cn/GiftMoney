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
import Accelerate

class SpeechManager: NSObject, SFSpeechRecognizerDelegate {
    static let shared = SpeechManager()
    
    private let audioEngine = AVAudioEngine()
    private let fftSize: UInt32
    let audioAnalyzer: RealtimeAnalyzer
    var speechAvailable = BehaviorRelay<Bool>(value: true)
    var peakPower = PublishRelay<Float>()
    
    private override init() {
        fftSize = 2048
        audioAnalyzer = RealtimeAnalyzer(fftSize: Int(fftSize))
        super.init()
    }
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_CN"))
    private lazy var fftSetup = vDSP_create_fftsetup(vDSP_Length(Int(round(log2(Double(fftSize))))), FFTRadix(kFFTRadix2))
    
    func requestAuthorizeAndStart() -> Observable<SFSpeechRecognitionResult> {
        return requestAuthorizationNoDispose().flatMap { (authorized) -> Observable<SFSpeechRecognitionResult> in
            return self.startSpeech(authorized: authorized)
        }.observeOn(MainScheduler.instance)
    }
    
    func startSpeech(authorized: Bool) -> Observable<SFSpeechRecognitionResult> {
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
            var task: SFSpeechRecognitionTask?
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                let inputNode = self.audioEngine.inputNode
                
                
                let recordingFormat = inputNode.outputFormat(forBus: 0)
                
                inputNode.installTap(onBus: 0, bufferSize: self.fftSize, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                    recognitionRequest.append(buffer)
                    self.peakPower.accept(self.audioAnalyzer.peakPower(buffer: buffer))
                }
                
                self.audioEngine.prepare()
                try self.audioEngine.start()
                task = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                    var isFinal = false
                    
                    if let result = result {
                        observer.onNext(result)
                        isFinal = result.isFinal
                    }
                    if isFinal {
                        observer.onCompleted()
                    } else if let error = error {
                        SLog.error("speechRecognizer error:\(error)")
                        if !authorized {
                            observer.onError(AuthorizationError(type: .speechRecognizer))
                        } else {
                            observer.onError(CommonError(message: "语音识别失败，如有重试后无法解决，请把问题反馈给我们。"))
                        }
                    }
                }
            } catch _ {
                observer.onError(CommonError(message: "语音识别失败，如有重试后无法解决，请把问题反馈给我们。"))
            }
            
            return Disposables.create {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                task?.finish()
                self.recognitionRequest?.endAudio()
                self.recognitionRequest = nil
            }
        }
    }
    
    //MARK - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        speechAvailable.accept(available)
    }
    
    func requestMicrophoneAuthorization() -> Observable<AVAuthorizationStatus> {
        return Observable<AVAuthorizationStatus>.create { (observer) -> Disposable in
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (_) in
                let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
                observer.onNext(audioStatus)
                observer.onCompleted()
            })
            return Disposables.create { }
        }
    }
    
    func requestSpeechAuthorization() -> Observable<SFSpeechRecognizerAuthorizationStatus> {
        return Observable<SFSpeechRecognizerAuthorizationStatus>.create { (observer) -> Disposable in
            SFSpeechRecognizer.requestAuthorization { speechStatus in
                observer.onNext(speechStatus)
                observer.onCompleted()
            }
            return Disposables.create { }
        }
    }
    
    func requestAuthorizationNoDispose() -> Observable<Bool> {
        return Observable<Bool>.create({ (observer) -> Disposable in
            _ = self.requestAuthorization().subscribe(onNext: { (result) in
                observer.onNext(result)
            }, onError: { (error) in
                observer.onError(error)
            }, onCompleted: {
                observer.onCompleted()
            })
            return Disposables.create { }
        })
    }
    
    func requestAuthorization() -> Observable<Bool> {
        return requestSpeechAuthorization().flatMap { (speechStatus) -> Observable<(AVAuthorizationStatus, SFSpeechRecognizerAuthorizationStatus)> in
            return self.requestMicrophoneAuthorization().map { ($0, speechStatus) }
        }.flatMap { (audioStatus, speechStatus) -> Observable<Bool> in
            switch (speechStatus, audioStatus) {
            case (.authorized, .authorized):
                return Observable<Bool>.from(optional: true)
            case (.denied, _):
                return Observable<Bool>.error(AuthorizationError(type: .speechRecognizer))
            case (.restricted, _):
                return Observable<Bool>.error(AuthorizationError(type: .speechRecognizer))
            case (.notDetermined, _):
                return Observable<Bool>.error(AuthorizationError(type: .speechRecognizer))
            default:
                return Observable<Bool>.error(AuthorizationError(type: .microphone))
            }
        }.do(onCompleted: {
            _ = ContactManager.shared.initContactsAndReqAuthorizationIfNeed().subscribe()
        })
    }
}

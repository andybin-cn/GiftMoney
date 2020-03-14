//
//  RewardAdvertManager.swift
//  advert_support
//
//  Created by andy.bin on 2019/12/18.
//

import Foundation
import GoogleMobileAds
import RxSwift
import Common

enum AdvertResult: String {
    case onADLoad
    case onError
}

class GADRewardedAdHandler: NSObject, GADRewardedAdDelegate {
    var handler: ((Result<GADAdReward, Error>) -> Void)?
    init(handler: @escaping (Result<GADAdReward, Error>) -> Void) {
        self.handler = handler
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        
    }
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        self.handler?(Result<GADAdReward, Error>.failure(CommonError(message: "无法加载广告", code: -3)))
        self.handler = nil
    }
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.handler?(Result<GADAdReward, Error>.success(reward))
        self.handler = nil
    }
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.handler?(Result<GADAdReward, Error>.failure(CommonError(message: "取消观看广告", code: -2)))
        self.handler = nil
    }
}

class RewardAdvertPool {
    var loadedAds = Array<GADRewardedAd>()
    let adUnitID: String
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
        self.preLoadRewardVideo()
    }
    
    func preLoadRewardVideo(count: Int = 1) {
        for index in 1...count {
            _ = self.loadRewardVideo().subscribe(onNext: { (advert) in
                NSLog("RewardAdvertManager preLoadRewardVideo success \(index)/\(count)")
                self.loadedAds.append(advert)
            }, onError: { (error) in
                NSLog("RewardAdvertManager preLoadRewardVideo failure \(index)/\(count)")
                NSLog("RewardAdvertManager preLoadRewardVideo failure \(error)")
            })
        }
    }
    
    func loadRewardVideo() -> Observable<GADRewardedAd> {
        return Observable<GADRewardedAd>.create { [unowned self] (observer) -> Disposable in
            let rewardedAd = GADRewardedAd(adUnitID: self.adUnitID)
            rewardedAd.load(GADRequest()) { (error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(rewardedAd)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create {
                
            }
        }
    }
    
    private func loadRewardVideo1() -> Result<GADRewardedAd, Error> {
        var result: Result<GADRewardedAd, Error>!
        let semaphore = DispatchSemaphore(value: 0)
        let rewardedAd = GADRewardedAd(adUnitID: adUnitID)
        rewardedAd.load(GADRequest()) { (error) in
            if let error = error {
                result = Result<GADRewardedAd, Error>.failure(error)
            } else {
                result = Result<GADRewardedAd, Error>.success(rewardedAd)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    private func showRewardAdvert(rewardAd: GADRewardedAd, controller: UIViewController) -> Observable<GADAdReward> {
        return Observable<GADAdReward>.create { (observer) -> Disposable in
            rewardAd.present(fromRootViewController: controller, delegate: GADRewardedAdHandler(handler: { (showResult) in
                switch showResult {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }))
            return Disposables.create {
            }
        }.timeout(DispatchTimeInterval.seconds(50), scheduler: MainScheduler.instance)
    }
    func showRewardVideo(controller: UIViewController) -> Observable<GADAdReward> {
        if self.loadedAds.isEmpty {
            return self.loadRewardVideo().flatMap { (rewardAd) -> Observable<GADAdReward> in
                return self.showRewardAdvert(rewardAd: rewardAd, controller: controller)
            }
        } else {
            let rewardAd = loadedAds.remove(at: 0)
            DispatchQueue.global().async {
                self.preLoadRewardVideo(count: 1)
            }
            return self.showRewardAdvert(rewardAd: rewardAd, controller: controller)
        }
    }
}

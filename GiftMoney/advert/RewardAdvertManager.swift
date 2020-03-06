//
//  RewardAdvertManager.swift
//  advert_support
//
//  Created by andy.bin on 2019/12/18.
//

import Foundation
import GoogleMobileAds

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
        self.handler?(Result<GADAdReward, Error>.failure(error))
        self.handler = nil
    }
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        self.handler?(Result<GADAdReward, Error>.success(reward))
        self.handler = nil
    }
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        self.handler?(Result<GADAdReward, Error>.failure(NSError(domain: "rewardedAdDidDismiss", code: -2, userInfo: nil)))
        self.handler = nil
    }
}

class RewardAdvertManager {
    var loadedAds = Array<GADRewardedAd>()
    let adUnitID: String
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
        DispatchQueue.global().async {
            self.preLoadRewardVideo()
        }
    }
    
    func preLoadRewardVideo(count: Int = 2) {
        for index in 0...count {
            let result = self.loadRewardVideo()
            switch result {
            case .success(let data):
                NSLog("RewardAdvertManager preLoadRewardVideo success \(index + 1)/\(count)")
                self.loadedAds.append(data)
            case .failure(_):
                NSLog("RewardAdvertManager preLoadRewardVideo failure \(index + 1)/\(count)")
            }
        }
    }
    
    func loadRewardVideo() -> Result<GADRewardedAd, Error> {
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
    
    func showRewardVideo(controller: UIViewController) -> Result<GADAdReward, Error> {
        var rewardAd: GADRewardedAd?
        if loadedAds.isEmpty {
            let result = loadRewardVideo()
            if case let .success(adItem) = result {
                rewardAd = adItem
            }
        } else {
            rewardAd = loadedAds.remove(at: 0)
            DispatchQueue.global().async {
                self.preLoadRewardVideo(count: 1)
            }
        }
        guard rewardAd != nil else {
            return Result<GADAdReward, Error>.failure(NSError(domain: "can not got a GADRewardedAd", code: -3, userInfo: nil))
        }
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<GADAdReward, Error>!
        rewardAd?.present(fromRootViewController: controller, delegate: GADRewardedAdHandler(handler: { (showResult) in
            result = showResult
            semaphore.signal()
        }))
        semaphore.wait()
        return result
    }
}

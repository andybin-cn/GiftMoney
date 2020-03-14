import UIKit
import GoogleMobileAds
import RxSwift


class RewardAdvertManager: NSObject {
    var rewardAdvertPool: RewardAdvertPool
    static var shared: RewardAdvertManager = {
        #if DEBUG
        return RewardAdvertManager(adUnitId: "ca-app-pub-3940256099942544/1712485313")
        #else
        return RewardAdvertManager(adUnitId: "ca-app-pub-3156075797045250/9070048309")
        #endif
    }()
    
    private init(adUnitId: String) {
        rewardAdvertPool = RewardAdvertPool(adUnitID: adUnitId)
    }

    func preLoadRewardVideo(preLoadCount: Int) {
        self.rewardAdvertPool.preLoadRewardVideo(count: preLoadCount)
    }

    func showRewardVideoAD(controller: UIViewController) -> Observable<GADAdReward> {
        return self.rewardAdvertPool.showRewardVideo(controller: controller)
    }
}

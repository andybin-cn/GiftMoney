import UIKit
import GoogleMobileAds

class RewardAdvertManager: NSObject {
    var rewardAdvertPool: RewardAdvertPool
    static var shared: RewardAdvertManager = {
        #if DEV
        return RewardAdvertManager(adUnitId: "ca-app-pub-3940256099942544/1712485313")
        #else
        return RewardAdvertManager(adUnitId: "ca-app-pub-3156075797045250/9070048309")
        #endif
    }()
    
    private init(adUnitId: String) {
        rewardAdvertPool = RewardAdvertPool(adUnitID: adUnitId)
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    func preLoadRewardVideo(adUnitId: String?, preLoadCount: Int) {
        DispatchQueue.global().async {
            self.rewardAdvertPool.preLoadRewardVideo(count: preLoadCount)
            DispatchQueue.main.async {

            }
        }
    }

    func showRewardVideoAD(adUnitId: String?, controller: UIViewController) {
        DispatchQueue.global().async {
            let rewardResult = self.rewardAdvertPool.showRewardVideo(controller: controller)
            DispatchQueue.main.async {
                switch rewardResult {
                case .success(let reward):
                    break
                case .failure(let error):
                    break
                }
            }
        }
    }
}

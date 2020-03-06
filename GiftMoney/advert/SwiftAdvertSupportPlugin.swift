import UIKit
import GoogleMobileAds


extension UIApplication {
    func getCurrentVC() -> UIViewController? {
        var window = self.keyWindow
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = self.windows
            for  tempwin in windows {
                if tempwin.windowLevel == UIWindow.Level.normal{
                    window = tempwin
                    break
                }
            }
        }
//        // 获取window的rootViewController
//        var result = window?.rootViewController
//        while result?.presentedViewController {
//            result = result?.presentedViewController
//        }
//        if ([result isKindOfClass:[UITabBarController class]]) {
//            result = [(UITabBarController *)result selectedViewController];
//        }
//        if ([result isKindOfClass:[UINavigationController class]]) {
//            result = [(UINavigationController *)result visibleViewController];
//        }
//        while <#condition#> {
//            <#code#>
//        }
//
        guard let frontView = window?.subviews[0] else {
            return nil
        }
        let nextResponder = frontView.next
        if nextResponder is UIViewController {
            return nextResponder as? UIViewController
        } else if nextResponder is UINavigationController {
            return (nextResponder as! UINavigationController).visibleViewController
        } else {
            if (window?.rootViewController) is UINavigationController {
              return ((window?.rootViewController) as! UINavigationController).visibleViewController!//只有这个是显示的controller 是可以的必须有nav才行
            } else if (window?.rootViewController) is UITabBarController {
                return ((window?.rootViewController) as! UITabBarController).selectedViewController //不行只是最三个开始的页面
            }
            return (window?.rootViewController)
        }
    }
}

public class SwiftAdvertSupportPlugin: NSObject {
    var rewardAdvertManager: RewardAdvertManager?
    public static func register() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "preLoadRewardVideo", let arguments = call.arguments as? Dictionary<String, Any> {
            let preLoadCount = arguments["preLoadCount"] as? Int ?? 1
            if let adUnitId = arguments["adUnitId"] as? String {
                self.preLoadRewardVideo(adUnitId: adUnitId, result: result, preLoadCount: preLoadCount)
            } else {
                result(FlutterError(code: "-1", message: "adUnitId can not be null", details: nil))
            }
        } else if call.method == "showRewardVideoAD" {
            let arguments = call.arguments as? Dictionary<String, Any>
            let adUnitId = arguments?["adUnitId"] as? String
            self.showRewardVideoAD(adUnitId: adUnitId, result: result)
        } else {
            result(FlutterError(code: "0", message: "method '\(call.method)' notImplemented in channel advert_support", details: nil))
        }
    }
    
    var lock = NSLock()
    func initRewardAdvertManager(adUnitId: String) {
        lock.lock()
        if rewardAdvertManager == nil {
            rewardAdvertManager = RewardAdvertManager(adUnitID: adUnitId)
        }
        lock.unlock()
    }
    
    func preLoadRewardVideo(adUnitId: String?, result: @escaping FlutterResult, preLoadCount: Int) {
        if rewardAdvertManager == nil, adUnitId != nil {
            initRewardAdvertManager(adUnitId: adUnitId!)
        }
        DispatchQueue.global().async {
            self.rewardAdvertManager?.preLoadRewardVideo(count: preLoadCount)
            DispatchQueue.main.async {
                result("preLoadRewardVideo finished")
            }
        }
    }
    
    func showRewardVideoAD(adUnitId: String?, result: @escaping FlutterResult) {
        if rewardAdvertManager == nil, adUnitId != nil {
            initRewardAdvertManager(adUnitId: adUnitId!)
        }
        guard let controller = UIApplication.shared.getCurrentVC(), let manager = rewardAdvertManager else {
            result(FlutterError(code: "-1", message: "show failed", details: nil))
            return
        }
        DispatchQueue.global().async {
            let rewardResult = manager.showRewardVideo(controller: controller)
            DispatchQueue.main.async {
                switch rewardResult {
                case .success(let reward):
                    result(["type": reward.type, "amount": "\(reward.amount)"])
                case .failure(let error):
                    result(FlutterError(code: "-2", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
}

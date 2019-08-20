//
//  LocalAuthManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/20.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import LocalAuthentication
import RxSwift

class LocalAuthManager {
    static let shared = LocalAuthManager()
    
    var localAuthEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(localAuthEnabled, forKey: "localAuthEnabled")
        }
    }
    
    var biometryType: LABiometryType
    var localAuthAvailability: Bool
    
    init() {
        var error: NSError?
        let content = LAContext()
        if content.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            localAuthAvailability = true
        } else {
            localAuthAvailability =  false
        }
        biometryType = content.biometryType
        
        if !localAuthAvailability {
            UserDefaults.standard.set(false, forKey: "localAuthEnabled")
        } else if UserDefaults.standard.bool(forKey: "localAuthEnabled") {
            localAuthEnabled = true
        }
    }
    
    func authWithIPhone() -> Observable<Bool> {
        return Observable<Bool>.create { (observable) -> Disposable in
            let reason = "解锁App"
            LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                DispatchQueue.main.async {
                    observable.onNext(success)
                }
            }
            return Disposables.create { }
        }
    }
}

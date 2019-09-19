//
//  UserGuideManager.swift
//  GiftMoney
//
//  Created by binea on 2019/9/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation

class UserGuideManager {
    static let shared = UserGuideManager()
    
    var hasShowSpeechGuid = false {
        didSet {
            UserDefaults.standard.set(isFirstTimeForSpeech, forKey: "UserGuideManager_hasShowSpeechGuid")
        }
    }
    
    init() {
        isFirstTimeForSpeech = UserDefaults.standard.bool(forKey: "UserGuideManager_hasShowSpeechGuid")
    }
    
}

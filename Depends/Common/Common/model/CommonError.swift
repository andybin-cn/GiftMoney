//
//  CommonError.swift
//  Common
//
//  Created by andy.bin on 2019/8/21.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation


public struct CommonError: Error {
    public let message: String
    public let code: Int
    public init(message: String, code: Int = 0) {
        self.message = message
        self.code = code
    }
    public var localizedDescription: String {
        return message
    }
}

extension CommonError {
    public static var iCloudError: CommonError {
        return CommonError(message: "访问iCloud服务错误")
    }
}

public struct AuthorizationError: Error {
    public enum `Type` {
        case camara
        case photo
        case speechRecognizer
        case microphone
    }
    
    let type: `Type`
    public init(type: Type) {
        self.type = type
    }
    
    public var localizedDescription: String {
        switch type {
        case .microphone:
            return "您未授权麦克风权限"
        case .speechRecognizer:
            return "您未授权语音识别权限"
        case .camara:
            return "您未授权使用摄像头权限"
        case .photo:
            return "您未授权相册权限"
        }
    }
}


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
}

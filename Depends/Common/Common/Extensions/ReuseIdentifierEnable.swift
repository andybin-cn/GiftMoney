//
//  ReuseIdentifierEnable.swift
//  AnYou
//
//  Created by binea on 2017/3/5.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit

public protocol ReuseIdentifierEnable {
    static var commonIdentifier: String {get}
}

extension ReuseIdentifierEnable {
    static public var commonIdentifier: String {
        return "\(type(of: self))"
    }
}

extension UITableViewCell: ReuseIdentifierEnable {
    
}

extension UICollectionViewCell: ReuseIdentifierEnable {
    
}

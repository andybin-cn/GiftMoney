//
//  UITableView+Extensions.swift
//  Common
//
//  Created by binea on 2017/3/14.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension UITableView {
    public func setExtraCellLineHidden() {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        tableFooterView = view
    }
}

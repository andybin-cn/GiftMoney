//
//  CGSize+Extensions.swift
//  Common
//
//  Created by binea on 2017/3/15.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation

extension CGSize{
    public static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    public static var screenHeight:CGFloat{
        return self.screenSize.height
    }
    
    public static var screenWidth:CGFloat{
        return self.screenSize.width
    }
}


extension CGSize{
    public func scale(to size: CGSize) -> CGSize {
        let scale = min(size.height/height, size.width/width)
        return CGSize(width: width * scale, height: height * scale)
    }
}

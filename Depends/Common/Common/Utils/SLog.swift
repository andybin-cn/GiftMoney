//
//  SLog.swift
//  Common
//
//  Created by binea on 2017/3/9.
//  Copyright © 2017年 binea. All rights reserved.
//

import Foundation
import SwiftyBeaver



public class SLogClass {
    init() {
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        #if DEBUG
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        console.asynchronously = false
        SwiftyBeaver.addDestination(console)
        #endif
        file.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        file.asynchronously = true
        SwiftyBeaver.addDestination(file)
        SwiftyBeaver.info(file.logFileURL!)
    }
    
    public func info(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        SwiftyBeaver.info(message, file, function, line: line)
    }
    
    public func warning(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        SwiftyBeaver.warning(message, file, function, line: line)
    }
    
    public func verbose(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        SwiftyBeaver.verbose(message, file, function, line: line)
    }
    
    public func debug(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        SwiftyBeaver.debug(message, file, function, line: line)
    }
    
    public func error(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, line: Int = #line) {
        SwiftyBeaver.error(message, file, function, line: line)
    }
    
}

public let SLog: SLogClass = SLogClass()

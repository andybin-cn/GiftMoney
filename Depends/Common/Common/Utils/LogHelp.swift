//
//  LogHelp.swift
//  Common
//
//  Created by andy.bin on 2019/9/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

public class LogHelp {
    let fileLogger: DDFileLogger = DDFileLogger() // File Logger
    init() {
        fileLogger.rollingFrequency = 0 // 24 hours
        fileLogger.maximumFileSize = 1024 * 100
        fileLogger.logFileManager.maximumNumberOfLogFiles = 0
        
        #if DEBUG
            DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.all)
            DDLog.add(fileLogger, with: DDLogLevel.all)
        #else
            DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.info)
            DDLog.add(fileLogger, with: DDLogLevel.info)
        #endif
    }
    
    public var logFileURLs: [URL] {
        return fileLogger.logFileManager.unsortedLogFilePaths.map { return URL(fileURLWithPath: $0) }
    }
    
    public func verbose(_ format: String, _ arguments: Any..., level: DDLogLevel = DDDefaultLogLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
        DDLogVerbose(String(format: format, arguments), level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
    
    public func info(_ format: String, _ arguments: CVarArg..., level: DDLogLevel = DDDefaultLogLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
        DDLogInfo(String(format: format, arguments), level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
    
    public func warn(_ format: String, _ arguments: CVarArg..., level: DDLogLevel = DDDefaultLogLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
        DDLogWarn(String(format: format, arguments), level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
    public func error(_ format: String, _ arguments: CVarArg..., level: DDLogLevel = DDDefaultLogLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
        DDLogError(String(format: format, arguments), level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
    public func debug(_ format: String, _ arguments: CVarArg..., level: DDLogLevel = DDDefaultLogLevel, context: Int = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, tag: Any? = nil, asynchronous async: Bool = asyncLoggingEnabled, ddlog: DDLog = .sharedInstance) {
        DDLogDebug(String(format: format, arguments), level: level, context: context, file: file, function: function, line: line, tag: tag, asynchronous: async, ddlog: ddlog)
    }
}

public let Log = LogHelp()

class d {
    init() {
        Log.error("dasdas")
    }
}

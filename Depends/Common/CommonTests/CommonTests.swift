//
//  CommonTests.swift
//  CommonTests
//
//  Created by binea on 2017/3/1.
//  Copyright © 2017年 binea. All rights reserved.
//

import XCTest
@testable import Common

class CommonTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLog() {
        let expectation = self.expectation(description: "write log")
        Log.info("logFileURL:\(String(describing: Log.logFileURLs.first))")
        for i in 0...100 {
            Log.info("\(i)")
            Log.info("SpeechManager.shared.peakPower.asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { [unowned", 0.0)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        Log.info("logFileURL:\(String(describing: Log.logFileURLs.first))")
        waitForExpectations(timeout: 10000) { (nil) in
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
}

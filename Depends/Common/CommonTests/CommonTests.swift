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
    
    func testSecurityUtil() {
        let planText = "{\"seqno\":1,\"code\":\"011\",\"commRequest\":{\"clientId\":\"yuanli-test\",\"tsn\":\"\",\"sim\":\"\",\"pasm\":\"\",\"sysVer\":\"win10\",\"appVer\":\"pm1.0\"},\"uid\":\"admin\",\"pwd\":\"\",\"longi\":\"121.480237\",\"lati\":\"31.2363\",\"batchCode\":\"20170107004200\",\"platformId\":\"P+R\",\"parkingSpotId\":\"yuanli-test\",\"name\":\"停车点名称\",\"address\":\"停车点地址\",\"opentime\":\"24小时\",\"price\":\"10元每小时\"}"
        let security = SecurityUtil(key: "smkldospdosldaaa", iv: "0392039203920300")
        let cipherText = security.encryptAES(planText: planText)
        XCTAssertNotNil(cipherText)
        
        let planText2 = security.decryptAES(cipherText: cipherText!)
        XCTAssertNotNil(planText2)
        XCTAssertEqual(planText, planText2!)
    }
    
    func testLog() {
        SLog.setup()
        SLog.verbose("not so important")  // prio 1, VERBOSE in silver
        SLog.debug("something to debug")  // prio 2, DEBUG in green
        SLog.info("a nice information")   // prio 3, INFO in blue
        SLog.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        SLog.error("ouch, an error did occur!")  // prio 5, ERROR in red
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
}

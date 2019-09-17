//
//  GiftMoneyTests.swift
//  GiftMoneyTests
//
//  Created by binea on 2019/8/4.
//  Copyright © 2019 binea. All rights reserved.
//

import XCTest
@testable import GiftMoney

class GiftMoneyTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        JieBaBridge.initJieBa()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJieBaCut() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let string = JieBaBridge.jiebaCut("19年3月10号收到朋友李大强¥500红包.")
        print("JieBaBridge.jiebaCut:\(string)")
    }
    
    func testJieBaTag() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let result = JieBaBridge.jiebaTag("19年3月10号送给朋友李大强¥500红包.") as? Array<JieBaTag> else {
            return
        }
        let analyzeResult = WordAnalyze.shared.analyzeSentence(tags: result)
        print("JieBaBridge.jiebaTag:\(String(describing: result))")
        print("analyzeResult:\(analyzeResult)")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

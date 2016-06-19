//
//  APItanTests.swift
//  APItanTests
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import XCTest

class APItanTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testJSON() {
        let url = "http://jsonplaceholder.typicode.com/user"
        let request = NSURLRequest(URL: NSURL(string: url)!)
        APItan.send(request: request) { result in
            switch result {
            case .Success(let json):
                print(json)
            case .Failure(let error):
                print(error)
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}

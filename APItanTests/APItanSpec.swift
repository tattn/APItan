//
//  APItanSpec.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/03.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import Quick
import Nimble
import APItan

struct GetRequest: RequestType {
    let method = HTTPMethod.Get

    let path = "http://jsonplaceholder.typicode.com/posts"

    var parameters: [String: AnyObject] {
        return ["userId": userId]
    }

    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }
}

class APItanSpec: QuickSpec {
    override func spec() {
        describe("APItan") {
            context("when you request http://api.pokosho.com/v1/hoge.json") {
                it("returns JSON") {
                    let request1 = GetRequest(userId: 1)
                    let request2 = GetRequest(userId: 2)
                    let request3 = GetRequest(userId: 3)
                    let request4 = GetRequest(userId: 4)
                    var no = 0
                    APItan.send(requests: [request1, request2, request3, request4], isSeries: false) { results in
                        results.forEach {
                            switch $0 {
                            case .Success(let json):
                                for user in json as? Array<AnyObject> ?? [] {
                                    expect(user["id"]!).toEventually(equal(no))
                                    no += 1
                                }
                            default: break
                            }
                        }
                    }
                }
            }
        }
    }
}

//
//  AppDelegate.swift
//  Example
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit

struct GetRequest: RequestType {
    let method = HTTPMethod.Get

    let path = "http://jsonplaceholder.typicode.com/posts"

    var parameters: [String: Any] {
        return ["userId": userId]
    }

    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let request1 = GetRequest(userId: 1)
        let request2 = GetRequest(userId: 2)
        let request3 = GetRequest(userId: 3)
        let request4 = GetRequest(userId: 4)
        APItan.send(requests: [request1, request2, request3, request4], isSeries: false) { results in
            results.forEach {
                switch $0 {
                case .success(let json):
                    for user in json as? Array<AnyObject> ?? [] {
                        print(user["id"])
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }

//        APItan.send(request: GetRequest(userId: 1)).next { json -> RequestType? in
//            for user in json as? Array<AnyObject> ?? [] {
//                print(user["id"])
//            }
//            return GetRequest(userId: 2)
//        }.next { json -> RequestType? in
//            for user in json as? Array<AnyObject> ?? [] {
//                print(user["id"])
//            }
//            return GetRequest(userId: 3)
//        }.next { json -> Void in
//            for user in json as? Array<AnyObject> ?? [] {
//                print(user["id"])
//            }
//        }.fail { error in
//            print(error)
//        }.always {
//            print("always")
//        }

        return true
    }

}

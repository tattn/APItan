//
//  AppDelegate.swift
//  Example
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit

struct GetRequest: RequestType {
    let method = Method.Get

    let path = "http://jsonplaceholder.typicode.com/posts"

    var parameters: [String: AnyObject] {
        return ["userId": 1]
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let request = GetRequest()
        APItan.send(request: request) { result in
            switch result {
            case .Success(let json):
                print(json)
            case .Failure(let error):
                print(error)
            }
        }
        return true
    }

}

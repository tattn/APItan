//
//  APItan.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public enum Method: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
    case Patch = "PATCH"
    case Delete = "DELETE"
}

public final class APItan {

    static let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // タイムアウト設定
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120

        return NSURLSession(configuration: config)
    }()

    public static func send(request request: RequestType, completion: (Result<AnyObject>) -> Void) {
        do {
            guard let request = request.request() else {
                throw APIError.URLError("Bad URL")
            }

            session.dataTaskWithRequest(request) { data, response, error in
                do {
                    guard let data = data else {
                        throw APIError.JSONError("Failed to get a data")
                    }

                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)

                    self.completionOnMainThread(.Success(json), completion: completion)
                } catch let error as NSError {
                    self.completionOnMainThread(.Failure(error), completion: completion)
                }
            }.resume()

        } catch let error as NSError {
            self.completionOnMainThread(.Failure(error), completion: completion)
        }
    }

    public static func send(requests requests: [RequestType], completion: ([Result<AnyObject>]) -> Void) {
        var results: [Result<AnyObject>] = Array(count: requests.count, repeatedValue: Result.Failure(APIError.Unknown("")))

        let group = dispatch_group_create()
        requests.enumerate().forEach { i, request in
            dispatch_group_enter(group)
            send(request: request) { result in
                results[i] = result
                dispatch_group_leave(group)
            }
        }

        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(results)
        }
    }

    private static func completionOnMainThread(result: Result<AnyObject>, completion: (Result<AnyObject>) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            completion(result)
        }
    }
}

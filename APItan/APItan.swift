//
//  APItan.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
    case Patch = "PATCH"
    case Delete = "DELETE"

    var isQueryParameter: Bool {
        return self == .Get || self == .Delete
    }
}

public final class APItan {

    static let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // タイムアウト設定
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120

        return NSURLSession(configuration: config)
    }()

    private typealias Task = (request: RequestType, task: NSURLSessionDataTask)
    private static var tasks = [Task]()

    public static func send(request request: RequestType, completion: (Result<AnyObject>) -> Void) {
        if let mockData = request.mockData {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                usleep(UInt32(request.mockWaitTime * 1000))
                dispatch_async(dispatch_get_main_queue()) {
                    completion(.Success(mockData))
                }
            }
            return
        }

        do {
            guard let urlRequest = request.createRequest() else {
                throw APIError.URLError("Bad URL")
            }

            let taskIndex = tasks.count

            let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
                if tasks.indices ~= taskIndex {
                    tasks.removeAtIndex(taskIndex)
                }
                do {
                    guard let data = data else {
                        if error?.code == NSURLErrorCancelled {
                            throw APIError.Cancelled("Cancelled to request")
                        } else {
                            throw APIError.JSONError("Failed to get a data")
                        }
                    }

                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)

                    self.completionOnMainThread(.Success(json), completion: completion)
                } catch let error as NSError {
                    self.completionOnMainThread(.Failure(error), completion: completion)
                }
            }
            tasks.append(Task(request, task))
            task.resume()

        } catch let error as NSError {
            self.completionOnMainThread(.Failure(error), completion: completion)
        }
    }

    public static func send(requests requests: [RequestType], isSeries: Bool = false, completion: ([Result<AnyObject>]) -> Void) {
        if isSeries {
            sendInSeries(requests: requests, completion: completion)
        } else {
            sendInParallel(requests: requests, completion: completion)
        }
    }

    private static func sendInParallel(requests requests: [RequestType], completion: ([Result<AnyObject>]) -> Void) {
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

    private static func sendInSeries(requests requests: [RequestType], completion: ([Result<AnyObject>]) -> Void) {
        var results = [Result<AnyObject>]()

        func run(index: Int) {
            guard index < requests.count else {
                completion(results)
                return
            }

            send(request: requests[index]) { result in
                results.append(result)
                run(index + 1)
            }
        }

        if !requests.isEmpty {
            run(0)
        }
    }

    public static func send(request request: RequestType) -> Promise {
        return Promise(request: request)
    }

    private static func completionOnMainThread(result: Result<AnyObject>, completion: (Result<AnyObject>) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            completion(result)
        }
    }

    public static func cancel(request request: RequestType) {
        while let target = tasks.enumerate().filter({ $0.element.request == request }).first {
            target.element.task.cancel()
            tasks.removeAtIndex(target.index)
        }
    }
}

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

    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        // タイムアウト設定
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120

        return URLSession(configuration: config)
    }()

    fileprivate typealias Task = (request: RequestType, task: URLSessionDataTask)
    fileprivate static var tasks = [Task]()

    public static func send(request: RequestType, completion: @escaping (Result<Any>) -> Void) {
        if let mockData = request.mockData {
            DispatchQueue.global(qos: .default).async {
                usleep(UInt32(request.mockWaitTime * 1000))
                DispatchQueue.main.async {
                    completion(.success(mockData))
                }
            }
            return
        }

        do {
            guard let urlRequest = request.createRequest() else {
                throw APIError.urlError("Bad URL")
            }

            let taskIndex = tasks.count

            let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
                if tasks.indices ~= taskIndex {
                    tasks.remove(at: taskIndex)
                }
                do {
                    guard let data = data else {
                        if error?._code == NSURLErrorCancelled {
                            throw APIError.cancelled("Cancelled to request")
                        } else {
                            throw APIError.jsonError("Failed to get a data")
                        }
                    }

                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                    self.completionOnMainThread(.success(json), completion: completion)
                } catch let error as NSError {
                    self.completionOnMainThread(.failure(error), completion: completion)
                }
            }) 
            tasks.append(Task(request, task))
            task.resume()

        } catch let error as NSError {
            self.completionOnMainThread(.failure(error), completion: completion)
        }
    }

    public static func send(requests: [RequestType], isSeries: Bool = false, completion: @escaping ([Result<Any>]) -> Void) {
        if isSeries {
            sendInSeries(requests: requests, completion: completion)
        } else {
            sendInParallel(requests: requests, completion: completion)
        }
    }

    fileprivate static func sendInParallel(requests: [RequestType], completion: @escaping ([Result<Any>]) -> Void) {
        var results: [Result<Any>] = Array(repeating: Result.failure(APIError.unknown("")), count: requests.count)

        let group = DispatchGroup()
        requests.enumerated().forEach { i, request in
            group.enter()
            send(request: request) { result in
                results[i] = result
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            completion(results)
        }
    }

    fileprivate static func sendInSeries(requests: [RequestType], completion: @escaping ([Result<Any>]) -> Void) {
        var results = [Result<Any>]()

        func run(_ index: Int) {
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

    public static func send(request: RequestType) -> Promise {
        return Promise(request: request)
    }

    private static func completionOnMainThread(_ result: Result<Any>, completion: @escaping (Result<Any>) -> Void) {
        OperationQueue.main.addOperation {
            completion(result)
        }
    }

    public static func cancel(request: RequestType) {
        while let target = tasks.enumerated().filter({ $0.element.request == request }).first {
            target.element.task.cancel()
            tasks.remove(at: target.offset)
        }
    }
}

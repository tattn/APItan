//
//  Request.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public protocol RequestType {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }
    var headers: [String: String] { get }

    var mockData: AnyObject? { get }
    var mockWaitTime: Int { get }
}

// Default values
public extension RequestType {
    var parameters: [String: AnyObject] {
        return [:]
    }
    var headers: [String: String] {
        return [:]
    }
    var mockData: AnyObject? {
        return nil
    }
    var mockWaitTime: Int {
        return 0
    }
}

public extension RequestType {
    public func createRequest() -> URLRequest? {
        guard let url = URL(string: urlWithParameters) else { return nil }

        let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.httpMethod = method.rawValue

        setHTTPHeaders(request: request)

        if let body = createBody() {
            request.httpBody = body
        }

        return request as URLRequest
    }

    public var urlWithParameters: String {
        return method.isQueryParameter ? "\(path)?\(parameters.stringFromHttpParameters())" : path
    }

    fileprivate func setHTTPHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if !method.isQueryParameter {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
    }

    fileprivate func createBody() -> Data? {
        guard !method.isQueryParameter else { return nil }

        guard let body = self.serializeJSON(data: parameters) else {
            print("NSJSONSerialization error")
            return nil
        }

        return body
    }

    fileprivate func serializeJSON(data: [String: AnyObject]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions(rawValue: 2))
        } catch {
            return nil
        }
    }
}

func ==(lhs: RequestType, rhs: RequestType) -> Bool {
    return !(lhs.method != rhs.method || lhs.path != rhs.path)
}

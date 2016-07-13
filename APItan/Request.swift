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

    var mockData: AnyObject? { get }
    var mockWaitTime: Int { get }
}

// Default values
public extension RequestType {
    var parameters: [String: AnyObject] {
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
    public func createRequest() -> NSURLRequest? {
        guard let url = NSURL(string: urlWithParameters) else { return nil }

        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.HTTPMethod = method.rawValue

        setHTTPHeaders(request)

        if let body = createBody() {
            request.HTTPBody = body
        }

        return request
    }

    public var urlWithParameters: String {
        return method.isQueryParameter ? "\(path)?\(parameters.stringFromHttpParameters())" : path
    }

    private func setHTTPHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if !method.isQueryParameter {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    private func createBody() -> NSData? {
        guard !method.isQueryParameter else { return nil }

        guard let body = self.serializeJSON(parameters) else {
            print("NSJSONSerialization error")
            return nil
        }

        return body
    }

    private func serializeJSON(data: [String: AnyObject]) -> NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 2))
        } catch {
            return nil
        }
    }
}

func ==(lhs: RequestType, rhs: RequestType) -> Bool {
    return !(lhs.method != rhs.method || lhs.path != rhs.path)
}

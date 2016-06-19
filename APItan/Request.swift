//
//  Request.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public protocol RequestType {
    var method: Method { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }
}

extension RequestType {
    func request() -> NSURLRequest? {
        guard let url = createUrl() else { return nil }

        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.HTTPMethod = method.rawValue

        setHTTPHeaders(request)

        if let body = createBody() {
            request.HTTPBody = body
        }

        return request
    }

    private func createUrl() -> NSURL? {
        switch method {
        case .Get, .Delete:
            return NSURL(string: "\(path)?\(parameters.stringFromHttpParameters())")
        default:
            return NSURL(string: path)
        }
    }

    private func setHTTPHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        switch method {
        case .Post, .Put, .Patch:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default: break
        }

    }

    private func createBody() -> NSData? {
        switch method {
        case .Post, .Put, .Patch:
            guard let body = self.serializeJSON(parameters) else {
                print("NSJSONSerialization error")
                return nil
            }

            return body
        default:
            return nil
        }
    }

    private func serializeJSON(data: [String: AnyObject]) -> NSData? {
        do {
            return try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 2))
        } catch {
            return nil
        }
    }
}

private extension String {
    /**
     URLとして許可された文字列かどうかを確認
     */
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
}

private extension Dictionary {
    /**
     HTTPパラメータを作成
     */
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { key, value -> String in
            let key = String(key)
            let value = String(value)
            guard let escapedKey = key.stringByAddingPercentEncodingForURLQueryValue() else { return "" }
            guard let escapedValue = value.stringByAddingPercentEncodingForURLQueryValue() else { return "" }
            return "\(escapedKey)=\(escapedValue)"
        }
        return parameterArray.joinWithSeparator("&")
    }

}

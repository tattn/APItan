//
//  Dictionary+.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/13.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

extension Dictionary {
    func stringFromHttpParameters() -> String {

        var parameters = [String]()

        for (key, value) in self {
            let keyString = "\(key)"
            let value: String = value as? String ?? ""

            if !keyString.isEmpty, let parameter = buildQuery(key: keyString, object: value as AnyObject) {
                parameters.append(parameter)
            }
        }
        return parameters.joined(separator: "&")
    }

    private func buildQuery(key: String, object: AnyObject) -> String? {
        if let value = object as? String {
            return urlEncode(key: key, value: value)
        }

        var parameters = [String]()
        switch object {
        case let items as [AnyObject]:
            for item in items {
                if let parameter = buildQuery(key: "\(key)[]", object: item) {
                    parameters.append(parameter)
                }
            }
        case let items as [String: AnyObject]:
            for (itemKey, value) in items {
                let newKey = "\(key)[\(itemKey)]"
                if value is [AnyObject] || value is [String: AnyObject],
                    let parameter = buildQuery(key: newKey, object: value) {
                    parameters.append(parameter)
                } else if let parameter = urlEncode(key: newKey, value: "\(value)") {
                    parameters.append(parameter)
                }
            }
        default: break
        }
        return parameters.joined(separator: "&")
    }

    fileprivate func urlEncode(key: String, value: String) -> String? {
        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics),
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
                return nil
        }
        return "\(encodedKey)=\(encodedValue)"
    }
}

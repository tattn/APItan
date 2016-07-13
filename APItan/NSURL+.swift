//
//  NSURL+.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/14.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

extension NSURL {
    func parameterDictionaries() -> [String: String] {
        var dictionary = [String: String]()
        guard let components = NSURLComponents(string: absoluteString) else {
            return dictionary
        }

        components.queryItems?.forEach { dictionary[$0.name] = $0.value }
        return dictionary
    }
}

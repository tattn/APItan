//
//  APIError.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

private let domain = "com.github.tattn.apitan"

/**
 APIのエラーを扱うクラス

 - JSONError: JSON関係のエラー
 */
public enum APIError: Error {
    case jsonError(String)
    case urlError(String)
    case cancelled(String)
    case unknown(String)

    var error: NSError {
        switch self {
        case .jsonError(let message):
            return self.createError(code: 10000, message: message)
        case .urlError(let message):
            return self.createError(code: 10001, message: message)
        case .cancelled(let message):
            return self.createError(code: 10002, message: message)
        case .unknown(let message):
            return self.createError(code: 50000, message: message)
        }
    }

    private func createError(code: Int, message: String) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

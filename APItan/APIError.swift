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
public enum APIError: ErrorType {
    case JSONError(String)
    case URLError(String)
    case Cancelled(String)
    case Unknown(String)

    var error: NSError {
        switch self {
        case .JSONError(let message):
            return self.createError(10000, message: message)
        case .URLError(let message):
            return self.createError(10001, message: message)
        case .Cancelled(let message):
            return self.createError(10002, message: message)
        case .Unknown(let message):
            return self.createError(50000, message: message)
        }
    }

    private func createError(code: Int, message: String) -> NSError {
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

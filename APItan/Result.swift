//
//  Result.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public enum Result<T> {
    case Success(T)
    case Failure(ErrorType)

    public var value: T? {
        switch self {
        case .Success(let value):
            return value
        default:
            return nil
        }
    }

    public var error: ErrorType? {
        switch self {
        case .Failure(let error):
            return error
        default:
            return nil
        }
    }
}

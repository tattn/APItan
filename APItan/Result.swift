//
//  Result.swift
//  APItan
//
//  Created by 田中　達也 on 2016/06/19.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

public protocol ResultType {
    associatedtype Value
    associatedtype Error

    var isSuccess: Bool { get }
    var isFailure: Bool { get }

    var value: Value? { get }
    var error: Error? { get }
}

public enum Result<T>: ResultType {
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

    public var isSuccess: Bool {
        switch self {
        case .Success(_):
            return true
        default:
            return false
        }
    }

    public var isFailure: Bool {
        return !isSuccess
    }
}

public extension Array where Element: ResultType {
    var isSuccess: Bool {
        return filter { $0.isFailure }.isEmpty
    }

    var isFailure: Bool {
        return !isSuccess
    }
}

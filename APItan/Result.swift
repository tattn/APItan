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
    case success(T)
    case failure(Error)

    public var value: T? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }

    public var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success(_):
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

    public var values: [Element.Value?] {
        return flatMap { $0.value }
    }

    public var errors: [Element.Error?] {
        return flatMap { $0.error }
    }

    public var isSuccess: Bool {
        return filter { $0.isFailure }.isEmpty
    }

    public var isFailure: Bool {
        return !isSuccess
    }
}

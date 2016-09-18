//
//  Promise.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/02.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

private protocol InternalPromiseType: class {
    var processes: [(Any) -> RequestType?] { get set }
    var alwaysProcess: (() -> Void)? { get set }
    var failProcess: ((Any?) -> Void)? { get set }

    var error: Any? { get set }
    var isError: Bool { get set }
    var isFinished: Bool { get set }

    var nextRequests: [RequestType]? { get set }
}

public protocol PromiseType: class {
    associatedtype T
    associatedtype U

    func next(completion: @escaping (T) -> U?) -> Self
    func next(completion: @escaping (T) -> Void) -> Self
    func always(completion: @escaping () -> Void) -> Self
    func fail(completion: @escaping (Any?) -> Void) -> Self
}

private extension InternalPromiseType {

    func finish() {
        guard !isFinished else {
            alwaysProcess?()
            return
        }

        failProcess?(error)
        alwaysProcess?()
        isError = true
        isFinished = true
    }
}

private extension PromiseType {
    var internalSelf: InternalPromiseType {
        return self as! InternalPromiseType
    }
}

public extension PromiseType {
    public func next(completion: @escaping (T) -> Void) -> Self {
        return next { obj -> U? in
            completion(obj)
            return nil
        }
    }

    public func always(completion: @escaping () -> Void) -> Self {
        if internalSelf.isFinished {
            completion()
        } else {
            internalSelf.alwaysProcess = completion
        }
        return self
    }

    public func fail(completion: @escaping (Any?) -> Void) -> Self {
        if internalSelf.isError {
            internalSelf.isFinished = true
            completion(internalSelf.error)
            internalSelf.alwaysProcess?()
        } else {
            internalSelf.failProcess = completion
        }
        return self
    }
}

public final class Promise: InternalPromiseType, PromiseType {

    public typealias T = Any
    public typealias U = RequestType

    fileprivate var nextRequests: [RequestType]?

    var processes: [(Any) -> RequestType?] = []
    var alwaysProcess: (() -> Void)?
    var failProcess: ((Any?) -> Void)?

    var error: Any?
    var isError = false
    var isFinished = false

    init(request: RequestType) {
        nextRequests = [request]
    }

    public func next(completion: @escaping (Any) -> RequestType?) -> Self {
        guard !isError else { return self }

        if let nextRequest = nextRequests?.first {
            self.nextRequests = nil
            runProcess(request: nextRequest, completion: completion)
        } else {
            processes.append(completion)
        }
        return self
    }

    private func runProcess(request: RequestType, completion: @escaping (Any) -> RequestType?) {
        APItan.send(request: request) { result in
            switch result {
            case .success(let json):
                switch completion(json) {
                case nil:
                    self.isFinished = true
                case let request:
                    self.nextProcess(request: request)
                    return
                }
            case .failure(let error):
                self.error = error as NSError
            }

            self.nextProcess(request: nil)
        }
    }

    private func nextProcess(request: RequestType?) {
        guard !isFinished, let request = request else {
            finish()
            return
        }

        if let process = processes.shift() {
            runProcess(request: request, completion: process)
        } else {
            nextRequests = [request]
        }
    }
}

private extension Array {
    mutating func shift() -> Element? {
        return isEmpty ? nil : self.remove(at: startIndex)
    }
}

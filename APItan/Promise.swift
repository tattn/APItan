//
//  Promise.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/02.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

private protocol InternalPromiseType: class {
    var processes: [AnyObject -> RequestType?] { get set }
    var alwaysProcess: (() -> Void)? { get set }
    var failProcess: (AnyObject? -> Void)? { get set }

    var error: AnyObject? { get set }
    var isError: Bool { get set }
    var isFinished: Bool { get set }

    var nextRequests: [RequestType]? { get set }
}

public protocol PromiseType: class {
    associatedtype T
    associatedtype U

    func next(completion: T -> U?) -> Self
    func next(completion: T -> Void) -> Self
    func always(completion: () -> Void) -> Self
    func fail(completion: (AnyObject?) -> Void) -> Self
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
    private var internalSelf: InternalPromiseType {
        return self as! InternalPromiseType
    }
}

public extension PromiseType {
    public func next(completion: T -> Void) -> Self {
        return next { obj -> U? in
            completion(obj)
            return nil
        }
    }

    public func always(completion: () -> Void) -> Self {
        if internalSelf.isFinished {
            completion()
        } else {
            internalSelf.alwaysProcess = completion
        }
        return self
    }

    public func fail(completion: (AnyObject?) -> Void) -> Self {
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
    public typealias T = AnyObject
    public typealias U = RequestType

    private var nextRequests: [RequestType]?

    var processes: [AnyObject -> RequestType?] = []
    var alwaysProcess: (() -> Void)?
    var failProcess: (AnyObject? -> Void)?

    var error: AnyObject?
    var isError = false
    var isFinished = false

    init(request: RequestType) {
        nextRequests = [request]
    }

    public func next(completion: AnyObject -> RequestType?) -> Promise {
        guard !isError else { return self }

        if let nextRequest = nextRequests?.first {
            self.nextRequests = nil
            runProcess(request: nextRequest, completion: completion)
        } else {
            processes.append(completion)
        }
        return self
    }

    private func runProcess(request request: RequestType, completion: AnyObject -> RequestType?) {
        APItan.send(request: request) { result in
            switch result {
            case .Success(let json):
                switch completion(json) {
                case nil:
                    self.isFinished = true
                case let request:
                    self.nextProcess(request: request)
                    return
                }
            case .Failure(let error):
                self.error = error as NSError
            }

            self.nextProcess(request: nil)
        }
    }

    private func nextProcess(request request: RequestType?) {
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
        return isEmpty ? nil : self.removeAtIndex(startIndex)
    }
}

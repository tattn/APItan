//
//  Promise.swift
//  APItan
//
//  Created by 田中　達也 on 2016/07/02.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

protocol PromiseType: class {
    associatedtype T
    associatedtype U

    var processes: [AnyObject -> RequestType?] { get }
    var alwaysProcess: (() -> Void)? { get }
    var failProcess: (AnyObject? -> Void)? { get }

    var error: AnyObject? { get }
    var isError: Bool { get }
    var isFinished: Bool { get }

    func next(completion: T -> U?) -> Promise
    func next(completion: T -> Void) -> Promise
    func always(completion: () -> Void) -> Promise
    func fail(completion: (AnyObject?) -> Void) -> Promise
}

public final class Promise: PromiseType {

    private var nextRequests: [RequestType]?

    private(set) var processes: [AnyObject -> RequestType?] = []
    private(set) var alwaysProcess: (() -> Void)?
    private(set) var failProcess: (AnyObject? -> Void)?

    private(set) var error: AnyObject?
    private(set) var isError = false
    private(set) var isFinished = false

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

    public func next(completion: AnyObject -> Void) -> Promise {
        return next { obj -> RequestType? in
            completion(obj)
            return nil
        }
    }

    public func always(completion: () -> Void) -> Promise {
        if isFinished {
            completion()
        } else {
            alwaysProcess = completion
        }
        return self
    }

    public func fail(completion: (AnyObject?) -> Void) -> Promise {
        if isError {
            isFinished = true
            completion(error)
            alwaysProcess?()
        } else {
            failProcess = completion
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
        guard !isFinished else {
            alwaysProcess?()
            return // finish
        }

        guard let request = request else {
            failProcess?(error)
            alwaysProcess?()
            isError = true
            isFinished = true
            return // finish
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

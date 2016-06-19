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
}

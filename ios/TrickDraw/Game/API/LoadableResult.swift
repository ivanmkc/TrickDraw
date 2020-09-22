//
//  LoadableResult.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-21.
//  Copyright © 2020 Google. All rights reserved.
//

enum LoadableResult<Result, Error> {
    case loading
    case success(Result)
    case failure(Error)
}

//
//  ModelDataHandling.swift
//  TrickDraw
//
//  Created by Ivan Cheung on 2020-09-15.
//  Copyright © 2020 Google. All rights reserved.
//

/// Information about a model file or labels file.
typealias FileInfo = (name: String, extension: String)

protocol ModelDataHandling {
    associatedtype Input
    associatedtype Inference
    
    var threadCount: Int { get }
    
    func runModel(input: Input) -> Result<Inference, Error>
}

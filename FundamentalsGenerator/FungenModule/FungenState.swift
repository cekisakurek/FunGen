//
//  FungenState.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture

public struct FungenState: Equatable {
    public var inputFile: String
    public var outputFolder: String
    public var verbose = false
    public var baseURL: URL
    
    public var rootModule: Module?
    public var dependencies: [Module] = []
}

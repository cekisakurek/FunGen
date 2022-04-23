//
//  FungenState.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture

struct FungenState: Equatable {
    
    var inputFile: String
    var outputFolder: String
    var baseURL: URL
    
    var rootModule: Module?
    var dependencies: [Module] = []
    
    var stateFileCreated = false
    var actionFileCreated = false
    var extensionFileCreated = false
    
    var verbose = false
    
    func isFileCreationFinished() -> Bool {
        return stateFileCreated && actionFileCreated && extensionFileCreated
    }
}

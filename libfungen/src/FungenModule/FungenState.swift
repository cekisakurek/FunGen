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
    public var templatesFolder: String?
    public var baseURL: URL
    
    public var rootModule: Module?
    public var dependencies: [Module] = []
    
    public var stateFileCreated = false
    public var actionFileCreated = false
    public var extensionFileCreated = false
    
    public var verbose = false
    
    public func isFileCreationFinished() -> Bool {
        if let rootModule = rootModule {
            return (extensionFileCreated || (rootModule.countOfSubmodules(type: "scope") == 0)) && stateFileCreated && actionFileCreated
        }
        return false
    }
    
    public var generatedStateContent: String?
    public var generatedActionContent: String?
    public var generatedExtensionContent: String?
    
    public init(inputFile: String, outputFolder: String, templatesFolder: String?, baseURL: URL, verbose: Bool) {
        self.inputFile = inputFile
        self.outputFolder = outputFolder
        self.templatesFolder = templatesFolder
        self.baseURL = baseURL
        self.verbose = verbose
    }
}

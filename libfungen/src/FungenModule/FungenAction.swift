//
//  FungenAction.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation

public struct ModuleContent: Equatable {
    public var module: Module?
    public var content: String?
}

public enum FungenAction: Equatable {
    
    case loadRootModule
    case rootModuleLoaded(Result<Module, NSError>)
    
    case loadModule
    case moduleLoaded(Result<Module, NSError>)
    
    case resolveDependencies(Module)
    case dependenciesResolved(Result<[Module], NSError>)
    
    case generate
    
    // State
    case loadStateFileTemplate(fromPath: String?)
    case stateFileTemplateLoaded(Result<String, NSError>)
    
    case generateStateFile(from: Module, dependencies: [Module], template: String)
    case stateFileGenerated(Result<ModuleContent, NSError>)
    case stateFileWritten(Result<String, NSError>)

    // Action
    case loadActionFileTemplate(fromPath: String?)
    case actionFileTemplateLoaded(Result<String, NSError>)
    
    case generateActionFile(from: Module, dependencies: [Module], template: String)
    case actionFileGenerated(Result<ModuleContent, NSError>)
    case actionFileWritten(Result<String, NSError>)
    
    // Extension
    case loadExtensionFileTemplate(fromPath: String?)
    case extensionFileTemplateLoaded(Result<String, NSError>)
    
    case generateExtensionFile(from: Module, dependencies: [Module], template: String)
    case extensionFileGenerated(Result<ModuleContent, NSError>)
    case extensionFileWritten(Result<String, NSError>)
    
    case exit
}


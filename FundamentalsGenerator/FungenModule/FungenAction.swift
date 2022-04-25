//
//  FungenAction.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation

enum FungenAction {
    
    case loadRootModule
    case rootModuleLoaded(Result<Module, NSError>)
    
    case loadModule
    case moduleLoaded(Result<Module, NSError>)
    
    case resolveDependencies(Module)
    case dependenciesResolved(Result<[Module], NSError>)
    
    case generate
    
    case loadStateFileTemplate(fromPath: String)
    case stateFileTemplateLoaded(Result<String, NSError>)
    
    case generateStateFile(from: Module, dependencies: [Module], template: String)
    case stateFileGenerated(Result<(Module, String), NSError>)
    case stateFileWritten(Result<String, NSError>)
    
    case loadActionFileTemplate(fromPath: String)
    case actionFileTemplateLoaded(Result<String, NSError>)
    
    case generateActionFile(from: Module, dependencies: [Module], template: String)
    case actionFileGenerated(Result<(Module, String), NSError>)
    case actionFileWritten(Result<String, NSError>)
    
    case loadExtensionFileTemplate(fromPath: String)
    case extensionFileTemplateLoaded(Result<String, NSError>)
    
    case generateExtensionFile(from: Module, dependencies: [Module], template: String)
    case extensionFileGenerated(Result<(Module, String), NSError>)
    case extensionFileWritten(Result<String, NSError>)
    
    case exit
}


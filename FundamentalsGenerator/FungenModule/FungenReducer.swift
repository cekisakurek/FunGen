//
//  FungenReducer.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture
import Yams
import Files
import Stencil
import os.log

let fungenReducer = Reducer<FungenState, FungenAction, FungenEnvironment> {
    state, action, environment in
    
    switch action {
        
    case .exit:
        environment.printMessage("Done!", .default, environment.verbose)
        DefaultCommand.exit()
        
        
        // Loading the Root module
    case .loadRootModule:
        return FungenLogic.loadRootModule(state: state, environment: environment)
    case let .rootModuleLoaded(.success(module)):
        return FungenLogic.rootModuleLoaded(state: &state, module: module, environment: environment)
        
        
        // Loading the dependency modules
    case .loadModule:
        return FungenLogic.loadModule(state: state, environment: environment)
    case let .moduleLoaded(.success(module)):
        return FungenLogic.moduleLoaded(state: &state, module: module, environment: environment)
        
        
        // Resolving the Dependencies
    case let .resolveDependencies(module):
        return FungenLogic.resolveDependencies(state: state, module: module, environment: environment)
    case let .dependenciesResolved(.success(dependencies)):
        return FungenLogic.dependenciesResolved(state: state, dependencies: dependencies, environment: environment)
        
        
        // Generate
    case .generate:
        return FungenLogic.generate(state: state, environment: environment)
        
        
        // State File
    case .generateStateFile(let module, let dependencies):
        return FungenLogic.generateStateFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .stateFileGenerated(.success((module, content))):
        return FungenLogic.stateFileGenerated(state: &state, module: module, content: content, environment: environment)
        
        // Action File
    case .generateActionFile(from: let module, dependencies: let dependencies):
        return FungenLogic.generateActionFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .actionFileGenerated(.success((module, content))):
        return FungenLogic.actionFileGenerated(state: &state, module: module, content: content, environment: environment)
        
        // Extension File
    case .generateExtensionFile(from: let module, dependencies: let dependencies):
        return FungenLogic.generateExtensionFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .extensionFileGenerated(.success((module, content))):
        return FungenLogic.extensionFileGenerated(state: &state, module: module, content: content, environment: environment)
        
        
        // File created
    case let .stateFileWritten(.success(filename)):
        fallthrough
    case let .actionFileWritten(.success(filename)):
        fallthrough
    case let .extensionFileWritten(.success(filename)):
        return FungenLogic.fileWritten(state: state, to: filename, environment: environment)

        
        // Errors
    case let .actionFileGenerated(.failure(error)):
        fallthrough
    case let .extensionFileGenerated(.failure(error)):
        fallthrough
    case let .stateFileGenerated(.failure(error)):
        fallthrough
    case let .stateFileWritten(.failure(error)):
        fallthrough
    case let .moduleLoaded(.failure(error)):
        fallthrough
    case let .dependenciesResolved(.failure(error)):
        fallthrough
    case let .extensionFileWritten(.failure(error)):
        fallthrough
    case let .actionFileWritten(.failure(error)):
        fallthrough
    case let .rootModuleLoaded(.failure(error)):
        environment.printErrorAndAbort(error, OSLogType.error)
    }
}





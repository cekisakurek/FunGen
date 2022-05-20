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

public let fungenReducer = Reducer<FungenState, FungenAction, FungenEnvironment> {
    state, action, environment in
    
    switch action {
        
    case .exit:
        environment.printMessage("Done!", .default, state.verbose)
        environment.exitIfPossible()
        return .none
//        DefaultCommand.exit()
        
        // Loading the Root module
    case .loadRootModule:
        return FileLoading.loadRootModule(state: state, environment: environment)
    case let .rootModuleLoaded(.success(module)):
        return FileLoading.rootModuleLoaded(state: &state, module: module, environment: environment)
        
        
        // Loading the dependency modules
    case .loadModule:
        return FileLoading.loadModule(state: state, environment: environment)
        
    case let .moduleLoaded(.success(module)):
        
        return FileLoading.moduleLoaded(state: &state, module: module, environment: environment)
        
        
        // Resolving the Dependencies
    case let .resolveDependencies(module):
        return DependencyResolution.resolveDependencies(state: state, module: module, environment: environment)
        
    case let .dependenciesResolved(.success(dependencies)):
        return DependencyResolution.dependenciesResolved(state: state, dependencies: dependencies, environment: environment)
        
        
        // Generate
    case .generate:
        return FileGeneration.generate(state: state, environment: environment)
        
        
        // State File
    case .generateStateFile(let module, let dependencies, let template):
        return FileGeneration.generateStateFile(state: state, module: module, dependencies: dependencies, environment: environment, template: template)
    case let .stateFileGenerated(.success(moduleContent)):
        state.generatedStateContent = moduleContent.content
        return FileGeneration.stateFileGenerated(state: &state, module: moduleContent.module!, content: moduleContent.content!, environment: environment)
        
        // Action File
    case .generateActionFile(from: let module, dependencies: let dependencies, let template):
        return FileGeneration.generateActionFile(state: state, module: module, dependencies: dependencies, environment: environment, template: template)
    case let .actionFileGenerated(.success(moduleContent)):
        state.generatedActionContent = moduleContent.content
        return FileGeneration.actionFileGenerated(state: &state, module: moduleContent.module!, content: moduleContent.content!, environment: environment)
        
        // Extension File
    case .generateExtensionFile(from: let module, dependencies: let dependencies, let template):
        return FileGeneration.generateExtensionFile(state: state, module: module, dependencies: dependencies, environment: environment, template: template)
    case let .extensionFileGenerated(.success(moduleContent)):
        if let content = moduleContent.content {
            state.generatedExtensionContent = content
            return FileGeneration.extensionFileGenerated(state: &state, module: moduleContent.module!, content: content, environment: environment)
        }
        return .none
        

        // File created
    case let .stateFileWritten(.success(filename)):
        fallthrough
    case let .actionFileWritten(.success(filename)):
        fallthrough
    case let .extensionFileWritten(.success(filename)):
        
        
        return FileGeneration.fileWritten(state: state, to: filename, environment: environment)

        // Loading Templates
    case .loadStateFileTemplate(fromPath: let fromPath):
        return environment.loadTemplateFile(fromPath, state.verbose, "State")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.stateFileTemplateLoaded)
    case .loadActionFileTemplate(fromPath: let fromPath):
        return environment.loadTemplateFile(fromPath, state.verbose, "Action")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.actionFileTemplateLoaded)
    case .loadExtensionFileTemplate(fromPath: let fromPath):
        return environment.loadTemplateFile(fromPath, state.verbose, "Extension")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.extensionFileTemplateLoaded)
        
    case let .stateFileTemplateLoaded(.success(content)):
        return Effect<FungenAction, Never>.init(value: .generateStateFile(from:state.rootModule!, dependencies: state.dependencies, template: content))
    
    case let .actionFileTemplateLoaded(.success(content)):
        return Effect<FungenAction, Never>.init(value: .generateActionFile(from:state.rootModule!, dependencies: state.dependencies, template: content))
    
    case let .extensionFileTemplateLoaded(.success(content)):
        return Effect<FungenAction, Never>.init(value: .generateExtensionFile(from:state.rootModule!, dependencies: state.dependencies, template: content))
        
        
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
    case let .stateFileTemplateLoaded(.failure(error)):
        fallthrough
    case let .actionFileTemplateLoaded(.failure(error)):
        fallthrough
    case let .extensionFileTemplateLoaded(.failure(error)):
        fallthrough
    case let .rootModuleLoaded(.failure(error)):
        environment.printErrorAndAbort(error)
    }
}





//
//  FileGeneration.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import os.log

extension FungenLogic {

    static func generate(state: FungenState, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating...", OSLogType.debug, environment.verbose)
        return .merge(
            Effect<FungenAction, Never>.init(value: FungenAction.generateStateFile(from:state.rootModule!, dependencies: state.dependencies)),
            Effect<FungenAction, Never>.init(value: FungenAction.generateActionFile(from:state.rootModule!, dependencies: state.dependencies)),
            Effect<FungenAction, Never>.init(value: FungenAction.generateExtensionFile(from:state.rootModule!, dependencies: state.dependencies))
        )
    }

    static func generateStateFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    
        environment.printMessage("Generating State file for \(module.name)", OSLogType.debug, environment.verbose)
        return environment.generateStateContent(module, dependencies, environment)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.stateFileGenerated)
    }

    static func stateFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("State file generated for \(module.name)", OSLogType.debug, environment.verbose)
        state.stateFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)State.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.stateFileWritten)
    }

    static func generateActionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating Action file for \(module.name)", OSLogType.debug, environment.verbose)
        return environment.generateActionContent(module, dependencies, environment)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.actionFileGenerated)
    }

    static func actionFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Action file generated for \(module.name)", OSLogType.debug, environment.verbose)
        state.actionFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Action.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.actionFileWritten)
    }


    static func generateExtensionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating Extension file for \(module.name)", OSLogType.debug, environment.verbose)
        return environment.generateStateExtensionContent(module, dependencies, environment)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.extensionFileGenerated)
    }

    static func extensionFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Extension file generated for \(module.name)", OSLogType.debug, environment.verbose)
        state.extensionFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Extension.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.extensionFileWritten)
    }

    static func fileWritten(state: FungenState, to path: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("File created at \(path)", OSLogType.default, environment.verbose)
        if state.isFileCreationFinished() {
            return Effect<FungenAction, Never>.init(value: FungenAction.exit)
                .deferred(for: 1, scheduler: environment.mainQueue)
        }
        return .none
    }

}


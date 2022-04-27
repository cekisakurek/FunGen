//
//  FileGeneration.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import os.log

struct FileGeneration {
    
    static func generate(state: FungenState, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating...", OSLogType.debug, state.verbose)
        
        // Read templates
        var effects = [Effect<FungenAction, Never>]()
        
        if let templateFolder = state.templatesFolder {
            let stateContent = FungenAction.loadStateFileTemplate(fromPath: templateFolder + "/StateTemplate.text")
            effects.append(Effect<FungenAction, Never>.init(value: stateContent))
            
            let actionContent = FungenAction.loadActionFileTemplate(fromPath: templateFolder + "/ActionTemplate.text")
            effects.append(Effect<FungenAction, Never>.init(value: actionContent))
            
            let extensionContent = FungenAction.loadExtensionFileTemplate(fromPath: templateFolder + "/ExtensionTemplate.text")
            effects.append(Effect<FungenAction, Never>.init(value: extensionContent))
        }
        else {
            
            let stateContent = FungenAction.loadStateFileTemplate(fromPath: nil)
            effects.append(Effect<FungenAction, Never>.init(value: stateContent))
            
            let actionContent = FungenAction.loadActionFileTemplate(fromPath: nil)
            effects.append(Effect<FungenAction, Never>.init(value: actionContent))
            
            let extensionContent = FungenAction.loadExtensionFileTemplate(fromPath: nil)
            effects.append(Effect<FungenAction, Never>.init(value: extensionContent))
        }
        
        return .merge(
            effects
        )
    }
    
    static func generateStateFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating State file for \(module.name)", OSLogType.debug, state.verbose)
        return environment.generateStateContent(module, dependencies, environment, template)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.stateFileGenerated)
    }
    
    static func stateFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("State file generated for \(module.name)", OSLogType.debug, state.verbose)
        state.stateFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)State.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.stateFileWritten)
    }
    
    static func generateActionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating Action file for \(module.name)", OSLogType.debug, state.verbose)
        return environment.generateActionContent(module, dependencies, environment, template)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.actionFileGenerated)
    }
    
    static func actionFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Action file generated for \(module.name)", OSLogType.debug, state.verbose)
        state.actionFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Action.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.actionFileWritten)
    }
    
    
    static func generateExtensionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Generating Extension file for \(module.name)", OSLogType.debug, state.verbose)
        return environment.generateStateExtensionContent(module, dependencies, environment, template)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.extensionFileGenerated)
    }
    
    static func extensionFileGenerated(state: inout FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Extension file generated for \(module.name)", OSLogType.debug, state.verbose)
        state.extensionFileCreated = true
        return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Extension.swift")
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.extensionFileWritten)
    }
    
    static func fileWritten(state: FungenState, to path: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("File created at \(path)", OSLogType.default, state.verbose)
//        if state.isFileCreationFinished() {
            return Effect<FungenAction, Never>.init(value: FungenAction.exit)
                .deferred(for: 1, scheduler: environment.mainQueue)
//        }
//        return .none
    }
    
}


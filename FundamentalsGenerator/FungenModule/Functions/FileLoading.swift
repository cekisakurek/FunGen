//
//  FileLoading.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import os.log

extension FungenLogic {
    
    static func loadRootModule(state: FungenState, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("Reading Module definitions from \(state.inputFile)", OSLogType.debug, state.verbose)
        return environment.loadFile(state.inputFile, state.verbose)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.rootModuleLoaded)
    }
    
    static func rootModuleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("\(module.name) has been loaded", OSLogType.debug, state.verbose)
        state.rootModule = module
        return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
    }
    
    static func loadModule(state: FungenState, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("Loading module \(state.inputFile)", OSLogType.debug, state.verbose)
        return environment.loadFile(state.inputFile, state.verbose)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.moduleLoaded)
    }
    
    static func moduleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("\(module.name) Module has been loaded", OSLogType.debug, state.verbose)
        state.dependencies.append(module)
        return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
    }
}

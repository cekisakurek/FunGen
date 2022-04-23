//
//  DependencyResolution.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import Yams
import os.log

extension FungenLogic {
    
    static func resolveDependencies(state: FungenState, module: Module, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Resolving dependencies for \(module.name)", OSLogType.debug, state.verbose)
        return environment.resolveDependencies(module, state.baseURL, false)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.dependenciesResolved)
    }
    
    static func dependenciesResolved(state: FungenState, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
        
        environment.printMessage("Dependencies resolved \(dependencies.map({ $0.name }))", OSLogType.debug, state.verbose)
        let effects = dependencies.map { item in
            Effect<FungenAction, Never>.init(value: FungenAction.moduleLoaded(.success(item)))
        }
        return .merge(effects)
    }
    
    static func resolveDependencies(module: Module, baseURL: URL?, verbose: Bool) -> Effect<[Module], NSError> {
        
        guard let dependencies = module.dependencies, let baseURL = baseURL else {
            return Effect(value: [])
        }
        
        var resultModule = module
        var results = [Module]()
        
        for dependency in dependencies {
            let url = baseURL.appendingPathComponent(dependency)
            let dependencyPath = url.relativePath
            
            guard let content = try? String(contentsOfFile: dependencyPath, encoding: .utf8) else {
                return Effect(error: FungenError.cannotReadFile(name: dependencyPath))
            }
            guard var submodule = try? YAMLDecoder().decode(Module.self, from: content) else {
                return Effect(error: FungenError.cannotDecodeFile(name: dependencyPath))
            }
            
            submodule.inputFilename = dependency
            submodule.baseURL = baseURL
            results.append(submodule)
            
            for state in submodule.states {
                resultModule.states.insert(state)
            }
        }
        return Effect(value: results)
    }
}

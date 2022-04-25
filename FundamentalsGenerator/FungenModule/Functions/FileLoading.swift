//
//  FileLoading.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import os.log
import Yams
import Files

struct FileLoading {
    
    static func writeFile(content: String, folder: String, subfolder: String, filename: String) -> Effect<String, NSError> {
        
        guard let folder = try? Folder(path: folder).createSubfolder(named: subfolder) else {
            return Effect(error: FungenError.outputFolderNotReachable)
        }
        guard let file = try? folder.createFile(named: filename) else {
            return Effect(error: FungenError.cannotCreateFile(name: filename))
        }
        
        try? file.delete()
        
        guard let _ = try? file.write(content) else  {
            return Effect(error: FungenError.cannotWriteFile(name: filename))
        }
        return Effect(value: file.url.absoluteString)
    }
    
    static func loadFile(filename: String, verbose: Bool) -> Effect<Module, NSError> {
        
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            return Effect(error: FungenError.cannotReadFile(name: filename))
        }
        guard var module = try? YAMLDecoder().decode(Module.self, from: content) else {
            return Effect(error: FungenError.cannotDecodeFile(name: filename))
        }
        
        module.inputFilename = filename
        return Effect(value: module)
    }
    
    static func loadTemplateFile(filename: String?, verbose: Bool, name: String?) -> Effect<String, NSError> {
        
        // if filename exist use it. otherwise use default
        if let filename = filename {
            guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
                return Effect(error: FungenError.cannotReadFile(name: filename))
            }
            return Effect(value: content)
        }
        else {
            if name == "Action" {
                return Effect(value: actionTemplate)
            }
            else if name == "State" {
                return Effect(value: stateTemplate)
            }
            else if name == "Extension" {
                return Effect(value: stateExtensionTemplate)
            }
            else {
                return Effect(error: FungenError.cannotFindTemplateFile(name: name!))
            }
        }
    }
    
    
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

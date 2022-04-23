//
//  Rendering.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import Files
import Yams

extension FungenLogic {
    
    static func generateStateContent(module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<(Module, String), NSError> {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["protocols"] = module.protocols
        context["states"] = module.allStates()
        context["imports"] = module.imports
        
        guard let rendered = try? environment.stencil.renderTemplate(string: stateTemplate, context: context) else {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "State"))
        }
        return Effect(value: (module, rendered))
    }
    
    static func generateActionContent(module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<(Module, String), NSError> {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["actions"] = module.actions
        context["submodules"] = Array(module.submodules)
        context["imports"] = module.imports
        
        guard let rendered = try? environment.stencil.renderTemplate(string: actionTemplate, context: context) else {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Action"))
        }
        return Effect(value: (module, rendered))
    }
    
    static func generateStateExtensionContent(module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<(Module, String), NSError> {
        
        var module = module
        module.applyDependencies(dependencies)
        
        guard module.submodules.count > 0 else {
            let error = NSError(domain: "Fungen", code: -1)
            return Effect(error: error)
        }
        
        var submodules = [Module]()
        for s in module.submodules {
            if !s.identifiable {
                var object = s
                object.statesArrayForStencil = object.allStates()
                submodules.append(object)
            }
        }
        
        var context = [String: Any]()
        context["name"] = module.name
        context["submodules"] = submodules
        context["imports"] = module.imports
        
        guard let rendered = try? environment.stencil.renderTemplate(string: stateExtensionTemplate, context: context) else {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Extension"))
        }
        return Effect(value: (module, rendered))
    }
    
    
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
}

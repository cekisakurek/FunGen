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

struct Rendering {
    
    static func generateStateContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<(Module, String), NSError> {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["protocols"] = module.protocols
        context["states"] = module.allStates()
        context["imports"] = module.imports
        
        do {
            let rendered = try environment.stencil.renderTemplate(string: template, context: context)
            return Effect(value: (module, rendered))
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "State", description: "\(error))"))
        }
    }
    
    static func generateActionContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<(Module, String), NSError> {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["actions"] = module.actions
        context["submodules"] = Array(module.submodules)
        context["imports"] = module.imports
        
        do {
            let rendered = try environment.stencil.renderTemplate(string: template, context: context)
            return Effect(value: (module, rendered))
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Action", description: "\(error))"))
        }
    }
    
    static func generateStateExtensionContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<(Module, String), NSError> {
        
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
        
        do {
            let rendered = try environment.stencil.renderTemplate(string: template, context: context)
            return Effect(value: (module, rendered))
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Extension", description: "\(error))"))
        }
    }
}

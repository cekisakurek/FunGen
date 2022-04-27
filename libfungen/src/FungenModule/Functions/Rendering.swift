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
    
    static func renderState(module: Module, template: String, dependencies: [Module], environment: FungenEnvironment) throws -> ModuleContent {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["protocols"] = module.protocols
        context["states"] = module.allStates()
        context["imports"] = module.imports
        
        let rendered = try environment.stencil.renderTemplate(string: template, context: context)
        return ModuleContent(module: module, content: rendered)
    }
    
    static func renderAction(module: Module, template: String, dependencies: [Module], environment: FungenEnvironment) throws -> ModuleContent {
        
        var module = module
        module.applyDependencies(dependencies)
        
        var context = [String: Any]()
        context["name"] = module.name
        context["actions"] = Array(module.actionsSet).sorted(by: {$0.name < $1.name })
        context["submodules"] = Array(module.submodules)
        context["imports"] = module.imports
        
        let rendered = try environment.stencil.renderTemplate(string: template, context: context)
        return ModuleContent(module: module, content: rendered)
    }
    
    static func renderExtension(module: Module, template: String, dependencies: [Module], environment: FungenEnvironment) throws -> ModuleContent {
        
        var module = module
        module.applyDependencies(dependencies)
        
        guard module.submodules.count > 0 else {
            
            return ModuleContent()
        }
        
        var submodules = [Module]()
        for s in module.submodules {
            if s.type == "scope" {
                var object = s
                object.states = object.allStates()
                submodules.append(object)
            }
        }
        
        var context = [String: Any]()
        context["name"] = module.name
        context["submodules"] = submodules
        context["imports"] = module.imports
        
        let rendered = try environment.stencil.renderTemplate(string: template, context: context)
        return ModuleContent(module: module, content: rendered)
    }
    
    
    
    static func generateStateContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<ModuleContent, NSError> {
        
        do {
            let mc = try self.renderState(module: module, template: template, dependencies: dependencies, environment: environment)
            return Effect(value: mc)
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "State", description: "\(error))"))
        }
    }
    
    static func generateActionContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<ModuleContent, NSError> {
        
        do {
            let mc = try self.renderAction(module: module, template: template, dependencies: dependencies, environment: environment)
            return Effect(value: mc)
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Action", description: "\(error))"))
        }
    }
    
    static func generateStateExtensionContent(module: Module, dependencies: [Module], environment: FungenEnvironment, template: String) -> Effect<ModuleContent, NSError> {
        
        do {
            let mc = try self.renderExtension(module: module, template: template, dependencies: dependencies, environment: environment)
            return Effect(value: mc)
        }
        catch {
            return Effect(error: FungenError.cannotRenderModule(name: module.name, filename: "Extension", description: "\(error))"))
        }
    }
}

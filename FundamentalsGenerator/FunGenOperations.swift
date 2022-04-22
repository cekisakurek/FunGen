//
//  FunGenOperations.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import Files
import Stencil

extension Generate {
    
    // Stencil Environment
    static let environment = Environment()
    
    func writeFile(content: String, to path: String, moduleName: String, fileName: String, fileExt: String) throws {
        
        let folder = try Folder(path: path).createSubfolder(named: moduleName)
        let file = try folder.createFile(named: fileName + "." +  fileExt)
        
        try file.delete()
        try file.write(content)
        log("Writing \(fileName + "." +  fileExt)")
    }

    func generateStateFile(for module: Module, to path: String) throws {
        log("Generating \(module.name)State.swift")
        var context = [String: Any]()
        
        context["name"] = module.name
        context["protocols"] = module.protocols
        context["states"] = Array(module.states.sorted(by: {$0.name < $1.name }))
        
        let rendered = try Generate.environment.renderTemplate(string: stateTemplate, context: context)
        try writeFile(content: rendered, to: path, moduleName: module.name, fileName: "\(module.name)State", fileExt: "swift")
        
    }

    func generateActionFile(for module: Module, to path: String) throws {

        log("Generating \(module.name)Action.swift")
        var context = [String: Any]()
        
        context["name"] = module.name
        context["actions"] = module.actions
        context["submodules"] = module.submodules
        
        let rendered = try Generate.environment.renderTemplate(string: actionTemplate, context: context)
        try writeFile(content: rendered, to: path, moduleName: module.name, fileName: "\(module.name)Action", fileExt: "swift")
    }

    func generateStateExtensionFile(for module: Module, to path: String) throws {

        guard module.submodules.count > 0 else { return }
        
        var context = [String: Any]()
        
        // Stencil does not work with Set.
        // Create a sorted state array for submodules
        var submodules = [Module]()
        for submodule in module.submodules {
            if !submodule.identifiable {
                var m = submodule
                m.statesArray = Array(submodule.states.sorted(by: {$0.name < $1.name }))
                submodules.append(m)
            }
        }
        
        context["name"] = module.name
        context["submodules"] = submodules
        log("Generating \(module.name)StateExtension.swift")
        let rendered = try Generate.environment.renderTemplate(string: stateExtensionTemplate, context: context)
        try writeFile(content: rendered, to: path, moduleName: module.name, fileName: "\(module.name)StateExtension", fileExt: "swift")
    }
}

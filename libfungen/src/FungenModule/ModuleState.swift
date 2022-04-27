//
//  ModuleState.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture

public struct Module: Equatable, Codable, Identifiable {
    
    // Stencil does not work with calculated values or functions. So we use this array in the template engine
    var statesSet: Set<StateDefinition>
    var actionsSet: Set<ActionDefinition>
    
    public var id: String { name }
    
    var inputFilename: String = ""
    var name: String
    var states: [StateDefinition] = []
    var actions: [ActionDefinition] = []
    var dependencies: [String]?
    var type: String
    
    var submodules: IdentifiedArrayOf<Module> = []
    
    var caseName: String
    
    var protocols: [String] = ["Equatable"]
    var imports: [String] = ["Foundation", "ComposableArchitecture"]
    
    var baseURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case name
        case statesSet = "states"
        case actionsSet = "actions"
        case dependencies
        case type
        case protocols
        
    }
    public init(name: String, statesSet: Set<StateDefinition>, actionsSet: Set<ActionDefinition>, dependencies: [String], type: String) {
        self.name = name
        self.statesSet = statesSet
        self.actionsSet = actionsSet
        self.dependencies = dependencies
        self.type = type
        
        let first = name.prefix(1)
        self.caseName = first.lowercased() + name[1...]
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)!
        
        self.statesSet = try container.decodeIfPresent(Set<StateDefinition>.self, forKey: .statesSet)!
        self.actionsSet = try container.decodeIfPresent(Set<ActionDefinition>.self, forKey: .actionsSet)!
        self.dependencies = try container.decodeIfPresent([String].self, forKey: .dependencies)
        
        self.type = try container.decodeIfPresent(String.self, forKey: .type)!
        
        if let protocols = try? container.decodeIfPresent([String].self, forKey: .protocols) {
            self.protocols.append(contentsOf: protocols)
        }
        
        let first = name.prefix(1)
        self.caseName = first.lowercased() + name[1...]
    }
}


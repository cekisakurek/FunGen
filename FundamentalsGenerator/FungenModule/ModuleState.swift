//
//  ModuleState.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture

struct Module: Equatable, Codable, Identifiable {
    
    // Stencil does not work with calculated values or functions. So we use this array in the template engine
    var statesSet: Set<StateDefinition>
    
    var id: String { name }
    
    var inputFilename: String = ""
    var name: String
    var states: [StateDefinition] = []
    var actions: [ActionDefinition]
    var dependencies: [String]?
    var identifiable: Bool
    
    var submodules: IdentifiedArrayOf<Module> = []
    
    var caseName: String
    
    var protocols: [String] = ["Equatable"]
    var imports: [String] = ["Foundation", "ComposableArchitecture"]
    
    var baseURL: URL?
    
    enum CodingKeys: String, CodingKey {
            case name
            case statesSet = "states"
            case actions
            case dependencies
            case identifiable
            case protocols
            
        }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)!
        
        self.statesSet = try container.decodeIfPresent(Set<StateDefinition>.self, forKey: .statesSet)!
        self.actions = try container.decodeIfPresent([ActionDefinition].self, forKey: .actions)!
        self.dependencies = try container.decodeIfPresent([String].self, forKey: .dependencies)

        self.identifiable = try container.decodeIfPresent(Bool.self, forKey: .identifiable) ?? false

        if let protocols = try? container.decodeIfPresent([String].self, forKey: .protocols) {
            self.protocols.append(contentsOf: protocols)
        }

        let first = name.prefix(1)
        self.caseName = first.lowercased() + name[1...]
    }
}


//
//  DataModel.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation

struct Module: Codable {
    
    var name: String
    var states: Set<StateDefinition>
    var actions: [ActionDefinition]
    var dependencies: [String]?
    var submodules: [Module] = []
    var identifiable: Bool
    
    var caseName: String
    var statesArray: [StateDefinition] = []
    
    var protocols: [String] = ["Equatable"]
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)!
        self.states = try container.decodeIfPresent(Set<StateDefinition>.self, forKey: .states)!
        self.actions = try container.decodeIfPresent([ActionDefinition].self, forKey: .actions)!
        self.dependencies = try container.decodeIfPresent([String].self, forKey: .dependencies)
        
        if let identifiable = try container.decodeIfPresent(Bool.self, forKey: .identifiable) {
            self.identifiable = identifiable
        }
        else {
            self.identifiable = false
        }
        
        if let protocols = try? container.decodeIfPresent([String].self, forKey: .protocols) {
            self.protocols.append(contentsOf: protocols)
        }
        
        let first = name.prefix(1)
        self.caseName = first.lowercased() + name[1...]
    }
    
    // We need to transfer submodule states to supermodule
    
    // If a module definition is identifiable then the supermodule has an array of submodules
    // This means we shouldnt merge states between this couple since it is (1 -> N) now
    mutating func addSubmodule(_ submodule: Module) {
        self.submodules.append(submodule)
        for state in submodule.states {
            if !submodule.identifiable {
                self.states.insert(state)
            }
        }
    }
    
    struct StateDefinition: Codable, Hashable, Equatable {
        var name: String
        var type: String
        var accessLevel: String
        var mutable: String

        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)!
            self.type = try container.decodeIfPresent(String.self, forKey: .type)!
            
            self.accessLevel = try container.decodeIfPresent(String.self, forKey: .accessLevel) ?? "public"
            self.mutable = try! container.decodeIfPresent(String.self, forKey: .mutable) ?? "var"
        }
        
        // We want the name property as unique identifier
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.name == rhs.name
        }
    }

    struct ActionDefinition: Codable {
        var name: String
        var subtypes: [StateDefinition]?
    }
}

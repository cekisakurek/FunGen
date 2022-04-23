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
    public var statesArrayForStencil: [StateDefinition]
    
    public var id: String { name }
    
    var inputFilename: String
    var name: String
    var states: Set<StateDefinition>
    var actions: [ActionDefinition]
    var dependencies: [String]?
    var identifiable: Bool
    
    var submodules: IdentifiedArrayOf<Module> = []
    
    var caseName: String
    
    var protocols: [String] = ["Equatable"]
    var imports: [String] = ["Foundation", "ComposableArchitecture"]
    
    var baseURL: URL?
    
    public init(from decoder: Decoder) throws {

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

        self.submodules = []
        self.inputFilename = ""
        self.statesArrayForStencil = []
    }
    
    public struct StateDefinition: Codable, Hashable, Equatable {
        var name: String
        var type: String
        var accessLevel: String
        var mutable: String

        public init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)!
            self.type = try container.decodeIfPresent(String.self, forKey: .type)!
            
            self.accessLevel = try container.decodeIfPresent(String.self, forKey: .accessLevel) ?? "public"
            self.mutable = try! container.decodeIfPresent(String.self, forKey: .mutable) ?? "var"
        }
        
        // We want the name property as unique identifier
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.name == rhs.name
        }
    }

    public struct ActionDefinition: Codable, Equatable {
        var name: String
        var subtypes: [StateDefinition]?
    }
}


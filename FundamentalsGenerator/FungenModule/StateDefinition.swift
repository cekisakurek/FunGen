//
//  StateDefinition.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

struct StateDefinition: Codable, Hashable, Equatable, Identifiable {
    
    var id: String { name }
    
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
}

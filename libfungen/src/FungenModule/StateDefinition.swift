//
//  StateDefinition.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

public struct StateDefinition: Codable, Hashable, Equatable, Identifiable {
    
    public var id: String { name }
    
    var name: String
    var type: String
    var accessLevel: String
    var mutable: String

    
    public init(name: String, type: String, accessLevel: String = "public", mutable: String = "var") {
        self.name = name
        self.type = type
        self.accessLevel = accessLevel
        self.mutable = mutable
    }
    
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

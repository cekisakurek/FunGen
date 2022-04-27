//
//  ActionDefinition.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

public struct ActionDefinition: Codable, Equatable, Hashable {
    
    var name: String
    var associatedData: [StateDefinition]?
}

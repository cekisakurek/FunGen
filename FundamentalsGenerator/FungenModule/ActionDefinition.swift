//
//  ActionDefinition.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

struct ActionDefinition: Codable, Equatable {
    
    var name: String
    var subtypes: [StateDefinition]?
}

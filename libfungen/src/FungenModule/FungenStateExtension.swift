//
//  FungenStateExtension.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

extension Module {
    
    var allSubmodulesRecursively: [Module] {
        
        let items = self.submodules
        return items + items.flatMap { $0.allSubmodulesRecursively }
    }
    
    // This looks ugly
    mutating func applyDependencies(_ subModules: [Module]) {
        
        guard subModules.count > 0 else { return }
        
        if let dependencies = dependencies {
            for depName in dependencies {
                for sub in subModules {
                    if sub.inputFilename == depName {
                        var sub = sub
                        sub.applyDependencies(subModules)
                        submodules.append(sub)
                    }
                }
            }
        }
    }
    // This looks ugly too!
    func allStates() -> [StateDefinition] {
        guard self.statesSet.count > 0 else { return [] }
        var states = Set<StateDefinition>()
        for state in self.statesSet {
            states.insert(state)
        }
        for submodule in allSubmodulesRecursively {
            if submodule.type == "scope" {
                for state in submodule.allStates() {
                    states.insert(state)
                }
            }
        }
        return states.sorted(by: {$0.name < $1.name })
    }
    
    func countOfSubmodules(type: String) -> Int {
        var count = 0
        for s in self.submodules {
            if s.type == type {
                count += 1
            }
        }
        return count
    }
    
    
}

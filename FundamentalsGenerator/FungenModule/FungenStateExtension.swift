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
    
    public mutating func applyDependencies(_ subModules: [Module]) {
        guard subModules.count > 0 else { return }
        
        // This looks ugly
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
    
    public func allStates() -> [StateDefinition] {
        // This looks ugly too!
        var states = Set<StateDefinition>()
        for state in self.states {
            states.insert(state)
        }
        for submodule in allSubmodulesRecursively {
            if !submodule.identifiable {
                for state in submodule.allStates() {
                    states.insert(state)
                }
            }
        }
        return states.sorted(by: {$0.name < $1.name })
    }
}

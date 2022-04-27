//
//  FunGen.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture
import libfungen

final class FunGenerator {
    
    var state: FungenState?
    var store: Store<FungenState, FungenAction>!
    var viewStore: ViewStore<FungenState, FungenAction>!
    
    func run(for state: FungenState) {
        
        self.store = Store(initialState: state, reducer: fungenReducer, environment: .live )
        self.viewStore = ViewStore(store)
        
        let group = DispatchGroup()
        group.enter()
        self.viewStore.send(.loadRootModule)
        DispatchQueue.main.async {
            
            group.leave()
        }
        
        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        group.notify(queue: .main) {
            self.viewStore.send(.generate)
        }
    }
    
    func run(inputFile: String, outputFolder: String, templatesFolder: String?, baseURL: URL, verbose: Bool) {
        let state = FungenState(inputFile: inputFile, outputFolder: outputFolder, templatesFolder: templatesFolder, baseURL: baseURL, verbose: verbose)
        run(for: state)
    }
}

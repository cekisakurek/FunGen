//
//  FunGen.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture

final class FunGenerator {
    
    var verbose: Bool = false
    
    var state: FungenState?
    var store: Store<FungenState, FungenAction>!
    var viewStore: ViewStore<FungenState, FungenAction>!
    
    func run(for state: FungenState) {
        
        var environment = FungenEnvironment.live
        environment.verbose = verbose
        
        self.store = Store(initialState: state, reducer: fungenReducer, environment: environment )
        self.viewStore = ViewStore(store)
        self.viewStore.send(.loadRootModule)
        
        // We need to wait until everything is resolved
        // TODO: Find a better way of doing this
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.viewStore.send(.generate)
        }
    }
    
    func run(inputFile: String, outputFolder: String, baseURL: URL) {
        let state = FungenState(inputFile: inputFile, outputFolder: outputFolder, baseURL: baseURL)
        run(for: state)
    }
}

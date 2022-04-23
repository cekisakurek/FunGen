//
//  FunGen.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture


public final class FunGenerator {
    
    
    
    static let generator = FunGenerator()
    
    private var outputs: [String: String] = [:]
    
    var verbose: Bool = false
    
    var state: FungenState?
    var store: Store<FungenState, FungenAction>!
    var viewStore: ViewStore<FungenState, FungenAction>!
    
    func run(for state: FungenState) {
        self.store = Store(initialState: state, reducer: appReducer, environment: .live )
        self.viewStore = ViewStore(store)
        self.viewStore.send(.loadRootModule)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.viewStore.send(.generate)
        }
    }
}

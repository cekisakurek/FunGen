//
//  Generate.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ArgumentParser
import ComposableArchitecture

struct Generate: ParsableCommand {
        
    public static let configuration = CommandConfiguration(abstract: "Generate a Composable Architecture module.")
    
    @Option(name: .customLong("input"), help: "The file path for input file. Please check out the examples for the definitions")
    private var inputFile: String
    
    @Option(name: .customLong("output"), help: "Output file directory. Required to be already existing.")
    private var outputFolder: String
    
    @Option(name: .customLong("templates"), help: "Templates directory")
    private var templateFolder: String?
    
    @Flag var verbose = false
    
    func run() throws {
        
        let baseURL = URL(fileURLWithPath: inputFile, isDirectory: false).deletingLastPathComponent()
        FunGenerator.generator.run(inputFile: inputFile, outputFolder: outputFolder, templatesFolder: templateFolder, baseURL: baseURL, verbose: verbose)
    }
}

final class FunGenerator {
    
    var state: FungenState?
    var store: Store<FungenState, FungenAction>!
    var viewStore: ViewStore<FungenState, FungenAction>!
    
    func run(for state: FungenState) {
        
        self.store = Store(initialState: state, reducer: fungenReducer, environment: .live )
        self.viewStore = ViewStore(store)
        
        self.viewStore.send(.loadRootModule)
        
        let group = DispatchGroup()
        group.enter()
        
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


extension FunGenerator {
    static let generator = FunGenerator()
}

//
//  Generate.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ArgumentParser

struct Generate: ParsableCommand {
        
    public static let configuration = CommandConfiguration(abstract: "Generate a Composable Architecture module")
    
    @Option(name: .customLong("input"), help: "The file path for input file. Please check out the examples for the definitions")
    private var inputFile: String
    
    @Option(name: .customLong("output"), help: "Output file directory. Required to be already existing.")
    private var outputFolder: String
        
    @Option(name: .customLong("verbose"), help: "Verbose. Default is false")
    private var verbose: Bool = false
    
//    @Argument(help: "URL to retrieve", transform: ({ return URL(string: $0)!})) var string: URL

    func run() throws {
        
        let baseURL = URL(fileURLWithPath: inputFile, isDirectory: false).deletingLastPathComponent()
        let state = FungenState(inputFile: inputFile, outputFolder: outputFolder, baseURL: baseURL)
        FunGenerator.generator.run(for: state)
    }
}

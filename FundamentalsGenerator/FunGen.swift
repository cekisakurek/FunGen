//
//  FunGen.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ArgumentParser
import Yams

struct FunGen: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool to generate state and action for composable architecture",
        subcommands: [Generate.self])
    
    init() { }
}

enum FunError: Error {
    case runtimeError(String)
}


struct Generate: ParsableCommand {
        
    public static let configuration = CommandConfiguration(abstract: "Generate a module")
    
    @Argument(help: "URL of the definition file ")
    private var inputFile: String
    
    @Argument(help: "Output directory")
    private var outputFolder: String
        
    @Argument(help: "Verbose")
    private var verbose: Bool = false
    
    func run() throws {
        log("Generating Files from: \(inputFile) to \(outputFolder)")
        try generateFiles(from: inputFile, to: outputFolder)
    }
    
    @discardableResult
    func generateFiles(from path: String, to output: String) throws -> Module {
        
        
        let module = try generateAndLinkDependencies(from: path, to: output)

        try generateStateFile(for: module, to: output)
        try generateActionFile(for: module, to: output)
        
        if module.submodules.count > 0 {
            try generateStateExtensionFile(for: module, to: output)
        }
        return module
    }
    
    func generateAndLinkDependencies(from path: String, to output: String) throws -> Module  {
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            throw FunError.runtimeError("Cannot read file content at path: \(path)")
        }
        var module = try YAMLDecoder().decode(Module.self, from: contents)
        
        for dependency in module.dependencies ?? [] {
            let url = URL(fileURLWithPath: path, isDirectory: false).deletingLastPathComponent().appendingPathComponent(dependency)
            let dependencyPath = url.relativePath
            let submodule = try generateFiles(from: dependencyPath, to: output)
            log("Dependency generated \(module.name) -> \(submodule.name)")
            module.addSubmodule(submodule)
        }
        
        return module
        
    }
    
    func log(_ string: String) {
        if verbose {
            print(string)
        }
    }
}

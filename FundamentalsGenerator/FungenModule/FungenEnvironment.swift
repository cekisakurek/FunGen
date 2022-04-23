//
//  FungenEnvironment.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture
import Yams
import Files

struct FungenEnvironment {
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public var loadFile: (_ inputFile: String, _ verbose: Bool) -> Effect<Module, NSError>
    public var resolveDependencies: (_ module: Module, _ baseURL: URL?, _ verbose: Bool) -> Effect<[Module], NSError>
    
    public var generateStateContent: (_ module: Module,_ dependencies: [Module]) -> Effect<(Module, String), NSError>
    public var generateActionContent: (_ module: Module, _ dependencies: [Module]) -> Effect<(Module, String), NSError>
    public var generateStateExtensionContent: (_ module: Module, _ dependencies: [Module]) -> Effect<(Module, String), NSError>
    public var writeFile: (_ content: String, _ folder: String, _ subfolder: String, _ filename: String) -> Effect<String, NSError>
    
    static let live = Self(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                           loadFile: loadFile(filename:verbose:),
                           resolveDependencies: resolveDependencies(module:baseURL:verbose:),
                           generateStateContent: generateStateContent(module:dependencies:),
                           generateActionContent: generateActionContent(module:dependencies:),
                           generateStateExtensionContent: generateStateExtensionContent(module:dependencies:),
                           writeFile: writeFile(content:folder:subfolder:filename:)
    )
}

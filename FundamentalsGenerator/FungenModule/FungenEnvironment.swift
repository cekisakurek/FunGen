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
import Stencil

struct FungenEnvironment {
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let stencil = Stencil.Environment()
    
    var loadFile: (_ inputFile: String, _ verbose: Bool) -> Effect<Module, NSError>
    
    var resolveDependencies: (_ module: Module, _ baseURL: URL?, _ verbose: Bool) -> Effect<[Module], NSError>
    
    var generateStateContent: (_ module: Module,_ dependencies: [Module],_ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var generateActionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var generateStateExtensionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var writeFile: (_ content: String, _ folder: String, _ subfolder: String, _ filename: String) -> Effect<String, NSError>
    
    var printMessage: (_ message: String) -> Void
    
    var printErrorAndAbort: (_ message: String) -> Never
    
    var verbose = false
    
    static let live = Self(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                           loadFile: FungenLogic.loadFile(filename:verbose:),
                           resolveDependencies: FungenLogic.resolveDependencies(module:baseURL:verbose:),
                           generateStateContent: FungenLogic.generateStateContent(module:dependencies:environment:),
                           generateActionContent: FungenLogic.generateActionContent(module:dependencies:environment:),
                           generateStateExtensionContent: FungenLogic.generateStateExtensionContent(module:dependencies:environment:),
                           writeFile: FungenLogic.writeFile(content:folder:subfolder:filename:),
                           printMessage: printMessage(_:),
                           printErrorAndAbort: printErrorAndAbort(message:)
    )
    
    static func printMessage(_ message: String){
        print("INFO: \(message)")
    }

    static func printErrorAndAbort(message: String) -> Never {
        print("ERROR: \(message)")
        return abort()
    }
}





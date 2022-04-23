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
import os.log

struct FungenEnvironment {
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let stencil = Stencil.Environment()
    
    var loadFile: (_ inputFile: String, _ verbose: Bool) -> Effect<Module, NSError>
    
    var resolveDependencies: (_ module: Module, _ baseURL: URL?, _ verbose: Bool) -> Effect<[Module], NSError>
    
    var generateStateContent: (_ module: Module,_ dependencies: [Module],_ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var generateActionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var generateStateExtensionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment) -> Effect<(Module, String), NSError>
    
    var writeFile: (_ content: String, _ folder: String, _ subfolder: String, _ filename: String) -> Effect<String, NSError>
    
    var printMessage: (_ message: String, _ logType: OSLogType, _ verbose: Bool) -> Void
    
    var printErrorAndAbort: (_ message: NSError) -> Never
        
    static let live = Self(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                           loadFile: FungenLogic.loadFile(filename:verbose:),
                           resolveDependencies: FungenLogic.resolveDependencies(module:baseURL:verbose:),
                           generateStateContent: FungenLogic.generateStateContent(module:dependencies:environment:),
                           generateActionContent: FungenLogic.generateActionContent(module:dependencies:environment:),
                           generateStateExtensionContent: FungenLogic.generateStateExtensionContent(module:dependencies:environment:),
                           writeFile: FungenLogic.writeFile(content:folder:subfolder:filename:),
                           printMessage: printMessage(_:logType:verbose:),
                           printErrorAndAbort: printErrorAndAbort(error:)
    )
    
    
    
    static func printMessage(_ message: String, logType: OSLogType, verbose: Bool) {
        
        if logType == .default {
            os_log("%@", log: OSLog.default, type: logType, message)
        }
        else if verbose {
            os_log("%@", log: OSLog.default, type: logType, message)
            
        }
        
    }

    static func printErrorAndAbort(error: NSError) -> Never {
        os_log("%@", log: OSLog.default, type: .error, error.localizedDescription)
        return abort()
    }
}





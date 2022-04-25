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
    var loadTemplateFile: (_ inputFile: String?, _ verbose: Bool, _ name: String) -> Effect<String, NSError>
    
    
    
    var resolveDependencies: (_ module: Module, _ baseURL: URL?, _ verbose: Bool) -> Effect<[Module], NSError>
    
    var generateStateContent: (_ module: Module,_ dependencies: [Module],_ environment: FungenEnvironment, _ template: String) -> Effect<(Module, String), NSError>
    
    var generateActionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment, _ template: String) -> Effect<(Module, String), NSError>
    
    var generateStateExtensionContent: (_ module: Module, _ dependencies: [Module], _ environment: FungenEnvironment, _ template: String) -> Effect<(Module?, String), NSError>
    
    var writeFile: (_ content: String, _ folder: String, _ subfolder: String, _ filename: String) -> Effect<String, NSError>
    
    var printMessage: (_ message: String, _ logType: OSLogType, _ verbose: Bool) -> Void
    
    var printErrorAndAbort: (_ message: NSError) -> Never
        
    static let live = Self(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                           loadFile: FileLoading.loadFile(filename:verbose:),
                           loadTemplateFile: FileLoading.loadTemplateFile(filename:verbose:name:),
                           resolveDependencies: DependencyResolution.resolveDependencies(module:baseURL:verbose:),
                           generateStateContent: Rendering.generateStateContent(module:dependencies:environment:template:),
                           generateActionContent: Rendering.generateActionContent(module:dependencies:environment:template:),
                           generateStateExtensionContent: Rendering.generateStateExtensionContent(module:dependencies:environment:template:),
                           writeFile: FileLoading.writeFile(content:folder:subfolder:filename:),
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





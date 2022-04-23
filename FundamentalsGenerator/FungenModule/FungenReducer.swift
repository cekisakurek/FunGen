//
//  FungenReducer.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import Foundation
import ComposableArchitecture
import Yams
import Files
import Stencil

func loadRootModule(state: FungenState, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Reading Module definitions from \(state.inputFile)")
    return environment.loadFile(state.inputFile, state.verbose)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.rootModuleLoaded)
}

func rootModuleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("\(module.name) has been loaded")
    state.rootModule = module
    return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
}

func loadModule(state: FungenState, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Loading module \(state.inputFile)")
    return environment.loadFile(state.inputFile, state.verbose)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.moduleLoaded)
}

func moduleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("\(module.name) Module has been loaded")
    state.dependencies.append(module)
    return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
}

func resolveDependencies(state: FungenState, module: Module, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Resolving dependencies for \(module.name) ")
    return environment.resolveDependencies(module, state.baseURL, false)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.dependenciesResolved)
}

func dependenciesResolved(state: FungenState, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Dependencies resolved \(dependencies.map({ $0.name }))")
    let effects = dependencies.map { item in
        Effect<FungenAction, Never>.init(value: FungenAction.moduleLoaded(.success(item)))
    }
    return .merge(effects)
}

func generate(state: FungenState, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Generating...")
    let effects = [
        Effect<FungenAction, Never>.init(value: FungenAction.generateStateFile(from:state.rootModule!, dependencies: state.dependencies)),
        Effect<FungenAction, Never>.init(value: FungenAction.generateActionFile(from:state.rootModule!, dependencies: state.dependencies)),
        Effect<FungenAction, Never>.init(value: FungenAction.generateExtensionFile(from:state.rootModule!, dependencies: state.dependencies))
    ]
    return .merge(effects)
}

func generateStateFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Generating State file for \(module.name)")
    return environment.generateStateContent(module, dependencies)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.stateFileGenerated)
}

func stateFileGenerated(state: FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("State file generated for \(module.name)")
    return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)State.swift")
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.stateFileWritten)
}

func generateActionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Generating Action file for \(module.name)")
    return environment.generateActionContent(module, dependencies)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.actionFileGenerated)
}

func actionFileGenerated(state: FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Action file generated for \(module.name)")
    return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Action.swift")
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.actionFileWritten)
}


func generateExtensionFile(state: FungenState, module: Module, dependencies: [Module], environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Generating Extension file for \(module.name)")
    return environment.generateStateExtensionContent(module, dependencies)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.extensionFileGenerated)
}

func extensionFileGenerated(state: FungenState, module: Module, content: String, environment: FungenEnvironment) -> Effect<FungenAction, Never> {
    print("Extension file generated for \(module.name)")
    return environment.writeFile(content, state.outputFolder, module.name, "\(module.name)Extension.swift")
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(FungenAction.extensionFileWritten)
}



func writeFile(content: String, folder: String, subfolder: String, filename: String) -> Effect<String, NSError> {

    guard let folder = try? Folder(path: folder).createSubfolder(named: subfolder) else {
        return Effect(error: FunGenError.outputFolderNotReachable)
    }
    guard let file = try? folder.createFile(named: filename) else {
        return Effect(error: FunGenError.cannotCreateFile(name: filename))
    }
    try? file.delete()
    guard let _ = try? file.write(content) else  {
        return Effect(error: FunGenError.cannotWriteFile(name: filename))
    }
    return Effect(value: file.url.absoluteString)
}

func loadFile(filename: String, verbose: Bool) -> Effect<Module, NSError> {
    guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
        return Effect(error: FunGenError.cannotReadFile(name: filename))
    }
    guard var module = try? YAMLDecoder().decode(Module.self, from: content) else {
        return Effect(error: FunGenError.cannotDecodeFile(name: filename))
    }
    module.inputFilename = filename
    return Effect(value: module)
}


func resolveDependencies(module: Module, baseURL: URL?, verbose: Bool) -> Effect<[Module], NSError> {

    guard let dependencies = module.dependencies, let baseURL = baseURL else {
        return Effect(value: [])
    }
    
    var resultModule = module
    var results = [Module]()
    
    for dependency in dependencies {
        
        let url = baseURL.appendingPathComponent(dependency)
        let dependencyPath = url.relativePath
        
        guard let content = try? String(contentsOfFile: dependencyPath, encoding: .utf8) else {
            return Effect(error: FunGenError.cannotReadFile(name: dependencyPath))
        }
        guard var submodule = try? YAMLDecoder().decode(Module.self, from: content) else {
            return Effect(error: FunGenError.cannotDecodeFile(name: dependencyPath))
        }
        submodule.inputFilename = dependency
        submodule.baseURL = baseURL
        results.append(submodule)
        
        for state in submodule.states {
            resultModule.states.insert(state)
        }
    }
        
    return Effect(value: results)
}

func generateStateContent(module: Module, dependencies: [Module]) -> Effect<(Module, String), NSError> {
    
    var module = module
    module.applyDependencies(dependencies)
    
    var context = [String: Any]()
    context["name"] = module.name
    context["protocols"] = module.protocols
    context["states"] = module.allStates()
    context["imports"] = module.imports
    
    guard let rendered = try? FunGenerator.environment.renderTemplate(string: stateTemplate, context: context) else {
        return Effect(error: FunGenError.cannotRenderModule(name: module.name, filename: "State"))
    }
    
    return Effect(value: (module, rendered))
}


func generateActionContent(module: Module, dependencies: [Module]) -> Effect<(Module, String), NSError> {
    
    var module = module
    module.applyDependencies(dependencies)
    
    var context = [String: Any]()
    context["name"] = module.name
    context["actions"] = module.actions
    context["submodules"] = Array(module.submodules)
    context["imports"] = module.imports
    
    guard let rendered = try? FunGenerator.environment.renderTemplate(string: actionTemplate, context: context) else {
        return Effect(error: FunGenError.cannotRenderModule(name: module.name, filename: "Action"))
    }
    return Effect(value: (module, rendered))
}

func generateStateExtensionContent(module: Module, dependencies: [Module]) -> Effect<(Module, String), NSError> {

    var module = module
    module.applyDependencies(dependencies)
    
    guard module.submodules.count > 0 else {
        let error = NSError(domain: "Fungen", code: -1)
        return Effect(error: error)
    }
    
    var submodules = [Module]()
    for s in module.submodules {
        if !s.identifiable {
            var object = s
            object.statesArrayForStencil = object.allStates()
            submodules.append(object)
        }
    }
    
    var context = [String: Any]()
    
    context["name"] = module.name
    context["submodules"] = submodules
    context["imports"] = module.imports

    
    guard let rendered = try? FunGenerator.environment.renderTemplate(string: stateExtensionTemplate, context: context) else {
        return Effect(error: FunGenError.cannotRenderModule(name: module.name, filename: "Extension"))
    }
    return Effect(value: (module, rendered))
}



let appReducer = Reducer<FungenState, FungenAction, FungenEnvironment> { state, action, environment in
    switch action {

        // Loading the Root module
    case .loadRootModule: return loadRootModule(state: state, environment: environment)
    case let .rootModuleLoaded(.success(module)): return rootModuleLoaded(state: &state, module: module, environment: environment)
        
        // Loading the dependency modules
    case .loadModule: return loadModule(state: state, environment: environment)
    case let .moduleLoaded(.success(module)): return moduleLoaded(state: &state, module: module, environment: environment)
        
        // Resolving the Dependencies
    case let .resolveDependencies(module): return resolveDependencies(state: state, module: module, environment: environment)
    case let .dependenciesResolved(.success(dependencies)): return dependenciesResolved(state: state, dependencies: dependencies, environment: environment)
        
        // Generate
    case .generate: return generate(state: state, environment: environment)
        
        // State File
    case .generateStateFile(let module, let dependencies): return generateStateFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .stateFileGenerated(.success((module, content))): return stateFileGenerated(state: state, module: module, content: content, environment: environment)
        
        // Action File
    case .generateActionFile(from: let module, dependencies: let dependencies): return generateActionFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .actionFileGenerated(.success((module, content))): return actionFileGenerated(state: state, module: module, content: content, environment: environment)
        
        // Extension File
    case .generateExtensionFile(from: let module, dependencies: let dependencies): return generateExtensionFile(state: state, module: module, dependencies: dependencies, environment: environment)
    case let .extensionFileGenerated(.success((module, content))): return extensionFileGenerated(state: state, module: module, content: content, environment: environment)
        
    case let .stateFileWritten(.success(filename)):
        print("State file written to \(filename)")
        return .none
    case let .actionFileWritten(filename):
        print("Action file written to \(filename)")
        return .none
    case let .extensionFileWritten(.success(filename)):
        print("Extension file written to \(filename)")
        return .none
        
        // Errors
    case let .actionFileGenerated(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
    case let .extensionFileGenerated(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
        
    case let .stateFileGenerated(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
        
    case let .stateFileWritten(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
        
    case let .rootModuleLoaded(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
        
    case let .moduleLoaded(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
        
    case let .dependenciesResolved(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
    case let .extensionFileWritten(.failure(error)):
        printError(message: error.localizedDescription)
        abort()
    }
}


func printError(message: String) {
    print("ERROR: \(message)")
}

extension FunGenerator {
    // Stencil Environment
    static let environment = Stencil.Environment()
}

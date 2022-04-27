//
//  libfungenTests.swift
//  libfungenTests
//
//  Created by Cihan Kisakurek on 27.04.22.
//

import XCTest
@testable import libfungen
import ComposableArchitecture
import Yams

func doNothing() {
    
}

class libfungenTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func lessonModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "lesson", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "lesson.yaml"
        module.baseURL = baseURL
        return module
    }
    private func courseModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "course", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "course.yaml"
        module.baseURL = baseURL
        return module
    }
    
    private func authenticationModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "authentication", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "authentication.yaml"
        module.baseURL = baseURL
        return module
    }
    
    private func registrationModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "registration", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "registration.yaml"
        module.baseURL = baseURL
        return module
    }
    
    private func userModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "user", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "user.yaml"
        module.baseURL = baseURL
        return module
    }
    
    private func coursesModule(baseURL: URL) -> Module {
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "courses", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = "courses.yaml"
        module.baseURL = baseURL
        return module
    }
    
    private func appModule(filename: String) -> Module {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "app", ofType: "yaml")!
        let str = try! String(contentsOfFile: path)
        
        var module = try! YAMLDecoder().decode(Module.self, from: str)
        module.inputFilename = filename
        return module
    }
    
    
    
    func testModuleReducer() {
        
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "app", ofType: "yaml")!
        
        let inputFile = path
        
        
        let baseURL = URL(fileURLWithPath: inputFile, isDirectory: false).deletingLastPathComponent()
        let scheduler = DispatchQueue.test
        let outputFolder = ""
        
        
        let verbose = true
        
        
        let coursesModule = coursesModule(baseURL: baseURL)
        let userModule = userModule(baseURL: baseURL)
        let registrationModule = registrationModule(baseURL: baseURL)
        let authenticationModule = authenticationModule(baseURL: baseURL)
        let courseModule = courseModule(baseURL: baseURL)
        let lessonModule = lessonModule(baseURL: baseURL)
        
        let state = FungenState(inputFile: inputFile,
                                outputFolder: outputFolder,
                                templatesFolder: nil,
                                baseURL: baseURL,
                                verbose: verbose)
        
        
        
        let env = FungenEnvironment(mainQueue: scheduler.eraseToAnyScheduler(),
                                    loadFile: FileLoading.loadFile(filename:verbose:),
                                    loadTemplateFile: FileLoading.loadTemplateFile(filename:verbose:name:),
                                    resolveDependencies: DependencyResolution.resolveDependencies(module:baseURL:verbose:),
                                    generateStateContent: Rendering.generateStateContent(module:dependencies:environment:template:),
                                    generateActionContent: Rendering.generateActionContent(module:dependencies:environment:template:),
                                    generateStateExtensionContent: Rendering.generateStateExtensionContent(module:dependencies:environment:template:),
                                    writeFile: FileLoading.writeFile(content:folder:subfolder:filename:),
                                    printMessage: FungenEnvironment.printMessage(_:logType:verbose:),
                                    printErrorAndAbort: FungenEnvironment.printErrorAndAbort(error:),
                                    exitIfPossible: doNothing
                                    
        )
        
        
        
        let store = TestStore(
            initialState: state,
            reducer: fungenReducer,
            environment: env)
        
        
        store.send(.loadRootModule) { _ in }
        scheduler.advance()
        
        var appModule = appModule(filename: inputFile)
        
        store.receive(.rootModuleLoaded(.success(appModule))) { state in
            state.rootModule = appModule
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(appModule)) {
            $0.rootModule = appModule
        }
        
        scheduler.advance()
        
        store.receive(.dependenciesResolved(.success([coursesModule, userModule]))) { state in }
        
        scheduler.advance()
        
        store.receive(.moduleLoaded(.success(coursesModule))) { state in
            state.dependencies = [coursesModule]
        }
        
        scheduler.advance()
        
        store.receive(.moduleLoaded(.success(userModule))) { state in
            state.dependencies = [coursesModule, userModule]
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(coursesModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(userModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([courseModule]))) { state in
            
        }
        
        scheduler.advance()
        store.receive(.moduleLoaded(.success(courseModule))) { state in
            state.dependencies = [coursesModule, userModule, courseModule]
        }
        
        
        scheduler.advance()
        store.receive(.resolveDependencies(courseModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([authenticationModule, registrationModule]))) { state in
            
        }
        
        scheduler.advance()
        store.receive(.moduleLoaded(.success(authenticationModule))) { state in
            state.dependencies = [coursesModule, userModule, courseModule, authenticationModule]
        }
        
        scheduler.advance()
        store.receive(.moduleLoaded(.success(registrationModule))) { state in
            state.dependencies = [coursesModule, userModule, courseModule, authenticationModule, registrationModule]
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(authenticationModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(registrationModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([lessonModule]))) { state in
            
        }
        
        scheduler.advance()
        store.receive(.moduleLoaded(.success(lessonModule))) { state in
            state.dependencies = [coursesModule, userModule, courseModule, authenticationModule, registrationModule, lessonModule]
        }
        
        scheduler.advance()
        store.receive(.resolveDependencies(lessonModule)) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([]))) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([]))) { state in
            
        }
        
        scheduler.advance()
        store.receive(.dependenciesResolved(.success([]))) { state in
            
        }
        
        store.send(.generate) { _ in }
        scheduler.advance()
        
        store.receive(.loadStateFileTemplate(fromPath: nil))
        scheduler.advance()
        
        
        
        
        store.receive(.loadActionFileTemplate(fromPath: nil))
        scheduler.advance()
        store.receive(.loadExtensionFileTemplate(fromPath: nil))
        
        scheduler.advance()
        store.receive(.stateFileTemplateLoaded(.success(stateTemplate)))
        
        
        scheduler.advance()
        store.receive(.generateStateFile(from: appModule, dependencies: [coursesModule, userModule, courseModule, authenticationModule, registrationModule, lessonModule], template: stateTemplate))
        
        
        scheduler.advance()
        store.receive(.actionFileTemplateLoaded(.success(actionTemplate)))
        
        scheduler.advance()
        store.receive(.generateActionFile(from: appModule, dependencies: [coursesModule, userModule, courseModule, authenticationModule, registrationModule, lessonModule], template: actionTemplate))
        
        
        scheduler.advance()
        store.receive(.extensionFileTemplateLoaded(.success(extensionTemplate)))
        
        scheduler.advance()
        store.receive(.generateExtensionFile(from: appModule, dependencies: [coursesModule, userModule, courseModule, authenticationModule, registrationModule, lessonModule], template: extensionTemplate))
        
        
        scheduler.advance()
        
        let allDeps = [coursesModule, userModule, courseModule, authenticationModule, registrationModule, lessonModule]
        
        
        appModule.applyDependencies(allDeps)
        let appModuleStateContent = ModuleContent(module: appModule,
                                                  content: appStateOutput)
        
        store.receive(.stateFileGenerated(.success(appModuleStateContent))) { state in
            state.stateFileCreated = true
            state.generatedStateContent = appModuleStateContent.content
        }
        
        scheduler.advance()
        
        
        
        
        
        let appModuleActionContent = ModuleContent(module: appModule,
                                                   content: appActionOutput)
        
        store.receive(.actionFileGenerated(.success(appModuleActionContent))) { state in
            state.actionFileCreated = true
            state.generatedActionContent = appModuleActionContent.content
        }
        
        scheduler.advance()
        
        
        let appModuleExtensionContent = ModuleContent(module: appModule,
                                                      content: appExtensionOutput)
        
        store.receive(.extensionFileGenerated(.success(appModuleExtensionContent))) { state in
            state.extensionFileCreated = true
            state.generatedExtensionContent = appModuleExtensionContent.content
        }
        
        scheduler.advance()
        store.receive(.stateFileWritten(.success("file:///private/tmp/App/AppState.swift")))
        
        scheduler.advance()
        store.receive(.actionFileWritten(.success("file:///private/tmp/App/AppAction.swift")))
        
        scheduler.advance()
        
        //        let extensionPath = "file:///private/tmp/App/AppExtension.swift"
        
        store.receive(.extensionFileWritten(.success("file:///private/tmp/App/AppExtension.swift"))) { state in
            
        }
        
        
        
        scheduler.advance(by: 1)
        store.receive(.exit) { state in}
        store.receive(.exit) { state in}
        store.receive(.exit) { state in}
        
    }
    
    
    var appActionOutput: String {
        let bundle = Bundle(for: type(of: self))
        var string =  try! String(contentsOfFile: bundle.path(forResource: "AppAction.swift", ofType: "txt")!)
        string.removeLast()
        return string
    }
    
    var appStateOutput: String {
        let bundle = Bundle(for: type(of: self))
        var string =  try! String(contentsOfFile: bundle.path(forResource: "AppState.swift", ofType: "txt")!)
        string.removeLast()
        return string
    }
    
    var appExtensionOutput: String {
        let bundle = Bundle(for: type(of: self))
        var string =  try! String(contentsOfFile: bundle.path(forResource: "AppExtension.swift", ofType: "txt")!)
        string.removeLast()
        return string
    }
    
//    var stateTemplate: String {
//        let bundle = Bundle(for: type(of: self))
//        let string =  try! String(contentsOfFile: bundle.path(forResource: "StateTemplate", ofType: "text")!)
////        string.removeLast()
//        return string
//    }
//    
//    var actionTemplate: String {
//        let bundle = Bundle(for: type(of: self))
//        let string =  try! String(contentsOfFile: bundle.path(forResource: "ActionTemplate", ofType: "text")!)
////        string.removeLast()
//        return string
//    }
//    
//    var extensionTemplate: String {
//        let bundle = Bundle(for: type(of: self))
//        let string =  try! String(contentsOfFile: bundle.path(forResource: "ExtensionTemplate", ofType: "text")!)
////        string.removeLast()
//        return string
//    }
    
    
    
    //    func testExample() throws {
    //        // This is an example of a functional test case.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //        // Any test you write for XCTest can be annotated as throws and async.
    //        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    //        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    //    }
    //
    //    func testPerformanceExample() throws {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}









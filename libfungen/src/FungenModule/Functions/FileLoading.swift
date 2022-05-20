//
//  FileLoading.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation
import ComposableArchitecture
import os.log
import Yams
import Files
import SwiftFormat
import SwiftFormatConfiguration
import SwiftSyntaxParser


//struct FileLoadingMock {
//    static func loadFile(filename: String, verbose: Bool) -> Effect<Module, NSError> {
//        
//        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
//            return Effect(error: FungenError.cannotReadFile(name: filename))
//        }
//        guard var module = try? YAMLDecoder().decode(Module.self, from: content) else {
//            return Effect(error: FungenError.cannotDecodeFile(name: filename))
//        }
//        
//        module.inputFilename = filename
//        return Effect(value: module)
//    }
//    
//    static func loadTemplateFile(filename: String?, verbose: Bool, name: String?) -> Effect<String, NSError> {
//        
//        if name == "Action" {
//            return Effect(value: actionTemplate)
//        }
//        else if name == "State" {
//            return Effect(value: stateTemplate)
//        }
//        else if name == "Extension" {
//            return Effect(value: stateExtensionTemplate)
//        }
//        else {
//            return Effect(error: FungenError.cannotFindTemplateFile(name: name!))
//        }
//    }
//    
////    static let exampleAppContent =
////            """
////            name: App
////            type: module
////            states:
////              - name: deviceToken
////                type: Data?
////              - name: keychainCredentials
////                type: Fundamentals.Credentials?
////            actions:
////              - name: appDidFinishLaunching
////              - name: didRegisterForRemoteNotifications
////                associatedData:
////                  - type: Result<Data, NSError>
////                    name: result
////              - name: didLoadCredentials
////                associatedData:
////                  - type: Result<Fundamentals.Credentials, NSError>
////                    name: result
////              - name: loadCourses
////              - name: didLoadCourses
////                associatedData:
////                  - type: Result<[CourseState], NSError>
////                    name: result
////            dependencies:
////              - courses.yaml
////              - user.yaml
////            """
////    
////    static let exampleUserContent =
////            """
////            name: User
////            type: scope
////            states:
////              - name: showRegistrationForm
////                type: Bool
////              - name: profilePictureURL
////                type: URL?
////            actions:
////              - name: toggleShowRegistrationForm
////              - name: loadAppUserProfile
////              - name: didLoadAppUser
////                associatedData:
////                  - type: Result<Fundamentals.AppUser, NSError>
////                    name: result
////            dependencies:
////              - authentication.yaml
////              - registration.yaml
////            """
////    
////    static let exampleCoursesContent =
////            """
////            name: Courses
////            type: scope
////            states:
////              - name: courses
////                type: IdentifiedArrayOf<CourseState>
////              - name: authToken
////                type: String?
////            actions:
////              - name: course
////                associatedData:
////                  - name: id
////                    type: CourseState.ID
////                  - name: action
////                    type: CourseAction
////            dependencies:
////              - course.yaml
////            """
////    
////    static let exampleCourseContent =
////            """
////            name: Course
////            type: item
////            protocols:
////              - Identifiable
////            states:
////              - name: id
////                type: UUID
////              - name: mediaURL
////                type: URL?
////              - name: title
////                type: String
////              - name: description
////                type: String
////              - name: authToken
////                type: String?
////              - name: lessons
////                type: IdentifiedArrayOf<LessonState>
////            actions:
////              - name: loadLessons
////              - name: lesson
////                associatedData:
////                  - name: id
////                    type: LessonState.ID
////                  - name: action
////                    type: LessonAction
////              - name: didLoadLessons
////                associatedData:
////                  - type: Result<[LessonState], NSError>
////                    name: result
////            dependencies:
////              - lesson.yaml
////            """
////    
////    static let exampleLessonContent =
////            """
////            name: Lesson
////            type: item
////            protocols:
////              - Identifiable
////            states:
////              - name: id
////                type: UUID
////              - name: videoURL
////                type: URL?
////              - name: title
////                type: String
////              - name: description
////                type: String
////              - name: authToken
////                type: String?
////            actions:
////              - name: watchVideo
////            """
////
////    
////    static let exampleAuthenticationContent =
////            """
////            name: Authentication
////            type: scope
////            states:
////              - name: email
////                type: String
////              - name: password
////                type: String
////              - name: authToken
////                type: String?
////              - name: isLoginButtonDisabled
////                type: Bool
////            actions:
////              - name: loginButtonTapped
////              - name: saveCredentials
////              - name: emailTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: passwordTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: authenticationResponse
////                associatedData:
////                  - type: Result<String, NSError>
////                    name: result
////            """
////    static let exampleRegistrationContent =
////            """
////            name: Registration
////            type: scope
////            states:
////              - name: name
////                type: String
////              - name: email
////                type: String
////              - name: password
////                type: String
////              - name: passwordConfirmation
////                type: String
////              - name: authToken
////                type: String?
////              - name: isRegisterButtonDisabled
////                type: Bool
////            actions:
////              - name: registerButtonTapped
////              - name: saveCredentials
////              - name: usernameTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: emailTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: passwordTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: passwordConfirmationTextFieldChanged
////                associatedData:
////                  - type: String
////                    name: text
////              - name: registrationResponse
////                associatedData:
////                  - type: Result<String, NSError>
////                    name: result
////            """
//}

struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

struct MemoryOutputStream: TextOutputStream {
    var content: String = ""
    let encoding: String.Encoding

    init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        content.append(string)
    }
}



struct FileLoading {
    
    static func writeFile(content: String, folder: String, subfolder: String, filename: String) -> Effect<String, NSError> {
        
        guard let folder = try? Folder(path: folder).createSubfolder(named: subfolder) else {
            return Effect(error: FungenError.outputFolderNotReachable)
        }
        guard let file = try? folder.createFile(named: filename) else {
            return Effect(error: FungenError.cannotCreateFile(name: filename))
        }
        
        try? file.delete()
        
        var config = Configuration()
        config.indentation = .spaces(4)
        config.indentSwitchCaseLabels = true
        let formatter = SwiftFormatter(configuration: config)
        
        do {
            var output = MemoryOutputStream()
            try formatter.format(source: content, assumingFileURL: nil, to: &output)
            let _ = try SyntaxParser.parse(source: output.content)
            
            guard let _ = try? file.write(output.content) else  {
                return Effect(error: FungenError.cannotWriteFile(name: filename))
            }
        }
        catch {
            return Effect(error: FungenError.error(with: error))
            
        }
        return Effect(value: file.url.absoluteString)
    }
    
    static func loadFile(filename: String, verbose: Bool) -> Effect<Module, NSError> {
        
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
            return Effect(error: FungenError.cannotReadFile(name: filename))
        }
        guard var module = try? YAMLDecoder().decode(Module.self, from: content) else {
            return Effect(error: FungenError.cannotDecodeFile(name: filename))
        }
        
        module.inputFilename = filename
        return Effect(value: module)
    }
    
    static func loadTemplateFile(filename: String?, verbose: Bool, name: String) -> Effect<String, NSError> {
        
        // if filename exist use it. otherwise use default
        if let filename = filename {
            guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else {
                return Effect(error: FungenError.cannotReadFile(name: filename))
            }
            return Effect(value: content)
        }
        else {
            if name == "Action" {
                return Effect(value: actionTemplate)
            }
            else if name == "State" {
                return Effect(value: stateTemplate)
            }
            else if name == "Extension" {
                return Effect(value: extensionTemplate)
            }
            else {
                return Effect(error: FungenError.cannotFindTemplateFile(name: name))
            }
        }
    }
    
    
    static func loadRootModule(state: FungenState, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("Reading Module definitions from \(state.inputFile)", OSLogType.debug, state.verbose)
        return environment.loadFile(state.inputFile, state.verbose)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.rootModuleLoaded)
    }
    
    static func rootModuleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("\(module.name) has been loaded", OSLogType.debug, state.verbose)
        state.rootModule = module
        return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
    }
    
    static func loadModule(state: FungenState, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("Loading module \(state.inputFile)", OSLogType.debug, state.verbose)
        return environment.loadFile(state.inputFile, state.verbose)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(FungenAction.moduleLoaded)
    }
    
    static func moduleLoaded(state: inout FungenState, module: Module, environment: FungenEnvironment)
    -> Effect<FungenAction, Never> {
        
        environment.printMessage("\(module.name) Module has been loaded", OSLogType.debug, state.verbose)
        state.dependencies.append(module)
        return Effect<FungenAction, Never>.init(value: FungenAction.resolveDependencies(module))
    }
}

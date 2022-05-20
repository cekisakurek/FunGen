//
//  FungenError.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

struct FungenError {
    
    static let outputFolderNotReachable = NSError(domain: "FungenError", code: -800,
                                                  userInfo: [NSLocalizedDescriptionKey: "Output folder is not reachable."])
    
    static func cannotCreateFile(name: String) -> NSError {
        return NSError(domain: "FungenError", code: -801,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot create file at path \(name)"])
    }
    
    static func cannotWriteFile(name: String) -> NSError {
        return NSError(domain: "FungenError", code: -802,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot create file at path \(name)"])
    }
    
    static func cannotReadFile(name: String) -> NSError {
        return NSError(domain: "FungenError", code: -803,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot read file at path \(name)"])
    }
    
    static func cannotDecodeFile(name: String) -> NSError {
        return NSError(domain: "FungenError", code: -804,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot decode content at path \(name)"])
    }
    
    static func cannotRenderModule(name: String, filename: String, description: String) -> NSError {
        return NSError(domain: "FungenError", code: -805,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot render \(filename) for \(name) Reason: \(description)"])
    }
    
    static func cannotFindTemplateFile(name: String) -> NSError {
        return NSError(domain: "FungenError", code: -804,
                       userInfo: [NSLocalizedDescriptionKey: "Cannot find template \(name)"])
    }
    
    static func error(with error: Error) -> NSError {
        return NSError(domain: "FungenError", code: -819,
                       userInfo: [NSLocalizedDescriptionKey: "Error \(error)"])
    }
}

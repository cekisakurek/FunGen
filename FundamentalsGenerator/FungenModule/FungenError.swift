//
//  FungenError.swift
//  fungen
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import Foundation

struct FunGenError {
    
    static let outputFolderNotReachable = NSError(domain: "FunGen", code: -800, userInfo: [NSLocalizedDescriptionKey: "Output folder is not reachable."])
    
    static func cannotCreateFile(name: String) -> NSError {
        return NSError(domain: "FunGen", code: -801, userInfo: [NSLocalizedDescriptionKey: "Cannot create file at path \(name)"])
    }
    
    static func cannotWriteFile(name: String) -> NSError {
        return NSError(domain: "FunGen", code: -802, userInfo: [NSLocalizedDescriptionKey: "Cannot create file at path \(name)"])
    }
    
    static func cannotReadFile(name: String) -> NSError {
        return NSError(domain: "FunGen", code: -803, userInfo: [NSLocalizedDescriptionKey: "Cannot read file at path \(name)"])
    }
    
    static func cannotDecodeFile(name: String) -> NSError {
        return NSError(domain: "FunGen", code: -804, userInfo: [NSLocalizedDescriptionKey: "Cannot decode content at path \(name)"])
    }
    
    static func cannotRenderModule(name: String, filename: String) -> NSError {
        return NSError(domain: "FunGen", code: -805, userInfo: [NSLocalizedDescriptionKey: "Cannot render \(filename) for \(name)"])
    }
}

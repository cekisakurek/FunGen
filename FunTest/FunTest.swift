//
//  FunTest.swift
//  FunTest
//
//  Created by Cihan Kisakurek on 22.04.22.
//

import XCTest

@testable import FundamentalsGenerator

extension StringProtocol where Self: RangeReplaceableCollection {
    var removingAllWhitespaces: Self {
        filter(\.isWhitespace.negated)
    }
    mutating func removeAllWhitespaces() {
        removeAll(where: \.isWhitespace)
    }
}
extension Bool {
    var negated: Bool { !self }
}


class FunTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    private func module(name: String) throws -> Module {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: name, ofType: "yaml")!
        let content = try String(contentsOfFile: path, encoding: .utf8)
        return try FunGenerator.generator.decodeModule(from: content)
    }
    
    private func validation(name: String) throws -> String {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: name, ofType: "text")!
        return try String(contentsOfFile: path, encoding: .utf8)
    }
    
    
    func testUserModule() throws {

        let app = try module(name: "user")
        
        var dependencies = [
            try module(name: "authentication"),
            try module(name: "registration")
        ]
             
        var results = [GeneratorResult]()
        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)
        
        for result in results {
            let validation = try validation(name: result.fileName)
            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)
            
        }
    }
    
    func testRegistrationModule() throws {

        let app = try module(name: "registration")
        
        var dependencies = [Module]()
             
        var results = [GeneratorResult]()
        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)
        
        for result in results {
            let validation = try validation(name: result.fileName)
            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)
            
        }
    }
    
    func testLessonModule() throws {

        let app = try module(name: "lesson")
        
        var dependencies = [Module]()
             
        var results = [GeneratorResult]()
        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)
        
        for result in results {
            let validation = try validation(name: result.fileName)
            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)
            
        }
    }
    
//    func testCoursesModule() throws {
//
//        let app = try module(name: "courses")
//
//        let dependencies = [
//            try module(name: "course")
//        ]
//
//        var results = [GeneratorResult]()
//        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)
//
//        for result in results {
//            let validation = try validation(name: result.fileName)
//            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)
//
//        }
//    }
    
    func testCourseModule() throws {

        let app = try module(name: "course")

        var dependencies = [
            try module(name: "lesson")
        ]

        var results = [GeneratorResult]()
        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)

        for result in results {
            let validation = try validation(name: result.fileName)
            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)

        }
    }
    
    func testAuthenticationModule() throws {

        let app = try module(name: "authentication")

        var dependencies = [Module]()

        var results = [GeneratorResult]()
        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)

        for result in results {
            let validation = try validation(name: result.fileName)
            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)

        }
    }
//    
//    func testAppModule() throws {
//
//        let app = try module(name: "app")
//
//        var dependencies = [
//            try module(name: "courses"),
//            try module(name: "user")
//        ]
//
//        var results = [GeneratorResult]()
//        try FunGenerator.generator.generate(for: app, into: &results, dependencies: dependencies, baseURL: nil)
//
//        for result in results {
//            let validation = try validation(name: result.fileName)
//            XCTAssert(result.content.removingAllWhitespaces  == validation.removingAllWhitespaces)
//
//        }
//    }
}

//
//  DefaultCommand.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import ArgumentParser

struct DefaultCommand: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "CLI tool to generate state and action files for composable architecture",
        subcommands: [Generate.self])
    
    init() { }
}

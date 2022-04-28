//
//  DefaultCommand.swift
//  FundamentalsGenerator
//
//  Created by Cihan Kisakurek on 23.04.22.
//

import ArgumentParser

struct DefaultCommand: ParsableCommand {
    
    static let configuration = CommandConfiguration(
        abstract: "CLI tool to generate state and action files for composable architecture\n\n\n https://github.com/cekisakurek/FunGen\n\n\n",
        subcommands: [Generate.self])
    
    init() { }
}

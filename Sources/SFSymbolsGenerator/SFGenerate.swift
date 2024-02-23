//
//  SFGenerate.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

import ArgumentParser
import Foundation

@main
struct SFGenerate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sfgenerate",
        abstract: "A tool to generate a type-safe SFSymbolsResource definition for use in apps."
    )

    mutating func run() throws {
    }
}

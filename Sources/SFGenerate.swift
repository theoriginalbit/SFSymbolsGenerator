//
//  SFGenerate.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 24/2/2024.
//

import ArgumentParser

@main
struct SFGenerate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sfgenerate",
        abstract: "A tool to generate a type-safe SFSymbolsResource definition for use in apps."
    )
    
    @OptionGroup
    var versionOptions: VersionOptions
    
    @Flag
    var exportLocalizations: LocalizationFlag?
    
    @Flag(
        name: [.customShort("s"), .customLong("export-semantic-symbols")],
        inversion: .prefixedNo,
        help: #"When enabled the generated source will contain semantic symbols. E.g. a "search" symbol for the "magnifyingglass" symbol"#
    )
    var exportSemanticSymbols: Bool = true
    
    @Option
    var enabledExtensions: [EnabledExtensions] = EnabledExtensions.allCases
    
    @Option(help: "The Swift access modifier to use in the generated output")
    var accessModifier: AccessModifier = .internal
    
    mutating func run() throws {
        let options = LocalizationOptionTransformer.transform(exportLocalizations)
        let frontend = try GenerateFrontend(
            accessModifier: accessModifier,
            safeNameGenerator: .idiomatic,
            exportLocalizationOptions: options
        )
        try frontend.run()
    }
}

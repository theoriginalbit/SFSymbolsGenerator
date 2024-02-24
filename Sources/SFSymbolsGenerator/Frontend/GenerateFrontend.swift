//
//  GenerateFrontend.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

import Files
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

class GenerateFrontend {
    private let nameAvailability: NameAvailability
    private let nameAliases: [String: String]
    private let noFillToFill: [String: String]
    private let semanticToDescriptive: [String: String]
    private let symbolRestrictions: [String: String]

    private init(resourceFolder resources: Folder) throws {
        let decoder = PropertyListDecoder()

        func readStringsFile(_ filename: String) throws -> [String: String] {
            let file = try resources.file(at: "\(filename).strings")
            let data = try file.read()
            var format: PropertyListSerialization.PropertyListFormat = .openStep
            return try decoder.decode([String: String].self, from: data, format: &format)
        }

        let nameAvailabilityFile = try resources.file(named: "name_availability.plist")
        let nameAvailabilityData = try nameAvailabilityFile.read()

        nameAvailability = try decoder.decode(NameAvailability.self, from: nameAvailabilityData)
        nameAliases = try readStringsFile("name_aliases")
        noFillToFill = try readStringsFile("nofill_to_fill")
        semanticToDescriptive = try readStringsFile("semantic_to_descriptive_name")
        symbolRestrictions = try readStringsFile("symbol_restrictions")
    }

    convenience init() throws {
        let resources = try Folder(path: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources")
        try self.init(resourceFolder: resources)
    }

    func run() throws {
        
    }
}

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
    private let exportLocalizationOptions: LocalizationOption

    /// A set of all language codes, used to determine if the last segment of a symbol is a language code.
    private let isoLanguageCodes = Set(Locale.LanguageCode.isoLanguageCodes.map(\.identifier))

    private init(resourceFolder resources: Folder, exportLocalizationOptions: LocalizationOption) throws {
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

        self.exportLocalizationOptions = exportLocalizationOptions
    }

    convenience init(exportLocalizationOptions: LocalizationOption) throws {
        let resources = try Folder(path: "/System/Library/PrivateFrameworks/SFSymbols.framework/Versions/A/Resources/CoreGlyphs.bundle/Contents/Resources")
        try self.init(resourceFolder: resources, exportLocalizationOptions: exportLocalizationOptions)
    }

    func run() throws {
        var symbolsNames = Array(nameAvailability.symbols.keys) // .sorted()

        if !exportLocalizationOptions.contains(.languageCode) {
            symbolsNames.removeAll(where: hasLanguageCode(_:))
        }
        if !exportLocalizationOptions.contains(.rightToLeft) {
            symbolsNames.removeAll(where: hasRightToLeftSpecifier(_:))
        }

        let restrictedSymbols = symbolsNames.filter { symbolRestrictions[$0] != nil }.prefix(2)
        symbolsNames = Array(symbolsNames.prefix(2))
        symbolsNames.append(contentsOf: restrictedSymbols)

        let source = try SourceFileSyntax {
            // Imports
            "import Foundation"

            canImportUIKit {
                "import UIKit"
            }

            // Support type
            """
            /// A SFSymbol resource.
            struct SFSymbolResource: Hashable {
                /// A SFSymbol system name.
                fileprivate let systemName: String

                /// Initialize a `SFSymbolResource` with `systemName`.
                init(systemName name: String) {
                    self.systemName = name
                }
            }

            """

            try ExtensionDeclSyntax("extension SFSymbolResource") {
                for propertyName in symbolsNames {
                    """


                    /// The \(literal: propertyName) SF Symbol.
                    ///
                    /// \(raw: symbolRestrictions[propertyName].map { "- Important: \($0)" } ?? " ")
                    @available(\(availabilityOfSymbol(propertyName)))
                    static var \(raw: propertyName.asIdentifier): SFSymbolResource {
                        SFSymbolResource(systemName: \(literal: propertyName))
                    }
                    """
                }
            }

            try canImportUIKit {
                availabilityHeaderUIKit {
                    """
                    extension UIKit.UIImage {
                        /// Initialize a `UIImage` with a SFSymbol resource.
                        convenience init(systemSymbolResource resource: SFSymbolResource) {
                            self.init(systemName: resource.name)!
                        }
                    }
                    """
                }

                try availabilityHeaderUIKit {
                    try ExtensionDeclSyntax("extension UIKit.UIImage") {
                        for propertyName in symbolsNames {
                            """


                            /// The \(literal: propertyName) SF Symbol.
                            ///
                            /// \(raw: symbolRestrictions[propertyName].map { "- Important: \($0)" } ?? " ")
                            @available(\(availabilityOfSymbol(propertyName)))
                            static var \(raw: propertyName.asIdentifier): UIKit.UIImage {
                                UIKit.UIImage(systemSymbolResource: .\(raw: propertyName.asIdentifier))
                            }
                            """
                        }
                    }
                }
            }
        }

        print(source.formatted())
    }

    func hasLanguageCode(_ value: String) -> Bool {
        if let lastSegment = value.split(separator: ".").last {
            return isoLanguageCodes.contains(String(lastSegment))
        }
        return false
    }

    func hasRightToLeftSpecifier(_ value: String) -> Bool {
        value.hasSuffix(".rtl")
    }

    @AvailabilityArgumentListBuilder
    func availabilityOfSymbol(
        _ symbolName: String
    ) -> AvailabilityArgumentListBuilder.FinalResult {
        let availability = nameAvailability.yearToRelease[nameAvailability.symbols[symbolName]!]!

        // This definitely feels like not the right way to do it...
        AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(.init(platform: .identifier("iOS \(availability.iOS)"))))
        AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(.init(platform: .identifier("macOS \(availability.macOS)"))))
        AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(.init(platform: .identifier("tvOS \(availability.tvOS)"))))
        AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(.init(platform: .identifier("watchOS \(availability.watchOS)"))))
        AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(.init(platform: .identifier("visionOS \(availability.visionOS)"))))
        AvailabilityArgumentSyntax(argument: .token(.unknown("*")))
    }

    @CodeBlockItemListBuilder
    func availabilityHeaderUIKit(
        @CodeBlockItemListBuilder statementsBuilder: () throws -> CodeBlockItemListSyntax
    ) rethrows -> CodeBlockItemListSyntax {
        try """

        @available(iOS 13.0, tvOS 13.0, *)
        @available(watchOS, unavailable)
        \(statementsBuilder())

        """
    }

    @CodeBlockItemListBuilder
    func canImportUIKit(
        @CodeBlockItemListBuilder statementsBuilder: () throws -> CodeBlockItemListSyntax
    ) rethrows -> CodeBlockItemListSyntax {
        try """
        #if canImport(UIKit) && !os(watchOS)
        \(statementsBuilder())
        #endif

        """
    }
}

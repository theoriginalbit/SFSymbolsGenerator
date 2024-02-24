//
//  LocalizationFlag.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

import ArgumentParser

enum LocalizationFlag: EnumerableFlag {
    case both
    case languageCode
    case rightToLeft

    static func name(for value: Self) -> NameSpecification {
        switch value {
        case .both:
            return [.customShort("a"), .customLong("export-all"), .customLong("export-all-localizations")]
        case .languageCode:
            return [.customShort("l"), .customLong("export-lang"), .customLong("export-language-code")]
        case .rightToLeft:
            return [.customShort("r"), .customLong("export-rtl"), .customLong("export-right-to-left")]
        }
    }

    static func help(for value: Self) -> ArgumentHelp? {
        switch value {
        case .both:
            return ArgumentHelp("Enables exports for symbols that provide language code or right-to-left variants")
        case .languageCode:
            return ArgumentHelp("Enables exports for symbols that provide language code variants")
        case .rightToLeft:
            return ArgumentHelp("Enables exports for symbols that provide right-to-left variants")
        }
    }
}

//
//  LocalizationOption.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 24/2/2024.
//

struct LocalizationOption: OptionSet {
    let rawValue: Int

    static let languageCode = Self(rawValue: 1 << 0)
    static let rightToLeft = Self(rawValue: 1 << 1)
}

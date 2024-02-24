//
//  LocalizationOptionTransformer.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

enum LocalizationOptionTransformer {
    static func transform(_ value: LocalizationFlag?) -> LocalizationOption {
        guard let value else {
            return []
        }
        return switch value {
        case .both:
            [.languageCode, .rightToLeft]
        case .languageCode:
            .languageCode
        case .rightToLeft:
            .rightToLeft
        }
    }
}

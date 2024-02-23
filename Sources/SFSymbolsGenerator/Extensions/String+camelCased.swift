//
//  String+camelCased.swift
//
//
//  Created by Joshua Asbury on 21/2/2024.
//

import NaturalLanguage

extension String {
    var camelCased: String {
        let tokens = Self.tokenizer(self)
        guard let first = tokens.first else {
            return tokens.joined()
        }
        return first.lowercased() + tokens.dropFirst().map(\.capitalized).joined()
    }

    static func tokenizer(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text

        var words: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex ..< text.endIndex) { tokenRange, attributes in
            let value = String(text[tokenRange])
            guard tokenRange.lowerBound > text.startIndex else {
                if attributes == .numeric {
                    words.append("_\(value)")
                } else {
                    words.append(value)
                }
                return true
            }
            words.append(value)
            return true
        }
        return words
    }
}

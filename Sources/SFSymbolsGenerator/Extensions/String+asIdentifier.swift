//
//  String+asIdentifier.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

import Foundation

extension String {
    var asIdentifier: String {
        if Keyword.isKeyword(self) {
            return "`\(camelCased)`"
        }
        return camelCased
    }
}

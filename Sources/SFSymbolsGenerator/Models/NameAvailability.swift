//
//  NameAvailability.swift
//
//
//  Created by Joshua Asbury on 24/2/2024.
//

import Foundation

struct NameAvailability: Decodable {
    enum CodingKeys: String, CodingKey {
        case symbols
        case yearToRelease = "year_to_release"
    }

    let symbols: [String: String]
    let yearToRelease: [String: YearMapping]
}

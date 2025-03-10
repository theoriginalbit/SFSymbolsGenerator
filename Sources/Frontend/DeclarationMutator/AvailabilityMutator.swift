//
//  AvailabilityMutator.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 3/3/2025.
//

struct AvailabilityMutator: DeclarationMutator {
    private let nameAvailability: NameAvailability
    
    init(nameAvailability: NameAvailability) {
        self.nameAvailability = nameAvailability
    }
    
    func mutate(_ value: inout Declaration, for symbolName: String) {
        guard let symbol = nameAvailability.symbols[symbolName],
              let release = nameAvailability.yearToRelease[symbol]
        else { return }
        
        let availableDescription: AvailableAttributeDescription = .os([
            .iOS(release.iOS),
            .macOS(release.macOS),
            .macCatalyst(release.iOS),
            .tvOS(release.tvOS),
            .visionOS(release.visionOS),
            .watchOS(release.watchOS),
        ])
        guard case let .commentable(comment, declaration) = value else {
            value = .availableAttribute(availableDescription, value)
            return
        }
        
        // we always want the @available attribute to come after the comment
        value = .commentable(comment, .availableAttribute(availableDescription, declaration))
    }
}


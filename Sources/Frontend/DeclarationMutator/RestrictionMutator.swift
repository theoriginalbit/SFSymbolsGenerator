//
//  RestrictionMutator.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 10/3/2025.
//

struct RestrictionMutator: DeclarationMutator {
    private let symbolRestrictions: [String: String]
    
    init(symbolRestrictions: [String : String]) {
        self.symbolRestrictions = symbolRestrictions
    }
    
    func mutate(_ value: inout Declaration, for symbolName: String) {
        guard let restriction = symbolRestrictions[symbolName] else {
            return
        }
        let restrictionComment = "- Important: \(restriction)"
        guard case let .commentable(.doc(comment), decl) = value else {
            // was not a commentable (weird!) so now make it one to show the restriction
            value = .commentable(.doc(restrictionComment), value)
            return
        }
        value = .commentable(
            .doc("""
            \(comment)
            
            \(restrictionComment)
            """),
            decl
        )
    }
}

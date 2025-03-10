//
//  DeprecationMutator.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 10/3/2025.
//

struct DeprecationMutator: DeclarationMutator {
    private let nameAliases: [String: String]
    
    init(nameAliases: [String : String]) {
        self.nameAliases = nameAliases
    }
    
    func mutate(_ value: inout Declaration, for symbolName: String) {
        guard let symbol = nameAliases[symbolName] else { return }
        
        let availableDescription: AvailableAttributeDescription = .deprecated(
            message: "This name has been deprecated. You should use a more modern name if your app does not need to support older platforms.",
            renamed: symbol
        )
        guard case let .commentable(comment, declaration) = value else {
            value = .availableAttribute(availableDescription, value)
            return
        }
        
        // we always want the @available attribute to come after the comment
        value = .commentable(comment, .availableAttribute(availableDescription, declaration))
    }
}

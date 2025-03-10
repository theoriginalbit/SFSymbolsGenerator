//
//  DeclarationMutator.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 3/3/2025.
//

protocol DeclarationMutator {
    func mutate(_ value: inout Declaration, for symbolName: String)
}

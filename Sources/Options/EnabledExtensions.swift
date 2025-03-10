//
//  EnabledExtensions.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 10/3/2025.
//

import ArgumentParser

enum EnabledExtensions: String, ExpressibleByArgument, CaseIterable {
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"
    case appKit = "AppKit"
}


//
//  Keyword.swift
//  
//
//  Created by Joshua Asbury on 24/2/2024.
//

import Foundation

enum Keyword {
    static func isKeyword(_ value: String) -> Bool {
        keywordTextLookupTable.contains(value)
    }
    
    private static let keywordTextLookupTable: Set<String> = [
        "__consuming",
        "__owned",
        "__setter_access",
        "__shared",
        "_alignment",
        "_backDeploy",
        "_borrow",
        "_cdecl",
        "_Class",
        "_compilerInitialized",
        "_const",
        "_documentation",
        "_dynamicReplacement",
        "_effects",
        "_expose",
        "_forward",
        "_implements",
        "_linear",
        "_local",
        "_modify",
        "_move",
        "_NativeClass",
        "_NativeRefCountedObject",
        "_noMetadata",
        "_nonSendable",
        "_objcImplementation",
        "_objcRuntimeName",
        "_opaqueReturnTypeOf",
        "_optimize",
        "_originallyDefinedIn",
        "_PackageDescription",
        "_private",
        "_projectedValueProperty",
        "_read",
        "_RefCountedObject",
        "_semantics",
        "_specialize",
        "_spi",
        "_spi_available",
        "_swift_native_objc_runtime_base",
        "_Trivial",
        "_TrivialAtMost",
        "_typeEraser",
        "_unavailableFromAsync",
        "_underlyingVersion",
        "_UnknownLayout",
        "_version",
        "accesses",
        "actor",
        "addressWithNativeOwner",
        "addressWithOwner",
        "any",
        "Any",
        "as",
        "assignment",
        "associatedtype",
        "associativity",
        "async",
        "attached",
        "autoclosure",
        "availability",
        "available",
        "await",
        "backDeployed",
        "before",
        "block",
        "borrowing",
        "break",
        "canImport",
        "case",
        "catch",
        "class",
        "compiler",
        "consume",
        "copy",
        "consuming",
        "continue",
        "convenience",
        "convention",
        "cType",
        "default",
        "defer",
        "deinit",
        "deprecated",
        "derivative",
        "didSet",
        "differentiable",
        "distributed",
        "do",
        "dynamic",
        "each",
        "else",
        "enum",
        "escaping",
        "exclusivity",
        "exported",
        "extension",
        "fallthrough",
        "false",
        "file",
        "fileprivate",
        "final",
        "for",
        "discard",
        "forward",
        "func",
        "get",
        "guard",
        "higherThan",
        "if",
        "import",
        "in",
        "indirect",
        "infix",
        "init",
        "initializes",
        "inline",
        "inout",
        "internal",
        "introduced",
        "is",
        "isolated",
        "kind",
        "lazy",
        "left",
        "let",
        "line",
        "linear",
        "lowerThan",
        "macro",
        "message",
        "metadata",
        "module",
        "mutableAddressWithNativeOwner",
        "mutableAddressWithOwner",
        "mutating",
        "nil",
        "noasync",
        "noDerivative",
        "noescape",
        "none",
        "nonisolated",
        "nonmutating",
        "objc",
        "obsoleted",
        "of",
        "open",
        "operator",
        "optional",
        "override",
        "package",
        "postfix",
        "precedencegroup",
        "prefix",
        "private",
        "Protocol",
        "protocol",
        "public",
        "reasync",
        "renamed",
        "repeat",
        "required",
        "rethrows",
        "return",
        "reverse",
        "right",
        "safe",
        "self",
        "Self",
        "Sendable",
        "set",
        "some",
        "sourceFile",
        "spi",
        "spiModule",
        "static",
        "struct",
        "subscript",
        "super",
        "swift",
        "switch",
        "target",
        "throw",
        "throws",
        "transpose",
        "true",
        "try",
        "Type",
        "typealias",
        "unavailable",
        "unchecked",
        "unowned",
        "unsafe",
        "unsafeAddress",
        "unsafeMutableAddress",
        "var",
        "visibility",
        "weak",
        "where",
        "while",
        "willSet",
        "witness_method",
        "wrt",
        "yield",
    ]
}
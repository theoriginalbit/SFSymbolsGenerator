//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension TypeName {

    /// Returns the type name for the String type.
    static var string: Self { .swift("String") }

    /// Returns the type name for the Int type.
    static var int: Self { .swift("Int") }

    /// Returns a type name for a type with the specified name in the
    /// Swift module.
    /// - Parameter name: The name of the type.
    /// - Returns: A TypeName representing the specified type within the Swift module.
    static func swift(_ name: String) -> TypeName { TypeName(swiftKeyPath: ["Swift", name]) }

    /// Returns a type name for a type with the specified name in the
    /// Foundation module.
    /// - Parameter name: The name of the type.
    /// - Returns: A TypeName representing the specified type within the Foundation module.
    static func foundation(_ name: String) -> TypeName { TypeName(swiftKeyPath: ["Foundation", name]) }

    /// Returns the type name for the Date type.
    static var date: Self { .foundation("Date") }

    /// Returns the type name for the URL type.
    static var url: Self { .foundation("URL") }

    /// Returns the type name for the DecodingError type.
    static var decodingError: Self { .swift("DecodingError") }
}

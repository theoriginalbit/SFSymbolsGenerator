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

/*
 * Removed:
 * - OpenAPI import and related extensions
 */

extension Comment {

    /// Returns the string contents of the comment.
    var contents: String {
        switch self {
        case .inline(let string): return string
        case .doc(let string): return string
        case .mark(let string, _): return string
        }
    }

    /// Returns the first line of content, unless it starts with a dash.
    ///
    /// Lines starting with a dash are appended remarks, which don't
    /// describe the property.
    var firstLineOfContent: String? {
        guard let line = contents.split(separator: "\n").first, !line.hasPrefix("-") else { return nil }
        return String(line)
    }
}

extension Comment {
    /// Returns a documentation comment for a function with the provided
    /// parameters.
    /// - Parameters:
    ///   - abstract: The documentation of the function.
    ///   - parameters: The parameters.
    /// - Returns: A documentation comment for the function.
    static func functionComment(abstract: String?, parameters: [(name: String, comment: String?)]) -> Comment? {
        guard !parameters.isEmpty else { return abstract.map { .doc($0) } }
        var components: [String] = abstract.map { [$0] } ?? []
        var parameterComponents: [String] = []
        parameterComponents.append("- Parameters:")
        for (name, comment) in parameters {
            let parameterComment: String
            if let comment {
                parameterComment = Comment.doc(comment).firstLineOfContent.map { " \($0)" } ?? ""
            } else {
                parameterComment = ""
            }
            parameterComponents.append("  - \(name):\(parameterComment)")
        }
        components.append("")
        components.append(parameterComponents.joined(separator: "\n"))
        return .doc(components.joined(separator: "\n"))
    }
}

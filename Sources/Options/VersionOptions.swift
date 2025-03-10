//
//  VersionOptions.swift
//  SFSymbolsGenerator
//
//  Created by Joshua Asbury on 24/2/2024.
//

import ArgumentParser

/// Encapsulates `--version` flag behavior without needing to override `run` on the entry point of the tool.
struct VersionOptions: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Print the version and exit")
    var version = false

    func validate() throws {
        if version {
            print(toolVersion)
            throw ExitCode.success
        }
    }

    /// A human-readable string describing the tool's version.
    ///
    /// - Note: This value's format is is not meant to be machine-readable
    /// - Bug: Build plugins do not currently run on Windows. ([swift-package-manager-#6851](https://github.com/apple/swift-package-manager/issues/6851))
    var toolVersion: String {
        #if os(Windows)
        "unknown"
        #else
        // The variable `_toolVersion` is generated at compile-time by the
        // GitStatus plugin. If the plugin was unable to gather tag or commit
        // information from Git, it produces a nil value.
        "unknown"
        #endif
    }
}

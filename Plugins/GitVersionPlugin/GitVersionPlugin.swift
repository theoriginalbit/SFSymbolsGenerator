//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import Foundation
import PackagePlugin

@main struct GitVersionPlugin: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
		let version = gitVersion(in: context.package.directoryURL)
		let output = context.pluginWorkDirectoryURL.appending(path: "GitVersion.swift")

		// Version is passed as an argument, so the command re-runs whenever it changes.
		return [.buildCommand(
			displayName: "Generate GitVersion (\(version))",
			executable: URL(filePath: "/bin/sh"),
			arguments: [
				"-c",
				// more trouble than it's worth using SwiftStructureKit as I'd need a 'GitVersion' executable for this plugin to run
				#"printf 'enum GitVersion { static let current = "%s" }\n' "$1" > "$2""#,
				"_",
				version,
				output.path,
			],
			outputFiles: [output],
		)]
	}

	private func gitVersion(in dir: URL) -> String {
		git(["describe", "--tags", "--abbrev=0", "--dirty=-modified"], in: dir) ?? "0.0.0"
	}

	private func git(_ args: [String], in dir: URL) -> String? {
		let process = Process()
		process.executableURL = URL(filePath: "/usr/bin/env")
		process.arguments = CollectionOfOne("git") + args
		process.currentDirectoryURL = dir

		let outputPipe = Pipe()
		process.standardOutput = outputPipe
		process.standardError = Pipe()

		do {
			try process.run()
			process.waitUntilExit()
			guard process.terminationStatus == 0 else {
				return nil
			}
			let result = outputPipe.fileHandleForReading.readDataToEndOfFile()
			let output = String(decoding: result, as: UTF8.self)
				.trimmingCharacters(in: .whitespacesAndNewlines)
			return if !output.isEmpty { output } else { nil }
		} catch {
			return nil
		}
	}
}

//
// Copyright © 2026 SFSymbolsGenerator. All rights reserved.
//

import ArgumentParser
import Foundation
import _SFSymbolsGeneratorCore

@main
struct SFSymbolsGenerator: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "sfgenerate",
		abstract: "Generate type-safe access to SF Symbols.",
		version: GitVersion.current,
		subcommands: [GenerateCommand.self],
		defaultSubcommand: GenerateCommand.self,
	)
}

# SF Symbols Generator

[![](https://img.shields.io/github/v/release/theoriginalbit/SFSymbolsGenerator)](https://github.com/theoriginalbit/SFSymbolsGenerator/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftheoriginalbit%2FSFSymbolsGenerator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/theoriginalbit/SFSymbolsGenerator)
[![](https://img.shields.io/github/actions/workflow/status/theoriginalbit/SFSymbolsGenerator/test.yml?branch=main&label=tests&logo=swift)](https://github.com/theoriginalbit/SFSymbolsGenerator/actions/workflows/test.yml)

A build tool which generates a type to safely access SF Symbols.

## Usage

The simplest command you can run is:
```bash
sfgenerate
```

It will generate files to support all UI frameworks (AppKit, SwiftUI, UIKit) in the current working directory.

> [!NOTE]
> Generation is split over many files to reduce file size and compile time. You will likely want to have them generate into their own directory.
>
> The files have the suffix `.generated.swift` to easily allow you to configure any static-analysis tools to ignore the files.

Choose the output directory, generated frameworks, and access modifiers with command options:

```bash
sfgenerate generate \
  --output-directory Sources/Generated \
  --ui-frameworks SwiftUI,UIKit \
  --public
```

| Option | Description |
| --- | --- |
| `--output-directory <path>` | Directory for the generated `.generated.swift` files. Defaults to the current working directory. |
| `--ui-frameworks <frameworks>` | Comma-separated frameworks: `AppKit`, `UIKit`, and `SwiftUI`. Defaults to all three. |
| `--public`, `--package`, `--internal` | Access modifier for generated code. Defaults to `--internal`. |
| `--enable-raw-identifiers` | Emit identifiers using Swift 6.2 raw identifier syntax. Disabled by default. |
| `--verbose` | Repeat to increase diagnostic verbosity (`-vvv` for full verbosity.) |

Run `sfgenerate help generate` for the complete command reference.

### SwiftPM build-tool plugin

Add the `SFSymbolsGeneratorPlugin` build-tool plugin to a target to generate its symbol files during the build:

```swift
.target(
  name: "MyApp",
  plugins: [.plugin(name: "SFSymbolsGeneratorPlugin", package: "sfsymbolsgenerator")]
)
```

The plugin writes the generated files to its plugin output directory. To configure generation, add an optional `.sfgenerate.json` config file to the package root:

```json
{
  "symbolExtensions": true,
  "accessModifier": "internal",
  "uiFrameworks": ["AppKit", "SwiftUI", "UIKit"],
  "rawIdentifiers": false
}
```

Each field is optional and defaults to the value shown. `accessModifier` accepts `public`, `package`, or `internal`; `uiFrameworks` accepts any combination of `AppKit`, `UIKit`, and `SwiftUI`.

### Using the plugin in an Xcode project

Add SFSymbolsGenerator as a package dependency in Xcode, then add `SFSymbolsGeneratorPlugin` to your app target from **Build Phases > Run Build Tool Plug-ins**. The plugin generates its files in Xcode's plugin output directory. To configure it, add `.sfgenerate.json` to the target's input files; it accepts the same options described above.

### Using the generated code

```swift
// SwiftUI

Image(systemSymbol: .folder)

// UIKit
let image = UIImage(systemSymbol: .squareAndArrowUp)

// AppKit
let image = NSImage(systemSymbol: .characterMagnify, accessibilityDescription: nil)
```

It's that easy!

### The generated code helps you!

The properties are declared with `@available` annotations, so the compiler will even check platform availability and warn of deprecations, for example:

```swift
@available(iOS, introduced: 14.0, deprecated: 17.0, renamed: "characterMagnify", message: "...")
@available(macOS, introduced: 11.0, deprecated: 14.0, renamed: "characterMagnify", message: "...")
@available(watchOS, introduced: 7.0, deprecated: 10.0, renamed: "characterMagnify", message: "...")
@available(tvOS, introduced: 14.0, deprecated: 17.0, renamed: "characterMagnify", message: "...")
@available(visionOS, deprecated, renamed: "characterMagnify", message: "...")
static let aMagnify: SFSymbolResource = SFSymbolResource(systemName: "a.magnify")
```

> [!NOTE]
> The messages are truncated here for brevity, the generated source will contain a deprecation message.

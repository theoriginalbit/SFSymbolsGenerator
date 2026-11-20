# SF Symbols Generator

[![](https://img.shields.io/github/v/release/theoriginalbit/SFSymbolsGenerator)](https://github.com/theoriginalbit/SFSymbolsGenerator/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftheoriginalbit%2FSFSymbolsGenerator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/theoriginalbit/SFSymbolsGenerator)
[![](https://img.shields.io/github/actions/workflow/status/theoriginalbit/SFSymbolsGenerator/test.yml?branch=main&label=tests&logo=swift)](https://github.com/theoriginalbit/SFSymbolsGenerator/actions/workflows/test.yml)

A build tool which generates a type to safely access SF Symbols.

## Usage

```swift
let imageView = UIImageView(system: .messageCircle)
let image = UIImage(system: .squareAndArrowUp)
```

It's that easy! The properties are declared with `@available` annotations, so the compiler will even check platform availability and warn of deprecations.

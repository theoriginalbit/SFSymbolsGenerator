# Contributing to SF Symbols Generator

Thanks for your interest in contributing to SF Symbols Generator. Contributions of bug fixes, documentation improvements, tests, and new descriptor or renderer capabilities are welcome.

## Getting started

You need the Swift 6.1 toolchain or later. Clone the repository, then run the test suite from the repository root:

```sh
swift test
```

To build the package without running tests:

```sh
swift build
```

The package manifest is `Package.swift`; implementation code is directly under `Sources/` and tests are directly under `Tests/`.

## AI tools

Human discourse is an essential part of open source development. To encourage productive collaboration between contributors and maintainers, please refrain from using AI tools for the following:

- Issues: titles, bodies, and comments.
- Pull requests: titles, descriptions, and comments.

Contributors who feel more comfortable writing in another language may use automated translation tools, but must include their original content in their preferred language.

## Making changes

- Keep changes focused and consistent with the existing descriptor and renderer APIs.
- Add or update tests for behavior changes. Renderer tests should verify the exact generated Swift source.
- Update relevant documentation when changing public APIs or user-visible behavior.
- Follow the surrounding Swift style and avoid unrelated formatting changes.
- Run `swift test` before submitting your changes.

## How to submit a bug report

Please ensure to specify the following:

* Commit hash
* Contextual information (e.g. what you were trying to achieve with SF Symbols Generator)
* Simplest possible steps to reproduce
  * More complex the steps are, lower the priority will be.
  * A pull request with failing test case is preferred, but it's just fine to paste the test case into the issue description.
* Anything that might be relevant in your opinion, such as:
  * Swift version or the output of `swift --version`
### Example

```
Commit hash: b17a8a9f0f814c01a56977680cb68d8a779c951f

Context:
While testing my application that uses SF Symbols Generator, I noticed that ...

Steps to reproduce:
1. ...
2. ...
3. ...
4. ...

$ swift --version
swift-driver version: 1.168.6 Apple Swift version 6.4.2 (swiftlang-6.4.2.1.9 clang-2100.4.1.1)
Target: arm64-apple-macosx27.0.0
```

## Writing a Patch

A good patch is:

1. Concise, and contains as few changes as needed to achieve the end result.
2. Tested, ensuring that any tests provided failed before the patch and pass after it.
3. Documented, adding API documentation as needed to cover new functions and properties.
4. Accompanied by a great commit message.
## Submitting a contribution

Open a pull request with a clear description of the problem and the change. Include relevant context, note any API or behavior changes, and mention the tests you ran. **For larger changes**, please discuss the approach in an issue before beginning implementation.

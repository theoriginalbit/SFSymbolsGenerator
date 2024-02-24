# SF Symbols Generator

A build tool which generates a type to safely access SF Symbols.

## Usage:

```swift
let imageView = UIImageView(image: .messageCircle)
```
It's that easy! The properties are declared with the `@availabile` annotations, so the compiler will even check platform availability.


### Interested how it works?

The tool uses files on your machine, and/or build system, to dynamically generate types with all the symbols available.
That means as Apple adds new symbols the tool will pick them up without any updates necessary!

With this information the tool will output a structure very similar to the Asset Catalog symbols announced at WWDC23.

Example output:
```swift
import Foundation
#if canImport (UIKit) && !os(watchOS)
import UIKit
#endif
/// A SFSymbol resource.
struct SFSymbolResource: Hashable {
    /// A SFSymbol system name.
    fileprivate let systemName: String

    /// Initialize a `SFSymbolResource` with `systemName`.
    init(systemName name: String) {
        self.systemName = name
    }
}
extension SFSymbolResource {

    /// The "car.rear.waves.up" SF Symbol.
    ///
    ///  
    @available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, visionOS 1.0, *)
    static var carRearWavesUp: SFSymbolResource {
        SFSymbolResource(systemName: "car.rear.waves.up")
    }

    /// The "c.square" SF Symbol.
    ///
    ///  
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    static var cSquare: SFSymbolResource {
        SFSymbolResource(systemName: "c.square")
    }

    /// The "macstudio" SF Symbol.
    ///
    /// - Important: This symbol may not be modified and may only be used to refer to Apple’s Mac Studio.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
    static var macstudio: SFSymbolResource {
        SFSymbolResource(systemName: "macstudio")
    }

    /// The "message.circle" SF Symbol.
    ///
    /// - Important: This symbol may not be modified and may only be used to refer to Apple’s Messages app.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    static var messageCircle: SFSymbolResource {
        SFSymbolResource(systemName: "message.circle")
    }
}
#if canImport (UIKit) && !os(watchOS)

@available(iOS 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {
    /// Initialize a `UIImage` with a SFSymbol resource.
    convenience init(systemSymbolResource resource: SFSymbolResource) {
        self.init(systemName: resource.name)!
    }
}
@available(iOS 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "car.rear.waves.up" SF Symbol.
    ///
    ///  
    @available(iOS 16.1, macOS 13.0, tvOS 16.1, watchOS 9.1, visionOS 1.0, *)
    static var carRearWavesUp: UIKit.UIImage {
        UIKit.UIImage(systemSymbolResource: .carRearWavesUp)
    }

    /// The "c.square" SF Symbol.
    ///
    ///  
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    static var cSquare: UIKit.UIImage {
        UIKit.UIImage(systemSymbolResource: .cSquare)
    }

    /// The "macstudio" SF Symbol.
    ///
    /// - Important: This symbol may not be modified and may only be used to refer to Apple’s Mac Studio.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
    static var macstudio: UIKit.UIImage {
        UIKit.UIImage(systemSymbolResource: .macstudio)
    }

    /// The "message.circle" SF Symbol.
    ///
    /// - Important: This symbol may not be modified and may only be used to refer to Apple’s Messages app.
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
    static var messageCircle: UIKit.UIImage {
        UIKit.UIImage(systemSymbolResource: .messageCircle)
    }
}
#endif
```

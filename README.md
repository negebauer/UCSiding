# UCSiding

[![CI Status](http://img.shields.io/travis/negebauer/UCSiding.svg?style=flat)](https://travis-ci.org/negebauer/UCSiding)
[![Version](https://img.shields.io/cocoapods/v/UCSiding.svg?style=flat)](http://cocoapods.org/pods/UCSiding)
[![License](https://img.shields.io/cocoapods/l/UCSiding.svg?style=flat)](http://cocoapods.org/pods/UCSiding)
[![Platform](https://img.shields.io/cocoapods/p/UCSiding.svg?style=flat)](http://cocoapods.org/pods/UCSiding)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UCSiding is available through [CocoaPods](http://cocoapods.org)  
To install it, simply add the following line to your Podfile:

```ruby
pod "UCSiding"
```

## Credentials

For testing you must provide your own Credentials in `UCSiding/UCSTestCredentials.swift`  
In order to do so, create a file called QQ, copy and paste the following in it  
```swift
public struct UCSTestCredentials {

    /// A valid username for the SIDING without `@uc.cl`
    public func username() -> String {
        return "myUsername"
    }

    /// The password for the `username()` user
    public func password() -> String {
        return "myPassword"
    }
}
```

## Author

Nicolás Gebauer, negebauer@uc.cl

## License

UCSiding is available under the MIT license. See the [LICENSE](./LICENSE.md) file for more info

# Willow 6.0 Migration Guide

Willow 6.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, macOS, tvOS and watchOS written in Swift.
As a major release, following Semantic Versioning conventions, 6.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 5.x to the latest APIs.

## Requirements

Willow 6.0 officially supports iOS 9.0+, macOS 10.11+, tvOS 9.0+, watchOS 2.0+, Xcode 9.0+ and Swift 4.0+.
If you'd like to use Willow in a project targeting Xcode 8.3 and Swift 3.1, use the latest tagged 3.x release.

---

## Breaking API Changes

Willow 6.0 contains very minor breaking changes on the log message string APIs.
Most of your Willow code will be able to remain the same.

### Logger APIs

Unfortunately, in the Willow 5.0.0 release, we missed a way to correct fact that multi-line escaping closures are ambiguous with different return types.
For example, the following call was ambiguous in Willow 4:

```swift
log.event {
let value = 10
return "Total value is: \(value)"
}
```

The only way to correct the ambiguity error is to declare the closure signature for the compiler:

```swift
log.event { () -> String in
let value = 10
return "Total value is: \(value)"
}
```

This was certainly not intended and was an unfortunate oversight on our part.
Single line closures did not exhibit the issue, but multi-line escaping closures certainly do.

To resolve this issue in Willow 5, we modified the log message string APIs to include the `Message` suffix.

```swift
log.eventMessage {
let value = 10
return "Total value is: \(value)"
}
```
However, subsequently, a way was discovered to have our cake and eat it to, so in Willow 6 we're going back to the Willow 4 syntax, except now you don't have to worry about ambiguity warnings. You can just do:

```swift
log.event {
let value = 10
return "Total value is: \(value)"
}
```
As long as the return value conforms to to CustomStringConvertible protocol, everything will be fine. Therefore, now, you can do a number of new things, like:

```swift
log.event {
let value = 10
return ["Value": value]
}
```

Or:

```swift
log.error {
return responses.filter { $0.statusCode > 299 }
}
```

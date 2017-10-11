# Willow 5.0 Migration Guide

Willow 5.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, macOS, tvOS and watchOS written in Swift.
As a major release, following Semantic Versioning conventions, 5.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 4.x to the latest APIs.

## Requirements

Willow 5.0 officially supports iOS 9.0+, macOS 10.11+, tvOS 9.0+, watchOS 2.0+, Xcode 9.0+ and Swift 4.0+.
If you'd like to use Willow in a project targeting Xcode 8.3 and Swift 3.1, use the latest tagged 3.x release.

---

## Breaking API Changes

Willow 5.0 contains very minor breaking changes on the log message string APIs.
Most of your Willow code will be able to remain the same.

### Logger APIs

Unfortunately, in the Willow 4.0.0 release, we missed the fact that multi-line escaping closures are ambiguous with different return types.
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

To resolve this issue in Willow 5, we've modified the log message string APIs to include the `Message` suffix.

```swift
log.eventMessage {
let value = 10
return "Total value is: \(value)"
}
```

The `LogMessage` APIs do not include the `Message` suffix which satisfies the compiler.
Sadly we were unable to make this change in a backwards compatible way.
However, it is a very simple change to make to migrate from Willow 4 to Willow 5.

### Optional APIs

The `Optional<Logger>` extension APIs have also been updated to use the `Message` suffix for log message string APIs.

```swift
var log: Logger?

log.eventMessage {
let value = 10
return "Total value is: \(value)"
}
```

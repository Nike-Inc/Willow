# Willow 3.0 Migration Guide

Willow 3.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, macOS, tvOS and watchOS written in Swift. As a major release, following Semantic Versioning conventions, 3.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 2.x to the latest APIs.

## Requirements

Willow 3.0 officially supports iOS 9.0+, macOS 10.11+, tvOS 9.0+, watchOS 2.0+, Xcode 8.2+ and Swift 3.0+. If you'd like to use Willow in a project targeting iOS 8 and Swift 2.3, use the latest tagged 1.x release.

---

## Breaking API Changes

Willow 3.0 contains only two breaking API changes that are very minor, but needed to be corrected. Most of your Willow code will be able to remain the same.

### ExecutionMethod

The `ExecutionMethod` cases have been refactored to be lowercased to match the Swift API Design Guidelines. Sadly this was missed in the port of Willow 2.0.

```swift
public struct LoggerConfiguration
    public enum ExecutionMethod {
        case synchronous(lock: NSRecursiveLock)
        case asynchronous(queue: DispatchQueue)
    }
}
```

This change should be simple to make in your Willow code.

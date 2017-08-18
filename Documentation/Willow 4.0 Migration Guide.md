# Willow 4.0 Migration Guide

Willow 4.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, macOS, tvOS and watchOS written in Swift. 
As a major release, following Semantic Versioning conventions, 4.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 3.x to the latest APIs.

## Requirements

Willow 4.0 officially supports iOS 9.0+, macOS 10.11+, tvOS 9.0+, watchOS 2.0+, Xcode 9.0+ and Swift 4.0+. 
If you'd like to use Willow in a project targeting Xcode 8.3 and Swift 3.1, use the latest tagged 3.x release.

---

## Breaking API Changes

Willow 4.0 contains only two breaking API changes that are very minor, but needed to be corrected. 
Most of your Willow code will be able to remain the same.

### LogModifier

The `LogMessageModifier` type has been renamed to `LogModifier`.

### LogWriter

The `LogMessageWriter` type has been renamed to `LogWriter` and includes a new method to be implemented to write `LogMessage` types.

### LoggerConfiguration

The `LoggerConfiguration` type has been removed as a part of making Willow easier to setup and use. 
`LogModifier`s are now passed into `LogWriter`s when they are initialized and are not associated with specific log levels.

Creating a new `Logger` instance is now as simple as initializing with a set of `LogLevel`s, `LogWriters` and the `ExecutionMethod`.

```swift
let writers = [ConsoleWriter(modifiers: [TimestampModifier()])]
let log =  Logger(logLevels: .all, writers: writers)
```

## New Functionality

### Messages

In addition to logging strings, Willow now supports logging attributed data in the form of `LogMessage`. 
`LogMessage` are structured data with a name and a dictionary of attributes. 
Willow declares the `LogMessage` protocol which frameworks and applications can use as the basis for concrete implementations.

This allows for the creation of `LogWriter`s that pass along rich log data to third party services that accept log strings with additional attribute dictionaries.

### Optional Loggers

Willow 4.0 extends the built-in `Optional` type to allow for calling loggers using non-optional syntax. 
This gives frameworks the flexibility to not have a default logger instance that the caller is required to customize with the convenience of not having to use optional unwrap syntax at call sites.

For example:

```swift
var log: Logger?

public func doSomething() {
    log.event("Did something")
}
```

`log.event` will log the message to Willow if `log` is not `nil`, or do nothing if `log` is `nil`.

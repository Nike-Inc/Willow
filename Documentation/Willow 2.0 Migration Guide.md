# Willow 2.0 Migration Guide

Willow 2.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, macOS, tvOS and watchOS written in Swift.
As a major release, following Semantic Versioning conventions, 2.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 1.x to the latest APIs, as well as explain the design and structure of new and changed functionality.

## Requirements

Willow 2.0 officially supports iOS 9.0+, macOS 10.11+, tvOS 9.0+, watchOS 2.0+, Xcode 8.0+ and Swift 3.0+.
If you'd like to use Willow in a project targeting iOS 8 and Swift 2.3, use the latest tagged 1.x release.

## Reasons for Bumping to 2.0

In general, we try to avoid MAJOR version bumps unless absolutely necessary.
We realize the difficulty of transitioning between MAJOR version API changes.
Willow 2.0 was unavoidable due to the drastic API changes introduced by Apple in Swift 3.
There was no possible way to adhere to the new Swift [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) and not bump the MAJOR version.

Since we knew we had to cut a MAJOR release to support Swift 3, we decided to package up a few API changes as well while we were at it.
These changes are covered in detail in the [Breaking API Changes](#breaking-api-changes) section below.

## Benefits of Upgrading

The benefits of upgrading can be summarized as follows:

* All new APIs designed to adhere to the Swift 3 API Design Guidelines.
* `OSLogWriter` writes messages directly to the new `os_log` APIs from Apple directly inside Willow.
* `ConsoleWriter` can now be configured to use the `print` or `NSLog` function internally when initialized.

While these benefits are nice, the core motivation for updating to Willow 2.0 should be because you're making the transition over to Swift 3 in your upstream targets that depend on Willow.

---

## Breaking API Changes

Willow 2.0 contains several breaking API changes, although the majority of your Willow code will be able to remain the same.

### Swift 3

#### Formatter and LogMessageModifier

In Swift 3, the `NSFormatter` abstract class is now named `Formatter` which creates a nasty naming collision with Willow.
Because of this, we decided to refactor the `Formatter` protocol to `LogMessageModifier` to be more explicit and avoid naming collisions moving forward.

Here's a look at the old `Formatter` protocol.

```swift
public protocol Formatter {
    func formatMessage(message: String, logLevel: LogLevel) -> String
}
```

And here's the new `LogMessageModifier` protocol to replace the `Formatter`.

```swift
public protocol LogMessageModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String
}
```

All you need to do here is refactor your conforming types to use the new protocol name and API signature.

#### Writer and LogMessageWriter

We also decided to refactor the `Writer` protocol to more closely follow the new convention of the `LogMessageModifier` protocol.
It has been renamed the `LogMessageWriter` protocol.

Here's a look at the original `Writer` protocol in Willow 1.x.

```swift
public protocol Writer {
    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?)
}
```

And here's the new `LogMessageWriter` protocol in Swift 3.

```swift
public protocol LogMessageWriter {
    func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?)
}
```

Same story here, just refactor your conforming types to match the new signatures.

#### Other Changes

There are a few other property changes to the `LoggerConfiguration` such as renaming the `formatters` property to` modifiers` to match the new protocol name.
There are several other small changes that don't warrant being called out directly in this doc, mostly due to matching the API Design Guidelines.

## New Features

### OSLogWriter

The `OSLogWriter` class allows you to use the new [os_log](https://developer.apple.com/reference/os/1891852-logging) APIs from Apple directly within the Willow system.
In order to use it, all you need to do is to create the `LogMessageWriter` instance and add it to the `LoggerConfiguration`.

```swift
let writer = OSLogWriter(subsystem: "com.nike.willow.example", category: "testing")
let writers: [LogLevel: LogMessageWriter] = [.all: [writer]]

let configuration = LoggerConfiguration(writers: writers)
let log = Logger(configuration: configuration)

log.debug("Hello world...coming to your from the os_log APIs!")
```

These APIs are only available on the latest versions of each platform including iOS 10.0+, macOS 10.12.0+, tvOS 10.0+ and watchOS 3.0+.
Unfortunately at this time, the `OSLogWriter` is not available on macOS due to missing implementation in the Xcode 8 GM and issues linking in test targets.
This is something that will be enabled once Xcode supports it.

### ConsoleWriter Method

The `ConsoleWriter` now has a nested `Method` enumeration that defines whether to use the `print` or `NSLog` functions when logging to the console.
By default, the `ConsoleWriter` is initialized using the `print` function.

The main reason for adding the ability to switch between the two functions is that you should use different functions in different scenarios.
We recommend that in development, you use the `.print` case.
When deploying to production, the `.nslog` case should be used instead.
This is because `print` does not log to the device console where as the `NSLog` function does.

```swift
open class ConsoleWriter: LogMessageWriter {
    public enum Method {
        case print, nslog
    }
}
```

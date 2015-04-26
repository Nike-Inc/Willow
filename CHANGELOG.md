# Changelog

The changelog for Willow includes information about the each release including any update notes, release notes as well as bug fixes, updates to existing features and new features. Additionally, Willow follows [semantic versioning](http://semver.org/) (a.k.a semver) which makes it easy to tell whether the release was a MAJOR, MINOR or PATCH revision.

---

## 0.3.0

### Upgrade Notes

The major change with this release is the support for custom log levels. Since the new `LogLevel` struct uses bitmasking to determine whether a `LogLevel` is enabled, you must now set the `LogLevel` in the `LoggerConfiguration` using bitwise operations. Here are some examples of how to do this.

```swift
let logLevel = .All // this is the new default value
let eventAndAbove = .Event | .Warn | .Error
let eventOnly = .Event
let allExceptDebug = .Debug ^ .All
```

### Release Notes

* **CHANGED** the `LogLevel` enum to a struct that now supports custom log level creation through bitmasking.
* **ADDED** new unit tests around log level customization.
* **ADDED** a playground demonstrating how to create custom log levels
* **ADDED** a playground demonstrating how to share a dispatch queue between multiple `Logger` instances
* **CHANGED** the source code structure by splitting out the Willow.swift file into smaller, more focused files.
* **REMOVED** `Logger` log message methods (they were deprecated in the 0.2.0 release).
* **FIXED** issue where the `LoggerConfiguration.timestampConfiguration()` method was not bridging an internal array properly at runtime.
* **FIXED** issue where `unowned self` could crash during `Logger` deinitialization the internal queue was still active.

## 0.2.0

### Upgrade Notes

This release is only compatible with Swift 1.2. You will need to update your project to build against Swift 1.2 in conjunction with updating to Willow `0.2.0`. Additionally, the log message methods have been deprecated for performance reasons. The log closure methods should be used instead.

### Release Notes

* **UPDATED** all source code and tests for Swift 1.2.
* **UPDATED** Xcode project OS X deployment target to 10.9.
* **DEPRECATED** `Logger` log message methods for performance reasons.

## 0.1.0

### Release Notes

This is the initial release of Willow. Until Willow is publicly released on Github, it will continue evolve with versions being released as closely to semver as possible. The actual `1.0.0` release will not be locked until the public Github release.

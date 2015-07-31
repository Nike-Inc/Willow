# Changelog

The changelog for Willow includes information about the each release including any update notes, release notes as well as bug fixes, updates to existing features and new features. Additionally, Willow follows [semantic versioning](http://semver.org/) (a.k.a semver) which makes it easy to tell whether the release was a MAJOR, MINOR or PATCH revision.

---

## 1.0.0

### Upgrade Notes

Willow no longer supports the concept of a global `LogLevel`. Custom `Formatter` and `Writer` objects now require you to specify a single `LogLevel` or combined `LogLevel` such as `.All` to define which log levels are allowed. This greatly increases the flexibility of the `Writer` protocol, and also aligns the `Formatter` and `Writer` protocols to have the exact setup behavior.

### Release Notes

* **UPDATED** Logger configuration to allow specify the allowed `LogLevel` for a given set of writers.
* **UPDATED** Test logic to use all latest formatting practices.

---

## 0.4.0

### Upgrade Notes

Willow has been migrated to Swift 2.0. Please make sure to update your project to build with Xcode 7.0 before migrating.

### Release Notes

* **UPDATED** Minimum version of Xcode supported to Xcode 7.0 and Swift 2.0.
* **UPDATED** `LogLevel` type now conforms to `OptionSetType` instead of `RawOptionSetType`.
* **UPDATED** The custom log level section of the README.
* **UPDATED** The minimum supported iOS version to 8.0.

## 0.3.1

### Release Notes

* **ADDED** public docstrings to all `ConsoleWriter` methods.
* **FIXED** issue where the `ConsoleWriter` could not be directly initialized due to missing public initializer.

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

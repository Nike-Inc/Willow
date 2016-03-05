# Willow 2.0 Migration Guide

Willow 2.0 is the latest major release of Willow, a powerful, yet lightweight logging library for iOS, Mac OS X, tvOS and watchOS written in Swift. As a major release, following Semantic Versioning conventions, 2.0 introduces several API-breaking changes that one should be aware of.

This guide is provided in order to ease the transition of existing applications using Willow 1.x to the latest APIs, as well as explain the design and structure of new and changed functionality.

## New Requirements

Willow 2.0 officially supports iOS 8.0+, Mac OS X 10.10+, tvOS 9.0+, watchOS 2.0+, Xcode 7.2+ and Swift 2.1+.

---

## Breaking API Changes

### Execution Method

Synchronous and asynchronously logging is now controlled in Willow 2.0 through the `ExecutionMethod` enumeration.

```swift
public enum ExecutionMethod {
	case Synchronous(lock: NSRecursiveLock)
	case Asynchronous(queue: dispatch_queue_t)
}
```

The `ExecutionMethod` enumeration in Willow 2.0 replaces the `asynchronous` and `queue` parameters in the `LoggerConfiguration`. The reason the Willow 1.x was replaced was to support recursive logging in `synchronous` loggers. Previously, it was not possible to log a message inside a log message closure when `asychronous` was set to `false`. In Willow 2.0, you can recursively log as many times as needed on both synchronous and asynchronous loggers.

#### Synchronous Usage

In Willow 2.0, creating a synchronous logger can be accomplished by the following:

```swift
let configuration = LoggerConfiguration(executionMethod: .Synchronous(lock: NSRecursiveLock()))
let logger = Logger(configuration: configuration)
```

If you have multiple loggers, make sure to share the recursive lock between each instance to prevent log mangling:

```swift
let sharedLock = NSRecursiveLock()

let configuration1 = LoggerConfiguration(executionMethod: .Synchronous(lock: sharedLock))
let logger1 = Logger(configuration: configuration1)

let configuration2 = LoggerConfiguration(executionMethod: .Synchronous(lock: sharedLock))
let logger2 = Logger(configuration: configuration2)
```

> By default, Willow will initialize a `LoggerConfiguration` with a `.Synchronous` execution method and a default recursive lock.

#### Asynchronous Usage

In Willow 2.0, creating an asynchronous logger can be accomplished by the following:

```swift
let queue = dispatch_queue_create("serial.queue", DISPATCH_QUEUE_SERIAL)
let configuration = LoggerConfiguration(executionMethod: .Asynchronous(queue: queue))
let logger = Logger(configuration: configuration)
```

If you have multiple loggers, make sure to share the queue between each instance to prevent log mangling:

```swift
let sharedQueue = dispatch_queue_create("shared.serial.queue", DISPATCH_QUEUE_SERIAL)

let configuration1 = LoggerConfiguration(executionMethod: .Asynchronous(queue: sharedQueue))
let logger1 = Logger(configuration: configuration1)

let configuration2 = LoggerConfiguration(executionMethod: .Asynchronous(queue: sharedQueue))
let logger2 = Logger(configuration: configuration2)
```

#### Mixing and Matching

In Willow 2.0, it is no longer possible to share a queue between synchronous and asynchronous loggers. This behavior was allowed in Willow 1.x, but has been removed to make Willow more robust. If you want to avoid log mangling across all Logger instances, you MUST have use either a `.Synchronous` or `.Asynchronous` execution method across all `Logger` instances while sharing either the `lock` or `queue` between them.

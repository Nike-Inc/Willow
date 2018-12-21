# Willow

[![Build Status](https://travis-ci.org/Nike-Inc/Willow.svg?branch=master)](https://travis-ci.org/Nike-Inc/Willow)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Willow.svg)](https://img.shields.io/cocoapods/v/Willow.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Willow.svg?style=flat)](http://cocoadocs.org/docsets/Willow)

Willow is a powerful, yet lightweight logging library written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Migration Guides](#migration-guides)
- [Communication](#communication)
- [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
- [Usage](#usage)
    - [Creating a Logger](#creating-a-logger)
    - [Logging Messages with Closures](#logging-messages-with-closures)
    - [Disabling a Logger](#disabling-a-logger)
    - [Synchronous and Asynchronous Logging](#synchronous-and-asynchronous-logging)
    - [Log Modifiers](#log-modifiers)
    - [Log Writers](#log-writers)
- [Advanced Usage](#advanced-usage)
    - [Creating Custom Log Levels](#creating-custom-log-levels)
    - [Shared Loggers between Frameworks](#shared-loggers-between-frameworks)
    - [Multiple Loggers, One Queue](#multiple-loggers-one-queue)
- [FAQ](#faq)
- [License](#license)
- [Creators](#creators)

## Features

- [X] Default Log Levels
- [X] Custom Log Levels
- [X] Simple Logging Functions using Closures
- [X] Configurable Synchronous or Asynchronous Execution
- [X] Thread-Safe Logging Output (No Log Mangling)
- [X] Custom Writers through Dependency Injection
- [X] Custom Modifiers through Dependency Injection per Writer
- [X] Supports Multiple Simultaneous Writers
- [X] Shared Loggers Between Frameworks
- [X] Shared Locks or Queues Between Multiple Loggers
- [X] Comprehensive Unit Test Coverage
- [X] Complete Documentation

## Requirements

- iOS 9.0+ / Mac OS X 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.3+
- Swift 4.1+

## Migration Guides

- [Willow 2.0 Migration Guide](https://github.com/Nike-Inc/Willow/blob/master/Documentation/Willow%202.0%20Migration%20Guide.md)
- [Willow 3.0 Migration Guide](https://github.com/Nike-Inc/Willow/blob/master/Documentation/Willow%203.0%20Migration%20Guide.md)
- [Willow 4.0 Migration Guide](https://github.com/Nike-Inc/Willow/blob/master/Documentation/Willow%204.0%20Migration%20Guide.md)
- [Willow 5.0 Migration Guide](https://github.com/Nike-Inc/Willow/blob/master/Documentation/Willow%205.0%20Migration%20Guide.md)

## Communication

- Need help? Open an issue.
- Have a feature request? Open an issue.
- Find a bug? Open an issue.
- Want to contribute? Fork the repo and submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

> CocoaPods 1.3+ is required.

To integrate Willow into your project, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

pod 'Willow', '~> 5.0'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Willow into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "Nike-Inc/Willow" ~> 5.0
```

Run `carthage update` to build the framework and drag the built `Willow.framework` into your Xcode project.

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.
It is in early development, but Willow does support its use on supported platforms.

Once you have your Swift package set up, adding Willow as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/Nike-Inc/Willow.git", majorVersion: 5)
]
```

---

## Usage

### Creating a Logger

```swift
import Willow

let defaultLogger = Logger(logLevels: [.all], writers: [ConsoleWriter()])
```

The `Logger` initializer takes three parameters to customize the behavior of the logger instance.

- `logLevels: [LogLevel]` - The log message levels that should be processed.
Messages that don't match the current log level are not processed.

- `writers: [LogWriter]` - The array of writers to write to.
Writers can be used to log output to a specific destination such as the console, a file, or an external service.

- `executionMethod: ExecutionMethod = .synchronous(lock: NSRecursiveLock())` - The execution method used when writing messages.

`Logger` objects can only be customized during initialization.
If you need to change a `Logger` at runtime, it is advised to create an additional logger with a custom configuration to fit your needs.
It is perfectly acceptable to have many different `Logger` instances running simultaneously.

#### Thread Safety

The `print` function does not guarantee that the `String` parameter will be fully logged to the console.
If two `print` calls are happening simultaneously from two different queues (threads), the messages can get mangled, or intertwined.
`Willow` guarantees that messages are completely finished writing before starting on the next one.

> It is important to note that by creating multiple `Logger` instances, you can potentially lose the guarantee of thread-safe logging.
> If you want to use multiple `Logger` instances, you should create a `NSRecursiveLock` or `DispatchQueue` that is shared between both configurations.
> For more info, see the [Advanced Usage](#advanced-usage) section.

### Logging Messages and String Messages

Willow can log two different types of objects: Messages and Strings.

#### Log Messages

Messages are structured data with a name and a dictionary of attributes.
Willow declares the `LogMessage` protocol which frameworks and applications can use as the basis for concrete implementations.
Messages are a good choice if you want to provide context information along with the log text (e.g. routing log information to an external system like New Relic).

```swift
enum Message: LogMessage {
    case requestStarted(url: URL)
    case requestCompleted(url: URL, response: HTTPURLResponse)

    var name: String {
        switch self {
        case .requestStarted:   return "Request started"
        case .requestCompleted: return "Request completed"
        }
    }

    var attributes: [String: Any] {
        switch self {
        case let .requestStarted(url):
            return ["url": url]

        case let .requestCompleted(url, response):
            return ["url": url, "response_code": response.statusCode]
        }
    }
}

let url = URL(string: "https://httpbin.org/get")!

log.debug(Message.requestStarted(url: url))
log.info(Message.requestStarted(url: url))
log.event(Message.requestStarted(url: url))
log.warn(Message.requestStarted(url: url))
log.error(Message.requestStarted(url: url))
```

#### Log Message Strings

Log message strings are just `String` instances with no additional data.

```swift
let url = URL(string: "https://httpbin.org/get")!

log.debugMessage("Request Started: \(url)")
log.infoMessage("Request Started: \(url)")
log.eventMessage("Request Started: \(url)")
log.warnMessage("Request Started: \(url)")
log.errorMessage("Request Started: \(url)")
```

> The log message string APIs have the `Message` suffix on the end to avoid ambiguity with the log message APIs.
> The multi-line escaping closure APIs collide without the suffix.

### Logging Messages with Closures

The logging syntax of Willow was optimized to make logging as lightweight and easy to remember as possible.
Developers should be able to focus on the task at hand and not remembering how to write a log message.

#### Single Line Closures

```swift
let log = Logger()

// Option 1
log.debugMessage("Debug Message")    // Debug Message
log.infoMessage("Info Message")      // Info Message
log.eventMessage("Event Message")    // Event Message
log.warnMessage("Warn Message")      // Warn Message
log.errorMessage("Error Message")    // Error Message

// or

// Option 2
log.debugMessage { "Debug Message" } // Debug Message
log.infoMessage { "Info Message" }   // Info Message
log.eventMessage { "Event Message" } // Event Message
log.warnMessage { "Warn Message" }   // Warn Message
log.errorMessage { "Error Message" } // Error Message
```

Both of these approaches are equivalent.
The first set of APIs accept autoclosures and the second set accept closures.

> Feel free to use whichever syntax you prefer for your project.
Also, by default, only the `String` returned by the closure will be logged.
See the [Log Modifiers](#log-modifiers) section for more information about customizing log message formats.

The reason both sets of APIs use closures to extract the log message is performance.

> There are some VERY important performance considerations when designing a logging solution that are described in more detail in the [Closure Performance](#closure-performance) section.

#### Multi-Line Closures

Logging a message is easy, but knowing when to add the logic necessary to build a log message and tune it for performance can be a bit tricky.
We want to make sure logic is encapsulated and very performant.
`Willow` log level closures allow you to cleanly wrap all the logic to build up the message.

```swift
log.debugMessage {
    // First let's run a giant for loop to collect some info
    // Now let's scan through the results to get some aggregate values
    // Now I need to format the data
    return "Computed Data Value: \(dataValue)"
}

log.infoMessage {
    let countriesString = ",".join(countriesArray)
    return "Countries: \(countriesString)"
}
```

> Unlike the Single Line Closures, the Multi-Line Closures require a `return` declaration.

#### Closure Performance

Willow works exclusively with logging closures to ensure the maximum performance in all situations.
Closures defer the execution of all the logic inside the closure until absolutely necessary, including the string evaluation itself.
In cases where the Logger instance is disabled, log execution time was reduced by 97% over the traditional log message methods taking a `String` parameter.
Additionally, the overhead for creating a closure was measured at 1% over the traditional method making it negligible.
In summary, closures allow Willow to be extremely performant in all situations.

### Disabling a Logger

The `Logger` class has an `enabled` property to allow you to completely disable logging.
This can be helpful for turning off specific `Logger` objects at the app level, or more commonly to disable logging in a third-party library.

```swift
let log = Logger()
log.enabled = false

// No log messages will get sent to the registered Writers

log.enabled = true

// We're back in business...
```

### Synchronous and Asynchronous Logging

Logging can greatly affect the runtime performance of your application or library.
Willow makes it very easy to log messages synchronously or asynchronously.
You can define this behavior when creating the `LoggerConfiguration` for your `Logger` instance.

```swift
let queue = DispatchQueue(label: "serial.queue", qos: .utility)
let log = Logger(logLevels: [.all], writers: [ConsoleWriter()], executionMethod: .asynchronous(queue: queue))
```

#### Synchronous Logging

Synchronous logging is very helpful when you are developing your application or library.
The log operation will be completed before executing the next line of code.
This can be very useful when stepping through the debugger.
The downside is that this can seriously affect performance if logging on the main thread.

#### Asynchronous Logging

Asynchronous logging should be used for deployment builds of your application or library.
This will offload the logging operations to a separate dispatch queue that will not affect the performance of the main thread.
This allows you to still capture logs in the manner that the `Logger` is configured, yet not affect the performance of the main thread operations.

> These are large generalizations about the typical use cases for one approach versus the other.
> Before making a final decision about which approach to use when, you should really break down your use case in detail.

### Log Writers

Writing log messages to various locations is an essential feature of any robust logging library.
This is made possible in `Willow` through the `LogWriter` protocol.

```swift
public protocol LogWriter {
    func writeMessage(_ message: String, logLevel: LogLevel)
    func writeMessage(_ message: Message, logLevel: LogLevel)
}
```

Again, this is an extremely lightweight design to allow for ultimate flexibility.
As long as your `LogWriter` classes conform, you can do anything with those log messages that you want.
You could write the message to the console, append it to a file, send it to a server, etc.
Here's a quick look at a simple write that writes to the console.

```swift
open class ConsoleWriter: LogMessageWriter {
    open func writeMessage(_ message: String, logLevel: LogLevel) {
        print(message)
    }

    open func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
        let message = "\(message.name): \(message.attributes)"
        print(message)
    }
}
```

### Log Modifiers

Log message customization is something that `Willow` specializes in.
Some devs want to add a prefix to their library output, some want different timestamp formats, some even want emoji!
There's no way to predict all the types of custom formatting teams are going to want to use.
This is where `LogModifier` objects come in.

```swift
public protocol LogModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String
}
```

The `LogModifier` protocol has only a single API.
It receives the `message` and `logLevel` and returns a newly formatted `String`.
This is about as flexible as you can get.

As an added layer of convenience, writers intending to output strings (e.g. writing to the console, files, etc.) can conform to the `LogModifierWritier` protocol.
The `LogModifierWriter` protocol adds an array of `LogModifier` objects to the `LogWriter` that can be applied to the message before it is output using the `modifyMessage(_:logLevel)` API in the extension.

Let's walk through a simple example for adding a prefix to a logger for the `debug` and `info` log levels.

```swift
class PrefixModifier: LogModifier {
    func modifyMessage(_ message: String, with logLevel: Logger.LogLevel) -> String {
        return "[Willow] \(message)"
    }
}

let prefixModifiers = [PrefixModifier()]
let writers = [ConsoleWriter(modifiers: prefixModifier)]
let log = Logger(logLevels: [.debug, .info], writers: writers)
```

To apply modifiers consistently to strings, `LogModifierWriter` objects should call `modifyMessage(_:logLevel)` to create a new string based on the original string with all the modifiers applied in order.

```swift
open func writeMessage(_ message: String, logLevel: LogLevel) {
    let message = modifyMessage(message, logLevel: logLevel)
    print(message)
}
```

#### Multiple Modifiers

Multiple `LogModifier` objects can be stacked together onto a single log level to perform multiple actions.
Let's walk through using the `TimestampModifier` (prefixes the message with a timestamp) in combination with an `EmojiModifier`.

```swift
class EmojiModifier: LogModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        return "🚀🚀🚀 \(message)"
    }
}

let writers: = [ConsoleWriter(modifiers: [EmojiModifier(), TimestampModifier()])]
let log = Logger(logLevels: [.all], writers: writers)
```

`Willow` doesn't have any hard limits on the total number of `LogModifier` objects that can be applied to a single log level.
Just keep in mind that performance is key.

> The default `ConsoleWriter` will execute the modifiers in the same order they were added into the `Array`.
In the previous example, Willow would log a much different message if the `TimestampModifier` was inserted before the `EmojiModifier`.

#### OSLog

The `OSLogWriter` class allows you to use the `os_log` APIs within the Willow system.
In order to use it, all you need to do is to create the `LogModifier` instance and add it to the `Logger`.

```swift
let writers = [OSLogWriter(subsystem: "com.nike.willow.example", category: "testing")]
let log = Logger(logLevels: [.all], writers: writers)

log.debugMessage("Hello world...coming to your from the os_log APIs!")
```

#### Multiple Writers

So what about logging to both a file and the console at the same time? No problem.
You can pass multiple `LogWriter` objects into the `Logger` initializer.
The `Logger` will execute each `LogWriter` in the order it was passed in.
For example, let's create a `FileWriter` and combine that with our `ConsoleWriter`.

```swift
public class FileWriter: LogWriter {
    public func writeMessage(_ message: String, logLevel: Logger.LogLevel, modifiers: [LogMessageModifier]?) {
	    var message = message
        modifiers?.map { message = $0.modifyMessage(message, with: logLevel) }
        // Write the formatted message to a file (We'll leave this to you!)
    }

    public func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
        let message = "\(message.name): \(message.attributes)"
        // Write the formatted message to a file (We'll leave this to you!)
    }
}

let writers: [LogMessageWriter] = [FileWriter(), ConsoleWriter()]
let log = Logger(logLevels: [.all], writers: writers)
```

> `LogWriter` objects can also be selective about which modifiers they want to run for a particular log level.
> All the examples run all the modifiers, but you can be selective if you want to be.

---

## Advanced Usage

### Creating Custom Log Levels

Depending upon the situation, the need to support additional log levels may arise.
Willow can easily support additional log levels through the art of [bitmasking](http://en.wikipedia.org/wiki/Mask_(computing)).
Since the internal `RawValue` of a `LogLevel` is a `UInt`, Willow can support up to 32 log levels simultaneously for a single `Logger`.
Since there are 7 default log levels, Willow can support up to 27 custom log levels for a single logger.
That should be more than enough to handle even the most complex of logging solutions.

Creating custom log levels is very simple. Here's a quick example of how to do so.
First, you must create a `LogLevel` extension and add your custom values.

```swift
extension LogLevel {
    private static var verbose = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
}
```

> It's a good idea to make the values for custom log levels `var` instead of `let`.
In the event of two frameworks using the same custom log level bit mask, the application can re-assign one of the frameworks to a new value.

Now that we have a custom log level called `verbose`, we need to extend the `Logger` class to be able to easily call it.

```swift
extension Logger {
    public func verboseMessage(_ message: @autoclosure @escaping () -> String) {
    	logMessage(message, with: .verbose)
    }

    public func verboseMessage(_ message: @escaping () -> String) {
    	logMessage(message, with: .verbose)
    }
}
```

Finally, using the new log level is a simple as...

```swift
let log = Logger(logLevels: [.all], writers: [ConsoleWriter()])
log.verboseMessage("My first verbose log message!")
```

> The `all` log level contains a bitmask where all bits are set to 1.
> This means that the `all` log level will contain all custom log levels automatically.

### Shared Loggers between Frameworks

Defining a single `Logger` and sharing that instance several frameworks can be very advantageous, especially with the addition of Frameworks in iOS 8.
Now that we're going to be creating more frameworks inside our own apps to be shared between apps, extensions and third party libraries, wouldn't it be nice if we could share `Logger` instances?

Let's walk through a quick example of a `Math` framework sharing a `Logger` with it's parent `Calculator` app.

```swift
//=========== Inside Math.swift ===========
public var log: Logger?

//=========== Calculator.swift ===========
import Math

let writers: [LogMessageWriter] = [FileWriter(), ConsoleWriter()]
var log = Logger(logLevels: [.all], writers: writers)

// Set the Math.log instance to the Calculator.log to share the same Logger instance
Math.log = log
```

It's very simple to swap out a pre-existing `Logger` with a new one.

### Multiple Loggers, One Queue

The previous example showed how to share `Logger` instances between multiple frameworks.
Something more likely though is that you would want to have each third party library or internal framework to have their own `Logger` with their own configuration.
The one thing that you really want to share is the `NSRecursiveLock` or `DispatchQueue` that they run on.
This will ensure all your logging is thread-safe.
Here's the previous example demonstrating how to create multiple `Logger` instances and still share the queue.

```swift
//=========== Inside Math.swift ===========
public var log: Logger?

//=========== Calculator.swift ===========
import Math

// Create a single queue to share
let sharedQueue = DispatchQueue(label: "com.math.logger", qos: .utility)

// Create the Calculator.log with multiple writers and a .Debug log level
let writers: [LogMessageWriter] = [FileWriter(), ConsoleWriter()]

var log = Logger(
    logLevels: [.all],
    writers: writers,
    executionMethod: .asynchronous(queue: sharedQueue)
)

// Replace the Math.log with a new instance with all the same configuration values except a shared queue
Math.log = Logger(
    logLevels: log.logLevels,
    writers: [ConsoleWriter()],
    executionMethod: .asynchronous(queue: sharedQueue)
)
```

`Willow` is a very lightweight library, but its flexibility allows it to become very powerful if you so wish.

---

## FAQ

### Why 5 default log levels? And why are they so named?

Simple...simplicity and elegance.
Contextually it gets difficult to understand which log level you need if you have too many.
However, that doesn't mean that this is always the perfect solution for everyone or every use case.
This is why there are 5 default log levels, with support for easily adding additional ones.

As for the naming, here's our mental breakdown of each log level for an iOS app (obviously it depends on your use case).

* `debug` - Highly detailed information of a context
* `info` - Summary information of a context
* `event` - User driven interactions such as button taps, view transitions, selecting a cell
* `warn` - An error occurred but it is recoverable
* `error` - A non-recoverable error occurred

### When should I use Willow?

If you are starting a new iOS project in Swift and want to take advantage of many new conventions and features of the language, Willow would be a great choice.
If you are still working in Objective-C, a pure Objective-C library such as [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) would probably be more appropriate.

### Where did the name Willow come from?

Willow is named after the one, the only, Willow tree.

---

## License

Willow is released under the MIT license.
See LICENSE for details.

## Creators

- [Christian Noon](https://github.com/cnoon) ([@Christian_Noon](https://twitter.com/Christian_Noon))
- [Eric Appel](https://github.com/ericappel) ([@EricAppel](https://twitter.com/EricAppel))
- [Dave Camp](https://github.com/atomiccat) ([@thinbits](https://twitter.com/thinbits))

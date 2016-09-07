# Willow

[![Build Status](https://travis-ci.org/Nike-Inc/Willow.svg?branch=master)](https://travis-ci.org/Nike-Inc/Willow)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Willow.svg)](https://img.shields.io/cocoapods/v/Willow.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/Willow.svg?style=flat)](http://cocoadocs.org/docsets/Willow)

Willow is a powerful, yet lightweight logging library written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
    - [CocoaPods](#cocoapods)
    - [Carthage](#carthage)
- [Usage](#usage)
    - [Creating a Logger](#creating-a-logger)
        - [Logger Configuration](#logger-configuration)
        - [Thread Safety](#thread-safety)
    - [Logging Messages with Closures](#logging-messages-with-closures)
        - [Single Line Closures](#single-line-closures)
        - [Multi-Line Closures](#multi-line-closures)
        - [Closure Performance](#closure-performance)
    - [Disabling a Logger](#disabling-a-logger)
    - [Synchronous and Asynchronous Logging](#synchronous-and-asynchronous-logging)
        - [Synchronous Logging](#synchronous-logging)
        - [Asynchronous Logging](#asynchronous-logging)
    - [Formatters](#formatters)
        - [Color Formatters](#color-formatters)
        - [Multiple Formatters](#multiple-formatters)
    - [Writers](#writers)
        - [Multiple Writers](#multiple-writers)
        - [Per LogLevel Writers](#per-loglevel-writers)
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
- [X] Custom Formatters through Dependency Injection per Log Level
- [X] Customizable Color Formatting for Console Output
- [X] Custom Writers through Dependency Injection per Log Level
- [X] Supports Multiple Simultaneous Writers
- [X] Shared Loggers Between Frameworks
- [X] Shared Locks or Queues Between Multiple Loggers
- [X] Comprehensive Unit Test Coverage
- [X] Complete Documentation

## Requirements

- iOS 8.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+
- Swift 2.3

## Communication

- Need help? Open an issue.
- Have a feature request? Open an issue.
- Find a bug? Open an issue.
- Want to contribute? Fork the repo and submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

> CocoaPods 1.0+ is required.

To integrate Willow into your project, specify it in your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Willow', '~> 1.2'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
brew update
brew install carthage
```

To integrate Willow into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "Nike-Inc/Willow" ~> 1.2
```

Run `carthage update` to build the framework and drag the built `Willow.framework` into your Xcode project.

---

## Usage

### Creating a Logger

```swift
import Willow
let defaultLogger = Logger()
```

The `Logger` initializer takes a single parameter which is a `LoggerConfiguration`. If no configuration is provided, the Logger will internally initialize a `LoggerConfiguration` with default parameters.

#### Logger Configuration

The `LoggerConfiguration` class is a container class to store all the configuration information to be applied to a particular `Logger`. Here are all the configurable parameters and their respective descriptions.

* `formatters: [LogLevel: [Formatter]] = [:]` - The dictionary of formatters to apply to each associated log level.
* `writers: [LogLevel: [Writer]] = [.All: [ConsoleWriter()]` - The dictionary of writers to write to for the associated log level. Writers can be used to log output to a specific destination such as the console or to a file.
* `executionMethod: ExecutionMethod = .Synchronous(lock: NSRecursiveLock())` - The execution method used when writing messages.

`LoggerConfiguration` and `Logger` objects can only be customized during initialization. If you need to change a `Logger` at runtime, it is advised to create an additional logger with a custom configuration to fit your needs. It is perfectly acceptable to have many different `Logger` instances running simutaneously.

There are two class methods that return custom `LoggerConfiguration` instances using combinations of the custom `Formatter` objects. These convenience methods make it VERY easy add timestamps as well as colored log message formatting to your `Logger` instance.

* `timestampConfiguration()` - A logger configuration instance with a timestamp formatter applied to each log level.
* `coloredTimestampConfiguration()` - A logger configuration instance with a timestamp and color formatter applied to each log level.

#### Thread Safety

The `println` function does not guarantee that the `String` parameter will be fully logged to the console. If two `println` calls are happening simultaneously from two different queues (threads), the messages can get mangled, or intertwined. `Willow` guarantees that messages are completely finished writing before starting on the next one.

> It is important to note that by creating multiple `Logger` instances, you can potentially lose the guarantee of thread-safe logging. If you want to use multiple `Logger` instances, you should create a `NSRecursiveLock` or `dispatch_queue_t` that is shared between both configurations. For more info...see the [Advanced Usage](#advanced-usage) section.

### Logging Messages with Closures

The logging syntax of Willow was optimized to make logging as lightweight and easy to remember as possible. Developers should be able to focus on the task at hand and not remembering how to write a log message.

#### Single Line Closures

```swift
let log = Logger()

// Option 1
log.debug("Debug Message")    // Debug Message
log.info("Info Message")      // Info Message
log.event("Event Message")    // Event Message
log.warn("Warn Message")      // Warn Message
log.error("Error Message")    // Error Message

// or

// Option 2
log.debug { "Debug Message" } // Debug Message
log.info { "Info Message" }   // Info Message
log.event { "Event Message" } // Event Message
log.warn { "Warn Message" }   // Warn Message
log.error { "Error Message" } // Error Message
```

Both of these approaches are equivalent. The first set of APIs accept autoclosures and the second set accept closures.

> Feel free to use whichever syntax you prefer for your project. Also, by default, only the `String` returned by the closure will be logged. See the [Formatters](#formatters) section for more information about customizing log message formats.

The reason both sets of APIs use closures to extract the log message is performance. 

> There are some VERY important performance considerations when designing a logging solution that are described in more detail in the [Closure Performance](#closure-performance) section.

#### Multi-Line Closures

Logging a message is easy, but knowing when to add the logic necessary to build a log message and tune it for performance can be a bit tricky. We want to make sure logic is encapsulated and very performant. `Willow` log level closures allow you to cleanly wrap all the logic to build up the message.

```swift
log.debug {
    // First let's run a giant for loop to collect some info
    // Now let's scan through the results to get some aggregate values
    // Now I need to format the data
    return "Computed Data Value: \(dataValue)"
}

log.info {
    let countriesString = ",".join(countriesArray)
    return "Countries: \(countriesString)"
}
```

> Unlike the Single Line Closures, the Multi-Line Closures require a `return` declaration.

#### Closure Performance

Willow works exclusively with logging closures to ensure the maximum performance in all situations. Closures defer the execution of all the logic inside the closure until absolutely necessary, including the string evaluation itself. In cases where the Logger instance is disabled, log execution time was reduced by 97% over the traditional log message methods taking a `String` parameter. Additionally, the overhead for creating a closure was measured at 1% over the traditional method making it negligible. In summary, closures allow Willow to be extremely performant in all situations.

### Disabling a Logger

The `Logger` class has an `enabled` property to allow you to completely disable logging. This can be helpful for turning off specific `Logger` objects at the app level, or more commonly to disable logging in a third-party library.

```swift
let log = Logger()
log.enabled = false

// No log messages will get sent to the registered Writers

log.enabled = true

// We're back in business...
```

### Synchronous and Asynchronous Logging

Logging can greatly affect the runtime performance of your application or library. Willow makes it very easy to log messages synchronously or asynchronously. You can define this behavior when creating the `LoggerConfiguration` for your `Logger` instance.

```swift
let queue = dispatch_queue_create("serial.queue", DISPATCH_QUEUE_SERIAL)
let configuration = LoggerConfiguration(executionMethod: .Asynchronous(queue: queue))
let log = Logger(configuration: configuration)
```

#### Synchronous Logging

Synchronous logging is very helpful when you are developing your application or library. The log operation will be completed before executing the next line of code. This can be very useful when stepping through the debugger. The downside is that this can seriously affect performance if logging on the main thread.

#### Asynchronous Logging

Asynchronous logging should be used for deployment builds of your application or library. This will offload the logging operations to a separate dispatch queue that will not affect the performance of the main thread. This allows you to still capture logs in the manner that the `Logger` is configured, yet not affect the performance of the main thread operations.

> These are large generalizations about the typical use cases for one approach versus the other. Before making a final decision about which approach to use when, you should really break down your use case in detail.

### Formatters

Log message customization is something that `Willow` specializes in. Some devs want to add a prefix to their library output, some want different timestamp formats, some even want emoticons! There's no way to predict all the types of custom formatting teams are going to want to use. This is where `Formatter` objects come in.

```swift
public protocol Formatter {
    func formatMessage(message: String, logLevel: LogLevel) -> String
}
```

The `Formatter` protocol has only a single API. It receives the `message` and `logLevel` and returns a newly formatted `String`. This is about as flexible as you can get. The `Logger` allows you to pass in your own `Formatter` objects and apply them to a `LogLevel`. Let's walk through a simple example for adding a prefix to only the `Debug` and `Info` log levels.

```swift
class PrefixFormatter: Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        return "[Willow] \(message)"
    }
}

let prefixFormatter = PrefixFormatter()

let formatters: [Logger.LogLevel: [Formatter]] = [
    .Debug: [prefixFormatter],
    .Info: [prefixFormatter]
]

let configuration = LoggerConfiguration(formatters: formatters)
let log = Logger(configuration: configuration)
```

`Formatter` objects are very powerful and can manipulate the message in any way.

#### Multiple Formatters

Multiple `Formatter` objects can be stacked together onto a single log level to perform multiple actions. Let's walk through using the `TimestampFormatter` (prefixes the message with a timestamp) in combination with an `EmojiFormatter`.

```swift
class EmojiFormatter: Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        return "🚀🚀🚀 \(message)"
    }
}

let formatters: [Logger.LogLevel: [Formatter]] = [.All: [EmojiFormatter(), TimestampFormatter()]
let configuration = LoggerConfiguration(formatters: formatters)
let log = Logger(configuration: configuration)
```

`Willow` doesn't have any hard limits on the total number of `Formatter` objects that can be applied to a single log level. Just keep in mind that performance is key.

> The default `ConsoleWriter` will execute the formatters in the same order they were added into the `Array`. In the previous example, Willow would log a much different message if the `TimestampFormatter` was inserted before the `EmojiFormatter`.

### Writers

Writing log messages to various locations is an essential feature of any robust logging library. This is made possible in `Willow` through the `Writer` protocol.

```swift
public protocol Writer {
    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?)
}
```

Again, this is an extremely lightweight design to allow for ultimate flexibility. As long as your `Writer` classes conform, you can do anything with those log messages that you want. You could write the message to the console, append it to a file, send it to a server, etc. Here's a quick look at the implementation of the default `ConsoleWriter` created by the `Logger` if you don't specify your own.

```swift
public class ConsoleWriter: Writer {
    public func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?) {
    	var mutableMessage = message
        formatters?.map { mutableMessage = $0.formatMessage(mutableMessage, logLevel: logLevel) }
        println(mutableMessage)
    }
}
```

#### Multiple Writers

So what about logging to both a file and the console at the same time? No problem. You can pass multiple `Writer` objects into the `Logger` initializer. The `Logger` will execute each `Writer` in the order it was passed in. For example, let's create a `FileWriter` and combine that with our `ConsoleWriter`.

```swift
public class FileWriter: Writer {
    public func writeMessage(var message: String, logLevel: Logger.LogLevel, formatters: [Formatter]?) {
	    var mutableMessage = message
        formatters?.map { mutableMessage = $0.formatMessage(mutableMessage, logLevel: logLevel) }
        // Write the formatted message to a file (I'll leave this to you!)
    }
}

let writers: [LogLevel: Writer] = [.All: [FileWriter(), ConsoleWriter()]]

let configuration = LoggerConfiguration(writers: writers)
let log = Logger(configuration: configuration)
```

> `Writer` objects can also be selective about which formatters they want to run for a particular log level. All the examples run all the formatters, but you can be selective if you want to be.

#### Per LogLevel Writers

It is also possible to specify different combinations of `Writer` objects for each `LogLevel`. Let's say we want to log `.Warn` and `.Error` messages to the console, and we want to log all messages to a file writer.

```swift
let writers: [LogLevel: Writer] = [
	.All: [FileWriter()],
	[.Warn, .Error]: [ConsoleWriter()]
]

let configuration = LoggerConfiguration(writers: writers)
let log = Logger(configuration: configuration)
```

---

## Advanced Usage

### Creating Custom Log Levels

Depending upon the situation, the need to support additional log levels may arise. Willow can easily support additional log levels through the art of [bitmasking](http://en.wikipedia.org/wiki/Mask_(computing)). Since the internal `RawValue` of a `LogLevel` is a `UInt`, Willow can support up to 32 log levels simultaneously for a single `Logger`. Since there are 7 default log levels, Willow can support up to 27 custom log levels for a single logger. That should be more than enough to handle even the most complex of logging solutions.

Creating custom log levels is very simple. Here's a quick example of how to do so. First, you must create a `LogLevel` extension and add your custom values.

```swift
extension LogLevel {
    private static let Verbose = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
}
```

Now that we have a custom log level called `Verbose`, we need to extend the `Logger` class to be able to easily call it.

```swift
extension Logger {
    public func verbose(message: () -> String) {
    	logMessage(message, withLogLevel: .Verbose)
    }
}
```

Finally, using the new log level is a simple as...

```swift
let log = Logger()
log.verbose("My first verbose log message!")
```

> The `All` log level contains a bitmask where all bits are set to 1. This means that the `All` log level will contain all custom log levels automatically.

### Shared Loggers between Frameworks

Defining a single `Logger` and sharing that instance several frameworks could be very advantageous. Especially with the addition of Frameworks in iOS 8. Now that we're going to be creating more frameworks inside our own apps to be shared between apps, extensions and third party libraries, wouldn't it be nice if we could share `Logger` instances?

Let's walk through a quick example of a `Math` framework sharing a `Logger` with it's parent `Calculator` app.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(configuration: LoggerConfiguration(writers: [.Warn, .Error]: [ConsoleWriter()])) // We're going to replace this

//=========== Calculator.swift ===========
import Math

let writers = [.All: [FileWriter(), ConsoleWriter()]]
var log = Logger(configuration: LoggerConfiguration(writers: writers))

// Replace the Math.log with the Calculator.log to share the same Logger instance
Math.log = log
```

It's very simple to swap out a pre-existing `Logger` with a new one.

### Multiple Loggers, One Queue

The previous example showed how to share `Logger` instances between multiple frameworks. Something more likely though is that you would want to have each third party library or internal framework to have their own `Logger` with their own configuration. The one thing that you really want to share is the `NSRecursiveLock` or `dispatch_queue_t` that they run on. This will ensure all your logging is thread-safe. Here's the previous example demonstrating how to create multiple `Logger` instances with different configurations and share the queue.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(configuration: LoggerConfiguration(writers: [.Warn, .Error]: [ConsoleWriter()])) // We're going to replace this

//=========== Calculator.swift ===========
import Math

// Create a single queue to share
let sharedQueue = dispatch_queue_create("com.math.logger", DISPATCH_QUEUE_SERIAL)

// Create the Calculator.log with multiple writers and a .Debug log level
let writers = [.All: [FileWriter(), ConsoleWriter()]]
let configuration = LoggerConfiguration(
    writers: writers, 
    executionMethod: .Asynchronous(queue: sharedQueue)
)

var log = Logger(configuration: configuration)

// Replace the Math.log with a new instance with all the same configuration values except a shared queue
let mathConfiguration = LoggerConfiguration(
    formatters: Math.log.configuration.formatters,
    writers: Math.log.configuration.writers,
    executionMethod: .Asynchronous(queue: sharedQueue)
)

Math.log = Logger(configuration: mathConfiguration)
```

`Willow` is a very lightweight library, but its flexibility allows it to become very powerful if you so wish.

---

## FAQ

### Why 5 default log levels? And why are they so named?

Simple...simplicity and elegance. Contextually it gets difficult to understand which log level you need if you have too many. However, that doesn't mean that this is always the perfect solution for everyone or every use case. This is why there are 5 default log levels, with support for easily adding additional ones.

As for the naming, here's my own mental breakdown of each log level for an iOS app (obviously it depends on your use case).

* `Debug` - Highly detailed information of a context
* `Info` - Summary information of a context
* `Event` - User driven interactions such as button taps, view transitions, selecting a cell
* `Warn` - An error occurred but it is recoverable
* `Error` - A non-recoverable error occurred

### When should I use Willow?

If you are starting a new iOS project in Swift and want to take advantage of many new conventions and features of the language, Willow would be a great choice. If you are still working in Objective-C, a pure Objective-C library such as the amazing [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) would probably be more appropriate.

### Where did the name Willow come from?

Willow is named after the one, the only, Willow tree.

---

## License

Willow is released under the MIT license. See LICENSE for details.

## Creators

- [Christian Noon](https://github.com/cnoon) ([@Christian_Noon](https://twitter.com/Christian_Noon))
- [Eric Appel](https://github.com/ericappel) ([@EricAppel](https://twitter.com/EricAppel))

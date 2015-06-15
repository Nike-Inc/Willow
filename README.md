# Willow

Willow is a powerful, yet lightweight logging library written in Swift.

## Features

- Default Log Levels
- Custom Log Levels
- Simple Logging Functions using Closures
- Configurable Synchronous or Asynchronous Execution
- Thread-Safe Logging Output (No Log Mangling)
- Custom Formatters through Dependency Injection
- Customizable Color Formatting for Console Output per Log Level
- Custom Writers through Dependency Injection
- Supports Multiple Simultaneous Writers
- Shared Loggers Between Frameworks
- Shared Queues Between Multiple Loggers
- Comprehensive Unit Test Coverage
- Complete Documentation

## Requirements

- iOS 7.0+ / Mac OS X 10.9+
- Xcode 6.3

## Communication

- Need help? Start here [StackOverflow](http://stackoverflow.com/questions/tagged/willow). (Tag `Willow`)
- Need to ask a question? Ask here [StackOverflow](http://stackoverflow.com/questions/tagged/willow).
- Want to contribute? Please fork the repo and submit a pull request.
- Have a feature request? Open an issue.
- Find a bug? Open an issue.

## Installation

Embedded frameworks require a minimum deployment target of iOS 8 or OS X Mavericks.

> Swift is not supported for deployment targets below iOS 7, so Willow can only be used with iOS 7+ deployment targets. With that said, we strongly encourage users to only use Willow in iOS 8+ deployment targets. Targeting iOS 7 is problematic and not supported by dependency management systems such as CocoaPods and Carthage.

### CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
[sudo] gem install cocoapods
```

Now to add the `Willow` pod to your project, create your [Podfile](http://guides.cocoapods.org/using/the-podfile.html) and add the following.

```ruby
platform :ios, '8.0'
use_frameworks!

# Spec sources
source 'ssh://git@stash.nikedev.com/ncps/nike-private-spec.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'Surge', '~> 0.3.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with Homebrew using the following command:

```bash
brew update
brew install carthage
```

To integrate Willow into your Xcode project using Carthage, specify it in your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
git "ssh://git@stash.nikedev.com/bmd/surge.git" ~> 0.3.0
```

---

## Usage

### Creating a Logger

```swift
import Willow
let defaultLogger = Logger()
```

The `Logger` initializer takes a single parameter which is a `LoggerConfiguration`. If no configuration is provided, the Logger will internally initialize a `LoggerConfiguration` with default parameters.

#### LoggerConfiguration

The `LoggerConfiguration` class is a container class to store all the configuration information to be applied to a particular `Logger`. Here are all the configurable parameters and their respective descriptions.

* `logLevel: LogLevel = .Info | .Event | .Warn | .Error` - The log level used to determine which messages are written. Each `LogLevel` conforms to the `BitwiseOperationsType`, so use bit operations if you wish to set a custom `LogLevel`. `.All` by default.
* `formatters: [LogLevel: [Formatter]]? = nil` - The dictionary of formatters to apply to each associated log level.
* `writers: [Writer] = [ConsoleWriter()]` - The writers to use when messages need to be written to a specific destination such as the console or to a file.
* `asynchronous: Bool = false` - Whether to write messages asynchronously on the given queue.
* `queue: dispatch_queue_t? = nil` - A custom dispatch queue to handle thread-safety to avoid log mangling. If you do not provide one, the Logger instance will create it's own internally.

`LoggerConfiguration` and `Logger` objects can only be customized during initialization. If you need to change a `Logger` at runtime, it is advised to create an additional logger with a custom configuration to fit your needs. It is perfectly acceptable to have many different `Logger` instances running simutaneously.

There are two class methods that return custom `LoggerConfiguration` instances using combinations of the custom `Formatter` objects. These convenience methods make it VERY easy add timestamps as well as colored log message formatting to your `Logger` instance.

* `timestampConfiguration()` - A logger configuration instance with a timestamp formatter applied to each log level.
* `coloredTimestampConfiguration()` - A logger configuration instance with a timestamp and color formatter applied to each log level.

#### Thread Safety

The `println` function does not guarantee that the `String` parameter will be fully logged to the console. If two `println` calls are happening simultaneously from two different queues (threads), the messages can get mangled, or intertwined. `Willow` guarantees that messages are completely finished writing before starting on the next one.

> It is important to note that by creating multiple `Logger` instances, you can potentially lose the guarantee of thread-safe logging. If you want to use multiple `Logger` instances, you should create a `dispatch_queue_t` that is shared between both configurations. For more info...see the [Advanced Usage](Advanced Usage) section.

### Logging Messages with Closures

The logging syntax of Willow was optimized to make logging as lightweight and easy to remember as possible. Developers should be able to focus on the task at hand and not remembering how to write a log message.

#### Single Line Closures

```swift
let log = Logger()

log.debug { "Debug Message" }
// Debug Message
log.info { "Info Message" }
// Info Message
log.event { "Event Message" }
// Event Message
log.warn { "Warn Message" }
// Warn Message
log.error { "Error Message" }
// Error Message
```

The single line closure does not require a `return` declaration since it is implied in Swift. This makes it very easy to declare a closure. There are some VERY important performance considerations which is why Willow only accepts closures for all the Logger convenience methods. See the [Closure Performance](Closure Performance) section for more information.

> By default, only the `String` returned by the closure will be logged. See the [Formatters](Formatters) section for more information about customizing log message formats.

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
    let countriesString = join(",", countriesArray)
    return "Countries: \(countriesString)"
}
```

> Unlike the Single Line Closures, the Multi-Line Closures require a `return` declaration.

#### Closure Performance

Willow works exclusively with logging closures to ensure the maximum performance in all situations. Closures defer the execution of all the logic inside the closure until absolutely necessary, including the string evaluation itself. In cases where the Logger instance is disabled, log execution time was reduced by 97% over the traditional log message methods taking a `String` parameter. Additionally, the overhead for creating a closure was measured at 1% over the traditional method making it negligible. In summary, closures allow Willow to be extremely performant in all situations.

> Unfortunately, it is not possible to utilize `@autoclosure` in this scenario. Swift 1.1 allows `@autoclosure` declaration, but Swift 1.2 does not, due to the way Willow supports Synchronous and Asynchronous logging. The Swift 1.2 `@autoclosure` declaration implies a `@noescape` which conflicts with the internal dispatch queue. Because of this, it was decided to avoid the `@autoclosure` declaration entirely since it would only be supported while on Swift 1.1.

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
let configuration = LoggerConfiguration(asynchronous: true) // false by default
let log = Logger(configuration: configuration)
```

#### Synchronous Logging

Synchronous logging is very helpful when you are developing your application or library. The log operation will be completed before executing the next line of code. This can be very useful when stepping through the debugger. The downside is that this can seriously affect performance if logging on the main thread.

#### Asynchronous Logging

Asynchronous logging should be used for deployment builds of your application or library. This will offload the logging operations to a separate dispatch queue that will not affect the performance of the main thread. This allows you to still capture logs in the manner that the `Logger` is configured, yet not affect the performance of the main thread operations.

> These are large generalizations about the typical use cases for one approach versus the other. Before making a final decision about which approach to use when, you should really break down your use case in detail.

### Formatters

Log message customization is something that `Willow` specializes in. Some devs want to add a prefix to their library output, some want different timestamp formats, some even want colors! There's no way to predict all the types of custom formatting teams are going to want to use. This is where `Formatter` objects come in.

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

### Color Formatters

There is a special `Formatter` in `Willow` called a `ColorFormatter`. It was designed to take a foreground and backround color in the form of a `UIColor` or `NSColor`. It then formats the message to match the coloring scheme of the [XcodeColors](https://github.com/robbiehanson/XcodeColors) plugin. This allows you to change the foreground and background colors of logging output in the Xcode console. This can make it much easier to dig through thousands of lines of logging output.

```swift
let purple = UIColor.purpleColor()
let blue = UIColor.blueColor()
let green = UIColor.greenColor()
let orange = UIColor.orangeColor()
let red = UIColor.redColor()
let white = UIColor.whiteColor()
let black = UIColor.blackColor()

let colorFormatters: [Logger.LogLevel: [Formatter]] = [
    LogLevel.Debug: [ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
    LogLevel.Info: [ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
    LogLevel.Event: [ColorFormatter(foregroundColor: green, backgroundColor: nil)],
    LogLevel.Warn: [ColorFormatter(foregroundColor: black, backgroundColor: orange)],
    LogLevel.Error: [ColorFormatter(foregroundColor: white, backgroundColor: red)]
]

let configuration = LoggerConfiguration(formatters: colorFormatters)
let log = Logger(configuration: configuration)
```

> The XcodeColors plugin is available through [Alcatraz](http://alcatraz.io/) and can be installed with the click of a button.

### Multiple Formatters

Multiple `Formatter` objects can be stacked together onto a single log level to perform multiple actions. Let's walk through using the `TimestampFormatter` (prefixes the message with a timestamp) in combination with the `ColorFormatter` objects from the previous example.

```swift
let purple = UIColor.purpleColor()
let blue = UIColor.blueColor()
let green = UIColor.greenColor()
let orange = UIColor.orangeColor()
let red = UIColor.redColor()
let white = UIColor.whiteColor()
let black = UIColor.blackColor()

let timestampFormatter = TimestampFormatter()

let formatters: [Logger.LogLevel: [Formatter]] = [
    LogLevel.Debug: [timestampFormatter, ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
    LogLevel.Info: [timestampFormatter, ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
    LogLevel.Event: [timestampFormatter, ColorFormatter(foregroundColor: green, backgroundColor: nil)],
    LogLevel.Warn: [timestampFormatter, ColorFormatter(foregroundColor: black, backgroundColor: orange)],
    LogLevel.Error: [timestampFormatter, ColorFormatter(foregroundColor: white, backgroundColor: red)]
]

let configuration = LoggerConfiguration(formatters: formatters)
let log = Logger(configuration: configuration)
```

`Willow` doesn't have any hard limits on the total number of `Formatter` objects that can be applied to a single log level. Just keep in mind that performance is key.

> The default `ConsoleWriter` will execute the formatters in the same order they were added into the `Array`. In the previous example, Willow would log a much different message if the `ColorFormatter` was inserted before the `TimestampFormatter`.

### Custom Writers

Writing log messages to various locations is an essential feature of any robust logging library. This is made possible in `Willow` through the `Writer` protocol.

```swift
public protocol Writer {
    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?)
}
```

Again, this is an extremely lightweight design to allow for ultimate flexibility. As long as your `Writer` classes conform, you can do anything with those log messages that you want. You could write the message to the console, append it to a file, send it to a server, etc. Here's a quick look at the implementation of the default `ConsoleWriter` created by the `Logger` if you don't specify your own.

```swift
public class ConsoleWriter: Writer {
    public func writeMessage(var message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        formatters?.map { message = $0.formatMessage(message, logLevel: logLevel) }
        println(message)
    }
}
```

### Multiple Writers

So what about logging to both a file and the console at the same time? No problem. You can pass multiple `Writer` objects into the `Logger` initializer. The `Logger` will execute each `Writer` in the order it was passed in. For example, let's create a `FileWriter` and combine that with our `ConsoleWriter`.

```swift
public class FileWriter: Writer {
    public func writeMessage(var message: String, logLevel: Logger.LogLevel, formatters: [Formatter]?) {
      formatters?.map { message = $0.formatMessage(message, logLevel: logLevel) }
      // Write the formatted message to a file (I'll leave this to you!)
    }
}

let writers: [Writer] = [FileWriter(), ConsoleWriter()]

let configuration = LoggerConfiguration(writers: writers)
let log = Logger(configuration: configuration)
```

> `Writer` objects can also be selective about which formatters they want to run for a particular log level. All the examples run all the formatters, but you can be selective if you want to be.

---

## Advanced Usage

### Creating Custom Log Levels

Depending upon the situation, the need to support additional log levels may arise. Willow can easily support additional log levels through the art of [bitmasking](http://en.wikipedia.org/wiki/Mask_(computing)). Since the internal `RawValue` of a `LogLevel` is a `UInt`, Willow can support up to 32 log levels simultaneously for a single `Logger`. Additionally, the default bitmasks have been spread out so that there are always at least 4 empty bits between the next default `LogLevel`. That means that Willow allows for up to 27 custom log levels. That should be more than enough to handle even the most complex of logging solutions.

Creating custom log levels is very simple. Here's a quick example of how to do so. First, you must create a `LogLevel` extension and add your custom values.

```swift
extension LogLevel {
    // Off      = 0b00000000_00000000_00000000_00000000
    // Verbose  = 0b00000000_00000000_00000000_00000100 // custom
    // Debug    = 0b00000000_00000000_00000000_00010000

    private static var Verbose: LogLevel { return self(0b00000000_00000000_00000000_00000100) }
}
```

Now that we have a custom log level called `Verbose`, we need to extend the `Logger` class to be able to easily call it.

```swift
extension Logger {
    private func verbose(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Verbose)
            }
        }
    }
}
```

Finally, using the new log level is a simple as...

```swift
let log = Logger()
log.verbose { "My first verbose log message!" }
```

### Shared Loggers between Frameworks

Defining a single `Logger` and sharing that instance several frameworks could be very advantageous. Especially with the addition of Frameworks in iOS 8. Now that we're going to be creating more frameworks inside our own apps to be shared between apps, extensions and third party libraries, wouldn't it be nice if we could share `Logger` instances?

Let's walk through a quick example of a `Math` framework sharing a `Logger` with it's parent `Calculator` app.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(configuration: LoggerConfiguration(logLevel: .Warn)) // We're going to replace this

//=========== Calculator.swift ===========
import Math

let writers = [FileWriter(), ConsoleWriter()]
var log = Logger(configuration: LoggerConfiguration(logLevel: .Debug, writers: writers))

// Replace the Math.log with the Calculator.log to share the same Logger instance
Math.log = log
```

It's very simple to swap out a pre-existing `Logger` with a new one.

### Multiple Loggers, One Queue

The previous example showed how to share `Logger` instances between multiple frameworks. Something more likely though is that you would want to have each third party library or internal framework to have their own `Logger` with their own configuration. The one thing that you really want to share is the `dispatch_queue_t` that they run on. This will ensure all your logging is thread-safe. Here's the previous example demonstrating how to create multiple `Logger` instances with different configurations and share the queue.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(configuration: LoggerConfiguration(logLevel: .Warn)) // We're going to replace this

//=========== Calculator.swift ===========
import Math

// Create a single queue to share
let queue = {
    let label = NSString(string: "com.math.logger")
    return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
}()

// Create the Calculator.log with multiple writers and a .Debug log level
let writers = [FileWriter(), ConsoleWriter()]
let configuration = LoggerConfiguration(logLevel: .Debug, writers: writers, queue: queue)
var log = Logger(configuration: configuration)

// Replace the Math.log with a new instance with all the same configuration values except a shared queue
let mathConfiguration = LoggerConfiguration(
    logLevel: Math.log.configuration.logLevel,
    formatters: Math.log.configuration.formatters,
    writers: Math.log.configuration.writers,
    asynchronous: Math.log.configuration.asynchronous,
    queue: queue
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

## Creator

- [Christian Noon](https://github.com/cnoon) ([@Christian_Noon](https://twitter.com/Christian_Noon))

## Contributors

- [Eric Appel](https://github.com/ericappel) ([@EricAppel](https://twitter.com/EricAppel))

## License

Willow is released under the FreeBSD license. See LICENSE for details.

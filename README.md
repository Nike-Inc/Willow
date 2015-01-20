#Timber

Timber is a powerful, yet lightweight logging library written in Swift.

## Features

- Multiple Log Levels
- Simple Logging Functions and Closures
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
- Xcode 6.1

## Communication

- Need help? Start here [StackOverflow](http://stackoverflow.com/questions/tagged/timber). (Tag `Timber`)
- Need to ask a question? Ask here [StackOverflow](http://stackoverflow.com/questions/tagged/timber).
- Want to contribute? Please fork the repo and submit a pull request.
- Have a feature request? Open an issue.
- Find a bug? Open an issue.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org/) has new released support for Swift in the latest beta release. First, make sure you have the latest beta version installed.

```
[sudo] gem install cocoapods --pre
```

Now to add the `Timber` pod to your project, create your [Podfile](http://guides.cocoapods.org/using/the-podfile.html) and add the following.

```
pod 'Timber', '1.0.0'
```

> NOTE: You have to have the pre-release version of CocoaPods install and an iOS deployment target of 8.0+.

### Carthage

First, you need to make sure you have [Carthage](https://github.com/Carthage/Carthage) installed.

```
brew update
brew install carthage
```

Then add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
# Require version 1.0.0 or later
github "cnoon/Timber" >= 1.0.0
```

---

## Usage

### Creating a Logger

```swift
import Timber
let defaultLogger = Logger()
```

Here are the parameters that the `Logger` initializer takes.

* `logLevel: LogLevel = .Info` - The logging level used to determine which messages are written.
* `formatters: [LogLevel: [Formatter]]? = nil` - The dictionary of formatters to apply to each associated log level.
* `writers: [Writer] = [ConsoleWriter()]` - The writers to use when messages need to be written to a specific destination such as the console or to a file.
* `queue: dispatch_queue_t? = nil` - A custom dispatch queue to handle thread-safety to avoid log mangling. If you do not provide one, the Logger instance will create it's own internally.

`Logger` objects can only be customized during initialization. If you need to change a `Logger` at runtime, it is advised to create an additional logger with a custom configuration to fit your needs. It is perfectly acceptable to have many different `Logger` instances running simutaneously.

#### Thread Safety

The `println` function does not guarantee that the `String` parameter will be fully logged to the console. If two `println` calls are happening simultaneously from two different queues (threads), the messages can get mangled, or intertwined. `Timber` guarantees that messages are completely finished writing before starting on the next one.

> It is important to note that by creating multiple `Logger` instances, you can potentially lose the guarantee of thread-safe logging. If you want to use multiple Logger instances, you should create a shared `dispatch_queue_t` between them. For more info...see the [Advanced Usage](Advanced Usage) section.

### Logging Messages

```swift
let log = Logger(logLevel: .Debug)

log.debug("Debug Message")
log.info("Info Message")
log.event("Event Message")
log.warn("Warn Message")
log.error("Error Message")

// Logs the following:
Debug Message
Info Message
Event Message
Warn Message
Error Message
```

The syntax was optimized to make logging as lightweight as possible. Developers should be able to focus on the task at hand and not remembering how to write a log message.

> By default, only the `String` message will be logged. See the [Formatters](Formatters) section for more information about customizing log message formats.

### Logging Message Closures

Logging a message is easy, but knowing when to add the logic necessary to build a log message and tune it for performance can be a bit tricky. We want to make sure logic is encapsulated and very performant. `Timber` log level closures allow you to cleanly wrap all the logic to build up the message. Once you pass the closure off to the `Logger`, it will only run that closure if the log level specified is actually enabled. This allows you to encapsulate all the logic around creating the log message, while ensure it will only run if the log message will actually be executed.

Let's start with a very naive example.

```swift
// First let's run a giant for loop to collect some info
// Now let's scan through the results to get some aggregate values
// Now I need to format the data
// I only need all this data for a debug log message, but oh well...
let message = "I finally computed it: \(computedValue) (nvm that all that logic runs in production)"
log.debug(message)
```

You can see that there's some room for improvement here. The next step forward would look something like the following.

```swift
if log.debugLogLevelAllowed() {
  // First let's run a giant for loop to collect some info
  // Now let's scan through the results to get some aggregate values
  // Now I need to format the data
  // We're just about there...
  log.debug("Finally I've got it! \(it)")
}
```

Okay, much better. Now at least we only run that logic if the debug log level is actually enabled which will not run in production builds. It's still a bit clunky though to have to have these `debugLogLevelAllowed` methods and still have to write the `log.debug()` at the end. Luckily, Swift Closures come to the rescue. `Timber` has closure messaging built in for each log level.

```swift
log.debug {
  // First let's run a giant for loop to collect some info
  // Now let's scan through the results to get some aggregate values
  // Now I need to format the data
  return "Much cleaner...thanks closures! \(dataValue)"
}

log.info {
  let countriesString = join(",", countriesArray)
  return "Countries: \(countriesString)"
}
```

### Disabling a Logger

The `Logger` class has an `enabled` property to allow you to completely disable logging. This can be helpful for turning off specific `Logger` objects at the app level, or more commonly to disable logging in a third-party library.

```swift
let log = Logger()
log.enabled = false

// No log messages will get sent to the registered Writers

log.enabled = true

// We're back in business...
```

### Formatters

Log message customization is something that `Timber` specializes in. Some devs want to add a prefix to their library output, some want different timestamp formats, some even want colors! There's no way to predict all the types of custom formatting teams are going to want to use. This is where `Formatter` objects come in.

```swift
public protocol Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String
}
```

The `Formatter` protocol has only a single API. It receives the `message` and `logLevel` and returns a newly formatted `String`. This is about as flexible as you can get. The `Logger` allows you to pass in your own `Formatter` objects and apply them to a `LogLevel`. Let's walk through a simple example for adding a prefix to only the `Debug` and `Info` log levels.

```swift
class PrefixFormatter: Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        return "[Timber] \(message)"
    }
}

let prefixFormatter = PrefixFormatter()

let formatters: [Logger.LogLevel: [Formatter]] = [
    .Debug: [prefixFormatter],
    .Info: [prefixFormatter]
]

let log = Logger(formatters: formatters)
```

`Formatter` objects are very powerful and can manipulate the message in any way.

### Color Formatters

There is a special `Formatter` in `Timber` called a `ColorFormatter`. It was designed to take a foreground and backround color in the form of a `UIColor`. It then formats the message to match the coloring scheme of the [XcodeColors](https://github.com/robbiehanson/XcodeColors) plugin. This allows you to change the foreground and background colors of logging output in the Xcode console. This can make it much easier to dig through thousands of lines of logging output.

```swift
let purple = UIColor.purpleColor()
let blue = UIColor.blueColor()
let green = UIColor.greenColor()
let orange = UIColor.orangeColor()
let red = UIColor.redColor()
let white = UIColor.whiteColor()
let black = UIColor.blackColor()

let colorFormatters: [Logger.LogLevel: [Formatter]] = [
    Logger.LogLevel.Debug: [ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
    Logger.LogLevel.Info: [ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
    Logger.LogLevel.Event: [ColorFormatter(foregroundColor: green, backgroundColor: nil)],
    Logger.LogLevel.Warn: [ColorFormatter(foregroundColor: black, backgroundColor: orange)],
    Logger.LogLevel.Error: [ColorFormatter(foregroundColor: white, backgroundColor: red)]
]

let log = Logger(logLevel: .Debug, formatters: colorFormatters)
```

> The XcodeColors plugin is available through [Alcatraz](http://alcatraz.io/) and can be installed with the click of a button.

### Multiple Formatters

Multiple `Formatter` objects can be stacked together onto a single log level to perform multiple actions. Let's walk through using the `DefaultFormatter` (prefixes the message with a timestamp and log level) in combination with the `ColorFormatter` objects from the previous example.

```swift
let purple = UIColor.purpleColor()
let blue = UIColor.blueColor()
let green = UIColor.greenColor()
let orange = UIColor.orangeColor()
let red = UIColor.redColor()
let white = UIColor.whiteColor()
let black = UIColor.blackColor()

let defaultFormatter = DefaultFormatter()

let formatters: [Logger.LogLevel: [Formatter]] = [
    Logger.LogLevel.Debug: [defaultFormatter, ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
    Logger.LogLevel.Info: [defaultFormatter, ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
    Logger.LogLevel.Event: [defaultFormatter, ColorFormatter(foregroundColor: green, backgroundColor: nil)],
    Logger.LogLevel.Warn: [defaultFormatter, ColorFormatter(foregroundColor: black, backgroundColor: orange)],
    Logger.LogLevel.Error: [defaultFormatter, ColorFormatter(foregroundColor: white, backgroundColor: red)]
]

let log = Logger(logLevel: .Debug, formatters: formatters)
```

`Timber` doesn't have any hard limits on the total number of `Formatter` objects that can be applied to a single log level. Just keep in mind that performance is key.

> The default `ConsoleWriter` will execute the formatters in the same order they were added into the `Dictionary`. In the previous example, Timber would log a much different message if the `ColorFormatter` came before the `DefaultFormatter`.

### Custom Writers

Writing log messages to various locations is an essential feature of any robust logging library. This is made possible in `Timber` through the `Writer` protocol.

```swift
public protocol Writer {
    func writeMessage(message: String, logLevel: Logger.LogLevel, formatters: [Formatter]?)
}
```

Again, this is an extremely lightweight design to allow for ultimate flexibility. As long as your `Writer` classes conform, you can do anything with those log messages that you want. You could write the message to the console, append it to a file, send it to a server, etc. Here's a quick look at the implementation of the default `ConsoleWriter` created by the `Logger` if you don't specify your own.

```swift
public class ConsoleWriter: Writer {
    public func writeMessage(var message: String, logLevel: Logger.LogLevel, formatters: [Formatter]?) {
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
let log = Logger(writers: writers)
```

> `Writer` objects can also be selective about which formatters they want to run for a particular log level. All the examples run all the formatters, but you can be selective if you want to be.

---

## Advanced Usage

### Shared Loggers between Frameworks

Defining a single `Logger` and having that instance be shared between many framework would be very advantageous. Especially with the addition of Frameworks in iOS 8. Now that we're going to be creating more frameworks inside our own apps to be shared between apps, extensions and third party libraries, wouldn't it be nice if we could shared `Logger` instances?

Let's walk through a quick example of a `Math` framework sharing a `Logger` with it's parent `Calculator` app.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(logLevel: .Warn)

//=========== Calculator.swift ===========
import Math

let writers = [FileWriter(), ConsoleWriter()]
var log = Logger(logLevel: .Debug, writers: writers)

// Now let's share the Calculator.log with the Math.log
Math.log = log
```

It's very simple to swap out a pre-existing `Logger` with a new one.

### Multiple Loggers, One Queue

The previous example showed how to share `Logger` instances between multiple frameworks. Something more likely though is that you would want to have each third party library or internal framework to have their own `Logger` with their own configuration. The one thing that you really want to share is the `dispatch_queue_t` that they run on. This will ensure all your logging is thread-safe. Here's the previous example demonstrating how to create multiple `Logger` instances with different configurations and share the queue.

```swift
//=========== Inside Math.swift ===========
public var log = Logger(logLevel: .Warn) // We're going to replace this guy with our own

//=========== Calculator.swift ===========
import Math

// Create a single queue to share
let queue = {
  let label = NSString(string: "com.math.logger")
  return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
}()

// Create the Calculator.log with multiple writers and a .Debug log level
let writers = [FileWriter(), ConsoleWriter()]
var log = Logger(logLevel: .Debug, writers: writers, queue: queue)

// Now let's create a different Math.log with a .Warn log level and only a ConsoleWriter
Math.log = Logger(logLevel: .Warn, queue: queue)
```

`Timber` is a very lightweight library, but its flexibility allows it to become very powerful if you so wish.

---

## FAQ

### Why only 5 log levels? And why are they so named?

Simple...simplicity and elegance. Contextually it gets difficult to understand which log level you need if you have too many. Additionally, by not supporting log level customization, it allows concrete APIs to be optimized for simplicity. If you feel you need more log levels, I would counter that you really need another `Logger`.

As for the naming, here's my own mental breakdown of each log level for an iOS app (obviously it depends on your use case).

* `Debug` - Highly detailed information of a context
* `Info` - Summary information of a context
* `Event` - User driven interactions such as button taps, view transitions, selecting a cell
* `Warn` - An error occurred but it is recoverable
* `Error` - A non-recoverable error occurred

### When should I use Timber?

If you are starting a new iOS project in Swift and want to take advantage of many new conventions and features of the language, Timber would be a great choice. If you are still working in Objective-C, a pure Objective-C library such as amazing [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) would probably be more appropriate.

---

## Creator

- [Christian Noon](https://github.com/cnoon) ([@Christian_Noon](https://twitter.com/Christian_Noon))

## License

Timber is released under the MIT license. See LICENSE for details.

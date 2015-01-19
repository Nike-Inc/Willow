#Timber

Timber is a powerful, yet light-weight logging library written in Swift.

## Features

- [x] Multiple Log Levels
- [x] Simple Logging Functions and Closures
- [x] Thread-Safe Logging Output
- [x] Custom Formatters through Dependency Injection
- [x] Customizable Colored Console Output per Log Level
- [x] Custom Writers through Dependency Injection
- [x] Supports Multiple Simultaneous Writers
- [x] Shared Loggers Between Frameworks
- [x] Customizable Timestamp Formatters
- [x] Comprehensive Unit Test Coverage
- [x] Complete Documentation

## Requirements

- iOS 8.0+
- Xcode 6.1

## Communication

- If you **need help**, use [JIRA](https://jira.nike.com/browse/bmd). (Tag `Timber`)
- If you'd like to **ask a general question**, use [JIRA](https://jira.nike.com/browse/bmd).
- If you **found a bug**, open a bug.
- If you **have a feature request**, open an Change Request.
- If you **want to contribute**, fork the repo and submit a pull request.

> We're still in the process of getting the [JIRA](https://jira.nike.com/browse/bmd) project configured. In the meantime, please [contact](christian.noon@nike.com) me directly.

## Installation

### Cocoapods

TODO

### Git Submodules

TODO

### Carthage

TODO

---

## Usage

### Creating a Logger

```swift
import Timber

// Using all default values
let defaultLogger = Logger(name: "default-logger")

// A more customized version
let customizedLogger = Logger(
  name: "customized-logger",
  logLevel: .Debug,
  printTimestamp: true,
  printLogLevel: true,
  timestampFormatter: nil,
  formatters: nil,
  writers: nil
)
```

`Logger` objects can only be customized during initialization. If you need to change a `Logger` at runtime, it is advised to create an additional logger with a custom configuration to fit your needs. It is perfectly fine to have many different `Logger` instances running together.

> It is important to note that by creating multiple `Logger` instances, you can potentially lose the guarantee of thread-safe logging. This is because each `Logger` instance uses an internal `NSOperationQueue` to guarantee serial operations. It is still possible to have multiple `Logger` instances by fully thread-safe, but will require custom `Writer` objects to facilitate this. See the `Advanced` section for more info.

### Logging Messages

```swift
let log = Logger(name: "default-logger")

log.debug("Debug Message")
log.info("Info Message")
log.event("Event Message")
log.warn("Warn Message")
log.error("Error Message")
```

The syntax was optimized to make logging as light-weight as possible. No one likes super long logging syntax in their projects.

### Logging Message Closures

Logging a message is easy, but knowing when to build it up based on a particular log level and tuning it for performance can be tricky. Let's start with a very naive example.

```swift
// First let's run a giant for loop to collect some info
// Now let's scan through the results to get some aggregate values
// Now I need to format the data
// We're just about there...

let message = "I finally computed it: \(computedValue) (nvm that all that logic runs in production)"

log.debug(message)
```

You can see that we have a large amount of room for improvement. The next step forward would look something like the following.

```swift
if log.debugLogLevelAllowed() {
  // First let's run a giant for loop to collect some info
  // Now let's scan through the results to get some aggregate values
  // Now I need to format the data
  // We're just about there...

  log.debug("Finally I've got it! \(it)")
}
```

Okay, much better. Now at least we only run that logic if the debug log level is actually enabled which will not run in production builds. It's still a bit clunky though to have to have these `debugLogLevelAllowed` methods and still have to write the `log.debug()` at the end. Luckily, Swift Closures come to the rescue. Timber has closure messaging built in for each log level.

```swift
log.debug {
  // First let's run a giant for loop to collect some info
  // Now let's scan through the results to get some aggregate values
  // Now I need to format the data
  // We're just about there...
  
  return "Much cleaner...thanks closures! \(dataValue)"
}

log.info {
  let countriesString = join(",", countriesArray)
  return "Countries: \(countriesString)"
}
```

`Timber` log level closures allow you to cleanly wrap all the logic to build up the message. Once you pass the closure off to the `Logger`, it will only run that closure if the log level specified is actually enabled.

### Formatters

`Timber` uses dependency injection to make the `Logger` very customizable. Anything that you don't like about the formatting of the message can be overriden by creating a custom formatter. For example, let's say that we wanted to prefix every message from our library with `[<lib_name>]`. A custom `Formatter` object would allow us to do just that.

```swift
class PrefixFormatter: Formatter {
    func formatMessage(message: String) -> String {
        return "[Timber] \(message)"
    }
}

let formatters: [Logger.LogLevel: [Formatter]] = [
    .Debug: [prefixFormatter],
    .Info: [prefixFormatter]
]

let log = Logger(name: "prefix-logger", formatters: formatters)
```

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

let log = Logger(
    name: "colored-logger",
    logLevel: .Debug,
    printTimestamp: true,
    printLogLevel: true,
    formatters: colorFormatters
)
```

> The XcodeColors plugin is available through [Alcatraz](http://alcatraz.io/) and can be installed with the click of a button.

### Multiple Formatters

TODO

### Custom Timestamps

TODO

### Custom Writers

TODO

### Multiple Writers

TODO

### Shared Loggers between Frameworks

TODO

---

## FAQ

### When should I use Timber?

If you are starting a new iOS project in Swift and want to take advantage of many new conventions and features of the language, Timber would be a great choice. If you are still working in Objective-C, a pure Objective-C library such as [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) would probably be more appropriate.

---

## Contact

If you have any questions, first check out the Example app. If you need to contact me directly, please feel free to email me. As always, pull requests are welcome!

- [Christian Noon](christian.noon@nike.com)

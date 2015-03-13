//
//  Willow.swift
//
//  Copyright (c) 2015, Nike
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

// MARK: - LogLevel

/**
    The LogLevel enum defines all the possible logging levels for Willow.

    - Error: Allows Error messages to be logged.
    - Warn:  Allows Warn and Error messages to be logged.
    - Event: Allows Event, Warn and Error messages to be logged.
    - Info:  Allows Info, Event, Warn and Error messages to be logged.
    - Debug: Allows Debug, Info, Event, Warn and Error messages to be logged.
*/
public enum LogLevel: UInt, Printable {
    case Error = 0, Warn, Event, Info, Debug
    
    public var description: String {
        switch self {
        case .Error:
            return "Error"
        case .Warn:
            return "Warn"
        case .Event:
            return "Event"
        case .Info:
            return "Info"
        case .Debug:
            return "Debug"
        }
    }
}

// MARK: - LoggerConfiguration

/**
    The LoggerConfiguration is a container class for storing all the configuration information to be applied to
    a Logger instance.
*/
public class LoggerConfiguration {
    
    // MARK: Properties
    
    /// The logging level used to determine which messages are written.
    public let logLevel: LogLevel
    
    /// The dictionary of formatters to apply to each associated log level.
    public let formatters: [LogLevel: [Formatter]]
    
    /// The writers to use when messages are written.
    public let writers: [Writer]
    
    /// Whether to write messages asynchronously to the internal queue.
    public let asynchronous: Bool
    
    /// A custom queue to swap out for the default one. This allows sharing queues between multiple logger instances.
    public let queue: dispatch_queue_t
    
    // MARK: Initialization Methods
    
    /**
        Initializes a logger configuration instance.
    
        :param: logLevel     The logging level used to determine which messages are written. `.Debug` by default.
        :param: formatters   The dictionary of formatters to apply to each associated log level. `nil` by default.
        :param: writers      The writers to use when messages are written. `[ConsoleWriter()]` by default.
        :param: asynchronous Whether to write messages asynchronously on the given queue. `false` by default.
        :param: queue        A custom queue to swap out for the default one. This allows sharing queues between multiple
                             logger instances. `nil` by default.
    
        :returns: A fully initialized logger configuration instance.
    */
    public init(
        logLevel: LogLevel = .Debug,
        formatters: [LogLevel: [Formatter]]? = nil,
        writers: [Writer] = [ConsoleWriter()],
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil)
    {
        self.logLevel = logLevel
        self.formatters = formatters ?? [LogLevel: [Formatter]]()
        self.writers = writers
        self.asynchronous = asynchronous
        self.queue = queue ?? {
            let label = NSString(format: "com.nike.willow-%08x%08x", arc4random(), arc4random())
            return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
        }()
    }
    
    // MARK: Customized Configurations
    
    /**
        Creates a logger configuration instance with a timestamp formatter applied to each log level.
    
        :param: logLevel     The logging level used to determine which messages are written. `.Debug` by default.
        :param: asynchronous Whether to write messages asynchronously on the given queue. `false` by default.
        :param: queue        A custom queue to swap out for the default one. This allows sharing queues between multiple
                             logger instances. `nil` by default.
    
        :returns: A fully initialized logger configuration instance.
    */
    public class func timestampConfiguration(
        logLevel: LogLevel = .Debug,
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil) -> LoggerConfiguration
    {
        let timestampFormatter = [TimestampFormatter()]
        
        let formatters: [LogLevel: [Formatter]] = [
            .Debug: timestampFormatter,
            .Info: timestampFormatter,
            .Event: timestampFormatter,
            .Warn: timestampFormatter,
            .Error: timestampFormatter,
        ]
        
        return LoggerConfiguration(logLevel: logLevel, formatters: formatters, asynchronous: asynchronous, queue: queue)
    }
    
    /**
        Creates a logger configuration instance with a timestamp and color formatter applied to each log level.
    
        :param: logLevel     The logging level used to determine which messages are written. `.Debug` by default.
        :param: asynchronous Whether to write messages asynchronously on the given queue. `false` by default.
        :param: queue        A custom queue to swap out for the default one. This allows sharing queues between multiple
                             logger instances. `nil` by default.
    
        :returns: A fully initialized logger configuration instance.
    */
    public class func coloredTimestampConfiguration(
        logLevel: LogLevel = .Debug,
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil) -> LoggerConfiguration
    {
        let purple = Color(red: 0.6, green: 0.247, blue: 1.0, alpha: 1.0)
        let blue = Color(red: 0.176, green: 0.569, blue: 1.0, alpha: 1.0)
        let green = Color(red: 0.533, green: 0.812, blue: 0.031, alpha: 1.0)
        let orange = Color(red: 0.914, green: 0.647, blue: 0.184, alpha: 1.0)
        let red = Color(red: 0.902, green: 0.078, blue: 0.078, alpha: 1.0)
        
        let timestampFormatter = TimestampFormatter()
        
        let formatters: [LogLevel: [Formatter]] = [
            .Debug: [timestampFormatter, ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
            .Info: [timestampFormatter, ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
            .Event: [timestampFormatter, ColorFormatter(foregroundColor: green, backgroundColor: nil)],
            .Warn: [timestampFormatter, ColorFormatter(foregroundColor: orange, backgroundColor: nil)],
            .Error: [timestampFormatter, ColorFormatter(foregroundColor: red, backgroundColor: nil)]
        ]
        
        return LoggerConfiguration(logLevel: logLevel, formatters: formatters, asynchronous: asynchronous, queue: queue)
    }
}

// MARK: - Logger

/**
    The Logger class is a fully thread-safe, synchronous or asynchronous logging solution using dependency injection 
    to allow custom Formatters and Writers. It also manages all the logic to determine whether to log a particular 
    message with a given log level.

    Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
    create an additional logger with a custom configuration to fit your needs.
*/
public class Logger {
    
    // MARK: Properties
    
    /// Controls whether to allow log messages to be sent to the writers.
    public var enabled = true
    
    /// The configuration to use when determining how to log messages.
    public let configuration: LoggerConfiguration
    
    // MARK: Private - Properties
    
    private let dispatch_method: (dispatch_queue_t, dispatch_block_t) -> Void
    
    // MARK: Initialization Methods
    
    /**
        Initializes a logger instance.
    
        :param: configuration The configuration to use when determining how to log messages. Creates a default 
                              `LoggerConfiguration()` by default.
    
        :returns: A fully initialized logger instance.
    */
    public init(configuration: LoggerConfiguration = LoggerConfiguration()) {
        self.configuration = configuration
        self.dispatch_method = self.configuration.asynchronous ? dispatch_async : dispatch_sync
    }
    
    // MARK: Logging Methods
    
    /**
        Writes out the given message with the logger configuration if the debug log level is allowed.
    
        :param: message The message string autoclosure to write out.
    */
    public func debug(message: @autoclosure () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Debug)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the debug log level is allowed.
    
        :param: closure A closure returning the message to log.
    */
    public func debug(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Debug)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the info log level is allowed.
    
        :param: message The message string autoclosure to write out.
    */
    public func info(message: @autoclosure () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Info)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the info log level is allowed.
    
        :param: closure A closure returning the message to log.
    */
    public func info(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Info)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the event log level is allowed.
    
        :param: message The message string autoclosure to write out.
    */
    public func event(message: @autoclosure () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the event log level is allowed.
    
        :param: closure A closure returning the message to log.
    */
    public func event(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the warn log level is allowed.
    
        :param: message The message string autoclosure to write out.
    */
    public func warn(message: @autoclosure () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Warn)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the warn log level is allowed.
    
        :param: closure A closure returning the message to log.
    */
    public func warn(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Warn)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the error log level is allowed.
    
        :param: message The message string autoclosure to write out.
    */
    public func error(message: @autoclosure () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(message, logLevel: .Error)
            }
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the error log level is allowed.
    
        :param: closure A closure returning the message to log.
    */
    public func error(closure: () -> String) {
        if self.enabled {
            self.dispatch_method(self.configuration.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Error)
            }
        }
    }
    
    // MARK: Private - Logging Helper Methods
    
    private func logMessageIfAllowed(closure: () -> String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(closure(), logLevel: logLevel)
        }
    }
    
    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return logLevel.rawValue <= self.configuration.logLevel.rawValue
    }
    
    private func logMessage(var message: String, logLevel: LogLevel) {
        let formatters = self.configuration.formatters[logLevel]
        self.configuration.writers.map { $0.writeMessage(message, logLevel: logLevel, formatters: formatters) }
    }
}

#if os(iOS)
import UIKit
public typealias Color = UIColor
#elseif os(OSX)
import Cocoa
public typealias Color = NSColor
#endif

// MARK: - Formatter

/**
    The Formatter protocol defines a single method for formatting a message after it has been constructed. This is very
    flexible allowing any object that conforms to use formatting scheme it wants.
*/
public protocol Formatter {
    func formatMessage(message: String, logLevel: LogLevel) -> String
}

// MARK: - TimestampFormatter

/**
    The TimestampFormatter class applies a timestamp to the beginning of the message.
*/
public class TimestampFormatter: Formatter {
    
    private let timestampFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    /**
        Initializes a timestamp formatter instance.
    
        :returns: A new timestamp formatter instance.
    */
    public init() {}
    
    /**
        Applies a timestamp to the beginning of the message.
    
        :param: message  The original message to format.
        :param: logLevel The log level set for the message.
    
        :returns: A newly formatted message.
    */
    public func formatMessage(message: String, logLevel: LogLevel) -> String {
        let timestampString = self.timestampFormatter.stringFromDate(NSDate())
        return "\(timestampString) \(message)"
    }
}

// MARK: - ColorFormatter

/**
    The ColorFormatter class takes foreground and background colors and applies them to a given message. It uses the
    XcodeColors plugin color formatting scheme.

    NOTE: These should only be used with the XcodeColors plugin.
*/
public class ColorFormatter: Formatter {
    
    // MARK: Private - ColorConstants
    
    private struct ColorConstants {
        static let ESCAPE = "\u{001b}["
        static let RESET_FG = ESCAPE + "fg;"
        static let RESET_BG = ESCAPE + "bg;"
        static let RESET = ESCAPE + ";"
    }
    
    // MARK: Private - Properties
    
    private let foregroundText: String
    private let backgroundText: String
    
    // MARK: Initialization Methods
    
    /**
        Returns a fully constructed ColorFormatter from the given UIColor objects.
    
        :param: foregroundColor The color to apply to the foreground.
        :param: backgroundColor The color to apply to the background.
    
        :returns: A fully constructed ColorFormatter from the given UIColor objects.
    */
    public init(foregroundColor: Color?, backgroundColor: Color?) {
        assert(foregroundColor != nil || backgroundColor != nil, "The foreground and background colors cannot both be nil")
        
        let foregroundTextString = ColorFormatter.textStringForColor(foregroundColor)
        let backgroundTextString = ColorFormatter.textStringForColor(backgroundColor)
        
        if (!foregroundTextString.isEmpty) {
            self.foregroundText = "\(ColorConstants.ESCAPE)fg\(foregroundTextString);"
        } else {
            self.foregroundText = ""
        }
        
        if (!backgroundTextString.isEmpty) {
            self.backgroundText = "\(ColorConstants.ESCAPE)bg\(backgroundTextString);"
        } else {
            self.backgroundText = ""
        }
    }
    
    // MARK: Formatter Methods
    
    /**
        Applies the foreground, background and reset color formatting values to the given message.
    
        :param: message The message to apply the color formatting to.
    
        :returns: A new string with all the color formatting values added.
    */
    public func formatMessage(message: String, logLevel: LogLevel) -> String {
        return "\(self.foregroundText)\(self.backgroundText)\(message)\(ColorConstants.RESET)"
    }
    
    // MARK: Private - Helper Methods
    
    private class func textStringForColor(color: Color?) -> String {
        var textString = ""
        
        if let color = color {
            var redValue: CGFloat = 0.0
            var greenValue: CGFloat = 0.0
            var blueValue: CGFloat = 0.0
            
            color.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
            
            let maxValue: CGFloat = 255.0
            
            let redInt = UInt8(round(redValue * maxValue))
            let greenInt = UInt8(round(greenValue * maxValue))
            let blueInt = UInt8(round(blueValue * maxValue))
            
            textString = "\(redInt),\(greenInt),\(blueInt)"
        }
        
        return textString
    }
}

// MARK: - Writer

/**
    The Writer protocol defines a single API for writing a message. The message can be written in any way the
    conforming object sees fit. For example, it could write to the console, write to a file, remote log to a third
    party service, etc.
*/
public protocol Writer {
    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?)
}

// MARK: - ConsoleWriter

/**
    The ConsoleWriter class runs all formatters in the order they were created and prints the resulting message
    to the console.
*/
public class ConsoleWriter: Writer {
    
    public func writeMessage(var message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        formatters?.map { message = $0.formatMessage(message, logLevel: logLevel) }
        println(message)
    }
}

//
//  Logger.swift
//
//  Copyright (c) 2015 Christian Noon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
    The Logger class is a fully thread-safe, asynchronous logging solution using dependency injection to allow custom
    Formatters and Writers. It also manages all the logic to determine whether to log a particular message with a given
    log level.

    Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
    create an additional logger with a custom configuration to fit your needs.
*/
public class Logger {

    // MARK: - LogLevel Enum
    
    /**
        The LogLevel enum defines all the possible logging levels for Timber.
    
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

    // MARK: - Properties
    
    /// Controls whether to allow log messages to be sent to the writers.
    public var enabled = true
    
    // MARK: - Private - Properties
    
    private let logLevel: LogLevel
    private let formatters: [LogLevel: [Formatter]]
    private let writers: [Writer]
    private let queue: dispatch_queue_t
    
    // MARK: - Initialization Methods
    
    /**
        Initializes a logger instance.
    
        :param: logLevel   The logging level used to determine which messages are written. `.Info` by default.
        :param: formatters The dictionary of formatters to apply to each associated log level. `nil` by default.
        :param: writers    The writers to use when messages are written. `[ConsoleWriter()]` by default.
        :param: queue      A custom queue to swap out for the default one. This allows sharing queues between multiple
                           logger instances. `nil` by default.
    
        :returns: A fully initialized logger instance.
    */
    public init(
        logLevel: LogLevel = .Info,
        formatters: [LogLevel: [Formatter]]? = nil,
        writers: [Writer] = [ConsoleWriter()],
        queue: dispatch_queue_t? = nil)
    {
        self.logLevel = logLevel
        self.formatters = formatters ?? [LogLevel: [Formatter]]()
        self.writers = writers
        self.queue = queue ?? {
            let label = NSString(format: "com.timber.logger-%08x%08x", arc4random(), arc4random())
            return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
        }()
    }
    
    // MARK: - Logging Methods
    
    /**
        Writes out the given message with the logger configuration if the debug log level is allowed.
        
        :param: message The message to write out.
    */
    public func debug(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
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
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Debug)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the info log level is allowed.
        
        :param: message The message to write out.
    */
    public func info(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
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
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Info)
            }
        }
    }

    /**
        Writes out the given message with the logger configuration if the event log level is allowed.
        
        :param: message The message to write out.
    */
    public func event(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
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
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Event)
            }
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the warn log level is allowed.
        
        :param: message The message to write out.
    */
    public func warn(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
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
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Warn)
            }
        }
    }

    /**
        Writes out the given message with the logger configuration if the error log level is allowed.
        
        :param: message The message to write out.
    */
    public func error(message: String) {
        if self.enabled {
            dispatch_async(self.queue) { [unowned self] in
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
            dispatch_async(self.queue) { [unowned self] in
                self.logMessageIfAllowed(closure, logLevel: .Error)
            }
        }
    }
    
    // MARK: - Private - Logging Helper Methods
    
    private func logMessageIfAllowed(message: String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(message, logLevel: logLevel)
        }
    }
    
    private func logMessageIfAllowed(closure: () -> String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(closure(), logLevel: logLevel)
        }
    }
    
    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return logLevel.rawValue <= self.logLevel.rawValue
    }
    
    private func logMessage(var message: String, logLevel: LogLevel) {
        let formatters = self.formatters[logLevel]
        self.writers.map { $0.writeMessage(message, logLevel: logLevel, formatters: formatters) }
    }
}

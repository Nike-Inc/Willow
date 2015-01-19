//
//  Logger.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
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
    
    // MARK: - Private - Properties
    
    private let logLevel: LogLevel
    private var formatters = [LogLevel: [Formatter]]()
    private let writers = [Writer]()
    
    private lazy var queue: dispatch_queue_t = {
        let label = NSString(format: "com.timber.logger-%08x%08x", arc4random(), arc4random())
        return dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_SERIAL)
    }()
    
    // MARK: - Initialization Methods
    
    /**
        Initializes a logger instance.
    
        :param: logLevel   The logging level used to determine which messages are written. `.Info` by default.
        :param: formatters The dictionary of formatters to apply to each associated log level. `nil` by default.
        :param: writers    The writers to use when messages are written. `nil` by default.
        :param: queue      A custom queue to swap out for the default one. This allows sharing queues between multiple
                           logger instances. `nil` by default.
    
        :returns: A fully initialized logger instance.
    */
    public init(
        logLevel: LogLevel = .Info,
        formatters: [LogLevel: [Formatter]]? = nil,
        writers: [Writer]? = nil,
        queue: dispatch_queue_t? = nil)
    {
        self.logLevel = logLevel
        
        if let formatters = formatters {
            for (logLevel, logLevelFormatters) in formatters {
                assert(!logLevelFormatters.isEmpty, "The [\(logLevel)] formatters array CANNOT be empty")
            }
            
            self.formatters = formatters
        } else {
            self.formatters = {
                var formatters = [LogLevel: [Formatter]]()
                let defaultFormatter = DefaultFormatter()
                
                for index in LogLevel.Error.rawValue...LogLevel.Debug.rawValue {
                    formatters[LogLevel(rawValue: index)!] = [defaultFormatter]
                }
                
                return formatters
            }()
        }
        
        if let writers = writers {
            self.writers = writers
        } else {
            self.writers.append(self.formatters.isEmpty ? ConsoleWriter() : ConsoleFormatWriter())
        }
        
        if let queue = queue {
            self.queue = queue
        }
    }
    
    // MARK: - Logging Methods
    
    /**
        Writes out the given message with the logger configuration if the debug log level is allowed.
        
        :param: message The message to write out.
    */
    public func debug(message: String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(message, logLevel: .Debug)
        }
    }

    /**
        Writes out the given message closure string with the logger configuration if the debug log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func debug(closure: () -> String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(closure, logLevel: .Debug)
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the info log level is allowed.
        
        :param: message The message to write out.
    */
    public func info(message: String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(message, logLevel: .Info)
        }
    }

    /**
        Writes out the given message closure string with the logger configuration if the info log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func info(closure: () -> String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(closure, logLevel: .Info)
        }
    }

    /**
        Writes out the given message with the logger configuration if the event log level is allowed.
        
        :param: message The message to write out.
    */
    public func event(message: String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(message, logLevel: .Event)
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the event log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func event(closure: () -> String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(closure, logLevel: .Event)
        }
    }
    
    /**
        Writes out the given message with the logger configuration if the warn log level is allowed.
        
        :param: message The message to write out.
    */
    public func warn(message: String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(message, logLevel: .Warn)
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the warn log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func warn(closure: () -> String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(closure, logLevel: .Warn)
        }
    }

    /**
        Writes out the given message with the logger configuration if the error log level is allowed.
        
        :param: message The message to write out.
    */
    public func error(message: String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(message, logLevel: .Error)
        }
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the error log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func error(closure: () -> String) {
        dispatch_async(self.queue) { [unowned self] in
            self.logMessageIfAllowed(closure, logLevel: .Error)
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
        
        for writer in writers {
            if writer is FormatWriter && formatters != nil {
                let formatWriter = writer as FormatWriter
                formatWriter.writeMessage(message, logLevel: logLevel.rawValue, formatters: formatters!)
            } else {
                writer.writeMessage(message, logLevel: logLevel.rawValue)
            }
        }
    }
}

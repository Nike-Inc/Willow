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
    Writable and Colorable writers. It also manages all the logic to determine whether to log a particular message with
    a given log level.

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
    
    private let name: String
    private let logLevel: LogLevel
    private let printTimestamp: Bool
    private let printLogLevel: Bool
    private var formatters = [LogLevel: Formatter]()
    private let writers = [Writer]()
    
    private lazy var timestampFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private let operationQueue = NSOperationQueue()
    
    // MARK: - Initialization Methods
    
    /**
        Initializes a logger instance.
    
        :param: name               The name of the logger for internal use which is required to not be empty. This is
                                   used for naming the internal operationQueue. Asserts if `name` is empty.
        :param: logLevel           The logging level used to determine which messages are written. `.Info` by default.
        :param: printTimestamp     Whether to print out the timestamp when messages are written. `false` by default.
        :param: printLogLevel      Whether to print out the log level when messages are written. `false` by default.
        :param: timestampFormatter The timestamp formatter used when messages are written. `nil` by default.
        :param: formatters         The dictionary of formatters to apply to each associated log level. `nil` by default.
        :param: writers            The writers to use when messages are written. `nil` by default.
    
        :returns: A fully initialized logger instance.
    */
    public init(
        name: String,
        logLevel: LogLevel = .Info,
        printTimestamp: Bool = false,
        printLogLevel: Bool = false,
        timestampFormatter: NSDateFormatter? = nil,
        formatters: [LogLevel: Formatter]? = nil,
        writers: [Writer]? = nil)
    {
        self.name = name
        self.logLevel = logLevel
        self.printTimestamp = printTimestamp
        self.printLogLevel = printLogLevel
        
        if let formatters = formatters {
            self.formatters = formatters
        }
        
        if let writers = writers {
            self.writers = writers
        } else {
            self.writers.append(self.formatters.isEmpty ? ConsoleWriter() : ConsoleFormatWriter())
        }
        
        if let timestampFormatterValue = timestampFormatter {
            self.timestampFormatter = timestampFormatterValue
        }
        
        assert(!name.isEmpty, "A logger must have a name to properly set up the operation queue")
        
        setUpOperationQueue()
    }
    
    deinit {
        self.operationQueue.cancelAllOperations()
    }
    
    // MARK: - Logging Methods
    
    /**
        Writes out the given message with the logger configuration if the debug log level is allowed.
        
        :param: message The message to write out.
    */
    public func debug(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Debug)
    }

    /**
        Writes out the given message closure string with the logger configuration if the debug log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func debug(closure: () -> String) {
        logMessageIfAllowed(closure, withLogLevel: .Debug)
    }
    
    /**
        Writes out the given message with the logger configuration if the info log level is allowed.
        
        :param: message The message to write out.
    */
    public func info(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Info)
    }

    /**
        Writes out the given message closure string with the logger configuration if the info log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func info(closure: () -> String) {
        logMessageIfAllowed(closure, withLogLevel: .Info)
    }

    /**
        Writes out the given message with the logger configuration if the event log level is allowed.
        
        :param: message The message to write out.
    */
    public func event(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Event)
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the event log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func event(closure: () -> String) {
        logMessageIfAllowed(closure, withLogLevel: .Event)
    }
    
    /**
        Writes out the given message with the logger configuration if the warn log level is allowed.
        
        :param: message The message to write out.
    */
    public func warn(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Warn)
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the warn log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func warn(closure: () -> String) {
        logMessageIfAllowed(closure, withLogLevel: .Warn)
    }

    /**
        Writes out the given message with the logger configuration if the error log level is allowed.
        
        :param: message The message to write out.
    */
    public func error(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Error)
    }
    
    /**
        Writes out the given message closure string with the logger configuration if the error log level is allowed.
        
        :param: closure A closure returning the message to log.
    */
    public func error(closure: () -> String) {
        logMessageIfAllowed(closure, withLogLevel: .Error)
    }
    
    // MARK: - Private - Set Up Methods
    
    private func setUpOperationQueue() {
        self.operationQueue.qualityOfService = NSQualityOfService.Background
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.name = "com.nike.timber.logger.\(name)"
    }
    
    // MARK: - Private - Logging Helper Methods
    
    private func logMessageIfAllowed(message: String, withLogLevel logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            self.operationQueue.addOperationWithBlock {
                self.logMessage(message, withLogLevel: logLevel)
            }
        }
    }
    
    private func logMessageIfAllowed(messageClosure: () -> String, withLogLevel logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            self.operationQueue.addOperationWithBlock {
                self.logMessage(messageClosure(), withLogLevel: logLevel)
            }
        }
    }
    
    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return logLevel.rawValue <= self.logLevel.rawValue
    }
    
    private func logMessage(var message: String, withLogLevel logLevel: LogLevel) {
        var logComponents = [String]()
        
        if self.printTimestamp {
            logComponents.append(self.timestampFormatter.stringFromDate(NSDate()))
        }
        
        if self.printLogLevel {
            logComponents.append("\(logLevel)")
        }
        
        logComponents.append(message)
        
        if logComponents.count == 2 {
            logComponents[0] = "[" + logComponents[0] + "]"
        } else if logComponents.count == 3 {
            logComponents[1] = "[" + logComponents[1] + "]"
        }
        
        message = " ".join(logComponents)
        let formatter = self.formatters[logLevel]
        
        for writer in writers {
            if writer is FormatWriter && formatter != nil {
                let formatWriter = writer as FormatWriter
                formatWriter.writeMessage(message, formatter: formatter!)
            } else {
                writer.writeMessage(message)
            }
        }
    }
}

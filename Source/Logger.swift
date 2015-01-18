//
//  Logger.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

import Foundation

public class Logger {

    // MARK: - API - Enums
    
    public enum LogLevel: UInt {
        case Off = 0, Error, Warn, Event, Info, Debug, All
        
        public func toString() -> String {
            switch self {
            case .Off:
                return "Off"
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
            case .All:
                return "All"
            }
        }
    }
    
    // MARK: - API - Properties
    
    /// The name of the logger for internal use.
    public internal(set) var name: String
    
    /// The logging level used to determine which messages are written.
    public var logLevel: LogLevel {
        willSet {
            self.operationQueue.cancelAllOperations()
        }
    }
    
    /// Whether to print out the timestamp when messages are written.
    public internal(set) var printTimestamp: Bool
    
    /// Whether to print out the log level when messages are written.
    public internal(set) var printLogLevel: Bool

    /// The writer to use when messages are written.
    public internal(set) var writer: Writable
    
    /// The timestamp formatter to use when messages are written.
    public lazy internal(set) var timestampFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Private - Properties
    
    private let operationQueue = NSOperationQueue()
    private var colorProfiles = [LogLevel: ColorProfile]()
    
    // MARK: - API - Initialization Methods
    
    /**
    Initializes a logger instance.
    
    :param: name               The name of the logger for internal use which is required to not be empty. This is
                               used for naming the internal operationQueue.
    :param: logLevel           The logging level used to determine which messages are written.
    :param: printTimestamp     Whether to print out the timestamp when messages are written.
    :param: printLogLevel      Whether to print out the log level when messages are written.
    :param: timestampFormatter The timestamp formatter used when messages are written.
    :param: writer             The writer to use when messages are written.
    
    :returns: A fully initialized logger instance.
    */
    public init(
        name: String,
        logLevel: LogLevel = .Info,
        printTimestamp: Bool = false,
        printLogLevel: Bool = false,
        timestampFormatter: NSDateFormatter? = nil,
        writer: Writable? = nil) {

        self.name = name
        self.logLevel = logLevel
        self.printTimestamp = printTimestamp
        self.printLogLevel = printLogLevel
        
        if let writerValue = writer {
            self.writer = writerValue
        } else {
            self.writer = Writer()
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
    
    // MARK: - API - Colorization Method(s)
    
    /**
    Creates a ColorProfile for the given logLevel that works with the XcodeColors plugin.
    
    :param: foregroundColor The foreground color to use when rendering output to the console.
    :param: backgroundColor The background color to use when rendering output to the console.
    :param: logLevel        The log level to apply the colors to.
    */
    public func setForegroundColor(foregroundColor: UIColor?, backgroundColor: UIColor?, forLogLevel logLevel: LogLevel) {
        colorProfiles[logLevel] = ColorProfile(foregroundColor: foregroundColor, backgroundColor: backgroundColor)
    }
    
    // MARK: - API - Logging Methods
    
    /**
    Writes out the given message with the logger configuration if the debug log level is allowed.
    
    :param: message The message to write out.
    */
    public func debug(message: String) {
        logMessageIfAllowed(message, withLogLevel: .Debug)
    }

    /**
    Writes out the given message closure string with the logger configuration if the debug log level is allowed.
    
    :param: message The message to write out.
    */
    public func debug(messageClosure: () -> String) {
        logMessageIfAllowed(messageClosure, withLogLevel: .Debug)
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
    
    :param: message The message to write out.
    */
    public func info(messageClosure: () -> String) {
        logMessageIfAllowed(messageClosure, withLogLevel: .Info)
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
    
    :param: message The message to write out.
    */
    public func event(messageClosure: () -> String) {
        logMessageIfAllowed(messageClosure, withLogLevel: .Event)
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
    
    :param: message The message to write out.
    */
    public func warn(messageClosure: () -> String) {
        logMessageIfAllowed(messageClosure, withLogLevel: .Warn)
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
    
    :param: message The message to write out.
    */
    public func error(messageClosure: () -> String) {
        logMessageIfAllowed(messageClosure, withLogLevel: .Error)
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
        // We cannot use "<=" here due to a compiler issue with Swift 1.0. Therefore,
        // the return has been modified to use "<" as a workaround.
        return logLevel.rawValue < self.logLevel.rawValue + 1
    }
    
    private func logMessage(var message: String, withLogLevel logLevel: LogLevel) {
        var logComponents = [String]()
        
        if self.printTimestamp {
            logComponents.append(self.timestampFormatter.stringFromDate(NSDate()))
        }
        
        if self.printLogLevel {
            logComponents.append(logLevel.toString())
        }
        
        logComponents.append(message)
        
        if logComponents.count == 2 {
            logComponents[0] = "[" + logComponents[0] + "]"
        } else if logComponents.count == 3 {
            logComponents[1] = "[" + logComponents[1] + "]"
        }
        
        message = " ".join(logComponents)
        
        if let colorProfile = self.colorProfiles[logLevel] {
            message = colorProfile.applyColorFormattingToMessage(message)
        }
        
        self.writer.writeMessage(message)
    }
}

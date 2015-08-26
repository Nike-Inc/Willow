//
//  Logger.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

/**
    The Logger class is a fully thread-safe, synchronous or asynchronous logging solution using dependency injection
    to allow custom Formatters and Writers. It also manages all the logic to determine whether to log a particular
    message with a given log level.

    Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
    create an additional logger with a custom configuration to fit your needs.
*/
public class Logger {

    // MARK: - Properties

    /// Controls whether to allow log messages to be sent to the writers.
    public var enabled = true

    /// The configuration to use when determining how to log messages.
    public let configuration: LoggerConfiguration

    /// The dispatch method used when executing a log operation on the internal dispatch queue.
    public let dispatch_method: (dispatch_queue_t, dispatch_block_t) -> Void

    // MARK: - Initialization Methods

    /**
        Initializes a logger instance.

        - parameter configuration: The configuration to use when determining how to log messages. Creates a default
                                   `LoggerConfiguration()` by default.

        - returns: A fully initialized logger instance.
    */
    public init(configuration: LoggerConfiguration = LoggerConfiguration()) {
        self.configuration = configuration
        self.dispatch_method = self.configuration.asynchronous ? dispatch_async : dispatch_sync
    }

    // MARK: - Log Methods

    /**
        Writes out the given message using the logger configuration if the debug log level has an attached writer.

        - parameter message: A closure returning the message to log.
    */
    public func debug(message: () -> String) {
        logMessage(message, withLogLevel: .Debug)
    }

    /**
        Writes out the given message using the logger configuration if the info log level has an attached writer.

        - parameter message: A closure returning the message to log.
    */
    public func info(message: () -> String) {
        logMessage(message, withLogLevel: .Info)
    }

    /**
        Writes out the given message using the logger configuration if the event log level has an attached writer.

        - parameter message: A closure returning the message to log.
    */
    public func event(message: () -> String) {
        logMessage(message, withLogLevel: .Event)
    }

    /**
        Writes out the given message using the logger configuration if the warn log level has an attached writer.

        - parameter message: A closure returning the message to log.
    */
    public func warn(message: () -> String) {
        logMessage(message, withLogLevel: .Warn)
    }

    /**
        Writes out the given message using the logger configuration if the error log level has an attached writer.

        - parameter message: A closure returning the message to log.
    */
    public func error(message: () -> String) {
        logMessage(message, withLogLevel: .Error)
    }

    /**
        Writes out the given message closure string with the logger configuration if the log level is allowed.

        - parameter message:      A closure returning the message to log.
        - parameter withLogLevel: The log level associated with the message closure.
    */
    public func logMessage(message: () -> String, withLogLevel logLevel: LogLevel) {
        if enabled {
            dispatch_method(self.configuration.queue) { [weak self] in
                if let strongSelf = self {
                    strongSelf.logMessageIfAllowed(message, logLevel: logLevel)
                }
            }
        }
    }

    // MARK: - Private - Helper Methods

    private func logMessageIfAllowed(message: () -> String, logLevel: LogLevel) {
        if logLevelAllowed(logLevel) {
            logMessage(message(), logLevel: logLevel)
        }
    }

    private func logLevelAllowed(logLevel: LogLevel) -> Bool {
        return configuration.writers.keys.contains(logLevel)
    }

    private func logMessage(message: String, logLevel: LogLevel) {
        let formatters = self.configuration.formatters[logLevel]
        configuration.writers[logLevel]?.forEach { $0.writeMessage(message, logLevel: logLevel, formatters: formatters) }
    }
}

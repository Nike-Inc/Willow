//
//  Logger.swift
//
//  Copyright (c) 2015-2017 Nike, Inc. (https://www.nike.com)
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

/// The Logger class is a fully thread-safe, synchronous or asynchronous logging solution using dependency injection
/// to allow custom Modifiers and Writers. It also manages all the logic to determine whether to log a particular
/// message with a given log level.
///
/// Loggers can only be configured during initialization. If you need to change a logger at runtime, it is advised to
/// create an additional logger with a custom configuration to fit your needs.
open class Logger {

    // MARK: - Properties

    /// Controls whether to allow log messages to be sent to the writers.
    open var enabled = true

    /// The configuration to use when determining how to log messages.
    open let configuration: LoggerConfiguration

    // MARK: - Initialization

    /// Initializes a logger instance.
    ///
    /// - Parameter configuration: The configuration to use when determining how to log messages. Creates a default
    ///                            `LoggerConfiguration()` by default.
    ///
    /// - Returns: A fully initialized logger instance.
    public init(configuration: LoggerConfiguration = LoggerConfiguration()) {
        self.configuration = configuration
    }

    // MARK: - Logging

    /// Writes out the given message using the logger configuration if the debug log level has an attached writer.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func debug(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger configuration if the debug log level has an attached writer.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func debug(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger configuration if the info log level has an attached writer.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func info(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger configuration if the info log level has an attached writer.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func info(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger configuration if the event log level has an attached writer.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func event(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger configuration if the event log level has an attached writer.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func event(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger configuration if the warn log level has an attached writer.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func warn(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger configuration if the warn log level has an attached writer.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func warn(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger configuration if the error log level has an attached writer.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func error(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.error)
    }

    /// Writes out the given message using the logger configuration if the error log level has an attached writer.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func error(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.error)
    }

    /// Writes out the given message closure string with the logger configuration if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:      A closure returning the message to log.
    ///   - withLogLevel: The log level associated with the message closure.
    open func logMessage(_ message: @escaping () -> String, with logLevel: LogLevel) {
        guard enabled else { return }

        switch configuration.executionMethod {
        case .synchronous(let lock):
            lock.lock() ; defer { lock.unlock() }
            logMessageIfAllowed(message, with: logLevel)
        case .asynchronous(let queue):
            queue.async { self.logMessageIfAllowed(message, with: logLevel) }
        }
    }

    // MARK: - Private - Log Helpers

    private func logMessageIfAllowed(_ message: () -> String, with logLevel: LogLevel) {
        guard logLevelAllowed(logLevel) else { return }
        logMessage(message(), with: logLevel)
    }

    private func logLevelAllowed(_ logLevel: LogLevel) -> Bool {
        return configuration.writers.keys.contains(logLevel)
    }

    private func logMessage(_ message: String, with logLevel: LogLevel) {
        let modifiers = configuration.modifiers[logLevel] ?? []
        configuration.writers[logLevel]?.forEach { $0.writeMessage(message, logLevel: logLevel, modifiers: modifiers) }
    }
}

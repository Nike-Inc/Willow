//
//  Logger.swift
//
//  Copyright (c) 2015-present Nike, Inc. (https://www.nike.com)
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

    // MARK: - Helper Types

    /// Defines the two types of execution methods used when logging a message.
    ///
    /// Logging operations can be expensive operations when there are hundreds of messages being generated or when
    /// it is computationally expensive to compute the message to log. Ideally, one would use the synchronous method
    /// in development, and the asynchronous method in production. This allows for easier debugging in the development
    /// environment, and better performance in production.
    ///
    /// - synchronous:  Logs messages synchronously once the recursive lock is available in serial order.
    /// - asynchronous: Logs messages asynchronously on the dispatch queue in a serial order.
    public enum ExecutionMethod {
        case synchronous(lock: NSRecursiveLock)
        case asynchronous(queue: DispatchQueue)
    }

   // MARK: - Properties

    /// A logger that does not output any messages to writers.
    public static let disabled: Logger = NoOpLogger()

    /// Controls whether to allow log messages to be sent to the writers.
    open var enabled = true

    /// Log levels this logger is configured for.
    public let logLevels: LogLevel

    /// The array of writers to use when messages are written.
    public let writers: [LogWriter]

    /// The execution method used when logging a message.
    public let executionMethod: ExecutionMethod

    // MARK: - Initialization

    /// Initializes a logger instance.
    ///
    /// - Parameters:
    ///   - logLevels:       The message levels that should be logged to the writers.
    ///   - writers:         Array of writers that messages should be sent to.
    ///   - executionMethod: The execution method used when logging a message. `.synchronous` by default.
    public init(
        logLevels: LogLevel,
        writers: [LogWriter],
        executionMethod: ExecutionMethod = .synchronous(lock: NSRecursiveLock()))
    {
        self.logLevels = logLevels
        self.writers = writers
        self.executionMethod = executionMethod
    }

    // MARK: - Log Messages

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func debug(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .debug, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func debug(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .debug, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }
    
    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func info(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .info, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func info(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .info, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func event(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .event, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func event(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .event, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func warn(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .warn, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func warn(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .warn, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func error(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .error, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter timestamp: When the message was recorded.
    /// - Parameter file: The file where the message was recorded.
    /// - Parameter function: The function where the message was recorded.
    /// - Parameter line: The line number in the file where the message was recorded.
    /// - Parameter message: A closure returning the message to log.
    open func error(timestamp: TimeInterval = Date().timeIntervalSince1970, file: String = #file, function: String = #function, line: Int = #line, subsystem: String? = nil, category: String? = nil, _ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogMessageContext(logLevel: .error, timestamp: timestamp, file: file, function: function, line: line, subsystem: subsystem, category: category))
    }

    /// Writes out the given message closure string with the logger if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:  A closure returning the message to log.
    ///   - logLevel: The log level associated with the message closure.
    open func logMessage(_ message: @escaping () -> (LogMessage), with logLevel: LogLevel) {
        guard enabled && logLevelAllowed(logLevel) else { return }

        switch executionMethod {
        case .synchronous(let lock):
            let message = message()
            lock.lock() ; defer { lock.unlock() }
            logMessage(message, with: logLevel)

        case .asynchronous(let queue):
            queue.async { self.logMessage(message(), with: logLevel) }
        }
    }

    /// Writes out the given message closure string with the logger if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:  A closure returning the message to log.
    ///   - context: The context associated with the message closure..
    open func logMessage(_ message: @escaping () -> (LogMessage), with context: LogMessageContext) {
        guard enabled && logLevelAllowed(context.logLevel) else { return }

        switch executionMethod {
        case .synchronous(let lock):
            let message = message()
            lock.lock() ; defer { lock.unlock() }
            logMessage(message, with: context)

        case .asynchronous(let queue):
            queue.async { self.logMessage(message(), with: context) }
        }
    }

    // MARK: - Log String Messages

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func debugMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func debugMessage(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func infoMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func infoMessage(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func eventMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func eventMessage(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func warnMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func warnMessage(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    open func errorMessage(_ message: @autoclosure @escaping () -> String) {
        logMessage(message, with: LogLevel.error)
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    open func errorMessage(_ message: @escaping () -> String) {
        logMessage(message, with: LogLevel.error)
    }

    /// Writes out the given message closure string with the logger if the log level is allowed.
    ///
    /// - Parameters:
    ///   - message:      A closure returning the message to log.
    ///   - withLogLevel: The log level associated with the message closure.
    open func logMessage(_ message: @escaping () -> String, with logLevel: LogLevel) {
        guard enabled && logLevelAllowed(logLevel) else { return }

        switch executionMethod {
        case .synchronous(let lock):
            lock.lock() ; defer { lock.unlock() }
            logMessage(message(), with: logLevel)

        case .asynchronous(let queue):
            queue.async { self.logMessage(message(), with: logLevel) }
        }
    }

    // MARK: - Private - Log Message Helpers

    private func logLevelAllowed(_ logLevel: LogLevel) -> Bool {
        return logLevels.contains(logLevel)
    }

    private func logMessage(_ message: String, with logLevel: LogLevel) {
        writers.forEach { $0.writeMessage(message, logLevel: logLevel) }
    }

    private func logMessage(_ message: LogMessage, with logLevel: LogLevel) {
        writers.forEach { $0.writeMessage(message, logLevel: logLevel) }
    }
    
    private func logMessage(_ message: LogMessage, with context: LogMessageContext) {
        writers.forEach { $0.writeMessage(message, context: context) }
    }

    // MARK: - Private - No-Op Logger

    private final class NoOpLogger: Logger {
        init() {
            super.init(logLevels: .off, writers: [])
            enabled = false
        }

        override func logMessage(_ message: @escaping () -> String, with logLevel: LogLevel) {}
    }
}

//
//  LogWriter.swift
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
import os

/// The LogWriter protocol defines a single API for writing a log message. The message can be written in any way
/// the conforming object sees fit. For example, it could write to the console, write to a file, remote log to a third
/// party service, etc.
public protocol LogWriter {
    func writeMessage(_ message: String, logLevel: LogLevel)
    func writeMessage(_ message: LogMessage, logLevel: LogLevel)
}

/// LogModifierWriter extends LogWriter to allow for standard writers that utilize MessageModifiers
/// to transform the message before being output.
public protocol LogModifierWriter: LogWriter {
    /// Array of modifiers that the writer should execute (in order) on incoming messages.
    var modifiers: [LogModifier] { get }
}

extension LogModifierWriter {
    /// Apply all of the LogMessageModifiers to the incoming message and return a new message.
    /// The modifiers are run in the order they are stored in `modifiers`.
    ///
    /// - Parameters:
    ///   - message:  Original message.
    ///   - logLevel: Log level of message.
    ///
    /// - Returns: The result of executing all the modifiers on the original message.
    public func modifyMessage(_ message: String, logLevel: LogLevel) -> String {
        var message = message
        modifiers.forEach { message = $0.modifyMessage(message, with: logLevel) }
        return message
    }
}

// MARK: -

/// The ConsoleWriter class runs all modifiers in the order they were created and prints the resulting message
/// to the console.
open class ConsoleWriter: LogModifierWriter {
    /// Used to define whether to use the print or NSLog functions when logging to the console.
    ///
    /// During development, it is recommendeded to use the `.print` case. When deploying to production, the `.nslog`
    /// case should be used instead. The main reason for this is that the `print` method does not log to the device
    /// console where as the `NSLog` method does.
    ///
    /// - print: Backed by the Swift `print` function.
    /// - nslog: Backed by the Objective-C `NSLog` function.
    public enum Method {
        case print, nslog
    }

    /// Array of modifiers that the writer should execute (in order) on incoming messages.
    public let modifiers: [LogModifier]

    private let method: Method

    /// Initializes a console writer instance.
    ///
    /// - Parameter method: The method to use when logging to the console. Defaults to `.print`.
    ///
    /// - Returns: A new console writer instance.
    public init(method: Method = .print, modifiers: [LogModifier] = []) {
        self.method = method
        self.modifiers = modifiers
    }

    /// Writes the message to the console using the global `print` function.
    ///
    /// Each modifier is run over the message in the order they are provided before writing the message to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original message to write to the console.
    ///   - logLevel:  The log level associated with the message.
    open func writeMessage(_ message: String, logLevel: LogLevel) {
        let message = modifyMessage(message, logLevel: logLevel)

        switch method {
        case .print: print(message)
        case .nslog: NSLog("%@", message)
        }
    }

    /// Writes the message to the console using the global `print` function.
    ///
    /// Each modifier is run over the message in the order they are provided before writing the message to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original message to write to the console.
    ///   - logLevel:  The log level associated with the message.
    open func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
        let message = modifyMessage("\(message.name): \(message.attributes)", logLevel: logLevel)

        switch method {
        case .print: print(message)
        case .nslog: NSLog("%@", message)
        }
    }
}

// MARK: -

/// The OSLogWriter class runs all modifiers in the order they were created and passes the resulting message
/// off to an OSLog with the specified subsystem and category.
@available(iOS 10.0, macOS 10.12.0, tvOS 10.0, watchOS 3.0, *)
open class OSLogWriter: LogModifierWriter {
    public let subsystem: String
    public let category: String

    /// Array of modifiers that the writer should execute (in order) on incoming messages.
    public let modifiers: [LogModifier]

    private let log: OSLog

    /// Creates an `OSLogWriter` instance from the specified `subsystem` and `category`.
    ///
    /// - Parameters:
    ///   - subsystem: The subsystem.
    ///   - category:  The category.
    public init(subsystem: String, category: String, modifiers: [LogModifier] = []) {
        self.subsystem = subsystem
        self.category = category
        self.modifiers = modifiers
        self.log = OSLog(subsystem: subsystem, category: category)
    }

    /// Writes the message to the `OSLog` using the `os_log` function.
    ///
    /// Each modifier is run over the message in the order they are provided before writing the message to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original message to write to the console.
    ///   - logLevel:  The log level associated with the message.
    open func writeMessage(_ message: String, logLevel: LogLevel) {
        let message = modifyMessage(message, logLevel: logLevel)
        let type = logType(forLogLevel: logLevel)

        os_log("%@", log: log, type: type, message)
    }

    /// Writes the breadrumb to the `OSLog` using the `os_log` function.
    ///
    /// Each modifier is run over the breadrumb in the order they are provided before writing the breadrumb to
    /// the console.
    ///
    /// - Parameters:
    ///   - message:   The original breadrumb to write to the console
    ///   - logLevel:  The log level associated with the message.
    open func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
        let message = modifyMessage("\(message.name): \(message.attributes)", logLevel: logLevel)
        let type = logType(forLogLevel: logLevel)

        os_log("%@", log: log, type: type, message)
    }

    /// Returns the `OSLogType` to use for the specified `LogLevel`.
    ///
    /// - Parameter logLevel: The level to be map to a `OSLogType`.
    ///
    /// - Returns: An `OSLogType` corresponding to the `LogLevel`.
    open func logType(forLogLevel logLevel: LogLevel) -> OSLogType {
        switch logLevel {
        case LogLevel.debug: return .debug
        case LogLevel.info:  return .info
        case LogLevel.warn:  return .default
        case LogLevel.error: return .error
        default:             return .default
        }
    }
}

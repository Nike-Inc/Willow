//
//  LogMessageWriter.swift
//
//  Copyright (c) 2015-2016 Nike, Inc. (https://www.nike.com)
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

/// The LogMessageWriter protocol defines a single API for writing a log message. The message can be written in any way
/// the conforming object sees fit. For example, it could write to the console, write to a file, remote log to a third
/// party service, etc.
public protocol LogMessageWriter {
    func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?)
}

// MARK: -

/// The ConsoleWriter class runs all modifiers in the order they were created and prints the resulting message
/// to the console.
open class ConsoleWriter: LogMessageWriter {
    /// Initializes a console writer instance.
    ///
    /// - returns: A new console writer instance.
    public init() {}

    /// Writes the message to the console using the global `print` function.
    ///
    /// Each modifier is run over the message in the order they are provided before writing the message to
    /// the console.
    ///
    /// - parameter message:   The original message to write to the console.
    /// - parameter logLevel:  The log level associated with the message.
    /// - parameter modifiers: The modifier objects to run over the message before writing to the console.
    open func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?) {
        var message = message
        modifiers?.forEach { message = $0.modifyMessage(message, with: logLevel) }

        print(message)
    }
}

#if !os(macOS)

/// The OSLogWriter class runs all modifiers in the order they were created and passes the resulting message
/// off to an OSLog with the specified subsystem and category.
@available(iOS 10.0, OSX 10.12.0, tvOS 10.0, watchOS 3.0, *)
open class OSLogWriter: LogMessageWriter {
    open let subsystem: String
    open let category: String
    private let log: OSLog

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        self.log = OSLog(subsystem: subsystem, category: category)
    }

    /// Writes the message to the `OSLog` using the `os_log` function.
    ///
    /// Each modifier is run over the message in the order they are provided before writing the message to
    /// the console.
    ///
    /// - parameter message:   The original message to write to the console.
    /// - parameter logLevel:  The log level associated with the message.
    /// - parameter modifiers: The modifier objects to run over the message before writing to the console.
    open func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?) {
        var message = message
        modifiers?.forEach { message = $0.modifyMessage(message, with: logLevel) }

        let logType: OSLogType

        switch logLevel {
        case LogLevel.debug:
            logType = .debug
        case LogLevel.info:
            logType = .info
        case LogLevel.warn, LogLevel.error:
            logType = .error
        default:
            logType = .default
        }

        os_log("%@", log: log, type: logType, message)
    }
}

#endif

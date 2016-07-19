//
//  LoggerConfiguration.swift
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

/// The LoggerConfiguration is a container struct for storing all the configuration information to be applied to
/// a Logger instance.
public struct LoggerConfiguration {

    // MARK:
    // MARK: Helper Types

    /// Defines the two types of execution methods used when logging a message.
    ///
    /// Logging operations can be expensive operations when there are hundreds of messages being generated or when
    /// it is computationally expensive to compute the message to log. Ideally, one would use the synchronous method
    /// in development, and the asynchronous method in production. This allows for easier debugging in the development
    /// environment, and better performance in production.
    ///
    /// - Synchronous:  Logs messages synchronously once the recursive lock is available in serial order.
    /// - Asynchronous: Logs messages asynchronously on the dispatch queue in a serial order.
    public enum ExecutionMethod {
        case Synchronous(lock: RecursiveLock)
        case Asynchronous(queue: DispatchQueue)
    }

    // MARK:
    // MARK: Properties

    /// The dictionary of modifiers to apply to each associated log level.
    public let modifiers: [LogLevel: [LogMessageModifier]]

    /// The dictionary of writers to use when messages are written for each associated log level.
    public let writers: [LogLevel: [LogMessageWriter]]

    /// The execution method used when logging a message.
    public let executionMethod: ExecutionMethod

    // MARK:
    // MARK: Initialization

    /// Initializes a logger configuration instance.
    ///
    /// - parameter modifiers:       The dictionary of modifiers to apply to the associated log level. `[:]` by default.
    /// - parameter writers:         The dictionary of writers to write to for the associated log level.
    ///                              `[.All: [ConsoleWriter()]` by default.
    /// - parameter executionMethod: The execution method used when logging a message. `.Synchronous` by default.
    ///
    /// - returns: A fully initialized logger configuration instance.
    public init(
        modifiers: [LogLevel: [LogMessageModifier]] = [:],
        writers: [LogLevel: [LogMessageWriter]] = [.all: [ConsoleWriter()]],
        executionMethod: ExecutionMethod = .Synchronous(lock: RecursiveLock()))
    {
        func restructureDictionaryValuesPerBitBasedLogLevel<T>(_ values: [LogLevel: [T]]) -> [LogLevel: [T]] {
            var specifiedValues: [LogLevel: [T]] = [:]

            for bitShift in UInt(0)..<UInt(32) {
                let bitValue = 1 << bitShift
                var valuesForBit: [T] = []

                for key in values.keys where key.rawValue & bitValue > 0 {
                    valuesForBit += values[key]!
                }

                if !valuesForBit.isEmpty {
                    specifiedValues[LogLevel(rawValue: bitValue)] = valuesForBit
                }
            }

            return specifiedValues
        }

        self.modifiers = restructureDictionaryValuesPerBitBasedLogLevel(modifiers)
        self.writers = restructureDictionaryValuesPerBitBasedLogLevel(writers)
        self.executionMethod = executionMethod
    }

    // MARK:
    // MARK: Customized Configurations

    /// Creates a logger configuration instance with a timestamp modifier applied to each log level.
    ///
    /// - parameter logLevel:        The log level to apply to the default `ConsoleWriter`. `.All` by default.
    /// - parameter asynchronous:    Whether to write messages asynchronously on the given queue. `false` by default.
    /// - parameter executionMethod: The execution method used when logging a message. `.Synchronous` by default.
    ///
    /// - returns: A fully initialized logger configuration instance.
    public static func timestampConfiguration(
        logLevel: LogLevel = .all,
        executionMethod: ExecutionMethod = .Synchronous(lock: RecursiveLock()))
        -> LoggerConfiguration
    {
        let modifiers: [LogLevel: [LogMessageModifier]] = [logLevel: [TimestampModifier()]]
        let writers: [LogLevel: [LogMessageWriter]] = [logLevel: [ConsoleWriter()]]

        return LoggerConfiguration(modifiers: modifiers, writers: writers, executionMethod: executionMethod)
    }

    /// Creates a logger configuration instance with a timestamp and color modifier applied to each log level.
    ///
    /// - parameter logLevel:        The log level to apply to the default `ConsoleWriter`. `.All` by default.
    /// - parameter asynchronous:    Whether to write messages asynchronously on the given queue. `false` by default.
    /// - parameter executionMethod: The execution method used when logging a message. `.Synchronous` by default.
    ///
    /// - returns: A fully initialized logger configuration instance.
    public static func coloredTimestampConfiguration(
        logLevel: LogLevel = .all,
        executionMethod: ExecutionMethod = .Synchronous(lock: RecursiveLock()))
        -> LoggerConfiguration
    {
        let purple = Color(red: 0.6, green: 0.247, blue: 1.0, alpha: 1.0)
        let blue = Color(red: 0.176, green: 0.569, blue: 1.0, alpha: 1.0)
        let green = Color(red: 0.533, green: 0.812, blue: 0.031, alpha: 1.0)
        let orange = Color(red: 0.914, green: 0.647, blue: 0.184, alpha: 1.0)
        let red = Color(red: 0.902, green: 0.078, blue: 0.078, alpha: 1.0)

        let timestampModifier = TimestampModifier()

        let modifiers: [LogLevel: [LogMessageModifier]] = [
            .debug: [timestampModifier, ColorModifier(foregroundColor: purple, backgroundColor: nil)],
            .info: [timestampModifier, ColorModifier(foregroundColor: blue, backgroundColor: nil)],
            .event: [timestampModifier, ColorModifier(foregroundColor: green, backgroundColor: nil)],
            .warn: [timestampModifier, ColorModifier(foregroundColor: orange, backgroundColor: nil)],
            .error: [timestampModifier, ColorModifier(foregroundColor: red, backgroundColor: nil)]
        ]

        let writers: [LogLevel: [LogMessageWriter]] = [logLevel: [ConsoleWriter()]]

        return LoggerConfiguration(modifiers: modifiers, writers: writers, executionMethod: executionMethod)
    }
}

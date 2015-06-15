//
//  LoggerConfiguration.swift
//
//  Copyright (c) 2015, Nike
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

import Foundation

/**
    The LoggerConfiguration is a container struct for storing all the configuration information to be applied to
    a Logger instance.
*/
public struct LoggerConfiguration {

    // MARK: Properties

    /// The log level used to determine which messages are written.
    public let logLevel: LogLevel

    /// The dictionary of formatters to apply to each associated log level.
    public let formatters: [LogLevel: [Formatter]]

    /// The writers to use when messages are written.
    public let writers: [Writer]

    /// Whether to write messages asynchronously to the internal queue.
    public let asynchronous: Bool

    /// A custom queue to swap out for the default one. This allows sharing queues between multiple logger instances.
    public let queue: dispatch_queue_t

    // MARK: Initialization Methods

    /**
        Initializes a logger configuration instance.

        - parameter logLevel:     The log level used to determine which messages are written. `.All` by default.
        - parameter formatters:   The dictionary of formatters to apply to each associated log level. `nil` by default.
        - parameter writers:      The writers to use when messages are written. `[ConsoleWriter()]` by default.
        - parameter asynchronous: Whether to write messages asynchronously on the given queue. `false` by default.
        - parameter queue:        A custom queue to swap out for the default one. This allows sharing queues between
                                  multiple logger instances. `nil` by default.

        - returns: A fully initialized logger configuration instance.
    */
    public init(
        logLevel: LogLevel = .All,
        formatters: [LogLevel: [Formatter]]? = nil,
        writers: [Writer] = [ConsoleWriter()],
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil)
    {
        self.logLevel = logLevel
        self.formatters = formatters ?? [LogLevel: [Formatter]]()
        self.writers = writers
        self.asynchronous = asynchronous
        self.queue = queue ?? {
            let label = String(format: "com.nike.willow-%08x%08x", arc4random(), arc4random())
            return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
        }()
    }

    // MARK: Customized Configurations

    /**
        Creates a logger configuration instance with a timestamp formatter applied to each log level.

        - parameter logLevel:     The log level used to determine which messages are written. `.All` by default.
        - parameter asynchronous: Whether to write messages asynchronously on the given queue. `false` by default.
        - parameter queue:        A custom queue to swap out for the default one. This allows sharing queues between
                                  multiple logger instances. `nil` by default.

        - returns: A fully initialized logger configuration instance.
    */
    public static func timestampConfiguration(
        logLevel: LogLevel = .All,
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil)
        -> LoggerConfiguration
    {
        let timestampFormatter: [Formatter] = [TimestampFormatter()]

        let formatters: [LogLevel: [Formatter]] = [
            .Debug: timestampFormatter,
            .Info: timestampFormatter,
            .Event: timestampFormatter,
            .Warn: timestampFormatter,
            .Error: timestampFormatter,
        ]

        return LoggerConfiguration(logLevel: logLevel, formatters: formatters, asynchronous: asynchronous, queue: queue)
    }

    /**
        Creates a logger configuration instance with a timestamp and color formatter applied to each log level.

        - parameter logLevel:     The log level used to determine which messages are written. `.All` by default.
        - parameter asynchronous: Whether to write messages asynchronously on the given queue. `false` by default.
        - parameter queue:        A custom queue to swap out for the default one. This allows sharing queues between
                                  multiple logger instances. `nil` by default.

        - returns: A fully initialized logger configuration instance.
    */
    public static func coloredTimestampConfiguration(
        logLevel: LogLevel = .All,
        asynchronous: Bool = false,
        queue: dispatch_queue_t? = nil)
        -> LoggerConfiguration
    {
        let purple = Color(red: 0.6, green: 0.247, blue: 1.0, alpha: 1.0)
        let blue = Color(red: 0.176, green: 0.569, blue: 1.0, alpha: 1.0)
        let green = Color(red: 0.533, green: 0.812, blue: 0.031, alpha: 1.0)
        let orange = Color(red: 0.914, green: 0.647, blue: 0.184, alpha: 1.0)
        let red = Color(red: 0.902, green: 0.078, blue: 0.078, alpha: 1.0)

        let timestampFormatter = TimestampFormatter()

        let formatters: [LogLevel: [Formatter]] = [
            .Debug: [timestampFormatter, ColorFormatter(foregroundColor: purple, backgroundColor: nil)],
            .Info: [timestampFormatter, ColorFormatter(foregroundColor: blue, backgroundColor: nil)],
            .Event: [timestampFormatter, ColorFormatter(foregroundColor: green, backgroundColor: nil)],
            .Warn: [timestampFormatter, ColorFormatter(foregroundColor: orange, backgroundColor: nil)],
            .Error: [timestampFormatter, ColorFormatter(foregroundColor: red, backgroundColor: nil)]
        ]

        return LoggerConfiguration(logLevel: logLevel, formatters: formatters, asynchronous: asynchronous, queue: queue)
    }
}

//
//  WillowConfiguration.swift
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

import Database
import Foundation
import Network
import UIKit
import Willow

var log: Logger!

struct WillowConfiguration {

    // MARK: - Formatters

    private struct PrefixFormatter: Formatter {
        let emoji: String
        let name: String

        init(emoji: String, name: String) {
            self.emoji = emoji
            self.name = name
        }

        func formatMessage(message: String, logLevel: LogLevel) -> String {
            return emoji + " [" + name + "] => " + message
        }
    }

    private struct WarningPrefixFormatter: Formatter {
        func formatMessage(message: String, logLevel: LogLevel) -> String {
            return "🚨🚨🚨 \(message)"
        }
    }

    private struct ErrorPrefixFormatter: Formatter {
        func formatMessage(message: String, logLevel: LogLevel) -> String {
            return "💣💥💣💥 \(message)"
        }
    }

    // MARK: - Configure

    static func configure(
        appLogLevels appLogLevels: LogLevel = [.Debug, .Info, .Event],
        databaseLogLevels: LogLevel = [.SQL, .Debug, .Info, .Event],
        networkLogLevels: LogLevel = [.Debug, .Info, .Event],
        asynchronous: Bool = false)
    {
        let writers: [LogLevel: [Writer]] = [.All: [ConsoleWriter()]]
        let executionMethod: LoggerConfiguration.ExecutionMethod

        if asynchronous {
            executionMethod = .Synchronous(lock: NSRecursiveLock())
        } else {
            executionMethod = .Asynchronous(queue: dispatch_queue_create("com.nike.example.logger", DISPATCH_QUEUE_SERIAL))
        }

        log = configureLogger(
            emoji: "🌳🌳🌳",
            name: "App",
            formatterLogLevel: [.Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )

        Database.log = configureLogger(
            emoji: "🗃🗃🗃",
            name: "Database",
            formatterLogLevel: [.SQL, .Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )

        Network.log = configureLogger(
            emoji: "📡📡📡",
            name: "Network",
            formatterLogLevel: [.Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )
    }

    private static func configureLogger(
        emoji emoji: String,
        name: String,
        formatterLogLevel: LogLevel,
        writers: [LogLevel: [Writer]],
        executionMethod: LoggerConfiguration.ExecutionMethod)
        -> Logger
    {
        let prefixFormatter = PrefixFormatter(emoji: emoji, name: name)
        let timestampFormatter = TimestampFormatter()

        let formatters: [LogLevel: [Formatter]] = {
            let formatters: [Formatter] = [prefixFormatter, timestampFormatter]

            return [
                formatterLogLevel: formatters,
                .Warn: [WarningPrefixFormatter()] + formatters,
                .Error: [ErrorPrefixFormatter()] + formatters
            ]
        }()

        let configuration = LoggerConfiguration(
            formatters: formatters,
            writers: writers,
            executionMethod: executionMethod
        )

        return Logger(configuration: configuration)
    }
}

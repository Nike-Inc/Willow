//
//  WillowConfiguration.swift
//
//  Copyright (c) 2015-2016 Nike (https://developer.nike.com)
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
        let prefix: String

        init(prefix: String) {
            self.prefix = prefix
        }

        func formatMessage(message: String, logLevel: LogLevel) -> String {
            return "[\(prefix)] => \(message)"
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
        coloredOutputEnabled: Bool = true,
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
            foregroundColor: Color.whiteColor(),
            backgroundColor: coloredOutputEnabled ? Color(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0) : nil,
            prefix: "App",
            formatterLogLevel: [.Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )

        Database.log = configureLogger(
            foregroundColor: Color.whiteColor(),
            backgroundColor: Color(red: 1.0, green: 0.518, blue: 0.043, alpha: 1.0),
            prefix: "Database",
            formatterLogLevel: [.SQL, .Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )

        Network.log = configureLogger(
            foregroundColor: coloredOutputEnabled ? Color(white: 0.2, alpha: 1.0) : nil,
            backgroundColor: Color(red: 0.797, green: 0.984, blue: 0.0, alpha: 1.0),
            prefix: "Network",
            formatterLogLevel: [.Debug, .Info, .Event],
            writers: writers,
            executionMethod: executionMethod
        )
    }

    private static func configureLogger(
        foregroundColor foregroundColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        prefix: String,
        formatterLogLevel: LogLevel,
        writers: [LogLevel: [Writer]],
        executionMethod: LoggerConfiguration.ExecutionMethod)
        -> Logger
    {
        let prefixFormatter = PrefixFormatter(prefix: prefix)
        let timestampFormatter = TimestampFormatter()
        let colorFormatter = ColorFormatter(foregroundColor: foregroundColor, backgroundColor: backgroundColor)

        let formatters: [LogLevel: [Formatter]] = {
            let formatters: [Formatter] = {
                var formatters: [Formatter] = [prefixFormatter, timestampFormatter]
                if foregroundColor != nil || backgroundColor != nil { formatters.append(colorFormatter) }
                return formatters
            }()

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

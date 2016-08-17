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

    // MARK: Modifiers

    private struct PrefixModifier: LogMessageModifier {
        let prefix: String

        init(prefix: String) {
            self.prefix = prefix
        }

        func modifyMessage(_ message: String, with: LogLevel) -> String {
            return "[\(prefix)] => \(message)"
        }
    }

    private struct WarningPrefixModifier: LogMessageModifier {
        func modifyMessage(_ message: String, with: LogLevel) -> String {
            return "🚨🚨🚨 \(message)"
        }
    }

    private struct ErrorPrefixModifier: LogMessageModifier {
        func modifyMessage(_ message: String, with: LogLevel) -> String {
            return "💣💥💣💥 \(message)"
        }
    }

    // MARK: Configure

    static func configure(
        appLogLevels: LogLevel = [.debug, .info, .event],
        databaseLogLevels: LogLevel = [.sql, .debug, .info, .event],
        networkLogLevels: LogLevel = [.debug, .info, .event],
        coloredOutputEnabled: Bool = true,
        asynchronous: Bool = false)
    {
        let writers: [LogLevel: [LogMessageWriter]] = [.all: [ConsoleWriter()]]
        let executionMethod: LoggerConfiguration.ExecutionMethod

        if asynchronous {
            executionMethod = .Synchronous(lock: NSRecursiveLock())
        } else {
            executionMethod = .Asynchronous(
                queue: DispatchQueue(label: "com.nike.example.logger", qos: .utility)
            )
        }

        log = configureLogger(
            foregroundColor: Color.white,
            backgroundColor: coloredOutputEnabled ? Color(red: 0.0, green: 0.7, blue: 1.0, alpha: 1.0) : nil,
            prefix: "App",
            modifierLogLevel: [.debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )

        Database.log = configureLogger(
            foregroundColor: Color.white,
            backgroundColor: Color(red: 1.0, green: 0.518, blue: 0.043, alpha: 1.0),
            prefix: "Database",
            modifierLogLevel: [.sql, .debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )

        Network.log = configureLogger(
            foregroundColor: coloredOutputEnabled ? Color(white: 0.2, alpha: 1.0) : nil,
            backgroundColor: Color(red: 0.797, green: 0.984, blue: 0.0, alpha: 1.0),
            prefix: "Network",
            modifierLogLevel: [.debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )
    }

    private static func configureLogger(
        foregroundColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        prefix: String,
        modifierLogLevel: LogLevel,
        writers: [LogLevel: [LogMessageWriter]],
        executionMethod: LoggerConfiguration.ExecutionMethod)
        -> Logger
    {
        let prefixModifier = PrefixModifier(prefix: prefix)
        let timestampModifier = TimestampModifier()
        let colorModifier = ColorModifier(foregroundColor: foregroundColor, backgroundColor: backgroundColor)

        let modifiers: [LogLevel: [LogMessageModifier]] = {
            let modifiers: [LogMessageModifier] = {
                var modifiers: [LogMessageModifier] = [prefixModifier, timestampModifier]
                if foregroundColor != nil || backgroundColor != nil { modifiers.append(colorModifier) }
                return modifiers
            }()

            return [
                modifierLogLevel: modifiers,
                .warn: [WarningPrefixModifier()] + modifiers,
                .error: [ErrorPrefixModifier()] + modifiers
            ]
        }()

        let configuration = LoggerConfiguration(
            modifiers: modifiers,
            writers: writers,
            executionMethod: executionMethod
        )

        return Logger(configuration: configuration)
    }
}

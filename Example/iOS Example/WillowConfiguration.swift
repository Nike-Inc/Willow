//
//  WillowConfiguration.swift
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

import Database
import Foundation
import UIKit
import WebServices
import Willow

var log: Logger!

struct WillowConfiguration {

    // MARK: - Modifiers

    private struct PrefixModifier: LogMessageModifier {
        let emoji: String
        let name: String

        init(emoji: String, name: String) {
            self.emoji = emoji
            self.name = name
        }

        func modifyMessage(_ message: String, with: LogLevel) -> String {
            return emoji + " [" + name + "] => " + message
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

    // MARK: - Configure

    static func configure(
        appLogLevels: LogLevel = [.debug, .info, .event],
        databaseLogLevels: LogLevel = [.sql, .debug, .info, .event],
        webServicesLogLevels: LogLevel = [.debug, .info, .event],
        asynchronous: Bool = false)
    {
        let writers: [LogLevel: [LogMessageWriter]] = [.all: [ConsoleWriter()]]
        let executionMethod: LoggerConfiguration.ExecutionMethod

        if asynchronous {
            executionMethod = .synchronous(lock: NSRecursiveLock())
        } else {
            executionMethod = .asynchronous(
                queue: DispatchQueue(label: "com.nike.example.logger", qos: .utility)
            )
        }

        log = configureLogger(
            emoji: "🌳🌳🌳",
            name: "App",
            modifierLogLevel: [.debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )

        Database.log = configureLogger(
            emoji: "🗃🗃🗃",
            name: "Database",
            modifierLogLevel: [.sql, .debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )

        WebServices.log = configureLogger(
            emoji: "📡📡📡",
            name: "WebServices",
            modifierLogLevel: [.debug, .info, .event],
            writers: writers,
            executionMethod: executionMethod
        )
    }

    private static func configureLogger(
        emoji: String,
        name: String,
        modifierLogLevel: LogLevel,
        writers: [LogLevel: [LogMessageWriter]],
        executionMethod: LoggerConfiguration.ExecutionMethod)
        -> Logger
    {
        let prefixModifier = PrefixModifier(emoji: emoji, name: name)
        let timestampModifier = TimestampModifier()

        let modifiers: [LogLevel: [LogMessageModifier]] = {
            let modifiers: [LogMessageModifier] = [prefixModifier, timestampModifier]

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

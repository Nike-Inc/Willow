//
//  WillowConfiguration.swift
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

import Database
import Foundation
import UIKit
import WebServices
import Willow

var log: Logger = .disabled

struct WillowConfiguration {

    // MARK: - Modifiers

    private struct PrefixModifier: LogModifier {
        let prefix: String
        let name: String

        init(prefix: String, name: String) {
            self.prefix = prefix
            self.name = name
        }

        func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
            switch logLevel {
            case .warn:  return "🚨🚨🚨 [\(name)] => \(message)"
            case .error: return "💣💥💣💥 [\(name)] => \(message)"
            default:     return "\(prefix) [\(name)] => \(message)"
            }
        }
    }

    // MARK: Writers

    private class ServiceWriter: LogWriter {
        func writeMessage(_ message: String, logLevel: LogLevel) {
            // Send the message as-is to our external logging service
            let attributes: [String: Any] = ["LogLevel": logLevel.description]

             ServiceSDK.recordBreadcrumb(message, attributes: attributes)
        }

        func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
            // Send the message as-is to our external logging service
            var attributes = message.attributes
            attributes["LogLevel"] = logLevel.description

            ServiceSDK.recordBreadcrumb(message.name, attributes: attributes)
        }
    }

    // MARK: - Configure

    static func configure() {
        #if DEBUG
            // A debug build of the application would probably log at a higher level than a release version.
            // Also, synchronous logging can be beneficial in debug mode so that log statements emit as you step through the code.
            let appLogLevels: LogLevel = [.all]
            let databaseLogLevels: LogLevel = [.all]
            let webServicesLogLevels: LogLevel = [.event, .warn, .error]
            let executionMethod: Logger.ExecutionMethod = .synchronous(lock: NSRecursiveLock())
        #else
            // A release build probably logs only important data, omitting verbose debug information.
            // Also, asynchronous logging can be desirable to not hold up the current thread for each log statement.
            // Note that the execution method encapsulates the dispatch queue allowing for all logger instances using the same
            // execution method to share the same queue and be correctly synchronized.
            let appLogLevels: LogLevel = [.event, .warn, .error]
            let databaseLogLevels: LogLevel = [.event, .warn, .error]
            let webServicesLogLevels: LogLevel = [.event, .warn, .error]
            let executionMethod: Logger.ExecutionMethod = .asynchronous(
                queue: DispatchQueue(label: "com.nike.example.logger", qos: .utility)
            )
        #endif

        log = createLogger(
            prefix: "🌳🌳🌳",
            name: "App",
            logLevels: appLogLevels,
            executionMethod: executionMethod
        )

        Database.log = createLogger(
            prefix: "🗃🗃🗃",
            name: "Database",
            logLevels: databaseLogLevels,
            executionMethod: executionMethod
        )

        WebServices.log = createLogger(
            prefix: "📡📡📡",
            name: "WebServices",
            logLevels: webServicesLogLevels,
            executionMethod: executionMethod
        )
        WebServices.log.addFilter(HTTPStatusCodeFilter(statusCodeToIgnore: 200))
    }

    private static func createLogger(
        prefix: String,
        name: String,
        logLevels: LogLevel,
        executionMethod: Logger.ExecutionMethod)
        -> Logger
    {
        let prefixModifier = PrefixModifier(prefix: prefix, name: name)
        let timestampModifier = TimestampModifier()
        let writers: [LogWriter] = [ConsoleWriter(modifiers: [prefixModifier, timestampModifier]), ServiceWriter()]

        return Logger(logLevels: logLevels, writers: writers, executionMethod: executionMethod)
    }
}

/// Placeholder for a 3rd party logging service SDK. Serves as an example of calling an SDK with log output.
private struct ServiceSDK {
    static func recordBreadcrumb(_ message: String, attributes: [String: Any]) {
        // Implement me...
    }
}

// An example of a filter that can exclude certain logs
struct HTTPStatusCodeFilter: LogFilter {
    let statusCodeToIgnore: Int

    init(statusCodeToIgnore: Int) {
        self.statusCodeToIgnore = statusCodeToIgnore
    }

    func shouldInclude(_ logMessage: Willow.LogMessage, level: Willow.LogLevel) -> Bool {
        if let responseCode = logMessage.attributes["response_code"] as? Int {
            print("Ignored: \(logMessage.name), \(logMessage.attributes)")
            return responseCode != statusCodeToIgnore
        }

        return true
    }

    func shouldInclude(_ message: String, level: Willow.LogLevel) -> Bool {
        // string messages don't have the metadata we use to filter
        true
    }
}

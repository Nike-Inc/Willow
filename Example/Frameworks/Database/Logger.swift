//
//  Logger.swift
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

import Foundation
import Willow

extension LogLevel {
    // Namespace our custom levels
    public enum Database {
        /// Custom log level for SQL log messages with a bitmask of `1 << 8`.
        public static var sql = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
    }
}

// MARK: -

// Extend Logger to have `sql` log level functions.
extension Logger {
    func sql(_ message: @autoclosure @escaping () -> LogMessage) {
        logMessage(message, with: LogLevel.Database.sql)
    }

    func sql(_ message: @escaping () -> LogMessage) {
        logMessage(message, with: LogLevel.Database.sql)
    }
}

// Extend Logger optional support to have `sql` log level functions.
extension Optional where Wrapped == Logger {
    func sql(_ message: @autoclosure @escaping () -> LogMessage) {
        guard case let .some(log) = self else { return }
        log.logMessage(message, with: LogLevel.Database.sql)
    }

    func sql(_ message: @escaping () -> LogMessage) {
        guard case let .some(log) = self else { return }
        log.logMessage(message, with: LogLevel.Database.sql)
    }
}

// MARK: -

/// The single `Logger` instance used throughout Database.
/// Note that the extension for Optional<Logger> allows for the safe use of `log` without unwrapping.
public var log: Logger?

/// Message type used by the Database framework.
/// With this implementation you would have an enum case for each distinct message to be written.
/// Note that where you might have had separate (but similar) strings in the past for messages,
/// you can now consolidate into a single message with attributes now providing unique details
enum Message: Willow.LogMessage {
    case backupComplete
    case connectionOpened
    case sqlQuery(sql: String)
    case failure(error: Error)
    case sqlFailure(sql: String, error: Error)

    var name: String {
        switch self {
        case .connectionOpened: return "Connection opened"
        case .backupComplete:   return "Backup complete"
        case .sqlQuery:         return "SQL Query"
        case .failure:          return "Error"
        case .sqlFailure:       return "SQL Error"
        }
    }

    var attributes: [String: Any] {
        var keyPathAttributes: [KeyPath: Any] = [:]
        let success: Bool

        // Fill in message specific attributes
        switch self {
        case .connectionOpened:
            success = true

        case .backupComplete:
            success = true

        case let .sqlQuery(sql):
            keyPathAttributes[.sql] = sql
            success = true

        case let .failure(error):
            keyPathAttributes[.errorDescription] = message(forError: error)
            keyPathAttributes[.errorCode] = code(forError: error)
            success = false

        case let .sqlFailure(sql, error):
            keyPathAttributes[.sql] = sql
            keyPathAttributes[.errorDescription] = message(forError: error)
            keyPathAttributes[.errorCode] = code(forError: error)
            success = false
        }

        // Assign attributes that should be present for all messages
        keyPathAttributes[.frameworkName] = Framework.name
        keyPathAttributes[.frameworkVersion] = Framework.version
        keyPathAttributes[.result] = success ? "success" : "failure"

        // Map to the expected types
        var attributes: [String: Any] = [:]
        keyPathAttributes.forEach { attributes[$0.key.rawValue] = $0.value }

        return attributes
    }

    /// Information about this framework.
    private enum Framework {
        static let name = "Database"

        static let version: String = {
            class Version {}
            return Bundle(for: Version.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        }()
    }

    /// Attribute keys this framework uses.
    private enum KeyPath: String {
        case sql                = "sql"
        case errorDescription   = "error_description"
        case errorCode          = "error_code"
        case result             = "result"
        case frameworkName      = "framework_name"
        case frameworkVersion   = "framework_version"
    }

    private func code(forError error: Error) -> Int {
        guard let sqlError = error as? SQLError else { return (error as NSError).code }
        return Int(sqlError.code)
    }

    private func message(forError error: Error) -> String {
        guard let sqlError = error as? SQLError else { return (error as NSError).localizedDescription }
        return sqlError.message
    }
}

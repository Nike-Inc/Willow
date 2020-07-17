//
//  LogModifier.swift
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

/// The LogModifier protocol defines methods for modifying a log message after it has been constructed.
/// This is very flexible allowing any object that conforms to modify messages in any way it wants.
public protocol LogModifier {
    /// - Parameter message: The message to be modified.
    /// - Parameter logLevel: The log leve assigned to his message.
    /// - Returns: Modified message string.
    ///
    /// - Note: This is the method originally specified for the `LogModifier` protocol. All additional
    ///         protocol methods provide a default implementation via an extension so existing clients
    ///         will continue to work without modifications.
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String
    
    /// - Parameter message: The message to be modified.
    /// - Parameter logLevel: The log leve assigned to his message.
    /// - Parameter attributes: The array of message attributes that were part of the original log message.
    /// - Returns: Modified message string.
    func modifyMessage(_ message: String, with logLevel: LogLevel, attributes: [String: Any]) -> String
    
    /// - Parameter message: The message to be modified.
    /// - Parameter context: The context captured when this log message was recorded.
    /// - Parameter attributes: The array of message attributes that were part of the original log message.
    /// - Returns: Modified message string.
    func modifyMessage(_ message: String, with context: LogMessageContext, attributes: [String: Any]) -> String
}

public extension LogModifier {
    /// Default implementation is provided for existing clients of Willow. It ignores the attributes.
    func modifyMessage(_ message: String, with logLevel: LogLevel, attributes: [String: Any]) -> String {
        return modifyMessage(message, with: logLevel)
    }
    
    /// Default implementation is in terms of original modifyMessage method.
    func modifyMessage(_ message: String, with context: LogMessageContext, attributes: [String: Any]) -> String {
        return modifyMessage(message, with: context.logLevel)
    }
}

// MARK: -

/// The `PropertyExpansionModifier` replaces property references in the message string with values found in the `attributes` or `context`.
///
/// For example, if the message was `"Failure reason: {attributes.reason}"` and the passed attributes array contained
/// a key of `reason` with the value `Service unavailable`, the modified message would be `"Failure reason: Service unavailable"`
///
/// The syntax for an attribute property reference is: `{attributes.(key)}`.  You replace the `(key)` with an actual key value from the attributes array.
/// The syntax for a context property reference is: `{context.(key)}`. In this case, the `(key)` must be one of the following values:
///
/// * `logLevel` - The log level
/// * `timestamp` - The timestamp in milliseconds since epoch.
/// * `file` - The name of the file where the log message was recorded.
/// * `function`- The name of the function in which the log message was recorded.
/// * `line` - The line number where the log message was recorded.
/// * `subsystem` - The optional application-defined subsystem this log message belongs to.
/// * `category` - The optional application-defined category this log message belongs to.
/// * `session` - The optional application-defined session identifier.
/// * `user` - The optional application-defined user identifier.
///
/// Some of these context values are optional. If they are not provided in the log message context, the property reference
/// will be replaced with the string `missing`.
///
/// References are case sensitive. The replacement will fail if the cases do not match.
///
open class PropertyExpansionModifier: LogModifier {
    /// Initializes a `PropertyExpansionModifier` instance.
    ///
    /// - Returns: A new `PropertyExpansionModifier` instance.
    public init() {}
    
    public func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        // No expansion is possible when this method is called.
        return message
    }
    
    public func modifyMessage(_ message: String, with logLevel: LogLevel, attributes: [String : Any]) -> String {
        var modifiedMessage = message
        for (key, value) in attributes {
            if let convertableValue = value as? CustomStringConvertible {
                let stringValue = String(describing: convertableValue)
                let replaceableString = "{attributes.\(key)}"
                modifiedMessage = modifiedMessage.replacingOccurrences(of: replaceableString, with: stringValue)
            }
        }
        return modifiedMessage
    }
    
    public func modifyMessage(_ message: String, with context: LogMessageContext, attributes: [String : Any]) -> String {
        var modifiedMessage = message
        
        var contextProperties: [String: Any] = [:]
        contextProperties["logLevel"] = context.logLevel
        contextProperties["timestamp"] = context.timestamp
        contextProperties["file"] = context.file
        contextProperties["function"] = context.function
        contextProperties["line"] = context.line
        
        // The following properties are all optional in the LogMessageContext.
        // If no value is available, a property reference will be replaced with the
        // string "missing".
        let missingPropertyValue = "missing"
        contextProperties["subsystem"] = missingPropertyValue
        contextProperties["category"] = missingPropertyValue
        contextProperties["session"] = missingPropertyValue
        contextProperties["user"] = missingPropertyValue
        
        if let subsystem = context.subsystem {
            contextProperties["subsystem"] = subsystem
        }
        if let category = context.category {
            contextProperties["category"] = category
        }
        if let session = context.session {
            contextProperties["session"] = session
        }
        if let user = context.user {
            contextProperties["user"] = user
        }
        
        for (key, value) in contextProperties {
            if let convertableValue = value as? CustomStringConvertible {
                let stringValue = String(describing: convertableValue)
                let replaceableString = "{context.\(key)}"
                modifiedMessage = modifiedMessage.replacingOccurrences(of: replaceableString, with: stringValue)
            }
        }
        
        return modifyMessage(modifiedMessage, with: context.logLevel, attributes: attributes)
    }
}

// MARK: -

/// The TimestampModifier class applies a timestamp to the beginning of the message.
open class TimestampModifier: LogModifier {
    private let timestampFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    /// Initializes a `TimestampModifier` instance.
    ///
    /// - Returns: A new `TimestampModifier` instance.
    public init() {}

    /// Applies a timestamp to the beginning of the message.
    ///
    /// - Parameters:
    ///   - message:  The original message to format.
    ///   - logLevel: The log level set for the message.
    ///
    /// - Returns: A newly formatted message.
    open func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
        let timestampString = timestampFormatter.string(from: Date())
        return "\(timestampString) \(message)"
    }
    
    /// Applies a timestamp to the beginning of the message.
    ///
    /// - Parameters:
    ///   - message: The original message to format.
    ///   - context: Context for this log message.
    ///
    /// - Returns: A newly formatted message.
    open func modifyMessage(_ message: String, with context: LogMessageContext, attributes: [String: Any] = [:]) -> String {
        let messageDate = Date(timeIntervalSince1970: context.timestamp)
        let timestampString = timestampFormatter.string(from: messageDate)
        return "\(timestampString) \(message)"
    }
}

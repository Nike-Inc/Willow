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

/// The LogModifier protocol defines a single method for modifying a log message after it has been constructed.
/// This is very flexible allowing any object that conforms to modify messages in any way it wants.
public protocol LogModifier {
    func modifyMessage(_ message: String, with logLevel: LogLevel) -> String
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
}

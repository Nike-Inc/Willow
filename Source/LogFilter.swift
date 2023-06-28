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

/// The ``LogFilter`` protocol defines the requirements to add your own dynamic filters to allow your own code to
/// decide to filter out (i.e. not log) certain types of log messages based on criteria you define.
///
/// The canonical default implementation of this is the ``LogLevelFilter``, which will filter out messages that do
/// not meet the minimum specified log level.
public protocol LogFilter {
    /// An optional identifier to define if you need to remove this log filter later. Defaults to a randomly generated value.
    var name: String { get }

    /// Determines if a log message should be emitted.
    /// - Parameters:
    ///   - logMessage: A log message struct
    ///   - level: The log level of the message
    /// - Returns: true if the log message should be included
    func shouldInclude(_ logMessage: LogMessage, level: LogLevel) -> Bool

    /// Determines if a log message should be emitted.
    /// - Parameters:
    ///   - logMessage: A log message string
    ///   - level: The log level of the message
    /// - Returns: true if the log message should be included
    func shouldInclude(_ message: String, level: LogLevel) -> Bool
}

public extension LogFilter {
    var name: String { UUID().uuidString }
}

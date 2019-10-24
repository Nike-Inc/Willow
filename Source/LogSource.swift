//
//  LogMessage.swift
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

/// A LogSource represents the position in the source code where a message is logged.
public struct LogSource {
    /// The name of the file.
    public var file: StaticString

    /// The name of the function.
    public var function: StaticString

    /// The line number.
    public var line: UInt

    /// The column number.
    public var column: UInt

    /// Initializes a `LogSource` instance.
    ///
    /// - Parameters:
    ///    - file: The name of the file.
    ///    - function: The name of the function.
    ///    - line: The line number.
    ///    - column: The column number.
    ///    
    /// - Returns: A new `LogSource` instance.
    public init(file: StaticString, function: StaticString, line: UInt, column: UInt) {
        self.file = file
        self.function = function
        self.line = line
        self.column = column
    }
}

extension LogSource: Equatable {
    public static func == (lhs: LogSource, rhs: LogSource) -> Bool {
        guard lhs.column == rhs.column else { return false }
        guard lhs.line == rhs.line else { return false }
        guard String(describing: lhs.function) == String(describing: rhs.function) else { return false }
        guard String(describing: lhs.file) == String(describing: rhs.file) else { return false }
        return true
    }
}

extension LogSource: CustomStringConvertible {
    public var description: String {
        return "\(file):\(line).\(column) \(function)"
    }
}

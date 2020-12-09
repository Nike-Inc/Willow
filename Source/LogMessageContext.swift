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

public struct LogMessageContext {
    public typealias DeviceVendor = () -> String
    public static var deviceVendor: DeviceVendor? = nil
    public typealias SessionVendor = () -> String
    public static var sessionVendor: SessionVendor? = nil
    public typealias UserVendor = () -> String
    public static var userVendor: UserVendor? = nil
    
    public let logLevel: LogLevel
    public let timestamp: TimeInterval
    public let file: String
    public let function: String
    public let line: Int
    public let subsystem: String?
    public let category: String?
    public let device: String?
    public let session: String?
    public let user: String?
    
    public init(logLevel: LogLevel, timestamp: TimeInterval, file: String, function: String, line: Int, subsystem: String? = nil, category: String? = nil) {
        self.logLevel = logLevel
        self.timestamp = timestamp
        self.file = file
        self.function = function
        self.line = line
        self.subsystem = subsystem
        self.category = category
        self.device = LogMessageContext.deviceVendor?()
        self.session = LogMessageContext.sessionVendor?()
        self.user = LogMessageContext.userVendor?()
    }
}

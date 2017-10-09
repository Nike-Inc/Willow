//
//  LogWriterTests.swift
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
import os
import Willow
import XCTest

class TestConsoleWriter: ConsoleWriter {
    var codes = [Int]()

    override func writeMessage(_ message: CustomStringConvertible, logLevel: LogLevel) {
        var finalMessage: String = ""
        if let logMessage = message as? LogMessage {
            for (_, value) in logMessage.attributes {
                guard let code = value as? Int else {
                    continue
                }
                codes.append(code)
            }
            finalMessage = "Valid Codes: \(codes.filter { $0 >= 200 && $0 <= 300 })"
        }
        finalMessage += modifyMessage(message, logLevel: logLevel).description

        super.writeMessage(finalMessage as CustomStringConvertible, logLevel: logLevel)
    }
}

class ConsoleWriterTestCase: XCTestCase {
    func testThatConsoleWriterCanBeInitialized() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = ConsoleWriter()

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
    }

    func testThatConsoleWriterCanWriteMessageToConsoleWithPrint() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = ConsoleWriter(method: .print)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
    }

    func testThatConsoleWriterCanWriteMessageToConsoleWithNSLog() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = ConsoleWriter(method: .nslog)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
    }

    struct TestMessage: LogMessage {
        let name: String
        let attributes: [String: Any]

        init(_ name: String = "", attributes: [String: Any] = [:]) {
            self.name = name
            self.attributes = attributes
        }
    }

    func testThatLogMessageAttributesCanBeExposedToWriters() {
        // Given
        let message: LogMessage = TestMessage("testMessage", attributes: ["aCode": 1337, "bCode": 4000, "cCode": 9001, "dCode": 42])
        let logLevel = LogLevel.info
        let writer = TestConsoleWriter(method: .print)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
        XCTAssert(Set(writer.codes) == Set([1337, 4000, 9001, 42]))
    }
}

// MARK: -

class OSLogWriterTestCase: XCTestCase {
    let subsystem = "com.nike.willow.test"
    let category = "os-log-writer"

    func testThatOSLogWriterCanBeInitialized() {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, *) else { return }

        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = OSLogWriter(subsystem: subsystem, category: category)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
    }

    func testThatOSLogWriterCanWriteMessageUsingOSLog() {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, *) else { return }

        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = OSLogWriter(subsystem: subsystem, category: category)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel)
    }
}

class TestModifier: LogModifier {
    public init() {}
    open func modifyMessage(_ message: CustomStringConvertible, with logLevel: LogLevel) -> CustomStringConvertible {
        guard let logMessage = message as? LogMessage else {
            XCTFail()
            return "fail" as CustomStringConvertible
        }
        if logMessage.attributes.keys.contains("pass") {
            return "pass" as CustomStringConvertible
        } else {
            XCTFail()
            return "fail" as CustomStringConvertible
        }
    }
}


//
//  WriterTests.swift
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

import Foundation
import os
import Willow
import XCTest

class ConsoleWriterTestCase: XCTestCase {
    func testThatConsoleWriterCanBeInitializedAndDeinitialized() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        var writer: ConsoleWriter? = ConsoleWriter()

        // When, Then
        writer?.writeMessage(message, logLevel: logLevel, modifiers: [])
        writer = nil

        // Then
        XCTAssertNil(writer)
    }

    func testThatConsoleWriterCanWriteMessageToConsoleWithPrint() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = ConsoleWriter(method: .print)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel, modifiers: [TimestampModifier()])
    }

    func testThatConsoleWriterCanWriteMessageToConsoleWithNSLog() {
        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = ConsoleWriter(method: .nslog)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel, modifiers: [TimestampModifier()])
    }
}

// MARK: -

class OSLogWriterTestCase: XCTestCase {
    let subsystem = "com.nike.willow.test"
    let category = "os-log-writer"

    func testThatOSLogWriterCanBeInitializedAndDeinitialized() {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, *) else { return }

        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        var writer: OSLogWriter? = OSLogWriter(subsystem: subsystem, category: category)

        // When, Then
        writer?.writeMessage(message, logLevel: logLevel, modifiers: [])
        writer = nil

        // Then
        XCTAssertNil(writer)
    }

    func testThatOSLogWriterCanWriteMessageUsingOSLog() {
        guard #available(iOS 10.0, macOS 10.12, tvOS 10.0, *) else { return }

        // Given
        let message = "Test Message"
        let logLevel: LogLevel = .all
        let writer = OSLogWriter(subsystem: subsystem, category: category)

        // When, Then
        writer.writeMessage(message, logLevel: logLevel, modifiers: [TimestampModifier()])
    }
}

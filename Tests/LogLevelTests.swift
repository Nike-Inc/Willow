//
//  LogLevelTests.swift
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
import XCTest

// MARK: Custom Log Levels Using Extensions

extension LogLevel {
    static let verbose = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
    static let summary = LogLevel(rawValue: 0b00000000_00000000_00000010_00000000)
}

extension Logger {
    fileprivate func verbose(message: @autoclosure @escaping () -> CustomStringConvertible) {
        logMessage(message, with: LogLevel.verbose)
    }

    fileprivate func verbose(message: @escaping () -> CustomStringConvertible) {
        logMessage(message, with: LogLevel.verbose)
    }

    fileprivate func summary(message: @autoclosure @escaping () -> CustomStringConvertible) {
        logMessage(message, with: LogLevel.summary)
    }

    fileprivate func summary(message: @escaping () -> CustomStringConvertible) {
        logMessage(message, with: LogLevel.summary)
    }
}

// MARK: - Helper Test Classes

class TestWriter: LogWriter {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: CustomStringConvertible?

    func writeMessage(_ message: CustomStringConvertible, logLevel: LogLevel) {
        self.message = message
        actualNumberOfWrites += 1
    }
}

// MARK: - Test Cases

class LogLevelTestCase: XCTestCase {

    // MARK: Tests

    func testLogLevelHashValues() {
        // Given, When
        let off = LogLevel.off
        let debug = LogLevel.debug
        let info = LogLevel.info
        let event = LogLevel.event
        let warn = LogLevel.warn
        let error = LogLevel.error

        // Then
        XCTAssertEqual(off.hashValue, 0)
        XCTAssertEqual(debug.hashValue, 1)
        XCTAssertEqual(info.hashValue, 2)
        XCTAssertEqual(event.hashValue, 4)
        XCTAssertEqual(warn.hashValue, 8)
        XCTAssertEqual(error.hashValue, 16)
    }

    func testLogLevelDescriptions() {
        // Given, When
        let off = LogLevel.off
        let debug = LogLevel.debug
        let info = LogLevel.info
        let event = LogLevel.event
        let warn = LogLevel.warn
        let error = LogLevel.error
        let all = LogLevel.all
        let unknown = LogLevel(rawValue: 0b00000000_00000000_10000000_00000000)

        // Then
        XCTAssertEqual(off.description, "Off")
        XCTAssertEqual(debug.description, "Debug")
        XCTAssertEqual(info.description, "Info")
        XCTAssertEqual(event.description, "Event")
        XCTAssertEqual(warn.description, "Warn")
        XCTAssertEqual(error.description, "Error")
        XCTAssertEqual(all.description, "All")
        XCTAssertEqual(unknown.description, "Unknown")
    }

    func testLogLevelEquatableConformance() {
        // Given, When
        let off = LogLevel.off
        let debug = LogLevel.debug
        let info = LogLevel.info
        let event = LogLevel.event
        let warn = LogLevel.warn
        let error = LogLevel.error
        let all = LogLevel.all

        // Then
        XCTAssertEqual(off, off)
        XCTAssertEqual(debug, debug)
        XCTAssertEqual(info, info)
        XCTAssertEqual(event, event)
        XCTAssertEqual(warn, warn)
        XCTAssertEqual(error, error)
        XCTAssertEqual(all, all)

        XCTAssertNotEqual(off, debug)
        XCTAssertNotEqual(off, info)
        XCTAssertNotEqual(off, event)
        XCTAssertNotEqual(off, warn)
        XCTAssertNotEqual(off, error)
        XCTAssertNotEqual(off, all)

        XCTAssertNotEqual(debug, info)
        XCTAssertNotEqual(debug, event)
        XCTAssertNotEqual(debug, warn)
        XCTAssertNotEqual(debug, error)
        XCTAssertNotEqual(debug, all)

        XCTAssertNotEqual(info, event)
        XCTAssertNotEqual(info, warn)
        XCTAssertNotEqual(info, error)
        XCTAssertNotEqual(info, all)

        XCTAssertNotEqual(event, warn)
        XCTAssertNotEqual(event, error)
        XCTAssertNotEqual(event, all)

        XCTAssertNotEqual(warn, error)
        XCTAssertNotEqual(warn, all)

        XCTAssertNotEqual(error, all)
    }
}

// MARK: -

class CustomLogLevelTestCase: XCTestCase {

    // MARK: Tests

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .all)

        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.debug { "debug message" }
        XCTAssertEqual("debug message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.info { "info message" }
        XCTAssertEqual("info message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.event { "event message" }
        XCTAssertEqual("event message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.error { "error message" }
        XCTAssertEqual("error message", writer.message?.description ?? "", "Expected message should match actual writer message")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 7, "Actual number of writes should be 7")
    }

    func testThatItLogsAsExpectedWithOrdLogLevels() {
        // Given
        let logLevels: LogLevel = [LogLevel.verbose, LogLevel.info, LogLevel.summary, LogLevel.warn]
        let (log, writer) = logger(logLevels: logLevels)

        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.debug { "debug message" }
        XCTAssertEqual("verbose message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.info { "info message" }
        XCTAssertEqual("info message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.event { "event message" }
        XCTAssertEqual("summary message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message?.description ?? "", "Expected message should match actual writer message")

        log.error { "error message" }
        XCTAssertEqual("warn message", writer.message?.description ?? "", "Expected message should match actual writer message")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 4, "Actual number of writes should be 4")
    }

    // MARK: Private - Helper Methods

    func logger(logLevels: LogLevel) -> (Logger, TestWriter) {
        let writer = TestWriter()
        let logger = Logger(logLevels: logLevels, writers: [writer])

        return (logger, writer)
    }
}

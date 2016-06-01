//
//  LogLevelTests.swift
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
import Willow
import XCTest

// MARK: Custom Log Levels Using Extensions

extension LogLevel {
    static let Verbose = LogLevel(rawValue: 0b00000000_00000000_00000001_00000000)
    static let Summary = LogLevel(rawValue: 0b00000000_00000000_00000010_00000000)
}

extension Logger {
    private func verbose(message: () -> String) {
        logMessage(message, withLogLevel: .Verbose)
    }

    private func summary(message: () -> String) {
        logMessage(message, withLogLevel: .Summary)
    }
}

// MARK: - Helper Test Classes

class TestWriter: Writer {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?

    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        self.message = message
        actualNumberOfWrites += 1
    }
}

// MARK: - Test Cases

class CustomLogLevelTestCase: XCTestCase {

    // MARK: Tests

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .All)

        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")

        log.debug { "debug message" }
        XCTAssertEqual("debug message", writer.message ?? "", "Expected message should match actual writer message")

        log.info { "info message" }
        XCTAssertEqual("info message", writer.message ?? "", "Expected message should match actual writer message")

        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")

        log.event { "event message" }
        XCTAssertEqual("event message", writer.message ?? "", "Expected message should match actual writer message")

        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")

        log.error { "error message" }
        XCTAssertEqual("error message", writer.message ?? "", "Expected message should match actual writer message")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 7, "Actual number of writes should be 7")
    }

    func testThatItLogsAsExpectedWithOrdLogLevels() {
        // Given
        let logLevel: LogLevel = [LogLevel.Verbose, LogLevel.Info, LogLevel.Summary, LogLevel.Warn]
        let (log, writer) = logger(logLevel: logLevel)

        // When / Then
        log.verbose { "verbose message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")

        log.debug { "debug message" }
        XCTAssertEqual("verbose message", writer.message ?? "", "Expected message should match actual writer message")

        log.info { "info message" }
        XCTAssertEqual("info message", writer.message ?? "", "Expected message should match actual writer message")

        log.summary { "summary message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")

        log.event { "event message" }
        XCTAssertEqual("summary message", writer.message ?? "", "Expected message should match actual writer message")

        log.warn { "warn message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")

        log.error { "error message" }
        XCTAssertEqual("warn message", writer.message ?? "", "Expected message should match actual writer message")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 4, "Actual number of writes should be 4")
    }

    // MARK: Private - Helper Methods

    func logger(logLevel logLevel: LogLevel) -> (Logger, TestWriter) {
        let writer = TestWriter()

        let configuration = LoggerConfiguration(writers: [logLevel: [writer]])
        let logger = Logger(configuration: configuration)

        return (logger, writer)
    }
}

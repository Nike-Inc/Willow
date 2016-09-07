//
//  LoggerTests.swift
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

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

// MARK: Helper Test Classes

class SynchronousTestWriter: Writer {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var formattedMessages = [String]()

    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        var mutableMessage = message

        if let formatters = formatters {
            formatters.forEach { mutableMessage = $0.formatMessage(mutableMessage, logLevel: logLevel) }
            formattedMessages.append(mutableMessage)
        }

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }
}

// MARK: -

class AsynchronousTestWriter: SynchronousTestWriter {
    let expectation: XCTestExpectation
    private let expectedNumberOfWrites: Int

    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
    }

    override func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        super.writeMessage(message, logLevel: logLevel, formatters: formatters)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }
}

// MARK: -

class PrefixFormatter: Formatter {
    func formatMessage(message: String, logLevel: LogLevel) -> String {
        return "[Willow] \(message)"
    }
}

// MARK: - Base Test Cases

class SynchronousLoggerTestCase: XCTestCase {
    var message = "Test Message"
    let timeout = 0.1

    func logger(
        logLevel logLevel: LogLevel = .All,
        formatters: [LogLevel: [Formatter]] = [:]) -> (Logger, SynchronousTestWriter)
    {
        let writer = SynchronousTestWriter()

        let configuration = LoggerConfiguration(formatters: formatters, writers: [logLevel: [writer]])
        let logger = Logger(configuration: configuration)

        return (logger, writer)
    }

    func logger(writers writers: [LogLevel: [Writer]] = [:]) -> (Logger) {
        let configuration = LoggerConfiguration(writers: writers)
        let logger = Logger(configuration: configuration)

        return logger
    }
}

// MARK: -

class AsynchronousLoggerTestCase: SynchronousLoggerTestCase {
    func logger(
        logLevel logLevel: LogLevel = .Debug,
        formatters: [LogLevel: [Formatter]] = [:],
        expectedNumberOfWrites: Int = 1) -> (Logger, AsynchronousTestWriter)
    {
        let expectation = expectationWithDescription("Test writer should receive expected number of writes")
        let writer = AsynchronousTestWriter(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites)
        let queue = dispatch_queue_create("async-logger-test-queue", DISPATCH_QUEUE_SERIAL)

        let configuration = LoggerConfiguration(
            formatters: formatters,
            writers: [logLevel: [writer]],
            executionMethod: .Asynchronous(queue: queue)
        )

        let logger = Logger(configuration: configuration)

        return (logger, writer)
    }
}

// MARK: - Tests

class SynchronousLoggerLogLevelTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: LogLevel.Off)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 0, "Actual number of writes should be 0")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Debug)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Info)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Event)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Warn)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Error)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .All)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevel: LogLevel = [LogLevel.Debug, LogLevel.Event, LogLevel.Error]
        let (log, writer) = logger(logLevel: logLevel)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 3, "Actual number of writes should be 3")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, writer) = logger(logLevel: .All)

        // When
        log.debug {
            log.debug { "" }
            return ""
        }

        log.info {
            log.info { "" }
            return ""
        }

        log.event {
            log.event { "" }
            return ""
        }

        log.warn {
            log.warn { "" }
            return ""
        }

        log.error {
            log.error { "" }
            return ""
        }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 10, "Actual number of writes should be 10")
    }

    func testThatItLogsAsExpectedWithAutoclosureDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Debug)

        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Info)

        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Event)

        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Warn)

        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Error)

        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
}

// MARK: -

class AsynchronousLoggerLogLevelTestCase: AsynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Off, expectedNumberOfWrites: 0)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.075 * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            writer.expectation.fulfill()
        }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Debug, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Info, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Event, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Warn, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .Error, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevel: LogLevel = [LogLevel.Event, LogLevel.Warn, LogLevel.Error]
        let (log, writer) = logger(logLevel: logLevel, expectedNumberOfWrites: 3)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, writer) = logger(logLevel: .All, expectedNumberOfWrites: 10)

        // When
        log.debug {
            log.debug { "" }
            return ""
        }

        log.info {
            log.info { "" }
            return ""
        }

        log.event {
            log.event { "" }
            return ""
        }

        log.warn {
            log.warn { "" }
            return ""
        }

        log.error {
            log.error { "" }
            return ""
        }

        waitForExpectationsWithTimeout(timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites)
    }
}

// MARK: -

class SynchronousLoggerEnabledTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAllLogLevelsWhenEnabled() {
        // Given
        let (log, writer) = logger(logLevel: .All)
        log.enabled = true

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be equal to 5")
    }

    func testThatNoLoggingOccursForAnyLogLevelWhenDisabled() {
        // Given
        let (log, writer) = logger(logLevel: .All)
        log.enabled = false

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 0, "Actual number of writes should be equal to 0")
    }
}

// MARK: -

class SynchronousLoggerMultiFormatterTestCase: SynchronousLoggerTestCase {
    private struct SymbolFormatter: Formatter {
        func formatMessage(message: String, logLevel: LogLevel) -> String {
            return "+=+-+ \(message)"
        }
    }

    func testThatItLogsOutputAsExpectedWithMultipleFormatters() {
        // Given
        let formatters: [LogLevel: [Formatter]] = [.All: [PrefixFormatter(), SymbolFormatter()]]
        let (log, writer) = logger(formatters: formatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 5, "Formatted message count should be 5")

        let expected = "+=+-+ [Willow] Test Message"
        writer.formattedMessages.forEach { XCTAssertEqual($0, expected) }
    }
}

// MARK: -

class SynchronousLoggerMultiWriterTestCase: SynchronousLoggerTestCase {
    func testThatItLogsOutputAsExpectedWithMultipleWriters() {
        // Given
        let writer1 = SynchronousTestWriter()
        let writer2 = SynchronousTestWriter()
        let writer3 = SynchronousTestWriter()

        let writers: [LogLevel: [Writer]] = [
            .All: [writer1],
            .Debug: [writer2],
            [.Debug, .Event, .Error]: [writer3]
        ]

        let log = logger(writers: writers)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer1.actualNumberOfWrites, 5, "writer 1 actual number of writes should be 5")
        XCTAssertEqual(writer2.actualNumberOfWrites, 1, "writer 2 actual number of writes should be 1")
        XCTAssertEqual(writer3.actualNumberOfWrites, 3, "writer 3 actual number of writes should be 3")
    }
}

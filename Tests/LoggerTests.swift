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

// MARK: Test Helpers

class SynchronousTestWriter: LogMessageWriter {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var modifiedMessages = [String]()

    func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?) {
        var mutableMessage = message

        if let modifiers = modifiers {
            modifiers.forEach { mutableMessage = $0.modifyMessage(mutableMessage, with: logLevel) }
            modifiedMessages.append(mutableMessage)
        }

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }
}

// MARK:

class AsynchronousTestWriter: SynchronousTestWriter {
    let expectation: XCTestExpectation
    private let expectedNumberOfWrites: Int

    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
    }

    override func writeMessage(_ message: String, logLevel: LogLevel, modifiers: [LogMessageModifier]?) {
        super.writeMessage(message, logLevel: logLevel, modifiers: modifiers)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }
}

// MARK:

class PrefixModifier: LogMessageModifier {
    func modifyMessage(_ message: String, with: LogLevel) -> String {
        return "[Willow] \(message)"
    }
}

// MARK:
// MARK: Base Test Cases

class SynchronousLoggerTestCase: XCTestCase {
    var message = "Test Message"
    let timeout = 0.1

    func logger(logLevel: LogLevel = .all, modifiers: [LogLevel: [LogMessageModifier]] = [:]) -> (Logger, SynchronousTestWriter) {
        let writer = SynchronousTestWriter()

        let configuration = LoggerConfiguration(modifiers: modifiers, writers: [logLevel: [writer]])
        let logger = Logger(configuration: configuration)

        return (logger, writer)
    }

    func logger(writers: [LogLevel: [LogMessageWriter]] = [:]) -> (Logger) {
        let configuration = LoggerConfiguration(writers: writers)
        let logger = Logger(configuration: configuration)

        return logger
    }
}

// MARK:

class AsynchronousLoggerTestCase: SynchronousLoggerTestCase {
    func logger(
        logLevel: LogLevel = .debug,
        modifiers: [LogLevel: [LogMessageModifier]] = [:],
        expectedNumberOfWrites: Int = 1) -> (Logger, AsynchronousTestWriter)
    {
        let expectation = self.expectation(description: "Test writer should receive expected number of writes")
        let writer = AsynchronousTestWriter(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites)
        let queue = DispatchQueue(label: "async-logger-test-queue", attributes: [.serial, .qosUtility])

        let configuration = LoggerConfiguration(
            modifiers: modifiers,
            writers: [logLevel: [writer]],
            executionMethod: .Asynchronous(queue: queue)
        )

        let logger = Logger(configuration: configuration)

        return (logger, writer)
    }
}

// MARK:
// MARK: Tests

class SynchronousLoggerLogLevelTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .off)

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
        let (log, writer) = logger(logLevel: .debug)

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
        let (log, writer) = logger(logLevel: .info)

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
        let (log, writer) = logger(logLevel: .event)

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
        let (log, writer) = logger(logLevel: .warn)

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
        let (log, writer) = logger(logLevel: .error)

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
        let (log, writer) = logger(logLevel: .all)

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
        let logLevel: LogLevel = [.debug, .event, .error]
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
        let (log, writer) = logger(logLevel: .all)

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
        let (log, writer) = logger(logLevel: .debug)

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
        let (log, writer) = logger(logLevel: .info)

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
        let (log, writer) = logger(logLevel: .event)

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
        let (log, writer) = logger(logLevel: .warn)

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
        let (log, writer) = logger(logLevel: .error)

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

// MARK:

class AsynchronousLoggerLogLevelTestCase: AsynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .off, expectedNumberOfWrites: 0)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.

        DispatchQueue.main.after(when: .now() + 0.1) {
            writer.expectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .debug, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .info, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .event, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .warn, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevel: .error, expectedNumberOfWrites: 1)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevel: LogLevel = [.event, .warn, .error]
        let (log, writer) = logger(logLevel: logLevel, expectedNumberOfWrites: 3)

        // When
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, writer) = logger(logLevel: .all, expectedNumberOfWrites: 10)

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

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites)
    }
}

// MARK:

class SynchronousLoggerEnabledTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAllLogLevelsWhenEnabled() {
        // Given
        let (log, writer) = logger(logLevel: .all)
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
        let (log, writer) = logger(logLevel: .all)
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

// MARK:

class SynchronousLoggerMultiModifierTestCase: SynchronousLoggerTestCase {
    private struct SymbolModifier: LogMessageModifier {
        func modify(_ message: String, with logLevel: LogLevel) -> String {
            return "+=+-+ \(message)"
        }
    }

    func testThatItLogsOutputAsExpectedWithMultipleModifiers() {
        // Given
        let modifiers: [LogLevel: [LogMessageModifier]] = [.All: [PrefixModifier(), SymbolModifier()]]
        let (log, writer) = logger(modifiers: modifiers)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.modifiedMessages.count, 5, "Formatted message count should be 5")

        let expected = "+=+-+ [Willow] Test Message"
        writer.modifiedMessages.forEach { XCTAssertEqual($0, expected) }
    }
}

// MARK:

class SynchronousLoggerMultiWriterTestCase: SynchronousLoggerTestCase {
    func testThatItLogsOutputAsExpectedWithMultipleWriters() {
        // Given
        let writer1 = SynchronousTestWriter()
        let writer2 = SynchronousTestWriter()
        let writer3 = SynchronousTestWriter()

        let writers: [LogLevel: [LogMessageWriter]] = [
            .all: [writer1],
            .debug: [writer2],
            [.debug, .event, .error]: [writer3]
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

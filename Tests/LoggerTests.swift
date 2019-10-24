//
//  LoggerTests.swift
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
import Willow
import XCTest

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

// MARK: Test Helpers

class SynchronousTestWriter: LogModifierWriter {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var modifiedMessages = [String]()

    let modifiers: [LogModifier]
    var lastMessage: LogMessage?

    init(modifiers: [LogModifier] = []) {
        self.modifiers = modifiers
    }

    func writeMessage(_ message: String, logLevel: LogLevel, logSource: LogSource) {
        var mutableMessage = message

        modifiers.forEach { mutableMessage = $0.modifyMessage(mutableMessage, with: logLevel, at: logSource) }
        modifiedMessages.append(mutableMessage)

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }

    func writeMessage(_ message: LogMessage, logLevel: LogLevel, logSource: LogSource) {
        var mutableMessage = "\(message.name): \(message.attributes)"

        lastMessage = message

        modifiers.forEach { mutableMessage = $0.modifyMessage(mutableMessage, with: logLevel, at: logSource) }
        modifiedMessages.append(mutableMessage)

        self.message = mutableMessage

        actualNumberOfWrites += 1
    }
}

// MARK: -

class AsynchronousTestWriter: SynchronousTestWriter {
    let expectation: XCTestExpectation
    let expectedNumberOfWrites: Int

    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int, modifiers: [LogModifier] = []) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
        super.init(modifiers: modifiers)
    }

    override func writeMessage(_ message: String, logLevel: LogLevel, logSource: LogSource) {
        super.writeMessage(message, logLevel: logLevel, logSource: logSource)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }

    override func writeMessage(_ message: LogMessage, logLevel: LogLevel, logSource: LogSource) {
        super.writeMessage(message, logLevel: logLevel, logSource: logSource)

        if actualNumberOfWrites == expectedNumberOfWrites {
            expectation.fulfill()
        }
    }
}

// MARK: -

class PrefixModifier: LogModifier {
    func modifyMessage(_ message: String, with: LogLevel, at: LogSource) -> String {
        return "[Willow] \(message)"
    }
}

// MARK: - Base Test Cases

class SynchronousLoggerTestCase: XCTestCase {
    var message = "Test Message"
    let timeout = 0.1

    func logger(logLevels: LogLevel = .all, modifiers: [LogModifier] = []) -> (Logger, SynchronousTestWriter) {
        let writer = SynchronousTestWriter(modifiers: modifiers)
        let logger = Logger(logLevels: logLevels, writers: [writer])

        return (logger, writer)
    }

    func logger(writers: [LogWriter] = []) -> (Logger) {
        let logger = Logger(logLevels: [.all], writers: writers)

        return logger
    }
}

// MARK: -

class AsynchronousLoggerTestCase: SynchronousLoggerTestCase {
    func logger(
        logLevels: LogLevel = .debug,
        modifiers: [LogModifier] = [],
        expectedNumberOfWrites: Int = 1) -> (Logger, AsynchronousTestWriter)
    {
        let expectation = self.expectation(description: "Test writer should receive expected number of writes")
        let writer = AsynchronousTestWriter(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites, modifiers: modifiers)
        let queue = DispatchQueue(label: "async-logger-test-queue", qos: .utility)
        let logger = Logger(logLevels: logLevels, writers: [writer], executionMethod: .asynchronous(queue: queue))

        return (logger, writer)
    }
}

// MARK: -

class SynchronousLoggerMultiModifierTestCase: SynchronousLoggerTestCase {
    private struct SymbolModifier: LogModifier {
        func modifyMessage(_ message: String, with logLevel: LogLevel, at logSource: LogSource) -> String {
            return "+=+-+ \(message)"
        }
    }

    func testThatItLogsOutputAsExpectedWithMultipleModifiers() {
        // Given
        let modifiers: [LogModifier] = [PrefixModifier(), SymbolModifier()]
        let (log, writer) = logger(modifiers: modifiers)

        // When
        log.debugMessage { self.message }
        log.infoMessage { self.message }
        log.eventMessage { self.message }
        log.warnMessage { self.message }
        log.errorMessage { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.modifiedMessages.count, 5, "Formatted message count should be 5")

        let expected = "+=+-+ [Willow] Test Message"
        writer.modifiedMessages.forEach { XCTAssertEqual($0, expected) }
    }
}

// MARK: -

class SynchronousLoggerMultiWriterTestCase: SynchronousLoggerTestCase {
    func testThatItLogsOutputAsExpectedWithMultipleWriters() {
        // Given
        let writer1 = SynchronousTestWriter()
        let writer2 = SynchronousTestWriter()
        let writer3 = SynchronousTestWriter()
        let writers = [writer1, writer2, writer3]
        let log = logger(writers: writers)

        // When
        log.debugMessage { self.message }
        log.infoMessage { self.message }
        log.eventMessage { self.message }
        log.warnMessage { self.message }
        log.errorMessage { self.message }

        // Then
        XCTAssertEqual(writer1.actualNumberOfWrites, 5, "writer 1 actual number of writes should be 5")
        XCTAssertEqual(writer2.actualNumberOfWrites, 5, "writer 2 actual number of writes should be 5")
        XCTAssertEqual(writer3.actualNumberOfWrites, 5, "writer 3 actual number of writes should be 5")
    }
}

// MARK: -

class LoggerSourceTestCase: SynchronousLoggerTestCase {
    private class SourceModifier: LogModifier {
        private(set) var logSources: [LogSource] = []

        func modifyMessage(_ message: String, with logLevel: LogLevel, at logSource: LogSource) -> String {
            logSources.append(logSource)
            return message
        }
    }

    private class TestMessage: LogMessage {
        var name: String = "Message Name"
        var attributes: [String : Any] = [:]
    }

    func testThatSourcesAreEqual() {
        // Given
        let source1 = LogSource(file: "File", function: "Function", line: 1, column: 11)
        let source2 = LogSource(file: "File", function: "Function", line: 1, column: 11)

        // When
        let result = source1 == source2

        // Then
        XCTAssertTrue(result, "Comparision should be true for equal sources")
    }

    func testThatSourcesAreNotEqual() {
        // Given
        let baseSource = LogSource(file: "File", function: "Function", line: 0, column: 10)
        let variations = [
            LogSource(file: "Difference", function: "Function", line: 0, column: 10),
            LogSource(file: "File", function: "Difference", line: 0, column: 10),
            LogSource(file: "File", function: "Function", line: 1, column: 10),
            LogSource(file: "File", function: "Function", line: 0, column: 11)
        ]

        // When
        let results = variations.map { $0 == baseSource }

        // Then
        results.enumerated().forEach { XCTAssertFalse($0.element, "Variation at index \($0.offset) should be different to the base source") }
    }

    func testThatStringMessageClosuresPassLogSourcesToTheModifier() {
        // Given
        let sourceModifier = SourceModifier()
        let (log, _) = logger(modifiers: [sourceModifier])
        let logSources = [
            LogSource(file: "DebugFile", function: "DebugFunction", line: 1, column: 11),
            LogSource(file: "InfoFile", function: "InfoFunction", line: 2, column: 12),
            LogSource(file: "EventFile", function: "EventFunction", line: 3, column: 13),
            LogSource(file: "WarnFile", function: "WarnFunction", line: 4, column: 14),
            LogSource(file: "ErrorFile", function: "ErrorFunction", line: 5, column: 15)
        ]

        // When
        log.debugMessage(file: logSources[0].file, function: logSources[0].function, line: logSources[0].line, column: logSources[0].column) { self.message }
        log.infoMessage(file: logSources[1].file, function: logSources[1].function, line: logSources[1].line, column: logSources[1].column) { self.message }
        log.eventMessage(file: logSources[2].file, function: logSources[2].function, line: logSources[2].line, column: logSources[2].column) { self.message }
        log.warnMessage(file: logSources[3].file, function: logSources[3].function, line: logSources[3].line, column: logSources[3].column) { self.message }
        log.errorMessage(file: logSources[4].file, function: logSources[4].function, line: logSources[4].line, column: logSources[4].column) { self.message }

        // Then
        XCTAssertEqual(sourceModifier.logSources, logSources, "Actual sources should be equal to provided log sources")
    }

    func testThatStringMessagesPassLogSourcesToTheModifier() {
        // Given
        let sourceModifier = SourceModifier()
        let (log, _) = logger(modifiers: [sourceModifier])
        let logSources = [
            LogSource(file: "Debug", function: "Debug", line: 21, column: 31),
            LogSource(file: "Info", function: "Info", line: 22, column: 32),
            LogSource(file: "Event", function: "Event", line: 23, column: 33),
            LogSource(file: "Warn", function: "Warn", line: 24, column: 34),
            LogSource(file: "Error", function: "Error", line: 25, column: 35)
        ]

        // When
        log.debugMessage(file: logSources[0].file, function: logSources[0].function, line: logSources[0].line, column: logSources[0].column, self.message)
        log.infoMessage(file: logSources[1].file, function: logSources[1].function, line: logSources[1].line, column: logSources[1].column, self.message)
        log.eventMessage(file: logSources[2].file, function: logSources[2].function, line: logSources[2].line, column: logSources[2].column, self.message)
        log.warnMessage(file: logSources[3].file, function: logSources[3].function, line: logSources[3].line, column: logSources[3].column, self.message)
        log.errorMessage(file: logSources[4].file, function: logSources[4].function, line: logSources[4].line, column: logSources[4].column, self.message)

        // Then
        XCTAssertEqual(sourceModifier.logSources, logSources, "Actual sources should be equal to provided log sources")
    }

    func testThatLogMessageClosuresPassLogSourcesToTheModifier() {
        // Given
        let testMessage = TestMessage()
        let sourceModifier = SourceModifier()
        let (log, _) = logger(modifiers: [sourceModifier])
        let logSources = [
            LogSource(file: "DebugFile", function: "DebugFunction", line: 1, column: 11),
            LogSource(file: "InfoFile", function: "InfoFunction", line: 2, column: 12),
            LogSource(file: "EventFile", function: "EventFunction", line: 3, column: 13),
            LogSource(file: "WarnFile", function: "WarnFunction", line: 4, column: 14),
            LogSource(file: "ErrorFile", function: "ErrorFunction", line: 5, column: 15)
        ]

        // When
        log.debug(file: logSources[0].file, function: logSources[0].function, line: logSources[0].line, column: logSources[0].column) { testMessage }
        log.info(file: logSources[1].file, function: logSources[1].function, line: logSources[1].line, column: logSources[1].column) { testMessage }
        log.event(file: logSources[2].file, function: logSources[2].function, line: logSources[2].line, column: logSources[2].column) { testMessage }
        log.warn(file: logSources[3].file, function: logSources[3].function, line: logSources[3].line, column: logSources[3].column) { testMessage }
        log.error(file: logSources[4].file, function: logSources[4].function, line: logSources[4].line, column: logSources[4].column) { testMessage }

        // Then
        XCTAssertEqual(sourceModifier.logSources, logSources, "Actual sources should be equal to provided log sources")
    }

    func testThatLogMessagesPassLogSourcesToTheModifier() {
        // Given
        let testMessage = TestMessage()
        let sourceModifier = SourceModifier()
        let (log, _) = logger(modifiers: [sourceModifier])
        let logSources = [
            LogSource(file: "Debug", function: "Debug", line: 21, column: 31),
            LogSource(file: "Info", function: "Info", line: 22, column: 32),
            LogSource(file: "Event", function: "Event", line: 23, column: 33),
            LogSource(file: "Warn", function: "Warn", line: 24, column: 34),
            LogSource(file: "Error", function: "Error", line: 25, column: 35)
        ]

        // When
        log.debug(file: logSources[0].file, function: logSources[0].function, line: logSources[0].line, column: logSources[0].column, testMessage)
        log.info(file: logSources[1].file, function: logSources[1].function, line: logSources[1].line, column: logSources[1].column, testMessage)
        log.event(file: logSources[2].file, function: logSources[2].function, line: logSources[2].line, column: logSources[2].column, testMessage)
        log.warn(file: logSources[3].file, function: logSources[3].function, line: logSources[3].line, column: logSources[3].column, testMessage)
        log.error(file: logSources[4].file, function: logSources[4].function, line: logSources[4].line, column: logSources[4].column, testMessage)

        // Then
        XCTAssertEqual(sourceModifier.logSources, logSources, "Actual sources should be equal to provided log sources")
    }
}


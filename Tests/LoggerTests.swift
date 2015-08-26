//
//  LoggerTests.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Willow
import XCTest

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

// MARK: Helper Test Classes

class SynchronousTestWriter: Writer {
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var formattedMessages = [String]()

    func writeMessage(var message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        if let formatters = formatters {
            formatters.forEach { message = $0.formatMessage(message, logLevel: logLevel) }
            self.formattedMessages.append(message)
        }

        self.message = message

        ++self.actualNumberOfWrites
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

        if self.actualNumberOfWrites == self.expectedNumberOfWrites {
            self.expectation.fulfill()
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
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"

    let purpleColor = Color(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
    let blueColor = Color(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
    let greenColor = Color(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    let orangeColor = Color(red: 233.0 / 255.0, green: 165.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0)
    let redColor = Color(red: 230.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)

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

        let configuration = LoggerConfiguration(formatters: formatters, writers: [logLevel: [writer]], asynchronous: true)
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

class SynchronousLoggerColorFormatterTestCase: SynchronousLoggerTestCase {
    func testThatItAppliesCorrectColorFormatterToDebugLogLevel() {
        // Given
        let colorFormatters: [LogLevel: [Formatter]] = [
            .Debug: [ColorFormatter(foregroundColor: purpleColor, backgroundColor: blueColor)]
        ]

        let (log, writer) = logger(formatters: colorFormatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 1, "Color message count should be 1")

        if writer.formattedMessages.count == 1 {
            let actual = writer.formattedMessages[0]
            let expected = "\(escape)fg153,63,255;\(escape)bg45,145,255;Test Message\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
    }

    func testThatItAppliesCorrectColorFormatterToInfoLogLevel() {
        // Given
        let colorFormatters: [LogLevel: [Formatter]] = [
            .Info: [ColorFormatter(foregroundColor: greenColor, backgroundColor: orangeColor)]
        ]

        let (log, writer) = logger(formatters: colorFormatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 1, "Color message count should be 1")

        if writer.formattedMessages.count == 1 {
            let actual = writer.formattedMessages[0]
            let expected = "\(escape)fg136,207,8;\(escape)bg233,165,47;Test Message\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
    }

    func testThatItAppliesCorrectColorFormatterToEventLogLevel() {
        // Given
        let colorFormatters: [LogLevel: [Formatter]] = [
            .Event: [ColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)]
        ]

        let (log, writer) = logger(formatters: colorFormatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 1, "Color message count should be 1")

        if writer.formattedMessages.count == 1 {
            let actual = writer.formattedMessages[0]
            let expected = "\(escape)fg230,20,20;\(escape)bg153,63,255;Test Message\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
    }

    func testThatItAppliesCorrectColorFormatterToWarnLogLevel() {
        // Given
        let colorFormatters: [LogLevel: [Formatter]] = [
            LogLevel.Warn: [ColorFormatter(foregroundColor: blueColor, backgroundColor: greenColor)]
        ]

        let (log, writer) = logger(formatters: colorFormatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 1, "Color message count should be 1")

        if writer.formattedMessages.count == 1 {
            let actual = writer.formattedMessages[0]
            let expected = "\(escape)fg45,145,255;\(escape)bg136,207,8;Test Message\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
    }

    func testThatItAppliesCorrectColorFormatterToErrorLogLevel() {
        // Given
        let colorFormatters: [LogLevel: [Formatter]] = [
            .Error: [ColorFormatter(foregroundColor: purpleColor, backgroundColor: redColor)]
        ]

        let (log, writer) = logger(formatters: colorFormatters)

        // When
        log.debug { self.message }
        log.info { self.message }
        log.event { self.message }
        log.warn { self.message }
        log.error { self.message }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
        XCTAssertEqual(writer.formattedMessages.count, 1, "Color message count should be 1")

        if writer.formattedMessages.count == 1 {
            let actual = writer.formattedMessages[0]
            let expected = "\(escape)fg153,63,255;\(escape)bg230,20,20;Test Message\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
    }
}

// MARK: -

class SynchronousLoggerMultiFormatterTestCase: SynchronousLoggerTestCase {
    func testThatItLogsOutputAsExpectedWithMultipleFormatters() {
        // Given
        let prefixFormatter = PrefixFormatter()
        let formatters: [LogLevel: [Formatter]] = [
            .Debug: [prefixFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.blueColor)],
            .Info: [prefixFormatter, ColorFormatter(foregroundColor: self.greenColor, backgroundColor: self.orangeColor)],
            .Event: [prefixFormatter, ColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)],
            .Warn: [prefixFormatter, ColorFormatter(foregroundColor: self.blueColor, backgroundColor: self.greenColor)],
            .Error: [prefixFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.redColor)]
        ]

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

        let message = "[Willow] Test Message"

        if writer.formattedMessages.count == 5 {
            var actual = writer.formattedMessages[0]
            var expected = "\(escape)fg153,63,255;\(escape)bg45,145,255;\(message)\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")

            actual = writer.formattedMessages[1]
            expected = "\(escape)fg136,207,8;\(escape)bg233,165,47;\(message)\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")

            actual = writer.formattedMessages[2]
            expected = "\(escape)fg230,20,20;\(escape)bg153,63,255;\(message)\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")

            actual = writer.formattedMessages[3]
            expected = "\(escape)fg45,145,255;\(escape)bg136,207,8;\(message)\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")

            actual = writer.formattedMessages[4]
            expected = "\(escape)fg153,63,255;\(escape)bg230,20,20;\(message)\(reset)"
            XCTAssertEqual(actual, expected, "Failed to apply correct color formatting to message")
        }
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

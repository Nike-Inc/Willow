//
//  LoggerTests.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

import UIKit
import XCTest

import Timber

class TestWriter: Writer {
    
    private let expectation: XCTestExpectation
    private let expectedNumberOfWrites: Int
    
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var formattedMessages = [String]()
    
    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
    }
    
    func writeMessage(var message: String, logLevel: Logger.LogLevel, formatters: [Formatter]?) {
        if let formatters = formatters {
            formatters.map { message = $0.formatMessage(message, logLevel: logLevel) }
            self.formattedMessages.append(message)
        }
        
        self.message = message
        
        ++self.actualNumberOfWrites
        
        if self.actualNumberOfWrites == self.expectedNumberOfWrites {
            self.expectation.fulfill()
        }
    }
}

// MARK: -

class LoggerTestCase: TimberTestCase {
    
    var message = "Test Message"
    let defaultTimeout = 0.1
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"
    
    let purpleColor = UIColor(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
    let blueColor = UIColor(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
    let greenColor = UIColor(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    let orangeColor = UIColor(red: 233.0 / 255.0, green: 165.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0)
    let redColor = UIColor(red: 230.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    
    func logger(
        logLevel: Logger.LogLevel = .Debug,
        formatters: [Logger.LogLevel: [Formatter]]? = nil,
        expectedNumberOfWrites: Int = 1) -> (Logger, TestWriter)
    {
        let expectation = expectationWithDescription("Test writer should receive expected number of writes")
        let writer = TestWriter(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites)
        let logger = Logger(logLevel: logLevel, formatters: formatters, writers: [writer])
        
        return (logger, writer)
    }
}

// MARK: -

class LoggerLogLevelTestCase: LoggerTestCase {
    
    func testThatItLogsAsExpectedWithDebugLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .Debug, expectedNumberOfWrites: 10)
        
        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")

        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
        }
    }
    
    func testThatItLogsAsExpectedWithInfoLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .Info, expectedNumberOfWrites: 8)
        
        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")
        
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
        }
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .Event, expectedNumberOfWrites: 6)
        
        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")
        
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
        }
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .Warn, expectedNumberOfWrites: 4)
        
        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")
        
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
        }
    }
    
    func testThatItLogsAsExpectedWithErrorLogLevel() {
        
        // Given
        let (log, writer) = logger(logLevel: .Error, expectedNumberOfWrites: 2)
        
        // When
        log.debug("")
        log.info("")
        log.event("")
        log.warn("")
        log.error("")
        
        log.debug { "" }
        log.info { "" }
        log.event { "" }
        log.warn { "" }
        log.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
        }
    }
}

// MARK: -

class LoggerColorFormatterTestCase: LoggerTestCase {
    
    func testThatItAppliesCorrectColorFormatterToDebugLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            .Debug: [ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.blueColor)]
        ]
        
        let (log, writer) = logger(formatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.formattedMessages.count, "Color message count should be 1")
            
            if writer.formattedMessages.count == 1 {
                let expected = "\(self.escape)fg153,63,255;\(self.escape)bg45,145,255;Test Message\(self.reset)"
                let actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }

    func testThatItAppliesCorrectColorFormatterToInfoLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            .Info: [ColorFormatter(foregroundColor: self.greenColor, backgroundColor: self.orangeColor)]
        ]
        
        let (log, writer) = logger(formatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.formattedMessages.count, "Color message count should be 1")
            
            if writer.formattedMessages.count == 1 {
                let expected = "\(self.escape)fg136,207,8;\(self.escape)bg233,165,47;Test Message\(self.reset)"
                let actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToEventLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            .Event: [ColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)]
        ]
        
        let (log, writer) = logger(formatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.formattedMessages.count, "Color message count should be 1")
            
            if writer.formattedMessages.count == 1 {
                let expected = "\(self.escape)fg230,20,20;\(self.escape)bg153,63,255;Test Message\(self.reset)"
                let actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToWarnLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            Logger.LogLevel.Warn: [ColorFormatter(foregroundColor: self.blueColor, backgroundColor: self.greenColor)]
        ]
        
        let (log, writer) = logger(formatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.formattedMessages.count, "Color message count should be 1")
            
            if writer.formattedMessages.count == 1 {
                let expected = "\(self.escape)fg45,145,255;\(self.escape)bg136,207,8;Test Message\(self.reset)"
                let actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToErrorLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: [Formatter]] = [
            .Error: [ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.redColor)]
        ]
        
        let (log, writer) = logger(formatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.formattedMessages.count, "Color message count should be 1")
            
            if writer.formattedMessages.count == 1 {
                let expected = "\(self.escape)fg153,63,255;\(self.escape)bg230,20,20;Test Message\(self.reset)"
                let actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
}

// MARK: -

class LoggerMultiFormatterTestCase: LoggerTestCase {
    
    func testThatItAppliesCorrectColorFormatterToDebugLogLevel() {
        
        // Given
        let defaultFormatter = DefaultFormatter()
        let formatters: [Logger.LogLevel: [Formatter]] = [
            .Debug: [defaultFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.blueColor)],
            .Info: [defaultFormatter, ColorFormatter(foregroundColor: self.greenColor, backgroundColor: self.orangeColor)],
            .Event: [defaultFormatter, ColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)],
            .Warn: [defaultFormatter, ColorFormatter(foregroundColor: self.blueColor, backgroundColor: self.greenColor)],
            .Error: [defaultFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.redColor)]
        ]
        
        let (log, writer) = logger(formatters: formatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(5, writer.formattedMessages.count, "Formatted message count should be 5")
            
            let message = "2015-01-19 02:20:17.754 [Info] Test Message"
            
            if writer.formattedMessages.count == 5 {
                var expected = "\(self.escape)fg153,63,255;\(self.escape)bg45,145,255;2014-10-03 08:20:45.000 [Debug] Test Message\(self.reset)"
                var actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg136,207,8;\(self.escape)bg233,165,47;2014-10-03 08:20:45.000 [Info] Test Message\(self.reset)"
                actual = writer.formattedMessages[1]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg230,20,20;\(self.escape)bg153,63,255;2014-10-03 08:20:45.000 [Event] Test Message\(self.reset)"
                actual = writer.formattedMessages[2]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg45,145,255;\(self.escape)bg136,207,8;2014-10-03 08:20:45.000 [Warn] Test Message\(self.reset)"
                actual = writer.formattedMessages[3]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg153,63,255;\(self.escape)bg230,20,20;2014-10-03 08:20:45.000 [Error] Test Message\(self.reset)"
                actual = writer.formattedMessages[4]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
}

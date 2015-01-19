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

class TestWriter: ColorWriter {
    private let expectation: XCTestExpectation
    private let expectedNumberOfWrites: Int
    
    private(set) var actualNumberOfWrites: Int = 0
    private(set) var message: String?
    private(set) var colorMessages = [String]()
    
    init(expectation: XCTestExpectation, expectedNumberOfWrites: Int) {
        self.expectation = expectation
        self.expectedNumberOfWrites = expectedNumberOfWrites
    }
    
    func writeMessage(message: String) {
        self.message = message
        ++self.actualNumberOfWrites
        
        if self.actualNumberOfWrites == self.expectedNumberOfWrites {
            self.expectation.fulfill()
        }
    }
    
    func writeMessage(message: String, colorFormatter: ColorFormatter) {
        self.colorMessages.append(colorFormatter.applyColorFormattingToMessage(message))
        
        ++self.actualNumberOfWrites
        
        if self.actualNumberOfWrites == self.expectedNumberOfWrites {
            self.expectation.fulfill()
        }
    }
}

class LoggerTestCase: XCTestCase {
    
    // MARK: - Private Properties
    
    var message = ""
    let defaultTimeout = 0.1
    let loggerName = "timber-logger-tests"
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"
    
    let purpleColor = UIColor(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
    let blueColor = UIColor(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
    let greenColor = UIColor(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    let orangeColor = UIColor(red: 233.0 / 255.0, green: 165.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0)
    let redColor = UIColor(red: 230.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        self.message = "Test Message"
        
        let calendar = NSCalendar.currentCalendar()
        
        var components = NSDateComponents()
        components.year = 2014
        components.month = 10
        components.day = 3
        components.hour = 8
        components.minute = 20
        components.second = 45
        
        let frozenDate = calendar.dateFromComponents(components)
        
        TUDelorean.freeze(frozenDate)
    }
    
    override func tearDown() {
        TUDelorean.backToThePresent()
    }

    // MARK: - Helper Methods
    
    func logger(
        logLevel: Logger.LogLevel = .Debug,
        printTimestamp: Bool = false,
        printLogLevel: Bool = false,
        timestampFormatter: NSDateFormatter? = nil,
        colorFormatters: [Logger.LogLevel: ColorFormatter]? = nil,
        expectedNumberOfWrites: Int = 1) -> (Logger, TestWriter)
    {
        let expectation = expectationWithDescription("Test writer should receive expected number of writes")
        let writer = TestWriter(expectation: expectation, expectedNumberOfWrites: expectedNumberOfWrites)
        let logger = Logger(
            name: self.loggerName,
            logLevel: logLevel,
            printTimestamp: printTimestamp,
            printLogLevel: printLogLevel,
            timestampFormatter: timestampFormatter,
            colorFormatters: colorFormatters,
            writers: [writer]
        )
        
        return (logger, writer)
    }
}

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

class LoggerOutputFormatTestCase: LoggerTestCase {
    
    func testThatItFormatsOutputCorrectlyWithNoPrintOptionsEnabled() {

        // Given
        let (log, writer) = logger()
        
        // When
        log.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            
            if let actualMessage = writer.message {
                let expectedMessage = "Test Message"
                XCTAssertEqual(expectedMessage, actualMessage, "Expected message should be equal to actual message")
            } else {
                XCTFail("The writer message should NOT be nil")
            }
        }
    }
    
    func testThatItFormatsOutputCorrectlyWithPrintTimestampEnabled() {
        
        // Given
        let (log, writer) = logger(printTimestamp: true)
        
        // When
        log.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")

            if let actualMessage = writer.message {
                let expectedMessage = "[2014-10-03 08:20:45.000] Test Message"
                XCTAssertEqual(expectedMessage, actualMessage, "Expected message should be equal to actual message")
            } else {
                XCTFail("The writer message should NOT be nil")
            }
        }
    }

    func testThatItFormatsOutputCorrectlyWithPrintLogLevelEnabled() {
        
        // Given
        let (log, writer) = logger(printLogLevel: true)
        
        // When
        log.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            
            if let actualMessage = writer.message {
                let expectedMessage = "[Debug] Test Message"
                XCTAssertEqual(expectedMessage, actualMessage, "Expected message should be equal to actual message")
            } else {
                XCTFail("The writer message should NOT be nil")
            }
        }
    }

    func testThatItFormatsOutputCorrectlyWithAllPrintOptionsEnabled() {
        
        // Given
        let (log, writer) = logger(printTimestamp: true, printLogLevel: true)
        
        // When
        log.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            
            if let actualMessage = writer.message {
                let expectedMessage = "2014-10-03 08:20:45.000 [Debug] Test Message"
                XCTAssertEqual(expectedMessage, actualMessage, "Expected message should be equal to actual message")
            } else {
                XCTFail("The writer message should NOT be nil")
            }
        }
    }

    func testThatItFormatsOutputCorrectlyWithCustomDateFormatters() {
        
        // Given
        let timestampFormatter = NSDateFormatter()
        timestampFormatter.locale = NSLocale.currentLocale()
        timestampFormatter.dateFormat = "yyyy-MM-dd"
        
        let (log, writer) = logger(printTimestamp: true, printLogLevel: true, timestampFormatter: timestampFormatter)
        
        // When
        log.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            
            if let actualMessage = writer.message {
                let expectedMessage = "2014-10-03 [Debug] Test Message"
                XCTAssertEqual(expectedMessage, actualMessage, "Expected message should be equal to actual message")
            } else {
                XCTFail("The writer message should NOT be nil")
            }
        }
    }
}

class LoggerColorFormatterTestCase: LoggerTestCase {
    
    func testThatItAppliesCorrectColorFormatterToDebugLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: ColorFormatter] = [
            .Debug: XcodeColorsColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.blueColor)
        ]
        
        let (log, writer) = logger(colorFormatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.colorMessages.count, "Color message count should be 1")
            
            if writer.colorMessages.count == 1 {
                let expected = "\(self.escape)fg153,63,255;\(self.escape)bg45,145,255;Test Message\(self.reset)"
                let actual = writer.colorMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }

    func testThatItAppliesCorrectColorFormatterToInfoLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: ColorFormatter] = [
            .Info: XcodeColorsColorFormatter(foregroundColor: self.greenColor, backgroundColor: self.orangeColor)
        ]
        
        let (log, writer) = logger(colorFormatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.colorMessages.count, "Color message count should be 1")
            
            if writer.colorMessages.count == 1 {
                let expected = "\(self.escape)fg136,207,8;\(self.escape)bg233,165,47;Test Message\(self.reset)"
                let actual = writer.colorMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToEventLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: ColorFormatter] = [
            .Event: XcodeColorsColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)
        ]
        
        let (log, writer) = logger(colorFormatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.colorMessages.count, "Color message count should be 1")
            
            if writer.colorMessages.count == 1 {
                let expected = "\(self.escape)fg230,20,20;\(self.escape)bg153,63,255;Test Message\(self.reset)"
                let actual = writer.colorMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToWarnLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: ColorFormatter] = [
            Logger.LogLevel.Warn: XcodeColorsColorFormatter(foregroundColor: self.blueColor, backgroundColor: self.greenColor)
        ]
        
        let (log, writer) = logger(colorFormatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.colorMessages.count, "Color message count should be 1")
            
            if writer.colorMessages.count == 1 {
                let expected = "\(self.escape)fg45,145,255;\(self.escape)bg136,207,8;Test Message\(self.reset)"
                let actual = writer.colorMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    func testThatItAppliesCorrectColorFormatterToErrorLogLevel() {
        
        // Given
        let colorFormatters: [Logger.LogLevel: ColorFormatter] = [
            .Error: XcodeColorsColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.redColor)
        ]
        
        let (log, writer) = logger(colorFormatters: colorFormatters, expectedNumberOfWrites: 5)
        
        // When
        log.debug(self.message)
        log.info(self.message)
        log.event(self.message)
        log.warn(self.message)
        log.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.defaultTimeout) { _ in
            XCTAssertEqual(writer.expectedNumberOfWrites, writer.actualNumberOfWrites, "Expected should match actual number of writes")
            XCTAssertEqual(1, writer.colorMessages.count, "Color message count should be 1")
            
            if writer.colorMessages.count == 1 {
                let expected = "\(self.escape)fg153,63,255;\(self.escape)bg230,20,20;Test Message\(self.reset)"
                let actual = writer.colorMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
    
    /*

    func testThatItAddsColorToErrorLogLevel() {
        
        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        logger.setForegroundColor(self.purpleColor, backgroundColor: self.redColor, forLogLevel: .Error)
        
        // When
        logger.error(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        
        let expected = "\(self.escape)fg153,63,255;\(self.escape)bg230,20,20;Test Message\(self.reset)"
        let actual = mockWriter.message!
        let failureMessage = "Failed to apply color formatting to error log level"
        
        XCTAssertEqual(expected, actual, failureMessage)
    }
    */
    
//    // MARK: - Tester Helper Methods
//    
//    func mockWriterWithExpectation() -> MockWriter {
//        let expectation = expectationWithDescription("mock writer expectation")
//        return MockWriter(expectation: expectation)
//    }
//    
//    func writeMessageCalledWithLogger(logger: Logger) -> Bool {
//        let writer = logger.writer as MockWriter
//        return writer.writeMessageCalled
//    }
//    
//    func loggerWithLogLevel(logLevel: Logger.LogLevel) -> Logger {
//        let logger = Logger(
//            name: self.loggerName,
//            logLevel: logLevel,
//            printTimestamp: true,
//            printLogLevel: true,
//            timestampFormatter: nil,
//            writers: [MockWriter()]
//        )
//        
//        return logger
//    }
//    
//    func expectationLoggerWithLogLevel(logLevel: Logger.LogLevel) -> Logger {
//        let logger = Logger(
//            name: self.loggerName,
//            logLevel: logLevel,
//            printTimestamp: true,
//            printLogLevel: true,
//            timestampFormatter: nil,
//            writers: [mockWriterWithExpectation()]
//        )
//        
//        return logger
//    }
}

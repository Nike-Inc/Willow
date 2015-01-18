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

/*

class LoggerTests: XCTestCase {
    
    // MARK: - Mock Classes
    
    class MockWriter: Writable {
        var message: String?
        var writeMessageCalled = false
        var expectation: XCTestExpectation?
        
        init(expectation: XCTestExpectation? = nil) {
            self.expectation = expectation
        }
        
        func writeMessage(message: String) {
            self.message = message
            self.writeMessageCalled = true
            self.expectation?.fulfill()
        }
    }

    // MARK: - Private Properties
    
    var message = ""
    let writeMessageDelay = 0.1
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
    
    // MARK: - Log Message Tests
    
    func testThatItLogsDebugMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = loggerWithLogLevel(.Info)
        let eventLogger = loggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.debug("")
        debugLogger.debug("")
        infoLogger.debug("")
        eventLogger.debug("")
        warnLogger.debug("")
        errorLogger.debug("")
        offLogger.debug("")
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(infoLogger), "Info logger should not write debug message")
        XCTAssertFalse(writeMessageCalledWithLogger(eventLogger), "Event logger should not write debug message")
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write debug message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write debug message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write debug message")
    }
    
    func testThatItLogsInfoMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = loggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.info("")
        debugLogger.info("")
        infoLogger.info("")
        eventLogger.info("")
        warnLogger.info("")
        errorLogger.info("")
        offLogger.info("")
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(eventLogger), "Event logger should not write info message")
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write info message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write info message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write info message")
    }
    
    func testThatItLogsEventMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.event("")
        debugLogger.event("")
        infoLogger.event("")
        eventLogger.event("")
        warnLogger.event("")
        errorLogger.event("")
        offLogger.event("")
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write event message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write event message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write event message")
    }

    func testThatItLogsWarnMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = expectationLoggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.warn("")
        debugLogger.warn("")
        infoLogger.warn("")
        eventLogger.warn("")
        warnLogger.warn("")
        errorLogger.warn("")
        offLogger.warn("")
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write warn message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write warn message")
    }

    func testThatItLogsErrorMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = expectationLoggerWithLogLevel(.Warn)
        let errorLogger = expectationLoggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.error("")
        debugLogger.error("")
        infoLogger.error("")
        eventLogger.error("")
        warnLogger.error("")
        errorLogger.error("")
        offLogger.error("")
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write error message")
    }
    
    // MARK: - Log Message Closure Tests
    
    func testThatItLogsDebugClosureMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = loggerWithLogLevel(.Info)
        let eventLogger = loggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.debug { "" }
        debugLogger.debug { "" }
        infoLogger.debug { "" }
        eventLogger.debug { "" }
        warnLogger.debug { "" }
        errorLogger.debug { "" }
        offLogger.debug { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(infoLogger), "Info logger should not write debug closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(eventLogger), "Event logger should not write debug closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write debug closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write debug closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write debug closure message")
    }
  
    func testThatItLogsInfoClosureMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = loggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.info { "" }
        debugLogger.info { "" }
        infoLogger.info { "" }
        eventLogger.info { "" }
        warnLogger.info { "" }
        errorLogger.info { "" }
        offLogger.info { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(eventLogger), "Event logger should not write info closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write info closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write info closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write info closure message")
    }

    func testThatItLogsEventClosureMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = loggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.event { "" }
        debugLogger.event { "" }
        infoLogger.event { "" }
        eventLogger.event { "" }
        warnLogger.event { "" }
        errorLogger.event { "" }
        offLogger.event { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(warnLogger), "Warn logger should not write event closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write event closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write event closure message")
    }

    func testThatItLogsWarnClosureMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = expectationLoggerWithLogLevel(.Warn)
        let errorLogger = loggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.warn { "" }
        debugLogger.warn { "" }
        infoLogger.warn { "" }
        eventLogger.warn { "" }
        warnLogger.warn { "" }
        errorLogger.warn { "" }
        offLogger.warn { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(errorLogger), "Error logger should not write warn closure message")
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write warn closure message")
    }

    func testThatItLogsErrorClosureMessages() {
        
        // Given
        let allLogger = expectationLoggerWithLogLevel(.All)
        let debugLogger = expectationLoggerWithLogLevel(.Debug)
        let infoLogger = expectationLoggerWithLogLevel(.Info)
        let eventLogger = expectationLoggerWithLogLevel(.Event)
        let warnLogger = expectationLoggerWithLogLevel(.Warn)
        let errorLogger = expectationLoggerWithLogLevel(.Error)
        let offLogger = loggerWithLogLevel(.Off)
        
        // When
        allLogger.error { "" }
        debugLogger.error { "" }
        infoLogger.error { "" }
        eventLogger.error { "" }
        warnLogger.error { "" }
        errorLogger.error { "" }
        offLogger.error { "" }
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        XCTAssertFalse(writeMessageCalledWithLogger(offLogger), "Off logger should not write error closure message")
    }

    // MARK: - Log Output Tests
    
    func testThatItFormatsOutputCorrectlyWithNoPrintOptionsEnabled() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        // When
        logger.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        XCTAssertEqual("Test Message", mockWriter.message!)
    }
    
    func testThatItFormatsOutputCorrectlyWithPrintTimestampEnabled() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: true,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        // When
        logger.debug(self.message)

        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        XCTAssertEqual("[2014-10-03 08:20:45.000] Test Message", mockWriter.message!)
    }

    func testThatItFormatsOutputCorrectlyWithPrintLogLevelEnabled() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: true,
            writer: mockWriterWithExpectation()
        )
        
        // When
        logger.debug(self.message)

        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        XCTAssertEqual("[Debug] Test Message", mockWriter.message!)
    }

    func testThatItFormatsOutputCorrectlyWithAllPrintOptionsEnabled() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: true,
            printLogLevel: true,
            writer: mockWriterWithExpectation()
        )
        
        // When
        logger.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        XCTAssertEqual("2014-10-03 08:20:45.000 [Debug] Test Message", mockWriter.message!)
    }
    
    func testThatItWorksWithCustomDateFormatters() {

        // Given
        let timestampFormatter = NSDateFormatter()
        timestampFormatter.locale = NSLocale.currentLocale()
        timestampFormatter.dateFormat = "yyyy-MM-dd"
        
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: true,
            printLogLevel: true,
            timestampFormatter: timestampFormatter,
            writer: mockWriterWithExpectation()
        )
        
        // When
        logger.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        XCTAssertEqual("2014-10-03 [Debug] Test Message", mockWriter.message!)
    }
    
    // MARK: - Log Output Color Tests
    
    func testThatItAddsColorToDebugLogLevel() {
        
        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        logger.setForegroundColor(self.purpleColor, backgroundColor: self.blueColor, forLogLevel: .Debug)
        
        // When
        logger.debug(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        
        let expected = "\(self.escape)fg153,63,255;\(self.escape)bg45,145,255;Test Message\(self.reset)"
        let actual = mockWriter.message!
        let failureMessage = "Failed to apply color formatting to debug log level"
        
        XCTAssertEqual(expected, actual, failureMessage)
    }
    
    func testThatItAddsColorToInfoLogLevel() {
        
        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        logger.setForegroundColor(self.greenColor, backgroundColor: self.orangeColor, forLogLevel: .Info)
        
        // When
        logger.info(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        
        let expected = "\(self.escape)fg136,207,8;\(self.escape)bg233,165,47;Test Message\(self.reset)"
        let actual = mockWriter.message!
        let failureMessage = "Failed to apply color formatting to info log level"
        
        XCTAssertEqual(expected, actual, failureMessage)
    }

    func testThatItAddsColorToEventLogLevel() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        logger.setForegroundColor(self.redColor, backgroundColor: self.purpleColor, forLogLevel: .Event)
        
        // When
        logger.event(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        
        let expected = "\(self.escape)fg230,20,20;\(self.escape)bg153,63,255;Test Message\(self.reset)"
        let actual = mockWriter.message!
        let failureMessage = "Failed to apply color formatting to event log level"
        
        XCTAssertEqual(expected, actual, failureMessage)
    }

    func testThatItAddsColorToWarnLogLevel() {

        // Given
        let logger = Logger(
            name: self.loggerName,
            logLevel: .All,
            printTimestamp: false,
            printLogLevel: false,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        logger.setForegroundColor(self.blueColor, backgroundColor: self.greenColor, forLogLevel: .Warn)
        
        // When
        logger.warn(self.message)
        
        // Then
        waitForExpectationsWithTimeout(self.writeMessageDelay, handler: nil)
        let mockWriter = logger.writer as MockWriter
        
        let expected = "\(self.escape)fg45,145,255;\(self.escape)bg136,207,8;Test Message\(self.reset)"
        let actual = mockWriter.message!
        let failureMessage = "Failed to apply color formatting to warn log level"
        
        XCTAssertEqual(expected, actual, failureMessage)
    }

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
    
    // MARK: - Tester Helper Methods
    
    func mockWriterWithExpectation() -> MockWriter {
        let expectation = expectationWithDescription("mock writer expectation")
        return MockWriter(expectation: expectation)
    }
    
    func writeMessageCalledWithLogger(logger: Logger) -> Bool {
        let writer = logger.writer as MockWriter
        return writer.writeMessageCalled
    }
    
    func loggerWithLogLevel(logLevel: Logger.LogLevel) -> Logger {
        let logger = Logger(
            name: self.loggerName,
            logLevel: logLevel,
            printTimestamp: true,
            printLogLevel: true,
            timestampFormatter: nil,
            writer: MockWriter()
        )
        
        return logger
    }
    
    func expectationLoggerWithLogLevel(logLevel: Logger.LogLevel) -> Logger {
        let logger = Logger(
            name: self.loggerName,
            logLevel: logLevel,
            printTimestamp: true,
            printLogLevel: true,
            timestampFormatter: nil,
            writer: mockWriterWithExpectation()
        )
        
        return logger
    }
}

*/

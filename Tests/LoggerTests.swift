//
//  LoggerTests.swift
//
//  Copyright (c) 2015, Christian Noon
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those
//  of the authors and should not be interpreted as representing official policies,
//  either expressed or implied, of the FreeBSD Project.
//

import XCTest
import Timber

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

class TestWriter: Writer {
    
    let expectation: XCTestExpectation
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

class PrefixFormatter: Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        return "[Timber] \(message)"
    }
}

// MARK: -

class LoggerTestCase: XCTestCase {
    
    var message = "Test Message"
    let defaultTimeout = 0.1
    let escape = "\u{001b}["
    let reset = "\u{001b}[;"
    
    let purpleColor = Color(red: 153.0 / 255.0, green: 63.0 / 255.0, blue: 1.0, alpha: 1.0)
    let blueColor = Color(red: 45.0 / 255.0, green: 145.0 / 255.0, blue: 1.0, alpha: 1.0)
    let greenColor = Color(red: 136.0 / 255.0, green: 207.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
    let orangeColor = Color(red: 233.0 / 255.0, green: 165.0 / 255.0, blue: 47.0 / 255.0, alpha: 1.0)
    let redColor = Color(red: 230.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0)
    
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

class LoggerEnabledTestCase: LoggerTestCase {
    
    func testThatItLogsAllLogLevelsWhenEnabled() {
        
        // Given
        let (log, writer) = logger(logLevel: .Debug, expectedNumberOfWrites: 10)
        log.enabled = true
        
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
    
    func testThatNoLoggingOccursForAnyLogLevelWhenDisabled() {

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.
        
        // Given
        let (log, writer) = logger(logLevel: .Error, expectedNumberOfWrites: 0)
        log.enabled = false
        
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
        
        // Fullfill the expectation manually before the timeout occurs
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.075 * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            writer.expectation.fulfill()
        }
        
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
    
    func testThatItLogsOutputAsExpectedWithMultipleFormatters() {
        
        // Given
        let prefixFormatter = PrefixFormatter()
        let formatters: [Logger.LogLevel: [Formatter]] = [
            .Debug: [prefixFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.blueColor)],
            .Info: [prefixFormatter, ColorFormatter(foregroundColor: self.greenColor, backgroundColor: self.orangeColor)],
            .Event: [prefixFormatter, ColorFormatter(foregroundColor: self.redColor, backgroundColor: self.purpleColor)],
            .Warn: [prefixFormatter, ColorFormatter(foregroundColor: self.blueColor, backgroundColor: self.greenColor)],
            .Error: [prefixFormatter, ColorFormatter(foregroundColor: self.purpleColor, backgroundColor: self.redColor)]
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
            
            let message = "[Timber] Test Message"
            
            if writer.formattedMessages.count == 5 {
                var expected = "\(self.escape)fg153,63,255;\(self.escape)bg45,145,255;\(message)\(self.reset)"
                var actual = writer.formattedMessages[0]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg136,207,8;\(self.escape)bg233,165,47;\(message)\(self.reset)"
                actual = writer.formattedMessages[1]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg230,20,20;\(self.escape)bg153,63,255;\(message)\(self.reset)"
                actual = writer.formattedMessages[2]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg45,145,255;\(self.escape)bg136,207,8;\(message)\(self.reset)"
                actual = writer.formattedMessages[3]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")

                expected = "\(self.escape)fg153,63,255;\(self.escape)bg230,20,20;\(message)\(self.reset)"
                actual = writer.formattedMessages[4]
                XCTAssertEqual(expected, actual, "Failed to apply correct color formatting to message")
            }
        }
    }
}

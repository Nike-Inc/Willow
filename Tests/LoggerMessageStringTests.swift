//
//  LoggerMessageStringTests.swift
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

// MARK: - Tests

class SynchronousLoggerLogLevelTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .off)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 0, "Actual number of writes should be 0")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .debug)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .info)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .event)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .warn)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .error)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAllLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .all)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be 5")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.debug, .event, .error]
        let (log, writer) = logger(logLevels: logLevels)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 3, "Actual number of writes should be 3")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, writer) = logger(logLevels: .all)

        // When
        log.debugMessage {
            log.debugMessage { "" }
            return ""
        }

        log.infoMessage {
            log.infoMessage { "" }
            return ""
        }

        log.eventMessage {
            log.eventMessage { "" }
            return ""
        }

        log.warnMessage {
            log.warnMessage { "" }
            return ""
        }

        log.errorMessage {
            log.errorMessage { "" }
            return ""
        }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 10, "Actual number of writes should be 10")
    }

    func testThatItLogsAsExpectedWithAutoclosureDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .debug)

        // When
        log.debugMessage("")
        log.infoMessage("")
        log.eventMessage("")
        log.warnMessage("")
        log.errorMessage("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .info)

        // When
        log.debugMessage("")
        log.infoMessage("")
        log.eventMessage("")
        log.warnMessage("")
        log.errorMessage("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .event)

        // When
        log.debugMessage("")
        log.infoMessage("")
        log.eventMessage("")
        log.warnMessage("")
        log.errorMessage("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .warn)

        // When
        log.debugMessage("")
        log.infoMessage("")
        log.eventMessage("")
        log.warnMessage("")
        log.errorMessage("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }

    func testThatItLogsAsExpectedWithAutoclosureErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .error)

        // When
        log.debugMessage("")
        log.infoMessage("")
        log.eventMessage("")
        log.warnMessage("")
        log.errorMessage("")

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 1, "Actual number of writes should be 1")
    }
}

// MARK: -

class AsynchronousLoggerLogLevelTestCase: AsynchronousLoggerTestCase {
    func testThatItLogsAsExpectedWithOffLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .off, expectedNumberOfWrites: 0)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // This is an interesting test because we have to wait to make sure nothing happened. This makes it
        // very difficult to fullfill the expectation. For now, we are using a dispatch_after that fires
        // slightly before the timeout to fullfill the expectation.

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            writer.expectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithDebugLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .debug, expectedNumberOfWrites: 1)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithInfoLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .info, expectedNumberOfWrites: 1)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithEventLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .event, expectedNumberOfWrites: 1)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithWarnLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .warn, expectedNumberOfWrites: 1)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithErrorLogLevel() {
        // Given
        let (log, writer) = logger(logLevels: .error, expectedNumberOfWrites: 1)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItLogsAsExpectedWithMultipleLogLevels() {
        // Given
        let logLevels: LogLevel = [.event, .warn, .error]
        let (log, writer) = logger(logLevels: logLevels, expectedNumberOfWrites: 3)

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites, "Expected should match actual number of writes")
    }

    func testThatItCanLogMessageInsideAnotherLogStatement() {
        // Given
        let (log, writer) = logger(logLevels: .all, expectedNumberOfWrites: 10)

        // When
        log.debugMessage {
            log.debugMessage { "" }
            return ""
        }

        log.infoMessage {
            log.infoMessage { "" }
            return ""
        }

        log.eventMessage {
            log.eventMessage { "" }
            return ""
        }

        log.warnMessage {
            log.warnMessage { "" }
            return ""
        }

        log.errorMessage {
            log.errorMessage { "" }
            return ""
        }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, writer.expectedNumberOfWrites)
    }
}

// MARK: -

class SynchronousLoggerEnabledTestCase: SynchronousLoggerTestCase {
    func testThatItLogsAllLogLevelsWhenEnabled() {
        // Given
        let (log, writer) = logger(logLevels: .all)
        log.enabled = true

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 5, "Actual number of writes should be equal to 5")
    }

    func testThatNoLoggingOccursForAnyLogLevelWhenDisabled() {
        // Given
        let (log, writer) = logger(logLevels: .all)
        log.enabled = false

        // When
        log.debugMessage { "" }
        log.infoMessage { "" }
        log.eventMessage { "" }
        log.warnMessage { "" }
        log.errorMessage { "" }

        // Then
        XCTAssertEqual(writer.actualNumberOfWrites, 0, "Actual number of writes should be equal to 0")
    }
}


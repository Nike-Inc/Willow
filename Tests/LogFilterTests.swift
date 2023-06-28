//
//  LogWriterTests.swift
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
import os
import Willow
import XCTest

struct TestLogFilter: LogFilter {
    var name: String { "test" }

    func shouldInclude(_ logMessage: LogMessage, level: LogLevel) -> Bool {
        !logMessage.name.contains("EXCLUDE")
    }

    func shouldInclude(_ message: String, level: LogLevel) -> Bool {
        !message.contains("EXCLUDE")
    }
}

class MockWriter: LogWriter {
    var messagesWritten: [String] = []
    var logMessagesWritten: [LogMessage] = []

    func writeMessage(_ message: String, logLevel: LogLevel) {
        messagesWritten.append(message)
    }

    func writeMessage(_ message: LogMessage, logLevel: LogLevel) {
        logMessagesWritten.append(message)
    }
}

class LogFilterTests: XCTestCase {
    var mockWriter: MockWriter!

    override func setUp() {
        mockWriter = MockWriter()
    }

    func testFilterMessages() {
        let logger = Logger(logLevels: .all, writers: [mockWriter])
        logger.addFilter(TestLogFilter())

        logger.infoMessage("message 1")
        logger.infoMessage("message 2 EXCLUDED")

        XCTAssertEqual(mockWriter.messagesWritten.count, 1)
        XCTAssertEqual(mockWriter.messagesWritten.last, "message 1")
    }

    func testRemovingFilters() {
        let logger = Logger(logLevels: .all, writers: [mockWriter])
        logger.addFilter(TestLogFilter())
        logger.removeFilters()
        XCTAssert(logger.filters.isEmpty)

        logger.addFilter(TestLogFilter())
        logger.removeFilter(named: "asdf")
        XCTAssertEqual(logger.filters.count, 1)

        logger.removeFilter(named: "test")
        XCTAssert(logger.filters.isEmpty)
    }
}

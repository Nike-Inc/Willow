//
//  LogFilterTests.swift
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

    let stringToExclude: String

    func shouldInclude(_ logMessage: LogMessage, level: LogLevel) -> Bool {
        !logMessage.name.contains(stringToExclude)
    }

    func shouldInclude(_ message: String, level: LogLevel) -> Bool {
        !message.contains(stringToExclude)
    }
}

struct TestLogFilterByAttributes: LogFilter {
    var name: String { "test2" }

    var excludedGroups: Set<String> = []

    func shouldInclude(_ logMessage: LogMessage, level: LogLevel) -> Bool {
        guard let groupName = logMessage.attributes["group"] as? String else {
            return true
        }

        return !excludedGroups.contains(groupName)
    }

    func shouldInclude(_ message: String, level: LogLevel) -> Bool {
        true // don't have attributes here, so no filter
    }
}

struct GroupedMessage: LogMessage {
    var name: String
    let group: String

    var attributes: [String : Any] {
        [
            "group": group
        ]
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
        logger.addFilter(TestLogFilter(stringToExclude: "EXCLUDE"))

        logger.infoMessage("message 1")
        logger.infoMessage("message 2 EXCLUDED")

        XCTAssertEqual(mockWriter.messagesWritten.count, 1)
        XCTAssertEqual(mockWriter.messagesWritten.last, "message 1")
    }

    func testFilterMessagesByAttributes() {
        let logger = Logger(logLevels: .all, writers: [mockWriter])
        logger.addFilter(TestLogFilterByAttributes(excludedGroups: ["analytics"]))

        logger.info(GroupedMessage(name: "analytics event", group: "analytics"))
        logger.info(GroupedMessage(name: "checkout event", group: "checkout"))

        XCTAssertEqual(mockWriter.logMessagesWritten.count, 1)
        XCTAssertEqual(mockWriter.logMessagesWritten.first?.name, "checkout event")
    }

    func testRemovingFilters() {
        let logger = Logger(logLevels: .all, writers: [mockWriter])
        logger.infoMessage("example 1 FOO") //expected

        logger.addFilter(TestLogFilter(stringToExclude: "FOO"))
        logger.infoMessage("example 2 FOO") // not expected
        XCTAssertFalse(logger.filters.isEmpty)
        logger.removeFilters()
        XCTAssert(logger.filters.isEmpty)
        logger.infoMessage("example 3 FOO") // expected

        logger.addFilter(TestLogFilter(stringToExclude: "..."))
        logger.removeFilter(named: "asdf")
        XCTAssertEqual(logger.filters.count, 1)

        logger.removeFilter(named: "test")
        XCTAssert(logger.filters.isEmpty)

        // assert only expected messages were logged
        let expectedMessages = ["example 1 FOO", "example 3 FOO"]
        XCTAssertEqual(mockWriter.messagesWritten.count, expectedMessages.count)
        expectedMessages.forEach {
            XCTAssert(mockWriter.messagesWritten.contains($0))
        }
    }
}

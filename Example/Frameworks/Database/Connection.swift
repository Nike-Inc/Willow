//
//  Connection.swift
//
//  Copyright (c) 2015-2017 Nike, Inc. (https://www.nike.com)
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

public struct SQLError: Error {
    public let code: Int32
    public var message: String
}

public class Connection {
    public static func makeSQLCall() {
        let sql = "SELECT * FROM MyTable WHERE awesome = true"
        // Make an interesting database call…

        log.sql(Message.sqlQuery(sql: sql))
    }

    public static func makeDebugCall() {
        log.debug(Message.connectionOpened)
    }

    public static func makeInfoCall() {
        log.infoMessage("Making call that logs info message")
    }

    public static func makeEventCall() {
        log.event(Message.backupComplete)
    }

    public static func makeWarnCall() {
        log.warnMessage("Making call that logs warn message")
    }

    public static func makeErrorCall() {
        let sql = "CREATE TABLE cars(make TEXT NOT NULL, model TEXT NOT NULL)"

        do {
            // Do something that can throw
            throw SQLError(code: 5, message: "The database file is locked")
        } catch {
            log.error(Message.sqlFailure(sql: sql, error: error))
        }
    }
}

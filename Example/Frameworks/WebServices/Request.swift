//
//  Request.swift
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

public class Request {
    public static func makeDebugRequest() {
        log.debugMessage("Making request that logs debug message")
    }

    public static func makeInfoRequest() {
        log.infoMessage("Making request that logs info message")
    }

    public static func makeEventRequest() {
        let request = URLRequest(url: URL(string: "http://www.apple.com")!)
        log.event(Message.requestStarted(request: request))

        DispatchQueue.main.async {
            let fakeResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.0", headerFields: nil)!
            log.event(Message.requestCompleted(request: request, response: fakeResponse))
        }
    }

    public static func makeWarnRequest() {
        log.warnMessage("Making request that logs warn message")
    }

    public static func makeErrorRequest() {
        let request = URLRequest(url: URL(string: "http://www.apple.com")!)
        log.event(Message.requestStarted(request: request))

        DispatchQueue.main.async {
            let fakeResponse = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: "1.0", headerFields: nil)!
            log.error(Message.requestFailed(request: request, response: fakeResponse, error: nil))
        }
    }
}

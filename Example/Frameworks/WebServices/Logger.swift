//
//  Logger.swift
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

/// The single `Logger` instance used throughout WebServices.
/// Note that the extension for Optional<Logger> allows for the safe use of `log` without unwrapping.
public var log: Logger?

/// Message type used by the WebServices framework.
/// With this implementation you would have an enum case for each distinct message to be written.
/// Note that where you might have had separate (but similar) strings in the past for messages,
/// you can now consolidate into a single message with attributes now providing unique details
enum Message: Willow.LogMessage {

    case requestStarted(request: URLRequest)
    case requestCompleted(request: URLRequest, response: HTTPURLResponse)
    case requestFailed(request: URLRequest, response: HTTPURLResponse, error: Error?)

    var name: String {
        switch self {
        case .requestStarted:   return "Request started"
        case .requestCompleted: return "Request completed"
        case .requestFailed:    return "Request failed"
        }
    }

    var attributes: [String: Any] {
        var keyPathAttributes: [KeyPath: Any] = [:]
        let success: Bool

        // Fill in message specific attributes
        switch self {
        case let .requestStarted(request):
            keyPathAttributes[.url] = request.url
            success = true

        case let .requestCompleted(request, response):
            keyPathAttributes[.url] = request.url
            keyPathAttributes[.responseCode] = response.statusCode
            success = true

        case let .requestFailed(request, response, error):
            keyPathAttributes[.url] = request.url
            keyPathAttributes[.responseCode] = response.statusCode

            if let error = error {
                keyPathAttributes[.errorDescription] = message(for: error)
                keyPathAttributes[.errorCode] = code(for: error)
            }

            success = false
        }

        // Assign attributes that should be present for all messages
        keyPathAttributes[.frameworkName] = Framework.name
        keyPathAttributes[.frameworkVersion] = Framework.version
        keyPathAttributes[.result] = success ? "success" : "failure"

        // Map to the expected types
        var attributes: [String: Any] = [:]
        keyPathAttributes.forEach { attributes[$0.key.rawValue] = $0.value }

        // MARK: Custom String Convertible

        var description: String {
            return "\(name): \(attributes)"
        }

        return attributes
    }

    /// Information about this framework.
    private enum Framework {
        static let name = "WebServices"

        static let version: String = {
            class Version {}
            return Bundle(for: Version.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        }()
    }

    /// Attribute keys this framework uses.
    private enum KeyPath: String {
        case url                = "url"
        case result             = "result"
        case responseCode       = "response_code"
        case errorDescription   = "error_description"
        case errorCode          = "error_code"
        case frameworkName      = "framework_name"
        case frameworkVersion   = "framework_version"
    }

    private func code(for error: Error) -> Int {
        return (error as NSError).code
    }

    private func message(for error: Error) -> String {
        return (error as NSError).localizedDescription
    }
}

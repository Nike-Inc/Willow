//
//  Logger.swift
//
//  Copyright (c) 2015-2016 Nike, Inc. (https://www.nike.com)
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
import UIKit
import Willow

/// The single `Logger` instance used throughout Network.
public var log: Logger = {
    struct PrefixModifier: Modifier {
        func modifyMessage(_ message: String, with: LogLevel) -> String {
            return "[Network] => \(message)"
        }
    }

    let prefixModifier = PrefixModifier()
    let timestampModifier = TimestampModifier()

    let purple = UIColor(red: 0.600, green: 0.247, blue: 1.000, alpha: 1.0)
    let blue = UIColor(red: 0.176, green: 0.569, blue: 1.000, alpha: 1.0)
    let green = UIColor(red: 0.533, green: 0.812, blue: 0.031, alpha: 1.0)
    let orange = UIColor(red: 0.914, green: 0.647, blue: 0.184, alpha: 1.0)
    let red = UIColor(red: 0.902, green: 0.078, blue: 0.078, alpha: 1.0)

    let debugColorModifier = ColorModifier(foregroundColor: purple, backgroundColor: nil)
    let infoColorModifier = ColorModifier(foregroundColor: blue, backgroundColor: nil)
    let eventColorModifier = ColorModifier(foregroundColor: green, backgroundColor: nil)
    let warnColorModifier = ColorModifier(foregroundColor: orange, backgroundColor: nil)
    let errorColorModifier = ColorModifier(foregroundColor: red, backgroundColor: nil)

    let modifiers: [LogLevel: [Modifier]] = [
        .debug: [prefixModifier, timestampModifier, debugColorModifier],
        .info: [prefixModifier, timestampModifier, infoColorModifier],
        .event: [prefixModifier, timestampModifier, eventColorModifier],
        .warn: [prefixModifier, timestampModifier, warnColorModifier],
        .error: [prefixModifier, timestampModifier, errorColorModifier]
    ]

    let queue = DispatchQueue(label: "com.nike.network.logger.queue", attributes: [.serial, .qosUtility])
    let configuration = LoggerConfiguration(modifiers: modifiers, executionMethod: .Asynchronous(queue: queue))

    return Logger(configuration: configuration)
}()

//
//  Writer.swift
//  Willow
//
//  Created by Christian Noon on 1/18/15.
//  Copyright © 2015 Nike. All rights reserved.
//

import Foundation

// MARK: Writer

/**
    The Writer protocol defines a single API for writing a message. The message can be written in any way the
    conforming object sees fit. For example, it could write to the console, write to a file, remote log to a third
    party service, etc.
*/
public protocol Writer {
    func writeMessage(message: String, logLevel: LogLevel, formatters: [Formatter]?)
}

// MARK: -

/**
    The ConsoleWriter class runs all formatters in the order they were created and prints the resulting message
    to the console.
*/
public class ConsoleWriter: Writer {

    /**
        Initializes a console writer instance.

        - returns: A new console writer instance.
    */
    public init() {}

    /**
        Writes the message to the console using the global `print` function.

        Each formatter is run over the message in the order they are provided before writing the message to
        the console.

        - parameter message:    The original message to write to the console.
        - parameter logLevel:   The log level associated with the message.
        - parameter formatters: The formatter objects to run over the message before writing to the console.
    */
    public func writeMessage(var message: String, logLevel: LogLevel, formatters: [Formatter]?) {
        formatters?.forEach { message = $0.formatMessage(message, logLevel: logLevel) }
        print(message)
    }
}

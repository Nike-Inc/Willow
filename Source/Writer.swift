//
//  Writer.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

// MARK: - Protocols

/**
    The Writer protocol defines a single API for writing a message. The message can be written in any way the
    conforming object sees fit. For example, it could write to the console, write to a file, remote log to a third
    party service, etc.
*/
@objc public protocol Writer {
    func writeMessage(message: String)
}

/**
    The FormatWriter protocol defines a single API for writing a message and is provided a `Formatter`. The
    conforming object can use the formatter API to format the message, then write the message anywhere it wants.
*/
@objc public protocol FormatWriter: Writer {
    func writeMessage(message: String, formatter: Formatter)
}

// MARK: - ConsoleWriter

/**
    The ConsoleWriter class is a simple Writer that prints the message to the console.
*/
public class ConsoleWriter: Writer {
    public func writeMessage(message: String) {
        println(message)
    }
}

// MARK: - ConsoleFormatWriter

/**
    The ConsoleFormatWriter class is a FormatWriter that prints both default and formatted messages to the console.
*/
public class ConsoleFormatWriter: ConsoleWriter, FormatWriter {
    public func writeMessage(var message: String, formatter: Formatter) {
        message = formatter.formatMessage(message)
        println(message)
    }
}

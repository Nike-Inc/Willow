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
    The ColorWriter protocol defines a single API for writing a message and is provided a ColorFormatter. The 
    conforming object can use the color formatter API to apply the coloring to the message, then write the message 
    anywhere it wants.
*/
@objc public protocol ColorWriter: Writer {
    func writeMessage(message: String, colorFormatter: ColorFormatter)
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

// MARK: - ConsoleColorWriter

/**
    The ConsoleColorWriter class is a ColorWriter that prints both colored and non-colored messages to the console.
*/
public class ConsoleColorWriter: ConsoleWriter, ColorWriter {
    public func writeMessage(var message: String, colorFormatter: ColorFormatter) {
        message = colorFormatter.applyColorFormattingToMessage(message)
        println(message)
    }
}

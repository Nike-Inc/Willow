//
//  Writer.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

// MARK: - Protocols

@objc public protocol Writer {
    func writeMessage(message: String)
}

@objc public protocol ColorWriter: Writer {
    func writeMessage(message: String, colorFormatter: ColorFormatter)
}

// MARK: - Internal - ConsoleWriter

class ConsoleWriter: Writer {
    func writeMessage(message: String) {
        println(message)
    }
}

// MARK: - Internal - ConsoleColorWriter

class ConsoleColorWriter: ConsoleWriter, ColorWriter {
    func writeMessage(var message: String, colorFormatter: ColorFormatter) {
        message = colorFormatter.applyColorFormattingToMessage(message)
        println(message)
    }
}

//
//  Writer.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

// MARK: - Protocols

@objc public protocol Writable {
    func writeMessage(message: String)
}

@objc public protocol Colorable: Writable {
    func writeMessage(message: String, colorProfile: ColorProfile)
}

// MARK: - Internal - ConsoleWriter

class ConsoleWriter: Writable {
    func writeMessage(message: String) {
        println(message)
    }
}

// MARK: - Internal - ConsoleColorWriter

class ConsoleColorWriter: ConsoleWriter, Colorable {
    func writeMessage(var message: String, colorProfile: ColorProfile) {
        message = colorProfile.applyColorFormattingToMessage(message)
        println(message)
    }
}

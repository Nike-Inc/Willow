//
//  Writer.swift
//  Timber
//
//  Created by Christian Noon on 10/2/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

public protocol Writable {
    func writeMessage(message: String)
}

public class Writer: Writable {
    public func writeMessage(message: String) {
        println(message)
    }
}

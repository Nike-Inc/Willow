//
//  Formatter.swift
//  Timber
//
//  Created by Christian Noon on 11/24/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

import UIKit

/**
    The Formatter protocol defines a single method for formatting a message after it has been constructed. This is very
    flexible allowing any object that conforms to use formatting scheme it wants.
*/
public protocol Formatter {
    func formatMessage(message: String, logLevel: Logger.LogLevel) -> String
}

// MARK: -

/**
    The DefaultFormatter class applies a timestamp and log level prefix to the message.
*/
public class DefaultFormatter: Formatter {
    
    private let timestampFormatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public init() {}
    
    /**
        Applies a timestamp and log level prefix to the message.
    
        :param: message  The original message to format.
        :param: logLevel The log level set for the message.
    
        :returns: A newly formatted message.
    */
    public func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        let timestampString = self.timestampFormatter.stringFromDate(NSDate())
        return "\(timestampString) [\(logLevel)] \(message)"
    }
}

// MARK: -

/**
    The ColorFormatter class takes foreground and background colors and applies them to a given message. It uses the
    XcodeColors plugin color formatting scheme.

    NOTE: These should only be used with the XcodeColors plugin.
*/
public class ColorFormatter: Formatter {
    
    // MARK: - Private - ColorConstants Struct
    
    private struct ColorConstants {
        static let ESCAPE = "\u{001b}["
        static let RESET_FG = ESCAPE + "fg;"
        static let RESET_BG = ESCAPE + "bg;"
        static let RESET = ESCAPE + ";"
    }
    
    // MARK: - Private - Properties
    
    private let foregroundText = ""
    private let backgroundText = ""
    
    // MARK: - Initialization Methods
    
    /**
        Returns a fully constructed ColorFormatter from the given UIColor objects.
        
        :param: foregroundColor The color to apply to the foreground.
        :param: backgroundColor The color to apply to the background.
        
        :returns: A fully constructed ColorFormatter from the given UIColor objects.
    */
    public init(foregroundColor: UIColor?, backgroundColor: UIColor?) {
        assert(foregroundColor != nil || backgroundColor != nil, "The foreground and background colors cannot both be nil")
        
        let foregroundTextString = ColorFormatter.textStringForColor(foregroundColor)
        let backgroundTextString = ColorFormatter.textStringForColor(backgroundColor)
        
        if (!foregroundTextString.isEmpty) {
            self.foregroundText = "\(ColorConstants.ESCAPE)fg\(foregroundTextString);"
        }
        
        if (!backgroundTextString.isEmpty) {
            self.backgroundText = "\(ColorConstants.ESCAPE)bg\(backgroundTextString);"
        }
    }
    
    // MARK: - Formatter Methods
    
    /**
        Applies the foreground, background and reset color formatting values to the given message.
        
        :param: message The message to apply the color formatting to.
        
        :returns: A new string with all the color formatting values added.
    */
    public func formatMessage(message: String, logLevel: Logger.LogLevel) -> String {
        return "\(self.foregroundText)\(self.backgroundText)\(message)\(ColorConstants.RESET)"
    }
    
    // MARK: - Private - Helper Methods
    
    private class func textStringForColor(color: UIColor?) -> String {
        var textString = ""
        
        if let colorValue = color {
            var redValue: CGFloat = 0.0
            var greenValue: CGFloat = 0.0
            var blueValue: CGFloat = 0.0
            
            colorValue.getRed(&redValue, green: &greenValue, blue: &blueValue, alpha: nil)
            
            let maxValue: CGFloat = 255.0
            
            let redInt = UInt8(round(redValue * maxValue))
            let greenInt = UInt8(round(greenValue * maxValue))
            let blueInt = UInt8(round(blueValue * maxValue))
            
            textString = "\(redInt),\(greenInt),\(blueInt)"
        }
        
        return textString
    }
}

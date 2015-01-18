//
//  ColorProfile.swift
//  Timber
//
//  Created by Christian Noon on 11/24/14.
//  Copyright (c) 2014 Nike. All rights reserved.
//

public class ColorProfile {

    // MARK: - Private - Helper Structs
    
    private struct ColorConstants {
        static let ESCAPE = "\u{001b}["
        static let RESET_FG = ESCAPE + "fg;"
        static let RESET_BG = ESCAPE + "bg;"
        static let RESET = ESCAPE + ";"
    }

    // MARK: - Private - Properties
    
    private let foregroundText: String = ""
    private let backgroundText: String = ""
    
    // MARK: - API - Initialization Methods
    
    /**
    Returns a fully constructed ColorProfile from the given UIColor objects.
    
    :param: foregroundColor The color to apply to the foreground.
    :param: backgroundColor The color to apply to the background.
    
    :returns: A fully constructed ColorProfile from the given UIColor objects.
    */
    public init(foregroundColor: UIColor?, backgroundColor: UIColor?) {
        let foregroundTextString = textStringForColor(foregroundColor)
        let backgroundTextString = textStringForColor(backgroundColor)
        
        if (!foregroundTextString.isEmpty) {
            self.foregroundText = "\(ColorConstants.ESCAPE)fg\(foregroundTextString);"
        }
        
        if (!backgroundTextString.isEmpty) {
            self.backgroundText = "\(ColorConstants.ESCAPE)bg\(backgroundTextString);"
        }
    }
    
    // MARK: - API - Color Methods
    
    /**
    Applies the foreground, background and reset color formatting values to the given message.
    
    :param: message The message to apply the color formatting to.
    
    :returns: A new string with all the color formatting values added.
    */
    public func applyColorFormattingToMessage(message: String) -> String {
        return "\(self.foregroundText)\(self.backgroundText)\(message)\(ColorConstants.RESET)"
    }
    
    // MARK: - Private - Helper Methods
    
    private func textStringForColor(color: UIColor?) -> String {
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

//
//  UIColor.swift
//  MicCheck
//
//  Created by Eric Nash on 3/29/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

extension UIColor {
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }

    func isDark() -> Bool
    {
        let components = self.cgColor.components
        let redComponent = (components?[0])! * 299
        let greenComponent = (components?[1])! * 587
        let blueComponent = (components?[2])! * 114
        
        let brightness = (redComponent + greenComponent + blueComponent) / 1000
        
        if brightness > 0.5
        {
            return false
        }
        else
        {
            return true
        }

    }
}


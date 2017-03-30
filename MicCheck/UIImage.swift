//
//  UIImage.swift
//  MicCheck
//
//  Created by Eric Nash on 3/29/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit


extension UIImage {
    
    class func blend(image:UIImage, color:UIColor, mode:CGBlendMode) -> UIImage? {
        let rect = CGRect(origin: .zero, size: image.size)
        
        //image colored
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //image multiply
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // fill the background with white so that translucent colors get lighter
        context!.setFillColor(UIColor.white.cgColor)
        context!.fill(rect)
        
        image.draw(in: rect, blendMode: .normal, alpha: 1)
        coloredImage?.draw(in: rect, blendMode: mode, alpha: 1)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
}

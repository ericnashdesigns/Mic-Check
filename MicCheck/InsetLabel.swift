//
//  InsetLabel.swift
//  MicCheck
//
//  Created by Eric Nash on 4/4/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let topInset = CGFloat(8)
    let bottomInset = CGFloat(0)
    let leftInset = CGFloat(0)
    let rightInset = CGFloat(8)
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    
    
}

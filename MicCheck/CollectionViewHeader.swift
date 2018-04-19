//
//  CollectionViewHeader.swift
//  MicCheck
//
//  Created by Eric Nash on 2/21/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {

    @IBOutlet var viewColoredBackground: UIView!
    @IBOutlet var imgViewAppIcon: UIImageView!

    @IBOutlet var labelTodaysDate: UILabel!
    @IBOutlet var labelVenueList: UILabel!

    // place the outlets in the Header class instead so you won't get the 'repeating content' erro
    @IBOutlet var constraintViewColoredBackground: NSLayoutConstraint!
    
}

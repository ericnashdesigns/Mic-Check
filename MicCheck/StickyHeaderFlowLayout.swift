//
//  StickyHeaderFlowLayout.swift
//  MicCheck
//
//  Created by Eric Nash on 7/18/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

class StickyHeaderFlowLayout: UICollectionViewFlowLayout {

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Return true so we're asked for layout attributes as the content is scrolled
        return true
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        
        // Get the layout attributes for a standard UICollectionViewFlowLayout
        var elementsLayoutAttributes = super.layoutAttributesForElements(in: rect)
        if elementsLayoutAttributes == nil {
            return nil
        }
        
        
        // Define a struct we can use to store optional layout attributes in a dictionary
        struct HeaderAttributes {
            var layoutAttributes: UICollectionViewLayoutAttributes?
        }
        var visibleSectionHeaderLayoutAttributes = [Int : HeaderAttributes]()
        
        
        // Loop through the layout attributes we have
        for (index, layoutAttributes) in (elementsLayoutAttributes?.enumerated())! {
            let section = layoutAttributes.indexPath.section
            
            switch layoutAttributes.representedElementCategory {
            case .supplementaryView:
                // If this is a set of layout attributes for a section header, replace them with modified attributes
                if layoutAttributes.representedElementKind == UICollectionElementKindSectionHeader {
                    let newLayoutAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: layoutAttributes.indexPath)
                    elementsLayoutAttributes![index] = newLayoutAttributes!
                    
                    // Store the layout attributes in the dictionary so we know they've been dealt with
                    visibleSectionHeaderLayoutAttributes[section] = HeaderAttributes(layoutAttributes: newLayoutAttributes)
                }
                
            case .cell:
                // Check if this is a cell for a section we've not dealt with yet
                if visibleSectionHeaderLayoutAttributes[section] == nil {
                    // Stored a struct for this cell's section so we can can fill it out later if needed
                    visibleSectionHeaderLayoutAttributes[section] = HeaderAttributes(layoutAttributes: nil)
                }
                
            case .decorationView:
                break
            }
        }
        
        // Loop through the sections we've found
        for (section, headerAttributes) in visibleSectionHeaderLayoutAttributes {
            // If the header for this section hasn't been set up, do it now
            if headerAttributes.layoutAttributes == nil {
                let newAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: section))
                elementsLayoutAttributes!.append(newAttributes!)
            }
        }
        
        return elementsLayoutAttributes
    }
    
    
    
    
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Get the layout attributes for a standard flow layout
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        
        // If this is a header, we should tweak it's attributes
        if elementKind == UICollectionElementKindSectionHeader {
            
//            self.sectionInset = UIEdgeInsets(top: collectionView!.frame.size.height/3, left: 0, bottom: 0, right: 0)
//            collectionView!.collectionViewLayout.invalidateLayout()
            
            if let fullSectionFrame = frameForSection(indexPath.section) {
                let minimumY = max(collectionView!.contentOffset.y + collectionView!.contentInset.top, fullSectionFrame.origin.y) // this really only changes with scrolling and won't be less than 0
                
                // debugging
                // print(" collectionView!.contentOffset.y = \(collectionView!.contentOffset.y)")
                // print(" collectionView!.contentInset.top = \(collectionView!.contentInset.top)")
                // print(" fullSectionFrame.origin.y = \(fullSectionFrame.origin.y)")
                // print(" collectionView!.fullSectionFrame.maxY = \(fullSectionFrame.maxY)")
                // print(" headerReferenceSize.height = \(headerReferenceSize.height)")
                // print(" collectionView!.contentInset.bottom = \(collectionView!.contentInset.bottom) \r\n \r\n \r\n")
                
                
                let maximumY = fullSectionFrame.maxY - headerReferenceSize.height - collectionView!.contentInset.bottom
                
                // original code
                // attributes!.frame = CGRect(x: 0, y: min(minimumY, maximumY), width: collectionView!.bounds.size.width, height: headerReferenceSize.height)
                
                // make sure heights and cellSpacings match with those used in CollectionViewController.swift
                let cellSpacingsInStoryboard: CGFloat = 8.0
                let originalHeaderHeight: CGFloat = collectionView!.frame.size.height/3 - cellSpacingsInStoryboard
                let opacityScrollThreshold = originalHeaderHeight - collectionView!.contentOffset.y
                let minimumHeight: CGFloat = 64.0
                
                // update both positioning and height
                if collectionView!.contentOffset.y >= 0 {
                    attributes!.frame = CGRect(x: 0, y: min(minimumY, maximumY), width: collectionView!.bounds.size.width, height: max(minimumHeight, opacityScrollThreshold))
                } else {
                    attributes!.frame = CGRect(x: 0, y: collectionView!.contentOffset.y, width: collectionView!.bounds.size.width, height: max(minimumHeight, opacityScrollThreshold))
                }
                attributes!.zIndex = 1
            }
        }
        
        return attributes
    }
    
    
    
    
    
    // MARK: Private helper methods
    
    fileprivate func frameForSection(_ section: Int) -> CGRect? {
        
        // Sanity check
        let numberOfItems = collectionView!.numberOfItems(inSection: section)
        if numberOfItems == 0 {
            return nil
        }
        
        // Get the index paths for the first and last cell in the section
        let firstIndexPath = IndexPath(row: 0, section: section)
        let lastIndexPath = numberOfItems == 0 ? firstIndexPath : IndexPath(row: numberOfItems - 1, section: section)
        
        // Work out the top of the first cell and bottom of the last cell
        let firstCellTop = layoutAttributesForItem(at: firstIndexPath)?.frame.origin.y
        let lastCellBottom = (layoutAttributesForItem(at: lastIndexPath)?.frame)?.maxY
        // Build the frame for the section
        var frame = CGRect.zero
        
        frame.size.width = collectionView!.bounds.size.width
        frame.origin.y = firstCellTop!
        frame.size.height = lastCellBottom! - firstCellTop!
        
        // Increase the frame to allow space for the header
        frame.origin.y -= headerReferenceSize.height
        frame.size.height += headerReferenceSize.height
        
        // Increase the frame to allow space for an section insets
        frame.origin.y -= sectionInset.top
        frame.size.height += sectionInset.top
        
        frame.size.height += sectionInset.bottom
        
        return frame
    }
    
    
}

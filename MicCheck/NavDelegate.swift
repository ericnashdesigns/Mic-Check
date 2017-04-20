//
//  NavDelegate.swift
//  MicCheck
//
//  Created by Eric Nash on 2/27/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

class NavDelegate: NSObject, UINavigationControllerDelegate {
    
    private let animator = Animator()
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var selectedCellFrame: CGRect? = nil
    private var originCollectionViewY: CGFloat? = nil
    private var selectedCellFrameInSuperview: CGRect? = nil
    
    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using context: UIViewControllerContextTransitioning) {
        
        // push
        if let collectionVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? CollectionViewController,
            let rootVC = context.viewController(forKey: UITransitionContextViewControllerKey.to) as? RootViewController {
            
            moveFromCollectionView(collectionVC: collectionVC, toRoot: rootVC, withContext: context)
            
            // pop
        } else if let collectionVC = context.viewController(forKey: UITransitionContextViewControllerKey.to) as? CollectionViewController,
            let rootVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? RootViewController {
            
            moveFromRootView(rootVC: rootVC, toCollection: collectionVC, withContext: context)
            
        }
        
    }
    
    private func moveFromCollectionView(collectionVC: CollectionViewController, toRoot rootVC: RootViewController, withContext context: UIViewControllerContextTransitioning) {
        
        // this was tough because an array is returned instead of an index for collectionViews
        if let indexPath = collectionVC.collectionView?.indexPathsForSelectedItems?.first!,
            let selectedCell = collectionVC.collectionView?.cellForItem(at: indexPath) as? CollectionViewCell {
            
            context.containerView.addSubview(rootVC.view)
            
            // save collection view's original position and selected cell frame
            // (as a property) to move them back during pop transition animation
            selectedCellFrame = selectedCell.frame
            originCollectionViewY = collectionVC.collectionView?.frame.origin.y
            let convertedCoordinateY = collectionVC.collectionView?.convert(selectedCellFrame!, to: collectionVC.collectionView?.superview).origin.y // Different number depending on scroll position
            selectedCellFrameInSuperview = CGRect(x: selectedCell.frame.origin.x, y: convertedCoordinateY!, width: selectedCell.frame.width, height: selectedCell.frame.height)
            
            // use hero image on DataViewController to determine by how much to move the content
            let currentDataViewController = rootVC.pageViewController?.viewControllers?.first as! DataViewController

            
            
            
            
            // cell background -> hero image view transition
            // (don't want to mess with actual views, so creating a new image view just for transition)
            let imageView = createTransitionImageViewWithFrame(frame: selectedCellFrameInSuperview!)
            imageView.image = selectedCell.imgViewArtist.image
            imageView.alpha = 0.0 // hidden initially
            rootVC.view.addSubview(imageView)
            rootVC.view.alpha = 1.0
            collectionVC.view.alpha = 1.0

            
            currentDataViewController.view.alpha = 0.0
            let heroFinalHeight = currentDataViewController.imgViewArtist.frame.height
            let deltaY = convertedCoordinateY! - heroFinalHeight / 2.0
            
            // print("\r\n \r\n \(currentDataViewController.dataArtist)")
            // print(" imgViewArtist.frame.width is : \(currentDataViewController.imgViewArtist.frame.width)")
            // print(" selectedCell.frame.width is : \(selectedCell.frame.width)")
            // print(" convertedCoordinateY is : \(convertedCoordinateY!)")
            // print(" heroFinalHeight / 2 is : \(heroFinalHeight / 2)")
            // print(" deltaY is : \(deltaY)")
            
            // setup the mask for the artist image
            let shadowSize: CGFloat = 20.0
            let maskLayer = CAGradientLayer()
            maskLayer.frame = CGRect(x: -shadowSize, y: -shadowSize, width: currentDataViewController.imgViewArtist.frame.width + shadowSize * CGFloat(5.0), height: heroFinalHeight)
            maskLayer.shadowRadius = shadowSize
            maskLayer.shadowPath = CGPath(rect: maskLayer.frame, transform: nil)
            maskLayer.shadowOpacity = 1;
            maskLayer.shadowOffset = CGSize(width: 0, height: 0)
            maskLayer.shadowColor = UIColor.white.cgColor
            currentDataViewController.imgViewArtist.layer.mask = maskLayer;

            
            // hide page elements and offset them slightly down the page until we start to transition them back in
            currentDataViewController.hideElementsForPushTransition()

            // this appears to be the only way to get the new height of the label so I can derive the height of artist image
            currentDataViewController.labelDescription.text = currentDataViewController.dataDescriptionArtist

            print("NavDelegate.swift – currentDataViewController.labelDescription.text is : \(currentDataViewController.labelDescription.text!)")
            
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                
                // move collectionView frame so it appears like it's moving with the cell image
                collectionVC.collectionView?.frame.origin.y -= deltaY
                collectionVC.view.alpha = 0.0

                // make sure I have the latest on the height of the artist image
                currentDataViewController.imgViewArtist.layoutIfNeeded()
                
                // move our transitioning imageView towards hero image position (and grow its size at the same time)
                imageView.frame = CGRect(x: 0.0, y: 0.0, width: currentDataViewController.imgViewArtist.frame.width, height: currentDataViewController.imgViewArtist.frame.height)
                imageView.alpha = 1.0
                
                // fade the destination into view
                currentDataViewController.view.alpha = 1.0
                
            }) { finished in
                
                // now we are ready to show real heroView on top of our imageView
                rootVC.view.sendSubview(toBack: imageView)
                
                // rootVC.categoryDescriptionBottomSpacer.constant = originalCategoryDescriptionBottomSpacerConstant
                currentDataViewController.prepareToCompletePushTransition()
                
                currentDataViewController.imgViewArtist.alpha = 1.0
                
                let controlsDeltaY: CGFloat = 20.0
                currentDataViewController.labelArtist.frame.origin.y += controlsDeltaY
                currentDataViewController.labelVenueAndPrice.frame.origin.y += controlsDeltaY
                currentDataViewController.labelDescription.frame.origin.y += controlsDeltaY
                currentDataViewController.viewVideoPlayerTopLeft.frame.origin.y += controlsDeltaY
                currentDataViewController.viewVideoPlayerTopRight.frame.origin.y += controlsDeltaY

                
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {

                    maskLayer.shadowOffset = CGSize(width: 0, height: -shadowSize)
                    
                    currentDataViewController.labelArtist.alpha = 1.0
                    currentDataViewController.labelVenueAndPrice.alpha = 1.0
                    currentDataViewController.labelDescription.alpha = 1.0
                    currentDataViewController.viewVideoPlayerTopLeft.alpha = 1.0
                    currentDataViewController.viewVideoPlayerTopRight.alpha = 1.0
                    
                    currentDataViewController.labelArtist.frame.origin.y -= controlsDeltaY
                    currentDataViewController.labelVenueAndPrice.frame.origin.y -= controlsDeltaY
                    currentDataViewController.labelDescription.frame.origin.y -= controlsDeltaY
                    currentDataViewController.viewVideoPlayerTopLeft.frame.origin.y -= controlsDeltaY
                    currentDataViewController.viewVideoPlayerTopRight.frame.origin.y -= controlsDeltaY
                    //for view in autoLayoutViews { view.layoutIfNeeded() }
                    
                }) { finishedInner in
                    
                    print(" imageView.frame.width is : \(imageView.frame.width)")
                    
                    
                    // clean up & revert all the temporary things
//                    imageView.alpha = 0.5
                    imageView.removeFromSuperview()
                    currentDataViewController.startKenBurnsAnimation()
                    print(" NavDelegate.swift – moveFromCollectionView() finished animation")
                    //collectionVC.collectionView?.deselectRowAtIndexPath(indexPath, animated: false)
                    
                    context.completeTransition(!context.transitionWasCancelled)
                }
                
            } // end callback
            
        }  // end if
        
        print(" NavDelegate.swift – moveFromCollectionView() finished")
        
    }
    
    private func moveFromRootView(rootVC: RootViewController, toCollection collectionVC: CollectionViewController, withContext context: UIViewControllerContextTransitioning) {
        
        context.containerView.addSubview(collectionVC.view)
        // make the destination invisible so we can fade it in later
        collectionVC.view.alpha = 0.0
        
        // Access the DataViewController within the rootVC
        let currentDataViewController = rootVC.pageViewController?.viewControllers?.first as! DataViewController
        
        // Access the coordinates of the selected cell
        let imageView = createTransitionImageViewWithFrame(frame: currentDataViewController.imgViewArtist.frame)
        imageView.image = currentDataViewController.imgViewArtist.image
        context.containerView.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            rootVC.view.alpha = 0.0
            currentDataViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            collectionVC.view.alpha = 1.0
            collectionVC.collectionView?.frame.origin.y = self.originCollectionViewY ?? (collectionVC.collectionView?.frame.origin.y)!
            imageView.alpha = 0.0
            imageView.frame = self.selectedCellFrameInSuperview ?? imageView.frame
        }) { finished in
            rootVC.view.transform = .identity
            imageView.removeFromSuperview()
            // print("\r\n CollectionView FadeIn complete")
            context.completeTransition(!context.transitionWasCancelled)
        }
        
    }
    
    private func createTransitionImageViewWithFrame(frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        //        print("  NavDelegate.swift – imageView.frame.origin.y is : \(imageView.frame.origin.y)")
        imageView.contentMode = .scaleAspectFill
        //imageView.setupDefaultTopInnerShadow()
        imageView.clipsToBounds = true
        return imageView
    }
    
}

private extension DataViewController {
    func hideElementsForPushTransition() {
        
        // hero view appears with slight delay (not in sync)
        // so need to hide it explicitly from container view
        view.alpha = 0.0
        
        // hide the elements on the DataViewController
        //let currentDataViewController = self.pageViewController?.viewControllers?.first as! DataViewController
        self.imgViewArtist.alpha = 0.0
        self.labelArtist.alpha = 0.0
        self.labelVenueAndPrice.alpha = 0.0
        self.labelDescription.alpha = 0.0
        self.viewVideoPlayerTopLeft.alpha = 0.0
        self.viewVideoPlayerTopRight.alpha = 0.0
        
        // hide all visible cells
        //for cell in visibleCellViews { cell.alpha = 0.0 }
        
        // move back button arrow beyond screen
        //backButtonHorizontalSpacer.constant = -70.0
    }
    
    func prepareToCompletePushTransition() {
        
        //backButtonHorizontalSpacer.constant = 0.0
        //disableTransparencyAnimatedForViews(visibleCellViews)
        
        UIView.animate(withDuration: 0.2, animations: {
            //self.view.alpha = 1.0
        }) { finished in
            
        }
    }
    
    //    private var visibleCellViews: [UIView] {
    //        return (tableView.visibleCells() as! [UITableViewCell]).map { $0.contentView }
    //    }
}



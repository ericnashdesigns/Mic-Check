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
            let transitionImageView = createTransitionImageViewWithFrame(frame: selectedCellFrameInSuperview!)
            transitionImageView.image = selectedCell.imgViewArtist.image

            // setup the mask for the artist image
//            let shadowSize: CGFloat = 50.0
//            let maskLayer = CAGradientLayer()
//            maskLayer.frame = CGRect(x: -shadowSize, y: -shadowSize, width: transitionImageView.frame.width + shadowSize * CGFloat(5.0), height: transitionImageView.frame.height)
//            maskLayer.shadowRadius = shadowSize
//            maskLayer.shadowPath = CGPath(rect: maskLayer.frame, transform: nil)
//            maskLayer.shadowOpacity = 1;
//            maskLayer.shadowOffset = CGSize(width: 0, height: 0)
//            maskLayer.shadowColor = UIColor.white.cgColor
//            transitionImageView.layer.mask = maskLayer;
            
            transitionImageView.alpha = 0.0 // hidden initially
            rootVC.view.addSubview(transitionImageView)
            rootVC.view.alpha = 1.0
            collectionVC.view.alpha = 1.0
            
            currentDataViewController.view.alpha = 0.0
            currentDataViewController.imgViewArtist.alpha = 0.0 // hidden initially
            let heroFinalHeight = currentDataViewController.imgViewArtist.frame.height
            let deltaY = convertedCoordinateY! - heroFinalHeight / 2.0
            
            // hide page elements and offset them slightly down the page until we start to transition them back in
            currentDataViewController.hideElementsForPushTransition()

            // this appears to be the only way to get the new height of the label so I can derive the height of artist image
            currentDataViewController.labelDescription.text = currentDataViewController.dataDescriptionArtist
            
            print("   NavDelegate.swift – currentDataViewController.dataDescriptionArtist: \(currentDataViewController.dataDescriptionArtist)")

            //print("   NavDelegate.swift – currentDataViewController.labelDescription.text is : \(currentDataViewController.labelDescription.text!)")
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                
                // move collectionView frame so it appears like it's moving with the cell image
                collectionVC.collectionView?.frame.origin.y -= deltaY
                collectionVC.view.alpha = 0.0

                // make sure I have the latest on the height of the artist image
                currentDataViewController.imgViewArtist.layoutIfNeeded()
                
                // move our transitionImageView towards hero image position (and grow its size at the same time)
                transitionImageView.frame = CGRect(x: 0.0, y: 0.0, width: currentDataViewController.imgViewArtist.frame.width, height: currentDataViewController.imgViewArtist.frame.height)
                transitionImageView.alpha = 1.0
                
                // fade the destination into view
                currentDataViewController.view.alpha = 1.0
                
            }) { finished in

                // unhide the permanent hero image underneath and slowly let the transitionImage give way to it
                currentDataViewController.imgViewArtist.alpha = 1.0
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {

                    transitionImageView.alpha = 0
                    
                // now we are ready to clean up the transitionImageView and show the real heroView on top
                }) { finishedInner in

                    
                    rootVC.view.sendSubview(toBack: transitionImageView)
                    transitionImageView.removeFromSuperview()
                }


                // start the animation of the other controls as a "down" swipe, which uses positive Y coordinates
                currentDataViewController.animateControlsIn(controlsDeltaY: 40.0)

                context.completeTransition(!context.transitionWasCancelled)

                print("   NavDelegate.swift – moveFromCollectionView() finished animation")
                
            } // end callback
            
        }  // end if
        
        print("   NavDelegate.swift – moveFromCollectionView() finished")
        
    }
    
    private func moveFromRootView(rootVC: RootViewController, toCollection collectionVC: CollectionViewController, withContext context: UIViewControllerContextTransitioning) {
        
        // Access the DataViewController within the rootVC
        let currentDataViewController = rootVC.pageViewController?.viewControllers?.first as! DataViewController

        // end kenBurns animation as soon as another DataViewController is summoned
        currentDataViewController.stopKenBurnsAnimation()
        
        context.containerView.addSubview(collectionVC.view)
        // make the destination invisible so we can fade it in later
        collectionVC.view.alpha = 0.0
        
        
        // Access the coordinates of the selected cell
        let transitionImageView = createTransitionImageViewWithFrame(frame: currentDataViewController.imgViewArtist.frame)
        transitionImageView.image = currentDataViewController.imgViewArtist.image
        context.containerView.addSubview(transitionImageView)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            rootVC.view.alpha = 0.0
            currentDataViewController.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            collectionVC.view.alpha = 1.0
            collectionVC.collectionView?.frame.origin.y = self.originCollectionViewY ?? (collectionVC.collectionView?.frame.origin.y)!
            transitionImageView.alpha = 0.0
            transitionImageView.frame = self.selectedCellFrameInSuperview ?? transitionImageView.frame
        }) { finished in
            rootVC.view.transform = .identity
            transitionImageView.removeFromSuperview()
            // print("\r\n CollectionView FadeIn complete")
            context.completeTransition(!context.transitionWasCancelled)
        }
        
    }
    
    private func createTransitionImageViewWithFrame(frame: CGRect) -> UIImageView {
        let transitionImageView = UIImageView(frame: frame)
        //        print("  NavDelegate.swift – imageView.frame.origin.y is : \(imageView.frame.origin.y)")
        transitionImageView.contentMode = .scaleAspectFill
        //transitionImageView.setupDefaultTopInnerShadow()
        transitionImageView.clipsToBounds = true
        return transitionImageView
    }
    
}

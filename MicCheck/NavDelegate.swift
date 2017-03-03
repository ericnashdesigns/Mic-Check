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
    private var originalCollectionViewY: CGFloat? = nil

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
 
        // this was tough because an array is returned instead of an index
        if let indexPath = collectionVC.collectionView?.indexPathsForSelectedItems?.first!,
            let selectedCell = collectionVC.collectionView?.cellForItem(at: indexPath) as? CollectionViewCell {

            context.containerView.addSubview(rootVC.view)

            // cell background -> hero image view transition
            // (don't want to mess with actual views,
            // so creating a new image view just for transition)
            let imageView = createTransitionImageViewWithFrame(frame: selectedCell.frame)
            imageView.image = selectedCell.imgViewArtist.image
            imageView.alpha = 0.0 // hidden initially
            rootVC.view.addSubview(imageView)
            rootVC.view.alpha = 1.0
            collectionVC.view.alpha = 1.0
            
            // save table view's original position and selected cell frame
            // (as a property) to move them back during pop transition animation
            selectedCellFrame = selectedCell.frame
            originalCollectionViewY = collectionVC.collectionView?.frame.origin.y

            // figure out by how much need to move content
            let currentDataViewController = rootVC.pageViewController?.viewControllers?.first as! DataViewController
            currentDataViewController.view.alpha = 0.0
            let heroFinalHeight = currentDataViewController.view.bounds.size.height / 2.0
            let deltaY = selectedCell.center.y - heroFinalHeight / 2.0

            currentDataViewController.hideElementsForPushTransition() // hide page elements until transition ends
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                
                // hide "your future pack" label
                //categoryVC.titleLabel.alpha = 0.0
                
                // adjust collectionView frame so it appears like whole content is moving with cell image
                collectionVC.collectionView?.frame.origin.y -= deltaY
                collectionVC.view.alpha = 0.0
                
                // move our transitioning imageView towards hero image position (and grow its size at the same time)
                imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.frame.width, height: heroFinalHeight)
                imageView.alpha = 1.0

                // fade the destination into view
                currentDataViewController.view.alpha = 1.0
                
            }) { finished in
                
                // now we are ready to show real heroView on top of our imageView
                rootVC.view.sendSubview(toBack: imageView)
                
                //rootVC.categoryDescriptionBottomSpacer.constant = originalCategoryDescriptionBottomSpacerConstant
                currentDataViewController.prepareToCompletePushTransition()
                
                // prepare constraints for animation
                //let autoLayoutViews = [rootVC.backButton]
                //for view in autoLayoutViews { view.setNeedsUpdateConstraints() }

                currentDataViewController.imgViewArtist.alpha = 1.0
                
                UIView.animate(withDuration: 0.3, animations: {
                    currentDataViewController.labelArtist.alpha = 1.0
                    currentDataViewController.labelVenue.alpha = 1.0
                    currentDataViewController.labelPrice.alpha = 1.0
                    currentDataViewController.labelDescription.alpha = 1.0
                    currentDataViewController.viewVideoPlayerTopLeft.alpha = 1.0
                    currentDataViewController.viewVideoPlayerTopRight.alpha = 1.0

                    //for view in autoLayoutViews { view.layoutIfNeeded() }
                    
                }) { finishedInner in
                    
                    // clean up & revert all the temporary things
                    imageView.removeFromSuperview()
                    //collectionVC.collectionView?.deselectRowAtIndexPath(indexPath, animated: false)
                    
                    context.completeTransition(!context.transitionWasCancelled)
                }

            } // end callback
            
        }  // end if
        
    }
    
    private func moveFromRootView(rootVC: RootViewController, toCollection collectionVC: CollectionViewController, withContext context: UIViewControllerContextTransitioning) {

        context.containerView.addSubview(collectionVC.view)
        // make the destination invisible so we can fade it in later
        collectionVC.view.alpha = 0.0

        // Access the DataViewController within the rootVC
        let currentDataViewController = rootVC.pageViewController?.viewControllers?.first as! DataViewController
        
        let imageView = createTransitionImageViewWithFrame(frame: currentDataViewController.imgViewArtist.frame)
        imageView.image = currentDataViewController.imgViewArtist.image
        context.containerView.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4, animations: {
            rootVC.view.alpha = 0.0
            rootVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            collectionVC.view.alpha = 1.0
            collectionVC.collectionView?.frame.origin.y = self.originalCollectionViewY ?? (collectionVC.collectionView?.frame.origin.y)!
            imageView.alpha = 0.0
            imageView.frame = self.selectedCellFrame ?? imageView.frame
        }) { finished in
            rootVC.view.transform = .identity
            imageView.removeFromSuperview()
            print("\r\n CollectionView FadeIn complete")
            context.completeTransition(!context.transitionWasCancelled)
        }
    
    }

    private func createTransitionImageViewWithFrame(frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
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
        self.labelVenue.alpha = 0.0
        self.labelPrice.alpha = 0.0
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


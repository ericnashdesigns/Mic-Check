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
        let toVC = context.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from)
        context.containerView.addSubview((toVC?.view)!)
        // animate your views here, then call this method when your animation is completed:
        
        // push
        if let collectionVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? CollectionViewController,
            let rootVC = context.viewController(forKey: UITransitionContextViewControllerKey.to) as? RootViewController {
            
            moveFromCollectionView(collectionVC: collectionVC, toRoot: rootVC, withContext: context)
            
        } else if let collectionVC = context.viewController(forKey: UITransitionContextViewControllerKey.to) as? CollectionViewController,
            let rootVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) as? RootViewController {
            
            moveFromRootView(rootVC: rootVC, toCollection: collectionVC, withContext: context)
            
        }
        
        
        context.completeTransition(!context.transitionWasCancelled)
    }

    
    private func moveFromCollectionView(collectionVC: CollectionViewController, toRoot rootVC: RootViewController, withContext context: UIViewControllerContextTransitioning) {
 
        print("TRANSITIONING TO ROOT!!!!!!!!!!!!!!!!!!!")

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

            // save table view's original position and selected cell frame
            // (as a property) to move them back during pop transition animation
            selectedCellFrame = selectedCell.frame
            originalCollectionViewY = collectionVC.collectionView?.frame.origin.y

            // figure out by how much need to move content
            //let currentDataViewController = rootVC.modelController.viewControllerAtIndex(indexPath[1], direction: "down", storyboard: rootVC.storyboard!)!
            //let heroFinalHeight = currentDataViewController.imgViewArtist?.bounds.size.height
            //print("the height is \(heroFinalHeight)")
            //let heroFinalHeight = rootVC.HeroViewHeight.Regular.rawValue
            //let deltaY = selectedCell.center.y - heroFinalHeight / 2.0
            
        }  // end if
        
    }
    
    private func moveFromRootView(rootVC: RootViewController, toCollection collectionVC: CollectionViewController, withContext context: UIViewControllerContextTransitioning) {

        print("TRANSITIONING TO COLLECTION!!!!!!!!!!!!!!!!!!!")
    
    }

    private func createTransitionImageViewWithFrame(frame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        //imageView.setupDefaultTopInnerShadow()
        imageView.clipsToBounds = true
        return imageView
    }
    
}

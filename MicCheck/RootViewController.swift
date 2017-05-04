//
//  RootViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    //var eventLineUp: EventLineup?
    var eventIndex: Int?
    var nextEventIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        self.pageViewController!.delegate = self

        // ERic: swapped out the 0 for the monthIndex as an Int
        
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(eventIndex!, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMove(toParentViewController: self)

        // if I don't use this, the dataviewcontrollers will be too low on the screen.
        self.automaticallyAdjustsScrollViewInsets = false
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }
    
    // The kenburns animation seemed to cause a performance lag as I paged, so trying to turning it on/off improves
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if completed == true {

            // stop animation on previous controller
            // EXPERIMENT: Seeing if stopping the animation on the previous controller here helps keep it from jittering when I page off and the page back onto it
//            let previousViewController = previousViewControllers[0] as! DataViewController
//            previousViewController.stopKenBurnsAnimation()
            
            let completedController = self.pageViewController!.viewControllers![0] as! DataViewController
            
            // there's no way to mathematically tell if you're moving up/down using subtraction with 2 elements, so don't animate
            guard self.modelController.lineUp.events.count > 2 else {
                return
            }
            
            // I'm using (destination - depature) so that positive values mean going downward.             
            // I'm also adding 1 to everything so that when I use subtraction, I never accidentally subtract 0            
            let direction = (nextEventIndex! + 1) - (eventIndex! + 1)
            
            if (direction == 1 || direction <= -2) { // you're moving down the stack or returning to the top                print("\r\nRootViewController.swift – Swipe Down")
                completedController.animateControlsIn(controlsDeltaY: 120.0)
            }
            else if (direction == -1 || direction >= 2) { // you're moving up the stack or returning to the bottom                print("\r\nRootViewController.swift – Swipe Up")
                completedController.animateControlsIn(controlsDeltaY: -120.0)
            }
            
            // since completed is true and we're down transitioning to the next view controller, reset eventIndex so there's a frame of reference for the next swipe            
            eventIndex = nextEventIndex
            
        } // end if
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // the page view controller is about to transition to a new page, so take note
        // of the index of the page it will display.  (We can't update our currentIndex
        // yet, because the transition might not be completed - we will check in didFinishAnimating:)

//        print("RootViewController.swift – willTransitionTo called")

        // end kenBurns animation as soon as another DataViewController is summoned
        // EXPERIMENT: For some reason, this causes the image to look jittery when I page off and then page back on
//        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
//        currentViewController.stopKenBurnsAnimation()
        
        
        // no need to do any animation if there's only two events
        guard self.modelController.lineUp.events.count > 2 else {
            return
        }
        
        // get pending Controller ready for transition
        if let pendingController = pendingViewControllers[0] as? DataViewController {

            nextEventIndex = pendingController.dataIntEventIndex
            pendingController.hideElementsForPushTransition()
        }
        
    }
    
    // EXPERIMENT: It seems like this method is not getting called, so I put the logic into the willTransitionTo protocol above
    // Not sure that worked, it maked everything kinda jumpy

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {

        print("RootViewController.swift – willTransition called")
        
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        
        // end kenBurns animation as soon as another DataViewController is summoned
        currentViewController.stopKenBurnsAnimation()
        
    }

}


//
//  ModelController.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    // MARK: - Use Singleton to load up event objects from the JSON file and create the model
    let lineUp = EventLineup.sharedInstance

    override init() {
        super.init()
    }

    // Added the swipe direction parameter so I know which way to move the text
    func viewControllerAtIndex(_ index: Int, direction: String, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.lineUp.events.count == 0) || (index >= self.lineUp.events.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController

        dataViewController.dataIntEventIndex = index
        
        dataViewController.dataArtist = self.lineUp.events[index].artist
        dataViewController.dataImgArtist = self.lineUp.events[index].imgArtist
        dataViewController.dataVenue = self.lineUp.events[index].venue!
        dataViewController.dataPrice = self.lineUp.events[index].price!
        
        dataViewController.dataColorsImgArtist = self.lineUp.events[index].colorsFromArtistImage

        dataViewController.swipeDirection = direction
        
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return self.lineUp.events.index(where: {$0.artist == viewController.dataArtist }) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (self.lineUp.events.count == 1) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        let swipeDirection: String = "up"
        
        // if you're at the top and you swipe to go up again, restart at the end
        if index < 0 {
            return self.viewControllerAtIndex(self.lineUp.events.count - 1, direction: swipeDirection, storyboard: viewController.storyboard!)
        }
        
        return self.viewControllerAtIndex(index, direction: swipeDirection, storyboard: viewController.storyboard!)
    
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (self.lineUp.events.count == 1) || (index == NSNotFound) {
            return nil
        }
        
        index += 1
        let swipeDirection: String = "down"
        
        // if you're at the bottom and you swipe to go down again, restart at the beginning instead of returning nil
        if index == self.lineUp.events.count {
            return self.viewControllerAtIndex(0, direction: swipeDirection, storyboard: viewController.storyboard!)
        }
        return self.viewControllerAtIndex(index, direction: swipeDirection, storyboard: viewController.storyboard!)
    }

}


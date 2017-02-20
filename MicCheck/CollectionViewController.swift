//
//  CollectionViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 1/29/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit

private let reuseIdentifier = "IDcell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var lineUp: EventLineup?
    var eventsLoaded: Bool = false // keeps track of when everything is loaded
    let cellSpacingsInStoryboard: CGFloat = 2 * 2 // spacing * 2 edges
    
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.

        print(" CollectionViewController – 1 of 4: before the first shared instance")

        // if I don't use this, the collectionview will be too low on the screen.
        self.automaticallyAdjustsScrollViewInsets = false
        
        let images = [
            UIImage(named: "empty.stage")!,
            UIImage(named: "guitarist.mountain.oasis")!,
            UIImage(named: "guitarist.on.stage")!,
            UIImage(named: "edm")!,
            UIImage(named: "jazz.horns")!
        ]
    
        self.kenBurnsView.animateWithImages(images, imageAnimationDuration: 5, initialDelay: 0, shouldLoop: true, randomFirstImage: true)

        self.lineUp = EventLineup.sharedInstance
        
        // start cranking through the color palletes for the detail views, moving to a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            print(" CollectionViewController – 2 of 4: Global queue right after the ken burns initialize")
            self.lineUp?.filterTodaysEvents() // this filter will return nothing if in test mode

            DispatchQueue.main.async {

                //self.collectionView?.bringSubview(toFront: self.kenBurnsView)
                print(" CollectionViewController – 3 of 4: Main Queue - right before reloadDate")
                self.eventsLoaded = true
                
                self.collectionView?.reloadData()
                
                self.collectionView?.bringSubview(toFront: self.kenBurnsView)
                
                self.kenBurnsView.alpha = 0
                self.kenBurnsView.stopAnimation()

                // TODO: This part takes a long time, so I think I'll try to get it on a separate thread.
                //       I may even try again to put it on the DataViewController
                
                //print(" CollectionViewController – 3 of 4: getColorsForArtistImages start")
                self.lineUp?.getColorsForArtistImages()
                //print(" CollectionViewController – 4 of 4: getColorsForArtistImages end")
                
                
            } // end Dispatch.main.sync

        } // end Dispatch.global
    
        // print(" CollectionViewController – viewDidLoad() called")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: – Sizing
    // Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        
        if(orientation == .landscapeLeft || orientation == .landscapeRight) {
        // 1 header row of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/2
            return CGSize(width: width, height: height)
        }
        else { // portrait mode
        // 1 header row of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/3
            return CGSize(width: width, height: height)
        }        
    }
    
    // Main Cells
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // your code here
        let orientation = UIApplication.shared.statusBarOrientation
        
        if(orientation == .landscapeLeft || orientation == .landscapeRight) {
            // 2 rows of 2
            let width = collectionView.frame.size.width/2 - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/2
            return CGSize(width: width, height: height)
        }
        else { // portrait mode
            // 3 rows of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/3
            return CGSize(width: width, height: height)
        }
    }
    

    // Footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        
        if(orientation == .landscapeLeft || orientation == .landscapeRight) {
        // 1 footer row of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/2
            return CGSize(width: width, height: height)
        }
        else { // portrait mode
        // 1 footer row of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/3
            return CGSize(width: width, height: height)
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "collectionViewSegue" {
            
            // Pass the selected index to the new view controller.
            let cell = sender as! CollectionViewCell
            let vc = segue.destination as! RootViewController
            
            if let indexPath = self.collectionView?.indexPath(for: cell) {
                vc.eventIndex = indexPath.row
                // let selectedEvent = self.modelController.lineUp.events[indexPath.row]
                // print(" CollectionViewController – indexPath = \(indexPath.row)")
            }
            
        }
        
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.lineUp!.events.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        cell.imgViewArtist.image = self.lineUp?.events[indexPath.row].imgArtist

        if eventsLoaded == false {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        return cell
    }
    
    //
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

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

    var gradientLayerAdded: CALayer?  // reference gradient later when changing size on rotations
    
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.

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

        print(" CollectionViewController – 1 of 4: Main Queue - Starting EventLineup() Instance")
        
        // create the model with placeholder data
        self.lineUp = EventLineup.sharedInstance

        // Create the gradient
        let topColor = UIColor(red: (62/255.0), green: (70/255.0), blue: (76/255.0), alpha: 1)
        let bottomColor = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.frame.origin = CGPoint(x: 0.0, y: 0.0)
        self.collectionView?.backgroundColor = UIColor.clear
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayerAdded = self.view.layer.sublayers?.first
        
        // start cranking through the events in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            print(" CollectionViewController – 2 of 4: Global Queue - Starting filterTodaysEvents()")
            self.lineUp?.filterTodaysEvents() // this filter will return nothing if in test mode

            print(" CollectionViewController – 3 of 4: Global Queue - Finish filterTodaysEvents(), Starting getColorsForArtistImages()")
            // I updated getColorsForArtistImages to run in a separate thread and (hopefully) will just chug in the background
            self.lineUp?.getColorsForArtistImages()
            
            DispatchQueue.main.async {

                //self.collectionView?.bringSubview(toFront: self.kenBurnsView)
                print(" CollectionViewController – 4 of 4: Main Queue - Finish getColorsForArtistImages(), Starting reloadData()")
                self.eventsLoaded = true
                
                self.collectionView?.reloadData()
                
                self.collectionView?.bringSubview(toFront: self.kenBurnsView)
                
                self.kenBurnsView.alpha = 0
                self.kenBurnsView.stopAnimation()

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
    
    // MARK: – Formatting
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:

            let headerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeader",for: indexPath) as! CollectionViewHeader

            if eventsLoaded == false {
                headerView.isHidden = true
            } else {
                headerView.isHidden = false

                // do color processing for the first event and assign the background color to the header

                if let coloredBackground = self.lineUp?.events[0].getColorsForArtistImage() {

                    print(" CollectionViewController.swift - Header Formatting: ArtistImage Colors Were Used")
                    //headerView.viewColoredBackground.backgroundColor = coloredBackground.backgroundColor
                    //headerView.labelEventCount.textColor = coloredBackground.secondaryColor.withAlphaComponent(0.25)
                    headerView.labelEventCount.textColor = coloredBackground.secondaryColor.withAlphaComponent(0.75)
                    //headerView.viewColoredBackground.backgroundColor = coloredBackground.backgroundColor.withAlphaComponent(0.25)
                    headerView.viewColoredBackground.backgroundColor = coloredBackground.primaryColor

                    
                } else {

                    print(" CollectionViewController.swift - Header Formatting: Couldn't Get ImageColors.  Using Red")
                    headerView.viewColoredBackground.backgroundColor = UIColor(red: (0.95), green: (0.26), blue: (0.21), alpha: 1)

                } // end else

                // update the count
                headerView.labelEventCount.text =  "\(self.lineUp!.events.count)"
                
                // add the border
                headerView.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.black, thickness: 2.0)
                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.right, color: UIColor.black, thickness: 2.0)
                
            } // end else
            
            return headerView
            
            
        case UICollectionElementKindSectionFooter:
            let footerView =
                collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                withReuseIdentifier: "CollectionViewFooter",
                                                                for: indexPath)
            return footerView
            
        default:
            //4
            assert(false, "Unexpected element kind")
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

//
//  CollectionViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 1/29/17.
//  Copyright © 2017 Eric Nash Designs. All rights reserved.
//

import UIKit
import UIImageColors

private let reuseIdentifier = "IDcell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // data variables
    var lineUp: EventLineup?
    var eventsLoaded: Bool = false // keeps track of when everything is loaded
    var dataDateToday: String = ""

    // UI variables
    var colorsFromFirstArtistImage: UIImageColors? = nil  // use these colors for the hero area
    var viewHeroBackground: UIView!
    var viewRadialGradientBackground: RadialGradientView!
    let backgroundColorDark = UIColor(red: (62/255.0), green: (70/255.0), blue: (76/255.0), alpha: 1)
    let backgroundColorDarker = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
    let cellSpacingsInStoryboard: CGFloat = 8 * 2 // spacing * 2 edges
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    @IBOutlet var viewAppIcon: UIView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // create the model, starting with placeholder data
        print(" CollectionViewController.swift – 1 of 5: Main Queue - Starting EventLineup() Instance")
        self.lineUp = EventLineup.sharedInstance

        // create array of ken burns images to iterate through
        let images = [
            UIImage(named: "empty.stage")!,
            UIImage(named: "guitarist.mountain.oasis")!,
            UIImage(named: "guitarist.on.stage")!,
            UIImage(named: "edm")!,
            UIImage(named: "jazz.horns")!
        ]
        self.kenBurnsView.animateWithImages(images, imageAnimationDuration: 5, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
        self.kenBurnsView.bringSubview(toFront: self.viewAppIcon)
        
        // get and format todays date
        let currentDate = NSDate()
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        let convertedDay = dayFormatter.string(from: currentDate as Date).uppercased()
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "M"
        let convertedMonth = monthFormatter.string(from: currentDate as Date).uppercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let convertedDate = dateFormatter.string(from: currentDate as Date).uppercased()
        dataDateToday = convertedDay + " " + convertedMonth + "/" + convertedDate
        
        // Add background color to the collectionView
        self.collectionView?.backgroundColor = backgroundColorDarker

        // start cranking through the events in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            print(" CollectionViewController.swift – 2 of 5: Global Queue - Starting filterTodaysEvents()")
            self.lineUp?.filterTodaysEvents() // this filter will return nothing if in test mode

            print(" CollectionViewController.swift – 3 of 5: Global Queue - Finish filterTodaysEvents(), Starting getColorsForArtistImage()")

            // get the colors for the first image since we'll need them for the main UI thread
            self.colorsFromFirstArtistImage = self.lineUp?.events[0].getColorsForArtistImage()
            
            print(" CollectionViewController.swift – 4 of 5: Global Queue - Finish getColorsForArtistImage(), Resuming Main Thread")
            
            DispatchQueue.main.async {

                print(" CollectionViewController.swift – 5 of 5: Main Queue – Starting reloadData()")

                // set flag so that I'll know how to let UI respond later
                self.eventsLoaded = true

                // show only events filtered for today
                self.collectionView?.reloadData()

                // stop and fade the ken burns animations
                self.kenBurnsView.stopAnimation()
                UIView.animate(withDuration: 0.5, animations: { self.kenBurnsView.alpha = 0 })

                // create a radial gradient background for the hero region just behind the CollectionViewHeader
                let newColors: [UIColor] = [self.colorsFromFirstArtistImage!.primaryColor, self.backgroundColorDarker]
                self.viewRadialGradientBackground = RadialGradientView(frame: CGRect(x: 0, y: -(self.collectionView?.bounds.height)! / 2.0, width: (self.collectionView?.bounds.width)!, height: (self.collectionView?.bounds.height)!))
                self.viewRadialGradientBackground.colors = newColors
                self.viewHeroBackground = UIView(frame: CGRect(x: 0, y: -(self.collectionView?.bounds.height)! / 2.0, width: (self.collectionView?.bounds.width)!, height:(self.collectionView?.bounds.height)!))
                self.collectionView?.addSubview(self.viewRadialGradientBackground)
                self.collectionView?.sendSubview(toBack: self.viewRadialGradientBackground)

                // add a bottom border to the background, using the lighter of the two colorsFromFirstArtistImage
                var borderColor = self.colorsFromFirstArtistImage?.primaryColor!
                if (borderColor?.isDark())! {
                    borderColor = self.colorsFromFirstArtistImage?.backgroundColor!
                }
                self.viewHeroBackground.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor!, thickness: 2.0)
                
                // chug through the rest of the artist images in a separate background thread in global queue
                self.lineUp?.getColorsForArtistImages()

                // chug through the rest of the artist descriptions in a separate background thread in global queue
                self.lineUp?.getArtistDescriptions()
                
            } // end Dispatch.main.sync
        } // end Dispatch.global
    }

    // removes the status bar
    override var prefersStatusBarHidden : Bool {
        return true
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
            let height = collectionView.frame.size.height/2 - cellSpacingsInStoryboard
            return CGSize(width: width, height: height)
        }
        else { // portrait mode
            // 3 rows of 1
            let width = collectionView.frame.size.width - cellSpacingsInStoryboard
            let height = collectionView.frame.size.height/3 - cellSpacingsInStoryboard
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
                
                print(" CollectionViewController.swift - Header Formatting: ArtistImage Colors Were Used")
                
                // add todays date to the app icon
                headerView.labelTodaysDate.text = dataDateToday
                
                // add color to the app icon, working through the image colors until I find something dark
                var imageColorDark: UIColor
                if (self.colorsFromFirstArtistImage?.primaryColor.isDark())! {
                    imageColorDark = (self.colorsFromFirstArtistImage?.primaryColor)!
                } else {
                    if (self.colorsFromFirstArtistImage?.secondaryColor.isDark())! {
                        imageColorDark = (self.colorsFromFirstArtistImage?.secondaryColor)!
                    } else {
                        if (self.colorsFromFirstArtistImage?.detailColor.isDark())! {
                            imageColorDark = (self.colorsFromFirstArtistImage?.detailColor)!
                        } else {
                            if (self.colorsFromFirstArtistImage?.backgroundColor.isDark())! {
                                imageColorDark = (self.colorsFromFirstArtistImage?.backgroundColor)!
                            } else {
                                imageColorDark = backgroundColorDarker
                                
                            }
                        }
                    }
                }
                headerView.viewColoredBackground.backgroundColor = imageColorDark
                headerView.labelTodaysDate.backgroundColor = imageColorDark
 
                // add border to app icon, garbage collecting any borders added at any earlier point
                headerView.viewColoredBackground.layer.removeAllBorders()
                let borderColor = backgroundColorDarker
                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: 1.0)
                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: 1.0)
                headerView.labelTodaysDate.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: 1.0)
                headerView.labelTodaysDate.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: 1.0)
                headerView.labelTodaysDate.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor, thickness: 1.0)
                
                // add topShadow to app icon, garbage collecting any sublayers inserted at any earlier point
                // the .forEach is better here because it works with the sublayers optional value
                headerView.viewColoredBackground.layer.sublayers?.forEach {
                    if $0.name == "topShadow" {
                        $0.removeFromSuperlayer()
                    }
                }
                let gradient = CAGradientLayer()
                gradient.name = "topShadow"
                gradient.frame = CGRect(x: 0, y: 0, width: headerView.viewColoredBackground.frame.width, height: headerView.viewColoredBackground.frame.height / 5)
                let startColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.10)
                let endColor = UIColor.clear
                gradient.colors = [startColor.cgColor, endColor.cgColor]
                headerView.viewColoredBackground.layer.insertSublayer(gradient, at: 0)
                
                // add the venues.  I don't think I should do this every time the header renders though
                headerView.labelVenueList.text = ""
                headerView.labelVenueList.numberOfLines = 0
                var venueCount = 0
                for currentEvent in (self.lineUp?.events)! {
                    if (currentEvent.eventHappeningTonight) {
                        
                        if venueCount == 6 {
                            headerView.labelVenueList.text = headerView.labelVenueList.text! + "& More"
                            break
                        } // end if
                        
                        headerView.labelVenueList.text = headerView.labelVenueList.text! + currentEvent.venue! + "\r"
                        headerView.labelVenueList.numberOfLines += 1
                        venueCount += 1
                    } // end if
                } // end for
                
                // when there's no events today, a single blank event gets added to the events array
                // with the venue set to "noVenuesToday"
                if self.lineUp?.events[0].venue == "noVenuesToday" {
                    headerView.labelVenueList.text = "No Shows,\r\nThat Blows..."
                }

                // Set the line height for venues
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2.25
                let attrString = NSMutableAttributedString(string: headerView.labelVenueList.text!)
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                headerView.labelVenueList.attributedText = attrString
                
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
    
        // hide the cell so we can fade it in once it's ready
        cell.alpha = 0
        
        // Add artist image, name, and venue
        cell.imgViewArtist.image = self.lineUp?.events[indexPath.row].imgArtist
        cell.labelArtistAndVenue.text = (self.lineUp?.events[indexPath.row].artist)! + " / " + (self.lineUp?.events[indexPath.row].venue)!
        cell.labelArtistAndVenue.backgroundColor = backgroundColorDarker
        
        // add border, garbage collecting any that may have already been created
        cell.layer.removeAllBorders()
        let borderColor = backgroundColorDarker
        cell.layer.addBorder(edge: UIRectEdge.top, color: borderColor, thickness: 1.0)
        cell.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: 1.0)
        cell.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor, thickness: 1.0)
        cell.imgViewArtist.layer.removeAllBorders()
        cell.imgViewArtist.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: 1.0)

        // add topShadow, garbage collecting any gradient sublayers inserted at any earlier point
        // the .forEach is better here because it works with the sublayers optional value
        cell.imgViewArtist.layer.sublayers?.forEach {
            if $0.name == "topShadow" {
                $0.removeFromSuperlayer()
            }
        }
        let gradient = CAGradientLayer()
        gradient.name = "topShadow"
        gradient.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height / 5)
        let startColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.10)
        let endColor = UIColor.clear
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        cell.imgViewArtist.layer.insertSublayer(gradient, at: 0)
        
        // fade the cell into view
        UIView.animate(withDuration: 0.5, animations: { cell.alpha = 1 })
        
        if eventsLoaded == false {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
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

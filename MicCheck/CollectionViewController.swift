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

    var lineUp: EventLineup?
    var eventsLoaded: Bool = false // keeps track of when everything is loaded
    let cellSpacingsInStoryboard: CGFloat = 8 * 2 // spacing * 2 edges
    var colorsFromFirstArtistImage: UIImageColors? = nil  // colors from the first artist image
    let backgroundColorDarker = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
    var dateToday: String = ""
    
    var viewBackgroundGradient: UIView!
    var viewRadialGradientBackground: RadialGradientView!
    
    var imageStageView: UIImageView!
    var cachedImageViewSize: CGRect!
    
    var gradientLayerAdded: CALayer?  // reference gradient later when changing size on rotations
    
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.

        // if I don't use this, the collectionview will be too low on the screen.
        self.automaticallyAdjustsScrollViewInsets = false

        // create the array of ken burns images to iterate through
        let images = [
            UIImage(named: "empty.stage")!,
            UIImage(named: "guitarist.mountain.oasis")!,
            UIImage(named: "guitarist.on.stage")!,
            UIImage(named: "edm")!,
            UIImage(named: "jazz.horns")!
        ]
        self.kenBurnsView.animateWithImages(images, imageAnimationDuration: 5, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
        
        // get todays date
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

        dateToday = convertedDay + " " + convertedMonth + "/" + convertedDate

        print(" CollectionViewController.swift – 1 of 5: Main Queue - Starting EventLineup() Instance")
        
        // create the model, starting with placeholder data
        self.lineUp = EventLineup.sharedInstance

        // Add background color to the collectionView
        self.collectionView?.backgroundColor = backgroundColorDarker

        // start cranking through the events in a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            
            print(" CollectionViewController.swift – 2 of 5: Global Queue - Starting filterTodaysEvents()")
            self.lineUp?.filterTodaysEvents() // this filter will return nothing if in test mode

            print(" CollectionViewController.swift – 3 of 5: Global Queue - Finish filterTodaysEvents(), Starting getColorsForArtistImage()")

            // get the colors for the first image since we'll need them for the main UI thread
            self.colorsFromFirstArtistImage = self.lineUp?.events[0].getColorsForArtistImage()

            
            
            
            print(" CollectionViewController.swift – 4 of 5: Global Queue - Finish getColorsForArtistImage(), Starting Main Thread")

            // create a blurred background image of an empty stage using artist colors
//            let imageStage = UIImage(named: "empty.stage")
//            let blurRadius = 5
//            let imageToBlur = CIImage(image: imageStage!)
//            let blurfilter = CIFilter(name: "CIGaussianBlur")
//            blurfilter?.setValue(imageToBlur, forKey: "inputImage")
//            blurfilter?.setValue(blurRadius, forKey: "inputRadius")
//            let resultImage = blurfilter?.value(forKey: "outputImage") as! CIImage
//            let blurredImage = UIImage(ciImage: resultImage)

            
            
            
            // the .multiply blendMode is giving me some trouble when the background color is really dark.
            // essentially, it blocks the underlying gradient from appearing.
            // maybe I could check to see if background color is dark and if it is, just do a .hue blendMode instead
            
            //            let imgBlended = UIImage.blend(image: blurredImage, color: (self.colorsFromFirstArtistImage?.backgroundColor)!, mode: .multiply)
            
            DispatchQueue.main.async {

                print(" CollectionViewController.swift – 5 of 5: Main Queue – Starting reloadData()")

                // set flag so that I'll know how to let UI respond later
                self.eventsLoaded = true

                // show only events filtered for today
                self.collectionView?.reloadData()

                // move the ken burns animations to the back
                self.kenBurnsView.stopAnimation()
                self.collectionView?.sendSubview(toBack: self.kenBurnsView)
                self.kenBurnsView.alpha = 0

                // create a radial gradient background just behind the CollectionViewHeader and the first collectionViewCell
                
                // attempting to create a new radial background programmatically
                let backgroundColorDarker = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)

                
                let newColors: [UIColor] = [self.colorsFromFirstArtistImage!.primaryColor, backgroundColorDarker]

                self.viewRadialGradientBackground = RadialGradientView(frame: CGRect(x: 0, y: -(self.collectionView?.bounds.height)! / 2.0,
                                                                   width: (self.collectionView?.bounds.width)!, height: (self.collectionView?.bounds.height)!))
                self.viewRadialGradientBackground.colors = newColors
                
                
//                self.viewRadialGradientBackground.frame.size = self.view.frame.size
//                self.viewRadialGradientBackground.frame.origin = CGPoint(x: 0.0, y: 0.0)
//                self.viewRadialGradientBackground.colors = newColors
//                self.view.layer.insertSublayer(self.viewRadialGradientBackground, at: 0)

                

                
                // create a gradient background just behind the CollectionViewHeader and the first collectionViewCell
                self.viewBackgroundGradient = UIView(frame: CGRect(x: 0, y: -(self.collectionView?.bounds.height)! / 2.0,
                                                   width: (self.collectionView?.bounds.width)!, height: (self.collectionView?.bounds.height)!))

//                let topColor = self.colorsFromFirstArtistImage?.primaryColor
//                let bottomColor = self.colorsFromFirstArtistImage?.secondaryColor
//                let gradientColors: [CGColor] = [topColor!.cgColor, bottomColor!.cgColor]
//                let gradientLocations: [Float] = [0.0, 1.0]
//                let gradientLayer: CAGradientLayer = CAGradientLayer()
//                gradientLayer.colors = gradientColors
//                gradientLayer.locations = gradientLocations as [NSNumber]?
//                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//                gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//                gradientLayer.frame.size = self.viewBackgroundGradient.frame.size
//                gradientLayer.frame.origin = CGPoint(x: 0.0, y: 0.0)
//                self.viewBackgroundGradient.backgroundColor = UIColor.clear
//                self.viewBackgroundGradient.layer.insertSublayer(gradientLayer, at: 0)
                
                // add a bottom border to the background, using the lighter of the two colorsFromFirstArtistImage
                var borderColor = self.colorsFromFirstArtistImage?.primaryColor!
                if (borderColor?.isDark())! {
                    borderColor = self.colorsFromFirstArtistImage?.backgroundColor!
                }
//                self.viewBackgroundGradient.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor!, thickness: 1.0)
                

//                self.imageStageView = UIImageView(image: imgBlended!)
//                self.imageStageView.clipsToBounds = true
//                self.imageStageView.contentMode = .center
//                self.imageStageView.frame = CGRect(x: 0, y: self.viewBackgroundGradient.frame.size.height / 2.0, width: self.viewBackgroundGradient.frame.size.width, height: self.viewBackgroundGradient.frame.size.height / 2.0)
//                self.cachedImageViewSize = self.imageStageView.frame;
//                
//                
//                // use a more opaque background image if the gradient colors are not dark
//                self.imageStageView.alpha = 0.35
//                if (!(self.colorsFromFirstArtistImage?.primaryColor?.isDark())! && !(self.colorsFromFirstArtistImage?.secondaryColor?.isDark())!) {
//                    print(" CollectionViewController.swift – Light background colors.  Using more opaque imageStageView")
//                    self.imageStageView.alpha = 0.80
//                }
                
                
                // send our newly constructed background to the back of the stack
//                self.viewBackgroundGradient.addSubview(self.imageStageView)
//                self.collectionView?.addSubview(self.viewBackgroundGradient)
//                self.collectionView?.sendSubview(toBack: self.viewBackgroundGradient)
  
                self.collectionView?.addSubview(self.viewRadialGradientBackground)
                self.collectionView?.sendSubview(toBack: self.viewRadialGradientBackground)

                
                // chug through the rest of the artist images.  runs in a separate background thread in global queue
                self.lineUp?.getColorsForArtistImages()

                // chug through the rest of the artist descriptions.  runs in a separate background thread in global queue
                self.lineUp?.getArtistDescriptions()
                
            } // end Dispatch.main.sync

        } // end Dispatch.global
    
        // print(" CollectionViewController – viewDidLoad() called")
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
                
                // add the border to the app icon, using lightest of two colorsFromFirstArtistImage
//                var borderColor = self.colorsFromFirstArtistImage!.primaryColor!
                
                // I think I need to clear them first so that the alphas don't add up as they get reused
                // I wrote this removeAllBorders function but it may be too crappy
                headerView.viewColoredBackground.layer.removeAllBorders()
                
                var borderColor = UIColor.white.withAlphaComponent(0.10)
//                if borderColor.isDark() {
//                    borderColor = colorsFromFirstArtistImage!.backgroundColor!
//                }
//                if borderColor.isDark() {
//                    borderColor = colorsFromFirstArtistImage!.secondaryColor!
//                }
//                if borderColor.isDark() {
//                    borderColor = colorsFromFirstArtistImage!.detailColor!
//                }
                
//                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.top, color: borderColor, thickness: 1.0)
//                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: 1.0)
//                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor, thickness: 1.0)
//                headerView.viewColoredBackground.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: 1.0)
                
                // EXPERIMENT: Set the app icon to color tint.
                // I'm not sure it will work well in all cases though because it's sometimes too dark
                // borderColor = self.colorsFromFirstArtistImage!.primaryColor!
                // headerView.imgViewAppIcon.image = headerView.imgViewAppIcon.image!.maskWithColor(color: borderColor)

                
                // Trying to decide if I want a gradient on the App icon
                // var newGradientLayerAdded: CALayer?  // reference gradient later when changing size on rotations
                
                // let topColor = coloredBackground.secondaryColor
                // let bottomColor = coloredBackground.primaryColor
                // let gradientColors: [CGColor] = [topColor!.cgColor, bottomColor!.cgColor]
                // let gradientLocations: [Float] = [0.0, 1.0]
                // let gradientLayer: CAGradientLayer = CAGradientLayer()
                // gradientLayer.colors = gradientColors
                // gradientLayer.locations = gradientLocations as [NSNumber]?
                // gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
                // gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
                // gradientLayer.frame.size = headerView.viewColoredBackground.frame.size
                //gradientLayer.frame.origin = CGPoint(x: 0.0, y: 0.0)
                //headerView.viewColoredBackground.backgroundColor = coloredBackground.detailColor.withAlphaComponent(0.15)
                //headerView.viewColoredBackground.backgroundColor = UIColor.clear
                //headerView.viewColoredBackground.layer.insertSublayer(gradientLayer, at: 0)
                
                //headerView.viewColoredBackground.backgroundColor = borderColor.withAlphaComponent(0.15)
                //headerView.viewColoredBackground.backgroundColor = self.colorsFromFirstArtistImage?.detailColor.withAlphaComponent(0.15)

                // work through the image colors until I find something dark
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
                
                // update the venues.  I don't think I should do this every time the header renders, so maybe I'll move it up later.
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
                                
                // update todays date
                headerView.labelTodaysDate.text = dateToday
                //headerView.labelTodaysDate.textColor = borderColor
                
                
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
    
        // hide the cell
        cell.alpha = 0
        
        // Configure the cell
        cell.imgViewArtist.image = self.lineUp?.events[indexPath.row].imgArtist

        cell.labelArtistAndVenue.text = (self.lineUp?.events[indexPath.row].artist)! + " / " + (self.lineUp?.events[indexPath.row].venue)!

        cell.labelArtistAndVenue.backgroundColor = backgroundColorDarker
        
        // add the border
//        let coloredBackground = self.lineUp?.events[indexPath.row].getColorsForArtistImage()
//        
//        var borderColor = coloredBackground?.primaryColor!.withAlphaComponent(0.10)
//        if (borderColor?.isDark())! {
//            //borderColor = UIColor.white.withAlphaComponent(0.75)
//            borderColor = UIColor.white.withAlphaComponent(0.10)
//        }

        // I think I need to clear them first so that the alphas don't add up as they get reused
        // I wrote this removeAllBorders function but it may be too crappy
        cell.layer.removeAllBorders()
        
        let borderColor = UIColor.white.withAlphaComponent(0.10)
//        cell.labelArtist.layer.addBorder(edge: UIRectEdge.right, color: borderColor!, thickness: 1.0)
        
        //headerView.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.black, thickness: 2.0)
        cell.layer.addBorder(edge: UIRectEdge.top, color: borderColor, thickness: 1.0)
        cell.layer.addBorder(edge: UIRectEdge.right, color: borderColor, thickness: 1.0)
        cell.layer.addBorder(edge: UIRectEdge.bottom, color: borderColor, thickness: 1.0)
        cell.imgViewArtist.layer.removeAllBorders()
        cell.imgViewArtist.layer.addBorder(edge: UIRectEdge.left, color: borderColor, thickness: 1.0)

        
//        let tempBorderColor = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
//        cell.labelArtist.layer.addBorder(edge: UIRectEdge.left, color: tempBorderColor, thickness: 1.0)

        // I'm not sure what this does
        // cell.sendSubview(toBack: cell.imgViewArtist)

        // fade the cell into view once it's configured
        UIView.animate(withDuration: 0.5, animations: { cell.alpha = 1 })
        
        if eventsLoaded == false {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // EXPERIMENT: this doesn't quite work right.  I really want the image to expand more when you pull down, but for now it's better than nothing...
        
//        let y: CGFloat = -scrollView.contentOffset.y
//        if y > 0 {
//
//            let muliplier = y * 5
//            
//            self.imageStageView.frame = CGRect(x: 0, y: scrollView.contentOffset.y + self.view.frame.height / 2.0, width: self.cachedImageViewSize.size.width + muliplier, height: self.cachedImageViewSize.size.height + y)
//        
//            self.imageStageView.center = CGPoint(x: self.view.center.x, y: self.imageStageView.center.y)
//        }
        
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

//
//  DataViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import UIImageColors
import KenBurns

class DataViewController: UIViewController {

    let lineUp = EventLineup.sharedInstance
    var dataArtist: String = ""
    var dataDescriptionArtist: String = ""
    var dataImgArtist: UIImage!
    var dataVenue: String = ""
    var dataPrice: String = ""
    var dataIntEventIndex: Int = 0
    var dataStrVIDs: Array<String> = []
    var dataColorsImgArtist: UIImageColors?
    var swipeDirection: String = ""
    
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var imgViewArtist: UIImageView!
    @IBOutlet weak var stackViewLabels: UIStackView!
    let kenBurnsImageView = KenBurnsImageView()
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelVenueAndPrice: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet var labelNoVideosFound: UILabel!
    @IBOutlet var viewVideoPlayerTopLeft: YTPlayerView!
    @IBOutlet var viewVideoPlayerTopRight: YTPlayerView!

    // viewDidLoad is things you have to do once.  it occures before viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // viewWillAppear gets called every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("  DataViewController.swift – viewWillAppear() called for \(dataArtist)")

        let backgroundColorDarker = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
        self.view.backgroundColor = backgroundColorDarker
        
        self.labelArtist.text = dataArtist
        self.imgViewArtist.image =  dataImgArtist
        self.labelVenueAndPrice.text = dataVenue
        if dataPrice != "" {
            self.labelVenueAndPrice.text = dataVenue + " / " + dataPrice
        }
        
        // EXPERIMENT: I think we need to keep setting the label at this point so that when I do the animation I have the proper size for the label
        if dataDescriptionArtist != "" {
            self.labelDescription.text = dataDescriptionArtist
        } else {
            
            // I'm using a StackView with ContentHugging Priorities to get the artistImage and other fields to adjust to the vacant space when description isn't available.
            // EXPERIMENT: It still doesn't work when the description is null and I'm not in testMode.
            // Going to try and just leave it null to see how it lays out.
            // I think the reason why this experiment succeeded was because I set the label equal to the data value in the first few lines of the code.
            self.labelDescription.text = dataDescriptionArtist
            self.labelDescription.isHidden = true
            //                        self.labelDescription.sizeToFit()
            //                        self.labelDescription.numberOfLines = 0
            
        }
        
        // setup the mask for the artist image
        let shadowSize: CGFloat = 50.0
        let maskLayer = CAGradientLayer()
        maskLayer.frame = CGRect(x: -shadowSize, y: -shadowSize, width: imgViewArtist.frame.width + shadowSize * CGFloat(5.0), height: imgViewArtist.frame.height)
        maskLayer.shadowRadius = shadowSize
        maskLayer.shadowPath = CGPath(rect: maskLayer.frame, transform: nil)
        maskLayer.shadowOpacity = 1;
        maskLayer.shadowOffset = CGSize(width: 0, height: 0)
        maskLayer.shadowColor = UIColor.white.cgColor
        imgViewArtist.layer.mask = maskLayer;
        
        let currentEvent = lineUp.events[dataIntEventIndex]

        // Use artists image to assign colors, if available.  If not, use a background thread so that the image processing won't slow down paging
        DispatchQueue.global(qos: .userInitiated).async {
        
            if let colorsFromArtistImage = currentEvent.getColorsForArtistImage() {

                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {
                    
                    self.viewContainer.backgroundColor = colorsFromArtistImage.backgroundColor
                    if (self.navigationController != nil) {
                        self.navigationController?.navigationBar.tintColor = colorsFromArtistImage.secondaryColor;
                    }
                    //self.labelArtist.textColor = colorsFromArtistImage.primaryColor
                    self.labelVenueAndPrice.textColor = colorsFromArtistImage.secondaryColor
                    self.labelDescription.textColor = colorsFromArtistImage.detailColor
                    self.labelNoVideosFound.textColor = colorsFromArtistImage.detailColor
                    
                } // end Dispatch.main
                
            } else {

                print(" DataViewController.swift - No Artist Image Colors Available for Formatting ")
                
            } // end else
            
            if let artistDescription = currentEvent.getArtistDescription(testMode: self.lineUp.testMode) {
                
                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {
                    
                    if artistDescription != "" {
                        self.labelDescription.text = artistDescription
                        print("  DataViewController.swift – Show description")
                    } else {
                        
                        // I'm using a StackView with ContentHugging Priorities to get the artistImage and other fields to adjust to the vacant space when description isn't available.
                        // EXPERIMENT: It still doesn't work when the description is null and I'm not in testMode.  
                        // Going to try and just leave it null to see how it lays out.
                        self.labelDescription.text = artistDescription
                        self.labelDescription.isHidden = true
                        print("  DataViewController.swift – Hide description")
                        
                    }
                    
                } // end Dispatch.main
                
            } else {
                
                print("  DataViewController.swift - No Description Available for Formatting ")
                
            } // end else
            
        } // end Dispatch.global

        // Grab a description of the artist from the Wikipedia API asynchronously.  When it's finished, use it in our UI
        // closures have a syntax: { (parameters) -> return type in statements }
        // you can tack closures at the end of the function call and it will be passed to the function just like a parameter
//        currentEvent.getDescriptionForArtist() { (strDescription, error) -> Void in
//
//            if error != nil{
//                print(error as Any)
//            }
//            else {
//                
//                // To update anything on the main thread, just jump back on like so.
//                DispatchQueue.main.async {
//                    
//                    // populate the label with the description, otherwise, just hide it.  Not sure how this affects constraints.
//                    if strDescription != nil && strDescription != "" {
//                        self.labelDescription.text = strDescription
//                        print(" DataViewController.swift – Show description")
//                    } else {
//                        
//                        // I'm using a StackView with ContentHugging Priorities to get the artistImage and other fields to adjust to the vacant space when description isn't available.
//                        self.labelDescription.isHidden = true
//                        print(" DataViewController.swift – Hide description")
//
//                    }
//
//                } // end Dispatch.main.sync
//                
//            } // end if
//            
//        }
        
    
        // fetch the artist videos and load them into the Event object
        currentEvent.getVideosForArtist() { (strVIDs, error) -> Void in
            
            if error != nil{
                print(error as Any)
            }
            else {
                
                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {

                    // load the video thumbs onto the page
                    self.loadVideoThumbs(strVIDs: strVIDs)

                    print("  DataViewController.swift – Video Thumbs Loaded")
                } // end Dispatch.main.sync
                
            } // end if

        } // end getVideoForArtist() completion handler

//        self.labelArtist.alpha = 0
//        self.labelVenue.alpha = 0
//        self.labelPrice.alpha = 0
        
//        let labelAnimationOffsetBegin: CGFloat = 100
//        if self.swipeDirection == "up" {

            //print(" DataViewController.swift – swipe direction UP")
            
//            UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
//                
//                self.labelArtist.center.y += labelAnimationOffsetBegin
//                self.labelArtist.alpha = 1
//                self.labelVenue.center.y += labelAnimationOffsetBegin
//                self.labelVenue.alpha = 1
//                self.labelPrice.center.y += labelAnimationOffsetBegin
//                self.labelPrice.alpha = 1
                
//            }, completion: nil)
            
//        } else if self.swipeDirection == "down" {

            //print(" DataViewController.swift – swipe direction DOWN")
            
//            UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {

//                self.labelArtist.center.y -= labelAnimationOffsetBegin
//                self.labelArtist.alpha = 1
//                self.labelVenue.center.y -= labelAnimationOffsetBegin
//                self.labelVenue.alpha = 1
//                self.labelPrice.center.y -= labelAnimationOffsetBegin
//                self.labelPrice.alpha = 1
                
//            }, completion: nil)
        
//        }
        
    } // end viewWillAppear()
    
    func animateControlsIn(controlsDeltaY: CGFloat) {
        
        let shadowSize: CGFloat = 40.0
        
        // debugging
        // print("\r\n \r\n \(currentDataViewController.dataArtist)")
        // print(" imgViewArtist.frame.width is : \(currentDataViewController.imgViewArtist.frame.width)")
        // print(" selectedCell.frame.width is : \(selectedCell.frame.width)")
        // print(" convertedCoordinateY is : \(convertedCoordinateY!)")
        // print(" heroFinalHeight / 2 is : \(heroFinalHeight / 2)")
        // print(" deltaY is : \(deltaY)")
        if controlsDeltaY == 40.0 {
            // positive values (20.0) mean swipe down
            print("  DataViewController.swift – SWIPE DOWN")
        } else if controlsDeltaY == -40 {
            // negative values (-20.0) mean swipe up
            print("  DataViewController.swift – SWIPE UP")
        }
        
        // setup the mask for the artist image intially offset so we can move it in later
//        let maskLayer = CAGradientLayer()
//        maskLayer.frame = CGRect(x: -shadowSize, y: -shadowSize, width: self.imgViewArtist.frame.width + shadowSize * CGFloat(5.0), height: self.imgViewArtist.frame.height)
//        maskLayer.shadowRadius = shadowSize
//        maskLayer.shadowPath = CGPath(rect: maskLayer.frame, transform: nil)
//        maskLayer.shadowOpacity = 1;
//        maskLayer.shadowOffset = CGSize(width: 0, height: 0)
//        maskLayer.shadowColor = UIColor.white.cgColor
//        self.imgViewArtist.layer.mask = maskLayer;
        
        // hide controls initially so that we can fade them back in
        hideElementsForPushTransition()
        
        // offset the controls initially before we move them later, they won't be offset
        self.labelArtist.frame.origin.y += controlsDeltaY
        self.labelVenueAndPrice.frame.origin.y += controlsDeltaY
        self.labelDescription.frame.origin.y += controlsDeltaY
        self.viewVideoPlayerTopLeft.frame.origin.y += controlsDeltaY
        self.viewVideoPlayerTopRight.frame.origin.y += controlsDeltaY
        
        // fade the controls, shadow, and move them all into the proper view
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            
//            maskLayer.shadowOffset = CGSize(width: 0, height: -shadowSize)                

            self.labelArtist.alpha = 1.0
            self.labelVenueAndPrice.alpha = 1.0
            self.labelDescription.alpha = 1.0
            self.viewVideoPlayerTopLeft.alpha = 1.0
            self.viewVideoPlayerTopRight.alpha = 1.0
            
            self.labelArtist.frame.origin.y -= controlsDeltaY
            self.labelVenueAndPrice.frame.origin.y -= controlsDeltaY
            self.labelDescription.frame.origin.y -= controlsDeltaY
            self.viewVideoPlayerTopLeft.frame.origin.y -= controlsDeltaY
            self.viewVideoPlayerTopRight.frame.origin.y -= controlsDeltaY
            //for view in autoLayoutViews { view.layoutIfNeeded() }
            
        }) { finished in
            
            self.startKenBurnsAnimation()
//            print("   DataViewController.swift – animateControlsIn() finished animation")
            //collectionVC.collectionView?.deselectRowAtIndexPath(indexPath, animated: false)
            
        } // end finished in
        
    } // end animateControlsIn()
    
    func loadVideoThumbs(strVIDs: Array<String>?) {
        
        // if the model is empty now then it's because there were no videos returned by the YouTube API
        guard (strVIDs?.count)! > 0 else {
            
            // Fade out the the video thumbs
            self.viewVideoPlayerTopLeft.alpha = 0
            self.viewVideoPlayerTopRight.alpha = 0

            // Fade in the "No videos found" label
            labelNoVideosFound.isHidden = false
            labelNoVideosFound.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                self.labelNoVideosFound.alpha = 1
            }, completion: nil)

            return

        } // end guard

        // load the video thumb parameters
        let playervars: [String: Int] = [
            "controls": 0,
            "showinfo": 0,
            "fs": 0,
            "modestbranding": 1
        ]

        // load the video IDs into the YTPlayerViews
        let viewVideoPlayers = [self.viewVideoPlayerTopLeft,
                                self.viewVideoPlayerTopRight]
        var intVIDIndex = 0

        for currentViewVideoPlayer in viewVideoPlayers {
            
            // check to see if each exists and if so, fade it in
            if (strVIDs?.count)! > intVIDIndex {
                currentViewVideoPlayer?.load(withVideoId: strVIDs![intVIDIndex], playerVars: playervars)
            } else {
                currentViewVideoPlayer?.alpha = 0
            } // end if

            intVIDIndex += 1
            
        } // end for
        
    } // end loadVideoThumbs()
    
    func startKenBurnsAnimation() {

        kenBurnsImageView.setImage(self.imgViewArtist.image!)
        kenBurnsImageView.zoomIntensity = 0.25
        kenBurnsImageView.setDuration(min: 10, max: 13)
        kenBurnsImageView.frame.size = self.imgViewArtist.frame.size
        
        // only add the kenBurns subview if it's not already added
        if !kenBurnsImageView.isDescendant(of: self.imgViewArtist) {
            self.imgViewArtist.addSubview(kenBurnsImageView)
        }

        self.imgViewArtist.bringSubview(toFront: kenBurnsImageView)
        kenBurnsImageView.startAnimating()
        
    } // end newKenBurnsImageView()
    
    func stopKenBurnsAnimation() {
        kenBurnsImageView.stopAnimating()
//        self.imgViewArtist.willRemoveSubview(kenBurnsImageView)
    }

    func hideElementsForPushTransition() {
        
        // hide the elements on the DataViewController
//        self.imgViewArtist.alpha = 0.0
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
}

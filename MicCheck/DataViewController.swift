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
import Material

class DataViewController: UIViewController {
    
    // data variables
    let lineUp = EventLineup.sharedInstance
    var dataArtist: String = ""
    var dataDescriptionArtist: String = ""
    var dataImgArtist: UIImage!
    var dataVenue: String = ""
    var dataPrice: String = ""
    var dataIntEventIndex: Int = 0
    var dataStrVIDs: Array<String> = []
    var dataColorsImgArtist: UIImageColors?
    var dataURLEvent: String = ""
    
    // UI variables
    @IBOutlet var viewContainer: UIView!
    @IBOutlet weak var imgViewArtist: UIImageView!
    let kenBurnsImageView = KenBurnsImageView()
    @IBOutlet var viewHeaders: UIView!
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelVenueAndPrice: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet var labelNoVideosFound: UILabel!
    @IBOutlet var viewVideoPlayerLeft: YTPlayerView!
    @IBOutlet var viewVideoPlayerCenter: YTPlayerView!
    @IBOutlet var viewVideoPlayerRight: YTPlayerView!
    @IBOutlet var btnGetTickets: FABButton!
    
    // viewDidLoad is things you have to do once.  it occures before viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up so that tapping the artist image returns to the CollectionView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        self.viewHeaders.isUserInteractionEnabled = true
        self.viewHeaders.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // viewWillAppear gets called every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("  DataViewController.swift – viewWillAppear() called for \(dataArtist)")
        
        // set the page to the proper event
        let currentEvent = lineUp.events[dataIntEventIndex]
        
        // populate the labels
        self.imgViewArtist.image =  dataImgArtist
        self.labelArtist.text = dataArtist
        self.labelVenueAndPrice.text = dataVenue
        if dataPrice != "" {
            self.labelVenueAndPrice.text = dataVenue + " / " + dataPrice
        }
        self.labelDescription.text = dataDescriptionArtist
        
        // Grab artist videos from YouTube API asynchronously.  When it's finished, use it in our UI
        DispatchQueue.global(qos: .userInitiated).async {
            // fetch the artist videos and load them into the Event object
            // closures have a syntax: { (parameters) -> return type in statements }
            // you can tack closures at the end of the function call and it will be passed to the function just like a parameter
            currentEvent.getVideosForArtist() { (strVIDs, error) -> Void in
                if error != nil{
                    print(error as Any)
                } else {
                    DispatchQueue.main.async { // jump back on the main thread to update UI
                        // load the video thumbs onto the page
                        self.loadVideoThumbs(strVIDs: strVIDs)
                        print("  DataViewController.swift – Video Thumbs Loaded")
                    } // end Dispatch.main.sync
                } // end if
            } // end getVideoForArtist() completion handler
        } // end Dispatch.global
        
        
        // Grab artist description from the Wikipedia API asynchronously.  When it's finished, use it in our UI
        DispatchQueue.global(qos: .userInitiated).async {
            if let artistDescription = currentEvent.getArtistDescription(testMode: self.lineUp.testMode) {
                DispatchQueue.main.async { // jump back on the main thread to update UI
                    self.labelDescription.text = artistDescription
                    
                    // increase lineheight of artist description
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 3
                    let attrString = NSMutableAttributedString(string: artistDescription)
                    attrString.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                    self.labelDescription.attributedText = attrString
                } // end Dispatch.main
            } else {
                print("  DataViewController.swift - No Description Available for Formatting ")
            } // end else
        } // end Dispatch.global

        
        // set the colors, gradients, and shadows
        let backgroundColorDarker = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
        self.view.backgroundColor = backgroundColorDarker

        // add topShadow, garbage collecting any gradient sublayers inserted at any earlier point
        // the .forEach is better here because it works with the sublayers optional value
        self.imgViewArtist.layoutIfNeeded()
        self.imgViewArtist.layer.sublayers?.forEach {
            $0.name == "topShadow" ? $0.removeFromSuperlayer() : ()
        }
        let gradient = CAGradientLayer()
        gradient.name = "topShadow"
        gradient.frame = CGRect(x: 0, y: 0, width: self.imgViewArtist.frame.width, height: self.imgViewArtist.frame.height / 5)
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
        let endColor = UIColor.clear
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        self.imgViewArtist.layer.insertSublayer(gradient, at: 0)
        
        // add lower mask for the artist image, using a shadow around perimeter to generage the gradient change
        // intially drawn off the viewport so we can move it in later
        let shadowSize: CGFloat = 60.0
        let maskLayer = CAGradientLayer()
        maskLayer.name = "bottomShadow"
        maskLayer.frame = CGRect(x: -shadowSize, y: -shadowSize, width: self.imgViewArtist.frame.width + shadowSize * CGFloat(5.0), height: self.imgViewArtist.frame.height)
        maskLayer.shadowRadius = shadowSize
        maskLayer.shadowPath = CGPath(rect: maskLayer.frame, transform: nil)
        maskLayer.shadowOpacity = 1;
        maskLayer.shadowOffset = CGSize(width: 0, height: 0)
        maskLayer.shadowColor = UIColor.white.cgColor
        self.imgViewArtist.layer.mask = maskLayer;
        
        
        // Use current event's artist's image colors to assign colors in the UI, if available
        // If not yet available, finish color processing in a background thread so that paging isn't slown down
        DispatchQueue.global(qos: .userInitiated).async {
            if let colorsFromArtistImage = currentEvent.getColorsForArtistImage() {
                DispatchQueue.main.async { // jump back on the main thread to update UI
                    
                    // find a dark background color for the label and button background colors
                    var backgroundColorDark: UIColor
                    if colorsFromArtistImage.primary.isDark() {
                        backgroundColorDark = colorsFromArtistImage.primary
                        print("  DataViewController.swift – used primaryColor")
                    } else {
                        if colorsFromArtistImage.secondary.isDark() {
                            backgroundColorDark = colorsFromArtistImage.secondary
                            print("  DataViewController.swift – used secondaryColor")
                        } else {
                            if colorsFromArtistImage.detail.isDark() {
                                backgroundColorDark = colorsFromArtistImage.detail
                                print("  DataViewController.swift – used detailColor")
                            } else {
                                if colorsFromArtistImage.background.isDark() {
                                    backgroundColorDark = colorsFromArtistImage.background
                                    print("  DataViewController.swift – used backgroundColor")
                                } else {
                                    backgroundColorDark = backgroundColorDarker
                                    print("  DataViewController.swift – used backgroundColorDarker")
                                } // end else
                            } // end else
                        } // end else
                    } // end else

                    // color the controls
                    self.btnGetTickets.backgroundColor = backgroundColorDark
                    self.btnGetTickets.pulseColor = backgroundColorDarker
                    self.labelArtist.backgroundColor = backgroundColorDark
                    self.labelVenueAndPrice.backgroundColor = backgroundColorDark
                    self.labelDescription.textColor = UIColor.white // have to set because it's attributed text

                    // THIS DID NOT WORK
                    // tint the status bar controls to contrast with light or dark background color darkness
                    if colorsFromArtistImage.primary.isDark() {
                        self.navigationController?.navigationBar.tintColor = UIColor.white
                    } else {
                        self.navigationController?.navigationBar.tintColor = UIColor.black
                    }
                } // end Dispatch.main
                
            } else {
                print(" DataViewController.swift - No Artist Image Colors Available for Formatting ")
            } // end else
        } // end Dispatch.global
    } // end viewWillAppear()
    
    func animateControlsIn(controlsDeltaY: CGFloat) {
                
        // debugging
        // print("\r\n \r\n \(currentDataViewController.dataArtist)")
        // print(" imgViewArtist.frame.width is : \(currentDataViewController.imgViewArtist.frame.width)")
        // print(" selectedCell.frame.width is : \(selectedCell.frame.width)")
        // print(" convertedCoordinateY is : \(convertedCoordinateY!)")
        // print(" heroFinalHeight / 2 is : \(heroFinalHeight / 2)")
        // print(" deltaY is : \(deltaY)")
        if controlsDeltaY >= 0 {
            // positive values (20.0) mean swipe down
            print("  DataViewController.swift – SWIPE DOWN")
        } else if controlsDeltaY < 0 {
            // negative values (-20.0) mean swipe up
            print("  DataViewController.swift – SWIPE UP")
        }

        // hide controls initially so that we can fade them back in
        hideElementsForPushTransition()
        
        // offset the controls initially before we move them later, they won't be offset
        self.btnGetTickets.frame.origin.y -= controlsDeltaY
        self.labelArtist.frame.origin.y += controlsDeltaY
        self.labelVenueAndPrice.frame.origin.y += controlsDeltaY
        self.labelDescription.frame.origin.y += controlsDeltaY
        self.viewVideoPlayerLeft.frame.origin.y += controlsDeltaY
        self.viewVideoPlayerCenter.frame.origin.y += controlsDeltaY
        self.viewVideoPlayerRight.frame.origin.y += controlsDeltaY
        
        // fade in the controls, shadow, and move them all into the proper view
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
        
            self.btnGetTickets.alpha = 1.0
            self.labelArtist.alpha = 1.0
            self.labelVenueAndPrice.alpha = 1.0
            self.labelDescription.alpha = 1.0
            self.viewVideoPlayerLeft.alpha = 1.0
            self.viewVideoPlayerCenter.alpha = 1.0
            self.viewVideoPlayerRight.alpha = 1.0
            
            self.btnGetTickets.frame.origin.y += controlsDeltaY
            self.labelArtist.frame.origin.y -= controlsDeltaY
            self.labelVenueAndPrice.frame.origin.y -= controlsDeltaY
            self.labelDescription.frame.origin.y -= controlsDeltaY
            self.viewVideoPlayerLeft.frame.origin.y -= controlsDeltaY
            self.viewVideoPlayerCenter.frame.origin.y -= controlsDeltaY
            self.viewVideoPlayerRight.frame.origin.y -= controlsDeltaY
            
        }) { finished in
            let when = DispatchTime.now() + 5 // 5 second delay
            DispatchQueue.main.asyncAfter(deadline: when) {
                // TODO: Need to get the topShadow to fade off or stay put or something while image animates
                self.startKenBurnsAnimation()
                // print("   DataViewController.swift – animateControlsIn() finished animation")
            } //end DispatchQueue.main.asyncAfter
        } // end finished in
        
    } // end animateControlsIn()
    
    func loadVideoThumbs(strVIDs: Array<String>?) {
        // if the model is empty now then it's because there were no videos returned by the YouTube API
        guard (strVIDs?.count)! > 0 else {

            // Fade out the the video thumbs
            self.viewVideoPlayerLeft.alpha = 0
            self.viewVideoPlayerCenter.alpha = 0
            self.viewVideoPlayerRight.alpha = 0
            
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
        let viewVideoPlayers = [self.viewVideoPlayerLeft,
                                self.viewVideoPlayerCenter,
                                self.viewVideoPlayerRight]
        var intVIDIndex = 0

        // check to see if each exists and if so, fade it in
        for currentViewVideoPlayer in viewVideoPlayers {
            if (strVIDs?.count)! > intVIDIndex {
                currentViewVideoPlayer?.load(withVideoId: strVIDs![intVIDIndex], playerVars: playervars)
            } else {
                currentViewVideoPlayer?.alpha = 0
            } // end if
            intVIDIndex += 1
        } // end for
        
    } // end loadVideoThumbs()
    
    func startKenBurnsAnimation() {

        // set parameters
        kenBurnsImageView.setImage(self.imgViewArtist.image!)
        kenBurnsImageView.zoomIntensity = 0.15
        kenBurnsImageView.setDuration(min: 15, max: 20)
        kenBurnsImageView.frame.size = self.imgViewArtist.frame.size
        
        // only add kenBurns subview if it's not already added
        if !kenBurnsImageView.isDescendant(of: self.imgViewArtist) {
            self.imgViewArtist.addSubview(kenBurnsImageView)
        } // end if
        self.imgViewArtist.bringSubview(toFront: kenBurnsImageView)
        kenBurnsImageView.startAnimating()
    } // end newKenBurnsImageView()
    
    func stopKenBurnsAnimation() {
        kenBurnsImageView.stopAnimating()
        //self.imgViewArtist.willRemoveSubview(kenBurnsImageView)
    } // end stopKenBurnsAnimation()

    // hide elements on the DataViewController
    func hideElementsForPushTransition() {
        self.btnGetTickets.alpha = 0.0
        self.labelArtist.alpha = 0.0
        self.labelVenueAndPrice.alpha = 0.0
        self.labelDescription.alpha = 0.0
        self.viewVideoPlayerLeft.alpha = 0.0
        self.viewVideoPlayerCenter.alpha = 0.0
        self.viewVideoPlayerRight.alpha = 0.0
    } // end hideElementsForPushTransition()

    func viewTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    } // end viewTapped

    @IBAction func gotoEventLink(sender: AnyObject) {
        if let url = URL(string: dataURLEvent) {
            UIApplication.shared.open(url, options: [:])
        } // end if
    } // end @IBAction
    
}

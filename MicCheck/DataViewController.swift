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

class DataViewController: UIViewController {

    let lineUp = EventLineup.sharedInstance
    
    @IBOutlet var viewContainer: UIView!
    
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelIndexOfCount: UILabel!
    
    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelVenue: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imgViewArtist: UIImageView!

    @IBOutlet var labelNoVideosFound: UILabel!
    @IBOutlet var viewVideoPlayerTopLeft: YTPlayerView!
    @IBOutlet var viewVideoPlayerTopRight: YTPlayerView!
    
    var dataArtist: String = ""
    var dataImgArtist: UIImage!
    var dataVenue: String = ""
    var dataPrice: String = ""
    var dataIntEventIndex: Int = 0
    var dataStrVIDs: Array<String> = []
    var dataColorsImgArtist: UIImageColors?
    
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
        self.labelArtist.text = dataArtist
        self.imgViewArtist.image =  dataImgArtist
        self.labelVenue.text = dataVenue
        self.labelPrice.text = dataPrice

        
        let currentEvent = lineUp.events[dataIntEventIndex]

        // Use artists image to assign colors, if available.  If not, use a background thread so that the image processing won't slow down paging
        DispatchQueue.global(qos: .userInitiated).async {
        
            if let colorsFromArtistImage = currentEvent.getColorsForArtistImage() {

                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {
                    
                    self.viewContainer.backgroundColor = colorsFromArtistImage.backgroundColor
                    self.navigationController!.navigationBar.tintColor = colorsFromArtistImage.secondaryColor;
                    self.labelArtist.textColor = colorsFromArtistImage.primaryColor
                    self.labelVenue.textColor = colorsFromArtistImage.secondaryColor
                    self.labelPrice.textColor = colorsFromArtistImage.detailColor
                    self.labelDescription.textColor = colorsFromArtistImage.detailColor
                    self.labelNoVideosFound.textColor = colorsFromArtistImage.detailColor

                } // end Dispatch.main
                
            } else {

                // Assign some colors
                print(" DataViewController.swift - No Artist Image Colors Available for Formatting ")
                
            } // end else
            
        } // end Dispatch.global

        // Grab a description of the artist from the Wikipedia API asynchronously.  When it's finished, use it in our UI
        // closures have a syntax: { (parameters) -> return type in statements }
        // you can tack closures at the end of the function call and it will be passed to the function just like a parameter
        currentEvent.getDescriptionForArtist() { (strDescription, error) -> Void in

            if error != nil{
                print(error as Any)
            }
            else {
                
                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {
                    
                    if strDescription != nil && strDescription != "" {
                        self.labelDescription.text = strDescription
                    }

                } // end Dispatch.main.sync
                
            } // end if
            
        }
        
    
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
                
                } // end Dispatch.main.sync
                
            } // end if

        } // end getVideoForArtist() completion handler
        
    } // end viewWillAppear()

    
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

}


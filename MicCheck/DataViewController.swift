//
//  DataViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 12/20/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class DataViewController: UIViewController {

    let lineUp = EventLineup.sharedInstance
    
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelIndexOfCount: UILabel!

    @IBOutlet weak var labelArtist: UILabel!
    @IBOutlet weak var labelVenue: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!

    @IBOutlet var labelNoVideosFound: UILabel!
    @IBOutlet var viewVideoPlayerTopLeft: YTPlayerView!
    
    var dataArtist: String = ""
    var dataImgArtist: UIImage!
    var dataVenue: String = ""
    var dataPrice: String = ""
    var dataVIDItems: Array<Dictionary<NSObject, AnyObject>> = []
    var dataIntEventIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        // fetch the artist videos
        if dataVIDItems.isEmpty {

            // if the artist videos aren't already in the model then add them to the model
            // callback to load the videos into the DataViewController and update the UI
            // I think I should rewrite getVideosForArtist so that it also grabs the thumbnail images from YouTube and 
            // I'll use those in my Ken Burns transition on the detail page.

            lineUp.events[dataIntEventIndex].getVideosForArtist(completion: { Void in
                
                print("  DataViewController.swift - ViewWillAppear() - callback executing")
                self.dataVIDItems = self.lineUp.events[self.dataIntEventIndex].vIDItems
                
            })
            
        }

        // display the artist videos
        self.loadVideoThumbs()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.labelArtist.text = dataArtist
        self.imgArtist.image =  dataImgArtist
        self.labelVenue.text = dataVenue
        self.labelPrice.text = dataPrice

        // load the video thumb parameters
        let playervars: [String: Int] = [
            "controls": 0,
            "showinfo": 0,
            "fs": 0,
            "modestbranding": 1
        ]
        self.viewVideoPlayerTopLeft.load(withVideoId: "uA0Xja6xem8", playerVars: playervars)
    }

    func loadVideoThumbs() {

        // if the model is empty now then it's because there were no videos returned by the YouTube API
        guard dataVIDItems.count > 0 else {

            // Fade in the "No videos found" label
            labelNoVideosFound.isHidden = false
            labelNoVideosFound.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 1, options: [], animations: {
                self.labelNoVideosFound.alpha = 1
                
            }, completion: nil)

            return

        }
 
        // load the video thumb parameters
        let playervars: [String: Int] = [
            "controls": 0,
            "showinfo": 0,
            "fs": 0,
            "modestbranding": 1
            
        ]
        
        
    }
}


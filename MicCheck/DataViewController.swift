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
    var dataStrVIDs: Array<String> = []
    
    // when you are loading things from a server, you also have to think about latency. If you pack all of your network communication into viewDidLoad or viewWillAppear, they will be executed before the user gets to see the view - possibly resulting a short freeze of your app. It may be good idea to first show the user an unpopulated view with an activity indicator of some sort
    
    // viewDidLoad is things you have to do once.
    // it occures before viewWillAppear
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    

        // display the artist videos
//        self.loadVideoThumbs()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // viewWillAppear gets called every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.labelArtist.text = dataArtist
        self.imgArtist.image =  dataImgArtist
        self.labelVenue.text = dataVenue
        self.labelPrice.text = dataPrice

        // fetch the artist videos and load them into the Event object
        let currentEvent = lineUp.events[dataIntEventIndex]
        
        // closures have s syntax: { (parameters) -> return type in statements }
        // you can tack closures at the end of the function call and it will be passed to the function just like a parameter
        currentEvent.getVideosForArtist() { (strVIDs, error) -> Void in
            
            if error != nil{
                
                print(error as Any)
            }
            else{
                
                // load the video thumbs onto the page
                print(strVIDs![0])
 
                // To update anything on the main thread, just jump back on like so.
                DispatchQueue.main.async {

                    // load the video thumb parameters
                    let playervars: [String: Int] = [
                        "controls": 0,
                        "showinfo": 0,
                        "fs": 0,
                        "modestbranding": 1
                        
                    ]
                    
                    self.viewVideoPlayerTopLeft.load(withVideoId: strVIDs![0], playerVars: playervars)
                
                } // end Dispatch.main.sync
                
            } // end if

        } // end getVideoForArtist() completion handler

    } // end viewWillAppear()

    
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

        } // end guard
        
    } // end loadVideoThumbs()

}


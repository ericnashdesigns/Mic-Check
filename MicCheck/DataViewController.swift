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
    
        // get the videos for the artist and load them into the model
        self.lineUp.events[self.dataIntEventIndex - 0].getVideosForArtist(completion: { Void in
            
            // callback to load the videos into the DataViewController and update the UI
            print("  DataViewController.swift - ViewWillAppear() - callback executing")
            self.dataVIDItems = self.lineUp.events[self.dataIntEventIndex - 1].vIDItems
            self.loadVideoThumbs()
            self.viewVideoPlayerTopLeft.load(withVideoId: "uA0Xja6xem8")
        })
        
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
        
    }

    func loadVideoThumbs() {

        
        
//        print("  DataViewController.swift - loadVideoThumbs() – self.lineUp.events[self.dataIntEventIndex - 1].vIDItems.count = \(self.lineUp.events[self.dataIntEventIndex - 1].vIDItems.count)")
//        
//        // load the video thumb parameters
//        let playervars: [String: Int] = [
//            "controls": 0,
//            "showinfo": 0,
//            "fs": 0,
//            "modestbranding": 1
//            
//        ]
        
        
//        viewVideoPlayerTopLeft.load(withVideoId: self.dataVIDItems[index]["videoID"] as! String)
        
//                    let currentVideo = (self.dataVIDItems[index]["videoID"] as! String)
//                    viewVideoPlayerTopLeft.load(withVideoId: currentVideo, playerVars: playervars)
//
//                }
//                
//                videoIndex += 1
//            }
//            
//            print("  DataViewController.swift - loadVideoThumbs() - videos loaded successfully.")
        
    }
    
    

}


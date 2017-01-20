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

        // load the video thumb parameters
        let playervars: [String: Int] = [
            "controls": 0,
            "showinfo": 0,
            "fs": 0,
            "modestbranding": 1
        ]

        // fetch the artist videos and load them into the Event object
        
        let todoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)

        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
        
        if dataStrVIDs.isEmpty {
            
            print("  DataViewController.swift - dataStrVIDs is empty, so fill it")
            
            // if the artist videos aren't already in the model then add them to the model
            // callback to load the videos into the DataViewController and update the UI
            // I think I should rewrite getVideosForArtist so that it also grabs the thumbnail images from YouTube and
            // I'll use those in my Ken Burns transition on the detail page.
            
            let currentEvent = lineUp.events[dataIntEventIndex]
            
            currentEvent.getVideosForArtist(completion: { Void in
                
                print("  DataViewController.swift - ViewWillAppear() - callback executing")
                self.dataStrVIDs = self.lineUp.events[self.dataIntEventIndex].strVIDs
                print("self.dataStrVIDs[0] = \(self.dataStrVIDs[0])")
                self.viewVideoPlayerTopLeft.load(withVideoId: self.dataStrVIDs[0], playerVars: playervars)
                
            })
            
        } else {
            viewVideoPlayerTopLeft.load(withVideoId: dataStrVIDs[0], playerVars: playervars)
            print("dataStrVIDs was not empty")
        }
        
        
        // load the video thumbs onto the page
        //let videoID = self.dataStrVIDs[0]
        //self.viewVideoPlayerTopLeft.load(withVideoId: videoID, playerVars: playervars)
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

